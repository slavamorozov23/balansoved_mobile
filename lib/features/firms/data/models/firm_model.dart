import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';

class FirmModel extends FirmEntity {
  const FirmModel({
    required super.id,
    required super.name,
    required super.ownerUserId,
    required super.roles,
  });

  factory FirmModel.fromJson(Map<String, dynamic> json) {
    return FirmModel(
      id: json['firm_id'] ?? '',
      name: json['firm_name'] ?? '',
      ownerUserId: json['owner_user_id'] ?? '',
      roles: List<String>.from(json['user_roles'] ?? const []),
    );
  }

  FirmEntity toEntity() => FirmEntity(
    id: id,
    name: name,
    ownerUserId: ownerUserId,
    roles: roles,
  );
}
