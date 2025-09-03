// lib/screens/poem_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poem.dart';
import '../db/db_helper.dart';
import '../providers/app_config.dart';

// Optional: Uncomment if using google_fonts
// import 'package:google_fonts/flutter.dart';

class PoemDetailPage extends StatefulWidget {
  final Poem poem;

  const PoemDetailPage({required this.poem, super.key});

  @override
  _PoemDetailPageState createState() => _PoemDetailPageState();
}

class _PoemDetailPageState extends State<PoemDetailPage> {
  final dbHelper = DBHelper();
  late Poem _poem;

  @override
  void initState() {
    super.initState();
    _poem = widget.poem;
  }

  Future<void> _editPoem() async {
    final updatedPoem = await showDialog<Poem>(
      context: context,
      builder: (context) => EditPoemDialog(poem: _poem),
    );
    if (updatedPoem != null) {
      await dbHelper.updatePoem(updatedPoem);
      setState(() {
        _poem = updatedPoem;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'መዝሙር ተሻሽሏል።',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deletePoem() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('መዝሙር ይሰረዝ?'),
        content: const Text('ይህ መዝሙር ይሰረዛል። መቀጠል ይፈልጋሉ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('አይ', style: TextStyle(color: Color.fromARGB(255, 117, 116, 116))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('አዎ', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await dbHelper.deletePoem(_poem.id!);
      Navigator.pop(context); // Return to previous page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'መዝሙር ተሰርዟል።',
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
    final appConfig = Provider.of<AppConfig>(context);
    const double baseFontSize = 18;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _poem.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          FutureBuilder<bool>(
            future: dbHelper.isPoemFavorite(_poem.id!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              final isFavorite = snapshot.data!;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                tooltip: isFavorite ? 'ከተወዳጆች አስወግድ' : 'ወደ ተወዳጆች ጨምር',
                onPressed: () async {
                  await dbHelper.togglePoemFavorite(_poem.id!);
                  setState(() {});
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
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'መዝሙር ሰርዝ',
            onPressed: _deletePoem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ምድብ: ${_poem.category}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal, // This color is intentional and will not change with the theme
                  ),
                ),
                const SizedBox(height: 16),
                _poem.content.isEmpty
                    ? const Text(
                        'ለዚህ መዝሙር ይዘት የለም።',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey, // This will be grey in both themes. You can remove this for theme-based color.
                        ),
                      )
                    : Text(
                        _poem.content,
                        style: TextStyle(
                          fontSize: baseFontSize * appConfig.fontSizeScale,
                          height: 1.5,
                          // REMOVED: No hardcoded color here, so the text will automatically adapt to the theme.
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: _editPoem,
        tooltip: 'መዝሙር አርም',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class EditPoemDialog extends StatefulWidget {
  final Poem poem;

  const EditPoemDialog({required this.poem, super.key});

  @override
  _EditPoemDialogState createState() => _EditPoemDialogState();
}

class _EditPoemDialogState extends State<EditPoemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.poem.title);
    _contentController = TextEditingController(text: widget.poem.content);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'መዝሙር አርም',
        style: TextStyle(color: Colors.teal),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ርዕስ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ርዕስ ያስፈልጋል።';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'ይዘት',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ይዘት ያስፈልጋል።';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ይቅር', style: TextStyle(color: Color.fromARGB(255, 185, 180, 180))),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                Poem(
                  id: widget.poem.id,
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  category: widget.poem.category,
                ),
              );
            }
          },
          child: const Text('አስቀምጥ', style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}