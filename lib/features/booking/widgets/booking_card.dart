// lib/features/booking/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import '../model/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  Color _getStatusColor() {
    switch (booking.status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
      case BookingStatus.expired:
        return Colors.grey;
      case BookingStatus.pickedUp:
        return Colors.blue;
      case BookingStatus.delivered:
        return Colors.purple;
      case BookingStatus.completed:
        return AppColors.success;
    }
  }

  String _getStatusText() {
    switch (booking.status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
      case BookingStatus.pickedUp:
        return 'Picked Up';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case BookingStatus.pending:
        return Icons.hourglass_empty_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.rejected:
        return Icons.cancel_rounded;
      case BookingStatus.cancelled:
        return Icons.block_rounded;
      case BookingStatus.expired:
        return Icons.access_time_rounded;
      case BookingStatus.pickedUp:
        return Icons.local_shipping_rounded;
      case BookingStatus.delivered:
        return Icons.done_all_rounded;
      case BookingStatus.completed:
        return Icons.celebration_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? formattedDateTime = booking.createdAt != null
        ? '${DateFormat('dd MMM yyyy').format(booking.createdAt!)} • ${DateFormat('HH:mm').format(booking.createdAt!)}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.trip?.title ?? booking.customerRequest?.title ?? 'Booking',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (formattedDateTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          formattedDateTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(), size: 14, color: _getStatusColor()),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User info
            if (booking.driver != null || booking.customer != null) ...[
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.8),
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (booking.driver?.name.isNotEmpty == true
                                ? booking.driver!.name[0]
                                : booking.customer?.name.isNotEmpty == true
                                    ? booking.customer!.name[0]
                                    : '?')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.driver != null
                              ? 'Driver: ${booking.driver!.name}'
                              : 'Customer: ${booking.customer?.name ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (booking.customer != null && booking.driver != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Customer: ${booking.customer!.name}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Price
            if (booking.price != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee_rounded, size: 20, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Price: ₹${booking.price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Notes
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note_rounded, size: 20, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

