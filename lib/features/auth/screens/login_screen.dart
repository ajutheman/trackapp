import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truck_app/features/auth/screens/otp_screen.dart';

import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final bool isDriverLogin;

  const LoginScreen({super.key, required this.isDriverLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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

                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(Icons.local_shipping_rounded, size: 40, color: Colors.white),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 28)),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text('Enter your mobile number to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Phone Input Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),

                        const SizedBox(height: 12),

                        // Phone Input Container
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: phoneFocusNode.hasFocus ? AppColors.secondary : Colors.grey.shade200, width: phoneFocusNode.hasFocus ? 2 : 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              // Country Code
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF138808)],
                                          stops: [0.33, 0.5, 0.67],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('+91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),

                              // Phone Input
                              Expanded(
                                child: TextField(
                                  controller: phoneController,
                                  focusNode: phoneFocusNode,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter phone number',
                                    hintStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Helper Text
                        Text('We will send you a verification code', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Continue Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient:
                                phoneController.text.length == 10
                                    ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight)
                                    : null,
                            color: phoneController.text.length == 10 ? null : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                phoneController.text.length == 10 ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
                          ),
                          child: ElevatedButton(
                            onPressed:
                                phoneController.text.length == 10
                                    ? () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpScreen()));
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: phoneController.text.length == 10 ? Colors.white : Colors.grey.shade600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms and Conditions
                        Text.rich(
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
