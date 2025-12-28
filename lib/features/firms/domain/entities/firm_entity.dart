import 'package:equatable/equatable.dart';

class FirmEntity extends Equatable {
  final String id;
  final String name;
  final String ownerUserId;
  final List<String> roles;

  const FirmEntity({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.roles,
  });

  bool get isOwner => roles.contains('OWNER');
  bool get isAdmin => roles.contains('ADMIN');

  @override
  List<Object?> get props => [id, name, ownerUserId, roles];
}
