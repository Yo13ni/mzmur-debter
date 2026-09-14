import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/category.dart';
import '../models/poem.dart';
import '../services/poem_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/ui_bits.dart';
import 'poem_list_page.dart';
import 'poem_detail_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = PoemRepository();
  final _db = DBHelper();
  final _searchController = TextEditingController();
  String _filter = '';
  late Future<({List<Category> categories, Map<String, int> counts})> _future;
  late final Future<List<Poem>> _allPoems;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _allPoems = _repo.getPoems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<({List<Category> categories, Map<String, int> counts})> _load() =>
      _repo.getCategoriesWithCounts();

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

            if (_filter.isNotEmpty) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: SearchField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _filter = v.trim().toLowerCase()),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Poem>>(
                      future: _allPoems,
                      builder: (context, poemsSnap) {
                        if (poemsSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent),
                          );
                        }
                        if (poemsSnap.hasError) {
                          return const Center(
                            child: Text(
                              'ፍለጋው አልተሳካም።',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          );
                        }
                        final words = _filter
                            .split(RegExp(r'\s+'))
                            .where((w) => w.isNotEmpty)
                            .toList();
                        final results =
                            (poemsSnap.data ?? const <Poem>[]).where((p) {
                          final title = p.title.toLowerCase();
                          final content = p.content.toLowerCase();
                          return words.every((w) =>
                              title.contains(w) || content.contains(w));
                        }).toList();

                        if (results.isEmpty) {
                          return const Center(
                            child: Text(
                              'ምንም መዝሙሮች አልተገኙም።',
                              style: TextStyle(color: AppColors.inkMuted),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final poem = results[index];
                            return FutureBuilder<bool>(
                              future: poem.id == null
                                  ? Future.value(false)
                                  : _db.isPoemFavorite(poem.id!),
                              builder: (context, favSnap) {
                                return HymnListTile(
                                  title: poem.title,
                                  subtitle: poem.category,
                                  imageIndex: index,
                                  isFavorite: favSnap.data ?? false,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PoemDetailPage(
                                        poem: poem,
                                        imageIndex: index,
                                      ),
                                    ),
                                  ),
                                  onFavorite: () async {
                                    await _db.togglePoemFavorite(poem);
                                    setState(() {});
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: SearchField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _filter = v.trim().toLowerCase()),
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
