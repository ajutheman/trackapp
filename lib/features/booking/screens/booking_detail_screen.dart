// lib/features/booking/screens/booking_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/booking/bloc/booking_bloc.dart';
import 'package:truck_app/features/booking/model/booking.dart';
import 'package:truck_app/features/booking/screens/pickup_otp_verification_screen.dart';
import 'package:truck_app/features/booking/screens/delivery_otp_verification_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Booking? _booking;

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(FetchBookingById(bookingId: widget.bookingId));
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAccept() {
    if (_booking == null) return;
    context.read<BookingBloc>().add(AcceptBooking(bookingId: _booking!.id!));
  }

  void _handleReject() {
    if (_booking == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Booking?'),
          content: const Text('Are you sure you want to reject this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BookingBloc>().add(RejectBooking(bookingId: _booking!.id!));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleCancel() {
    if (_booking == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final reasonController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cancel Booking?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this booking?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BookingBloc>().add(
                      CancelBooking(
                        bookingId: _booking!.id!,
                        cancellationReason: reasonController.text.isNotEmpty ? reasonController.text : null,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handlePickupOtp() {
    if (_booking == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupOtpVerificationScreen(bookingId: _booking!.id!),
      ),
    );
  }

  void _handleDeliveryOtp() {
    if (_booking == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryOtpVerificationScreen(bookingId: _booking!.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingDetailLoaded) {
            setState(() {
              _booking = state.booking;
            });
          } else if (state is BookingAccepted) {
            _showSnackBar('Booking accepted successfully!');
            context.read<BookingBloc>().add(FetchBookingById(bookingId: widget.bookingId));
          } else if (state is BookingRejected) {
            _showSnackBar('Booking rejected', isSuccess: false);
            Navigator.of(context).pop();
          } else if (state is BookingCancelled) {
            _showSnackBar('Booking cancelled');
            Navigator.of(context).pop();
          } else if (state is PickupOtpVerified) {
            _showSnackBar('Pickup verified successfully!');
            context.read<BookingBloc>().add(FetchBookingById(bookingId: widget.bookingId));
          } else if (state is DeliveryOtpVerified) {
            _showSnackBar('Delivery verified successfully!');
            context.read<BookingBloc>().add(FetchBookingById(bookingId: widget.bookingId));
          } else if (state is BookingError) {
            _showSnackBar(state.message, isSuccess: false);
          }
        },
        child: _booking == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildPartiesCard(),
                    const SizedBox(height: 20),
                    if (_booking!.price != null) _buildPriceCard(),
                    if (_booking!.notes != null && _booking!.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildNotesCard(),
                    ],
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _booking!.status;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case BookingStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Confirmed';
        statusIcon = Icons.check_circle_rounded;
        break;
      case BookingStatus.pickedUp:
        statusColor = Colors.blue;
        statusText = 'Picked Up';
        statusIcon = Icons.local_shipping_rounded;
        break;
      case BookingStatus.delivered:
        statusColor = Colors.purple;
        statusText = 'Delivered';
        statusIcon = Icons.done_all_rounded;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        statusIcon = Icons.celebration_rounded;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status.toString().split('.').last;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, size: 32, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_booking!.trip?.title != null) ...[
            _buildInfoRow(Icons.local_shipping_rounded, 'Trip', _booking!.trip!.title!),
            const SizedBox(height: 12),
          ],
          if (_booking!.customerRequest?.title != null) ...[
            _buildInfoRow(Icons.description_rounded, 'Request', _booking!.customerRequest!.title!),
            const SizedBox(height: 12),
          ],
          if (_booking!.pickupDate != null) ...[
            _buildInfoRow(
              Icons.calendar_today_rounded,
              'Pickup Date',
              DateFormat('dd MMM yyyy • HH:mm').format(_booking!.pickupDate!),
            ),
            const SizedBox(height: 12),
          ],
          if (_booking!.createdAt != null)
            _buildInfoRow(
              Icons.access_time_rounded,
              'Created',
              DateFormat('dd MMM yyyy • HH:mm').format(_booking!.createdAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parties',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_booking!.driver != null) ...[
            _buildPartyRow(Icons.person_rounded, 'Driver', _booking!.driver!.name, _booking!.driver!.phone),
            const SizedBox(height: 12),
          ],
          if (_booking!.customer != null)
            _buildPartyRow(Icons.person_outline_rounded, 'Customer', _booking!.customer!.name, _booking!.customer!.phone),
        ],
      ),
    );
  }

  Widget _buildPartyRow(IconData icon, String role, String name, String? phone) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (phone != null) ...[
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.currency_rupee_rounded, size: 32, color: AppColors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_booking!.price!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _booking!.notes!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _booking!.status;

    if (status == BookingStatus.pending) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleAccept,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: const Text(
                'Accept Booking',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleReject,
              icon: Icon(Icons.close_rounded, color: AppColors.error),
              label: Text(
                'Reject',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    } else if (status == BookingStatus.confirmed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handlePickupOtp,
              icon: const Icon(Icons.local_shipping_rounded, color: Colors.white),
              label: const Text(
                'Verify Pickup',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleCancel,
              icon: Icon(Icons.cancel_rounded, color: AppColors.error),
              label: Text(
                'Cancel Booking',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    } else if (status == BookingStatus.pickedUp) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _handleDeliveryOtp,
          icon: const Icon(Icons.done_all_rounded, color: Colors.white),
          label: const Text(
            'Verify Delivery',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

