import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/allergen.dart';
import 'models/scan_result.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(AllergenTypeAdapter());
  Hive.registerAdapter(SeverityAdapter());
  Hive.registerAdapter(AllergenAdapter());
  Hive.registerAdapter(ScanResultAdapter());

  await Hive.openBox<Allergen>('allergens');
  await Hive.openBox<ScanResult>('scans');

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: SafeBiteApp()));
}
