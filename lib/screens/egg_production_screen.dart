import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class EggProductionScreen extends StatefulWidget {
  const EggProductionScreen({super.key});

  @override
  State<EggProductionScreen> createState() => _EggProductionScreenState();
}

class _EggProductionScreenState extends State<EggProductionScreen> {
  // Tab state: 'daily' or 'grade'
  String _selectedTab = 'daily';

  // Data
  final List<int> weekEggs = [2600, 2720, 2800, 2840, 2810, 2750, 2690];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  final List<Map<String, dynamic>> grades = [
    {'grade': 'A (Large)', 'count': 1840, 'pct': 65, 'color': const Color(0xFFC0860A)},
    {'grade': 'B (Medium)', 'count': 710, 'pct': 25, 'color': const Color(0xFFE8A020)},
    {'grade': 'C (Small)', 'count': 200, 'pct': 7, 'color': const Color(0xFFFFE066)},
    {'grade': 'Cracked/Reject', 'count': 90, 'pct': 3, 'color': const Color(0x4D3C320A)}, // 0.3 opacity
  ];

  @override
  Widget build(BuildContext context) {
    final int maxEggs = weekEggs.reduce(max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Egg Production', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Collection & grading', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),

          // Hero Section
          _buildGlassContainer(
            child: Column(
              children: [
                const Text("Today's Collection", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                const SizedBox(height: 4),
                const Text('2,840', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2A2000), letterSpacing: -1)),
                const Text('eggs', style: TextStyle(fontSize: 14, color: Color(0xFFC0860A))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeroStat('91%', 'Lay Rate'),
                    Container(width: 1, height: 30, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _buildHeroStat('+3.2%', 'vs Yesterday'),
                    Container(width: 1, height: 30, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _buildHeroStat('3,120', 'Hens Active'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTabButton('daily', 'Daily Trend'),
                _buildTabButton('grade', 'Grade Breakdown'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
          if (_selectedTab == 'daily') ...[
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(weekEggs.length, (index) {
                        final val = weekEggs[index];
                        final height = (val / maxEggs) * 80;
                        final isToday = index == 3; // Matching the highlight in your React code
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: double.infinity,
                                height: height,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  gradient: isToday
                                      ? const LinearGradient(colors: [Color(0xFFE8A020), Color(0xFFC07010)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                                      : null,
                                  color: isToday ? null : const Color(0x4DE8A020),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(days[index], style: const TextStyle(fontSize: 9, color: Color(0x663C320A))),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Column(
              children: grades.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGlassContainer(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: g['color'], shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(g['grade'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                            ],
                          ),
                          Text(g['count'].toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: g['color'])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: g['pct'] / 100,
                          backgroundColor: Colors.black.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(g['color']),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${g['pct']}%', style: const TextStyle(fontSize: 12, color: Color(0x663C320A))),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Action Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE8A020), Color(0xFFC07010)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x66E8A020), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('+ Record Collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label) {
    final isActive = _selectedTab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.7) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2A2000) : const Color(0x733C320A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0x803C320A))),
      ],
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }
}