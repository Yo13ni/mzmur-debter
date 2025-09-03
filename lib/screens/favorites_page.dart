import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import 'poem_detail_page.dart';
// Optional: Uncomment if using google_fonts
// import 'package:google_fonts/google_fonts.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final dbHelper = DBHelper();

  Future<void> _removeFavoritePoem(int poemId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('መዝሙር ከተወዳጆች ያውጡ?'),
        content: const Text('ይህ መዝሙር ከተወዳጆች ዝርዝር ይወገዳል። መቀጠል ይፈልጋሉ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('አይ', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('አዎ', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await dbHelper.togglePoemFavorite(poemId);
      setState(() {}); // Refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'መዝሙር ከተወዳጆች ተወግዷል።',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ተወዳጅ መዝሙሮች',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            // Optional: Use Google Fonts
            // style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        backgroundColor:  Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: FutureBuilder<List<Poem>>(
        future: dbHelper.getFavoritePoems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading favorite poems: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'ምንም ተወዳጅ መዝሙሮች የሉም።',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
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
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      poem.title[0],
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
                    poem.category,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.teal,
                    ),
                    onPressed: () => _removeFavoritePoem(poem.id!),
                    tooltip: 'ከተወዳጆች አውጣ',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PoemDetailPage(poem: poem),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }}