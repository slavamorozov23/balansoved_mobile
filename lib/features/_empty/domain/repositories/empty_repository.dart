import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/_empty/domain/entities/empty_entity.dart';

abstract class EmptyRepository {
  Future<Either<Failure, EmptyEntity>> getEmpty();
}

