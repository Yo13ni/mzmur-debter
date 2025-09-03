import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'poem_list_page.dart';

class CategoriesPage extends StatelessWidget {
  final dbHelper = DBHelper();

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder that waits for two futures to complete.
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        dbHelper.getCategoryCounts(), // This gets a Map<String, int>
        dbHelper.getTotalPoemCount(), // This gets an int
      ]),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }
        // Handle error state
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading categories: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        // Data is available. Extract the results from the list.
        final categoryCounts = snapshot.data![0] as Map<String, int>;
        final totalCount = snapshot.data![1] as int;
        final categories = categoryCounts.keys.toList();

        return Scaffold(
          appBar: AppBar(
            // Display the total count in the app bar title
            title: Text(
              '$totalCount መዝሙሮች',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: categories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'ምንም መዝሙር አልፃፉም',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final count = categoryCounts[category] ?? 0;
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
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '$count መዝሙሮች',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PoemListPage(category: category),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}