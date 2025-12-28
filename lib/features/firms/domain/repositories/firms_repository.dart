import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';

abstract class FirmsRepository {
  Future<Either<Failure, List<FirmEntity>>> getFirms();
}
