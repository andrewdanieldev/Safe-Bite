import 'package:flutter_test/flutter_test.dart';
import 'package:safebite/models/allergen.dart';
import 'package:safebite/models/scan_result.dart';
import 'package:safebite/providers/allergy_profile_provider.dart';
import 'package:safebite/services/storage_service.dart';

class FakeStorageService implements StorageService {
  List<Allergen> _allergens = [];
  final Map<String, ScanResult> _scans = {};
  int saveAllergensCalls = 0;

  @override
  bool get hasProfile => _allergens.isNotEmpty;

  @override
  List<Allergen> loadAllergens() => List.of(_allergens);

  @override
  Future<void> saveAllergens(List<Allergen> allergens) async {
    _allergens = List.of(allergens);
    saveAllergensCalls++;
  }

  @override
  List<ScanResult> loadScans() {
    final scans = _scans.values.toList();
    scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return scans;
  }

  @override
  Future<void> saveScan(ScanResult scan) async {
    _scans[scan.id] = scan;
  }

  @override
  Future<void> deleteScan(String id) async {
    _scans.remove(id);
  }
}

void main() {
  late FakeStorageService fakeStorage;
  late AllergyProfileNotifier notifier;

  setUp(() {
    fakeStorage = FakeStorageService();
    notifier = AllergyProfileNotifier(fakeStorage);
  });

  test('toggleAllergen adds allergen when not selected', () {
    notifier.toggleAllergen(AllergenType.peanuts);

    expect(notifier.state.length, 1);
    expect(notifier.state.first.type, AllergenType.peanuts);
  });

  test('toggleAllergen removes allergen when already selected', () {
    notifier.toggleAllergen(AllergenType.peanuts);
    notifier.toggleAllergen(AllergenType.peanuts);

    expect(notifier.state, isEmpty);
  });

  test('addCustomAllergen adds with custom name', () {
    notifier.addCustomAllergen('Mango');

    expect(notifier.state.length, 1);
    expect(notifier.state.first.type, AllergenType.custom);
    expect(notifier.state.first.customName, 'Mango');
  });

  test('addCustomAllergen prevents duplicates (case-insensitive)', () {
    notifier.addCustomAllergen('Mango');
    notifier.addCustomAllergen('mango');
    notifier.addCustomAllergen('MANGO');

    expect(notifier.state.length, 1);
  });

  test('addCustomAllergen ignores empty/whitespace input', () {
    notifier.addCustomAllergen('');
    notifier.addCustomAllergen('   ');

    expect(notifier.state, isEmpty);
  });

  test('removeAllergen removes correct allergen', () {
    notifier.toggleAllergen(AllergenType.peanuts);
    notifier.toggleAllergen(AllergenType.dairy);

    final peanut = notifier.state.firstWhere((a) => a.type == AllergenType.peanuts);
    notifier.removeAllergen(peanut);

    expect(notifier.state.length, 1);
    expect(notifier.state.first.type, AllergenType.dairy);
  });

  test('updateSeverity changes severity for correct allergen', () {
    notifier.toggleAllergen(AllergenType.peanuts);

    final peanut = notifier.state.first;
    expect(peanut.severity, Severity.moderate); // default

    notifier.updateSeverity(peanut, Severity.severe);

    expect(notifier.state.first.severity, Severity.severe);
  });

  test('changes persist to storage', () {
    notifier.toggleAllergen(AllergenType.peanuts);

    expect(fakeStorage.saveAllergensCalls, 1);
    expect(fakeStorage.loadAllergens().first.type, AllergenType.peanuts);
  });
}
