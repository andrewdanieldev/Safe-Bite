// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 3;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResult(
      id: fields[0] as String,
      restaurantName: fields[1] as String?,
      cuisineType: fields[2] as String?,
      rawOcrText: fields[3] as String,
      itemsJson: fields[4] as String,
      scannedAt: fields[5] as DateTime,
      imagePath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.restaurantName)
      ..writeByte(2)
      ..write(obj.cuisineType)
      ..writeByte(3)
      ..write(obj.rawOcrText)
      ..writeByte(4)
      ..write(obj.itemsJson)
      ..writeByte(5)
      ..write(obj.scannedAt)
      ..writeByte(6)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
