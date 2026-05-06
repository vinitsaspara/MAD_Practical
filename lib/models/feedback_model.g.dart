// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackModelAdapter extends TypeAdapter<FeedbackModel> {
  @override
  final int typeId = 2;

  @override
  FeedbackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedbackModel(
      feedbackId: fields[0] as String,
      sessionId: fields[1] as String,
      tutorId: fields[2] as String,
      learnerId: fields[3] as String,
      rating: fields[4] as int,
      comment: fields[5] as String,
      givenBy: fields[6] as String,
      createdAt: fields[7] as DateTime,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FeedbackModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.feedbackId)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.tutorId)
      ..writeByte(3)
      ..write(obj.learnerId)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.givenBy)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
