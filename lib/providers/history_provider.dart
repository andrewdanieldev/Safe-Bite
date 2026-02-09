import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import 'allergy_profile_provider.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<ScanResult>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return HistoryNotifier(storage);
});

class HistoryNotifier extends StateNotifier<List<ScanResult>> {
  final StorageService _storage;

  HistoryNotifier(this._storage) : super([]) {
    reload();
  }

  void reload() {
    state = _storage.loadScans();
  }

  Future<void> deleteScan(String id) async {
    await _storage.deleteScan(id);
    reload();
  }
}
