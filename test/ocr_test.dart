import 'package:flutter_test/flutter_test.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';

void main() {
  group('BillItem', () {
    test('copyWith should return a new object with updated values', () {
      const item = BillItem(
        name: 'Sugar',
        quantity: 10,
        unit: 'kg',
        rate: 40,
        amount: 400,
      );

      final updatedItem = item.copyWith(quantity: 15, amount: 600);

      expect(updatedItem.quantity, 15);
      expect(updatedItem.amount, 600);
      expect(updatedItem.name, 'Sugar');
    });
  });
}
