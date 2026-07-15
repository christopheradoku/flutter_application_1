import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/form_sheet.dart';

class FeedTrackingScreen extends StatefulWidget {
  const FeedTrackingScreen({super.key});

  @override
  State<FeedTrackingScreen> createState() => _FeedTrackingScreenState();
}

class _FeedTrackingScreenState extends State<FeedTrackingScreen> {
  int _activeDay = 6; // index into the 7-day window returned by the provider; defaults to "today"

  static const List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();

    if (farm.isLoading) return const Center(child: CircularProgressIndicator());

    final consumption = farm.last7DaysFeedTotals;
    final maxVal = consumption.reduce(max).clamp(1, double.infinity);
    final todayFeedKg = farm.todayFeedKg;
    final breakdown = farm.feedTypeBreakdownToday; 
    final feedColors = {
      'Starter Feed': const Color(0xFFE8A020),
      'Grower Feed': const Color(0xFF7A9A00),
      'Finisher Feed': const Color(0xFFC0860A),
    };
    final breakdownTotal = breakdown.values.fold(0.0, (s, v) => s + v);

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
                Text('Feed Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Weekly consumption report', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),
          _buildGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Today's Total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x803C320A))),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${todayFeedKg.toStringAsFixed(0)} ', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                            const Text('kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                          ],
                        ),
                      ],
                    ),
                    Consumer<FarmProvider>(
                      builder: (context, p, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${p.flockInfo.flockSize} birds', style: const TextStyle(fontSize: 12, color: Color(0x733C320A))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // --- FIXED OVERFLOW LAYOUT HERE ---
                SizedBox(
                  height: 120, // Increased height to prevent bottom overflow
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(consumption.length, (i) {
                      final isActive = i == _activeDay;
                      // Max height for the bar is 80, leaving 40 pixels for padding and text
                      final height = maxVal == 0 ? 0.0 : (consumption[i] / maxVal) * 80; 
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeDay = i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: height.toDouble(),
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
                              Text(_dayLabels[i % 7], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFFC07010) : const Color(0x663C320A))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // --- END FIXED LAYOUT ---

                const SizedBox(height: 8),
                Center(
                  child: Text('${_dayLabels[_activeDay % 7]}: ${consumption[_activeDay].toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC07010))),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('FEED BREAKDOWN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Column(
            children: breakdown.entries.map((e) {
              final pct = breakdownTotal == 0 ? 0.0 : e.value / breakdownTotal;
              final color = feedColors[e.key] ?? Colors.grey;
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
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                            ],
                          ),
                          Text('${e.value.toStringAsFixed(0)} kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.black.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(pct * 100).toStringAsFixed(0)}% of total', style: const TextStyle(fontSize: 12, color: Color(0x663C320A))),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FarmPrimaryButton(
            label: '+ Log Feed Entry',
            colors: const [Color(0xFFE8A020), Color(0xFFC07010)],
            onPressed: () => _openLogFeedSheet(context),
          ),
        ],
      ),
    );
  }

  void _openLogFeedSheet(BuildContext context) {
    String feedType = 'Starter Feed';
    final kgController = TextEditingController();

    showFarmFormSheet(
      context: context,
      title: 'Log Feed Entry',
      builder: (ctx, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: feedType,
              decoration: InputDecoration(
                labelText: 'Feed type',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: const [
                DropdownMenuItem(value: 'Starter Feed', child: Text('Starter Feed')),
                DropdownMenuItem(value: 'Grower Feed', child: Text('Grower Feed')),
                DropdownMenuItem(value: 'Finisher Feed', child: Text('Finisher Feed')),
              ],
              onChanged: (v) => setModalState(() => feedType = v ?? feedType),
            ),
            const SizedBox(height: 12),
            FarmNumberField(label: 'Amount', controller: kgController, suffix: 'kg'),
            const SizedBox(height: 8),
            FarmPrimaryButton(
              label: 'Save Entry',
              colors: const [Color(0xFFE8A020), Color(0xFFC07010)],
              onPressed: () async {
                final kg = double.tryParse(kgController.text);
                if (kg == null || kg <= 0) return;
                await context.read<FarmProvider>().addFeedEntry(feedType: feedType, kg: kg);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
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