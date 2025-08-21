import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/features/auth/bloc/vehicle/vehicle_event.dart';

import '../../../core/constants/app_user_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../main/screen/main_screen_driver.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_state.dart'; // Assuming AppColors is in this path

class RegisterScreenDriver extends StatefulWidget {
  final String phone;
  final String token;

  const RegisterScreenDriver({super.key, required this.phone, required this.token});

  @override
  State<RegisterScreenDriver> createState() => _RegisterProfileScreenDriverState();
}

class _RegisterProfileScreenDriverState extends State<RegisterScreenDriver> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // New
  final TextEditingController _whatsAppController = TextEditingController(); // New
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController(); // New
  final TextEditingController _vehicleCapacityController = TextEditingController(); // New

  // Focus Nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode(); // New
  final FocusNode _whatsAppFocus = FocusNode(); // New
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _pincodeFocus = FocusNode();
  final FocusNode _vehicleNumberFocus = FocusNode(); // New
  final FocusNode _vehicleCapacityFocus = FocusNode(); // New

  // File Uploads
  File? _profilePicture; // New
  File? _rcFile; // New
  File? _drivingLicenseFile; // New
  final List<File> _truckImages = []; // New
  File? _vehicleInsuranceFile;

  // Dropdowns/Selections
  String _selectedVehicleType = '';
  String _selectedVehicleBodyType = ''; // New
  final List<String> _goodsAccepted = []; // New - for optional goods accepted

  // Checkbox
  bool _termsAccepted = false; // New

  // Animations
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  int _currentPage = 0;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Small Truck', 'Medium Truck', 'Large Truck', 'Container Truck', 'Trailer', 'Mini Truck'];
  final List<String> _vehicleBodyTypes = ['Open', 'Closed', 'Container', 'Flatbed', 'Tipper']; // New

  @override
  void initState() {
    super.initState();

    _phoneController.text = widget.phone;

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
    _nameController.dispose();
    _phoneController.dispose(); // New
    _whatsAppController.dispose(); // New
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _vehicleNumberController.dispose(); // New
    _vehicleCapacityController.dispose(); // New
    _nameFocus.dispose();
    _phoneFocus.dispose(); // New
    _whatsAppFocus.dispose(); // New
    _emailFocus.dispose();
    _companyFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _pincodeFocus.dispose();
    _vehicleNumberFocus.dispose(); // New
    _vehicleCapacityFocus.dispose(); // New
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<UserBloc, UserState>(
              listener: (context, state) {
                // Your existing UserBloc logic
                if (state is UserRegistrationLoading) {
                  setState(() => _isLoading = true);
                } else if (state is UserRegistrationSuccess) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    _gotoPage(1);
                  }); // Proceed to next page after user registration
                } else if (state is UserRegistrationFailure) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
            ),
            // **ADD THIS NEW LISTENER FOR VehicleBloc**
            BlocListener<VehicleBloc, VehicleState>(
              listener: (context, state) {
                if (state is VehicleRegistrationLoading) {
                  setState(() => _isLoading = true);
                } else if (state is VehicleRegistrationSuccess) {
                  setState(() => _isLoading = false);
                  _showSuccessDialog(); // Show success and navigate
                } else if (state is VehicleRegistrationFailure) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
            ),
          ],
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
                    _isLoading ? Center(child: CircularProgressIndicator()) : _buildPersonalInfoPage(),
                    // _buildBusinessInfoPage(),
                    _isLoading ? Center(child: CircularProgressIndicator()) : _buildVehicleTypeSelectionPage(), // Renamed for clarity
                    _isLoading ? Center(child: CircularProgressIndicator()) : _buildVehicleDetailsPage(), // New page for remaining vehicle details
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
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
                    const Text('Create Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Step ${_currentPage + 1} of 3', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)), // Updated total steps
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

  Widget _buildPersonalInfoPage() {
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
                const Text('Personal Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Tell us about yourself and your contact details', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                _buildInputField(controller: _nameController, focusNode: _nameFocus, label: 'Full Name', hint: 'Enter your full name', icon: Icons.person_outline),
                const SizedBox(height: 20),

                _buildInputField(
                  enabled: false,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _whatsAppController,
                  focusNode: _whatsAppFocus,
                  label: 'WhatsApp Number',
                  hint: 'Enter your WhatsApp number',
                  icon: FontAwesomeIcons.whatsapp,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildFileUploadWidget(label: 'Profile Picture', file: _profilePicture, onPick: () => _pickFile((file) => _profilePicture = file), icon: Icons.camera_alt_outlined),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
              const Text('Select your primary vehicle type', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.2),
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
                            Icon(_getVehicleIcon(vehicleType), size: 40, color: isSelected ? AppColors.secondary : AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              vehicleType,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.secondary : AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                const Text('Vehicle Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Provide detailed information about your vehicle and documents', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
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

                _buildMultiImageUploadWidget(label: 'Upload Truck Images (4 Sides)', images: _truckImages, onPick: _pickMultipleImages),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _vehicleNumberController,
                  focusNode: _vehicleNumberFocus,
                  label: 'Vehicle Number',
                  hint: 'e.g., KA01AB1234',
                  icon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 20),
                _buildFileUploadWidget(
                  label: 'Upload Vehicle Insurance',
                  file: _vehicleInsuranceFile,
                  onPick: () => _pickFile((file) => _vehicleInsuranceFile = file),
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Vehicle Body Type',
                  value: _selectedVehicleBodyType,
                  items: _vehicleBodyTypes,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVehicleBodyType = newValue!;
                    });
                  },
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 20),

                // Goods Accepted (Optional - using chip selection for multi-select)
                Text('Goods Accepted (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children:
                      ['Electronics', 'Furniture', 'Textiles', 'Food', 'Machinery', 'Construction Material'].map((goods) {
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
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _vehicleCapacityController,
                  focusNode: _vehicleCapacityFocus,
                  label: 'Vehicle Capacity (in tons)',
                  hint: 'e.g., 5.0',
                  icon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),

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
                    ),
                    Expanded(child: Text('I agree to the Terms and Conditions', style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
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
    bool enabled = true,
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
            border: Border.all(color: focusNode.hasFocus ? AppColors.secondary : Colors.grey.shade300),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            enabled: enabled,
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required Function(String?) onChanged, required IconData icon}) {
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
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Row(
                children: [Icon(icon, color: AppColors.textSecondary), const SizedBox(width: 12), const Text('Select option', style: TextStyle(color: AppColors.textSecondary))],
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              onChanged: onChanged,
              items:
                  items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(value: item, child: Text(item));
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
        if (file != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Image.file(file, height: 100, width: 100, fit: BoxFit.cover)),
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
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isCurrentPageValid() ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)]) : null,
          color: _isCurrentPageValid() ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isCurrentPageValid() ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: ElevatedButton(
          onPressed: _isCurrentPageValid() ? submitForm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _currentPage == 2 ? "Complete Registration" : 'Continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _isCurrentPageValid() ? Colors.white : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'small truck':
        return Icons.local_shipping;
      case 'medium truck':
        return Icons.fire_truck;
      case 'large truck':
        return Icons.airport_shuttle;
      case 'container truck':
        return Icons.rv_hookup;
      case 'trailer':
        return Icons.directions_bus;
      case 'mini truck':
        return Icons.delivery_dining;
      default:
        return Icons.local_shipping;
    }
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0: // Personal Info
        return _nameController.text.isNotEmpty &&
            _phoneController.text.length == 10 &&
            _whatsAppController.text.length == 10 &&
            _emailController.text.isNotEmpty &&
            _emailController.text.contains('@');
      case 1: // Vehicle Type selection
        return _selectedVehicleType.isNotEmpty;
      case 2: // Vehicle Details
        return _rcFile != null &&
            _drivingLicenseFile != null &&
            _vehicleInsuranceFile != null &&
            _truckImages.isNotEmpty &&
            _vehicleNumberController.text.isNotEmpty &&
            _selectedVehicleBodyType.isNotEmpty &&
            _vehicleCapacityController.text.isNotEmpty &&
            _termsAccepted;
      default:
        return false;
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call and file uploads
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to main app or show success
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 50),
                ),
                const SizedBox(height: 20),
                const Text('Registration Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                const Text(
                  'Welcome to Return Cargo! Your account has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainScreenDriver()), (predict) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  submitForm() {
    if (_currentPage == 0) {
      context.read<UserBloc>().add(
        RegisterUser(userType: AppUserType.driver, name: _nameController.text, whatsappNumber: _whatsAppController.text, email: _emailController.text, token: widget.token),
      );
    } else if (_currentPage == 1) {
      _gotoPage(2);
    } else {
      context.read<VehicleBloc>().add(
        RegisterVehicle(
          vehicleNumber: _vehicleNumberController.text,
          vehicleType: _selectedVehicleType,
          vehicleBodyType: _selectedVehicleBodyType,
          vehicleCapacity: _vehicleCapacityController.text,
          goodsAccepted: _goodsAccepted.first,
          registrationCertificate: _rcFile!,
          // Ensure these are not null before dispatching
          truckImages: _truckImages,
          termsAndConditionsAccepted: _termsAccepted,
        ),
      );
    }
  }

  void _gotoPage(int page) {
    // Updated for 3 pages (0, 1, 2, 3)
    setState(() {
      _currentPage = page;
      _isLoading = false;
    });
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _updateProgress();
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
    double progress = (_currentPage + 1) / 3; // Updated for 4 pages
    _progressController.animateTo(progress);
  }

  Future<void> _pickFile(Function(File?) onFilePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery); // Can use .camera as well
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
}
