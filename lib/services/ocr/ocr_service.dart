import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OCRResult> recognizeFromFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final recognized = await _latinRecognizer.processImage(inputImage);

    final blocks = <OCRBlock>[];
    for (final block in recognized.blocks) {
      blocks.add(OCRBlock(
        text: block.text,
        lines: block.lines.map((l) => OCRLine(
          text: l.text,
          confidence: l.confidence ?? 0.0,
        )).toList(),
      ));
    }

    return OCRResult(fullText: recognized.text, blocks: blocks);
  }

  void dispose() {
    _latinRecognizer.close();
  }
}

class OCRResult {
  final String fullText;
  final List<OCRBlock> blocks;
  OCRResult({required this.fullText, required this.blocks});
}

class OCRBlock {
  final String text;
  final List<OCRLine> lines;
  OCRBlock({required this.text, required this.lines});
}

class OCRLine {
  final String text;
  final double confidence;
  OCRLine({required this.text, required this.confidence});
}
