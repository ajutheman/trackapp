import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/model/connect.dart';

class ConnectCard extends StatefulWidget {
  final Connect connect;
  final Function(Connect) onAccept;
  final Function(Connect) onReject;
  final Function(String) onCall;
  final Function(String) onWhatsApp;
  final bool showActions;

  const ConnectCard({super.key, required this.connect, required this.onAccept, required this.onReject, required this.onCall, required this.onWhatsApp, this.showActions = true});

  @override
  State<ConnectCard> createState() => _ConnectCardState();
}

class _ConnectCardState extends State<ConnectCard> with TickerProviderStateMixin {
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      widget.onCall(phoneNumber);
    }
  }

  // Function to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      widget.onWhatsApp(phoneNumber);
    }
  }

  Color _getStatusColor() {
    switch (widget.connect.status) {
      case ConnectStatus.pending:
        return Colors.orange;
      case ConnectStatus.accepted:
      case ConnectStatus.completed:
        return AppColors.success;
      case ConnectStatus.rejected:
        return AppColors.error;
      case ConnectStatus.hold:
        return Colors.amber;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (widget.connect.status) {
      case ConnectStatus.pending:
        return 'Pending';
      case ConnectStatus.accepted:
        return 'Accepted';
      case ConnectStatus.completed:
        return 'Completed';
      case ConnectStatus.rejected:
        return 'Rejected';
      case ConnectStatus.hold:
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.connect.status) {
      case ConnectStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ConnectStatus.accepted:
      case ConnectStatus.completed:
        return Icons.check_circle_rounded;
      case ConnectStatus.rejected:
        return Icons.cancel_rounded;
      case ConnectStatus.hold:
        return Icons.pause_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDateTime = '${DateFormat('dd MMM').format(widget.connect.dateTime)} • ${DateFormat('HH:mm').format(widget.connect.dateTime)}';

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer effect for pending status
            if (widget.connect.status == ConnectStatus.pending)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.1), Colors.transparent], stops: const [0.0, 0.5, 1.0]),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.connect.postName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(formattedDateTime, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(), size: 14, color: _getStatusColor()),
                            const SizedBox(width: 4),
                            Text(_getStatusText(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor())),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User info with avatar
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.8), AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Center(
                          child: Text(
                            widget.connect.replyUserName.isNotEmpty ? widget.connect.replyUserName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Request from', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(widget.connect.replyUserName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Post title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.article_rounded, size: 20, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.connect.postTitle,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  if (widget.showActions) ...[
                    const SizedBox(height: 20),
                    if (widget.connect.status == ConnectStatus.pending) ...[
                      // Pending status - show accept/reject buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => widget.onAccept(widget.connect),
                                icon: const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                                label: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
                            ),
                            child: IconButton(
                              onPressed: () => widget.onReject(widget.connect),
                              icon: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.connect.status == ConnectStatus.accepted || widget.connect.status == ConnectStatus.completed) ...[
                      // Accepted/Completed status - show call and WhatsApp buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _makePhoneCall('9876543210'),
                                icon: const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                                label: const Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _launchWhatsApp('9876543210'),
                                icon: const Icon(FontAwesomeIcons.whatsapp, size: 18, color: Colors.white),
                                label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
