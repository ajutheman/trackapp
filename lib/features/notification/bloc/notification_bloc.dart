import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../data/models/notification_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository})
    : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await repository.getNotifications(
      page: event.page,
      limit: event.limit,
    );

    if (result.isSuccess) {
      final data = result.data!;
      final List<dynamic> notificationsList = data['notifications'] ?? [];
      final notifications =
          notificationsList.map((e) => NotificationModel.fromJson(e)).toList();

      final pagination = data['pagination'] ?? {};
      final unreadCount = notifications.where((n) => !n.read).length;

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['totalPages'] ?? 1,
          hasMore: (pagination['page'] ?? 1) < (pagination['totalPages'] ?? 1),
        ),
      );
    } else {
      emit(NotificationError(result.message ?? 'Failed to load notifications'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;

    final result = await repository.getNotifications(page: 1, limit: 20);

    if (result.isSuccess) {
      final data = result.data!;
      final List<dynamic> notificationsList = data['notifications'] ?? [];
      final notifications =
          notificationsList.map((e) => NotificationModel.fromJson(e)).toList();

      final pagination = data['pagination'] ?? {};
      final unreadCount = notifications.where((n) => !n.read).length;

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['totalPages'] ?? 1,
          hasMore: (pagination['page'] ?? 1) < (pagination['totalPages'] ?? 1),
        ),
      );
    } else {
      // Keep current state if refresh fails
      if (currentState is NotificationLoaded) {
        emit(currentState);
      } else {
        emit(
          NotificationError(
            result.message ?? 'Failed to refresh notifications',
          ),
        );
      }
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Optimistic update
      final updatedNotifications =
          currentState.notifications.map((n) {
            if (n.id == event.notificationId) {
              return n.copyWith(read: true);
            }
            return n;
          }).toList();

      final newUnreadCount = updatedNotifications.where((n) => !n.read).length;

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ),
      );

      // Make API call
      final result = await repository.markAsRead(event.notificationId);

      if (!result.isSuccess) {
        // Revert on failure
        emit(currentState);
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Optimistic update
      final updatedNotifications =
          currentState.notifications.map((n) {
            return n.copyWith(read: true);
          }).toList();

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ),
      );

      // Make API call
      final result = await repository.markAllAsRead();

      if (!result.isSuccess) {
        // Revert on failure
        emit(currentState);
      }
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Add new notification to the top
      final updatedNotifications = [
        event.notification,
        ...currentState.notifications,
      ];
      final newUnreadCount = updatedNotifications.where((n) => !n.read).length;

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ),
      );
    }
  }
}
