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
  late final PageController _pageController;

  late final List<Widget> _pages = [
    const CategoriesPage(),
    const FavoritesPage(),
    const AddPoemPage(embedded: true),
    const MorePage(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onSettings: () => _onTabTapped(3),
      ),
    );
  }
}
