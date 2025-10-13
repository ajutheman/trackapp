import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
giimport 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'package:truck_app/features/post/screens/map_point_selector.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/home/utils/posts_api_helper.dart';

// Assuming AppColors is defined in this path
import '../../../core/theme/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _startLocationAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();
  final TextEditingController _goodsTypeController = TextEditingController();

  // State for date and time pickers
  DateTime? _selectedTripDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedTripEndDate;
  TimeOfDay? _selectedEndTime;

  // Placeholder for map coordinates (in a real app, this would come from a map picker)
  String? _startLocationCoordinates;
  String? _destinationCoordinates;

  LatLng? startLocation;
  LatLng? endLocation;

  // Additional trip data
  bool _isSelfDrive = true;
  String? _postType = 'load';
  List<TripLocation> _viaRoutes = [];
  double? _distance;
  int? _duration; // in minutes

  @override
  void dispose() {
    _startLocationAddressController.dispose();
    _destinationAddressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _vehicleController.dispose();
    _driverController.dispose();
    _goodsTypeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  // Function to pick trip date
  Future<void> _selectTripDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTripDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      // 2 years from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textPrimary, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTripDate) {
      setState(() {
        _selectedTripDate = picked;
      });
    }
  }

  // Function to pick start time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textPrimary, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  // Function to pick trip end date
  Future<void> _selectTripEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTripEndDate ?? (_selectedTripDate ?? DateTime.now()),
      firstDate: _selectedTripDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.secondary, onPrimary: Colors.white, onSurface: AppColors.textPrimary),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.secondary)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTripEndDate) {
      setState(() {
        _selectedTripEndDate = picked;
      });
    }
  }

  // Function to pick end time
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.secondary, onPrimary: Colors.white, onSurface: AppColors.textPrimary),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.secondary)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  // Function to handle form submission
  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields

      // Validate required fields
      if (startLocation == null || endLocation == null) {
        _showSnackBar('Please select both start and destination locations on the map');
        return;
      }

      if (_selectedTripDate == null || _selectedStartTime == null) {
        _showSnackBar('Please select trip start date and time');
        return;
      }

      // Create trip locations
      final tripStartLocation = TripLocation(address: _startLocationAddressController.text, coordinates: [startLocation!.longitude, startLocation!.latitude]);

      final tripDestination = TripLocation(address: _destinationAddressController.text, coordinates: [endLocation!.longitude, endLocation!.latitude]);

      // Create route GeoJSON
      final routeGeoJSON = RouteGeoJSON(
        type: "LineString",
        coordinates: [
          [startLocation!.longitude, startLocation!.latitude],
          [endLocation!.longitude, endLocation!.latitude],
        ],
      );

      // Calculate trip dates
      final tripStartDateTime = DateTime(_selectedTripDate!.year, _selectedTripDate!.month, _selectedTripDate!.day, _selectedStartTime!.hour, _selectedStartTime!.minute);

      DateTime? tripEndDateTime;
      if (_selectedTripEndDate != null && _selectedEndTime != null) {
        tripEndDateTime = DateTime(_selectedTripEndDate!.year, _selectedTripEndDate!.month, _selectedTripEndDate!.day, _selectedEndTime!.hour, _selectedEndTime!.minute);
      } else {
        // Default to 4 hours after start time if end time not specified
        tripEndDateTime = tripStartDateTime.add(const Duration(hours: 4));
      }

      // Create distance and duration (you can calculate these based on coordinates)
      final distance = Distance(
        value: _distance ?? _calculateDistance(startLocation!, endLocation!),
        text: "${(_distance ?? _calculateDistance(startLocation!, endLocation!)).toStringAsFixed(1)} km",
      );

      final duration = TripDuration(
        value: _duration ?? _calculateDuration(tripStartDateTime, tripEndDateTime),
        text: _formatDuration(_duration ?? _calculateDuration(tripStartDateTime, tripEndDateTime)),
      );

      // Create the trip using the API
      PostsApiHelper.createPost(
        context: context,
        title: _titleController.text,
        description: _descriptionController.text,
        postType: _postType,
        tripStartLocation: tripStartLocation,
        tripDestination: tripDestination,
        viaRoutes: _viaRoutes.isNotEmpty ? _viaRoutes : null,
        routeGeoJSON: routeGeoJSON,
        vehicle: _vehicleController.text.isNotEmpty ? _vehicleController.text : null,
        selfDrive: _isSelfDrive,
        driver: _driverController.text.isNotEmpty ? _driverController.text : null,
        distance: distance,
        duration: duration,
        goodsTypeId: _goodsTypeController.text.isNotEmpty ? _goodsTypeController.text : null,
        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        tripStartDate: tripStartDateTime,
        tripEndDate: tripEndDateTime,
      );

      _showSnackBar('Trip created successfully!');

      // Clear form
      _clearForm();
    }
  }

  // Helper method to calculate distance between two points (simplified)
  double _calculateDistance(LatLng start, LatLng end) {
    // This is a simplified calculation - in a real app you'd use proper distance calculation
    final latDiff = (start.latitude - end.latitude).abs();
    final lngDiff = (start.longitude - end.longitude).abs();
    return (latDiff + lngDiff) * 111; // Rough conversion to km
  }

  // Helper method to calculate duration
  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  // Helper method to format duration
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '$hours hours $mins mins' : '$hours hours';
    }
    return '$mins mins';
  }

  // Helper method to clear form
  void _clearForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedTripDate = null;
      _selectedStartTime = null;
      _selectedTripEndDate = null;
      _selectedEndTime = null;
      _startLocationCoordinates = null;
      _destinationCoordinates = null;
      startLocation = null;
      endLocation = null;
      _viaRoutes.clear();
      _distance = null;
      _duration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Trip', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostCreated) {
            _showSnackBar('Trip created successfully!');
            _clearForm();
          } else if (state is PostsError) {
            _showSnackBar('Error: ${state.message}');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Type Selection
                Text('Trip Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildPostTypeSelector(),
                const SizedBox(height: 30),

                // Start Location Section
                Text('Start Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _startLocationAddressController,
                  label: 'Address',
                  hint: 'e.g., Thiruvananthapuram, Kerala',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter start location address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildMapCoordinatesField(
                  label: 'Map Coordinates',
                  coordinates: _startLocationCoordinates,
                  onTap: () async {
                    LatLng location = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPointSelector()));
                    setState(() {
                      startLocation = location;
                      _startLocationCoordinates = formatLatLng(location);
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Destination Section
                Text('Destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _destinationAddressController,
                  label: 'Address',
                  hint: 'e.g., Kanyakumari, Tamil Nadu',
                  icon: Icons.flag_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter destination address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildMapCoordinatesField(
                  label: 'Map Coordinates',
                  coordinates: _destinationCoordinates,
                  onTap: () async {
                    LatLng location = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPointSelector()));
                    setState(() {
                      endLocation = location;
                      _destinationCoordinates = formatLatLng(location);
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Trip Details Section
                Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildDatePickerField(label: 'Start Date', selectedDate: _selectedTripDate, onTap: () => _selectTripDate(context)),
                const SizedBox(height: 16),
                _buildTimePickerField(label: 'Start Time', selectedTime: _selectedStartTime, onTap: () => _selectStartTime(context)),
                const SizedBox(height: 16),
                _buildDatePickerField(label: 'End Date (Optional)', selectedDate: _selectedTripEndDate, onTap: () => _selectTripEndDate(context)),
                const SizedBox(height: 16),
                _buildTimePickerField(label: 'End Time (Optional)', selectedTime: _selectedEndTime, onTap: () => _selectEndTime(context)),
                const SizedBox(height: 30),

                // Vehicle & Driver Section
                Text('Vehicle & Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInputField(controller: _vehicleController, label: 'Vehicle ID (Optional)', hint: 'e.g., 68ac5e670d66969b0f50b125', icon: Icons.local_shipping_outlined),
                const SizedBox(height: 16),
                _buildInputField(controller: _driverController, label: 'Driver ID (Optional)', hint: 'e.g., 68ac5aba31cc29079926f2d9', icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildSelfDriveToggle(),
                const SizedBox(height: 30),

                // Goods & Weight Section
                Text('Goods & Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInputField(controller: _goodsTypeController, label: 'Goods Type ID (Optional)', hint: 'e.g., 684aa733b88048daeaebff93', icon: Icons.inventory_outlined),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  hint: 'e.g., 25',
                  icon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final weight = double.tryParse(value);
                      if (weight == null || weight <= 0) {
                        return 'Please enter a valid weight';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Post Content Section
                Text('Trip Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g., Fresh Vegetables Delivery to Kochi',
                  icon: Icons.title_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title for your trip';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Provide details about the goods, size, weight, etc.',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description for your trip';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitPost,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    label: const Text('Create Trip', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: AppColors.secondary.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  // Widget for displaying map coordinates (placeholder)
  Widget _buildMapCoordinatesField({required String label, required String? coordinates, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coordinates ?? 'Tap to select on map',
                    style: TextStyle(color: coordinates != null ? AppColors.textPrimary : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for date picker field
  Widget _buildDatePickerField({required String label, required DateTime? selectedDate, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null ? DateFormat('dd MMM yyyy').format(selectedDate) : 'Select Date',
                    style: TextStyle(color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for time picker field
  Widget _buildTimePickerField({required String label, required TimeOfDay? selectedTime, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTime != null ? selectedTime.format(context) : 'Select Time',
                    style: TextStyle(color: selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for post type selector
  Widget _buildPostTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Load', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Looking for transport', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: 'load',
              groupValue: _postType,
              onChanged: (value) => setState(() => _postType = value),
              activeColor: AppColors.secondary,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Truck', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Offering transport', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: 'truck',
              groupValue: _postType,
              onChanged: (value) => setState(() => _postType = value),
              activeColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for self-drive toggle
  Widget _buildSelfDriveToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(Icons.drive_eta_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Self Drive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Text('Will you be driving yourself?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: _isSelfDrive, onChanged: (value) => setState(() => _isSelfDrive = value), activeColor: AppColors.secondary),
        ],
      ),
    );
  }

  String formatLatLng(LatLng location) {
    String latDirection = location.latitude >= 0 ? 'N' : 'S';
    String lngDirection = location.longitude >= 0 ? 'E' : 'W';

    // Use absolute values to avoid negative signs
    String lat = location.latitude.abs().toStringAsFixed(4);
    String lng = location.longitude.abs().toStringAsFixed(4);

    return '$lat° $latDirection, $lng° $lngDirection';
  }
}
