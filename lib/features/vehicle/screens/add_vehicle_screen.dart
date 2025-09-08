import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/features/vehicle/bloc/vehicle_metadata/vehicle_meta_bloc.dart';
import 'package:truck_app/features/vehicle/model/vehicle_metadata.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/core/utils/messages.dart';

import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../bloc/vehicle/vehicle_state.dart';
import '../bloc/vehicle_metadata/vehicle_meta_event.dart';
import '../bloc/vehicle_metadata/vehicle_meta_state.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleCapacityController = TextEditingController();

  // Focus Nodes
  final FocusNode _vehicleNumberFocus = FocusNode();
  final FocusNode _vehicleCapacityFocus = FocusNode();

  // File Uploads
  File? _rcFile;
  File? _drivingLicenseFile;
  final List<File> _truckImages = [];
  File? _vehicleInsuranceFile;

  // Dropdowns/Selections
  VehicleType? _selectedVehicleType;
  VehicleBodyType? _selectedVehicleBodyType;
  final List<GoodsAccepted> selectedGoodsAccepted = [];

  // Checkbox
  bool _termsAccepted = false;

  bool _isLoading = false;

  final List<VehicleType> _vehicleTypes = [];
  final List<VehicleBodyType> _vehicleBodyTypes = [];
  final List<GoodsAccepted> _goodsAcceptedList = [];

  @override
  void initState() {
    super.initState();
    // Load vehicle metadata on screen initialization
    context.read<VehicleMetaBloc>().add(LoadAllMeta());
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleCapacityController.dispose();
    _vehicleNumberFocus.dispose();
    _vehicleCapacityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<VehicleMetaBloc, VehicleMetaState>(
              listener: (context, state) {
                if (state is VehicleMetaLoading) {
                  setState(() => _isLoading = true);
                } else if (state is VehicleMetaLoaded) {
                  setState(() {
                    _isLoading = false;
                    _vehicleTypes.addAll(state.vehicleTypes);
                    _vehicleBodyTypes.addAll(state.bodyTypes);
                    _goodsAcceptedList.addAll(state.goodsAccepted);
                  });
                } else if (state is VehicleMetaError) {
                  setState(() => _isLoading = false);
                  showSnackBar(context, state.message);
                }
              },
            ),
            BlocListener<VehicleBloc, VehicleState>(
              listener: (context, state) {
                if (state is VehicleRegistrationLoading) {
                  setState(() => _isLoading = true);
                } else if (state is VehicleRegistrationSuccess) {
                  setState(() => _isLoading = false);
                  _showSuccessDialog();
                } else if (state is VehicleRegistrationFailure) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
            ),
          ],
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Vehicle Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Provide information about your vehicle and documents', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),

                  // Vehicle Type Selection Grid
                  const Text('Vehicle Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120, // Adjust height as needed
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 16, childAspectRatio: 1.2),
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
                                Icon(_getVehicleIcon(vehicleType.name), size: 40, color: isSelected ? AppColors.secondary : AppColors.textSecondary),
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
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Number
                  _buildInputField(
                    controller: _vehicleNumberController,
                    focusNode: _vehicleNumberFocus,
                    label: 'Vehicle Number',
                    hint: 'e.g., KA01AB1234',
                    icon: Icons.numbers_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Capacity
                  _buildInputField(
                    controller: _vehicleCapacityController,
                    focusNode: _vehicleCapacityFocus,
                    label: 'Vehicle Capacity (in tons)',
                    hint: 'e.g., 5.0',
                    icon: Icons.scale_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Body Type Dropdown
                  _buildDropdownField<VehicleBodyType>(
                    label: 'Vehicle Body Type',
                    value: _selectedVehicleBodyType,
                    items: _vehicleBodyTypes,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedVehicleBodyType = newValue!;
                      });
                    },
                    icon: Icons.local_shipping_outlined,
                    displayBuilder: (value) {
                      return value.name;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Goods Accepted Chips
                  const Text('Goods Accepted (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: _goodsAcceptedList.map((goods) {
                      final isSelected = selectedGoodsAccepted.contains(goods);
                      return ChoiceChip(
                        label: Text(goods.name),
                        selected: isSelected,
                        selectedColor: AppColors.secondary.withOpacity(0.1),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedGoodsAccepted.add(goods);
                            } else {
                              selectedGoodsAccepted.remove(goods);
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

                  // File Uploads
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

                  _buildFileUploadWidget(
                    label: 'Upload Vehicle Insurance',
                    file: _vehicleInsuranceFile,
                    onPick: () => _pickFile((file) => _vehicleInsuranceFile = file),
                    icon: Icons.shield_outlined,
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
                      const Expanded(child: Text('I agree to the Terms and Conditions', style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _rcFile != null &&
        _vehicleInsuranceFile != null &&
        _truckImages.length >= 4 &&
        _vehicleNumberController.text.isNotEmpty &&
        _selectedVehicleType != null &&
        _selectedVehicleBodyType != null &&
        _vehicleCapacityController.text.isNotEmpty &&
        _termsAccepted;
  }

  void _submitForm() {
    if (_isFormValid()) {
      context.read<VehicleBloc>().add(
        RegisterVehicle(
          vehicleNumber: _vehicleNumberController.text,
          vehicleType: _selectedVehicleType!.id,
          vehicleBodyType: _selectedVehicleBodyType!.id,
          vehicleCapacity: _vehicleCapacityController.text,
          goodsAccepted: selectedGoodsAccepted.first.id,
          registrationCertificate: _rcFile!,
          drivingLicense: _drivingLicenseFile!,
          truckImages: _truckImages,
          termsAndConditionsAccepted: _termsAccepted,
        ),
      );
    } else {
      showSnackBar(context, 'Please fill all required fields and accept the terms.');
    }
  }

  Widget _buildSubmitButton() {
    final isValid = _isFormValid();
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isValid ? LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)]) : null,
        color: isValid ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isValid ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
      ),
      child: ElevatedButton(
        onPressed: isValid ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          _isLoading ? 'Processing...' : 'Complete Registration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isValid ? Colors.white : Colors.grey.shade600),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              'Your vehicle has been added successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
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
        // _truckImages.clear();
        for (var img in images) {
          _truckImages.add(File(img.path));
        }
      });
    }
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

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayBuilder,
    required Function(T?) onChanged,
    required IconData icon,
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
              items:
              items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayBuilder(item)),
                );
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
}
