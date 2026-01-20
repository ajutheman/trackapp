import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:truck_app/features/auth/screens/register_screen_driver.dart';
import 'package:truck_app/features/auth/screens/register_screen_user.dart';
import 'package:truck_app/features/splash/screen/splash_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final bool isDriverLogin;
  final String phone;
  final String otpRequestToken;

  const OtpScreen({
    super.key,
    required this.isDriverLogin,
    required this.phone,
    required this.otpRequestToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin, CodeAutoFill {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _countdown = 60;
  bool _isResendEnabled = false;
  String _currentToken = '';

  @override
  void initState() {
    super.initState();
    _currentToken = widget.otpRequestToken;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _startCountdown();
    _listenForSMS();
  }

  void _listenForSMS() async {
    try {
      // Request SMS permission and listen for OTP
      await SmsAutoFill().listenForCode();
    } catch (e) {
      debugPrint('Error listening for SMS: $e');
    }
  }

  @override
  void codeUpdated() {
    // This is called when SMS is received
    if (code != null && code!.length == 4) {
      // Auto-fill OTP fields
      for (int i = 0; i < 4; i++) {
        _otpControllers[i].text = code![i];
      }
      setState(() {});

      // Auto-verify after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isOtpComplete) {
          _verifyOtp();
        }
      });
    }
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
    if (!_isResendEnabled) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Pulse animation for feedback
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    // Trigger resend event
    context.read<AuthBloc>().add(ResendOTPRequested(token: _currentToken));
  }

  // Zero-width space constant for consistency
  static const String _zeroWidthSpace = '\u200B';

  String get _otpValue {
    return _otpControllers
        .map((controller) => controller.text.replaceAll(_zeroWidthSpace, ''))
        .join();
  }

  bool get _isOtpComplete {
    // Check each field has exactly 1 digit
    for (var controller in _otpControllers) {
      final digit = controller.text.replaceAll(_zeroWidthSpace, '');
      if (digit.isEmpty || digit.length != 1) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    cancel();
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(child: CircularProgressIndicator()),
              );
            } else {
              // remove loading if present
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is OTPResentSuccess) {
              // Update token after successful resend
              setState(() {
                _currentToken = state.otpRequestToken;
                _countdown = 60;
                _isResendEnabled = false;
              });
              _startCountdown();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'OTP resent successfully'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Show resend info if available
              if (state.remainingResends > 0) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${state.remainingResends} resend(s) remaining',
                        ),
                        backgroundColor: AppColors.secondary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                });
              }
            }

            if (state is OTPVerifiedSuccess) {
              if (state.isNewUser) {
                if (widget.isDriverLogin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => RegisterScreenDriver(
                            phone: widget.phone,
                            token: state.token,
                          ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => RegisterScreenUser(
                            phone: widget.phone,
                            token: state.token,
                          ),
                    ),
                  );
                }
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (predict) => false,
                );
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
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppColors.textPrimary,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                colors: [
                                  AppColors.secondary.withOpacity(0.2),
                                  AppColors.secondary.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.sms_outlined,
                              size: 50,
                              color: AppColors.secondary,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Verify Phone Number',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 28,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'Enter the 4-digit code sent to\n${widget.phone}',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
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
                                  // Handle paste - if value has more than 1 character
                                  if (value.length > 1) {
                                    _handlePaste(value);
                                    return;
                                  }

                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                  setState(() {});
                                },
                                onBackspace: () {
                                  // Handle backspace on empty field
                                  if (_otpControllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                    // Clear the previous field value as well for better UX
                                    _otpControllers[index - 1].clear();
                                    setState(() {});
                                  }
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
                                    Text(
                                      "Didn't receive code? ",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          _isResendEnabled ? _resendOtp : null,
                                      child: Text(
                                        _isResendEnabled
                                            ? 'Resend OTP'
                                            : 'Resend in ${_countdown}s',
                                        style: TextStyle(
                                          color:
                                              _isResendEnabled
                                                  ? AppColors.secondary
                                                  : AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.secondary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                  : null,
                          color: _isOtpComplete ? null : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:
                              _isOtpComplete
                                  ? [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: ElevatedButton(
                          onPressed: _isOtpComplete ? () => _verifyOtp() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isOtpComplete
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
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

  /// Handle paste - distributes pasted OTP across all fields
  void _handlePaste(String pastedValue) {
    // Extract only digits from pasted value
    final digits = pastedValue.replaceAll(RegExp(r'[^0-9]'), '');

    // Fill OTP fields with pasted digits
    for (int i = 0; i < 4 && i < digits.length; i++) {
      _otpControllers[i].text = digits[i];
    }

    // Move focus to the last filled field or the next empty one
    final lastIndex = (digits.length - 1).clamp(0, 3);
    if (digits.length >= 4) {
      // All fields filled, focus on the last one
      _focusNodes[3].requestFocus();
    } else {
      // Focus on the next empty field
      _focusNodes[(lastIndex + 1).clamp(0, 3)].requestFocus();
    }

    setState(() {});

    // Auto-verify if all fields are filled
    if (digits.length >= 4) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isOtpComplete && mounted) {
          _verifyOtp();
        }
      });
    }
  }

  void _verifyOtp() {
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
      VerifyOTPRequested(otp: _otpValue, token: _currentToken),
    );
  }
}

