import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shimmer_effect.dart';

/// Skeleton loader for Post/Trip cards
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              ShimmerContainer(width: 80, height: 24, borderRadius: 12),
              const Spacer(),
              ShimmerContainer(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          // Route skeleton
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 40, height: 12, borderRadius: 6),
                    const SizedBox(height: 8),
                    ShimmerContainer(width: double.infinity, height: 40, borderRadius: 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ShimmerContainer(width: 24, height: 24, borderRadius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 40, height: 12, borderRadius: 6),
                    const SizedBox(height: 8),
                    ShimmerContainer(width: double.infinity, height: 40, borderRadius: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title skeleton
          ShimmerContainer(width: double.infinity, height: 20, borderRadius: 8),
          const SizedBox(height: 8),
          ShimmerContainer(width: double.infinity * 0.7, height: 20, borderRadius: 8),
          const SizedBox(height: 16),
          // Info row skeleton
          Row(
            children: [
              ShimmerContainer(width: 80, height: 32, borderRadius: 8),
              const SizedBox(width: 10),
              ShimmerContainer(width: 80, height: 32, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          // Button skeleton
          ShimmerContainer(width: double.infinity, height: 48, borderRadius: 14),
        ],
      ),
    );
  }
}

/// Skeleton loader for list views
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;

  const ListSkeleton({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => itemBuilder(),
      ),
    );
  }
}

/// Skeleton loader for form screens
class FormSkeleton extends StatelessWidget {
  final int fieldCount;

  const FormSkeleton({super.key, this.fieldCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        fieldCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerContainer(width: 100, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerContainer(
                width: double.infinity,
                height: 56,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for profile screens
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar skeleton
        ShimmerContainer(width: 100, height: 100, borderRadius: 50),
        const SizedBox(height: 20),
        // Name skeleton
        ShimmerContainer(width: 200, height: 24, borderRadius: 8),
        const SizedBox(height: 8),
        // Email skeleton
        ShimmerContainer(width: 150, height: 16, borderRadius: 8),
        const SizedBox(height: 32),
        // Info cards skeleton
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerContainer(
              width: double.infinity,
              height: 80,
              borderRadius: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton loader for transaction cards
class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ShimmerContainer(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(width: double.infinity * 0.6, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                ShimmerContainer(width: double.infinity * 0.4, height: 12, borderRadius: 4),
              ],
            ),
          ),
          ShimmerContainer(width: 60, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton loader for token plan cards
class TokenPlanCardSkeleton extends StatelessWidget {
  const TokenPlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerContainer(width: 120, height: 20, borderRadius: 4),
              ShimmerContainer(width: 80, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerContainer(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          ShimmerContainer(width: double.infinity * 0.7, height: 16, borderRadius: 4),
          const SizedBox(height: 20),
          ShimmerContainer(width: double.infinity, height: 48, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Skeleton loader for review cards
class ReviewCardSkeleton extends StatelessWidget {
  const ReviewCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerContainer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 120, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerContainer(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              ShimmerContainer(width: 100, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerContainer(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          ShimmerContainer(width: double.infinity * 0.8, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

