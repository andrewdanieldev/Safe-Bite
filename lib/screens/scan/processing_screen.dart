import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../providers/history_provider.dart';
import '../../providers/scan_provider.dart';

class ProcessingScreen extends ConsumerWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final theme = Theme.of(context);

    // Navigate to results when complete; refresh history so the History tab shows the new scan
    ref.listen(scanProvider, (previous, next) {
      if (next.status == ScanStatus.complete) {
        ref.read(historyProvider.notifier).reload();
        context.go('/results');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (scanState.status == ScanStatus.error) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  scanState.error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Try Again'),
                ),
              ] else ...[
                Lottie.asset(
                  'assets/animations/scanning.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                const SizedBox(height: 32),
                Text(
                  scanState.statusMessage ?? 'Processing...',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  _getSubtitle(scanState.status),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (scanState.rawOcrText != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        scanState.rawOcrText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(ScanStatus status) {
    return switch (status) {
      ScanStatus.extracting => 'Using OCR to read the menu text...',
      ScanStatus.analyzing =>
        'AI is checking every dish against your allergens...',
      _ => 'Please wait...',
    };
  }
}
