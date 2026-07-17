import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/farm_provider.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _biometricLogin = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Loads the saved toggle states when the screen opens
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pushNotifications = prefs.getBool('push_notifications') ?? true;
        _biometricLogin = prefs.getBool('biometric_login') ?? false;
      });
    }
  }

  // Toggles notifications and saves the choice
  Future<void> _togglePushNotifications(bool val) async {
    setState(() => _pushNotifications = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', val);
    
    if (val) {
      NotificationService.scheduleDailyReminders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily reminders enabled')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily reminders disabled')));
    }
  }

  // Toggles biometrics and saves the choice
  Future<void> _toggleBiometrics(bool val) async {
    setState(() => _biometricLogin = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_login', val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? 'Biometric login enabled' : 'Biometric login disabled')));
    }
  }

  // --- NEW: Smart Password Manager ---
  Future<void> _handleChangePasswordTap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check if the user signed in using Google
    bool isGoogleUser = user.providerData.any((provider) => provider.providerId == 'google.com');

    if (isGoogleUser) {
      // Show professional Google notice
      _showInfoDialog(
        'Google Security Linked', 
        'Your PoultryPro account is securely linked to your Google Account.\n\nTo change your password, please update your security settings directly through your Google Account dashboard.'
      );
    } else {
      // Show manual password change dialog for standard email users
      _showManualPasswordChangeDialog(user);
    }
  }

  // --- NEW: Manual Password Change Dialog ---
  void _showManualPasswordChangeDialog(User user) {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null) ...[
                    Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: oldPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9A00)),
                onPressed: isLoading ? null : () async {
                  // 1. Basic Validation
                  if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                    setModalState(() => errorMessage = 'New passwords do not match.');
                    return;
                  }
                  if (newPasswordCtrl.text.length < 6) {
                    setModalState(() => errorMessage = 'Password must be at least 6 characters long.');
                    return;
                  }

                  setModalState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  try {
                    // 2. Re-authenticate the user (Firebase requires this to ensure it's actually them)
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: oldPasswordCtrl.text.trim(),
                    );
                    await user.reauthenticateWithCredential(credential);

                    // 3. Update the password
                    await user.updatePassword(newPasswordCtrl.text.trim());

                    if (context.mounted) {
                      Navigator.pop(context); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Password updated successfully!'),
                        backgroundColor: Color(0xFF7A9A00),
                      ));
                    }
                  } on FirebaseAuthException catch (e) {
                    setModalState(() {
                      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                        errorMessage = 'Incorrect current password.';
                      } else {
                        errorMessage = e.message ?? 'An error occurred. Please try again.';
                      }
                    });
                  } finally {
                    setModalState(() => isLoading = false);
                  }
                },
                child: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Password', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  // Shows a popup for the legal/about text
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
        content: Text(content, style: const TextStyle(color: Colors.black87, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF7A9A00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF2A2000), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2000)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf4f0aa), Color(0xFFe8f5c0), Color(0xFFd4ebb8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('PREFERENCES'),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        value: _pushNotifications,
                        onChanged: _togglePushNotifications,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('SECURITY'),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildArrowTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: _handleChangePasswordTap, // <-- Hooked up the new smart function
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.fingerprint,
                        title: 'Biometric Login',
                        value: _biometricLogin,
                        onChanged: _toggleBiometrics,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('ABOUT'),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildArrowTile(
                        icon: Icons.info_outline,
                        title: 'Privacy Policy',
                        onTap: () => _showInfoDialog('Privacy Policy', 'Your data is securely stored using Firebase. We do not share your flock or financial data with third parties. All your records belong to you.'),
                      ),
                      _buildDivider(),
                      _buildArrowTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () => _showInfoDialog('Terms of Service', 'By using PoultryPro, you agree to log your farm data responsibly. Ensure accurate inputs for the best analytical results and health tracking.'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                _buildLogoutButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x803C320A), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7A9A00)), 
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
      trailing: CupertinoSwitch(activeTrackColor: const Color(0xFF7A9A00), value: value, onChanged: onChanged),
    );
  }

  Widget _buildArrowTile({required IconData icon, required String title, String? trailingText, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF7A9A00)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          if (trailingText != null) const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, endIndent: 16, color: Colors.black.withValues(alpha: 0.05));
  }

 Widget _buildLogoutButton(BuildContext context) {
    return _buildGlassContainer(
      child: ListTile(
        onTap: () async {
          // --- FIX: Force biometrics OFF when logging out ---
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('biometric_login', false);

          context.read<FarmProvider>().clearData();
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        leading: const Icon(Icons.logout, color: Color(0xFFE05050)),
        title: const Text('Log Out', style: TextStyle(color: Color(0xFFE05050), fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFE05050)),
      ),
    );
  }
}