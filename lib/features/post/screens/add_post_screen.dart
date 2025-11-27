import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:truck_app/features/post/screens/map_point_selector.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/post/bloc/customer_request_bloc.dart';
import 'package:truck_app/features/post/utils/customer_request_helper.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';
import 'package:truck_app/services/network/api_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../di/locator.dart';
import '../../../core/utils/error_display.dart';
import '../../../model/network/result.dart';

class AddPostScreen extends StatefulWidget {
  final Post? postToEdit; // If provided, screen will be in edit mode

  const AddPostScreen({super.key, this.postToEdit});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _pickupLocationAddressController = TextEditingController();
  final TextEditingController _dropoffLocationAddressController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _packageDescriptionController = TextEditingController();

  // Location coordinates
  String? _pickupLocationCoordinates;
  String? _dropoffLocationCoordinates;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;

  // Date and time
  DateTime? _selectedPickupTime;

  // Images and documents
  List<File> _selectedImages = [];
  List<File> _selectedDocuments = [];
  List<String> _uploadedImageIds = [];
  List<String> _uploadedDocumentIds = [];
  List<String> _existingImageIds = []; // Existing image IDs from post being edited
  List<String> _existingDocumentIds = []; // Existing document IDs from post being edited

  // Distance and duration (will be calculated)
  double? _distance;
  int? _duration; // in minutes

  // Repositories
  late ImageUploadRepository _imageUploadRepository;
  
  // Field errors from server validation
  List<ValidationError> _fieldErrors = [];

  @override
  void initState() {
    super.initState();
    _imageUploadRepository = ImageUploadRepository(apiService: locator<ApiService>());
    
    // Populate form if editing
    if (widget.postToEdit != null) {
      _populateFormFromPost(widget.postToEdit!);
    }
  }

  // Populate form fields from existing post
  void _populateFormFromPost(Post post) {
    // Populate text fields
    _titleController.text = post.title;
    _descriptionController.text = post.description;

    // Populate locations
    if (post.pickupLocationObj != null) {
      _pickupLocationAddressController.text = post.pickupLocationObj!.address ?? '';
      if (post.pickupLocationObj!.coordinates.length >= 2) {
        // coordinates[0] is lng, coordinates[1] is lat
        pickupLocation = LatLng(
          post.pickupLocationObj!.coordinates[1],
          post.pickupLocationObj!.coordinates[0],
        );
        _pickupLocationCoordinates = formatLatLng(pickupLocation!);
      }
    }

    if (post.dropoffLocationObj != null) {
      _dropoffLocationAddressController.text = post.dropoffLocationObj!.address ?? '';
      if (post.dropoffLocationObj!.coordinates.length >= 2) {
        // coordinates[0] is lng, coordinates[1] is lat
        dropoffLocation = LatLng(
          post.dropoffLocationObj!.coordinates[1],
          post.dropoffLocationObj!.coordinates[0],
        );
        _dropoffLocationCoordinates = formatLatLng(dropoffLocation!);
      }
    }

    // Populate package details
    if (post.packageDetails != null) {
      if (post.packageDetails!.weight != null) {
        _weightController.text = post.packageDetails!.weight.toString();
      }
      if (post.packageDetails!.dimensions != null) {
        if (post.packageDetails!.dimensions!.length != null) {
          _lengthController.text = post.packageDetails!.dimensions!.length.toString();
        }
        if (post.packageDetails!.dimensions!.width != null) {
          _widthController.text = post.packageDetails!.dimensions!.width.toString();
        }
        if (post.packageDetails!.dimensions!.height != null) {
          _heightController.text = post.packageDetails!.dimensions!.height.toString();
        }
      }
      if (post.packageDetails!.description != null) {
        _packageDescriptionController.text = post.packageDetails!.description!;
      }
    }

    // Populate pickup time
    _selectedPickupTime = post.pickupTime;

    // Store existing image and document IDs
    _existingImageIds = post.images ?? [];
    _existingDocumentIds = post.documents ?? [];

    // Populate distance and duration if available
    if (post.distance != null) {
      _distance = post.distance!.value;
    }
    if (post.duration != null) {
      _duration = post.duration!.value;
    }
  }

