import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers/allergy_profile_provider.dart';

class SafeBiteApp extends ConsumerWidget {
  const SafeBiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final router = createRouter(storage);

    return MaterialApp.router(
      title: Constants.appName,
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
