import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';

/// Base use case interface
abstract class UseCase<Type, Params> {
  Future<Either<AppException, Type>> call(Params params);
}

/// No parameters needed
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
