import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';
import 'package:balansoved_mobile/features/firms/domain/repositories/firms_repository.dart';

class GetFirmsUseCase {
  final FirmsRepository repository;

  GetFirmsUseCase(this.repository);

  Future<Either<Failure, List<FirmEntity>>> call() {
    return repository.getFirms();
  }
}
