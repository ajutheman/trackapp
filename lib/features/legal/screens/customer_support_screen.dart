import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'help_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'privacy_policy_screen.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Support', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: AppColors.secondary, size: 24),
                        const SizedBox(width: 12),
                        const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(icon: Icons.email_outlined, title: 'Email', value: 'support@truckapp.com', onTap: () => _copyToClipboard('support@truckapp.com', 'Email')),
                    const SizedBox(height: 12),
                    _buildContactItem(icon: Icons.phone_outlined, title: 'Phone', value: '+1 (555) 123-4567', onTap: () => _copyToClipboard('+1 (555) 123-4567', 'Phone')),
                    const SizedBox(height: 12),
                    _buildContactItem(icon: Icons.access_time_outlined, title: 'Hours', value: 'Mon-Fri: 9:00 AM - 6:00 PM', onTap: null),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support Form
              const Text('Send us a Message', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'What is this regarding?',
                  prefixIcon: const Icon(Icons.subject_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'Describe your issue or question in detail...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  if (value.length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitSupportRequest,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text('Send Message', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    shadowColor: AppColors.secondary.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Links
              const Text('Quick Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildQuickLink(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Browse FAQs and guides',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
                },
              ),
              const SizedBox(height: 8),
              _buildQuickLink(
                icon: Icons.description_outlined,
                title: 'Terms and Conditions',
                subtitle: 'Read our terms of service',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                },
              ),
              const SizedBox(height: 8),
              _buildQuickLink(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn about data privacy',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.copy_outlined, color: AppColors.secondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 18),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 2), backgroundColor: AppColors.success));
  }

  void _submitSupportRequest() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                const Text('Message Sent', style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            content: const Text(
              'Thank you for contacting us! We have received your message and will get back to you within 24-48 hours.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _subjectController.clear();
                  _messageController.clear();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }
}
