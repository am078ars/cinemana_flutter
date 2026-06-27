import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_service.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuth() async {
    final token = await ApiClient.getToken();
    if (token != null) {
      _isLoggedIn = true;
      notifyListeners();
      await fetchProfile();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.login(email, password);
      final token = data['token'] ?? data['access_token'] ?? '';
      if (token.isNotEmpty) {
        await ApiClient.saveToken(token);
        _isLoggedIn = true;
        if (data['user'] != null) {
          _user = UserProfile.fromJson(data['user']);
        } else {
          await fetchProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'فشل تسجيل الدخول';
    } catch (e) {
      _error = 'خطأ في الاتصال. تحقق من البيانات.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiService.getProfile();
      _user = UserProfile.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
