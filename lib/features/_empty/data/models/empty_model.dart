import 'package:balansoved_mobile/features/_empty/domain/entities/empty_entity.dart';

class EmptyModel extends EmptyEntity {
  const EmptyModel({required super.id});

  EmptyEntity toEntity() => EmptyEntity(id: id);

  factory EmptyModel.fromEntity(EmptyEntity entity) {
    return EmptyModel(id: entity.id);
  }

  factory EmptyModel.fromJson(Map<String, dynamic> json) {
    return EmptyModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

