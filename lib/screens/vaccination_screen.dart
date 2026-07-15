import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm_models.dart';
import '../widgets/form_sheet.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    if (farm.isLoading) return const Center(child: CircularProgressIndicator());

    final schedule = farm.vaccinations;
    final next = farm.nextUpcomingVaccination;

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
                Text('Vaccination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Schedule & records', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),
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
                        value: farm.vaccinationProgress,
                        strokeWidth: 8,
                        backgroundColor: const Color(0x264A9FD4),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A9FD4)),
                      ),
                      Center(child: Text('${(farm.vaccinationProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000)))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Programme Complete', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                    Text('${farm.vaccinationsDoneCount} / ${schedule.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                    const Text('Vaccines administered', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                    const SizedBox(height: 4),
                    if (next != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0x2E4A9FD4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x4D4A9FD4))),
                        child: Text('Next: ${_fmt(next.scheduledDate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A9FD4))),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('PROGRAMME SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Column(
            children: List.generate(schedule.length, (i) {
              final v = schedule[i];
              final isDone = v.isDone;
              final isUpcoming = !isDone && v == next;
              final isSelected = _selectedIndex == i;

              Color bgColor = Colors.white.withValues(alpha: 0.28);
              Color borderColor = Colors.white.withValues(alpha: 0.6);
              if (isUpcoming) {
                bgColor = const Color(0x1F4A9FD4);
                borderColor = const Color(0x664A9FD4);
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
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 1.5)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
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
                                      Text(v.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                                      Text('${v.method} · ${_fmt(v.scheduledDate)}', style: const TextStyle(fontSize: 12, color: Color(0x803C320A))),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isDone
                                      ? null
                                      : () => context.read<FarmProvider>().markVaccinationAdministered(v.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: isDone ? const Color(0x267A9A00) : const Color(0x0F000000), borderRadius: BorderRadius.circular(12)),
                                    child: Text(isDone ? 'Done' : 'Mark done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF5A7A00) : const Color(0x663C320A))),
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text('Birds: ${v.birds} · Method: ${v.method} · Date: ${_fmt(v.scheduledDate)}', style: const TextStyle(fontSize: 12, color: Color(0x993C320A))),
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
          FarmPrimaryButton(
            label: '+ Schedule / Record Vaccine',
            colors: const [Color(0xFF4A9FD4), Color(0xFF2A7FB4)],
            onPressed: () => _openRecordVaccinationSheet(context),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${_month(d.month)} ${d.day.toString().padLeft(2, '0')}';
  String _month(int m) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];

  void _openRecordVaccinationSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final birdsCtrl = TextEditingController();
    String method = 'Drinking water';
    bool isAdministered = false;
    DateTime scheduledDate = DateTime.now();

    showFarmFormSheet(
      context: context,
      title: 'Log Vaccination',
      builder: (ctx, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Vaccine name (e.g., Newcastle, Gumboro)',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            FarmNumberField(label: 'Birds covered', controller: birdsCtrl),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: InputDecoration(
                labelText: 'Method',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: const ['Intraocular', 'Drinking water', 'Subcutaneous', 'Wing web', 'Spray']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setModalState(() => method = v ?? method),
            ),
            const SizedBox(height: 16),
            
            // --- NEW: Toggle and Date Picker ---
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Already Administered?', style: TextStyle(fontSize: 14)),
                    value: isAdministered,
                    activeColor: const Color(0xFF4A9FD4),
                    onChanged: (v) => setModalState(() => isAdministered = v),
                  ),
                  ListTile(
                    title: Text(isAdministered ? 'Administered On:' : 'Schedule For:', style: const TextStyle(fontSize: 14)),
                    subtitle: Text(_fmt(scheduledDate), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A9FD4))),
                    trailing: const Icon(Icons.calendar_today, color: Color(0xFF4A9FD4)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: scheduledDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: Color(0xFF4A9FD4)),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => scheduledDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            FarmPrimaryButton(
              label: 'Save Record',
              colors: const [Color(0xFF4A9FD4), Color(0xFF2A7FB4)],
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final farm = context.read<FarmProvider>();
                final record = VaccinationRecord(
                  id: '', // Will be generated by Firestore
                  name: nameCtrl.text.trim(),
                  scheduledDate: scheduledDate,
                  administeredDate: isAdministered ? scheduledDate : null,
                  birds: int.tryParse(birdsCtrl.text) ?? farm.flockInfo.flockSize,
                  method: method,
                );
                await farm.addVaccinationRecord(record);
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