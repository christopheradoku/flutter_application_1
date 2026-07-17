import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm_models.dart';
import '../widgets/form_sheet.dart';

class EggProductionScreen extends StatefulWidget {
  const EggProductionScreen({super.key});

  @override
  State<EggProductionScreen> createState() => _EggProductionScreenState();
}

class _EggProductionScreenState extends State<EggProductionScreen> {
  String _selectedTab = 'daily';
  
  // --- Dynamic Date Calculator ---
  String _getDynamicDayName(int index) {
    if (index < 0 || index > 6) return '';
    final today = DateTime.now();
    final dateOfColumn = today.subtract(Duration(days: 6 - index));
    switch (dateOfColumn.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    if (farm.isLoading) return const Center(child: CircularProgressIndicator());

    final weekData = farm.last7DaysEggs;
    final weekTotals = weekData.map((e) => e.total).toList();
    final maxEggs = weekTotals.reduce(max).clamp(1, 1 << 30);
    final today =
        farm.todayEggCollection ?? EggCollection(date: DateTime.now());

    final gradeTotals = <String, int>{
      'A (Large)': weekData.fold(0, (s, e) => s + e.gradeA),
      'B (Medium)': weekData.fold(0, (s, e) => s + e.gradeB),
      'C (Small)': weekData.fold(0, (s, e) => s + e.gradeC),
      'Cracked/Reject': weekData.fold(0, (s, e) => s + e.cracked),
    };
    final gradeColors = {
      'A (Large)': const Color(0xFFC0860A),
      'B (Medium)': const Color(0xFFE8A020),
      'C (Small)': const Color(0xFFFFE066),
      'Cracked/Reject': const Color(0x4D3C320A),
    };
    final weekEggTotal = weekTotals.fold(0, (a, b) => a + b).clamp(1, 1 << 30);

    // --- NEW: Safe Lay Rate Calculation ---
    String layRateText = '—';
    if (today.hensActive > 0) {
      layRateText = '${(today.total / today.hensActive * 100).clamp(0, 100).toStringAsFixed(0)}%';
    }

    // --- NEW: Safe 'vs Yesterday' Calculation (Fixes the Infinity% bug) ---
    String vsYesterdayText = '—';
    if (weekTotals.length > 1) {
      int todayEggs = weekTotals.last;
      int yesterdayEggs = weekTotals[weekTotals.length - 2];
      if (yesterdayEggs == 0) {
        vsYesterdayText = todayEggs > 0 ? '+100%' : '0%';
      } else {
        double pct = ((todayEggs - yesterdayEggs) / yesterdayEggs) * 100;
        // Adds a '+' sign if the percentage is positive
        vsYesterdayText = '${pct > 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
      }
    }

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
                Text(
                  'Egg Production',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2000),
                  ),
                ),
                Text(
                  'Collection & grading',
                  style: TextStyle(fontSize: 12, color: Color(0x803C320A)),
                ),
              ],
            ),
          ),
          _buildGlassContainer(
            child: Column(
              children: [
                const Text(
                  "Today's Collection",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0x803C320A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${today.total}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2000),
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'eggs',
                  style: TextStyle(fontSize: 14, color: Color(0xFFC0860A)),
                ),
                const SizedBox(height: 16),
                
                // --- FIXED RESPONSIVE ROW LAYOUT ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeroStat(layRateText, 'Lay Rate'),
                    Container(width: 1, height: 30, color: Colors.black12),
                    _buildHeroStat(vsYesterdayText, 'vs Yesterday'),
                    Container(width: 1, height: 30, color: Colors.black12),
                    _buildHeroStat('${today.hensActive}', 'Hens Active'),
                  ],
                ),
                // --- END FIXED ROW ---
                
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          if (_selectedTab == 'daily') ...[
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120, 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(weekTotals.length, (index) {
                        final val = weekTotals[index];
                        final height = maxEggs == 0 ? 0.0 : (val / maxEggs) * 80;
                        final isToday = index == weekTotals.length - 1;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: double.infinity,
                                height: height.toDouble(),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  gradient: isToday
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE8A020),
                                            Color(0xFFC07010),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : null,
                                  color: isToday
                                      ? null
                                      : const Color(0x4DE8A020),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getDynamicDayName(index),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0x663C320A),
                                ),
                              ),
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
              children: gradeTotals.entries.map((g) {
                final pct = (g.value / weekEggTotal * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGlassContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: gradeColors[g.key],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  g.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A2000),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              g.value.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: gradeColors[g.key],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gradeColors[g.key]!,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0x663C320A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          FarmPrimaryButton(
            label: '+ Record Collection',
            colors: const [Color(0xFFE8A020), Color(0xFFC07010)],
            onPressed: () => _openRecordCollectionSheet(context),
          ),
        ],
      ),
    );
  }

  void _openRecordCollectionSheet(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final cCtrl = TextEditingController();
    final crackedCtrl = TextEditingController();
    
    // Automatically fill the "Hens Active" box with the total flock size
    final currentFlockSize = context.read<FarmProvider>().flockInfo.flockSize.toString();
    final hensActiveCtrl = TextEditingController(text: currentFlockSize);

    showFarmFormSheet(
      context: context,
      title: 'Record Collection',
      builder: (ctx, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FarmNumberField(
              label: 'Hens Active Today',
              controller: hensActiveCtrl,
              suffix: 'birds',
            ),
            const SizedBox(height: 12),
            FarmNumberField(
              label: 'Grade A (Large)',
              controller: aCtrl,
              suffix: 'eggs',
            ),
            FarmNumberField(
              label: 'Grade B (Medium)',
              controller: bCtrl,
              suffix: 'eggs',
            ),
            FarmNumberField(
              label: 'Grade C (Small)',
              controller: cCtrl,
              suffix: 'eggs',
            ),
            FarmNumberField(
              label: 'Cracked / Reject',
              controller: crackedCtrl,
              suffix: 'eggs',
            ),
            const SizedBox(height: 8),
            FarmPrimaryButton(
              label: 'Save Collection',
              colors: const [Color(0xFFE8A020), Color(0xFFC07010)],
              onPressed: () async {
                await context.read<FarmProvider>().addEggCollection(
                  gradeA: int.tryParse(aCtrl.text) ?? 0,
                  gradeB: int.tryParse(bCtrl.text) ?? 0,
                  gradeC: int.tryParse(cCtrl.text) ?? 0,
                  cracked: int.tryParse(crackedCtrl.text) ?? 0,
                  hensActive: int.tryParse(hensActiveCtrl.text) ?? 0, 
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
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
            color: isActive
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF2A2000)
                    : const Color(0x733C320A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- FIXED HERO STAT WITH EXPANDED & FITTED BOX ---
  Widget _buildHeroStat(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2000),
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0x803C320A)),
              ),
            ),
          ],
        ),
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}