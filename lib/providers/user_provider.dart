import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasProfile => _currentUser != null;
  String? get error => _error;

  UserProvider(this._apiService) {
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final userId = HiveService.getCurrentUserId();
    if (userId != null) {
      _currentUser = HiveService.getUser(userId);
      _isLoggedIn = _currentUser != null;
    }
    notifyListeners();
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required List<String> subjects,
    required String skillLevel,
    required List<String> availability,
    String? bio,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _apiService.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
        subjects: subjects,
        skillLevel: skillLevel,
        availability: availability,
        bio: bio,
      );

      if (data == null) throw Exception('Registration failed. Please try again.');

      final user = UserModel.fromJson(data);
      user.isSynced = true;

      await HiveService.saveUser(user);
      HiveService.saveCurrentUserId(user.id);

      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _apiService.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (data == null) throw Exception('Login failed. Please try again.');

      final user = UserModel.fromJson(data);
      user.isSynced = true;

      await HiveService.saveUser(user);
      HiveService.saveCurrentUserId(user.id);

      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String role,
    required List<String> subjects,
    required String skillLevel,
    required List<String> availability,
    String? bio,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final user = UserModel(
        id: _currentUser?.id ?? '',
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        subjects: subjects,
        skillLevel: skillLevel,
        availability: availability,
        rating: _currentUser?.rating ?? 0.0,
        totalSessions: _currentUser?.totalSessions ?? 0,
        isSynced: false,
        bio: bio?.trim(),
      );

      await HiveService.saveUser(user);
      _currentUser = user;

      final result = await _apiService.createOrUpdateUser(user);
      if (result != null) {
        user.isSynced = true;
        await HiveService.saveUser(user);
        _currentUser = user;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save profile: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  void logout() {
    HiveService.clearCurrentUser();
    _currentUser = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  // ── All Users ─────────────────────────────────────────────────────────────

  Future<void> loadAllUsers() async {
    _allUsers = HiveService.getAllUsers();
    notifyListeners();

    try {
      final apiUsers = await _apiService.getAllTutors();
      for (final u in apiUsers) {
        await HiveService.saveUser(u);
      }
      _allUsers = HiveService.getAllUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('[UserProvider] Could not refresh from API: $e');
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