  @override
  void dispose() {
    _pickupLocationAddressController.dispose();
    _dropoffLocationAddressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _packageDescriptionController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to pick pickup date and time
  Future<void> _selectPickupTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedPickupTime ?? now.add(const Duration(hours: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedPickupTime != null
            ? TimeOfDay.fromDateTime(_selectedPickupTime!)
            : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.secondary,
                onPrimary: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedPickupTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Function to pick images
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  // Function to pick documents
  Future<void> _pickDocuments() async {
    final ImagePicker picker = ImagePicker();
    final XFile? document = await picker.pickImage(source: ImageSource.gallery);
    if (document != null) {
      setState(() {
        _selectedDocuments.add(File(document.path));
      });
    }
  }

  // Function to remove image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Function to remove document
  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  // Function to upload images and documents
  Future<bool> _uploadFiles() async {
    _uploadedImageIds.clear();
    _uploadedDocumentIds.clear();

    // Upload images
    for (var imageFile in _selectedImages) {
      final result = await _imageUploadRepository.uploadImage(
        type: 'customer_request',
        imageFile: imageFile,
      );
      if (result.isSuccess) {
        _uploadedImageIds.add(result.data!);
      } else {
        _showSnackBar('Failed to upload image: ${result.message}');
        return false;
      }
    }

    // Upload documents
    for (var docFile in _selectedDocuments) {
      final result = await _imageUploadRepository.uploadDocument(
        type: 'general',
        imageFile: docFile,
      );
      if (result.isSuccess) {
        _uploadedDocumentIds.add(result.data!);
      } else {
        _showSnackBar('Failed to upload document: ${result.message}');
        return false;
      }
    }

    return true;
  }

  // Function to handle form submission
  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate required fields
      if (pickupLocation == null || dropoffLocation == null) {
        _showSnackBar('Please select both pickup and dropoff locations on the map');
        return;
      }

      if (_pickupLocationAddressController.text.trim().length < 3) {
        _showSnackBar('Pickup location address must be at least 3 characters');
        return;
      }

      if (_dropoffLocationAddressController.text.trim().length < 3) {
        _showSnackBar('Dropoff location address must be at least 3 characters');
        return;
      }

      // For new posts, require at least one image
      // For editing, allow keeping existing images
      if (widget.postToEdit == null && _selectedImages.isEmpty) {
        _showSnackBar('Please select at least one image');
        return;
      }

      // Upload new files if any
      if (_selectedImages.isNotEmpty || _selectedDocuments.isNotEmpty) {
        final uploadSuccess = await _uploadFiles();
        if (!uploadSuccess) {
          return;
        }
      }

      // Combine existing and newly uploaded IDs
      final allImageIds = <String>[..._existingImageIds, ..._uploadedImageIds];
      final allDocumentIds = <String>[..._existingDocumentIds, ..._uploadedDocumentIds];

      // Create trip locations
      final pickupLocationObj = TripLocation(
        address: _pickupLocationAddressController.text.trim(),
        coordinates: [pickupLocation!.longitude, pickupLocation!.latitude],
      );

      final dropoffLocationObj = TripLocation(
        address: _dropoffLocationAddressController.text.trim(),
        coordinates: [dropoffLocation!.longitude, dropoffLocation!.latitude],
      );

      // Calculate distance and duration
      final distanceValue = _distance ?? _calculateDistance(pickupLocation!, dropoffLocation!);
      final distance = Distance(
        value: distanceValue,
        text: "${distanceValue.toStringAsFixed(1)} km",
      );

      final durationValue = _duration ?? _calculateDuration(pickupLocation!, dropoffLocation!);
      final duration = TripDuration(
        value: durationValue,
        text: _formatDuration(durationValue),
      );

      // Create package details
      final packageDetails = PackageDetails(
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        dimensions: (_lengthController.text.isNotEmpty ||
                _widthController.text.isNotEmpty ||
                _heightController.text.isNotEmpty)
            ? Dimensions(
                length: _lengthController.text.isNotEmpty
                    ? double.tryParse(_lengthController.text)
                    : null,
                width: _widthController.text.isNotEmpty
                    ? double.tryParse(_widthController.text)
                    : null,
                height: _heightController.text.isNotEmpty
                    ? double.tryParse(_heightController.text)
                    : null,
              )
            : null,
        description: _packageDescriptionController.text.trim().isNotEmpty
            ? _packageDescriptionController.text.trim()
            : null,
      );

      // Create or update the customer request
      if (widget.postToEdit != null && widget.postToEdit!.id != null) {
        // Update existing request
        CustomerRequestHelper.updateRequest(
          context: context,
          requestId: widget.postToEdit!.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          pickupLocation: pickupLocationObj,
          dropoffLocation: dropoffLocationObj,
          distance: distance,
          duration: duration,
          packageDetails: packageDetails,
          images: allImageIds.isNotEmpty ? allImageIds : null,
          documents: allDocumentIds.isNotEmpty ? allDocumentIds : null,
          pickupTime: _selectedPickupTime,
        );
      } else {
        // Create new request
        CustomerRequestHelper.createRequest(
          context: context,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          pickupLocation: pickupLocationObj,
          dropoffLocation: dropoffLocationObj,
          distance: distance,
          duration: duration,
          packageDetails: packageDetails,
          images: allImageIds,
          documents: allDocumentIds.isNotEmpty ? allDocumentIds : null,
          pickupTime: _selectedPickupTime,
        );
      }
    }
  }

  // Helper method to calculate distance between two points (simplified)
  double _calculateDistance(LatLng start, LatLng end) {
    final latDiff = (start.latitude - end.latitude).abs();
    final lngDiff = (start.longitude - end.longitude).abs();
    return (latDiff + lngDiff) * 111; // Rough conversion to km
  }

  // Helper method to calculate duration (simplified)
  int _calculateDuration(LatLng start, LatLng end) {
    final distance = _calculateDistance(start, end);
    // Assume average speed of 50 km/h
    return (distance / 50 * 60).round(); // in minutes
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

  String formatLatLng(LatLng location) {
    String latDirection = location.latitude >= 0 ? 'N' : 'S';
    String lngDirection = location.longitude >= 0 ? 'E' : 'W';
    String lat = location.latitude.abs().toStringAsFixed(4);
    String lng = location.longitude.abs().toStringAsFixed(4);
    return '$lat° $latDirection, $lng° $lngDirection';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.postToEdit != null ? 'Edit Post' : 'Add New Post',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CustomerRequestBloc, CustomerRequestState>(
        listenWhen: (previous, current) {
          return (previous is! CustomerRequestCreated && current is CustomerRequestCreated) ||
              (previous is! CustomerRequestUpdated && current is CustomerRequestUpdated) ||
              (previous is! CustomerRequestError && current is CustomerRequestError);
        },
        listener: (context, state) {
          if (state is CustomerRequestCreated || state is CustomerRequestUpdated) {
            final route = ModalRoute.of(context);
            if (!mounted || route == null || !route.isCurrent) {
              return;
            }
            setState(() {
              _fieldErrors = [];
            });
            final message = widget.postToEdit != null 
                ? 'Post updated successfully!'
                : 'Post created successfully!';
            showSuccessSnackBar(context, message);
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted && context.mounted) {
                final currentRoute = ModalRoute.of(context);
                if (currentRoute != null && currentRoute.isCurrent) {
                  Navigator.of(context).pop(true);
                }
              }
            });
          } else if (state is CustomerRequestError) {
            final route = ModalRoute.of(context);
            if (mounted && route != null && route.isCurrent) {
              setState(() {
                _fieldErrors = state.fieldErrors ?? [];
              });
              
              if (state.hasFieldErrors) {
                showValidationErrorsDialog(context, state.fieldErrors!);
              } else {
                showErrorSnackBar(context, state.message);
              }
            }
          }
        },
        buildWhen: (previous, current) =>
            !(current is CustomerRequestCreated || 
              current is CustomerRequestUpdated || 
              current is CustomerRequestError),
        builder: (context, state) {
          final isLoading = state is CustomerRequestLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Validation Errors Banner
                  if (_fieldErrors.isNotEmpty)
                    ValidationErrorsBanner(
                      errors: _fieldErrors,
                      onDismiss: () {
                        setState(() {
                          _fieldErrors = [];
                        });
                      },
                    ),
                  if (_fieldErrors.isNotEmpty)
                    const SizedBox(height: 16),
                    
                  // Pickup Location Section
                  Text(
                    'Pickup Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _pickupLocationAddressController,
                    label: 'Address',
                    hint: 'e.g., Thiruvananthapuram, Kerala',
                    icon: Icons.location_on_outlined,
                    fieldName: 'pickupLocation.address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup location address';
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
                    coordinates: _pickupLocationCoordinates,
                    onTap: () async {
                      LatLng location = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapPointSelector()),
                      );
                      setState(() {
                        pickupLocation = location;
                        _pickupLocationCoordinates = formatLatLng(location);
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Dropoff Location Section
                  Text(
                    'Dropoff Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _dropoffLocationAddressController,
                    label: 'Address',
                    hint: 'e.g., Kanyakumari, Tamil Nadu',
                    icon: Icons.flag_outlined,
                    fieldName: 'dropoffLocation.address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dropoff location address';
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
                    coordinates: _dropoffLocationCoordinates,
                    onTap: () async {
                      LatLng location = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapPointSelector()),
                      );
                      setState(() {
                        dropoffLocation = location;
                        _dropoffLocationCoordinates = formatLatLng(location);
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Pickup Time Section
                  Text(
                    'Pickup Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDateTimePickerField(
                    label: 'Pickup Date & Time (Optional)',
                    selectedDateTime: _selectedPickupTime,
                    onTap: () => _selectPickupTime(context),
                  ),
                  const SizedBox(height: 30),

                  // Package Details Section
                  Text(
                    'Package Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _lengthController,
                          label: 'Length (cm)',
                          hint: 'e.g., 100',
                          icon: Icons.straighten_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _widthController,
                          label: 'Width (cm)',
                          hint: 'e.g., 50',
                          icon: Icons.straighten_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          hint: 'e.g., 30',
                          icon: Icons.straighten_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _packageDescriptionController,
                    label: 'Package Description',
                    hint: 'Describe your package...',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // Images Section
                  Text(
                    widget.postToEdit != null ? 'Images' : 'Images *',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildImagePicker(),
                  const SizedBox(height: 30),

                  // Documents Section
                  Text(
                    'Documents (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentPicker(),
                  const SizedBox(height: 30),

                  // Post Content Section
                  Text(
                    'Post Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g., Need Transport for Furniture',
                    icon: Icons.title_outlined,
                    fieldName: 'title',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title for your post';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
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
                    hint: 'Provide details about your shipment...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    fieldName: 'description',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description for your post';
                      }
                      if (value.trim().length > 1000) {
                        return 'Description must not exceed 1000 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitPost,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      label: Text(
                        isLoading 
                            ? (widget.postToEdit != null ? 'Updating...' : 'Creating...')
                            : (widget.postToEdit != null ? 'Update Post' : 'Create Post'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  /// Get field error for a specific field name
  String? _getFieldError(String fieldName) {
    if (_fieldErrors.isEmpty) return null;
    try {
      return _fieldErrors.firstWhere((error) => error.field == fieldName).message;
    } catch (e) {
      return null;
    }
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
    String? fieldName,
  }) {
    final fieldError = fieldName != null ? _getFieldError(fieldName) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: fieldError != null 
                  ? AppColors.error 
                  : Colors.grey.shade300, 
              width: fieldError != null ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
        if (fieldError != null) ...[
          const SizedBox(height: 4),
          FieldErrorText(errorText: fieldError),
        ],
      ],
    );
  }

  // Widget for displaying map coordinates
  Widget _buildMapCoordinatesField({
    required String label,
    required String? coordinates,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coordinates ?? 'Tap to select on map',
                    style: TextStyle(
                      color: coordinates != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for date and time picker field
  Widget _buildDateTimePickerField({
    required String label,
    required DateTime? selectedDateTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDateTime != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(selectedDateTime)
                        : 'Select Date & Time',
                    style: TextStyle(
                      color: selectedDateTime != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
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

  // Widget for image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.image_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedImages.isEmpty && _existingImageIds.isEmpty
                        ? widget.postToEdit != null 
                            ? 'Tap to add images (optional)'
                            : 'Tap to select images (at least 1 required)'
                        : '${_selectedImages.length} new + ${_existingImageIds.length} existing image(s)',
                    style: TextStyle(
                      color: (_selectedImages.isEmpty && _existingImageIds.isEmpty)
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.add_photo_alternate, color: AppColors.secondary),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // Widget for document picker
  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickDocuments,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDocuments.isEmpty
                        ? 'Tap to select documents (optional)'
                        : '${_selectedDocuments.length} document(s) selected',
                    style: TextStyle(
                      color: _selectedDocuments.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.upload_file, color: AppColors.secondary),
              ],
            ),
          ),
        ),
        if (_selectedDocuments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _selectedDocuments.length,
              (index) => Chip(
                label: Text(
                  _selectedDocuments[index].path.split('/').last,
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () => _removeDocument(index),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
