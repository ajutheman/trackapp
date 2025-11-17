// lib/features/booking/screens/delivery_otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/booking/bloc/booking_bloc.dart';

class DeliveryOtpVerificationScreen extends StatefulWidget {
  final String bookingId;

  const DeliveryOtpVerificationScreen({super.key, required this.bookingId});

  @override
  State<DeliveryOtpVerificationScreen> createState() => _DeliveryOtpVerificationScreenState();
}

class _DeliveryOtpVerificationScreenState extends State<DeliveryOtpVerificationScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  late AnimationController _animationController;
  bool _isGenerating = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _generateOtp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _generateOtp() {
    setState(() {
      _isGenerating = true;
    });
    context.read<BookingBloc>().add(GenerateDeliveryOtp(bookingId: widget.bookingId));
  }

  String get _otpValue {
    return _otpControllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete {
    return _otpValue.length == 6;
  }

  void _verifyOtp() {
    if (!_isOtpComplete) return;

    setState(() {
      _isVerifying = true;
    });

    HapticFeedback.mediumImpact();
    context.read<BookingBloc>().add(VerifyDeliveryOtp(bookingId: widget.bookingId, code: _otpValue));
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_isOtpComplete) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Verify Delivery',
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
          if (state is DeliveryOtpGenerated) {
            setState(() {
              _isGenerating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Delivery OTP generated successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is DeliveryOtpVerified) {
            setState(() {
              _isVerifying = false;
            });
            Navigator.of(context).pop(true);
          } else if (state is BookingError) {
            setState(() {
              _isGenerating = false;
              _isVerifying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _animationController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.done_all_rounded, size: 48, color: Colors.purple),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Delivery Verification',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit OTP code provided by the customer to verify delivery',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondary, width: 2),
                          ),
                        ),
                        onChanged: (value) => _onOtpChanged(index, value),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Verify Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isOtpComplete && !_isVerifying ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOtpComplete ? Colors.purple : AppColors.textSecondary,
                      disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: _isOtpComplete ? 4 : 0,
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verify Delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend OTP Button
                TextButton.icon(
                  onPressed: _isGenerating ? null : _generateOtp,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Resend OTP',
                    style: TextStyle(
                      color: _isGenerating ? AppColors.textSecondary : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

