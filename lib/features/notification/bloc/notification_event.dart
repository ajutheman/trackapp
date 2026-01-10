import 'package:equatable/equatable.dart';
import '../data/models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int page;
  final int limit;

  const LoadNotifications({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class NotificationReceived extends NotificationEvent {
  final NotificationModel notification;

  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
