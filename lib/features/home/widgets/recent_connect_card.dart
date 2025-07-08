import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connect.dart';

class RecentConnectCard extends StatelessWidget {
  final Connect connect;

  const RecentConnectCard({super.key, required this.connect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      // Fixed width for horizontal scroll
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(connect.replyUserName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(connect.postTitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text('${connect.dateTime.day}/${connect.dateTime.month} ${connect.dateTime.hour}:${connect.dateTime.minute}', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
