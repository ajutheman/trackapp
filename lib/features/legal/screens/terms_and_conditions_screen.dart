import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms and Conditions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
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
            Text('Last Updated: ${DateTime.now().toString().split(' ')[0]}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using this truck transportation app, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '2. Description of Service',
              content:
                  'This app provides a platform for connecting truck owners, drivers, and customers for transportation services. We facilitate the connection but are not responsible for the actual transportation services provided.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '3. User Responsibilities',
              content:
                  'Users are responsible for:\n• Providing accurate information\n• Maintaining the security of their account\n• Complying with all applicable laws\n• Ensuring proper insurance coverage for vehicles\n• Verifying driver credentials and vehicle conditions',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '4. Payment Terms',
              content:
                  'Payment terms are agreed upon between users. The app may facilitate payment processing but is not responsible for payment disputes. All transactions are subject to applicable fees as outlined in the payment section.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '5. Prohibited Activities',
              content:
                  'Users are prohibited from:\n• Using the service for illegal activities\n• Posting false or misleading information\n• Harassing or abusing other users\n• Violating any applicable laws or regulations\n• Interfering with the app\'s functionality',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '6. Insurance and Liability',
              content:
                  'Users are required to maintain appropriate insurance coverage. The app is not liable for any damages, losses, or injuries that occur during transportation services. Users are solely responsible for their vehicles and services.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '7. Account Termination',
              content: 'We reserve the right to terminate or suspend accounts that violate these terms, engage in fraudulent activity, or misuse the platform in any way.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '8. Changes to Terms',
              content:
                  'We reserve the right to modify these terms at any time. Users will be notified of significant changes. Continued use of the app after changes constitutes acceptance of the new terms.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '9. Contact Information',
              content: 'For questions about these Terms and Conditions, please contact us through the Customer Support section in the app.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
