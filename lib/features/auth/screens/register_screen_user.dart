import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_app/features/main/screen/main_screen_user.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';

class RegisterScreenUser extends StatefulWidget {
  final String phone;
  final String token;

  const RegisterScreenUser({super.key, required this.phone, required this.token});

  @override
  State<RegisterScreenUser> createState() => _RegisterScreenUserState();
}

class _RegisterScreenUserState extends State<RegisterScreenUser> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _whatsAppFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  File? _profilePicture;
  bool _isLoading = false;

  @override
  void initState() {
    _phoneController.text = widget.phone;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsAppController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _whatsAppFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("User Registration"), backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegistrationLoading) {
            setState(() => _isLoading = true);
          } else if (state is UserRegistrationSuccess) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreenUser()), (predict) => false);
          } else if (state is UserRegistrationFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                icon: Icons.chat_outlined,
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
              _buildFileUploadWidget(label: 'Profile Picture', file: _profilePicture, onPick: _pickFile, icon: Icons.camera_alt_outlined),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid() && !_isLoading ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid() ? AppColors.secondary : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
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
              border: Border.all(color: Colors.grey.shade300),
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

  Future<void> _pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _profilePicture = File(file.path));
    }
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty && _phoneController.text.length == 10 && _whatsAppController.text.length == 10 && _emailController.text.contains('@');
  }

  void _submit() async {
    if (!_isFormValid()) return;
    context.read<UserBloc>().add(RegisterUser(name: _nameController.text, whatsappNumber: _whatsAppController.text, email: _emailController.text, token: widget.token));
  }
}
