import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/utils/messages.dart';
import 'package:truck_app/features/auth/screens/register_screen_user.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final bool isDriverLogin;
  final String phone;
  final String otpRequestToken;

  const OtpScreen({super.key, required this.isDriverLogin, required this.phone, required this.otpRequestToken});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _countdown = 30;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _animationController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown == 0) {
            _isResendEnabled = true;
          }
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  void _resendOtp() {
    setState(() {
      _countdown = 30;
      _isResendEnabled = false;
    });
    _startCountdown();

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Pulse animation for feedback
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  String get _otpValue {
    return _otpControllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete {
    return _otpValue.length == 4;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            // Simple loading overlay
            if (state is AuthLoading) {
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
            } else {
              // remove loading if present
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            }

            if (state is OTPVerifiedSuccess) {
              if (widget.isDriverLogin) {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreenDriver()));
                showSnackBar(context, "Driver registration is still under construction. Please go back and choose 'Login as User'.");
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreenUser(phone: widget.phone, token: state.token)));
              }
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Back Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 2),
                            ),
                            child: Icon(Icons.sms_outlined, size: 50, color: AppColors.secondary),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Verify Phone Number',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 28),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'Enter the 4-digit code sent to your\nmobile number',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // OTP Input Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              4,
                              (index) => _OtpInputField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Resend Section
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Didn't receive code? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                    GestureDetector(
                                      onTap: _isResendEnabled ? _resendOtp : null,
                                      child: Text(
                                        _isResendEnabled ? 'Resend OTP' : 'Resend in ${_countdown}s',
                                        style: TextStyle(color: _isResendEnabled ? AppColors.secondary : AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Verify Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient:
                              _isOtpComplete
                                  ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight)
                                  : null,
                          color: _isOtpComplete ? null : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isOtpComplete ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
                        ),
                        child: ElevatedButton(
                          onPressed: _isOtpComplete ? () => _verifyOtp() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Verify & Continue',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _isOtpComplete ? Colors.white : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOtp() {
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(VerifyOTPRequested(otp: _otpValue, token: widget.otpRequestToken));
  }
}

class _OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _OtpInputField({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              focusNode.hasFocus
                  ? AppColors.secondary
                  : controller.text.isNotEmpty
                  ? AppColors.success
                  : Colors.grey.shade300,
          width: focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: '', border: InputBorder.none, contentPadding: EdgeInsets.zero),
        onChanged: (value) {
          if (value.isNotEmpty) {
            HapticFeedback.selectionClick();
          }
          onChanged(value);
        },
      ),
    );
  }
}
