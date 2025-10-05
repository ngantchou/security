// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_alert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineAlertModelAdapter extends TypeAdapter<OfflineAlertModel> {
  @override
  final int typeId = 0;

  @override
  OfflineAlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAlertModel(
      localId: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      dangerType: fields[3] as String,
      level: fields[4] as int,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      neighborhood: fields[7] as String?,
      city: fields[8] as String?,
      region: fields[9] as String?,
      imageUrls: (fields[10] as List?)?.cast<String>(),
      audioCommentUrl: fields[11] as String?,
      userId: fields[12] as String,
      userName: fields[13] as String,
      createdAt: fields[14] as DateTime,
      isSynced: fields[15] as bool,
      syncError: fields[16] as String?,
      syncAttempts: fields[17] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAlertModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dangerType)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.neighborhood)
      ..writeByte(8)
      ..write(obj.city)
      ..writeByte(9)
      ..write(obj.region)
      ..writeByte(10)
      ..write(obj.imageUrls)
      ..writeByte(11)
      ..write(obj.audioCommentUrl)
      ..writeByte(12)
      ..write(obj.userId)
      ..writeByte(13)
      ..write(obj.userName)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.isSynced)
      ..writeByte(16)
      ..write(obj.syncError)
      ..writeByte(17)
      ..write(obj.syncAttempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
