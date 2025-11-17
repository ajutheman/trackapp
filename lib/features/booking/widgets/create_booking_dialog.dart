// lib/features/booking/widgets/create_booking_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/booking/bloc/booking_bloc.dart';
import 'package:truck_app/features/connect/model/connect_request.dart';

class CreateBookingDialog extends StatefulWidget {
  final ConnectRequest connectRequest;

  const CreateBookingDialog({
    super.key,
    required this.connectRequest,
  });

  @override
  State<CreateBookingDialog> createState() => _CreateBookingDialogState();
}

class _CreateBookingDialogState extends State<CreateBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _pickupDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.secondary,
                onPrimary: Colors.white,
                surface: AppColors.surface,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _pickupDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.connectRequest.tripId == null || widget.connectRequest.customerRequestId == null || widget.connectRequest.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing required information to create booking'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final price = _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null;
    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    context.read<BookingBloc>().add(
          CreateBooking(
            tripId: widget.connectRequest.tripId!,
            customerRequestId: widget.connectRequest.customerRequestId!,
            connectRequestId: widget.connectRequest.id!,
            price: price,
            pickupDate: _pickupDate,
            notes: notes,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking created successfully! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is BookingError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.book_online_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Create Booking',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (Optional)',
                      hintText: 'Enter booking price',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Please enter a valid price';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pickup Date Field
                  InkWell(
                    onTap: _selectPickupDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppColors.secondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup Date (Optional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pickupDate != null
                                      ? DateFormat('dd MMM yyyy • HH:mm').format(_pickupDate!)
                                      : 'Select pickup date and time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _pickupDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: _pickupDate != null ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any additional notes...',
                      prefixIcon: const Icon(Icons.note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitBooking,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Creating...' : 'Create Booking',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

