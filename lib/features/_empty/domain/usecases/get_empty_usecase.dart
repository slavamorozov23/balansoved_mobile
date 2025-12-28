import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/_empty/domain/entities/empty_entity.dart';
import 'package:balansoved_mobile/features/_empty/domain/repositories/empty_repository.dart';

class GetEmptyUsecase {
  final EmptyRepository repository;

  const GetEmptyUsecase(this.repository);

  Future<Either<Failure, EmptyEntity>> call() {
    return repository.getEmpty();
  }
}

