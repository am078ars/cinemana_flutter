import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../player/player_screen.dart';

class ShowDetailScreen extends StatefulWidget {
  final int showId;
  const ShowDetailScreen({super.key, required this.showId});

  @override
  State<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends State<ShowDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _isFavorite = false;

  // Parsed sections
  ShowItem? _mainInfo;
  List<ShowItem> _episodes = [];
  List<ShowItem> _trailers = [];
  List<ShowItem> _related = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getShowDetail(widget.showId);
      final sections = (data['sections'] as List)
          .map((s) => HomeSection.fromJson(s))
          .toList();

      ShowItem? main;
      List<ShowItem> episodes = [];
      List<ShowItem> trailers = [];
      List<ShowItem> related = [];

      for (final s in sections) {
        switch (s.sectionType) {
          case 'episodes':
            episodes = s.data;
          case 'trailer':
            trailers = s.data;
          case 'normalPoster':
          case 'circlePoster':
            if (related.isEmpty) related = s.data;
        }
        // Get main info from first item with description
        if (main == null && s.data.isNotEmpty && s.data.first.description.isNotEmpty) {
          main = s.data.first;
        }
      }

      setState(() {
        _data = data;
        _mainInfo = main;
        _episodes = episodes;
        _trailers = trailers;
        _related = related;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    final coverImage = _episodes.isNotEmpty
        ? _episodes.first.style.image
        : (_mainInfo?.style.backgroundImage ?? _mainInfo?.style.image ?? '');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover image with back button
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: _isFavorite ? AppTheme.primary : Colors.white,
                ),
                onPressed: () async {
                  setState(() => _isFavorite = !_isFavorite);
                  if (_isFavorite) {
                    await ApiService.addFavorite(widget.showId);
                  } else {
                    await ApiService.removeFavorite(widget.showId);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverImage.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverImage,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.background],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (_mainInfo != null) ...[
                    Text(
                      _mainInfo!.title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Play button
                    if (_episodes.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _playEpisode(_episodes.first),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_episodes.length > 1
                            ? 'شاهد الحلقة 1'
                            : 'شاهد الآن'),
                      ),

                    const SizedBox(height: 16),

                    // Description
                    if (_mainInfo!.description.isNotEmpty) ...[
                      const Text('القصة',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _mainInfo!.description,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                            fontSize: 14),
                      ),
                    ],
                  ],

                  // Episodes
                  if (_episodes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'الحلقات (${_episodes.length})',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ..._episodes.map((ep) => _EpisodeTile(
                          episode: ep,
                          onTap: () => _playEpisode(ep),
                        )),
                  ],

                  // Trailers
                  if (_trailers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('الإعلانات',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trailers.length,
                        itemBuilder: (ctx, i) {
                          final t = _trailers[i];
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(left: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: t.style.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Related
                  if (_related.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('قد يعجبك أيضاً',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _related.length,
                        itemBuilder: (ctx, i) {
                          final item = _related[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ShowDetailScreen(showId: item.id)),
                            ),
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(left: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.style.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playEpisode(ShowItem ep) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(episodeId: ep.id),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final ShowItem episode;
  final VoidCallback onTap;

  const _EpisodeTile({required this.episode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = episode.continueWatchingProgress ?? 0;
    final length = episode.length ?? 1;
    final pct = length > 0 ? progress / length : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(10)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: episode.style.image,
                    width: 110,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.shimmerBase, width: 110, height: 70),
                  ),
                  const Positioned.fill(
                    child: Icon(Icons.play_circle_outline,
                        color: Colors.white70, size: 28),
                  ),
                  if (pct > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: Colors.black38,
                        valueColor:
                            const AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 3,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(episode.title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                    if (episode.length != null && episode.length! > 0)
                      Text(
                        '${(episode.length! / 60).round()} دقيقة',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
