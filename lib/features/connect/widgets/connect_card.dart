import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/model/connect.dart';

class ConnectCard extends StatelessWidget {
  final Connect connect;
  final Function(Connect) onAccept;
  final Function(Connect) onReject;
  final Function(String) onCall;
  final Function(String) onWhatsApp;
  final bool showActions; // New: to conditionally show action buttons

  const ConnectCard({
    super.key,
    required this.connect,
    required this.onAccept,
    required this.onReject,
    required this.onCall,
    required this.onWhatsApp,
    this.showActions = true, // Default to true
  });

  // Function to launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle error, e.g., show a snackbar
      print('Could not launch $phoneNumber');
    }
  }

  // Function to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // Handle error, e.g., show a snackbar
      print('WhatsApp is not installed or could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format date and time
    final String formattedDateTime = '${DateFormat('dd/MM/yyyy').format(connect.dateTime)} ${DateFormat('HH:mm').format(connect.dateTime)}';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12), // Added margin for spacing
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(connect.postName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(formattedDateTime, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Reply from: ${connect.replyUserName}', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(connect.postTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          if (showActions) ...[
            // Conditionally show actions
            const SizedBox(height: 16),
            if (!connect.isUser) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAccept(connect),
                      icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                      label: const Text('Accept', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _makePhoneCall('9876543210'),
                    icon: Icon(Icons.call, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _launchWhatsApp('9876543210'),
                    icon: Icon(FontAwesomeIcons.whatsapp, color: AppColors.success),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => onReject(connect),
                    icon: Icon(Icons.cancel_outlined, color: AppColors.error),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Full-width buttons for user
              ElevatedButton.icon(
                onPressed: () => onCall('9876543210'),
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text('Call', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => onWhatsApp('9876543210'),
                icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: const Text('Chat on WhatsApp', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
