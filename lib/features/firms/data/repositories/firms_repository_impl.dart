import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/firms/data/data_source/firms_remote_data_source.dart';
import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';
import 'package:balansoved_mobile/features/firms/domain/repositories/firms_repository.dart';
import 'package:dartz/dartz.dart';

class FirmsRepositoryImpl implements FirmsRepository {
  final FirmsRemoteDataSource remote;
  final IAuthLocalDataSource authLocal;

  FirmsRepositoryImpl({required this.remote, required this.authLocal});

  @override
  Future<Either<Failure, List<FirmEntity>>> getFirms() async {
    try {
      final token = await authLocal.getAccessToken();
      if (token == null || token.isEmpty) {
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }
      final firms = await remote.fetchFirms(token: token);
      return Right(firms.map((f) => f.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      return Left(
        UnexpectedFailure(message: e.toString(), details: stackTrace.toString()),
      );
    }
  }
}
