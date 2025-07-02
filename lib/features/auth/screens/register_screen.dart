import 'package:flutter/material.dart';

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController truckTypeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  bool isAvailable = false;

  @override
  void dispose() {
    nameController.dispose();
    licenseController.dispose();
    truckTypeController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Register',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueGrey.shade50,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: nameController, hint: 'Name'),
                  const SizedBox(height: 12),
                  _buildTextField(controller: licenseController, hint: 'License'),
                  const SizedBox(height: 12),
                  _buildTextField(controller: truckTypeController, hint: 'Truck Type'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: capacityController,
                    hint: 'Capacity',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available for Work',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Switch(
                        value: isAvailable,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile Submitted')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
