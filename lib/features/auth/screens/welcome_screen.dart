import 'package:flutter/material.dart';
import 'package:truck_app/features/auth/screens/login_screen.dart';

import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 60),

              // Hero Section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon with modern styling
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.local_shipping_rounded, size: 60, color: Colors.white),
                  ),

                  const SizedBox(height: 40),

                  // App Title
                  Text(
                    'LoadLink',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 36, letterSpacing: -0.5),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Your Gateway to Seamless\nTrucking Solutions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, fontSize: 18, height: 1.5, fontWeight: FontWeight.w400),
                  ),
                ],
              ),

              // Features Section
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: FeatureCard(icon: Icons.connect_without_contact_rounded, title: 'Connect', subtitle: 'Find customers instantly')),
                      const SizedBox(width: 16),
                      Expanded(child: FeatureCard(icon: Icons.trending_up_rounded, title: 'Grow', subtitle: 'Expand your business')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: FeatureCard(icon: Icons.security_rounded, title: 'Secure', subtitle: 'Safe transactions')),
                      const SizedBox(width: 16),
                      Expanded(child: FeatureCard(icon: Icons.support_agent_rounded, title: 'Support', subtitle: '24/7 assistance')),
                    ],
                  ),
                ],
              ),

              // CTA Section
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
