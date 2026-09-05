import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/floating_bottom_nav.dart';
import 'screens/categories_page.dart';
import 'screens/favorites_page.dart';
import 'screens/add_poem_page.dart';
import 'screens/more_page.dart';
import 'screens/loading_page.dart';
import 'screens/SearchResultsPage.dart';
import 'db/db_helper.dart';
import 'providers/app_config.dart';

class Strings {
  static const String appTitle = 'የመዝሙር ደብተር';
  static const String forSabbathStudents = 'ለሰንበት ተማሪዎች';
  static const String searchHint = 'መዝሙር ፈልግ';
  static const String emptySearchQuery = 'እባክዎ የፍለጋ ቃል ያስገቡ!';
  static const String searchFailed = 'ፍለጋው አልተሳካም: ';
  static const String categories = 'ምድቦች';
  static const String favorites = 'ተወዳጆች';
  static const String write = 'ፃፍ';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.nav,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppConfig(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfig>(
      builder: (context, appConfig, _) {
        return MaterialApp(
          title: Strings.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          theme: AppTheme.dark(),
          darkTheme: AppTheme.dark(),
          home: FutureBuilder(
            future: DBHelper().init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const HomeShell();
              }
              return const LoadingPage();
            },
          ),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    CategoriesPage(onOpenMore: _openMore, onSearch: _openSearch),
    const FavoritesPage(),
    const AddPoemPage(embedded: true),
  ];

  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  void _openMore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MorePage()),
    );
  }

  void _openSearch([String? initial]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: initial ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
