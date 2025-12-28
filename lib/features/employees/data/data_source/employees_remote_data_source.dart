import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';

abstract class EmployeesRemoteDataSource {
  Future<List<EmployeeEntity>> fetchEmployees(String token, String firmId);
}
