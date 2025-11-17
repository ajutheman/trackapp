// lib/features/connect/widgets/connect_request_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/connect/model/connect_request.dart';

class ConnectRequestCard extends StatelessWidget {
  final ConnectRequest request;
  final bool isSent; // Whether this request was sent by current user
  final String? currentUserId; // Current user ID
  final bool isDriver; // Whether current user is a driver
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;
  final VoidCallback? onViewContacts;
  final VoidCallback? onCreateBooking;

  const ConnectRequestCard({
    super.key,
    required this.request,
    this.isSent = false,
    this.currentUserId,
    this.isDriver = false,
    this.onAccept,
    this.onReject,
    this.onDelete,
    this.onViewContacts,
    this.onCreateBooking,
  });

  Color _getStatusColor() {
    switch (request.status) {
      case ConnectRequestStatus.pending:
        return Colors.orange;
      case ConnectRequestStatus.accepted:
        return AppColors.success;
      case ConnectRequestStatus.rejected:
        return AppColors.error;
      case ConnectRequestStatus.cancelled:
        return AppColors.textSecondary;
      case ConnectRequestStatus.hold:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case ConnectRequestStatus.pending:
        return 'Pending';
      case ConnectRequestStatus.accepted:
        return 'Accepted';
      case ConnectRequestStatus.rejected:
        return 'Rejected';
      case ConnectRequestStatus.cancelled:
        return 'Cancelled';
      case ConnectRequestStatus.hold:
        return 'On Hold';
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case ConnectRequestStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ConnectRequestStatus.accepted:
        return Icons.check_circle_rounded;
      case ConnectRequestStatus.rejected:
        return Icons.cancel_rounded;
      case ConnectRequestStatus.cancelled:
        return Icons.block_rounded;
      case ConnectRequestStatus.hold:
        return Icons.pause_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? formattedDateTime = request.createdAt != null
        ? '${DateFormat('dd MMM yyyy').format(request.createdAt!)} • ${DateFormat('HH:mm').format(request.createdAt!)}'
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
                        request.trip?.title ?? 'Connection Request',
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

            // User info with avatar
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
                      _getOtherUser()?.name.isNotEmpty == true
                          ? _getOtherUser()!.name[0].toUpperCase()
                          : '?',
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
                        isSent ? 'Sent to' : 'Request from',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getOtherUser()?.name ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Message
            if (request.message != null && request.message!.isNotEmpty) ...[
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
                    Icon(
                      Icons.message_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.message!,
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

            // Token information - only show for drivers
            if (isDriver && request.tokenDeduction != null) ...[
              const SizedBox(height: 16),
              _buildTokenInfo(),
            ],

            // Trip details
            if (request.trip != null) ...[
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Trip Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (request.trip!.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        request.trip!.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (request.trip!.startLocation != null ||
                        request.trip!.destination != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (request.trip!.startLocation != null) ...[
                            Expanded(
                              child: _buildLocationChip(
                                Icons.location_on_rounded,
                                request.trip!.startLocation!,
                                Colors.green,
                              ),
                            ),
                          ],
                          if (request.trip!.startLocation != null &&
                              request.trip!.destination != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (request.trip!.destination != null) ...[
                            Expanded(
                              child: _buildLocationChip(
                                Icons.flag_rounded,
                                request.trip!.destination!,
                                Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo() {
    final tokenDeduction = request.tokenDeduction!;
    final isHold = request.status == ConnectRequestStatus.hold;
    final hasDeducted = tokenDeduction.tokensDeducted > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHold
            ? Colors.blue.withOpacity(0.1)
            : (hasDeducted
                ? AppColors.success.withOpacity(0.1)
                : AppColors.background.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHold
              ? Colors.blue.withOpacity(0.3)
              : (hasDeducted
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.5)),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHold
                    ? Icons.pause_circle_outline_rounded
                    : (hasDeducted
                        ? Icons.check_circle_outline_rounded
                        : Icons.account_balance_wallet_outlined),
                size: 20,
                color: isHold
                    ? Colors.blue
                    : (hasDeducted ? AppColors.success : AppColors.secondary),
              ),
              const SizedBox(width: 8),
              Text(
                'Token Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tokenDeduction.tokensRequired.toStringAsFixed(0)} tokens',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDeducted) ...[
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.border.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deducted',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tokenDeduction.tokensDeducted.toStringAsFixed(0)} tokens',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isHold) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insufficient tokens. Add tokens to view contact details.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!hasDeducted && !tokenDeduction.hasSufficientTokens) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Low token balance. Tokens will be deducted on acceptance.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationChip(IconData icon, String location, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get the other user (not current user)
  ConnectUser? _getOtherUser() {
    if (isSent) {
      // If sent, show recipient
      return request.recipient;
    } else {
      // If received, show requester/initiator
      return request.requester;
    }
  }

  Widget _buildActionButtons() {
    if (request.status == ConnectRequestStatus.pending) {
      if (isSent) {
        // Sent request - show cancel/delete button only
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
            label: Text(
              'Cancel Request',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      } else {
        // Received request - show accept/reject buttons
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
              ),
              child: IconButton(
                onPressed: onReject,
                icon: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        );
      }
    } else if (request.status == ConnectRequestStatus.hold) {
      // Hold status - show retry button for drivers, info message for others
      if (isDriver) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Request is on hold. Add tokens and retry to accept.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onViewContacts,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        // Non-driver users see info message only
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request is on hold. Waiting for driver to add tokens.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (request.status == ConnectRequestStatus.accepted) {
      // Accepted status - show view contacts, create booking, and delete buttons
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onViewContacts,
                    icon: const Icon(Icons.contact_phone_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'View Contacts',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ],
          ),
          if (onCreateBooking != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onCreateBooking,
                  icon: const Icon(Icons.book_online_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Create Booking',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      // Rejected or cancelled - show delete button only
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
          label: Text(
            'Delete',
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }
  }
}


