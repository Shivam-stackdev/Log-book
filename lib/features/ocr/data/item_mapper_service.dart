import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

class ItemMapperService {
  /// Intelligently suggests an existing item ID for a given OCR name.
  /// Uses basic string similarity for now.
  String? suggestMapping(String ocrName, List<ItemEntity> existingItems) {
    if (ocrName.isEmpty) return null;

    final normalizedOcr = ocrName.toLowerCase().trim();
    
    ItemEntity? bestMatch;
    double highestSimilarity = 0.0;

    for (final item in existingItems) {
      final normalizedItem = item.name.toLowerCase().trim();
      
      // Exact match
      if (normalizedItem == normalizedOcr) return item.id;

      // Simple similarity check (substring or common words)
      final similarity = _calculateSimilarity(normalizedOcr, normalizedItem);
      if (similarity > highestSimilarity && similarity > 0.6) {
        highestSimilarity = similarity;
        bestMatch = item;
      }
    }

    return bestMatch?.id;
  }

  double _calculateSimilarity(String s1, String s2) {
    // Basic Jaccard similarity for words
    final set1 = s1.split(' ').toSet();
    final set2 = s2.split(' ').toSet();
    
    if (set1.isEmpty || set2.isEmpty) return 0.0;
    
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;
    
    return intersection / union;
  }
}
