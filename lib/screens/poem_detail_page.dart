import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/poem.dart';
import '../db/db_helper.dart';
import '../providers/app_config.dart';
import '../theme/app_colors.dart';

class PoemDetailPage extends StatefulWidget {
  final Poem poem;
  final int imageIndex;

  const PoemDetailPage({
    required this.poem,
    this.imageIndex = 0,
    super.key,
  });

  @override
  State<PoemDetailPage> createState() => _PoemDetailPageState();
}

class _PoemDetailPageState extends State<PoemDetailPage> {
  final dbHelper = DBHelper();
  late Poem _poem;
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _poem = widget.poem;
    _contentController.text = _poem.content;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _selectAllContent() {
    _contentFocusNode.requestFocus();
    _contentController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _contentController.text.length,
    );
  }

  Future<void> _copyContent() async {
    final text = _poem.content;
    if (text.trim().isEmpty) return;
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

  Future<void> _share() async {
    await Share.share('${_poem.title}\n\n${_poem.content}');
  }

  void _showFontSheet(AppConfig config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'የፊደል መጠን',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _FontChip(
                  label: 'ትንሽ',
                  selected: config.fontSizeLevel == 0,
                  onTap: () => config.setFontSizeLevel(0),
                ),
                _FontChip(
                  label: 'መካከለኛ',
                  selected: config.fontSizeLevel == 1,
                  onTap: () => config.setFontSizeLevel(1),
                ),
                _FontChip(
                  label: 'ትልቅ',
                  selected: config.fontSizeLevel == 2,
                  onTap: () => config.setFontSizeLevel(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);
    const baseFontSize = 18.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  FutureBuilder<bool>(
                    future: _poem.id == null
                        ? Future.value(false)
                        : dbHelper.isPoemFavorite(_poem.id!),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? AppColors.gold : AppColors.ink,
                        ),
                        onPressed: () async {
                          await dbHelper.togglePoemFavorite(_poem);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    if (_poem.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _poem.category,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SelectableText(
                      _poem.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26 * appConfig.fontSizeScale,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1.5,
                      width: double.infinity,
                      color: AppColors.border,
                    ),
                    const SizedBox(height: 24),
                    if (_poem.content.isEmpty)
                      const Text(
                        'ለዚህ መዝሙር ይዘት የለም።',
                        style: TextStyle(color: AppColors.inkMuted),
                      )
                    else
                      TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        readOnly: true,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: baseFontSize * appConfig.fontSizeScale,
                          height: 1.65,
                          color: AppColors.ink,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _DetailAction(
                      icon: Icons.text_fields_rounded,
                      label: 'ፊደል',
                      onTap: () => _showFontSheet(appConfig),
                    ),
                    _DetailAction(
                      icon: Icons.select_all,
                      label: 'ሁሉንም ምረጥ',
                      onTap: _selectAllContent,
                    ),
                    _DetailAction(
                      icon: Icons.copy,
                      label: 'ቅዳ',
                      onTap: _copyContent,
                    ),
                    _DetailAction(
                      icon: Icons.share_outlined,
                      label: 'አጋራ',
                      onTap: _share,
                    ),
                    _DetailAction(
                      icon: Icons.info_outline,
                      label: 'ምድብ',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_poem.category)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.ink, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor:
                selected ? AppColors.cardLight : AppColors.bgDeep,
            foregroundColor: AppColors.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
