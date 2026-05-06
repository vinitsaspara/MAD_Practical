import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';

class SessionProvider extends ChangeNotifier {
  final ApiService _apiService;
  final _uuid = const Uuid();

  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SessionModel> get upcomingSessions => _sessions
      .where((s) => s.status == 'scheduled' && s.dateTime.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<SessionModel> get completedSessions =>
      _sessions.where((s) => s.status == 'completed').toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<SessionModel> get cancelledSessions =>
      _sessions.where((s) => s.status == 'cancelled').toList();

  SessionProvider(this._apiService);

  Future<void> loadSessionsForUser(String userId) async {
    _sessions = HiveService.getSessionsByUser(userId);
    notifyListeners();

    try {
      final apiSessions = await _apiService.getSessionsByUser(userId);
      for (final s in apiSessions) {
        await HiveService.saveSession(s);
      }
      _sessions = HiveService.getSessionsByUser(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('[SessionProvider] API fetch failed: $e');
    }
  }

  /// Book a new session — returns (success, sessionId or errorMessage)
  Future<(bool, String)> bookSession({
    required UserModel tutor,
    required UserModel learner,
    required String subject,
    required DateTime dateTime,
    String? notes,
  }) async {
    _error = null;

    // ── Conflict Detection ──────────────────────────────────────────────────
    // 1. Tutor already has session at this time
    final tutorConflict = _sessions.any((s) =>
        s.tutorId == tutor.id &&
        s.status == 'scheduled' &&
        _isSameTimeSlot(s.dateTime, dateTime));
    if (tutorConflict) {
      return (false, '${tutor.name} already has a session at this time.');
    }

    // 2. Learner already has session at this time
    final learnerConflict = _sessions.any((s) =>
        s.learnerId == learner.id &&
        s.status == 'scheduled' &&
        _isSameTimeSlot(s.dateTime, dateTime));
    if (learnerConflict) {
      return (false, 'You already have a session booked at this time.');
    }

    // ── Generate Session ID ────────────────────────────────────────────────
    final ts = DateTime.now().millisecondsSinceEpoch;
    final shortId = _uuid.v4().substring(0, 6).toUpperCase();
    final sessionId = 'TUT-$ts-$shortId';

    final session = SessionModel(
      sessionId: sessionId,
      tutorId: tutor.id,
      learnerId: learner.id,
      tutorName: tutor.name,
      learnerName: learner.name,
      subject: subject,
      dateTime: dateTime,
      status: 'scheduled',
      isSynced: false,
      notes: notes,
    );

    // Save locally first
    await HiveService.saveSession(session);
    _sessions = HiveService.getSessionsByUser(learner.id);
    notifyListeners();

    // Try API sync
    try {
      final result = await _apiService.createSession(session);
      if (result != null) {
        session.isSynced = true;
        await HiveService.saveSession(session);
      }
    } catch (e) {
      debugPrint('[SessionProvider] Could not sync session to API: $e');
    }

    return (true, sessionId);
  }

  Future<bool> updateStatus(String sessionId, String newStatus) async {
    await HiveService.updateSessionStatus(sessionId, newStatus);
    _sessions = HiveService.getSessionsByUser(
        _sessions.firstWhere((s) => s.sessionId == sessionId).learnerId);
    notifyListeners();

    try {
      return await _apiService.updateSessionStatus(sessionId, newStatus);
    } catch (e) {
      debugPrint('[SessionProvider] Status update API failed: $e');
      return false;
    }
  }

  Future<bool> submitFeedback({
    required SessionModel session,
    required int rating,
    required String comment,
    required String givenBy,
  }) async {
    // Prevent duplicate feedback
    if (HiveService.hasSubmittedFeedback(session.sessionId, givenBy)) {
      _error = 'You have already submitted feedback for this session.';
      notifyListeners();
      return false;
    }

    final feedback = FeedbackModel(
      feedbackId: _uuid.v4(),
      sessionId: session.sessionId,
      tutorId: session.tutorId,
      learnerId: session.learnerId,
      rating: rating,
      comment: comment,
      givenBy: givenBy,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await HiveService.saveFeedback(feedback);

    try {
      final result = await _apiService.submitFeedback(feedback);
      if (result != null) {
        feedback.isSynced = true;
        await HiveService.saveFeedback(feedback);
      }
    } catch (e) {
      debugPrint('[SessionProvider] Feedback sync failed: $e');
    }

    // Mark session as completed after feedback
    await updateStatus(session.sessionId, 'completed');
    return true;
  }

  /// Check if two DateTimes fall within the same 1-hour slot
  bool _isSameTimeSlot(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }
}

