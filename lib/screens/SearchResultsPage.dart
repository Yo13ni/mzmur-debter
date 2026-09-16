import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import '../services/poem_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';
import 'poem_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController _controller;
  late String _query;
  late Future<List<Poem>> _searchFuture;
  final _db = DBHelper();

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _controller = TextEditingController(text: widget.query);
    _runSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Searches the local cache instantly (works offline), then merges in fresh
  /// server results when they arrive.
  void _runSearch() {
    final repo = PoemRepository();
    final q = _query;
    _searchFuture = repo.searchPoems(q);
    repo.searchPoems(q, forceRefresh: true).then((fresh) {
      if (mounted && q == _query) {
        setState(() => _searchFuture = Future.value(fresh));
      }
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'የመዝሙር ፍለጋ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SearchField(
                controller: _controller,
                autofocus: _query.isEmpty,
                onSubmitted: (q) => setState(() {
                  _query = q.trim();
                  if (_query.isNotEmpty) _runSearch();
                }),
                onClear: () => setState(() => _query = ''),
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? const Center(
                      child: Text(
                        'መዝሙር ለመፈለግ ይጻፉ...',
                        style: TextStyle(color: AppColors.inkMuted),
                      ),
                    )
                  : FutureBuilder<List<Poem>>(
                      future: _searchFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('ፍለጋው አልተሳካም: ${snapshot.error}',
                                  style: const TextStyle(
                                      color: AppColors.danger)));
                        }
                        final poems = snapshot.data ?? [];
                        if (poems.isEmpty) {
                          return const Center(
                            child: Text(
                              'ምንም መዝሙሮች አልተገኙም።',
                              style: TextStyle(color: AppColors.inkMuted),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: poems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final poem = poems[index];
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
        ),
      ),
    );
  }
}
