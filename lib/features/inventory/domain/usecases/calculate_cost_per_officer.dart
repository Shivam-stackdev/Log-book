import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/officer_repository.dart';

class CalculateCostPerOfficer extends UseCase<double, CostParams> {
  final OfficerRepository repository;

  CalculateCostPerOfficer(this.repository);

  @override
  Future<Either<Failure, double>> call(CostParams params) async {
    final totalCostResult = await repository.getTotalPartyCost(params.startDate, params.endDate);
    final officersResult = await repository.getOfficers();

    return totalCostResult.fold(
      (failure) => Left(failure),
      (totalCost) {
        return officersResult.fold(
          (failure) => Left(failure),
          (officers) {
            if (officers.isEmpty) return const Right(0.0);
            return Right(totalCost / officers.length);
          },
        );
      },
    );
  }
}

class CostParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const CostParams({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
