import 'package:flutter/material.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs (documents/images)

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  // Helper to launch a URL (e.g., for documents or images)
  Future<void> _launchURL(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file available to open.')));
      return;
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(vehicle.vehicleNumber, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,

        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Type and Body Type
            _buildInfoCard(
              context,
              title: 'Vehicle Overview',
              children: [
                _buildDetailRow(icon: vehicle.type.icon, label: 'Type', value: vehicle.type.name),
                _buildDetailRow(icon: Icons.local_shipping_outlined, label: 'Body Type', value: vehicle.bodyType.name),
                _buildDetailRow(icon: Icons.scale_outlined, label: 'Capacity', value: '${vehicle.capacity} tons'),
              ],
            ),
            const SizedBox(height: 16),

            // Vehicle Documents
            _buildInfoCard(
              context,
              title: 'Documents',
              children: [
                _buildDocumentRow(context, label: 'RC (Registration Certificate)', fileUrl: vehicle.rcFileUrl, icon: Icons.description_outlined),
                _buildDocumentRow(context, label: 'Driving License', fileUrl: vehicle.drivingLicenseFileUrl, icon: Icons.credit_card_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // Truck Images
            if (vehicle.truckImageUrls.isNotEmpty) ...[
              Text('Truck Images', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                height: 150, // Fixed height for horizontal scroll
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vehicle.truckImageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          // Assuming local file paths for demonstration
                          // In a real app, use NetworkImage for URLs
                          // Image.network(vehicle.truckImageUrls[index], ...)
                          // For now, using Image.file as the AddVehicleScreen saves file paths
                          // If you implement actual image upload, this would change.
                          // Fallback for network images if paths are not local:
                          // Image.network(
                          //   vehicle.truckImageUrls[index],
                          //   height: 150,
                          //   width: 200,
                          //   fit: BoxFit.cover,
                          //   errorBuilder: (context, error, stackTrace) => Container(
                          //     height: 150, width: 200, color: Colors.grey.shade200,
                          //     child: Icon(Icons.broken_image, color: AppColors.textSecondary.withOpacity(0.5)),
                          //   ),
                          // ),
                          // Temporary solution for local file paths:
                          vehicle.truckImageUrls[index],
                          height: 150,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Container(height: 150, width: 200, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: AppColors.textSecondary.withOpacity(0.5))),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Goods Accepted
            if (vehicle.goodsAccepted.isNotEmpty) ...[
              _buildInfoCard(
                context,
                title: 'Goods Accepted',
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        vehicle.goodsAccepted
                            .map(
                              (goods) => Chip(
                                label: Text(goods),
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                labelStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, {required String label, required String? fileUrl, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '${label.trim().toLowerCase().replaceAll(' ', '_')}_001.pdf',
                  // fileUrl != null && fileUrl.isNotEmpty ? fileUrl.split('/').last : 'Not uploaded',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: fileUrl != null && fileUrl.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (fileUrl != null && fileUrl.isNotEmpty)
            IconButton(icon: Icon(Icons.open_in_new, color: AppColors.secondary), onPressed: () => _launchURL(fileUrl, context), tooltip: 'Open Document'),
        ],
      ),
    );
  }
}
