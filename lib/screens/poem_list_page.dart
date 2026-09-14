import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import '../services/poem_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';
import 'poem_detail_page.dart';
import 'add_poem_page.dart';

class PoemListPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const PoemListPage({
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  @override
  State<PoemListPage> createState() => _PoemListPageState();
}

class _PoemListPageState extends State<PoemListPage> {
  final dbHelper = DBHelper();
  final _repo = PoemRepository();
  late Future<List<Poem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getPoems(categoryId: widget.categoryId);
  }

  void _refresh() =>
      setState(() => _future = _repo.getPoems(categoryId: widget.categoryId));

  Future<void> _toggleFavorite(Poem poem) async {
    await dbHelper.togglePoemFavorite(poem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<List<Poem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}',
                    style: const TextStyle(color: AppColors.danger)),
              );
            }

            final poems = snapshot.data ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppColors.ink),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.categoryName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: poems.isEmpty
                      ? const Center(
                          child: Text(
                            'ምንም መዝሙሮች አልተገኙም።',
                            style: TextStyle(color: AppColors.inkMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                          itemCount: poems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final poem = poems[index];
                            return FutureBuilder<bool>(
                              future: poem.id == null
                                  ? Future.value(false)
                                  : dbHelper.isPoemFavorite(poem.id!),
                              builder: (context, favSnap) {
                                final isFav = favSnap.data ?? false;
                                return HymnListTile(
                                  title: poem.title,
                                  subtitle: widget.categoryName,
                                  imageIndex: index,
                                  isFavorite: isFav,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PoemDetailPage(
                                        poem: poem,
                                        imageIndex: index,
                                      ),
                                    ),
                                  ).then((_) => setState(() {})),
                                  onFavorite: () => _toggleFavorite(poem),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cardLight,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPoemPage()),
          ).then((_) => _refresh());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
