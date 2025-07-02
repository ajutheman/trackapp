import 'package:flutter/material.dart';
import 'package:truck_app/features/auth/screens/login_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               SizedBox(),
               Column(
                 children: [ Text(
                   'Welcome to\nLoadLink',
                   textAlign: TextAlign.center,
                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                     fontWeight: FontWeight.w700,
                     color: AppColors.textPrimary,
                     height: 1.2,
                   ),
                 ),
                   const SizedBox(height: 32),
                   // Truck icon with orange and blue styling
                   Container(
                     width: 200,
                     height: 200,
                     decoration: BoxDecoration(
                       color: AppColors.secondary.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Icon(Icons.fire_truck,color: AppColors.secondary,size: 100,),
                   ),
                   const SizedBox(height: 32),
                   Text(
                     'Connect With Customers\nLooking for Trucking Services',
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                       color: AppColors.textSecondary,
                       height: 1.4,
                     ),
                   ),],
               ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}