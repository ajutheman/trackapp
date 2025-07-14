import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/vehicle/model/vehicle.dart'; // Import the Vehicle model

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  // Controllers for text fields
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleCapacityController = TextEditingController();

  // Focus Nodes
  final FocusNode _vehicleNumberFocus = FocusNode();
  final FocusNode _vehicleCapacityFocus = FocusNode();

  // File Uploads
  File? _rcFile;
  File? _drivingLicenseFile;
  final List<File> _truckImages = [];

  // Dropdowns/Selections
  VehicleType? _selectedVehicleType;
  VehicleBodyType? _selectedVehicleBodyType;
  final List<String> _goodsAccepted = [];

  // Checkbox
  bool _termsAccepted = false;

  // Animations
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  int _currentPage = 0;
  bool _isLoading = false;

  final List<VehicleType> _vehicleTypes = VehicleType.values.where((e) => e != VehicleType.other).toList();
  final List<VehicleBodyType> _vehicleBodyTypes = VehicleBodyType.values.where((e) => e != VehicleBodyType.other).toList();
  final List<String> _allGoods = ['Electronics', 'Furniture', 'Textiles', 'Food', 'Machinery', 'Construction Material', 'Perishables', 'Chemicals', 'Automotive Parts'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _progressController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    _vehicleNumberController.dispose();
    _vehicleCapacityController.dispose();
    _vehicleNumberFocus.dispose();
    _vehicleCapacityFocus.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) { // Only 2 pages (0, 1)
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _updateProgress();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _updateProgress();
    }
  }

  void _updateProgress() {
    double progress = (_currentPage + 1) / 2; // Total 2 pages
    _progressController.animateTo(progress);
  }

  Future<void> _pickFile(Function(File?) onFilePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        onFilePicked(File(file.path));
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _truckImages.clear(); // Clear previous images if re-picking
        for (var img in images) {
          _truckImages.add(File(img.path));
        }
      });
    }
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0: // Vehicle Type and Body Type selection
        return _selectedVehicleType != null && _selectedVehicleBodyType != null;
      case 1: // Vehicle Details and Documents
        return _rcFile != null &&
            _drivingLicenseFile != null &&
            _truckImages.length >= 4 && // Minimum 4 truck images
            _vehicleNumberController.text.isNotEmpty &&
            _vehicleCapacityController.text.isNotEmpty &&
            double.tryParse(_vehicleCapacityController.text) != null && // Ensure capacity is a valid number
            _termsAccepted;
      default:
        return false;
    }
  }

  Future<void> _addVehicle() async {
    if (!_isCurrentPageValid()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call and file uploads
    // In a real app, you would upload files to storage (e.g., Firebase Storage)
    // and get their URLs, then save the vehicle data to Firestore.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Create a new Vehicle object with a unique ID
      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
        type: _selectedVehicleType!,
        bodyType: _selectedVehicleBodyType!,
        capacity: double.parse(_vehicleCapacityController.text),
        vehicleNumber: _vehicleNumberController.text.toUpperCase(),
        rcFileUrl: _rcFile?.path, // In a real app, this would be the uploaded URL
        drivingLicenseFileUrl: _drivingLicenseFile?.path, // In a real app, this would be the uploaded URL
        truckImageUrls: _truckImages.map((f) => f.path).toList(), // In a real app, these would be uploaded URLs
        goodsAccepted: _goodsAccepted,
      );

      setState(() {
        _isLoading = false;
      });

      // Pass the new vehicle back to the previous screen (VehicleListScreen)
      Navigator.pop(context, newVehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Progress
            _buildHeader(),

            // Form Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildVehicleTypeSelectionPage(),
                  _buildVehicleDetailsPage(),
                ],
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Back Button and Title
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? _previousPage : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Vehicle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Step ${_currentPage + 1} of 2', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)), // Total 2 steps
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeSelectionPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vehicle Type', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Select your vehicle type and body type', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _vehicleTypes.length,
                        itemBuilder: (context, index) {
                          final vehicleType = _vehicleTypes[index];
                          final isSelected = _selectedVehicleType == vehicleType;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVehicleType = vehicleType;
                              });
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? AppColors.secondary : Colors.grey.shade300, width: isSelected ? 2 : 1),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(vehicleType.icon, size: 40, color: isSelected ? AppColors.secondary : AppColors.textSecondary),
                                  const SizedBox(height: 12),
                                  Text(
                                    vehicleType.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.secondary : AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildDropdownField<VehicleBodyType>(
                        label: 'Vehicle Body Type',
                        value: _selectedVehicleBodyType,
                        items: _vehicleBodyTypes,
                        onChanged: (VehicleBodyType? newValue) {
                          setState(() {
                            _selectedVehicleBodyType = newValue;
                          });
                        },
                        icon: Icons.local_shipping_outlined,
                        itemBuilder: (type) => Text(type.name),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vehicle Documents & Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Provide necessary documents and vehicle specifics', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                _buildFileUploadWidget(
                  label: 'Upload RC (Registration Certificate)',
                  file: _rcFile,
                  onPick: () => _pickFile((file) => _rcFile = file),
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 20),

                _buildFileUploadWidget(
                  label: 'Upload Driving License',
                  file: _drivingLicenseFile,
                  onPick: () => _pickFile((file) => _drivingLicenseFile = file),
                  icon: Icons.credit_card_outlined,
                ),
                const SizedBox(height: 20),

                _buildMultiImageUploadWidget(label: 'Upload Truck Images (Min 4 Sides)', images: _truckImages, onPick: _pickMultipleImages),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _vehicleNumberController,
                  focusNode: _vehicleNumberFocus,
                  label: 'Vehicle Number',
                  hint: 'e.g., KA01AB1234',
                  icon: Icons.numbers_outlined,
                  onChanged: (value) => setState(() {}),
                  textCapitalization: TextCapitalization.characters, // Capitalize input
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _vehicleCapacityController,
                  focusNode: _vehicleCapacityFocus,
                  label: 'Vehicle Capacity (in tons)',
                  hint: 'e.g., 5.0',
                  icon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))], // Allow decimals up to 2 places
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 30),

                // Goods Accepted (Optional - using chip selection for multi-select)
                Text('Goods Accepted (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _allGoods.map((goods) {
                    final isSelected = _goodsAccepted.contains(goods);
                    return ChoiceChip(
                      label: Text(goods),
                      selected: isSelected,
                      selectedColor: AppColors.secondary.withOpacity(0.1),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _goodsAccepted.add(goods);
                          } else {
                            _goodsAccepted.remove(goods);
                          }
                        });
                      },
                      labelStyle: TextStyle(color: isSelected ? AppColors.secondary : AppColors.textSecondary),
                      side: BorderSide(color: isSelected ? AppColors.secondary : Colors.grey.shade300),
                      backgroundColor: AppColors.surface,
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _termsAccepted = newValue ?? false;
                        });
                      },
                      activeColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms and Conditions',
                        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    required Function(String) onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
            border: Border.all(color: focusNode.hasFocus ? AppColors.secondary : Colors.grey.shade300, width: focusNode.hasFocus ? 2 : 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(icon, color: focusNode.hasFocus ? AppColors.secondary : AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required IconData icon,
    required Widget Function(T) itemBuilder,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Row(
                children: [Icon(icon, color: AppColors.textSecondary), const SizedBox(width: 12), const Text('Select option', style: TextStyle(color: AppColors.textSecondary))],
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadWidget({required String label, required File? file, required VoidCallback onPick, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
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
                Icon(icon, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null ? file.path.split('/').last : 'Tap to upload',
                    style: TextStyle(color: file != null ? AppColors.textPrimary : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.upload_file, color: AppColors.secondary),
              ],
            ),
          ),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(file, height: 100, width: 100, fit: BoxFit.cover),
          ),
      ],
    );
  }

  Widget _buildMultiImageUploadWidget({required String label, required List<File> images, required VoidCallback onPick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
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
                const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    images.isNotEmpty ? '${images.length} images selected' : 'Tap to upload (min 4)',
                    style: TextStyle(color: images.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.add_a_photo, color: AppColors.secondary),
              ],
            ),
          ),
        ),
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(padding: const EdgeInsets.only(right: 8.0), child: Image.file(images[index], height: 100, width: 100, fit: BoxFit.cover));
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _currentPage == 1 // Last page
          ? Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isCurrentPageValid() ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)]) : null,
          color: _isCurrentPageValid() ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isCurrentPageValid() ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: ElevatedButton(
          onPressed: _isCurrentPageValid() && !_isLoading ? _addVehicle : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
            'Add Vehicle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _isCurrentPageValid() ? Colors.white : Colors.grey.shade600),
          ),
        ),
      )
          : Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isCurrentPageValid() ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)]) : null,
          color: _isCurrentPageValid() ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isCurrentPageValid() ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: ElevatedButton(
          onPressed: _isCurrentPageValid() ? _nextPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _isCurrentPageValid() ? Colors.white : Colors.grey.shade600)),
        ),
      ),
    );
  }
}
