import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/allergen.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final allergyProfileProvider =
    StateNotifierProvider<AllergyProfileNotifier, List<Allergen>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return AllergyProfileNotifier(storage);
});

final hasProfileProvider = Provider((ref) {
  return ref.watch(allergyProfileProvider).isNotEmpty;
});

class AllergyProfileNotifier extends StateNotifier<List<Allergen>> {
  final StorageService _storage;

  AllergyProfileNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.loadAllergens();
  }

  void toggleAllergen(AllergenType type) {
    final existing = state.indexWhere((a) => a.type == type);
    if (existing >= 0) {
      state = [...state]..removeAt(existing);
    } else {
      state = [...state, Allergen(type: type)];
    }
    _persist();
  }

  void addCustomAllergen(String name) {
    if (name.trim().isEmpty) return;
    final already = state.any(
      (a) =>
          a.type == AllergenType.custom &&
          a.customName?.toLowerCase() == name.toLowerCase(),
    );
    if (already) return;

    state = [
      ...state,
      Allergen(type: AllergenType.custom, customName: name.trim()),
    ];
    _persist();
  }

  void removeAllergen(Allergen allergen) {
    state = state.where((a) => a != allergen).toList();
    _persist();
  }

  void updateSeverity(Allergen allergen, Severity severity) {
    state = state.map((a) {
      if (a == allergen) return a.copyWith(severity: severity);
      return a;
    }).toList();
    _persist();
  }

  bool isSelected(AllergenType type) => state.any((a) => a.type == type);

  Allergen? getAllergen(AllergenType type) {
    try {
      return state.firstWhere((a) => a.type == type);
    } catch (_) {
      return null;
    }
  }

  void _persist() {
    _storage.saveAllergens(state);
  }
}
