import 'package:flutter/material.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(
                getVehicleTypeIcon(vehicle.type), // Using the extension for the icon
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.vehicleNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.type} - ${vehicle.bodyType}', // Using extensions for names
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text('Capacity: ${vehicle.capacity} tons', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  if (vehicle.goodsAccepted.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Goods: ${vehicle.goodsAccepted.join(', ')}',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
