import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart';
import 'package:truck_app/features/vehicle/screens/add_vehicle_screen.dart';
import 'package:truck_app/features/vehicle/screens/vehicle_details_screen.dart';
import 'package:truck_app/features/vehicle/widgets/vehicle_card.dart';

import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../bloc/vehicle/vehicle_state.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  // Dummy list of vehicles for demonstration

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data or fetch from a service
    context.read<VehicleBloc>().add(GetVehicles());
  }

  void _navigateToVehicleDetails(Vehicle vehicle) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleDetailsScreen(vehicle: vehicle)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Vehicles', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehicleListFailure) {
            return Center(child: Text(state.error));
          } else if (state is VehicleListSuccess) {
            final vehicles = state.vehicles;
            if (vehicles.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return VehicleCard(vehicle: vehicle, onTap: () => _navigateToVehicleDetails(vehicle));
              },
            );
          } else {
            return _buildEmptyState(); // fallback
          }
        },
      ),
      floatingActionButton: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleListSuccess && state.vehicles.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () async {
                Navigator.push<Vehicle>(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.truck, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No vehicles added yet.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.push<Vehicle>(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
            },
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            label: const Text('Add First Vehicle', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
