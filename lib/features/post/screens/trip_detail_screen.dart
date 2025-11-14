import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/model/post.dart';
import '../../home/repo/posts_repo.dart';
import '../../../di/locator.dart';
import '../../../services/network/api_service.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Post? _trip;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    try {
      final postsRepo = PostsRepository(apiService: locator<ApiService>());
      final result = await postsRepo.getPostById(widget.tripId);

      if (result.isSuccess && result.data != null) {
        if (mounted) {
          setState(() {
            _trip = result.data;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to load trip details'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          // Wait a bit before navigating back to show the error
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trip: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not specified';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Trip Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trip = _trip!;
    final startLocation = trip.tripStartLocation;
    final endLocation = trip.tripDestination;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            // if (trip.status != null || trip.isActive != null)
            //   Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(16),
            //     margin: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         colors: [
            //           (trip.isActive ?? true) ? Colors.green.shade50 : Colors.orange.shade50,
            //           (trip.isActive ?? true) ? Colors.green.shade100.withOpacity(0.3) : Colors.orange.shade100.withOpacity(0.3),
            //         ],
            //       ),
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(color: (trip.isActive ?? true) ? Colors.green.shade200 : Colors.orange.shade200, width: 1.5),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(
            //           (trip.isActive ?? true) ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
            //           color: (trip.isActive ?? true) ? Colors.green.shade700 : Colors.orange.shade700,
            //         ),
            //         const SizedBox(width: 12),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 trip.status?.name ?? ((trip.isActive ?? true) ? 'Active' : 'Inactive'),
            //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: (trip.isActive ?? true) ? Colors.green.shade700 : Colors.orange.shade700),
            //               ),
            //               if (trip.status?.description != null) Text(trip.status!.description, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),

            // Route Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  // Start Location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green.shade50, Colors.green.shade100.withOpacity(0.3)]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade700]), shape: BoxShape.circle),
                          child: const Icon(Icons.my_location_rounded, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FROM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green.shade700, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                startLocation?.address ?? trip.pickupLocation ?? 'Start Location',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              if (startLocation?.coordinates.isNotEmpty == true)
                                Text(
                                  '${startLocation!.coordinates[1].toStringAsFixed(4)}°N, ${startLocation.coordinates[0].toStringAsFixed(4)}°E',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Via Routes
                  if (trip.viaRoutes != null && trip.viaRoutes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...trip.viaRoutes!.map(
                      (via) => Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(Icons.route_rounded, size: 16, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('VIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(via.address ?? 'Via Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  // End Location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100.withOpacity(0.3)]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade600, Colors.red.shade700]), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on_rounded, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.red.shade700, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                endLocation?.address ?? trip.dropLocation ?? 'Destination',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              if (endLocation?.coordinates.isNotEmpty == true)
                                Text(
                                  '${endLocation!.coordinates[1].toStringAsFixed(4)}°N, ${endLocation.coordinates[0].toStringAsFixed(4)}°E',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trip Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Title', trip.title, Icons.title_outlined),
                  const SizedBox(height: 12),
                  _buildInfoRow('Description', trip.description, Icons.description_outlined),
                  const SizedBox(height: 12),
                  _buildInfoRow('Start Date & Time', _formatDateTime(trip.tripStartDate), Icons.calendar_today_outlined),
                  const SizedBox(height: 12),
                  _buildInfoRow('End Date & Time', _formatDateTime(trip.tripEndDate), Icons.event_outlined),
                  if (trip.distance != null) ...[const SizedBox(height: 12), _buildInfoRow('Distance', trip.distance!.text, Icons.route_rounded)],
                  if (trip.duration != null) ...[const SizedBox(height: 12), _buildInfoRow('Duration', trip.duration!.text, Icons.access_time_rounded)],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vehicle & Driver Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle & Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  if (trip.vehicleDetails != null) ...[
                    _buildInfoRow('Vehicle Number', trip.vehicleDetails!.vehicleNumber, Icons.local_shipping_outlined),
                    const SizedBox(height: 12),
                    _buildInfoRow('Vehicle Type', trip.vehicleDetails!.vehicleType, Icons.category_outlined),
                    const SizedBox(height: 12),
                    _buildInfoRow('Body Type', trip.vehicleDetails!.vehicleBodyType, Icons.directions_car_outlined),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow('Self Drive', trip.selfDrive == true ? 'Yes' : 'No', Icons.drive_eta_outlined),
                  if (trip.driver != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Driver', trip.driver!.name, Icons.person_outlined),
                    const SizedBox(height: 12),
                    _buildInfoRow('Driver Phone', trip.driver!.phone, Icons.phone_outlined),
                  ],
                  if (trip.tripAddedBy != null) ...[const SizedBox(height: 12), _buildInfoRow('Trip Created By', trip.tripAddedBy!.name, Icons.person_add_outlined)],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Goods Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goods Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  if (trip.goodsTypeDetails != null) ...[
                    _buildInfoRow('Goods Type', trip.goodsTypeDetails!.name, Icons.inventory_2_outlined),
                    if (trip.goodsTypeDetails!.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow('Description', trip.goodsTypeDetails!.description, Icons.info_outlined),
                    ],
                  ],
                  if (trip.weight != null) ...[const SizedBox(height: 12), _buildInfoRow('Weight', '${trip.weight} kg', Icons.scale_outlined)],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Post Type', trip.postType ?? 'N/A', Icons.category_outlined),
                  const SizedBox(height: 12),
                  _buildInfoRow('Created At', _formatDateTime(trip.createdAt), Icons.calendar_today_outlined),
                  if (trip.updatedAt != null) ...[const SizedBox(height: 12), _buildInfoRow('Last Updated', _formatDateTime(trip.updatedAt), Icons.update_outlined)],
                  if (trip.isStarted != null) ...[const SizedBox(height: 12), _buildInfoRow('Trip Started', trip.isStarted == true ? 'Yes' : 'No', Icons.play_circle_outline)],
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
