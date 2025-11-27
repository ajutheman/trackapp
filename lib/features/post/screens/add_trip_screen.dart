import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/features/post/screens/map_point_selector.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/home/utils/posts_api_helper.dart';
import 'package:truck_app/features/vehicle/repo/vehicle_repo.dart';
import 'package:truck_app/features/vehicle/repo/vehicle_metadata_repo.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart' as VehicleModel;
import 'package:truck_app/features/vehicle/model/vehicle_metadata.dart';
import 'package:truck_app/services/network/api_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../di/locator.dart';
import '../../../core/utils/error_display.dart';
import '../../../model/network/result.dart';

class AddTripScreen extends StatefulWidget {
  final Post? postToEdit; // If provided, screen will be in edit mode

  const AddTripScreen({super.key, this.postToEdit});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _startLocationAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Dropdown selections (using IDs as required by backend)
  String? _selectedVehicleId;
  String? _selectedDriverId;
  String? _selectedGoodsTypeId;

  // Dropdown data
  List<VehicleModel.Vehicle> _vehicles = [];
  List<GoodsAccepted> _goodsTypes = [];
  List<Map<String, dynamic>> _drivers = []; // Contains {_id, name, phone, isSelfDrive}

  bool _isLoadingData = false;

  // State for date and time pickers (combined)
  DateTime? _selectedTripStartDateTime;
  DateTime? _selectedTripEndDateTime;

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
  void initState() {
    super.initState();
    // Load dropdown data first, then populate form if editing
    _loadDropdownData().then((_) {
      if (widget.postToEdit != null && mounted) {
        _populateFormFromPost(widget.postToEdit!);
      }
    });
  }

  void _populateFormFromPost(Post post) {
    // Populate text fields
    _titleController.text = post.title;
    _descriptionController.text = post.description;
    if (post.weight != null) {
      _weightController.text = post.weight.toString();
    }

    // Populate locations
    // Note: TripLocation coordinates are [lng, lat], but LatLng expects (lat, lng)
    if (post.tripStartLocation != null) {
      _startLocationAddressController.text = post.tripStartLocation!.address ?? '';
      if (post.tripStartLocation!.coordinates.length >= 2) {
        // coordinates[0] is lng, coordinates[1] is lat
        startLocation = LatLng(post.tripStartLocation!.coordinates[1], post.tripStartLocation!.coordinates[0]);
        _startLocationCoordinates = formatLatLng(startLocation!);
      }
    }

    if (post.tripDestination != null) {
      _destinationAddressController.text = post.tripDestination!.address ?? '';
      if (post.tripDestination!.coordinates.length >= 2) {
        // coordinates[0] is lng, coordinates[1] is lat
        endLocation = LatLng(post.tripDestination!.coordinates[1], post.tripDestination!.coordinates[0]);
        _destinationCoordinates = formatLatLng(endLocation!);
      }
    }

    // Populate dates
    _selectedTripStartDateTime = post.tripStartDate;
    _selectedTripEndDateTime = post.tripEndDate;

    // Populate dropdowns (will be set after data loads)
    if (post.vehicleDetails != null) {
      _selectedVehicleId = post.vehicleDetails!.id;
    }
    if (post.goodsTypeDetails != null) {
      _selectedGoodsTypeId = post.goodsTypeDetails!.id;
    }
    if (post.driver != null) {
      _selectedDriverId = post.driver!.id;
    }

    // Populate other fields
    _isSelfDrive = post.selfDrive ?? true;
    _postType = post.postType ?? 'load';
    _viaRoutes = post.viaRoutes ?? [];
    _distance = post.distance?.value;
    _duration = post.duration?.value;
  }

