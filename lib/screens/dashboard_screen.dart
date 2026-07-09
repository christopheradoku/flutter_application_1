import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Functional Data Structure: This is where API data will eventually feed in.
  final List<Map<String, dynamic>> dashboardStats = const [
    {
      'label': 'Feed Tracking', 'value': '240 kg', 'sub': 'Today\'s consumption',
      'icon': Icons.agriculture, 'color': Color(0xFFE8A020),
      'progress': 0.72, 'badge': 'Good', 'badgeColor': Color(0xFF7A9A00)
    },
    {
      'label': 'Vaccination', 'value': '3,200', 'sub': 'Birds vaccinated',
      'icon': Icons.vaccines, 'color': Color(0xFF4A9FD4),
      'progress': 0.88, 'badge': 'On Track', 'badgeColor': Color(0xFF4A9FD4)
    },
    {
      'label': 'Mortality', 'value': '0.4%', 'sub': 'Rate this week',
      'icon': Icons.warning_amber_rounded, 'color': Color(0xFFE05050),
      'progress': 0.08, 'badge': 'Low', 'badgeColor': Color(0xFF7A9A00)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Good morning ☀️', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                  Text('Farm Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white54,
                child: Icon(Icons.person, color: Colors.black54), // Replace with actual logo asset later
              )
            ],
          ),
          const SizedBox(height: 24),

          // Overview Strip
          _buildGlassContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Flock Size', '3,600'),
                _buildStatColumn('Batches', '4'),
                _buildStatColumn('Alerts', '2'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('QUICK OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.2)),
          const SizedBox(height: 12),

          // Dynamic Feature Cards
          ...dashboardStats.map((stat) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: stat['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(stat['icon'], color: stat['color']),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stat['label'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              Text(stat['value'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: stat['badgeColor'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: stat['badgeColor'].withOpacity(0.5)),
                        ),
                        child: Text(stat['badge'], style: TextStyle(color: stat['badgeColor'], fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(stat['sub'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: stat['progress'],
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(stat['color']),
                    borderRadius: BorderRadius.circular(4),
                  )
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A3A00))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  // Reusable Glassmorphism Widget
  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}