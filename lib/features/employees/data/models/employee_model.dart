import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    super.email,
    super.userName,
    required super.roles,
    super.isActive = true,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['user_id'] ?? json['id'] ?? '',
      email: json['email'],
      userName: json['user_name'] ?? json['name'] ?? json['full_name'],
      roles: List<String>.from(json['roles'] ?? const []),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'email': email,
    'user_name': userName,
    'roles': roles,
    'is_active': isActive,
  };

  EmployeeEntity toEntity() => EmployeeEntity(
    id: id,
    email: email,
    userName: userName,
    roles: roles,
    isActive: isActive,
  );
}
