import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';

class OcrService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<BillItem>> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    List<BillItem> items = [];
    
    // Simple heuristic parsing logic for bill items
    // In a real production app, this would use regex or a small LLM for better accuracy
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text;
        // Basic pattern: "Item Name 10 kg 50 500"
        final parts = text.split(' ');
        if (parts.length >= 3) {
          final qty = double.tryParse(parts[parts.length - 3]) ?? 0;
          final rate = double.tryParse(parts[parts.length - 2]) ?? 0;
          final amount = double.tryParse(parts[parts.length - 1]) ?? 0;
          
          if (qty > 0 && amount > 0) {
            final name = parts.sublist(0, parts.length - 3).join(' ');
            items.add(BillItem(
              name: name.isEmpty ? "Unknown Item" : name,
              quantity: qty,
              unit: "unit",
              rate: rate,
              amount: amount,
            ));
          }
        }
      }
    }

    return items;
  }

  void dispose() {
    textRecognizer.close();
  }
}
