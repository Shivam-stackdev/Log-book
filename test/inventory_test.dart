import 'package:flutter_test/flutter_test.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

void main() {
  group('ItemEntity', () {
    test('should support value equality', () {
      const item1 = ItemEntity(
        id: '1',
        name: 'Rice',
        unit: 'kg',
        currentStock: 100,
        reorderLevel: 20,
        category: 'Grains',
      );
      const item2 = ItemEntity(
        id: '1',
        name: 'Rice',
        unit: 'kg',
        currentStock: 100,
        reorderLevel: 20,
        category: 'Grains',
      );

      expect(item1, equals(item2));
    });
  });
}
