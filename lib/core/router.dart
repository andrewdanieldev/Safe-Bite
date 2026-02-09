import 'package:go_router/go_router.dart';
import '../screens/onboarding/allergy_setup_screen.dart';
import '../screens/scan/camera_screen.dart';
import '../screens/scan/processing_screen.dart';
import '../screens/scan/results_screen.dart';
import '../screens/detail/item_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home_screen.dart';
import '../services/storage_service.dart';

GoRouter createRouter(StorageService storage) {
  return GoRouter(
    initialLocation: storage.hasProfile ? '/scan' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const AllergySetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/scan',
            builder: (context, state) => const CameraScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/processing',
        builder: (context, state) => const ProcessingScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/detail/:index',
        builder: (context, state) {
          final index = int.parse(state.pathParameters['index']!);
          return ItemDetailScreen(itemIndex: index);
        },
      ),
    ],
  );
}
