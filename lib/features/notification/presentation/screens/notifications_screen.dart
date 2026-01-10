import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/notification_bloc.dart';
import '../../bloc/notification_event.dart';
import '../../bloc/notification_state.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              NotificationBloc(repository: context.read())
                ..add(const LoadNotifications()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoaded && state.unreadCount > 0) {
              return Row(
                children: [
                  const Text('Notifications'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Text('Notifications');
          },
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      const MarkAllNotificationsAsRead(),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        const LoadNotifications(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(
                  const RefreshNotifications(),
                );
              },
              child: ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationTile(notification: notification);
                },
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.read ? Colors.grey : Colors.blue,
        child: Icon(_getIconForType(notification.type), color: Colors.white),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, h:mm a').format(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        if (!notification.read) {
          context.read<NotificationBloc>().add(
            MarkNotificationAsRead(notification.id),
          );
        }
        _handleNotificationNavigation(context, notification);
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'TRIP':
        return Icons.local_shipping;
      case 'ORDER':
        return Icons.shopping_bag;
      case 'PROMOTION':
        return Icons.local_offer;
      case 'ACCOUNT':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationNavigation(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Handle navigation based on notification type and data
    final data = notification.data;

    switch (notification.type) {
      case 'TRIP':
        // Navigate to trip details if tripId exists
        if (data.containsKey('tripId')) {
          // TODO: Navigate to trip details screen
          debugPrint('Navigate to trip: ${data['tripId']}');
        }
        break;
      case 'ORDER':
        // Navigate to order/booking details
        if (data.containsKey('bookingId')) {
          // TODO: Navigate to booking details screen
          debugPrint('Navigate to booking: ${data['bookingId']}');
        }
        break;
      case 'ACCOUNT':
        // Navigate to profile or account settings
        // TODO: Navigate to profile screen
        debugPrint('Navigate to account');
        break;
      default:
        // No specific navigation
        break;
    }
  }
}
