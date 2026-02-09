// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllergenTypeAdapter extends TypeAdapter<AllergenType> {
  @override
  final int typeId = 0;

  @override
  AllergenType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AllergenType.peanuts;
      case 1:
        return AllergenType.treeNuts;
      case 2:
        return AllergenType.dairy;
      case 3:
        return AllergenType.eggs;
      case 4:
        return AllergenType.wheat;
      case 5:
        return AllergenType.soy;
      case 6:
        return AllergenType.fish;
      case 7:
        return AllergenType.shellfish;
      case 8:
        return AllergenType.sesame;
      case 9:
        return AllergenType.mustard;
      case 10:
        return AllergenType.celery;
      case 11:
        return AllergenType.lupin;
      case 12:
        return AllergenType.mollusks;
      case 13:
        return AllergenType.sulfites;
      case 14:
        return AllergenType.custom;
      default:
        return AllergenType.custom;
    }
  }

  @override
  void write(BinaryWriter writer, AllergenType obj) {
    switch (obj) {
      case AllergenType.peanuts:
        writer.writeByte(0);
        break;
      case AllergenType.treeNuts:
        writer.writeByte(1);
        break;
      case AllergenType.dairy:
        writer.writeByte(2);
        break;
      case AllergenType.eggs:
        writer.writeByte(3);
        break;
      case AllergenType.wheat:
        writer.writeByte(4);
        break;
      case AllergenType.soy:
        writer.writeByte(5);
        break;
      case AllergenType.fish:
        writer.writeByte(6);
        break;
      case AllergenType.shellfish:
        writer.writeByte(7);
        break;
      case AllergenType.sesame:
        writer.writeByte(8);
        break;
      case AllergenType.mustard:
        writer.writeByte(9);
        break;
      case AllergenType.celery:
        writer.writeByte(10);
        break;
      case AllergenType.lupin:
        writer.writeByte(11);
        break;
      case AllergenType.mollusks:
        writer.writeByte(12);
        break;
      case AllergenType.sulfites:
        writer.writeByte(13);
        break;
      case AllergenType.custom:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllergenTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeverityAdapter extends TypeAdapter<Severity> {
  @override
  final int typeId = 1;

  @override
  Severity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Severity.mild;
      case 1:
        return Severity.moderate;
      case 2:
        return Severity.severe;
      default:
        return Severity.moderate;
    }
  }

  @override
  void write(BinaryWriter writer, Severity obj) {
    switch (obj) {
      case Severity.mild:
        writer.writeByte(0);
        break;
      case Severity.moderate:
        writer.writeByte(1);
        break;
      case Severity.severe:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AllergenAdapter extends TypeAdapter<Allergen> {
  @override
  final int typeId = 2;

  @override
  Allergen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Allergen(
      type: fields[0] as AllergenType,
      customName: fields[1] as String?,
      severity: fields[2] as Severity,
    );
  }

  @override
  void write(BinaryWriter writer, Allergen obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.customName)
      ..writeByte(2)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllergenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
