import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String role; // 'tutor' | 'learner' | 'both'

  @HiveField(4)
  late List<String> subjects;

  @HiveField(5)
  late String skillLevel; // 'beginner' | 'intermediate' | 'advanced'

  @HiveField(6)
  late List<String> availability; // e.g. ["Mon 10:00", "Wed 14:00"]

  @HiveField(7)
  double rating;

  @HiveField(8)
  int totalSessions;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.subjects,
    required this.skillLevel,
    required this.availability,
    this.rating = 0.0,
    this.totalSessions = 0,
    this.isSynced = false,
    this.bio,
  });

  /// Convert to JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'subjects': subjects,
      'skillLevel': skillLevel,
      'availability': availability,
      'rating': rating,
      'totalSessions': totalSessions,
      'bio': bio,
    };
  }

  /// Create from JSON map (API response / MongoDB document)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'learner',
      subjects: List<String>.from(json['subjects'] ?? []),
      skillLevel: json['skillLevel'] ?? 'beginner',
      availability: List<String>.from(json['availability'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      totalSessions: json['totalSessions'] ?? 0,
      isSynced: true,
      bio: json['bio'],
    );
  }

  /// Copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    List<String>? subjects,
    String? skillLevel,
    List<String>? availability,
    double? rating,
    int? totalSessions,
    bool? isSynced,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      subjects: subjects ?? this.subjects,
      skillLevel: skillLevel ?? this.skillLevel,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      isSynced: isSynced ?? this.isSynced,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() => 'UserModel($id, $name, $role)';
}

