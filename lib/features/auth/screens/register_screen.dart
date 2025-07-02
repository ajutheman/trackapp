import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Focus Nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _pincodeFocus = FocusNode();

  // Animations
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  int _currentPage = 0;
  String _selectedVehicleType = '';
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Small Truck', 'Medium Truck', 'Large Truck', 'Container Truck', 'Trailer', 'Mini Truck'];

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
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _companyFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _pincodeFocus.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
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
    double progress = (_currentPage + 1) / 3;
    _progressController.animateTo(progress);
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _emailController.text.contains('@');
      case 1:
        return _companyController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _cityController.text.isNotEmpty &&
            _stateController.text.isNotEmpty &&
            _pincodeController.text.length == 6;
      case 2:
        return _selectedVehicleType.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
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
                  'Welcome to LoadLink! Your account has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to main app
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
                children: [_buildPersonalInfoPage(), _buildBusinessInfoPage(), _buildVehicleInfoPage()],
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
                    const Text('Create Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Step ${_currentPage + 1} of 3', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Tell us about yourself', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                _buildInputField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 20),

                _buildInputField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => setState(() {}),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfoPage() {
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
                const Text('Business Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Tell us about your business', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                _buildInputField(
                  controller: _companyController,
                  focusNode: _companyFocus,
                  label: 'Company Name',
                  hint: 'Enter company name',
                  icon: Icons.business_outlined,
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 20),

                _buildInputField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  label: 'Address',
                  hint: 'Enter full address',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _cityController,
                        focusNode: _cityFocus,
                        label: 'City',
                        hint: 'City',
                        icon: Icons.location_city_outlined,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _stateController,
                        focusNode: _stateFocus,
                        label: 'State',
                        hint: 'State',
                        icon: Icons.map_outlined,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildInputField(
                  controller: _pincodeController,
                  focusNode: _pincodeFocus,
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vehicle Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Select your vehicle type', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child:
          _currentPage == 2
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
                  onPressed: _isCurrentPageValid() && !_isLoading ? _completeRegistration : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                            'Complete Registration',
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
}
