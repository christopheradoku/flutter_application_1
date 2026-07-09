import 'package:flutter/material.dart';

// 1. Import your navigation bar
import 'widgets/bottom_nav.dart';

// 2. Import ALL of your screens
// Note: Double-check this splash screen path to ensure it matches your exact folder setup!
import 'feature/splash_screen/splash_screen.dart'; 
import 'screens/dashboard_screen.dart';
import 'screens/feed_tracking_screen.dart';
import 'screens/egg_production_screen.dart';
import 'screens/vaccination_screen.dart';
import 'screens/profit_loss_screen.dart';

void main() {
  runApp(const PoultryProApp());
}

// ------------------------------------------------------------------------
// THE ROOT APP
// This sets up the Material theme and launches the Splash Screen first.
// ------------------------------------------------------------------------
class PoultryProApp extends StatelessWidget {
  const PoultryProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poultry Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7a9a00), // Main brand green
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F0AA),
      ),
      // Boot the app directly into the Splash Screen
      home: const SplashScreen(), 
    );
  }
}

// ------------------------------------------------------------------------
// THE NAVIGATION SHELL
// The Splash Screen navigates to this widget once its animation is done.
// ------------------------------------------------------------------------
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // The 5 core screens of your app, ordered exactly as they appear on your bottom nav.
  final List<Widget> _screens = [
    const DashboardScreen(),
    const FeedTrackingScreen(),
    const EggProductionScreen(),
    const VaccinationScreen(),
    const ProfitLossScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf4f0aa),
              Color(0xFFe8f5c0),
              Color(0xFFd4ebb8),
            ],
          ),
        ),
        child: SafeArea(
          // IndexedStack is the secret weapon here. It loads all 5 screens into memory 
          // but only displays the one matching the _currentIndex. This preserves state!
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}