import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safebite/models/allergen.dart';
import 'package:safebite/models/scan_result.dart';
import 'package:safebite/services/storage_service.dart';

void main() {
  late Directory tempDir;
  late StorageService storage;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('safebite_storage_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(AllergenTypeAdapter());
    Hive.registerAdapter(SeverityAdapter());
    Hive.registerAdapter(AllergenAdapter());
    Hive.registerAdapter(ScanResultAdapter());
  });

  setUp(() async {
    await Hive.openBox<Allergen>('allergens');
    await Hive.openBox<ScanResult>('scans');
    storage = StorageService();
  });

  tearDown(() async {
    await Hive.box<Allergen>('allergens').clear();
    await Hive.box<ScanResult>('scans').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('hasProfile returns false when allergens box is empty', () {
    expect(storage.hasProfile, false);
  });

  test('hasProfile returns true when allergens exist', () async {
    await storage.saveAllergens([Allergen(type: AllergenType.peanuts)]);
    expect(storage.hasProfile, true);
  });

  test('saveAllergens then loadAllergens round-trips correctly', () async {
    final allergens = [
      Allergen(type: AllergenType.peanuts, severity: Severity.severe),
      Allergen(type: AllergenType.dairy, severity: Severity.mild),
    ];

    await storage.saveAllergens(allergens);
    final loaded = storage.loadAllergens();

    expect(loaded.length, 2);
    expect(loaded[0].type, AllergenType.peanuts);
    expect(loaded[0].severity, Severity.severe);
    expect(loaded[1].type, AllergenType.dairy);
    expect(loaded[1].severity, Severity.mild);
  });

  test('saveScan then loadScans returns scans sorted by date', () async {
    final older = ScanResult(
      id: 'old',
      rawOcrText: 'old menu',
      itemsJson: '[]',
      scannedAt: DateTime(2025, 1, 1),
    );
    final newer = ScanResult(
      id: 'new',
      rawOcrText: 'new menu',
      itemsJson: '[]',
      scannedAt: DateTime(2025, 6, 1),
    );

    await storage.saveScan(older);
    await storage.saveScan(newer);

    final scans = storage.loadScans();
    expect(scans.length, 2);
    expect(scans.first.id, 'new'); // newer first
    expect(scans.last.id, 'old');
  });

  test('deleteScan removes the scan from storage', () async {
    final scan = ScanResult(
      id: 'to-delete',
      rawOcrText: 'menu',
      itemsJson: '[]',
      scannedAt: DateTime.now(),
    );

    await storage.saveScan(scan);
    expect(storage.loadScans().length, 1);

    await storage.deleteScan('to-delete');
    expect(storage.loadScans(), isEmpty);
  });
}
