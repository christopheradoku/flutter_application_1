import 'package:flutter/material.dart';

// 1. IMPORT ADDED: This connects your splash screen to your main dashboard shell
import '../../main.dart'; 

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
    if (mounted) {
      setState(() {
        _loadingWidth = 77.50;
      });
    }

    // Transition to Frame 3 (Width: 155.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _loadingWidth = 155.0;
      });
    }

    // Transition to Frame 4 (Width: 232.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _loadingWidth = 232.0;
      });
    }

    // Transition to Frame 5 (Width: 310.0)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _loadingWidth = 310.0;
      });
    }
    
    // 2. NAVIGATION ADDED: Wait 0.5 seconds after filling, then go to the dashboard
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainNavigationShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xC1F4F0AA),
      // Center ensures the 402x874 design stays perfectly centered on any device screen size
      body: Center(
        child: Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xC1F4F0AA)),
          child: Stack(
            children: [
              // 1. The Logo Background Container with Shadow
              Positioned(
                left: 141,
                top: 379.14,
                child: Container(
                  width: 120,
                  height: 115.71,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF4F0AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 8,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),

              // 2. Your Splash Image Asset (splash1.png)
              Positioned(
                left: 142,
                top: 378,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/splash1.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              // 3. The Animated Gradient Loading Bar
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