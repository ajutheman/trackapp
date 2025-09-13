import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'package:truck_app/features/post/screens/map_point_selector.dart';

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

  // State for date and time pickers
  DateTime? _selectedTripDate;
  TimeOfDay? _selectedStartTime;

  // Placeholder for map coordinates (in a real app, this would come from a map picker)
  String? _startLocationCoordinates;
  String? _destinationCoordinates;

  LatLng? startLocation;
  LatLng? endLocation;

  @override
  void dispose() {
    _startLocationAddressController.dispose();
    _destinationAddressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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

  // Function to handle form submission
  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields

      // In a real app, you would send this data to your backend
      print('New Post Details:');
      print('Start Location Address: ${_startLocationAddressController.text}');
      print('Start Location Coordinates: ${_startLocationCoordinates ?? 'N/A'}');
      print('Destination Address: ${_destinationAddressController.text}');
      print('Destination Coordinates: ${_destinationCoordinates ?? 'N/A'}');
      print('Trip Date: ${_selectedTripDate != null ? DateFormat('yyyy-MM-dd').format(_selectedTripDate!) : 'N/A'}');
      print('Start Time: ${_selectedStartTime != null ? _selectedStartTime!.format(context) : 'N/A'}');
      print('Title: ${_titleController.text}');
      print('Description: ${_descriptionController.text}');

      _showSnackBar('Post added successfully!');
      // Optionally clear fields or navigate away
      _formKey.currentState!.reset();
      setState(() {
        _selectedTripDate = null;
        _selectedStartTime = null;
        _startLocationCoordinates = null;
        _destinationCoordinates = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Post', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                label: 'Map Coordinates (Placeholder)',
                coordinates: _startLocationCoordinates,
                onTap: () async {
                  // // In a real app, this would open a map picker
                  // setState(() {
                  //   _startLocationCoordinates = '8.5241° N, 76.9366° E'; // Mock coordinates
                  // });
                  // _showSnackBar('Map picker for Start Location would open here!');
                  LatLng location = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPointSelector()));
                  setState(() {
                    startLocation = location;
                    _startLocationCoordinates = formatLatLng(location);
                  });
                },
              ),
              const SizedBox(height: 30),

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
                label: 'Map Coordinates (Placeholder)',
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

              Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildDatePickerField(label: 'Trip Date', selectedDate: _selectedTripDate, onTap: () => _selectTripDate(context)),
              const SizedBox(height: 16),
              _buildTimePickerField(label: 'Start Time', selectedTime: _selectedStartTime, onTap: () => _selectStartTime(context)),
              const SizedBox(height: 30),

              Text('Post Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Need truck for furniture transport',
                icon: Icons.title_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for your post';
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
                    return 'Please enter a description for your post';
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
                  label: const Text('Submit Post', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  String formatLatLng(LatLng location) {
    String latDirection = location.latitude >= 0 ? 'N' : 'S';
    String lngDirection = location.longitude >= 0 ? 'E' : 'W';

    // Use absolute values to avoid negative signs
    String lat = location.latitude.abs().toStringAsFixed(4);
    String lng = location.longitude.abs().toStringAsFixed(4);

    return '$lat° $latDirection, $lng° $lngDirection';
  }
}
