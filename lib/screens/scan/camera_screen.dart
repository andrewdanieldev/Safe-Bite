import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/scan_provider.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final notifier = ref.read(scanProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Menu'),
        actions: [
          if (scanState.imagePaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.reset(),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: scanState.imagePaths.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildImagePreview(scanState, notifier),
            ),
            const SizedBox(height: 16),
            _buildCaptureButtons(context, notifier, theme),
            const SizedBox(height: 12),
            if (scanState.imagePaths.isNotEmpty)
              _buildAnalyzeButton(context, ref, scanState, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Take a photo of any menu',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll scan it and check for your allergens',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ScanState scanState, ScanNotifier notifier) {
    return ListView.separated(
      itemCount: scanState.imagePaths.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(scanState.imagePaths[index]),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                  onPressed: () => notifier.removeImage(index),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCaptureButtons(
    BuildContext context,
    ScanNotifier notifier,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(notifier, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(notifier, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    ThemeData theme,
  ) {
    return FilledButton.icon(
      onPressed: () {
        context.push('/processing');
        ref.read(scanProvider.notifier).analyze();
      },
      icon: const Icon(Icons.search),
      label: Text(
        'Analyze Menu (${scanState.imagePaths.length} '
        '${scanState.imagePaths.length == 1 ? "page" : "pages"})',
      ),
    );
  }

  Future<void> _pickImage(ScanNotifier notifier, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (image != null) {
      notifier.addImage(image.path);
    }
  }
}
