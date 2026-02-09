import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  Future<String> extractTextFromMultipleImages(List<String> imagePaths) async {
    final buffer = StringBuffer();
    for (final path in imagePaths) {
      final text = await extractText(path);
      if (text.isNotEmpty) {
        buffer.writeln(text);
        buffer.writeln('---'); // page separator
      }
    }
    return buffer.toString();
  }

  void dispose() => _textRecognizer.close();
}
