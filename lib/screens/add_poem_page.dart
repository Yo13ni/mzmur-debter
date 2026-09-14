import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../services/poem_repository.dart';
import '../theme/app_colors.dart';

class AddPoemPage extends StatefulWidget {
  /// When true (bottom tab), hide back button.
  final bool embedded;

  const AddPoemPage({super.key, this.embedded = false});

  @override
  State<AddPoemPage> createState() => _AddPoemPageState();
}

class _AddPoemPageState extends State<AddPoemPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _repo = PoemRepository();

  @override
  bool get wantKeepAlive => true;

  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _loadingCategories = true;
  bool _submitting = false;
  String? _categoriesError;

  static const int _maxChars = 2000;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final cats = await _repo.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.toString();
        _loadingCategories = false;
      });
    }
  }

  Future<void> _savePoem() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('ሁሉንም መስኮች ይሙሉ!', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.createSubmission(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        categoryId: _selectedCategoryId!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'መዝሙሩ ለማረጋገጥ ተልኳል!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      _titleController.clear();
      _contentController.clear();
      setState(() => _selectedCategoryId = null);

      if (!widget.embedded) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'መላክ አልተሳካም: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _selectAll(TextEditingController controller, FocusNode focusNode) {
    focusNode.requestFocus();
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    if (mounted) setState(() {});
  }

  Future<void> _copy(TextEditingController controller) async {
    final text = controller.text;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ተቀድቷል', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _paste(TextEditingController controller,
      {int? maxLength}) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : controller.text.length;
    final end =
        (selection.isValid && !selection.isCollapsed) ? selection.end : start;
    var newText = controller.text.replaceRange(start, end, text);
    if (maxLength != null && newText.length > maxLength) {
      newText = newText.substring(0, maxLength);
    }
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final charCount = _contentController.text.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text('መዝሙር ፃፍ'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const Text(
                    'የመዝሙር ርዕስ',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'ርዕስ ያስገቡ',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'ርዕሱን ያስገቡ' : null,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FieldActions(
                      onSelectAll: () => _selectAll(_titleController, _titleFocusNode),
                      onCopy: () => _copy(_titleController),
                      onPaste: () => _paste(_titleController),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ምድብ',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingCategories)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_categoriesError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ምድቦችን መጫን አልተቻለም: $_categoriesError',
                          style: const TextStyle(color: AppColors.danger),
                        ),
                        TextButton(
                          onPressed: _loadCategories,
                          child: const Text('እንደገና ሞክር'),
                        ),
                      ],
                    )
                  else
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'ምድብ ይምረጡ',
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      validator: (v) => v == null ? 'ምድቡን ይምረጡ' : null,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'የመዝሙር ግጥም',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 14),
                        ),
                      ),
                      Text(
                        '$charCount / $_maxChars',
                        style: TextStyle(
                          fontSize: 12,
                          color: charCount > _maxChars
                              ? AppColors.danger
                              : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    maxLines: 12,
                    maxLength: _maxChars,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'የመዝሙርን ግጥም እዚህ ይጻፉ...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'መዝሙሩን ያስገቡ' : null,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FieldActions(
                      onSelectAll: () =>
                          _selectAll(_contentController, _contentFocusNode),
                      onCopy: () => _copy(_contentController),
                      onPaste: () => _paste(_contentController, maxLength: _maxChars),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _submitting ? null : _savePoem,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('መዝሙሩን ይላኩ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}

class _FieldActions extends StatelessWidget {
  final VoidCallback onSelectAll;
  final VoidCallback onCopy;
  final VoidCallback onPaste;

  const _FieldActions({
    required this.onSelectAll,
    required this.onCopy,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _action(
          icon: Icons.select_all,
          label: 'ሁሉንም ምረጥ',
          onTap: onSelectAll,
        ),
        _action(
          icon: Icons.copy,
          label: 'ቅዳ',
          onTap: onCopy,
        ),
        _action(
          icon: Icons.paste,
          label: 'ለጥፍ',
          onTap: onPaste,
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
