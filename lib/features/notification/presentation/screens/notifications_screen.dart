import 'package:flutter/material.dart';

import 'package:truck_app/features/notification/repo/notification_repository.dart';
import 'package:truck_app/di/locator.dart';
import '../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository =
      locator<NotificationRepository>(); // Assuming registered in locator
  // Or if not in locator, standard way:
  // final NotificationRepository _repository = NotificationRepository(apiService: locator<ApiService>());

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getNotifications();

    if (result.isSuccess) {
      final List<dynamic> list = result.data?['notifications'] ?? [];
      setState(() {
        _notifications =
            list.map((e) => NotificationModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.read) return;

    // Optimistic update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        // Create copy with read=true
        // Since model is final, we'd need copyWith or manual reconstruction.
        // For now, simpler: re-fetch or ignore UI update if not critical,
        // but let's try to update locally.
      }
    });

    await _repository.markAsRead(notification.id);
    _fetchNotifications(); // Refresh to be sure
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await _repository.markAllAsRead();
              _fetchNotifications();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : RefreshIndicator(
                onRefresh: _fetchNotifications,
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            notification.read ? Colors.grey : Colors.blue,
                        child: Icon(
                          _getIconForType(notification.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                              notification.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.body),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM d, h:mm a',
                            ).format(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () {
                        _markAsRead(notification);
                        // Handle navigation if needed based on notification.data
                      },
                    );
                  },
                ),
              ),
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
}
