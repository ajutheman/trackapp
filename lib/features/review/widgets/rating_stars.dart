import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRating;
  final bool editable;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.showRating = false,
    this.editable = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.secondary;
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (editable)
          ...List.generate(5, (index) {
            return GestureDetector(
              onTap: onRatingChanged != null
                  ? () => onRatingChanged!(index + 1)
                  : null,
              child: Icon(
                index < fullStars
                    ? Icons.star_rounded
                    : (index == fullStars && hasHalfStar)
                        ? Icons.star_half_rounded
                        : Icons.star_border_rounded,
                size: size,
                color: effectiveColor,
              ),
            );
          })
        else
          ...List.generate(5, (index) {
            return Icon(
              index < fullStars
                  ? Icons.star_rounded
                  : (index == fullStars && hasHalfStar)
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded,
              size: size,
              color: effectiveColor,
            );
          }),
        if (showRating) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

