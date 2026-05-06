import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import 'api_service.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  final ApiService _apiService;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService(this._apiService) {
    _init();
  }

  Future<void> _init() async {
    // Check current status
    final results = await Connectivity().checkConnectivity();
    _isOnline = _isConnected(results);

    // Listen for changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      final wasOffline = !_isOnline;
      _isOnline = _isConnected(results);
      notifyListeners();

      // When coming back online, sync pending data
      if (wasOffline && _isOnline) {
        await syncPendingData();
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    if (kIsWeb) return true; // Web cannot reliably detect localhost status
    return results.isNotEmpty &&
        results.any((r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet);
  }

  /// Sync all unsynced local data to the backend
  Future<void> syncPendingData() async {
    if (!_isOnline) return;
    debugPrint('[Sync] Starting sync of pending offline data...');

    // Sync users
    final unsyncedUsers = HiveService.getUnsyncedUsers();
    for (final user in unsyncedUsers) {
      final result = await _apiService.createOrUpdateUser(user);
      if (result != null) {
        user.isSynced = true;
        await user.save();
        debugPrint('[Sync] Synced user: ${user.id}');
      }
    }

    // Sync sessions
    final unsyncedSessions = HiveService.getUnsyncedSessions();
    for (final session in unsyncedSessions) {
      final result = await _apiService.createSession(session);
      if (result != null) {
        session.isSynced = true;
        await session.save();
        debugPrint('[Sync] Synced session: ${session.sessionId}');
      }
    }

    // Sync feedback
    final unsyncedFeedback = HiveService.getUnsyncedFeedback();
    for (final feedback in unsyncedFeedback) {
      final result = await _apiService.submitFeedback(feedback);
      if (result != null) {
        feedback.isSynced = true;
        await feedback.save();
        debugPrint('[Sync] Synced feedback: ${feedback.feedbackId}');
      }
    }

    debugPrint('[Sync] Sync complete.');
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

