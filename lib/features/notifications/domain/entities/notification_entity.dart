import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String? title;
  final String? body;
  final String? icon;
  final DateTime createdAt;
  final bool isDelivered;
  final bool isArchived;
  final Map<String, dynamic>? additionalInfo;

  const NotificationEntity({
    required this.id,
    this.title,
    this.body,
    this.icon,
    required this.createdAt,
    required this.isDelivered,
    required this.isArchived,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        icon,
        createdAt,
        isDelivered,
        isArchived,
        additionalInfo,
      ];
}
