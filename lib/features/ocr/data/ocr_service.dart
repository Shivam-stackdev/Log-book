import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';

class OcrService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<BillItem>> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    List<BillItem> items = [];
    
    // Group all lines by their vertical center to identify rows
    final List<TextLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return [];

    // Sort lines by their top position
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // Group lines into rows based on vertical overlap
    final List<List<TextLine>> rows = [];
    if (allLines.isNotEmpty) {
      List<TextLine> currentRow = [allLines[0]];
      rows.add(currentRow);

      for (int i = 1; i < allLines.length; i++) {
        final line = allLines[i];
        final prevLine = currentRow.last;
        
        // If the current line's top is within the vertical range of the previous line, group them
        final verticalOverlap = (line.boundingBox.top - prevLine.boundingBox.top).abs() < 15; // threshold
        
        if (verticalOverlap) {
          currentRow.add(line);
        } else {
          currentRow = [line];
          rows.add(currentRow);
        }
      }
    }

    // Process each row to extract Item, Qty, Rate, Amount
    for (var row in rows) {
      // Sort lines in row by horizontal position
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      final rowText = row.map((l) => l.text).join(' ');
      
      // Try to find numeric values at the end of the row
      final numbers = <double>[];
      final nameParts = <String>[];
      
      for (var line in row) {
        final text = line.text.replaceAll('₹', '').replaceAll(',', '').trim();
        final val = double.tryParse(text);
        if (val != null) {
          numbers.add(val);
        } else {
          // If it's not a number, it might be part of the name
          // Skip serial numbers (e.g., "1.", "2.")
          if (!RegExp(r'^\d+\.?$').hasMatch(text)) {
            nameParts.add(text);
          }
        }
      }

      // Typically: [Qty, Rate, Amount] or [S.No, Qty, Rate, Amount]
      if (numbers.length >= 2) {
        double qty = 0;
        double rate = 0;
        double amount = 0;
        
        if (numbers.length == 2) {
          // Maybe just Rate and Amount
          rate = numbers[0];
          amount = numbers[1];
          qty = amount / (rate > 0 ? rate : 1);
        } else if (numbers.length >= 3) {
          // Likely Qty, Rate, Amount (ignoring S.No if it was parsed as number)
          // If the first number is small and sequential, it might be S.No
          int startIndex = (numbers[0] < 50 && numbers.length > 3) ? 1 : 0;
          
          if (numbers.length - startIndex >= 3) {
            qty = numbers[startIndex];
            rate = numbers[startIndex + 1];
            amount = numbers[startIndex + 2];
          } else {
            qty = numbers[startIndex];
            rate = numbers[startIndex + 1];
            amount = qty * rate;
          }
        }

        final name = nameParts.join(' ').trim();
        if (name.isNotEmpty && name.toLowerCase() != 'item' && name.toLowerCase() != 'name') {
          items.add(BillItem(
            name: name,
            quantity: qty,
            unit: "unit",
            rate: rate,
            amount: amount,
          ));
        }
      }
    }

    return items;
  }

  void dispose() {
    textRecognizer.close();
  }
}
