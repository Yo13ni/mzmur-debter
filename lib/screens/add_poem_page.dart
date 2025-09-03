import 'package:flutter/material.dart';
import '../models/poem.dart';
import '../db/db_helper.dart';
// Optional: Uncomment if using google_fonts
// import 'package:google_fonts/google_fonts.dart';

class AddPoemPage extends StatefulWidget {
  const AddPoemPage({super.key});

  @override
  _AddPoemPageState createState() => _AddPoemPageState();
}

class _AddPoemPageState extends State<AddPoemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'የዘወትር መዝሙራት',
    'የድንግል ማርያም መዝሙራት',
    'የዐውደ አመት መዝሙራት ',
    'የመስቀል መዝሙራት',
    'የፅጌ መዝሙራት',
    'የህዳር ጽዮን መዝሙራት',
    'የልደት መዝሙራት',
    'የጥምቀት መዝሙራት',
    'የቅዱሳን መላእክት መዝሙራት',
    'የቅዱሳን ሰዎች መዝሙራት',
    'የንስሀ መዝሙራት',
    'የስቅለት መዝሙራት',
    'የትንሳኤ መዝሙራት',
    'የእርገት መዝሙራት',
    'የደብረ ታቦር መዝሙራት',
    'የንግስ መዝሙራት',
    'ወረብ',
    'የቤተክርስቲያን መዝሙራት',
    'የሰርግ መዝሙራት',
  ];

  void _savePoem() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final category = _selectedCategory!;

      // Check for duplicate title
      final dbHelper = DBHelper();
      final exists = await dbHelper.doesPoemExist(title);

      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ይህ ርዕስ ቀድሞ ተመዝግቧል!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Insert poem if no duplicate
      Poem newPoem = Poem(
        title: title,
        content: content,
        category: category,
      );

      await dbHelper.insertPoem(newPoem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'መዝሙሩ ተጨመረ!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 2),
          ),
        );

        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedCategory = null;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ሁሉንም መስኮች ይሙሉ!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ቅጹ ተጸዳ!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'አዲስ መዝሙር ጨምር',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            // Optional: Use Google Fonts
            // style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'ርዕስ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        labelStyle: const TextStyle(color: Colors.teal),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // Optional: Use Google Fonts
                        // style: GoogleFonts.notoSansEthiopic(fontSize: 16),
                      ),
                      validator: (value) => value!.isEmpty ? 'ርዕሱን ያስገቡ' : null,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'መዝሙሩ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        labelStyle: const TextStyle(color: Colors.teal),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // Optional: Use Google Fonts
                        // style: GoogleFonts.notoSansEthiopic(fontSize: 16),
                      ),
                      maxLines: 6,
                      validator: (value) => value!.isEmpty ? 'መዝሙሩን ያስገቡ' : null,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'ምድብ ይምረጡ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        labelStyle: const TextStyle(color: Colors.teal),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // Optional: Use Google Fonts
                        // style: GoogleFonts.notoSansEthiopic(fontSize: 16),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              // Optional: Use Google Fonts
                              // style: GoogleFonts.notoSansEthiopic(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null ? 'ምድቡን ይምረጡ' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _savePoem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'መዝሙሩን ጨምር',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade300, // Lighter teal for distinction
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'አጽዳ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}