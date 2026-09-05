import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/poem.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/ui_bits.dart';
import 'poem_list_page.dart';
import 'SearchResultsPage.dart';

class CategoriesPage extends StatefulWidget {
  final VoidCallback? onOpenMore;
  final void Function([String?])? onSearch;

  const CategoriesPage({super.key, this.onOpenMore, this.onSearch});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  late Future<({List<Category> categories, Map<String, int> counts})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<({List<Category> categories, Map<String, int> counts})> _load() async {
    final categories = await _api.getCategories();
    final poems = await _api.getPoems();
    final counts = <String, int>{};
    for (final Poem p in poems) {
      final id = p.categoryId;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return (categories: categories, counts: counts);
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<
            ({List<Category> categories, Map<String, int> counts})>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ሰርቨሩን ማግኘት አልተቻለም።\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('እንደገና ሞክር'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final categories = snapshot.data!.categories;
            final counts = snapshot.data!.counts;

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: SoftCard(
                        color: AppColors.card,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                color: AppColors.ink, size: 26),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'የመዝሙር ደብተር',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded,
                                  color: AppColors.ink),
                              onPressed: widget.onOpenMore,
                              tooltip: 'ተጨማሪ',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: SearchField(
                        controller: _searchController,
                        onSubmitted: (q) {
                          if (q.trim().isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchResultsPage(query: q.trim()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (categories.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'ምንም ምድብ የለም',
                          style: TextStyle(color: AppColors.inkMuted),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final count = counts[category.id] ?? 0;
                          return SoftCard(
                            color: AppColors.card,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PoemListPage(
                                  categoryId: category.id,
                                  categoryName: category.name,
                                ),
                              ),
                            ).then((_) => _refresh()),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$count መዝሙሮች',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
