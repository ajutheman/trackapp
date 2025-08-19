// lib/features/notification/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:truck_app/core/theme/app_colors.dart'; // Ensure this path is correct

// A simple model for a user notification
class UserNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead; // Can be changed to mark as read

  UserNotification({required this.id, required this.title, required this.description, required this.timestamp, this.isRead = false});

  // Helper method to create a copy with updated read status
  UserNotification copyWith({bool? isRead}) {
    return UserNotification(id: id, title: title, description: description, timestamp: timestamp, isRead: isRead ?? this.isRead);
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy data for notifications
  // In a real application, this would come from a backend or state management
  final List<UserNotification> _notifications = [
    UserNotification(
      id: '1',
      title: 'New Connect Request from John Doe',
      description: 'John Doe has sent you a new connect request for a load from Malappuram to Kochi. Check it out now!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    UserNotification(
      id: '2',
      title: 'Your post "Need truck for furniture" is live!',
      description: 'Your post for furniture transport is now visible to drivers. Expect connects soon.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    UserNotification(
      id: '3',
      title: 'Connect with Mary Jane accepted',
      description: 'Great news! Your connect request with Mary Jane for the fragile goods has been accepted.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    UserNotification(
      id: '4',
      title: 'App Update Available',
      description: 'A new version of the app is available with performance improvements and bug fixes. Update now!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    UserNotification(
      id: '5',
      title: 'Profile Verification Complete',
      description: 'Your driver profile has been successfully verified. You can now accept loads!',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    ),
  ];

  void _markNotificationAsRead(UserNotification notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        foregroundColor: Colors.black,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead)) // Show button only if there are unread notifications
            TextButton(onPressed: _markAllAsRead, child: Text('Mark All as Read', style: TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600))),
        ],
      ),
      body:
          _notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No new notifications.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return GestureDetector(
                    onTap: () {
                      _markNotificationAsRead(notification);
                      // In a real app, you might navigate to a detail screen or related content
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on: ${notification.title}')));
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      color: notification.isRead ? AppColors.surface : Color(0xFFE2E8F0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: notification.isRead ? BorderSide.none : BorderSide(color: AppColors.secondary, width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(fontSize: 18, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(notification.description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(_formatTimestamp(notification.timestamp), style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
