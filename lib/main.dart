import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/allergen.dart';
import 'models/scan_result.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(AllergenTypeAdapter());
  Hive.registerAdapter(SeverityAdapter());
  Hive.registerAdapter(AllergenAdapter());
  Hive.registerAdapter(ScanResultAdapter());

  await Hive.openBox<Allergen>('allergens');
  await Hive.openBox<ScanResult>('scans');

  runApp(const ProviderScope(child: SafeBiteApp()));
}
