import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final int episodeId;
  const PlayerScreen({super.key, required this.episodeId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  EpisodePlayer? _episode;
  VideoPlayerController? _vpCtrl;
  ChewieController? _chewieCtrl;
  bool _loading = true;
  String? _error;
  String _selectedQuality = '720p';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _load();
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _vpCtrl?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getEpisodePlayer(widget.episodeId);
      final episode = EpisodePlayer.fromJson(data);

      // Pick initial quality
      final qualities = episode.videos.map((v) => v.quality).toList();
      if (qualities.contains('720p')) {
        _selectedQuality = '720p';
      } else if (qualities.isNotEmpty) {
        _selectedQuality = qualities.first;
      }

      await _initPlayer(episode, _selectedQuality);
      setState(() {
        _episode = episode;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل الفيديو';
        _loading = false;
      });
    }
  }

  Future<void> _initPlayer(EpisodePlayer episode, String quality) async {
    final video = episode.videos.firstWhere(
      (v) => v.quality == quality,
      orElse: () => episode.videos.first,
    );

    _vpCtrl?.dispose();
    _chewieCtrl?.dispose();

    final ctrl = VideoPlayerController.networkUrl(Uri.parse(video.url));
    await ctrl.initialize();

    final chewie = ChewieController(
      videoPlayerController: ctrl,
      autoPlay: true,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      placeholder: Container(color: Colors.black),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppTheme.primary,
        handleColor: AppTheme.primary,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      additionalOptions: (ctx) => [
        OptionItem(
          onTap: () => _showQualitySheet(episode),
          iconData: Icons.high_quality,
          title: 'الجودة: $_selectedQuality',
        ),
      ],
    );

    setState(() {
      _vpCtrl = ctrl;
      _chewieCtrl = chewie;
    });
  }

  void _showQualitySheet(EpisodePlayer episode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('اختر الجودة',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          ...episode.videos.map((v) => ListTile(
                title: Text(v.quality,
                    style: const TextStyle(color: AppTheme.textPrimary)),
                trailing: _selectedQuality == v.quality
                    ? const Icon(Icons.check, color: AppTheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedQuality = v.quality);
                  _initPlayer(episode, v.quality);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _episode == null
          ? AppBar(backgroundColor: Colors.black)
          : AppBar(
              backgroundColor: Colors.black,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _episode!.showTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'الموسم ${_episode!.seasonNumber} | الحلقة ${_episode!.episodeNumber}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              : _chewieCtrl != null
                  ? Chewie(controller: _chewieCtrl!)
                  : const SizedBox.shrink(),
    );
  }
}
