// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 1;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      sessionId: fields[0] as String,
      tutorId: fields[1] as String,
      learnerId: fields[2] as String,
      tutorName: fields[3] as String,
      learnerName: fields[4] as String,
      subject: fields[5] as String,
      dateTime: fields[6] as DateTime,
      status: fields[7] as String,
      isSynced: fields[8] as bool,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.tutorId)
      ..writeByte(2)
      ..write(obj.learnerId)
      ..writeByte(3)
      ..write(obj.tutorName)
      ..writeByte(4)
      ..write(obj.learnerName)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.dateTime)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
