import 'package:flutter/material.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/utils/posts_api_helper.dart';

/// Example usage of the new trip creation API
class TripCreationExample {
  /// Example: Create a trip with the exact structure you provided
  static Future<void> createVegetableDeliveryTrip(BuildContext context) async {
    // Create trip start location
    final tripStartLocation = TripLocation(
      address: "Pathanamthitta Bus Stand, Kerala",
      coordinates: [76.7704, 9.2645], // [longitude, latitude]
    );

    // Create trip destination
    final tripDestination = TripLocation(address: "Ernakulam South Railway Station, Kochi, Kerala", coordinates: [76.2875, 9.9674]);

    // Create via routes
    final viaRoutes = [
      TripLocation(address: "Kottayam, Kerala", coordinates: [76.5212, 9.5916]),
      TripLocation(address: "Aluva, Kerala", coordinates: [76.3516, 10.1076]),
    ];

    // Create route GeoJSON
    final routeGeoJSON = RouteGeoJSON(
      type: "LineString",
      coordinates: [
        [76.7704, 9.2645], // Start
        [76.5212, 9.5916], // Via Kottayam
        [76.3516, 10.1076], // Via Aluva
        [76.2875, 9.9674], // End
      ],
    );

    // Create distance
    final distance = Distance(value: 135.5, text: "135.5 km");

    // Create duration
    final duration = TripDuration(
      value: 150, // minutes
      text: "2 hours 30 mins",
    );

    // Create trip dates
    final tripStartDate = DateTime.parse("2025-08-26T09:00:00.000Z");
    final tripEndDate = DateTime.parse("2025-08-26T13:30:00.000Z");

    // Create the trip using the API helper
    await PostsApiHelper.createPost(
      context: context,
      title: "Fresh Vegetables Delivery to Kochi",
      description: "Transporting fresh vegetables from Pathanamthitta to Kochi via Kottayam.",
      postType: "load", // or "truck"
      // Trip-specific data
      tripStartLocation: tripStartLocation,
      tripDestination: tripDestination,
      viaRoutes: viaRoutes,
      routeGeoJSON: routeGeoJSON,
      vehicle: "68ac5e670d66969b0f50b125", // Vehicle ID
      selfDrive: true,
      driver: "68ac5aba31cc29079926f2d9", // Driver ID
      distance: distance,
      duration: duration,
      goodsTypeId: "684aa733b88048daeaebff93", // Goods type ID
      weight: 25.0,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
    );
  }

  /// Example: Create a simple trip with minimal data
  static Future<void> createSimpleTrip(BuildContext context) async {
    await PostsApiHelper.createPost(
      context: context,
      title: "Simple Transport Request",
      description: "Basic transport request from A to B",
      postType: "load",
      pickupLocation: "Kochi",
      dropLocation: "Bangalore",
      goodsType: "Electronics",
      weight: 10.0,
    );
  }

  /// Example: Create a trip with custom route
  static Future<void> createCustomRouteTrip(BuildContext context) async {
    final startLocation = TripLocation(address: "Mumbai, Maharashtra", coordinates: [72.8777, 19.0760]);

    final endLocation = TripLocation(address: "Delhi, Delhi", coordinates: [77.1025, 28.7041]);

    final viaRoute = TripLocation(address: "Jaipur, Rajasthan", coordinates: [75.7873, 26.9124]);

    final customRoute = RouteGeoJSON(
      type: "LineString",
      coordinates: [
        [72.8777, 19.0760], // Mumbai
        [75.7873, 26.9124], // Jaipur
        [77.1025, 28.7041], // Delhi
      ],
    );

    final tripDistance = Distance(value: 1200.0, text: "1200 km");

    final tripDuration = TripDuration(
      value: 720, // 12 hours
      text: "12 hours",
    );

    await PostsApiHelper.createPost(
      context: context,
      title: "Mumbai to Delhi via Jaipur",
      description: "Long distance transport with custom route",
      postType: "truck",
      tripStartLocation: startLocation,
      tripDestination: endLocation,
      viaRoutes: [viaRoute],
      routeGeoJSON: customRoute,
      vehicle: "vehicle_id_here",
      selfDrive: false,
      driver: "driver_id_here",
      distance: tripDistance,
      duration: tripDuration,
      goodsTypeId: "goods_type_id_here",
      weight: 50.0,
      tripStartDate: DateTime.now().add(const Duration(days: 1)),
      tripEndDate: DateTime.now().add(const Duration(days: 2)),
    );
  }
}

/// Widget example showing how to use the trip creation in a form
class TripCreationForm extends StatefulWidget {
  const TripCreationForm({super.key});

  @override
  State<TripCreationForm> createState() => _TripCreationFormState();
}

class _TripCreationFormState extends State<TripCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startAddressController = TextEditingController();
  final _endAddressController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startAddressController.dispose();
    _endAddressController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Trip Title'),
                validator: (value) => value?.isEmpty == true ? 'Please enter title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startAddressController,
                decoration: const InputDecoration(labelText: 'Start Address'),
                validator: (value) => value?.isEmpty == true ? 'Please enter start address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endAddressController,
                decoration: const InputDecoration(labelText: 'End Address'),
                validator: (value) => value?.isEmpty == true ? 'Please enter end address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Please enter weight' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _createTrip, child: const Text('Create Trip')),
            ],
          ),
        ),
      ),
    );
  }

  void _createTrip() {
    if (_formKey.currentState?.validate() == true) {
      // Create trip with form data
      final startLocation = TripLocation(
        address: _startAddressController.text,
        coordinates: [0.0, 0.0], // You would get these from geocoding
      );

      final endLocation = TripLocation(
        address: _endAddressController.text,
        coordinates: [0.0, 0.0], // You would get these from geocoding
      );

      PostsApiHelper.createPost(
        context: context,
        title: _titleController.text,
        description: _descriptionController.text,
        postType: "load",
        tripStartLocation: startLocation,
        tripDestination: endLocation,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        tripStartDate: DateTime.now().add(const Duration(days: 1)),
        tripEndDate: DateTime.now().add(const Duration(days: 2)),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip created successfully!')));
    }
  }
}
