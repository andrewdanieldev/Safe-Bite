import 'package:flutter_test/flutter_test.dart';
import 'package:safebite/models/allergen.dart';
import 'package:safebite/models/menu_item_result.dart';
import 'package:safebite/models/scan_result.dart';
import 'package:safebite/providers/scan_provider.dart';
import 'package:safebite/services/llm_service.dart';
import 'package:safebite/services/ocr_service.dart';
import 'package:safebite/services/image_service.dart';
import 'package:safebite/services/storage_service.dart';

// --- Fake services ---

class FakeOcrService implements OcrService {
  String textToReturn = 'Pad Thai 12.99\nGreen Curry 14.99';
  bool shouldReturnEmpty = false;

  @override
  Future<String> extractText(String imagePath) async =>
      shouldReturnEmpty ? '' : textToReturn;

  @override
  Future<String> extractTextFromMultipleImages(List<String> imagePaths) async =>
      shouldReturnEmpty ? '' : textToReturn;

  @override
  void dispose() {}
}

class FakeLlmService implements LlmService {
  List<MenuItemResult> itemsToReturn = [];
  bool shouldThrow = false;

  @override
  String buildPrompt(String ocrText, List<Allergen> allergens, String? cuisineHint) => '';

  @override
  List<MenuItemResult> parseResults(String text) => [];

  @override
  Future<List<MenuItemResult>> analyzeMenu({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async {
    if (shouldThrow) throw LlmException('Test error');
    return itemsToReturn;
  }

  @override
  Stream<StreamingUpdate> analyzeMenuStreaming({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async* {
    yield StreamingUpdate(
      partialText: '',
      isComplete: true,
      items: itemsToReturn,
    );
  }

  @override
  Stream<StreamingUpdate> analyzeMenuWithFallback({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async* {
    if (shouldThrow) throw LlmException('Test error');
    yield StreamingUpdate(
      partialText: '',
      isComplete: true,
      items: itemsToReturn,
    );
  }
}

class FakeImageService implements ImageService {
  @override
  Future<String> preprocessForOcr(String imagePath) async => imagePath;

  @override
  Future<List<String>> preprocessMultiple(List<String> paths) async => paths;
}

class FakeStorageService implements StorageService {
  final List<ScanResult> _savedScans = [];

  @override
  bool get hasProfile => false;

  @override
  List<Allergen> loadAllergens() => [];

  @override
  Future<void> saveAllergens(List<Allergen> allergens) async {}

  @override
  List<ScanResult> loadScans() => _savedScans;

  @override
  Future<void> saveScan(ScanResult scan) async {
    _savedScans.add(scan);
  }

  @override
  Future<void> deleteScan(String id) async {
    _savedScans.removeWhere((s) => s.id == id);
  }
}

// --- Tests ---

void main() {
  late FakeOcrService fakeOcr;
  late FakeLlmService fakeLlm;
  late FakeImageService fakeImage;
  late FakeStorageService fakeStorage;
  late ScanNotifier notifier;

  setUp(() {
    fakeOcr = FakeOcrService();
    fakeLlm = FakeLlmService();
    fakeImage = FakeImageService();
    fakeStorage = FakeStorageService();

    notifier = ScanNotifier(
      ocrService: fakeOcr,
      llmService: fakeLlm,
      imageService: fakeImage,
      storage: fakeStorage,
      allergens: [Allergen(type: AllergenType.peanuts)],
    );
  });

  test('initial state is idle', () {
    expect(notifier.state.status, ScanStatus.idle);
    expect(notifier.state.imagePaths, isEmpty);
  });

  test('addImage adds path to state', () {
    notifier.addImage('/path/to/image.jpg');

    expect(notifier.state.imagePaths, ['/path/to/image.jpg']);
  });

  test('addImage supports multiple images', () {
    notifier.addImage('/a.jpg');
    notifier.addImage('/b.jpg');

    expect(notifier.state.imagePaths, ['/a.jpg', '/b.jpg']);
  });

  test('removeImage removes correct index', () {
    notifier.addImage('/a.jpg');
    notifier.addImage('/b.jpg');
    notifier.addImage('/c.jpg');
    notifier.removeImage(1);

    expect(notifier.state.imagePaths, ['/a.jpg', '/c.jpg']);
  });

  test('reset returns to idle state', () {
    notifier.addImage('/a.jpg');
    notifier.reset();

    expect(notifier.state.status, ScanStatus.idle);
    expect(notifier.state.imagePaths, isEmpty);
    expect(notifier.state.result, isNull);
    expect(notifier.state.error, isNull);
  });

  test('loadFromHistory sets complete state with historical scan', () {
    final scan = ScanResult(
      id: 'test-id',
      rawOcrText: 'Some menu text',
      itemsJson: '[]',
      scannedAt: DateTime.now(),
    );

    notifier.loadFromHistory(scan);

    expect(notifier.state.status, ScanStatus.complete);
    expect(notifier.state.result, scan);
    expect(notifier.state.rawOcrText, 'Some menu text');
  });

  test('analyze does nothing when imagePaths is empty', () async {
    await notifier.analyze();

    expect(notifier.state.status, ScanStatus.idle);
  });

  test('analyze transitions to complete on success', () async {
    notifier.addImage('/test.jpg');
    fakeLlm.itemsToReturn = [
      const MenuItemResult(
        name: 'Pad Thai',
        riskLevel: RiskLevel.danger,
        explanation: 'Contains peanuts',
        confirmedAllergens: ['peanuts'],
        confidence: 90,
      ),
    ];

    await notifier.analyze();

    expect(notifier.state.status, ScanStatus.complete);
    expect(notifier.state.result, isNotNull);
    expect(notifier.state.result!.items.length, 1);
    expect(notifier.state.result!.items.first.name, 'Pad Thai');
  });

  test('analyze saves scan to storage on success', () async {
    notifier.addImage('/test.jpg');
    fakeLlm.itemsToReturn = [
      const MenuItemResult(
        name: 'Salad',
        riskLevel: RiskLevel.safe,
        explanation: 'Safe to eat',
      ),
    ];

    await notifier.analyze();

    expect(fakeStorage._savedScans.length, 1);
  });

  test('analyze handles empty OCR text gracefully', () async {
    notifier.addImage('/test.jpg');
    fakeOcr.shouldReturnEmpty = true;

    await notifier.analyze();

    expect(notifier.state.status, ScanStatus.error);
    expect(notifier.state.error, contains('Could not read any text'));
  });

  test('analyze handles LLM errors gracefully', () async {
    notifier.addImage('/test.jpg');
    fakeLlm.shouldThrow = true;

    await notifier.analyze();

    expect(notifier.state.status, ScanStatus.error);
    expect(notifier.state.error, contains('Test error'));
  });
}
