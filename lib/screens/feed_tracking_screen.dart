import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class FeedTrackingScreen extends StatefulWidget {
  const FeedTrackingScreen({super.key});

  @override
  State<FeedTrackingScreen> createState() => _FeedTrackingScreenState();
}

class _FeedTrackingScreenState extends State<FeedTrackingScreen> {
  int _activeDay = 3; // Defaults to Thursday

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> consumption = [210, 225, 218, 240, 235, 200, 190];
  
  final List<Map<String, dynamic>> feedTypes = [
    {'name': 'Starter Feed', 'kg': 80, 'color': const Color(0xFFE8A020), 'pct': 33},
    {'name': 'Grower Feed', 'kg': 100, 'color': const Color(0xFF7A9A00), 'pct': 42},
    {'name': 'Finisher Feed', 'kg': 60, 'color': const Color(0xFFC0860A), 'pct': 25},
  ];

  @override
  Widget build(BuildContext context) {
    final int maxVal = consumption.reduce(max);

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
                Text('Feed Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Weekly consumption report', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),

          // Today's Summary & Chart
          _buildGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('240 ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                            Text('kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x337A9A00),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x4D7A9A00)),
                          ),
                          child: const Text('+4.3% vs avg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A7A00))),
                        ),
                        const SizedBox(height: 4),
                        const Text('3,600 birds', style: TextStyle(fontSize: 12, color: Color(0x733C320A))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Interactive Bar Chart
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(days.length, (i) {
                      final isActive = i == _activeDay;
                      final height = (consumption[i] / maxVal) * 72;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeDay = i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: height,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  gradient: isActive 
                                    ? const LinearGradient(colors: [Color(0xFFE8A020), Color(0xFFC07010)], begin: Alignment.topCenter, end: Alignment.bottomCenter) 
                                    : null,
                                  color: isActive ? null : const Color(0x40E8A020),
                                  border: isActive ? null : Border.all(color: const Color(0x33E8A020)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(days[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFFC07010) : const Color(0x663C320A))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('${days[_activeDay]}: ${consumption[_activeDay]} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC07010))),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feed Types Breakdown
          const Text('FEED BREAKDOWN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Column(
            children: feedTypes.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: f['color'], shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(f['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                          ],
                        ),
                        Text('${f['kg']} kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: f['color'])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: f['pct'] / 100,
                        backgroundColor: Colors.black.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(f['color']),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${f['pct']}% of total', style: const TextStyle(fontSize: 12, color: Color(0x663C320A))),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
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
                    child: Text('+ Log Feed Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }
}