// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'screens/categories_page.dart';
import 'screens/favorites_page.dart';
import 'screens/add_poem_page.dart';
import 'screens/info_page.dart';
import 'screens/settings_page.dart';
import 'screens/SearchResultsPage.dart';
import 'screens/loading_page.dart';
import 'db/db_helper.dart';
import 'providers/app_config.dart';

// Centralized strings for localization and maintainability
class Strings {
  static const String appTitle = 'የመዝሙር ደብተር';
  static const String forSabbathStudents = 'ለሰንበት ተማሪዎች';
  static const String searchHint = 'መዝሙር ፈልግ...';
  static const String searchTooltip = 'ፈልግ';
  static const String closeTooltip = 'አጥፋ';
  static const String menuTooltip = 'ዝርዝር';
  static const String importPoems = 'መዝሙሮችን አስገባ';
  static const String exportPoems = 'መዝሙሮችን ላክ';
  static const String info = 'መረጃ';
  static const String settings = 'ቅንብሮች';
  static const String exit = 'ውጣ';
  static const String emptySearchQuery = 'እባክዎ የፍለጋ ቃል ያስገቡ!';
  static const String searchFailed = 'ፍለጋው አልተሳካም: ';
  static const String exportingPoems = 'መዝሙሮችን ወደ ውጭ በመላክ ላይ...';
  static const String exportPoemsSuccess = 'መዝሙሮች በስኬት ተልከዋል!';
  static const String exportPoemsFailed = 'ወደ ውጭ መላክ አልተሳካም: ';
  static const String importingPoems = 'መዝሙሮችን ወደ ውስጥ በማስገባት ላይ...';
  static const String importPoemsSuccess = 'መዝሙሮች በስኬት ተገብተዋል!';
  static const String importPoemsFailed = 'መግባት አልተሳካም: ';
  static const String exportingDatabase = 'የመጠባበቂያ ዳታቤዝ ፋይል በመፍጠር ላይ...';
  static const String exportDatabaseSuccess = 'የመጠባበቂያ ፋይሉ በስኬት ተልኳል!';
  static const String exportDatabaseFailed = 'የመጠሉ ፋይል መፍጠር አልተሳካም: ';
  static const String permissionDenied = 'የማከማቻ ፍቃድ አልተሰጠም';
  static const String categories = 'ምድቦች';
  static const String favorites = 'ተወዳጆች';
  static const String write = 'ፃፍ';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppConfig(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfig>(
      builder: (context, appConfig, child) {
        return MaterialApp(
          title: Strings.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: appConfig.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            // Per your request, global font size scaling is removed from here
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
            // Per your request, global font size scaling is removed from here
          ),
          home: FutureBuilder(
            future: DBHelper().database,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const BottomNavExample();
              } else {
                return const LoadingPage();
              }
            },
          ),
        );
      },
    );
  }
}

class BottomNavExample extends StatefulWidget {
  const BottomNavExample({super.key});

  @override
  _BottomNavExampleState createState() => _BottomNavExampleState();
}

class _BottomNavExampleState extends State<BottomNavExample> {
  int _currentIndex = 0;
  bool _isSearching = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final dbHelper = DBHelper();

  final List<Widget> _pages = [
    CategoriesPage(),
    const FavoritesPage(),
    const AddPoemPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _isLoading = false;
      _searchController.clear();
    });
  }

  void _performSearch(String query) async {
    if (query.trim().isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsPage(query: query),
          ),
        );
      } catch (e) {
        if (mounted) {
          _showSnackBar('${Strings.searchFailed}$e', isError: true);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showSnackBar(Strings.emptySearchQuery, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isError ? Colors.red : Colors.teal,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _exportPoemsToJson() async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    _showSnackBar(Strings.exportingPoems);
    final result = await dbHelper.exportPoemsToJson();
    setState(() => _isLoading = false);
    if (result['success']) {
      _showSnackBar(Strings.exportPoemsSuccess);
    } else {
      _showSnackBar('${Strings.exportPoemsFailed}${result['error']}', isError: true);
    }
  }

  void _importPoemsFromJson() async {
    // Use file_picker to handle file selection and access permissions
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath == null) {
        _showSnackBar('File path is not valid.', isError: true);
        return;
      }

      Navigator.pop(context); // Close the drawer
      setState(() => _isLoading = true);
      _showSnackBar(Strings.importingPoems);

      try {
        // Pass the file path directly to the database helper
        final importResult = await DBHelper().importPoemsFromJson();
        if (importResult['success']) {
          _showSnackBar(Strings.importPoemsSuccess);
        } else {
          _showSnackBar('${Strings.importPoemsFailed}${importResult['error']}', isError: true);
        }
      } catch (e) {
        _showSnackBar('${Strings.importPoemsFailed}$e', isError: true);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      _showSnackBar('File selection canceled.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        // Dynamic hint color based on theme
                        hintText: Strings.searchHint,
                        hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54),
                        border: InputBorder.none,
                      ),
                      // Dynamic text color based on theme
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18),
                      onSubmitted: _performSearch,
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: Strings.searchTooltip,
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                ],
              )
            : const Text(Strings.appTitle),
        leading: _isSearching
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: Strings.menuTooltip,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: Strings.closeTooltip,
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: Strings.searchTooltip,
                  onPressed: _startSearch,
                ),
        ],
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    Strings.appTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    Strings.forSabbathStudents,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.teal),
              title: const Text(Strings.importPoems, style: TextStyle(fontSize: 16)),
              onTap: _importPoemsFromJson,
            ),
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.teal),
              title: const Text(Strings.exportPoems, style: TextStyle(fontSize: 16)),
              onTap: _exportPoemsToJson,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: const Text(Strings.settings, style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: const Text(Strings.info, style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.teal),
              title: const Text(Strings.exit, style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: Strings.categories),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: Strings.favorites),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: Strings.write),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}