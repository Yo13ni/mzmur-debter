import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import 'poem_detail_page.dart'; // Import your new PoemDetailPage

// A Stateless Widget that fetches and displays search results
class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text('የፍለጋ ውጤቶች: "$query"'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: FutureBuilder<List<Poem>>(
        // Call the searchPoems method from your DBHelper
        future: DBHelper().searchPoems(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display a user-friendly error message
            return Center(child: Text('ፍለጋው አልተሳካም: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case where no results are found
            return Center(
              child: Text(
                'ምንም መዝሙሮች አልተገኙም።',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            );
          }

          // If data is available, build the list of poems
          final poems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return _PoemSearchResultCard(
                poem: poem,
                onTap: () {
                  // Navigate to the PoemDetailPage when a card is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoemDetailPage(poem: poem),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// A reusable Card widget for displaying a single search result
class _PoemSearchResultCard extends StatelessWidget {
  final Poem poem;
  final VoidCallback onTap;

  const _PoemSearchResultCard({
    required this.poem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(
          poem.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        subtitle: Text(
          poem.content.length > 50
              ? '${poem.content.substring(0, 50)}...'
              : poem.content,
        ),
        trailing: Text(
          poem.category,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}