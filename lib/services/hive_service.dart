import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/feedback_model.dart';

class HiveService {
  static const String usersBoxName = 'users';
  static const String sessionsBoxName = 'sessions';
  static const String feedbackBoxName = 'feedback';
  static const String currentUserBoxName = 'current_user';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(SessionModelAdapter());
    Hive.registerAdapter(FeedbackModelAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(usersBoxName);
    await Hive.openBox<SessionModel>(sessionsBoxName);
    await Hive.openBox<FeedbackModel>(feedbackBoxName);
    await Hive.openBox(currentUserBoxName);
  }

  // ── Current User (logged in profile) ─────────────────────────────────────

  static Box get _currentUserBox => Hive.box(currentUserBoxName);

  static void saveCurrentUserId(String id) {
    _currentUserBox.put('currentUserId', id);
  }

  static String? getCurrentUserId() {
    return _currentUserBox.get('currentUserId');
  }

  static void clearCurrentUser() {
    _currentUserBox.delete('currentUserId');
  }

  // ── Users Box ────────────────────────────────────────────────────────────

  static Box<UserModel> get _usersBox => Hive.box<UserModel>(usersBoxName);

  static Future<void> saveUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  static UserModel? getUser(String id) => _usersBox.get(id);

  static List<UserModel> getAllUsers() => _usersBox.values.toList();

  static List<UserModel> getUnsyncedUsers() =>
      _usersBox.values.where((u) => !u.isSynced).toList();

  static Future<void> deleteUser(String id) async {
    await _usersBox.delete(id);
  }

  // ── Sessions Box ─────────────────────────────────────────────────────────

  static Box<SessionModel> get _sessionsBox =>
      Hive.box<SessionModel>(sessionsBoxName);

  static Future<void> saveSession(SessionModel session) async {
    await _sessionsBox.put(session.sessionId, session);
  }

  static SessionModel? getSession(String sessionId) =>
      _sessionsBox.get(sessionId);

  static List<SessionModel> getAllSessions() => _sessionsBox.values.toList();

  static List<SessionModel> getUnsyncedSessions() =>
      _sessionsBox.values.where((s) => !s.isSynced).toList();

  static List<SessionModel> getSessionsByUser(String userId) {
    return _sessionsBox.values
        .where((s) => s.tutorId == userId || s.learnerId == userId)
        .toList();
  }

  static Future<void> updateSessionStatus(String sessionId, String status) async {
    final session = _sessionsBox.get(sessionId);
    if (session != null) {
      session.status = status;
      session.isSynced = false;
      await session.save();
    }
  }

  // ── Feedback Box ─────────────────────────────────────────────────────────

  static Box<FeedbackModel> get _feedbackBox =>
      Hive.box<FeedbackModel>(feedbackBoxName);

  static Future<void> saveFeedback(FeedbackModel feedback) async {
    await _feedbackBox.put(feedback.feedbackId, feedback);
  }

  static List<FeedbackModel> getUnsyncedFeedback() =>
      _feedbackBox.values.where((f) => !f.isSynced).toList();

  static List<FeedbackModel> getFeedbackForTutor(String tutorId) {
    return _feedbackBox.values.where((f) => f.tutorId == tutorId).toList();
  }

  static bool hasSubmittedFeedback(String sessionId, String givenBy) {
    return _feedbackBox.values
        .any((f) => f.sessionId == sessionId && f.givenBy == givenBy);
  }
}

