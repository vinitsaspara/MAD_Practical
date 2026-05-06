import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class TutorProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<UserModel> _allTutors = [];
  List<UserModel> _filteredTutors = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  String _searchQuery = '';
  String? _filterSkill;
  double _minRating = 0.0;
  String? _filterSubject;
  String? _filterAvailability;

  List<UserModel> get tutors => _filteredTutors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get filterSkill => _filterSkill;
  double get minRating => _minRating;
  String? get filterSubject => _filterSubject;

  TutorProvider(this._apiService);

  /// Load tutors for a given learner — applying matching logic
  Future<void> loadTutorsForLearner(UserModel? learner) async {
    _setLoading(true);

    // Load from Hive cache first
    _allTutors = HiveService.getAllUsers()
        .where((u) => learner == null || u.id != learner.id)
        .toList();

    _applyFilters(learner);
    notifyListeners();

    // Then refresh from API
    try {
      final apiTutors = await _apiService.getAllTutors();
      for (final t in apiTutors) {
        await HiveService.saveUser(t);
      }
      _allTutors = apiTutors
          .where((u) => learner == null || u.id != learner.id)
          .toList();
      _applyFilters(learner);
    } catch (e) {
      debugPrint('[TutorProvider] API fetch failed, using cached: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilters(UserModel? learner) {
    List<UserModel> result = List.from(_allTutors);

    // 1. Subject filter
    if (_filterSubject != null && _filterSubject!.isNotEmpty) {
      result = result
          .where((t) => t.subjects
              .any((s) => s.toLowerCase() == _filterSubject!.toLowerCase()))
          .toList();
    }

    // 2. Skill level filter
    if (_filterSkill != null && _filterSkill!.isNotEmpty) {
      result = result.where((t) => t.skillLevel == _filterSkill).toList();
    }

    // 4. Rating filter
    if (_minRating > 0) {
      result = result.where((t) => t.rating >= _minRating).toList();
    }

    // 5. Availability filter
    if (_filterAvailability != null && _filterAvailability!.isNotEmpty) {
      result = result.where((t) => t.availability.contains(_filterAvailability)).toList();
    }

    // 6. Search query (name or subject)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.name.toLowerCase().contains(q) ||
            t.subjects.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    // 7. Sort by match score (rating * subject overlap)
    result.sort((a, b) {
      final scoreA = _matchScore(a, learner);
      final scoreB = _matchScore(b, learner);
      return scoreB.compareTo(scoreA);
    });

    _filteredTutors = result;
  }

  /// Check if tutor's skill level is >= learner's skill level
  bool _isSkillCompatible(String tutorSkill, String learnerSkill) {
    const levels = {'beginner': 0, 'intermediate': 1, 'advanced': 2};
    final tLevel = levels[tutorSkill.toLowerCase()] ?? 0;
    final lLevel = levels[learnerSkill.toLowerCase()] ?? 0;
    return tLevel >= lLevel;
  }

  /// Calculate a match score for sorting
  double _matchScore(UserModel tutor, UserModel? learner) {
    if (learner == null) return tutor.rating;
    final subjectOverlap = tutor.subjects
        .where((s) => learner.subjects.any((ls) => ls.toLowerCase() == s.toLowerCase()))
        .length;
    return tutor.rating + subjectOverlap * 0.5;
  }

  void updateSearch(String query, UserModel? learner) {
    _searchQuery = query;
    _applyFilters(learner);
    notifyListeners();
  }

  void updateFilters({
    String? skill,
    double? minRating,
    String? subject,
    String? availability,
    UserModel? learner,
  }) {
    _filterSkill = skill;
    _minRating = minRating ?? 0.0;
    _filterSubject = subject;
    _filterAvailability = availability;
    _applyFilters(learner);
    notifyListeners();
  }

  void resetFilters(UserModel? learner) {
    _searchQuery = '';
    _filterSkill = null;
    _minRating = 0.0;
    _filterSubject = null;
    _filterAvailability = null;
    _applyFilters(learner);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}