class _OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onBackspace;

  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onBackspace,
  });

  @override
  State<_OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<_OtpInputField> {
  // Zero-width space used for backspace detection on mobile
  static const String _zeroWidthSpace = '\u200B';
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    // Initialize with zero-width space if empty
    if (widget.controller.text.isEmpty) {
      widget.controller.text = _zeroWidthSpace;
    }
    _previousValue = widget.controller.text;

    // Listen for focus changes to position cursor correctly
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus && mounted) {
      // Position cursor at the end when focused
      final text = widget.controller.text;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  // Get the actual digit value (excluding zero-width space)
  String get _actualValue {
    return widget.controller.text.replaceAll(_zeroWidthSpace, '');
  }

  // Check if field has actual content
  bool get _hasContent {
    return _actualValue.isNotEmpty;
  }

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
              widget.focusNode.hasFocus
                  ? AppColors.secondary
                  : _hasContent
                  ? AppColors.success
                  : Colors.grey.shade300,
          width: widget.focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\u200B]')),
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          // Remove all zero-width spaces and get actual digits
          final digits = value.replaceAll(_zeroWidthSpace, '');

          // Handle paste - multiple digits entered
          if (digits.length > 1) {
            // Reset this field to zero-width space
            widget.controller.text = _zeroWidthSpace;
            widget.controller.selection = TextSelection.fromPosition(
              const TextPosition(offset: 1),
            );
            _previousValue = _zeroWidthSpace;
            widget.onChanged(digits); // Pass full pasted value to parent
            return;
          }

          // Handle backspace - was there content before and now there's nothing?
          final prevDigits = _previousValue.replaceAll(_zeroWidthSpace, '');
          if (prevDigits.isEmpty && digits.isEmpty && value.isEmpty) {
            // Backspace pressed on empty field (zero-width space was deleted)
            widget.controller.text = _zeroWidthSpace;
            widget.controller.selection = TextSelection.fromPosition(
              const TextPosition(offset: 1),
            );
            _previousValue = _zeroWidthSpace;
            if (widget.onBackspace != null) {
              widget.onBackspace!();
            }
            return;
          }

          // Handle normal single digit input
          if (digits.length == 1) {
            widget.controller.text = digits;
            widget.controller.selection = TextSelection.fromPosition(
              const TextPosition(offset: 1),
            );
            _previousValue = digits;
            HapticFeedback.selectionClick();
            widget.onChanged(digits);
            setState(() {});
            return;
          }

          // Field is empty (digit was deleted)
          if (digits.isEmpty) {
            widget.controller.text = _zeroWidthSpace;
            widget.controller.selection = TextSelection.fromPosition(
              const TextPosition(offset: 1),
            );
            _previousValue = _zeroWidthSpace;
            widget.onChanged('');
            setState(() {});
          }
        },
      ),
    );
  }
}
