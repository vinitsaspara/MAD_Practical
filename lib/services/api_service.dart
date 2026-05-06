import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/feedback_model.dart';

class ApiService {
  // Android emulator → use 10.0.2.2 (maps to host localhost)
  // Physical device  → use your PC's IP e.g. http://192.168.1.5:3000/api
  // Chrome/web       → use http://localhost:3000/api
  static const String baseUrl = 'http://localhost:3000/api';

  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ));

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Register a new user — returns user map (without password) or null on error
  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required List<String> subjects,
    required String skillLevel,
    required List<String> availability,
    String? bio,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'subjects': subjects,
        'skillLevel': skillLevel,
        'availability': availability,
        'bio': bio,
      });
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message;
      throw Exception(msg);
    }
    return null;
  }

  /// Login — returns user map (without password) or throws
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message;
      throw Exception(msg);
    }
    return null;
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<UserModel?> createOrUpdateUser(UserModel user) async {
    try {
      final response = await _dio.post('/users', data: user.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<UserModel>> getAllTutors({
    String? subject,
    String? skillLevel,
    double? minRating,
  }) async {
    try {
      final Map<String, dynamic> q = {};
      if (subject != null) q['subject'] = subject;
      if (skillLevel != null) q['skillLevel'] = skillLevel;
      if (minRating != null) q['minRating'] = minRating;
      final response = await _dio.get('/tutors', queryParameters: q);
      if (response.statusCode == 200 || response.statusCode == 304) {
        if (response.data is List) {
          return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
        }
        return [];
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      if (response.statusCode == 200) return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('getUserById', e);
    }
    return null;
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<SessionModel?> createSession(SessionModel session) async {
    try {
      final response = await _dio.post('/sessions', data: session.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SessionModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      _log('createSession', e);
    }
    return null;
  }

  Future<List<SessionModel>> getSessionsByUser(String userId) async {
    try {
      final response = await _dio.get('/sessions', queryParameters: {'userId': userId});
      if (response.statusCode == 200 || response.statusCode == 304) {
        return (response.data as List).map((e) => SessionModel.fromJson(e)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<bool> updateSessionStatus(String sessionId, String status) async {
    try {
      final response = await _dio.patch('/sessions/$sessionId', data: {'status': status});
      return response.statusCode == 200;
    } on DioException catch (e) {
      _log('updateSessionStatus', e);
      return false;
    }
  }

  // ── Feedback ──────────────────────────────────────────────────────────────

  Future<FeedbackModel?> submitFeedback(FeedbackModel feedback) async {
    try {
      final response = await _dio.post('/feedback', data: feedback.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FeedbackModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      _log('submitFeedback', e);
    }
    return null;
  }

  Future<List<FeedbackModel>> getFeedbackForTutor(String tutorId) async {
    try {
      final response = await _dio.get('/feedback', queryParameters: {'tutorId': tutorId});
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => FeedbackModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      _log('getFeedbackForTutor', e);
    }
    return [];
  }

  void _log(String method, DioException e) {
    final msg = e.response?.data?['error'] ?? e.message;
    // ignore: avoid_print
    print('[$method] ${e.type}: $msg');
  }
}
