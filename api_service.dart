import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiService {
  static final Dio _dio = ApiClient.dio;

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String birthDate,
  }) async {
    final res = await _dio.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
      'birth_date': birthDate,
    });
    return res.data;
  }

  // Home
  static Future<Map<String, dynamic>> getHome() async {
    final res = await _dio.get('/home');
    return res.data;
  }

  // Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/users/profile');
    return res.data;
  }

  static Future<Map<String, dynamic>> getUser() async {
    final res = await _dio.get('/users');
    return res.data;
  }

  // Show detail
  static Future<Map<String, dynamic>> getShowDetail(int showId) async {
    final res = await _dio.get('/shows/shows/dynamic/$showId');
    return res.data;
  }

  // Player
  static Future<Map<String, dynamic>> getEpisodePlayer(int episodeId) async {
    final res = await _dio.get('/shows/episodes/player/$episodeId');
    return res.data;
  }

  static Future<Map<String, dynamic>> getSeasonPlayer(int seasonId) async {
    final res = await _dio.get('/shows/seasons/player/$seasonId');
    return res.data;
  }

  // Watch progress
  static Future<void> postWatchProgress({
    required int episodeId,
    required int progress,
  }) async {
    await _dio.post('/shows/episodes/watch', data: {
      'episode_id': episodeId,
      'progress': progress,
    });
  }

  // Continue watching
  static Future<List<dynamic>> getContinueWatching() async {
    final res = await _dio.get('/shows/episodes/continue_watch_section');
    return res.data;
  }

  // Search
  static Future<Map<String, dynamic>> search(String query) async {
    final res = await _dio.get('/search', queryParameters: {'q': query});
    return res.data;
  }

  static Future<Map<String, dynamic>> getSearchTrending() async {
    final res = await _dio.get('/search/trending/list');
    return res.data;
  }

  // Favorites
  static Future<void> addFavorite(int showId) async {
    await _dio.post('/shows/shows/$showId/favorite');
  }

  static Future<void> removeFavorite(int showId) async {
    await _dio.delete('/shows/shows/$showId/favorite');
  }

  // Likes
  static Future<void> likeShow(int showId) async {
    await _dio.post('/shows/shows/$showId/like');
  }

  static Future<void> dislikeShow(int showId) async {
    await _dio.post('/shows/shows/$showId/dislike');
  }

  // Notifications
  static Future<bool> hasNewNotifications() async {
    final res = await _dio.get('/notifications/has_new');
    return res.data['has_new'] ?? false;
  }

  // Sections - more
  static Future<Map<String, dynamic>> getSectionMore(int sectionId,
      {int page = 1}) async {
    final res = await _dio.get('/home/section/$sectionId/more',
        queryParameters: {'page_number': page, 'page_size': 20});
    return res.data;
  }
}
