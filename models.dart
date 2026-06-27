// ===== Show Item (used in sections) =====
class ShowItem {
  final int id;
  final String title;
  final String description;
  final String cardType;
  final String type; // MOVIE, SERIES, episode, trailer
  final ShowStyle style;
  final double? rating;
  final List<String>? genres;
  final int? length;
  final int? continueWatchingProgress;
  final String? url; // for trailers (YouTube)

  ShowItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cardType,
    required this.type,
    required this.style,
    this.rating,
    this.genres,
    this.length,
    this.continueWatchingProgress,
    this.url,
  });

  factory ShowItem.fromJson(Map<String, dynamic> json) {
    return ShowItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cardType: json['card_type'] ?? '',
      type: json['type'] ?? '',
      style: ShowStyle.fromJson(json['style'] ?? {}),
      rating: (json['rating'] as num?)?.toDouble(),
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      length: json['length'],
      continueWatchingProgress: json['continue_watching_progress'],
      url: json['url'],
    );
  }
}

class ShowStyle {
  final String image;
  final String? logo;
  final String? backgroundImage;

  ShowStyle({required this.image, this.logo, this.backgroundImage});

  factory ShowStyle.fromJson(Map<String, dynamic> json) {
    return ShowStyle(
      image: json['image'] ?? '',
      logo: json['logo'],
      backgroundImage: json['background_image'],
    );
  }
}

// ===== Home Section =====
class HomeSection {
  final int id;
  final String title;
  final String sectionType;
  final List<ShowItem> data;
  final Map<String, dynamic>? linker;

  HomeSection({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.data,
    this.linker,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      sectionType: json['section_type'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => ShowItem.fromJson(e))
          .toList(),
      linker: json['linker'],
    );
  }
}

// ===== User Profile =====
class UserProfile {
  final int id;
  final String username;
  final String name;
  final String email;
  final String image;
  final String bio;
  final int followers;
  final int following;
  final bool isVerified;
  final String gender;

  UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.image,
    required this.bio,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      bio: json['bio'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      gender: json['gender'] ?? '',
    );
  }
}

// ===== Episode Player =====
class VideoFile {
  final String url;
  final String quality;

  VideoFile({required this.url, required this.quality});

  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(url: json['url'] ?? '', quality: json['quality'] ?? '');
  }
}

class Subtitle {
  final String url;
  final String language;

  Subtitle({required this.url, required this.language});

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(url: json['url'] ?? '', language: json['language'] ?? '');
  }
}

class ParentalAccess {
  final Map<String, int> intro;
  final Map<String, int> outro;

  ParentalAccess({required this.intro, required this.outro});

  factory ParentalAccess.fromJson(Map<String, dynamic> json) {
    final intro = json['intro'] as Map<String, dynamic>? ?? {};
    final outro = json['outro'] as Map<String, dynamic>? ?? {};
    return ParentalAccess(
      intro: {'start': intro['start'] ?? 0, 'end': intro['end'] ?? 0},
      outro: {'start': outro['start'] ?? 0, 'end': outro['end'] ?? 0},
    );
  }
}

class EpisodePlayer {
  final int id;
  final String showTitle;
  final int episodeNumber;
  final int seasonNumber;
  final String showType;
  final int showId;
  final int seasonId;
  final int length;
  final String image;
  final List<VideoFile> videos;
  final List<Subtitle> subtitles;
  final ParentalAccess? parentalAccess;

  EpisodePlayer({
    required this.id,
    required this.showTitle,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.showType,
    required this.showId,
    required this.seasonId,
    required this.length,
    required this.image,
    required this.videos,
    required this.subtitles,
    this.parentalAccess,
  });

  factory EpisodePlayer.fromJson(Map<String, dynamic> json) {
    return EpisodePlayer(
      id: json['id'] ?? 0,
      showTitle: json['show_title'] ?? '',
      episodeNumber: json['episode_number'] ?? 1,
      seasonNumber: json['season_number'] ?? 1,
      showType: json['show_type'] ?? 'SERIES',
      showId: json['show_id'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      length: json['length'] ?? 0,
      image: json['image'] ?? '',
      videos: (json['videos'] as List? ?? [])
          .map((e) => VideoFile.fromJson(e))
          .toList(),
      subtitles: (json['subtitles'] as List? ?? [])
          .map((e) => Subtitle.fromJson(e))
          .toList(),
      parentalAccess: json['parental_access'] != null
          ? ParentalAccess.fromJson(json['parental_access'])
          : null,
    );
  }

  String? get bestQualityUrl {
    if (videos.isEmpty) return null;
    // prefer 1080p > 720p > 480p > first
    for (final q in ['1080p', '720p', '480p']) {
      final v = videos.firstWhere((v) => v.quality == q,
          orElse: () => videos.first);
      if (v.quality == q) return v.url;
    }
    return videos.first.url;
  }
}

// ===== Auth =====
class AuthResponse {
  final String token;
  final UserProfile? user;

  AuthResponse({required this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }
}
