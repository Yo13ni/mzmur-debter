import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('የፍለጋ ውጤቶች: $query'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: FutureBuilder<List<Poem>>(
        future: DBHelper().searchPoems(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('ፍለጋው አልተሳካም: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ምንም መዝሙሮች አልተገኙም።'));
          }
          final poems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(
                    poem.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    poem.content.length > 50
                        ? '${poem.content.substring(0, 50)}...'
                        : poem.content,
                  ),
                  onTap: () {
                    // TODO: Navigate to a poem details page or show full content
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('መዝሙር: ${poem.title}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}