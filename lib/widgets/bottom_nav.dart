import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 85, // Fixed height for consistent sliding space
          decoration: BoxDecoration(
            color: const Color(0xFFF4F9D8).withValues(alpha: 0.95), 
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate exactly how wide each of the 5 tabs should be
                final tabWidth = constraints.maxWidth / 5;

                return Stack(
                  children: [
                    // --- THE LIQUID GLASS GLIDER ---
                    // This floats behind the icons and physically slides to the active position
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.fastOutSlowIn, // Creates that smooth, liquid-like acceleration
                      left: currentIndex * tabWidth,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Center(
                        child: Container(
                          width: tabWidth * 0.85, // Slightly narrower than the slot for neat margins
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFE9AA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    // --- THE ICONS & TEXT ---
                    // These sit stationary on top of the glider
                    Row(
                      children: [
                        _buildNavItem(0, Icons.grid_view_outlined, 'Home', tabWidth),
                        _buildNavItem(1, '🌾', 'Feed', tabWidth),
                        _buildNavItem(2, '🥚', 'Eggs', tabWidth),
                        _buildNavItem(3, '💉', 'Vaccines', tabWidth),
                        _buildNavItem(4, '💰', 'Finance', tabWidth),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, dynamic iconOrEmoji, String label, double width) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width, // Locks the tap target to exactly 1/5th of the screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconOrEmoji is IconData)
              Icon(
                iconOrEmoji,
                color: isActive ? const Color(0xFF5C7410) : const Color(0xFF969B7B),
                size: 26,
              )
            else if (iconOrEmoji is String)
              Text(
                iconOrEmoji,
                style: const TextStyle(fontSize: 22), 
              ),
            
            const SizedBox(height: 4),
            
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? const Color(0xFF5C7410) : const Color(0xFF969B7B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}