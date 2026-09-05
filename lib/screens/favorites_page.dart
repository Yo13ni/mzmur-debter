import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';
import 'poem_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final dbHelper = DBHelper();

  Future<void> _removeFavorite(Poem poem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('መዝሙር ከተወዳጆች ያውጡ?'),
        content: const Text('ይህ መዝሙር ከተወዳጆች ዝርዝር ይወገዳል።'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('አይ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('አዎ',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await dbHelper.togglePoemFavorite(poem);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'ተወዳጆች',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Poem>>(
                future: dbHelper.getFavoritePoems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final poems = snapshot.data ?? [];
                  if (poems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 72, color: AppColors.inkMuted),
                          SizedBox(height: 12),
                          Text(
                            'ምንም ተወዳጅ መዝሙሮች የሉም።',
                            style: TextStyle(
                                color: AppColors.inkMuted, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: poems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final poem = poems[index];
                      return HymnListTile(
                        title: poem.title,
                        subtitle: poem.category,
                        imageIndex: index,
                        isFavorite: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PoemDetailPage(
                              poem: poem,
                              imageIndex: index,
                            ),
                          ),
                        ).then((_) => setState(() {})),
                        onFavorite: () => _removeFavorite(poem),
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
