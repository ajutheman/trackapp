import 'package:flutter/material.dart';

import '../../../core/constants/app_images.dart';
import '../../auth/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late final theme = Theme.of(context);

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeOutBack)));

    // Start the animation
    _controller.forward();
    init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.primaryColor.withOpacity(0.1), theme.primaryColor.withOpacity(0.3)]),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20.0, spreadRadius: 2.0)],
                        ),
                        child: Image.asset(AppImages.appIconWithName),
                      ),
                      const SizedBox(height: 30),
                      Text("Return Cargo", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.primaryColor, letterSpacing: 1.2)),
                      const SizedBox(height: 5),
                      const Text("Manage. Track. Deliver.", style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  init() {
    Future.delayed(Duration(seconds: 3)).then((result) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomeScreen()), (predicate) => false);
    });
  }
}
