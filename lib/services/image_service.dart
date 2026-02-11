import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  /// Preprocesses an image for optimal OCR accuracy.
  /// Returns the path to the processed image.
  Future<String> preprocessForOcr(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) return imagePath; // Return original if decode fails

    // Step 1: Resize if too large (optimal for ML Kit: ~1500-2000px width)
    var processed = image;
    if (processed.width > 2000) {
      processed = img.copyResize(processed, width: 2000);
    }

    // Step 2: Convert to grayscale for better text contrast
    processed = img.grayscale(processed);

    // Step 3: Increase contrast to make text stand out
    processed = img.adjustColor(processed, contrast: 1.3);

    // Step 4: Sharpen to improve text edges
    processed = img.convolution(processed, filter: [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0,
    ]);

    // Save to temp directory
    final dir = await getTemporaryDirectory();
    final outputPath = '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(processed, quality: 92));

    return outputPath;
  }

  /// Preprocesses multiple images for OCR.
  Future<List<String>> preprocessMultiple(List<String> paths) async {
    final results = <String>[];
    for (final path in paths) {
      results.add(await preprocessForOcr(path));
    }
    return results;
  }
}
