import 'package:flutter/material.dart';
import 'package:truck_app/core/constants/app_images.dart';
import 'package:truck_app/features/auth/screens/login_screen.dart'; // Assuming this is your login screen for users

import '../../../core/theme/app_colors.dart'; // Ensure this path is correct

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': AppImages.onboardingConnect, // Placeholder image
      'title': 'Connect Instantly',
      'description': 'Find and connect with reliable transporters and loads across India with ease.',
    },
    {
      'image': AppImages.onboardingGrow, // Placeholder image
      'title': 'Grow Your Business',
      'description': 'Expand your network and discover new opportunities to maximize your earnings.',
    },
    {
      'image':AppImages.onboardingSecure, // Placeholder image
      'title': 'Secure & Transparent',
      'description': 'Experience safe transactions and clear communication every step of the way.',
    },
    {
      'image': AppImages.onboardingSupport, // Placeholder image
      'title': '24/7 Support',
      'description': 'Our dedicated support team is always here to assist you, day or night.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkipPressed() {
    _pageController.jumpToPage(_onboardingData.length - 1);
  }

  void _onContinuePressed() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // On the last page, the "Continue" button is replaced by login options
      // This logic will not be triggered directly by "Continue" on the last page.
    }
  }

  void _navigateToLoginAsUser() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isDriverLogin: false)));
  }

  void _navigateToLoginAsDriver() {
    // Assuming a separate login screen or flow for drivers
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isDriverLogin: true)));
    // You might want to pass a flag or navigate to a different screen for driver login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _onboardingData.length - 1) // Show skip until last page
                    TextButton(
                      onPressed: _onSkipPressed,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Onboarding Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingSlide(
                    imagePath: _onboardingData[index]['image']!,
                    title: _onboardingData[index]['title']!,
                    description: _onboardingData[index]['description']!,
                  );
                },
              ),
            ),

            // Page Indicator Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                      (index) => _buildDot(index == _currentPage),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: _currentPage == _onboardingData.length - 1
                  ? Column(
                children: [
                  // Login as User Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToLoginAsUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Login as User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login as Driver Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // Different background for driver login
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToLoginAsDriver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Login as Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    ),
                  ),
                ],
              )
                  : Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingSlide({required String imagePath, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration (Placeholder)
          Image.asset(
            imagePath,
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                width: double.infinity,
                color: AppColors.background,
                child: Icon(Icons.image_not_supported_outlined, size: 100, color: AppColors.textSecondary.withOpacity(0.3)),
              );
            },
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Ensure LoginScreen can accept a flag for driver login if needed
// This is a simple modification for demonstration.
// You might have a more complex routing or state management for this.
// In features/auth/screens/login_screen.dart
/*
class LoginScreen extends StatelessWidget {
  final bool isDriverLogin;
  const LoginScreen({super.key, this.isDriverLogin = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isDriverLogin ? 'Driver Login' : 'User Login')),
      body: Center(
        child: Text('Login Screen for ${isDriverLogin ? "Driver" : "User"}'),
      ),
    );
  }
}
*/
