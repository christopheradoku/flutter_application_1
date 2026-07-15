import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/form_sheet.dart';

class MortalityScreen extends StatelessWidget {
  const MortalityScreen({super.key});

  static const List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const Map<String, Color> _causeColors = {
    'Respiratory': Color(0xFFE05050),
    'Disease': Color(0xFFC03030),
    'Injury': Color(0xFFE08050),
    'Unknown': Color(0x593C320A),
  };

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    if (farm.isLoading) return const Center(child: CircularProgressIndicator());

    final weekData = farm.last7DaysMortality;
    final total = farm.totalMortalityThisWeek;
    final maxCount = weekData.map((d) => d.count).fold(0, max).clamp(1, 1 << 30);
    final causeTotals = farm.mortalityByCauseThisWeek;
    
    // Grab the actual flock size to show exactly how the rate is calculated
    final flockSize = farm.flockInfo.flockSize;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              Expanded(
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Losses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                      Text(total.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                      const Text('birds died', style: TextStyle(fontSize: 12, color: Color(0x733C320A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mortality Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                      Text('${(farm.mortalityRate * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                      // Explicitly showing the numbers behind the rate
                      Text('$total out of $flockSize', style: const TextStyle(fontSize: 12, color: Color(0x733C320A))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Deaths This Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                const SizedBox(height: 12),
                
                // --- FIXED OVERFLOW LAYOUT HERE ---
                SizedBox(
                  height: 120, // Increased bounding box height
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(weekData.length, (i) {
                      final d = weekData[i];
                      // Max height of 80 to prevent overflow
                      final height = (d.count / maxCount) * 80;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(d.count.toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: height.toDouble(),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                border: Border.all(color: const Color(0x40E05050)),
                                gradient: const LinearGradient(colors: [Color(0xB3E05050), Color(0x66E05050)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_dayLabels[i % 7], style: const TextStyle(fontSize: 9, color: Color(0x663C320A))),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                // --- END FIXED LAYOUT ---
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('CAUSE ANALYSIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Column(
            children: causeTotals.entries.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: _causeColors[c.key] ?? Colors.grey, shape: BoxShape.circle)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : c.value / total,
                                backgroundColor: Colors.black.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(_causeColors[c.key] ?? Colors.grey),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(c.value.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _causeColors[c.key] ?? Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FarmPrimaryButton(
            label: '+ Log Mortality Event',
            colors: const [Color(0xFFE05050), Color(0xFFC03030)],
            onPressed: () => _openLogMortalitySheet(context),
          ),
        ],
      ),
    );
  }

  void _openLogMortalitySheet(BuildContext context) {
    final countCtrl = TextEditingController();
    String cause = 'Respiratory';

    showFarmFormSheet(
      context: context,
      title: 'Log Mortality Event',
      builder: (ctx, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FarmNumberField(label: 'Number of birds', controller: countCtrl),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: cause,
              decoration: InputDecoration(
                labelText: 'Cause',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _causeColors.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setModalState(() => cause = v ?? cause),
            ),
            const SizedBox(height: 16),
            FarmPrimaryButton(
              label: 'Save Event',
              colors: const [Color(0xFFE05050), Color(0xFFC03030)],
              onPressed: () async {
                final count = int.tryParse(countCtrl.text);
                if (count == null || count <= 0) return;
                await context.read<FarmProvider>().addMortalityEvent(count: count, cause: cause);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
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