  @override
  void dispose() {
    _startLocationAddressController.dispose();
    _destinationAddressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);
    try {
      // Load vehicles
      final vehicleRepo = VehicleRepository(apiService: locator<ApiService>());
      final vehiclesResult = await vehicleRepo.getVehicles();
      if (vehiclesResult.isSuccess) {
        if (mounted) {
          setState(() => _vehicles = vehiclesResult.data ?? []);
          // Only auto-select if not editing or if editing but vehicle not set
          if (_vehicles.isNotEmpty && _selectedVehicleId == null) {
            _selectedVehicleId = _vehicles.first.id;
          }
        }
      } else {
        if (mounted) {
          _showSnackBar('Failed to load vehicles: ${vehiclesResult.message}');
        }
      }

      // Load goods types
      final goodsRepo = VehicleMetaRepository(apiService: locator<ApiService>());
      final goodsResult = await goodsRepo.getAllGoodsAccepted();
      if (mounted) {
        setState(() => _goodsTypes = goodsResult);
        // Only auto-select if not editing or if editing but goods type not set
        if (_goodsTypes.isNotEmpty && _selectedGoodsTypeId == null) {
          _selectedGoodsTypeId = _goodsTypes.first.id;
        }
      }

      // Load drivers (friends list from driver-connections API)
      await _loadDrivers();

      // Auto-select driver if self-drive is enabled
      if (mounted && _isSelfDrive && _drivers.isNotEmpty) {
        final selfDriveDriver = _drivers.firstWhere((d) => d['isSelfDrive'] == true, orElse: () => _drivers.first);
        setState(() {
          _selectedDriverId = selfDriveDriver['_id'];
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadDrivers() async {
    try {
      final apiService = locator<ApiService>();
      final result = await apiService.get('api/v1/driver-connections/friends', isTokenRequired: true);
      if (result.isSuccess) {
        final data = result.data;
        if (data is Map && data['friends'] != null) {
          if (mounted) {
            setState(() => _drivers = List<Map<String, dynamic>>.from(data['friends']));
            if (_drivers.isNotEmpty && _selectedDriverId == null) {
              // Auto-select self-drive option if available
              final selfDrive = _drivers.firstWhere((d) => d['isSelfDrive'] == true, orElse: () => _drivers.first);
              _selectedDriverId = selfDrive['_id'];
            }
          }
        }
      } else {
        // If friends API fails, we'll still allow self-drive
        // Add current user as self-drive option
        if (mounted && _drivers.isEmpty) {
          // This will be handled by the UI - user can still create trip
        }
      }
    } catch (e) {
      // If friends API fails, we'll still allow self-drive
      print('Error loading drivers: $e');
      // Don't show error to user as this is not critical
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  // Function to pick trip start date and time
  Future<void> _selectTripStartDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedTripStartDateTime ?? now.add(const Duration(hours: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
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

    if (picked != null) {
      // After date is selected, pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTripStartDateTime != null ? TimeOfDay.fromDateTime(_selectedTripStartDateTime!) : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
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

      if (pickedTime != null) {
        setState(() {
          _selectedTripStartDateTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  // Function to pick trip end date and time
  Future<void> _selectTripEndDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedTripEndDateTime ?? (_selectedTripStartDateTime?.add(const Duration(hours: 4)) ?? now.add(const Duration(hours: 5)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _selectedTripStartDateTime ?? now,
      lastDate: now.add(const Duration(days: 365 * 2)),
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

    if (picked != null) {
      // After date is selected, pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTripEndDateTime != null ? TimeOfDay.fromDateTime(_selectedTripEndDateTime!) : TimeOfDay.fromDateTime(initialDate),
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

      if (pickedTime != null) {
        setState(() {
          _selectedTripEndDateTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  // Function to handle form submission
  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate required fields based on backend requirements
      if (startLocation == null || endLocation == null) {
        _showSnackBar('Please select both start and destination locations on the map');
        return;
      }

      if (_startLocationAddressController.text.trim().length < 3) {
        _showSnackBar('Start location address must be at least 3 characters');
        return;
      }

      if (_destinationAddressController.text.trim().length < 3) {
        _showSnackBar('Destination address must be at least 3 characters');
        return;
      }

      if (_selectedTripStartDateTime == null) {
        _showSnackBar('Please select trip start date and time');
        return;
      }

      // Use the selected start date and time
      final tripStartDateTime = _selectedTripStartDateTime!;

      // Validate trip start date is in the future (only for new trips)
      if (widget.postToEdit == null && tripStartDateTime.isBefore(DateTime.now())) {
        _showSnackBar('Trip start date must be in the future');
        return;
      }

      if (_selectedVehicleId == null) {
        _showSnackBar('Please select a vehicle');
        return;
      }

      if (_selectedDriverId == null) {
        _showSnackBar('Please select a driver');
        return;
      }

      if (_selectedGoodsTypeId == null) {
        _showSnackBar('Please select a goods type');
        return;
      }

      // Create trip locations with trimmed addresses
      final tripStartLocation = TripLocation(address: _startLocationAddressController.text.trim(), coordinates: [startLocation!.longitude, startLocation!.latitude]);

      final tripDestination = TripLocation(address: _destinationAddressController.text.trim(), coordinates: [endLocation!.longitude, endLocation!.latitude]);

      // Create route GeoJSON
      final routeGeoJSON = RouteGeoJSON(
        type: "LineString",
        coordinates: [
          [startLocation!.longitude, startLocation!.latitude],
          [endLocation!.longitude, endLocation!.latitude],
        ],
      );

      DateTime tripEndDateTime;
      if (_selectedTripEndDateTime != null) {
        tripEndDateTime = _selectedTripEndDateTime!;
        // Validate end date is after start date
        if (tripEndDateTime.isBefore(tripStartDateTime) || tripEndDateTime.isAtSameMomentAs(tripStartDateTime)) {
          _showSnackBar('Trip end date must be after start date');
          return;
        }
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

      // Check if we're editing or creating
      if (widget.postToEdit != null && widget.postToEdit!.id != null) {
        // Update existing trip
        context.read<PostsBloc>().add(
          UpdatePost(
            postId: widget.postToEdit!.id!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            tripStartLocation: tripStartLocation,
            tripDestination: tripDestination,
            viaRoutes: _viaRoutes.isNotEmpty ? _viaRoutes : null,
            routeGeoJSON: routeGeoJSON,
            vehicle: _selectedVehicleId!,
            selfDrive: _isSelfDrive,
            driver: _selectedDriverId!,
            distance: distance,
            duration: duration,
            goodsTypeId: _selectedGoodsTypeId!,
            weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
            tripStartDate: tripStartDateTime,
            tripEndDate: tripEndDateTime,
          ),
        );
      } else {
        // Create new trip
        PostsApiHelper.createPost(
          context: context,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          tripStartLocation: tripStartLocation,
          tripDestination: tripDestination,
          viaRoutes: _viaRoutes.isNotEmpty ? _viaRoutes : null,
          routeGeoJSON: routeGeoJSON,
          vehicle: _selectedVehicleId!,
          selfDrive: _isSelfDrive,
          driver: _selectedDriverId!,
          distance: distance,
          duration: duration,
          goodsTypeId: _selectedGoodsTypeId!,
          weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
          tripStartDate: tripStartDateTime,
          tripEndDate: tripEndDateTime,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.postToEdit != null ? 'Edit Trip' : 'Add New Trip', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : BlocConsumer<PostsBloc, PostsState>(
                listenWhen: (previous, current) {
                  // Only listen when transitioning TO PostCreated, PostUpdated or PostsError
                  // This prevents multiple listeners from firing
                  return (previous is! PostCreated && current is PostCreated) ||
                      (previous is! PostUpdated && current is PostUpdated) ||
                      (previous is! PostsError && current is PostsError);
                },
                listener: (context, state) {
                  if (state is PostCreated) {
                    // Only handle navigation if this screen is still mounted and active
                    final route = ModalRoute.of(context);
                    if (!mounted || route == null || !route.isCurrent) {
                      return; // Don't navigate if screen is not active
                    }
                    // Show success message and navigate back after a short delay
                    _showSnackBar('Trip created successfully!');
                    // Use a delayed navigation to ensure snackbar is shown and widget is still mounted
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted && context.mounted) {
                        final currentRoute = ModalRoute.of(context);
                        if (currentRoute != null && currentRoute.isCurrent) {
                          Navigator.of(context).pop(true); // Return true to indicate success
                        }
                      }
                    });
                  } else if (state is PostUpdated) {
                    // Only handle navigation if this screen is still mounted and active
                    final route = ModalRoute.of(context);
                    if (!mounted || route == null || !route.isCurrent) {
                      return; // Don't navigate if screen is not active
                    }
                    // Show success message and navigate back after a short delay
                    _showSnackBar('Trip updated successfully!');
                    // Use a delayed navigation to ensure snackbar is shown and widget is still mounted
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted && context.mounted) {
                        final currentRoute = ModalRoute.of(context);
                        if (currentRoute != null && currentRoute.isCurrent) {
                          Navigator.of(context).pop(true); // Return true to indicate success
                        }
                      }
                    });
                  } else if (state is PostsError) {
                    // Only show error if screen is still active
                    final route = ModalRoute.of(context);
                    if (mounted && route != null && route.isCurrent) {
                      showErrorSnackBar(context, state.message);
                    }
                  }
                },
                buildWhen: (previous, current) => !(current is PostCreated || current is PostUpdated || current is PostsError),
                builder: (context, state) {
                  return SingleChildScrollView(
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
                              if (value.trim().length < 3) {
                                return 'Address must be at least 3 characters';
                              }
                              if (value.trim().length > 200) {
                                return 'Address must not exceed 200 characters';
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
                              if (value.trim().length < 3) {
                                return 'Address must be at least 3 characters';
                              }
                              if (value.trim().length > 200) {
                                return 'Address must not exceed 200 characters';
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
                          _buildDateTimePickerField(label: 'Start Date & Time *', selectedDateTime: _selectedTripStartDateTime, onTap: () => _selectTripStartDateTime(context)),
                          const SizedBox(height: 16),
                          _buildDateTimePickerField(label: 'End Date & Time (Optional)', selectedDateTime: _selectedTripEndDateTime, onTap: () => _selectTripEndDateTime(context)),
                          const SizedBox(height: 30),

                          // Vehicle & Driver Section
                          Text('Vehicle & Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _buildVehicleDropdown(),
                          const SizedBox(height: 16),
                          _buildSelfDriveToggle(),
                          const SizedBox(height: 16),
                          _buildDriverDropdown(),
                          const SizedBox(height: 30),

                          // Goods & Weight Section
                          Text('Goods & Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _buildGoodsTypeDropdown(),
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
                                if (weight == null) {
                                  return 'Please enter a valid weight';
                                }
                                if (weight < 0.1) {
                                  return 'Weight must be at least 0.1 kg';
                                }
                                if (weight > 100) {
                                  return 'Weight must not exceed 100 kg';
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
                              if (value.trim().length < 5) {
                                return 'Title must be at least 5 characters';
                              }
                              if (value.trim().length > 200) {
                                return 'Title must not exceed 200 characters';
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
                              if (value.trim().length > 500) {
                                return 'Description must not exceed 500 characters';
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
                              icon: Icon(widget.postToEdit != null ? Icons.save_rounded : Icons.send_rounded, color: Colors.white),
                              label: Text(widget.postToEdit != null ? 'Update Trip' : 'Create Trip', style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                  );
                },
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

  // Widget for date and time picker field (combined)
  Widget _buildDateTimePickerField({required String label, required DateTime? selectedDateTime, required VoidCallback onTap}) {
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
                    selectedDateTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(selectedDateTime) : 'Select Date & Time',
                    style: TextStyle(color: selectedDateTime != null ? AppColors.textPrimary : AppColors.textSecondary),
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
          Switch(
            value: _isSelfDrive,
            onChanged: (value) {
              setState(() {
                _isSelfDrive = value;
                // Auto-select self-drive driver when toggled on
                if (value && _drivers.isNotEmpty) {
                  final selfDriveDriver = _drivers.firstWhere((d) => d['isSelfDrive'] == true, orElse: () => _drivers.first);
                  _selectedDriverId = selfDriveDriver['_id'];
                }
              });
            },
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  // Widget for vehicle dropdown
  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedVehicleId,
            decoration: InputDecoration(
              hintText: 'Select Vehicle',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.local_shipping_outlined, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items:
                _vehicles.map((vehicle) {
                  return DropdownMenuItem<String>(
                    value: vehicle.id,
                    child: Text('${vehicle.vehicleNumber} - ${vehicle.type}', style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedVehicleId = value),
            validator: (value) => value == null ? 'Please select a vehicle' : null,
          ),
        ),
      ],
    );
  }

  // Widget for driver dropdown
  Widget _buildDriverDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Driver *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDriverId,
            decoration: InputDecoration(
              hintText: 'Select Driver',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items:
                _drivers.map((driver) {
                  return DropdownMenuItem<String>(
                    value: driver['_id'],
                    child: Text(
                      driver['name'] ?? 'Unknown',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: driver['isSelfDrive'] == true ? FontWeight.bold : FontWeight.normal),
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedDriverId = value),
            validator: (value) => value == null ? 'Please select a driver' : null,
          ),
        ),
      ],
    );
  }

  // Widget for goods type dropdown
  Widget _buildGoodsTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Goods Type *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGoodsTypeId,
            decoration: InputDecoration(
              hintText: 'Select Goods Type',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.inventory_outlined, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items:
                _goodsTypes.map((goods) {
                  return DropdownMenuItem<String>(value: goods.id, child: Text(goods.name, style: const TextStyle(color: AppColors.textPrimary)));
                }).toList(),
            onChanged: (value) => setState(() => _selectedGoodsTypeId = value),
            validator: (value) => value == null ? 'Please select a goods type' : null,
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
