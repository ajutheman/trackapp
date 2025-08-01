import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/features/auth/screens/welcome_screen.dart';

// Assuming AppColors is defined in this path
import '../../../core/theme/app_colors.dart';
import '../../post/screens/my_posts_screen.dart';

class ProfileScreenUser extends StatefulWidget {
  const ProfileScreenUser({super.key});

  @override
  State<ProfileScreenUser> createState() => _ProfileScreenUserState();
}

class _ProfileScreenUserState extends State<ProfileScreenUser> {
  // Controllers for user data fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage; // For profile picture
  bool _isEditing = false; // To toggle edit mode

  @override
  void initState() {
    super.initState();
    // Initialize with mock user data
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@example.com';
    _phoneController.text = '9876543210';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: AppColors.secondary),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Save Profile' : 'Edit Profile',
          ),
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
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.person_rounded, size: 60, color: AppColors.textSecondary.withOpacity(0.5)) : null,
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
            _buildProfileInputField(controller: _phoneController, label: 'Phone', icon: Icons.phone_outlined, isEditable: _isEditing, keyboardType: TextInputType.phone),
            const SizedBox(height: 40),

            // Action Buttons/ListTiles
            _buildActionButton(
              label: 'My Posts',
              icon: Icons.assignment_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyPostsScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionButton(label: 'Terms and Conditions', icon: Icons.description_outlined, onTap: () => _showSnackBar('Navigating to Terms and Conditions')),
            const SizedBox(height: 12),
            _buildActionButton(label: 'Privacy Policy', icon: Icons.privacy_tip_outlined, onTap: () => _showSnackBar('Navigating to Privacy Policy')),
            const SizedBox(height: 12),
            _buildActionButton(label: 'Support', icon: Icons.support_agent_outlined, onTap: () => _showSnackBar('Navigating to Support')),
            const SizedBox(height: 12),
            _buildActionButton(label: 'Help', icon: Icons.help_outline, onTap: () => _showSnackBar('Navigating to Help')),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  // Function to pick profile image
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      _showSnackBar('Profile picture updated!');
    }
  }

  // Function to toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // If exiting edit mode, save changes (mock save)
        _saveProfileChanges();
      }
    });
  }

  // Function to save profile changes (mock implementation)
  void _saveProfileChanges() {
    // In a real app, you would send these updated values to a backend
    print('Saving profile:');
    print('Name: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    _showSnackBar('Profile updated successfully!');
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
              onPressed: () {
                // Perform logout logic here, e.g., clearing session/token
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomeScreen()), (route) => false);
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
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomeScreen()), (predicate) => false);
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
