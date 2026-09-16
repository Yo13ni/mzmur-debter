import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/poem_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import 'poem_list_page.dart';

/// Liturgy tab — filters categories related to ቅዳሴ / liturgy.
class KidasePage extends StatefulWidget {
  const KidasePage({super.key});

  @override
  State<KidasePage> createState() => _KidasePageState();
}

class _KidasePageState extends State<KidasePage> {
  final _repo = PoemRepository();
  late Future<List<Category>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Shows cached categories instantly (works offline) while refreshing from
  /// the server in the background.
  void _load() {
    _future = _repo.getCategories();
    _repo.getCategories(forceRefresh: true).then((fresh) {
      if (mounted) setState(() => _future = Future.value(fresh));
    }).catchError((_) {});
  }

  bool _isKidase(Category c) {
    final n = c.name;
    return n.contains('ቅዳሴ') ||
        n.contains('ቤተ') ||
        n.contains('ዘወትር') ||
        n.contains('ንግስ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: AppColors.danger),
                ),
              );
            }

            final all = snapshot.data ?? [];
            final categories = all.where(_isKidase).toList();
            final list = categories.isEmpty ? all : categories;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text(
                  'ቅዳሴ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                ...list.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftCard(
                      color: AppColors.cardLight,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PoemListPage(
                            categoryId: category.id,
                            categoryName: category.name,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.inkMuted),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
