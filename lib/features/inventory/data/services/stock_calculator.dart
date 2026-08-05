import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

/// Centralized stock calculation logic
class StockCalculator {
  /// Calculate opening stock from stock entries and deductions
  /// opening_stock = total_purchases - total_deductions
  static double calculateOpeningStock({
    required List<double> purchaseQuantities,
    required List<double> deductionQuantities,
  }) {
    final totalPurchased = purchaseQuantities.fold(0.0, (sum, qty) => sum + qty);
    final totalDeducted = deductionQuantities.fold(0.0, (sum, qty) => sum + qty);
    final opening = totalPurchased - totalDeducted;
    if (opening < 0) {
      AppLogger.w('StockCalculator', 'Negative opening stock detected: $opening');
    }
    return opening > 0 ? opening : 0;
  }

  /// Calculate remaining stock after deduction
  static double calculateRemaining(double currentStock, double deductionQty) {
    final remaining = currentStock - deductionQty;
    if (remaining < 0) {
      throw const StockException(
        message: 'Cannot deduct more than available stock',
        details: 'Available: $currentStock, Requested: $deductionQty',
      );
    }
    return remaining;
  }

  /// Get stock status label
  static String getStockStatus(ItemEntity item) {
    if (item.currentStock == 0) return 'Out of Stock';
    if (item.currentStock <= item.reorderLevel * 0.5) return 'Critical';
    if (item.currentStock <= item.reorderLevel) return 'Low';
    if (item.currentStock <= item.reorderLevel * 2) return 'Moderate';
    return 'Adequate';
  }

  /// Calculate total value of stock
  static double calculateStockValue(List<ItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + (item.currentStock * item.rate));
  }

  /// Calculate monthly consumption rate
  static double calculateMonthlyConsumption(List<double> dailyDeductions) {
    if (dailyDeductions.isEmpty) return 0;
    return dailyDeductions.fold(0.0, (sum, qty) => sum + qty) / dailyDeductions.length * 30;
  }

  /// Calculate suggested purchase quantity
  static double calculateSuggestedPurchase(ItemEntity item) {
    if (item.currentStock >= item.reorderLevel * 2) return 0;
    final deficit = item.reorderLevel - item.currentStock;
    return (deficit + item.reorderLevel).roundToDouble();
  }
}
