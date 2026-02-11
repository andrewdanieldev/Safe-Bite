import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/allergen.dart';
import '../models/menu_item_result.dart';
import '../models/scan_result.dart';
import '../services/llm_service.dart';
import '../services/ocr_service.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import 'allergy_profile_provider.dart';

enum ScanStatus { idle, extracting, analyzing, complete, error }

class ScanState {
  final ScanStatus status;
  final String? statusMessage;
  final ScanResult? result;
  final String? error;
  final List<String> imagePaths;
  final String? rawOcrText;

  const ScanState({
    this.status = ScanStatus.idle,
    this.statusMessage,
    this.result,
    this.error,
    this.imagePaths = const [],
    this.rawOcrText,
  });

  ScanState copyWith({
    ScanStatus? status,
    String? statusMessage,
    ScanResult? result,
    String? error,
    List<String>? imagePaths,
    String? rawOcrText,
  }) {
    return ScanState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      result: result ?? this.result,
      error: error,
      imagePaths: imagePaths ?? this.imagePaths,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }
}

final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(
    ocrService: OcrService(),
    llmService: LlmService(),
    imageService: ImageService(),
    storage: ref.read(storageServiceProvider),
    allergens: ref.read(allergyProfileProvider),
  );
});

class ScanNotifier extends StateNotifier<ScanState> {
  final OcrService ocrService;
  final LlmService llmService;
  final ImageService imageService;
  final StorageService storage;
  final List<Allergen> allergens;

  ScanNotifier({
    required this.ocrService,
    required this.llmService,
    required this.imageService,
    required this.storage,
    required this.allergens,
  }) : super(const ScanState());

  void addImage(String path) {
    state = state.copyWith(imagePaths: [...state.imagePaths, path]);
  }

  void removeImage(int index) {
    final paths = [...state.imagePaths]..removeAt(index);
    state = state.copyWith(imagePaths: paths);
  }

  void reset() {
    state = const ScanState();
  }

  void loadFromHistory(ScanResult scan) {
    state = ScanState(
      status: ScanStatus.complete,
      result: scan,
      rawOcrText: scan.rawOcrText,
    );
  }

  Future<void> analyze() async {
    if (state.imagePaths.isEmpty) return;

    try {
      // Step 0: Preprocess images
      state = state.copyWith(
        status: ScanStatus.extracting,
        statusMessage: 'Enhancing image quality...',
        error: null,
      );

      final processedPaths = await imageService.preprocessMultiple(state.imagePaths);

      // Step 1: OCR (use processed paths)
      state = state.copyWith(statusMessage: 'Reading menu text...');
      final ocrText =
          await ocrService.extractTextFromMultipleImages(processedPaths);

      if (ocrText.trim().isEmpty) {
        state = state.copyWith(
          status: ScanStatus.error,
          error: 'Could not read any text from the image. '
              'Try taking a clearer photo.',
        );
        return;
      }

      // Step 2: LLM Analysis (streaming)
      state = state.copyWith(
        rawOcrText: ocrText,
        statusMessage: 'Analyzing ingredients...',
        status: ScanStatus.analyzing,
      );

      List<MenuItemResult>? items;
      await for (final update in llmService.analyzeMenuWithFallback(
        ocrText: ocrText,
        allergens: allergens,
      )) {
        if (update.fallbackMessage != null) {
          state = state.copyWith(statusMessage: update.fallbackMessage);
        }
        if (update.isComplete && update.items != null) {
          items = update.items;
        }
      }

      if (items == null || items.isEmpty) {
        state = state.copyWith(
          status: ScanStatus.error,
          error: 'Could not analyze the menu. Please try again.',
        );
        return;
      }

      // Step 3: Build result
      final scanResult = ScanResult(
        id: const Uuid().v4(),
        rawOcrText: ocrText,
        itemsJson: jsonEncode(items.map((i) => i.toJson()).toList()),
        scannedAt: DateTime.now(),
        imagePath: state.imagePaths.first,
      );

      await storage.saveScan(scanResult);

      state = state.copyWith(
        status: ScanStatus.complete,
        statusMessage: 'Done!',
        result: scanResult,
      );
    } on LlmException catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        error: 'Something went wrong: $e',
      );
    }
  }
}
