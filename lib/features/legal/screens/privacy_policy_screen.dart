import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
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
              title: '1. Information We Collect',
              content:
                  'We collect the following types of information:\n\n• Personal Information: Name, email, phone number, address\n• Profile Information: Profile picture, vehicle details, driver credentials\n• Location Data: Pickup and delivery locations for trip planning\n• Usage Data: How you interact with the app, features used, preferences\n• Device Information: Device type, operating system, unique device identifiers',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use your information to:\n• Provide and improve our transportation services\n• Connect you with drivers or customers\n• Process payments and transactions\n• Send notifications and updates\n• Ensure platform safety and security\n• Comply with legal obligations\n• Analyze usage patterns to enhance user experience',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '3. Information Sharing',
              content:
                  'We may share your information with:\n• Other users (as necessary for service provision)\n• Service providers who assist in app operations\n• Legal authorities when required by law\n• Business partners with your consent\n\nWe do not sell your personal information to third parties.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '4. Data Security',
              content:
                  'We implement industry-standard security measures to protect your data:\n• Encryption of sensitive information\n• Secure authentication systems\n• Regular security audits\n• Access controls and monitoring\n\nHowever, no method of transmission over the internet is 100% secure.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '5. Location Data',
              content:
                  'We collect location data to:\n• Match trips with drivers\n• Provide route optimization\n• Enable real-time tracking (with your permission)\n• Improve service quality\n\nYou can control location permissions through your device settings.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '6. Your Rights',
              content:
                  'You have the right to:\n• Access your personal data\n• Request data correction\n• Request data deletion\n• Object to data processing\n• Data portability\n• Withdraw consent at any time',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '7. Cookies and Tracking',
              content:
                  'We use cookies and similar technologies to:\n• Remember your preferences\n• Analyze app usage\n• Improve functionality\n• Provide personalized content\n\nYou can manage cookie preferences through your device settings.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '8. Children\'s Privacy',
              content:
                  'Our service is not intended for users under the age of 18. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '9. Changes to Privacy Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or via email. Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '10. Contact Us',
              content: 'If you have questions about this Privacy Policy or wish to exercise your rights, please contact us through the Customer Support section in the app.',
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
