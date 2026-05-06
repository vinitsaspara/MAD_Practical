import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SessionModel extends HiveObject {
  @HiveField(0)
  late String sessionId;

  @HiveField(1)
  late String tutorId;

  @HiveField(2)
  late String learnerId;

  @HiveField(3)
  late String tutorName;

  @HiveField(4)
  late String learnerName;

  @HiveField(5)
  late String subject;

  @HiveField(6)
  late DateTime dateTime;

  @HiveField(7)
  late String status; // 'scheduled' | 'completed' | 'cancelled'

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  String? notes;

  SessionModel({
    required this.sessionId,
    required this.tutorId,
    required this.learnerId,
    required this.tutorName,
    required this.learnerName,
    required this.subject,
    required this.dateTime,
    this.status = 'scheduled',
    this.isSynced = false,
    this.notes,
  });

  /// Convert to JSON map for API
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'tutorId': tutorId,
      'learnerId': learnerId,
      'tutorName': tutorName,
      'learnerName': learnerName,
      'subject': subject,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  /// Create from JSON map
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['sessionId'] ?? json['_id']?.toString() ?? '',
      tutorId: json['tutorId'] ?? '',
      learnerId: json['learnerId'] ?? '',
      tutorName: json['tutorName'] ?? '',
      learnerName: json['learnerName'] ?? '',
      subject: json['subject'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'] ?? 'scheduled',
      isSynced: true,
      notes: json['notes'],
    );
  }

  SessionModel copyWith({
    String? sessionId,
    String? tutorId,
    String? learnerId,
    String? tutorName,
    String? learnerName,
    String? subject,
    DateTime? dateTime,
    String? status,
    bool? isSynced,
    String? notes,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      tutorId: tutorId ?? this.tutorId,
      learnerId: learnerId ?? this.learnerId,
      tutorName: tutorName ?? this.tutorName,
      learnerName: learnerName ?? this.learnerName,
      subject: subject ?? this.subject,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }
}

