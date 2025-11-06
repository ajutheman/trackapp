import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';
import 'package:truck_app/features/auth/screens/welcome_screen.dart';
import 'package:truck_app/features/profile/model/profile.dart';
import 'package:truck_app/features/profile/repo/profile_repo.dart';
import 'package:truck_app/features/splash/screen/splash_screen.dart';
import 'package:truck_app/services/local/local_services.dart';
import 'package:truck_app/services/network/api_service.dart';

// Assuming AppColors is defined in this path
import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../post/screens/my_trip_screen.dart';
import '../../legal/screens/terms_and_conditions_screen.dart';
import '../../legal/screens/privacy_policy_screen.dart';
import '../../legal/screens/help_screen.dart';
import '../../legal/screens/customer_support_screen.dart';

class ProfileScreenUser extends StatefulWidget {
  const ProfileScreenUser({super.key});

  @override
  State<ProfileScreenUser> createState() => _ProfileScreenUserState();
}

class _ProfileScreenUserState extends State<ProfileScreenUser> {
  // Repositories
  final ApiService _apiService = ApiService();
  late final ProfileRepository _profileRepository;
  late final ImageUploadRepository _imageUploadRepository;

  // Controllers for user data fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  File? _profileImage; // For profile picture
  String? _profileImageUrl; // Network image URL
  String? _profileImageId; // Uploaded image ID
  bool _isEditing = false; // To toggle edit mode
  bool _isLoading = true; // Loading state
  bool _isSaving = false; // Saving state
  Profile? _profile; // Current profile data

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(apiService: _apiService);
    _imageUploadRepository = ImageUploadRepository(apiService: _apiService);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  // Load profile from API
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _profileRepository.getProfile();

    if (result.isSuccess && result.data != null) {
      setState(() {
        _profile = result.data;
        _nameController.text = _profile!.name;
        _emailController.text = _profile!.email;
        _phoneController.text = _profile!.phone;
        _whatsappController.text = _profile!.whatsappNumber ?? '';
        _profileImageUrl = _profile!.profilePictureUrl;
        _profileImageId = _profile!.profilePictureId;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showSnackBar(result.message ?? 'Failed to load profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isSaving)
            IconButton(
              icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: AppColors.secondary),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Save Profile' : 'Edit Profile',
            )
          else
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            GestureDetector(
              onTap: _isEditing ? _pickProfileImage : null, // Only allow picking when editing
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.surface,
                    backgroundImage: _getProfileImage(),
                    child: _getProfileImage() == null ? Icon(Icons.person_rounded, size: 60, color: AppColors.textSecondary.withOpacity(0.5)) : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Data Fields
            _buildProfileInputField(controller: _nameController, label: 'Name', icon: Icons.person_outline, isEditable: _isEditing),
            const SizedBox(height: 16),
            _buildProfileInputField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, isEditable: _isEditing, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildProfileInputField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone_outlined,
              isEditable: false,
              keyboardType: TextInputType.phone,
            ), // Phone is read-only
            const SizedBox(height: 16),
            _buildProfileInputField(
              controller: _whatsappController,
              label: 'WhatsApp Number',
              icon: Icons.chat_outlined,
              isEditable: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),

            // Action Buttons/ListTiles
            _buildActionButton(label: 'My Posts', icon: Icons.assignment_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyTripScreen()))),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Terms and Conditions',
              icon: Icons.description_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Support',
              icon: Icons.support_agent_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSupportScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionButton(label: 'Help', icon: Icons.help_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: AppColors.secondary.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Delete Account Button
            TextButton.icon(
              onPressed: _deleteAccount,
              icon: Icon(Icons.delete_forever_outlined, color: AppColors.error),
              label: Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 16)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
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
            border: Border.all(color: isEditable ? AppColors.secondary : Colors.grey.shade300, width: isEditable ? 2 : 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: !isEditable,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: isEditable ? AppColors.secondary : AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 18),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Get profile image
  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_profileImageUrl != null) {
      // Construct full URL if relative path
      String imageUrl = _profileImageUrl!;
      if (!imageUrl.startsWith('http')) {
        // Remove trailing slash from baseUrl and leading slash from imageUrl
        String baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1/', '');
        if (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
        }
        if (imageUrl.startsWith('/')) {
          imageUrl = imageUrl.substring(1);
        }
        imageUrl = '$baseUrl/$imageUrl';
      }
      return NetworkImage(imageUrl);
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
    }
  }

  // Function to pick profile image
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _profileImageUrl = null; // Clear network image when local image is selected
      });
    }
  }

  // Function to toggle edit mode
  void _toggleEditMode() {
    if (_isEditing) {
      // Save changes
      _saveProfileChanges();
    } else {
      // Enter edit mode
      setState(() {
        _isEditing = true;
      });
    }
  }

  // Function to save profile changes
  Future<void> _saveProfileChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String? profilePictureId = _profileImageId;

      // Upload image if a new one was selected
      if (_profileImage != null) {
        final uploadResult = await _imageUploadRepository.uploadImage(type: 'profile', imageFile: _profileImage!);

        if (uploadResult.isSuccess) {
          profilePictureId = uploadResult.data;
        } else {
          setState(() {
            _isSaving = false;
          });
          _showSnackBar('Failed to upload profile picture: ${uploadResult.message}');
          return;
        }
      }

      // Update profile
      final updateResult = await _profileRepository.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        whatsappNumber: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
        profilePictureId: profilePictureId,
      );

      if (updateResult.isSuccess && updateResult.data != null) {
        setState(() {
          _profile = updateResult.data;
          _profileImageUrl = _profile!.profilePictureUrl;
          _profileImageId = _profile!.profilePictureId;
          _profileImage = null; // Clear local image after successful upload
          _isEditing = false;
          _isSaving = false;
        });
        _showSnackBar('Profile updated successfully!');
      } else {
        setState(() {
          _isSaving = false;
        });
        _showSnackBar(updateResult.message ?? 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showSnackBar('Error updating profile: ${e.toString()}');
    }
  }

  // Function to handle logout
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text('Are you sure you want to log out?', style: TextStyle(color: AppColors.textSecondary)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalService.deleteTokens();
                // Perform logout logic here, e.g., clearing session/token
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SplashScreen()), (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to handle delete account
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Account', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog

                // Show loading
                showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

                final result = await _profileRepository.deleteAccount();

                if (mounted) {
                  Navigator.of(context).pop(); // Dismiss loading

                  if (result.isSuccess) {
                    // Clear tokens and navigate to welcome screen
                    await LocalService.deleteTokens();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomeScreen()), (predicate) => false);
                    }
                  } else {
                    _showSnackBar(result.message ?? 'Failed to delete account');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
