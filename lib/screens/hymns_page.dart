import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/poem.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';
import 'poem_detail_page.dart';
import 'SearchResultsPage.dart';

class HymnsPage extends StatefulWidget {
  const HymnsPage({super.key});

  @override
  State<HymnsPage> createState() => _HymnsPageState();
}

class _HymnsPageState extends State<HymnsPage> {
  final _api = ApiService();
  final _db = DBHelper();
  final _searchController = TextEditingController();
  final _pageController = PageController(viewportFraction: 0.78);
  late Future<List<Poem>> _future;
  int _carouselIndex = 0;

  static const _carouselCaptions = [
    'ይለይብኛል ሚካኤል',
    'ማርያም ሆይ አማልጂን',
    'ቅዱሳን ሆይ ረዱን',
    'የመዝሙር ደብተር',
  ];

  @override
  void initState() {
    super.initState();
    _future = _api.getPoems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _future = _api.getPoems());

  Future<void> _toggleFavorite(Poem poem) async {
    await _db.togglePoemFavorite(poem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Poem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ሰርቨሩን ማግኘት አልተቻለም።\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('እንደገና ሞክር'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final poems = snapshot.data ?? [];

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: SearchField(
                        controller: _searchController,
                        onSubmitted: (q) {
                          if (q.trim().isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchResultsPage(query: q.trim()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildCarousel()),
                  if (poems.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'ምንም መዝሙር የለም',
                          style: TextStyle(color: AppColors.inkMuted),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList.separated(
                        itemCount: poems.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final poem = poems[index];
                          return FutureBuilder<bool>(
                            future: poem.id == null
                                ? Future.value(false)
                                : _db.isPoemFavorite(poem.id!),
                            builder: (context, favSnap) {
                              final isFav = favSnap.data ?? false;
                              return HymnListTile(
                                title: poem.title,
                                subtitle: poem.category.isNotEmpty
                                    ? poem.category
                                    : poem.title,
                                imageIndex: index,
                                isFavorite: isFav,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PoemDetailPage(
                                      poem: poem,
                                      imageIndex: index,
                                    ),
                                  ),
                                ).then((_) => setState(() {})),
                                onFavorite: () => _toggleFavorite(poem),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        backgroundColor: AppColors.cardLight,
        child: const Icon(Icons.download_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: AppAssets.photos.length,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final page = _pageController.page ??
                        _pageController.initialPage.toDouble();
                    scale = (1 - (page - index).abs() * 0.08).clamp(0.9, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AppAssets.photoAt(index),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.card,
                        child: const Icon(Icons.image, color: AppColors.ink),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _carouselCaptions[_carouselIndex % _carouselCaptions.length],
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(AppAssets.photos.length, (i) {
            final active = i == _carouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.ink : AppColors.card,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
