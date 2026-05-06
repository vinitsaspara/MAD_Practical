import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 2)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  late String feedbackId;

  @HiveField(1)
  late String sessionId;

  @HiveField(2)
  late String tutorId;

  @HiveField(3)
  late String learnerId;

  @HiveField(4)
  late int rating; // 1 to 5

  @HiveField(5)
  late String comment;

  @HiveField(6)
  late String givenBy; // userId of feedback giver

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  bool isSynced;

  FeedbackModel({
    required this.feedbackId,
    required this.sessionId,
    required this.tutorId,
    required this.learnerId,
    required this.rating,
    required this.comment,
    required this.givenBy,
    required this.createdAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'sessionId': sessionId,
      'tutorId': tutorId,
      'learnerId': learnerId,
      'rating': rating,
      'comment': comment,
      'givenBy': givenBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] ?? json['_id']?.toString() ?? '',
      sessionId: json['sessionId'] ?? '',
      tutorId: json['tutorId'] ?? '',
      learnerId: json['learnerId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      givenBy: json['givenBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isSynced: true,
    );
  }
}

