import 'package:equatable/equatable.dart';

class RustoreSubscriptionEntity extends Equatable {
  final String? userId;
  final String pushToken;
  final bool isRegistered;

  const RustoreSubscriptionEntity({
    required this.pushToken,
    required this.isRegistered,
    this.userId,
  });

  RustoreSubscriptionEntity copyWith({
    String? userId,
    String? pushToken,
    bool? isRegistered,
  }) {
    return RustoreSubscriptionEntity(
      userId: userId ?? this.userId,
      pushToken: pushToken ?? this.pushToken,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  List<Object?> get props => [userId, pushToken, isRegistered];
}
