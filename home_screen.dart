import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../show_detail/show_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeSection> _sections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final data = await ApiService.getHome();
      final sections = (data['sections'] as List)
          .map((s) => HomeSection.fromJson(s))
          .where((s) => s.sectionType != 'ad') // skip ads
          .toList();
      setState(() {
        _sections = sections;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: _loadHome,
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.background.withOpacity(0.95),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('سينما بوكس',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppTheme.textPrimary),
                onPressed: () {},
              ),
            ],
          ),

          // Sections
          SliverList(
            delegate: SliverChildListDelegate(
              _sections.map((section) => _buildSection(section)).toList(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSection(HomeSection section) {
    switch (section.sectionType) {
      case 'featured':
        return _FeaturedSlider(items: section.data);
      case 'continueWatching':
        return _HorizontalSection(
            title: section.title, items: section.data, isProgress: true);
      case 'posterWithDescription':
      case 'popular':
        return _BigCardSection(title: section.title, items: section.data);
      case 'genres':
        return _GenresSection(items: section.data);
      case 'actorArtWork':
        return _ActorsSection(title: section.title, items: section.data);
      default:
        return _HorizontalSection(title: section.title, items: section.data);
    }
  }
}

// ===== Featured Slider =====
class _FeaturedSlider extends StatefulWidget {
  final List<ShowItem> items;
  const _FeaturedSlider({required this.items});

  @override
  State<_FeaturedSlider> createState() => _FeaturedSliderState();
}

class _FeaturedSliderState extends State<_FeaturedSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          options: CarouselOptions(
            height: 240,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          itemBuilder: (ctx, i, _) {
            final item = widget.items[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShowDetailScreen(showId: item.id)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.style.backgroundImage ?? item.style.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.card),
                    errorWidget: (_, __, ___) => Container(color: AppTheme.card),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x88000000),
                          AppTheme.background,
                        ],
                        stops: [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.style.logo != null)
                          CachedNetworkImage(
                            imageUrl: item.style.logo!,
                            height: 40,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                            errorWidget: (_, __, ___) => Text(
                              item.title,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Text(item.title,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _TypeBadge(type: item.type),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ShowDetailScreen(showId: item.id)),
                              ),
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('مشاهدة', style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 34),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((e) {
            return Container(
              width: _current == e.key ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _current == e.key
                    ? AppTheme.primary
                    : AppTheme.textMuted,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ===== Horizontal Section =====
class _HorizontalSection extends StatelessWidget {
  final String title;
  final List<ShowItem> items;
  final bool isProgress;

  const _HorizontalSection(
      {required this.title, required this.items, this.isProgress = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        SizedBox(
          height: isProgress ? 170 : 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _PosterCard(
              item: items[i],
              showProgress: isProgress,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ===== Big Card Section =====
class _BigCardSection extends StatelessWidget {
  final String title;
  final List<ShowItem> items;

  const _BigCardSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        ...items.map((item) => _BigCard(item: item)),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ===== Genres Section =====
class _GenresSection extends StatelessWidget {
  final List<ShowItem> items;
  const _GenresSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'التصنيفات'),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(item.style.image),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(item.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ===== Actors Section =====
class _ActorsSection extends StatelessWidget {
  final String title;
  final List<ShowItem> items;
  const _ActorsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage:
                          CachedNetworkImageProvider(item.style.image),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ===== Shared Widgets =====

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const Text('المزيد',
              style: TextStyle(color: AppTheme.primary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final ShowItem item;
  final bool showProgress;

  const _PosterCard({required this.item, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    final progress = item.continueWatchingProgress ?? 0;
    final length = item.length ?? 1;
    final pct = showProgress && length > 0 ? progress / length : 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShowDetailScreen(showId: item.id)),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.style.image,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.shimmerBase),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppTheme.card,
                            child: const Icon(Icons.movie, color: AppTheme.textMuted)),
                  ),
                  if (showProgress && pct > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: Colors.black38,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 3,
                      ),
                    ),
                ],
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 4),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final ShowItem item;
  const _BigCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShowDetailScreen(showId: item.id)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: item.style.image,
                width: 90,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 6),
                    if (item.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.accent, size: 14),
                          const SizedBox(width: 4),
                          Text('${item.rating!.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  color: AppTheme.accent, fontSize: 13)),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                    ),
                    if (item.genres != null && item.genres!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.genres!.take(2).join(' • '),
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type == 'MOVIE' ? 'فيلم' : 'مسلسل';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }
}
