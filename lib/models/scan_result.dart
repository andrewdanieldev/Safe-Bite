import 'dart:convert';
import 'package:hive/hive.dart';
import 'menu_item_result.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 3)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? restaurantName;

  @HiveField(2)
  final String? cuisineType;

  @HiveField(3)
  final String rawOcrText;

  @HiveField(4)
  final String itemsJson; // Stored as JSON string for Hive compatibility

  @HiveField(5)
  final DateTime scannedAt;

  @HiveField(6)
  final String? imagePath;

  ScanResult({
    required this.id,
    this.restaurantName,
    this.cuisineType,
    required this.rawOcrText,
    required this.itemsJson,
    required this.scannedAt,
    this.imagePath,
  });

  List<MenuItemResult> get items {
    try {
      final list = jsonDecode(itemsJson) as List;
      return list
          .map((e) => MenuItemResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  int get safeCount =>
      items.where((i) => i.riskLevel == RiskLevel.safe).length;
  int get cautionCount =>
      items.where((i) => i.riskLevel == RiskLevel.caution).length;
  int get dangerCount =>
      items.where((i) => i.riskLevel == RiskLevel.danger).length;
}
