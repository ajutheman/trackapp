import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            _buildHelpSection(
              title: 'Getting Started',
              icon: Icons.rocket_launch,
              items: [
                _HelpItem(
                  question: 'How do I create an account?',
                  answer:
                      'To create an account, tap on "Sign Up" from the welcome screen. Enter your phone number, verify it with the OTP code sent to you, and complete your profile by providing your name, email, and other required information.',
                ),
                _HelpItem(
                  question: 'What\'s the difference between User and Driver accounts?',
                  answer:
                      'User accounts are for customers who need transportation services. Driver accounts are for truck owners and drivers who provide transportation services. You can select your account type during registration.',
                ),
                _HelpItem(
                  question: 'How do I verify my phone number?',
                  answer:
                      'After entering your phone number, you\'ll receive an OTP (One-Time Password) via SMS. Enter this code in the verification screen to complete your registration.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Creating Posts/Trips',
              icon: Icons.add_circle_outline,
              items: [
                _HelpItem(
                  question: 'How do I create a trip request?',
                  answer:
                      'Tap the "+" button in the center of the bottom navigation bar. Fill in the trip details including pickup location, destination, goods type, vehicle requirements, and dates. You can also add via routes for multi-stop trips.',
                ),
                _HelpItem(
                  question: 'Can I edit or delete my trip?',
                  answer: 'Yes, you can edit or delete your trips from the "My Posts" section. Open the trip you want to modify and use the edit or delete options.',
                ),
                _HelpItem(
                  question: 'How do I set trip pricing?',
                  answer: 'Pricing can be negotiated directly with drivers through the connection feature, or you can specify your budget in the trip description.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Connections & Communication',
              icon: Icons.chat_bubble_outline,
              items: [
                _HelpItem(
                  question: 'How do I connect with drivers/customers?',
                  answer:
                      'Browse available trips or drivers on the home screen. Tap on a post to view details, then use the "Connect" button to send a connection request. Once accepted, you can communicate and coordinate.',
                ),
                _HelpItem(
                  question: 'How do I manage connection requests?',
                  answer: 'Go to the Connections tab to view pending requests. You can accept or decline connection requests from there.',
                ),
                _HelpItem(
                  question: 'Can I block or report users?',
                  answer: 'Yes, you can report inappropriate behavior through the Customer Support section. We take user safety seriously and will investigate all reports.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Profile & Account',
              icon: Icons.person_outline,
              items: [
                _HelpItem(
                  question: 'How do I update my profile?',
                  answer:
                      'Go to your profile screen (Account tab) and tap the edit icon. You can update your name, email, phone number, and profile picture. Remember to save your changes.',
                ),
                _HelpItem(
                  question: 'How do I add vehicle information?',
                  answer:
                      'Drivers can add vehicle information from the "My Vehicle" section in the profile. Add details like vehicle type, registration number, capacity, and insurance information.',
                ),
                _HelpItem(
                  question: 'How do I delete my account?',
                  answer: 'Go to your profile screen and scroll to the bottom. Tap "Delete Account" and confirm your decision. This action cannot be undone.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Payment & Transactions',
              icon: Icons.payment,
              items: [
                _HelpItem(
                  question: 'How do payments work?',
                  answer:
                      'Payment terms are agreed upon between users. The app facilitates connections but payments are typically handled directly between parties. Ensure you discuss payment terms before starting a trip.',
                ),
                _HelpItem(
                  question: 'What payment methods are accepted?',
                  answer:
                      'Payment methods are agreed upon between users. Common methods include cash, bank transfers, or digital payment platforms. Always confirm payment details before the trip.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Troubleshooting',
              icon: Icons.build_outlined,
              items: [
                _HelpItem(
                  question: 'The app is not loading properly',
                  answer:
                      'Try closing and reopening the app. Ensure you have a stable internet connection. If the problem persists, try clearing the app cache or reinstalling the app.',
                ),
                _HelpItem(
                  question: 'I\'m not receiving notifications',
                  answer:
                      'Check your device notification settings for the app. Ensure notifications are enabled in both the app settings and your device settings. Also check your internet connection.',
                ),
                _HelpItem(
                  question: 'Location services are not working',
                  answer:
                      'Go to your device settings and ensure location permissions are granted for the app. The app needs location access to provide trip matching and route optimization.',
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: AppColors.secondary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Still need help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Contact our support team for additional assistance', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({required String title, required IconData icon, required List<_HelpItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        children: items.map((item) => _buildHelpItem(item)).toList(),
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildHelpItem(_HelpItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(item.answer, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

class _HelpItem {
  final String question;
  final String answer;

  _HelpItem({required this.question, required this.answer});
}
