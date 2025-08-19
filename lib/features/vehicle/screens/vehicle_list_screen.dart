import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:truck_app/core/constants/dummy_data.dart'; // Assuming you have a DummyData class
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart';
import 'package:truck_app/features/vehicle/screens/add_vehicle_screen.dart';
import 'package:truck_app/features/vehicle/screens/vehicle_details_screen.dart';
import 'package:truck_app/features/vehicle/widgets/vehicle_card.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  // Dummy list of vehicles for demonstration
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data or fetch from a service
    _vehicles = List.from(DummyData.driverVehicles);
  }

  void _addVehicle(Vehicle newVehicle) {
    setState(() {
      _vehicles.add(newVehicle);
    });
    _showSnackBar('Vehicle ${newVehicle.vehicleNumber} added successfully!');
  }

  void _navigateToVehicleDetails(Vehicle vehicle) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleDetailsScreen(vehicle: vehicle)));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
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
      body:
          _vehicles.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.truck, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No vehicles added yet.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final newVehicle = await Navigator.push<Vehicle>(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
                        if (newVehicle != null) {
                          _addVehicle(newVehicle);
                        }
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
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return VehicleCard(vehicle: vehicle, onTap: () => _navigateToVehicleDetails(vehicle));
                },
              ),
      floatingActionButton:
          _vehicles.isNotEmpty
              ? FloatingActionButton(
                onPressed: () async {
                  final newVehicle = await Navigator.push<Vehicle>(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
                  if (newVehicle != null) {
                    _addVehicle(newVehicle);
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              )
              : null,
    );
  }
}
