import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/core/logging/employees_logger.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/employees/data/data_source/employees_remote_data_source.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/repositories/employees_repository.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  final EmployeesRemoteDataSource remote;
  final IAuthLocalDataSource authLocal;

  EmployeesRepositoryImpl({required this.remote, required this.authLocal});

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees(
    String firmId,
  ) async {
    try {
      sl<Talker>().logCustom(
        EmployeesLog('EMP REPO: Fetch employees for firmId=$firmId'),
      );
      final token = await authLocal.getAccessToken();
      if (token == null) {
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }
      final employees = await remote.fetchEmployees(token, firmId);
      sl<Talker>().logCustom(
        EmployeesLog('EMP REPO: Received ${employees.length} employees'),
      );
      return Right(employees);
    } catch (e, stackTrace) {
      sl<Talker>().logCustom(
        EmployeesErrorLog('EmployeesRepositoryImpl: Exception', e, stackTrace),
      );
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      }
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      }
      return Left(
        UnexpectedFailure(message: e.toString(), details: stackTrace.toString()),
      );
    }
  }
}
