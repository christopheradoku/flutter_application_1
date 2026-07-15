import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/farm_provider.dart';
import 'login_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  void _showEditProfileDialog(BuildContext context, String currentFarmName) {
    final TextEditingController nameCtrl = TextEditingController(text: currentFarmName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Farm Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9A00)),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null && nameCtrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({'farmName': nameCtrl.text.trim()});
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditFlockDialog(BuildContext context, int currentFlock, int currentBatches) {
    final flockCtrl = TextEditingController(text: currentFlock.toString());
    final batchesCtrl = TextEditingController(text: currentBatches.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Flock Info', style: TextStyle(color: Color(0xFF2A2000), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: flockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Flock Size', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: batchesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Batches', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9A00)),
            onPressed: () async {
              final newFlock = int.tryParse(flockCtrl.text) ?? currentFlock;
              final newBatches = int.tryParse(batchesCtrl.text) ?? currentBatches;
              
              await context.read<FarmProvider>().updateFlock(newFlock, newBatches);
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogMortalityDialog(BuildContext context) {
    final countCtrl = TextEditingController();
    String cause = 'Respiratory';
    final causes = ['Respiratory', 'Disease', 'Injury', 'Unknown'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Log Bird Deaths', style: TextStyle(color: Color(0xFF2A2000), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of birds died', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cause,
                decoration: const InputDecoration(labelText: 'Cause of death', border: OutlineInputBorder()),
                items: causes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => cause = v ?? cause),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE05050)), 
              onPressed: () async {
                final count = int.tryParse(countCtrl.text);
                if (count != null && count > 0) {
                  await context.read<FarmProvider>().addMortalityEvent(count: count, cause: cause);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Alerts 🔔', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF7A9A00),
                  child: Icon(Icons.assignment, color: Colors.white),
                ),
                title: const Text('Daily Record Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Don\'t forget to log today\'s feed consumption, egg collection, and check for mortalities.'),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final user = FirebaseAuth.instance.currentUser;

    if (farm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7A9A00)));
    }
    if (farm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load dashboard: ${farm.error}'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: farm.loadAll, child: const Text('Retry')),
          ],
        ),
      );
    }

    final dashboardStats = <Map<String, dynamic>>[
      {
        'label': 'Feed Tracking',
        'value': '${farm.todayFeedKg.toStringAsFixed(0)} kg',
        'sub': "Today's consumption",
        'icon': Icons.agriculture,
        'color': const Color(0xFFE8A020),
        'progress': (farm.todayFeedKg / 300).clamp(0.0, 1.0),
        'badge': farm.todayFeedKg > 200 ? 'Good' : 'Low',
        'badgeColor': farm.todayFeedKg > 200 ? const Color(0xFF7A9A00) : const Color(0xFFE05050),
      },
      {
        'label': 'Vaccination',
        'value': '${farm.vaccinationsDoneCount * (farm.flockInfo.flockSize)}',
        'sub': 'Birds vaccinated',
        'icon': Icons.vaccines,
        'color': const Color(0xFF4A9FD4),
        'progress': farm.vaccinationProgress,
        'badge': farm.vaccinationProgress >= 0.8 ? 'On Track' : 'Behind',
        'badgeColor': const Color(0xFF4A9FD4),
      },
      {
        'label': 'Mortality',
        'value': '${(farm.mortalityRate * 100).toStringAsFixed(1)}%',
        'sub': 'Rate this week',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFE05050),
        'progress': farm.mortalityRate.clamp(0.0, 1.0),
        'badge': farm.mortalityRate < 0.02 ? 'Low' : 'Watch',
        'badgeColor': farm.mortalityRate < 0.02 ? const Color(0xFF7A9A00) : const Color(0xFFE05050),
      },
    ];

    return RefreshIndicator(
      onRefresh: farm.loadAll,
      color: const Color(0xFF7A9A00),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getGreeting(), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                      builder: (context, snapshot) {
                        String farmName = 'Farm Dashboard';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          farmName = snapshot.data!.get('farmName') ?? 'Farm Dashboard';
                        }
                        return Text(
                          farmName, 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))
                        );
                      },
                    ),
                  ],
                ),
                
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Farmer Profile'),
                        content: Text('Logged in as:\n${user?.email ?? 'Unknown User'}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); 
                              FirebaseFirestore.instance.collection('users').doc(user?.uid).get().then((doc) {
                                String currentName = doc.data()?['farmName'] ?? '';
                                _showEditProfileDialog(context, currentName);
                              });
                            },
                            child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF7A9A00))),
                          ),
                          TextButton(
                            onPressed: () async {
                              // 1. Wipe the local memory instantly!
                              context.read<FarmProvider>().clearData();
                              
                              // 2. Sign out of Firebase
                              await FirebaseAuth.instance.signOut();
                              
                              // 3. Send the user back to the login screen
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white60,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.black54) : null,
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildGlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showEditFlockDialog(context, farm.flockInfo.flockSize, farm.flockInfo.batches),
                    child: _buildStatColumn('Flock', farm.flockInfo.flockSize.toString()),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showEditFlockDialog(context, farm.flockInfo.flockSize, farm.flockInfo.batches),
                    child: _buildStatColumn('Batches', farm.flockInfo.batches.toString()),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showLogMortalityDialog(context),
                    child: _buildStatColumn('Deaths', farm.totalMortalityThisWeek.toString(), color: const Color(0xFFE05050)),
                  ),
                  _buildAlertBadge(context, 1), 
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('QUICK OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            
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
                                    color: (stat['color'] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(stat['icon'] as IconData, color: stat['color'] as Color),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stat['label'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text(stat['value'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (stat['badgeColor'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: (stat['badgeColor'] as Color).withOpacity(0.5)),
                              ),
                              child: Text(stat['badge'] as String, style: TextStyle(color: stat['badgeColor'] as Color, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(stat['sub'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stat['progress'] as double,
                          backgroundColor: Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(stat['color'] as Color),
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                  ),
                )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color color = const Color(0xFF2A3A00)}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildAlertBadge(BuildContext context, int alertCount) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showAlertsPanel(context),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, size: 28, color: Color(0xFF2A3A00)),
              if (alertCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      alertCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Alerts', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
            color: Colors.white.withOpacity(0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}