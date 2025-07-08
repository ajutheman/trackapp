import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = '${post.date.day}/${post.date.month}/${post.date.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Image (if available)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl!,
                height: 150, // Fixed height for consistency
                width: double.infinity, // Take full width
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.border,
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 48),
                    ),
                  );
                },
              ),
            ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(post.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text(formattedDate, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Align(alignment: Alignment.bottomRight, child: Text('Read More', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}