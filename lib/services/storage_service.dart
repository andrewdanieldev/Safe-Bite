import 'package:hive/hive.dart';
import '../models/allergen.dart';
import '../models/scan_result.dart';

class StorageService {
  static const _allergensBoxName = 'allergens';
  static const _scansBoxName = 'scans';

  Box<Allergen> get _allergensBox => Hive.box<Allergen>(_allergensBoxName);
  Box<ScanResult> get _scansBox => Hive.box<ScanResult>(_scansBoxName);

  // --- Allergy Profile ---

  bool get hasProfile => _allergensBox.isNotEmpty;

  List<Allergen> loadAllergens() => _allergensBox.values.toList();

  Future<void> saveAllergens(List<Allergen> allergens) async {
    await _allergensBox.clear();
    for (final allergen in allergens) {
      await _allergensBox.add(allergen);
    }
  }

  // --- Scan History ---

  List<ScanResult> loadScans() {
    final scans = _scansBox.values.toList();
    scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return scans;
  }

  Future<void> saveScan(ScanResult scan) async {
    await _scansBox.put(scan.id, scan);
  }

  Future<void> deleteScan(String id) async {
    await _scansBox.delete(id);
  }
}
