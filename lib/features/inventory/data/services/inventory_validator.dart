import 'package:army_mess_inventory/core/error/app_exceptions.dart';

/// Centralized inventory validation logic
class InventoryValidator {
  /// Validate item name is not empty
  static String validateName(String name) {
    if (name.trim().isEmpty) {
      throw const ValidationException(message: 'Item name cannot be empty');
    }
    if (name.trim().length < 2) {
      throw const ValidationException(message: 'Item name must be at least 2 characters');
    }
    return name.trim();
  }

  /// Validate quantity is positive
  static double validateQuantity(double quantity, String label) {
    if (quantity <= 0) {
      throw ValidationException(message: '$label must be greater than 0');
    }
    return quantity;
  }

  /// Validate sufficient stock before deduction
  static void validateSufficientStock(double currentStock, double deductionQty, String itemName) {
    if (deductionQty > currentStock) {
      throw StockException(
        message: 'Insufficient stock',
        details: '$itemName: available ${currentStock}, requested $deductionQty',
      );
    }
    if (currentStock - deductionQty < 0) {
      throw const StockException(
        message: 'Cannot create negative stock',
        details: 'Stock must remain >= 0',
      );
    }
  }

  /// Validate reorder level is non-negative
  static double validateReorderLevel(double level) {
    if (level < 0) {
      throw const ValidationException(message: 'Reorder level cannot be negative');
    }
    return level;
  }

  /// Validate unit is not empty
  static String validateUnit(String unit) {
    if (unit.trim().isEmpty) {
      throw const ValidationException(message: 'Unit cannot be empty');
    }
    return unit.trim();
  }

  /// Validate category is not empty
  static String validateCategory(String category) {
    if (category.trim().isEmpty) {
      throw const ValidationException(message: 'Category cannot be empty');
    }
    return category.trim();
  }

  /// Validate rate is non-negative
  static double validateRate(double rate) {
    if (rate < 0) {
      throw const ValidationException(message: 'Rate cannot be negative');
    }
    return rate;
  }
}
