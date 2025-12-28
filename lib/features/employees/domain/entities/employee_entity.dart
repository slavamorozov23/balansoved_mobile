import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String id;
  final String? email;
  final String? userName;
  final List<String> roles;
  final bool isActive;

  const EmployeeEntity({
    required this.id,
    this.email,
    this.userName,
    required this.roles,
    this.isActive = true,
  });

  bool get isAdmin => roles.contains('ADMIN');
  bool get isOwner => roles.contains('OWNER');

  @override
  List<Object?> get props => [id, email, userName, roles, isActive];
}
