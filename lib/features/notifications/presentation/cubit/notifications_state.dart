part of 'notifications_cubit.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoadingMore extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int undeliveredCount;

  const NotificationsLoadingMore(this.notifications, this.undeliveredCount);

  @override
  List<Object?> get props => [notifications, undeliveredCount];
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int undeliveredCount;

  const NotificationsLoaded(this.notifications, this.undeliveredCount);

  @override
  List<Object?> get props => [notifications, undeliveredCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
