import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:balansoved_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:balansoved_mobile/features/notifications/domain/usecases/mark_as_delivered_usecase.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotifications;
  final MarkAsDeliveredUseCase markAsDelivered;
  final AuthCubit authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  NotificationsCubit({
    required this.getNotifications,
    required this.markAsDelivered,
    required this.authCubit,
  }) : super(NotificationsInitial()) {
    _listenToAuthChanges();
  }

  List<NotificationEntity> _allNotifications = [];
  int _currentPage = 0;
  bool _hasMoreNotifications = true;
  int _undeliveredCount = 0;

  int get undeliveredCount => _undeliveredCount;
  List<NotificationEntity> get notifications => _allNotifications;
  bool get hasMoreNotifications => _hasMoreNotifications;

  void _listenToAuthChanges() {
    if (authCubit.state is AuthAuthenticated &&
        state is NotificationsInitial) {
      loadNotifications();
    }

    _authSubscription = authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        loadNotifications(refresh: true);
      }
      if (authState is AuthUnauthenticated) {
        _resetState();
        emit(NotificationsInitial());
      }
    });
  }

  void _resetState() {
    _allNotifications = [];
    _currentPage = 0;
    _hasMoreNotifications = true;
    _undeliveredCount = 0;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _resetState();
    }

    if (!_hasMoreNotifications && !refresh) {
      return;
    }

    if (_currentPage == 0) {
      emit(NotificationsLoading());
    } else {
      emit(NotificationsLoadingMore(_allNotifications, _undeliveredCount));
    }

    final result = await getNotifications(
      page: _currentPage,
      getArchived: false,
    );

    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) {
        if (notifications.length < 100) {
          _hasMoreNotifications = false;
        }

        _allNotifications.addAll(notifications);
        _currentPage++;

        if (_currentPage == 1) {
          _undeliveredCount =
              notifications.where((n) => !n.isDelivered).length;
        }

        emit(NotificationsLoaded(_allNotifications, _undeliveredCount));
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (_hasMoreNotifications && state is! NotificationsLoadingMore) {
      await loadNotifications();
    }
  }

  Future<void> markNotificationsAsDelivered(List<String> noticeIds) async {
    final result = await markAsDelivered(noticeIds);
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (_) {
        _allNotifications =
            _allNotifications.map((notification) {
              if (noticeIds.contains(notification.id)) {
                return NotificationEntity(
                  id: notification.id,
                  title: notification.title,
                  body: notification.body,
                  icon: notification.icon,
                  createdAt: notification.createdAt,
                  isDelivered: true,
                  isArchived: notification.isArchived,
                  additionalInfo: notification.additionalInfo,
                );
              }
              return notification;
            }).toList();

        _undeliveredCount =
            _allNotifications.where((n) => !n.isDelivered).length;

        emit(NotificationsLoaded(_allNotifications, _undeliveredCount));
      },
    );
  }

  Future<void> markAllUndeliveredAsDelivered() async {
    final undeliveredIds =
        _allNotifications
            .where((notification) => !notification.isDelivered)
            .map((notification) => notification.id)
            .toList();
    if (undeliveredIds.isNotEmpty) {
      await markNotificationsAsDelivered(undeliveredIds);
    }
  }
}
