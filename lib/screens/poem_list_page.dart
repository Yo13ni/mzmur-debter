import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import 'poem_detail_page.dart';
import 'add_poem_page.dart';
// Optional: Uncomment if using google_fonts
// import 'package:google_fonts/google_fonts.dart';

class PoemListPage extends StatefulWidget {
  final String category;

  const PoemListPage({required this.category, super.key});

  @override
  _PoemListPageState createState() => _PoemListPageState();
}

class _PoemListPageState extends State<PoemListPage> {
  final dbHelper = DBHelper();

  Future<bool> _areAllPoemsFavorited(List<Poem> poems) async {
    for (var poem in poems) {
      if (poem.id != null && !await dbHelper.isPoemFavorite(poem.id!)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _toggleAllPoemsFavorite(List<Poem> poems) async {
    final allFavorited = await _areAllPoemsFavorited(poems);
    for (var poem in poems) {
      if (poem.id != null) {
        if (allFavorited) {
          await dbHelper.togglePoemFavorite(poem.id!); // Unfavorite
        } else if (!await dbHelper.isPoemFavorite(poem.id!)) {
          await dbHelper.togglePoemFavorite(poem.id!); // Favorite only unfavorited poems
        }
      }
    }
    setState(() {}); // Refresh UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allFavorited
              ? 'ሁሉም መዝሙሮች ከተወዳጆች ተወግደዋል።'
              : 'ሁሉም መዝሙሮች ወደ ተወዳጆች ተጨምረዋል።',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            // Optional: Use Google Fonts
            // style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          FutureBuilder<List<Poem>>(
            future: dbHelper.getPoemsByCategory(widget.category),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink(); // Hide icon if no poems
              }
              final poems = snapshot.data!;
              return FutureBuilder<bool>(
                future: _areAllPoemsFavorited(poems),
                builder: (context, favoriteSnapshot) {
                  if (!favoriteSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final allFavorited = favoriteSnapshot.data!;
                  return IconButton(
                    icon: Icon(
                      allFavorited ? Icons.favorite : Icons.favorite_border,
                      color: allFavorited ? Colors.teal.shade100 : Colors.white,
                    ),
                    onPressed: () => _toggleAllPoemsFavorite(poems),
                    tooltip: allFavorited
                        ? 'Remove All from Favorites'
                        : 'Add All to Favorites',
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Poem>>(
        future: dbHelper.getPoemsByCategory(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading poems: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ምንም መዝሙሮች በዚህ ምድብ ውስጥ አልተገኙም።',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final poems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<bool>(
                  future: dbHelper.isPoemFavorite(poem.id!),
                  builder: (context, favoriteSnapshot) {
                    if (!favoriteSnapshot.hasData) {
                      return const ListTile(
                        leading: CircularProgressIndicator(color: Colors.teal),
                      );
                    }
                    final isFavorite = favoriteSnapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        poem.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          // Optional: Use Google Fonts
                          // style: GoogleFonts.notoSansEthiopic(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      subtitle: Text(
                        poem.content.length > 50
                            ? '${poem.content.substring(0, 50)}...'
                            : poem.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.teal.shade700 : Colors.grey,
                        ),
                        onPressed: () async {
                          await dbHelper.togglePoemFavorite(poem.id!);
                          setState(() {}); // Refresh UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'መዝሙር ከተወዳጆች ተወግዷል።'
                                    : 'መዝሙር ወደ ተወዳጆች ተጨምሯል።',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.teal,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PoemDetailPage(poem: poem),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPoemPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Poem',
      ),
    );
  }
}