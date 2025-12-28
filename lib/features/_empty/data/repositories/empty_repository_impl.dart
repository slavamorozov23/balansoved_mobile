import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/_empty/data/data_source/empty_remote_data_source.dart';
import 'package:balansoved_mobile/features/_empty/domain/entities/empty_entity.dart';
import 'package:balansoved_mobile/features/_empty/domain/repositories/empty_repository.dart';

class EmptyRepositoryImpl implements EmptyRepository {
  final EmptyRemoteDataSource remoteDataSource;

  const EmptyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EmptyEntity>> getEmpty() async {
    try {
      final model = await remoteDataSource.fetchEmpty();
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString(), message: 'Load failed'));
    }
  }
}

