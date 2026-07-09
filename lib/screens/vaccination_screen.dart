import 'dart:ui';
import 'package:flutter/material.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> schedule = [
    {'name': 'Newcastle Disease', 'date': 'Jul 02', 'done': true, 'birds': 3600, 'type': 'Intraocular', 'upcoming': false},
    {'name': 'Infectious Bronchitis', 'date': 'Jul 05', 'done': true, 'birds': 3600, 'type': 'Drinking water', 'upcoming': false},
    {'name': 'Gumboro Disease', 'date': 'Jul 12', 'done': true, 'birds': 3580, 'type': 'Drinking water', 'upcoming': false},
    {'name': 'Marek\'s Disease', 'date': 'Jul 18', 'done': false, 'birds': 3600, 'type': 'Subcutaneous', 'upcoming': true},
    {'name': 'Fowl Pox', 'date': 'Jul 28', 'done': false, 'birds': 3600, 'type': 'Wing web', 'upcoming': false},
  ];

  @override
  Widget build(BuildContext context) {
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
                Text('Vaccination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Schedule & records', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),

          // Progress Ring Area
          _buildGlassContainer(
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.88,
                        strokeWidth: 8,
                        backgroundColor: const Color(0x264A9FD4),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A9FD4)),
                      ),
                      const Center(child: Text('88%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000)))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Programme Complete', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                    const Text('3 / 5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                    const Text('Vaccines administered', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x2E4A9FD4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x4D4A9FD4)),
                      ),
                      child: const Text('Next: Jul 18', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A9FD4))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('PROGRAMME SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),

          // Schedule List
          Column(
            children: List.generate(schedule.length, (i) {
              final v = schedule[i];
              final isDone = v['done'] as bool;
              final isUpcoming = v['upcoming'] as bool;
              final isSelected = _selectedIndex == i;

              Color bgColor = Colors.white.withValues(alpha: 0.28);
              Color borderColor = Colors.white.withValues(alpha: 0.6);

              if (isUpcoming) {
                bgColor = const Color(0x1F4A9FD4); // 0.12 opacity blue
                borderColor = const Color(0x664A9FD4); // 0.4 opacity blue
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = isSelected ? null : i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Icon/Number Circle
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDone ? const Color(0x337A9A00) : (isUpcoming ? const Color(0x334A9FD4) : const Color(0x0F000000)),
                                    border: Border.all(color: isDone ? const Color(0x667A9A00) : (isUpcoming ? const Color(0x664A9FD4) : Colors.transparent)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isDone ? '✓' : (isUpcoming ? '!' : '${i + 1}'),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF5A7A00) : (isUpcoming ? const Color(0xFF4A9FD4) : const Color(0x663C320A))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(v['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                                      Text('${v['type']} · ${v['date']}', style: const TextStyle(fontSize: 12, color: Color(0x803C320A))),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0x267A9A00) : const Color(0x0F000000),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(isDone ? 'Done' : 'Pending', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF5A7A00) : const Color(0x663C320A))),
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text('Birds: ${v['birds']} · Method: ${v['type']} · Date: ${v['date']}', style: const TextStyle(fontSize: 12, color: Color(0x993C320A))),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Action Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4A9FD4), Color(0xFF2A7FB4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x664A9FD4), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('+ Record Vaccination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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