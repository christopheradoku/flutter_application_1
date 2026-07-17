import 'dart:ui'; // Required for the glass blur effect
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This connects your splash screen to your main dashboard shell
import '../../main.dart';
import '../../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Starting width from your first frame (10.0)
  double _loadingWidth = 10.0;

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
  }

  // This function automatically transitions through your 5 animation frames
  void _startLoadingAnimation() async {
    // Transition to Frame 2 (Width: 77.5)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _loadingWidth = 77.50);

    // Transition to Frame 3 (Width: 155.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _loadingWidth = 155.0);

    // Transition to Frame 4 (Width: 232.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _loadingWidth = 232.0);

    // Transition to Frame 5 (Width: 310.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _loadingWidth = 310.0);

    // NAVIGATION: Wait 0.5 seconds after filling, then check auth state
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Check if a user is currently logged into Firebase
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // User IS logged in, go straight to the Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
        );
      } else {
        // User IS NOT logged in, go to the Login Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0AA),
      // Center ensures the 402x874 design stays perfectly centered on any device screen size
      body: Center(
        child: Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          // 1. The beautiful React gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
              colors: [
                Color(0xFFF4F0AA),
                Color(0xFFE8F5C0),
                Color(0xFFD8EDB0)
              ],
            ),
          ),
          child: Stack(
            children: [
              // 3. Center Content: Glow Blob, Glass Card, and Typography
              Positioned(
                top: 240,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Stack for Blob and Logo Card
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The Yellow Glow Blob
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0x59FFDC28), Colors.transparent], // 35% opacity yellow
                                stops: [0.0, 0.7],
                              ),
                            ),
                          ),
                          // The Liquid Glass Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F000000), // 12% black
                                      blurRadius: 40,
                                      offset: Offset(0, 12),
                                    )
                                  ],
                                ),
                                child: Center(
                                  // Your Rooster Asset
                                  child: Image.asset(
                                    "assets/images/splash1.png",
                                    width: 117, // 90% of card size
                                    height: 117,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name with mixed colors
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          fontFamily: 'Segoe UI', // Clean sans-serif fallback
                        ),
                        children: [
                          TextSpan(text: 'Poultry ', style: TextStyle(color: Color(0xFF3A3000))),
                          TextSpan(text: 'Pro', style: TextStyle(color: Color(0xFF7A9A00))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Smart Farm Management',
                      style: TextStyle(fontSize: 14, color: Color(0x993C320A)), // 60% opacity dark brown
                    ),
                  ],
                ),
              ),

              // 4. Your Functional Animated Loading Bar
              Positioned(
                left: 46,
                top: 615,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000), // Smooth 1-second transition
                  curve: Curves.easeInOut, // Natural easing animation
                  width: _loadingWidth,
                  height: 12.0, // Standardized height across all frames
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-0.00, 1.00),
                      end: Alignment(1.00, 1.00),
                      colors: [
                        Color(0xFFFF0000),
                        Color(0xFFFF8D28) // Accents-Orange
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFF1E1E1E),
                      ),
                      borderRadius: BorderRadius.circular(6.08),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}