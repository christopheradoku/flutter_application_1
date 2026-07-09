import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class MortalityScreen extends StatelessWidget {
  const MortalityScreen({super.key});

  final List<Map<String, dynamic>> weekData = const [
    {'day': 'Mon', 'count': 3},
    {'day': 'Tue', 'count': 1},
    {'day': 'Wed', 'count': 2},
    {'day': 'Thu', 'count': 4},
    {'day': 'Fri', 'count': 1},
    {'day': 'Sat', 'count': 2},
    {'day': 'Sun', 'count': 1},
  ];

  final List<Map<String, dynamic>> causes = const [
    {'name': 'Respiratory', 'count': 5, 'color': Color(0xFFE05050)},
    {'name': 'Disease', 'count': 4, 'color': Color(0xFFC03030)},
    {'name': 'Injury', 'count': 3, 'color': Color(0xFFE08050)},
    {'name': 'Unknown', 'count': 2, 'color': Color(0x593C320A)}, // 0.35 opacity
  ];

  @override
  Widget build(BuildContext context) {
    final int total = weekData.fold(0, (sum, item) => sum + (item['count'] as int));
    final int maxCount = weekData.map((d) => d['count'] as int).reduce(max);

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
                Text('Mortality', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Weekly tracking & causes', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This Week', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                      Text(total.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                      const Text('birds lost', style: TextStyle(fontSize: 12, color: Color(0x733C320A))),
                      const SizedBox(height: 4),
                      const Text('-28%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                      Text('0.4%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7A9A00))),
                      Text('of flock', style: TextStyle(fontSize: 12, color: Color(0x733C320A))),
                      SizedBox(height: 4),
                      Text('✓ Healthy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A9A00))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart
          _buildGlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Deaths This Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weekData.map((d) {
                      final val = d['count'] as int;
                      final height = (val / maxCount) * 72;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(val.toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                border: Border.all(color: const Color(0x40E05050)),
                                gradient: const LinearGradient(
                                  colors: [Color(0xB3E05050), Color(0x66E05050)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(d['day'], style: const TextStyle(fontSize: 9, color: Color(0x663C320A))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cause Analysis
          const Text('CAUSE ANALYSIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Column(
            children: causes.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGlassContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: c['color'], shape: BoxShape.circle)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: c['count'] / total,
                              backgroundColor: Colors.black.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(c['color']),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(c['count'].toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c['color'])),
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
              gradient: const LinearGradient(colors: [Color(0xFFE05050), Color(0xFFC03030)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x59E05050), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('+ Log Mortality Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
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