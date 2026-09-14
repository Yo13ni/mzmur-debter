import 'package:flutter/material.dart';
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

  Future<void> _share() async {
    await Share.share('${_poem.title}\n\n${_poem.content}');
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
                          filled: false,
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
