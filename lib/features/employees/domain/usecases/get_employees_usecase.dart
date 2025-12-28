import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/repositories/employees_repository.dart';

class GetEmployeesUseCase {
  final EmployeesRepository repository;

  const GetEmployeesUseCase(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> call(String firmId) {
    return repository.getEmployees(firmId);
  }
}
