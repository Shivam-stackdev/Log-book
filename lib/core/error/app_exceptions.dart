/// Base application exception
class AppException implements Exception {
  final String code;
  final String message;
  final String? details;

  const AppException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'AppException[$code]: $message${details != null ? ' - $details' : ''}';
}

class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.details})
      : super(code: 'DB_ERROR');
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.details})
      : super(code: 'VALIDATION_ERROR');
}

class StockException extends AppException {
  const StockException({required super.message, super.details})
      : super(code: 'STOCK_ERROR');
}

class DeductionException extends AppException {
  const DeductionException({required super.message, super.details})
      : super(code: 'DEDUCTION_ERROR');
}

class DuplicateException extends AppException {
  const DuplicateException({required super.message, super.details})
      : super(code: 'DUPLICATE_ERROR');
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.details})
      : super(code: 'NETWORK_ERROR');
}

class PermissionException extends AppException {
  const PermissionException({required super.message, super.details})
      : super(code: 'PERMISSION_ERROR');
}
