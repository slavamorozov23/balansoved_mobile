import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';

abstract class EmployeesRepository {
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees(String firmId);
}
