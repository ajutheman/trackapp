import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connect.dart';

class RecentConnectCard extends StatelessWidget {
  final Connect connect;

  const RecentConnectCard({super.key, required this.connect});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(connect.status);
    final statusText = _getStatusText(connect.status);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, AppColors.surface.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar and Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.08), AppColors.secondary.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary.withOpacity(0.3), AppColors.secondary.withOpacity(0.15)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(child: Text(_getInitials(connect.replyUserName), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary))),
                  ),
                  const Spacer(),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(statusText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name
                  Text(
                    connect.replyUserName,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Post Title
                  Text(connect.postTitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),

                  // Date & Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatDateTime(connect.dateTime),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  Color _getStatusColor(ConnectStatus status) {
    switch (status) {
      case ConnectStatus.accepted:
        return Colors.green.shade600;
      case ConnectStatus.pending:
        return Colors.orange.shade600;
      case ConnectStatus.rejected:
        return Colors.red.shade600;
      case ConnectStatus.hold:
        return Colors.amber.shade700;
      case ConnectStatus.completed:
        return Colors.blue.shade600;
    }
  }

  String _getStatusText(ConnectStatus status) {
    switch (status) {
      case ConnectStatus.accepted:
        return 'Active';
      case ConnectStatus.pending:
        return 'Pending';
      case ConnectStatus.rejected:
        return 'Rejected';
      case ConnectStatus.hold:
        return 'On Hold';
      case ConnectStatus.completed:
        return 'Done';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
