import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/services/backup_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool _backupLoading = false;
  bool _restoreLoading = false;

  // ─── BACKUP ────────────────────────────────────────────────────────────────

  Future<void> _handleExport() async {
    setState(() => _backupLoading = true);
    final db = context.read<HabitDatabase>();
    final success = await BackupService.exportBackup(context, db);
    setState(() => _backupLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Export failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleImport() async {
    // Warn user first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Backup',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        content: const Text(
          'This will ADD all habits from your backup file to your current habits. Existing habits will not be deleted.\n\nMake sure you select a valid .json backup file.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9370DB),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Pick File'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _restoreLoading = true);
    final db = context.read<HabitDatabase>();

    try {
      final count = await BackupService.importBackup(context, db);
      setState(() => _restoreLoading = false);

      if (count == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Restored $count habit${count == 1 ? '' : 's'} successfully!'),
            backgroundColor: const Color(0xFF9370DB),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on FormatException {
      setState(() => _restoreLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid backup file. Please use a valid backup.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _restoreLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 28,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFE6E6FA),
                  child: const FaIcon(
                    FontAwesomeIcons.user,
                    size: 35,
                    color: Color(0xFF9370DB),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since ${_getJoinDate()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account Settings
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 12),

          _buildSettingsTile(
            icon: FontAwesomeIcons.envelope,
            title: 'Change Email',
            subtitle: user?.email ?? '',
            onTap: () => _showChangeEmailDialog(),
          ),

          _buildSettingsTile(
            icon: FontAwesomeIcons.lock,
            title: 'Change Password',
            subtitle: '••••••••',
            onTap: () => _showChangePasswordDialog(),
          ),

          const SizedBox(height: 24),

          // App Settings
          _sectionLabel('APP SETTINGS'),
          const SizedBox(height: 12),

          _buildSwitchTile(
            icon: FontAwesomeIcons.bell,
            title: 'Notifications',
            subtitle: 'Daily habit reminders',
            value: notificationsEnabled,
            onChanged: (value) => setState(() => notificationsEnabled = value),
          ),

          _buildSwitchTile(
            icon: FontAwesomeIcons.moon,
            title: 'Dark Mode',
            subtitle: 'Coming soon',
            value: darkModeEnabled,
            onChanged: (value) => setState(() => darkModeEnabled = value),
          ),

          const SizedBox(height: 24),

          // ✅ NEW: Backup & Restore
          _sectionLabel('BACKUP & RESTORE'),
          const SizedBox(height: 12),

          // Export card
          _buildBackupCard(
            icon: FontAwesomeIcons.fileExport,
            iconColor: const Color(0xFF4CAF50),
            title: 'Export Backup',
            subtitle: 'Save all habits & history as a .json file',
            buttonLabel: 'Export',
            buttonColor: const Color(0xFF4CAF50),
            isLoading: _backupLoading,
            onTap: _handleExport,
          ),

          const SizedBox(height: 12),

          // Import card
          _buildBackupCard(
            icon: FontAwesomeIcons.fileImport,
            iconColor: const Color(0xFF9370DB),
            title: 'Restore Backup',
            subtitle: 'Import habits from a .json backup file',
            buttonLabel: 'Restore',
            buttonColor: const Color(0xFF9370DB),
            isLoading: _restoreLoading,
            onTap: _handleImport,
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _sectionLabel('DANGER ZONE', color: Colors.red),
          const SizedBox(height: 12),

          _buildSettingsTile(
            icon: FontAwesomeIcons.userSlash,
            title: 'Deactivate Account',
            subtitle: 'Temporarily disable your account',
            iconColor: Colors.orange,
            onTap: () => _showDeactivateDialog(),
          ),

          _buildSettingsTile(
            icon: FontAwesomeIcons.trash,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            iconColor: Colors.red,
            onTap: () => _showDeleteDialog(),
          ),

          const SizedBox(height: 32),

          // About Section
          _sectionLabel('ABOUT'),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 185, 185, 235),
                  Color.fromARGB(255, 251, 245, 195)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE6E6FA).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const FaIcon(FontAwesomeIcons.seedling,
                    size: 50, color: Colors.white),
                const SizedBox(height: 16),
                const Text('Mini Habit Tracker',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Version 1.0.0',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 20),
                Container(
                    height: 1,
                    width: 100,
                    color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 20),
                const Text('Developed by Nafisa Anjum',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text('© ${DateTime.now().year} All rights reserved',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {Color color = Colors.black54}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBackupCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, color: iconColor, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                  ),
                )
              : ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(buttonLabel,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: FaIcon(icon,
            color: iconColor ?? const Color(0xFF9370DB), size: 20),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: FaIcon(icon, color: const Color(0xFF9370DB), size: 20),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF9370DB),
      ),
    );
  }

  String _getJoinDate() {
    if (user?.metadata.creationTime != null) {
      final date = user!.metadata.creationTime!;
      return '${date.month}/${date.year}';
    }
    return 'Unknown';
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Email',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new email and current password',
                style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'New Email',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Current Password',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: passwordController.text,
                );
                await user!.reauthenticateWithCredential(credential);
                await user!.updateEmail(emailController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Email updated successfully!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFACD),
              foregroundColor: Colors.black87,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Current Password',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'New Password',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm New Password',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Passwords do not match!')),
                );
                return;
              }
              try {
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: currentPasswordController.text,
                );
                await user!.reauthenticateWithCredential(credential);
                await user!.updatePassword(newPasswordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password updated successfully!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFACD),
              foregroundColor: Colors.black87,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation,
                color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text('Deactivate Account',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'This will temporarily disable your account. You can reactivate it by logging in again.',
                style: TextStyle(color: Colors.black54)),
            SizedBox(height: 12),
            Text('Your data will be preserved.',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation,
                color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text('Delete Account',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This action is PERMANENT and cannot be undone!',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'All your habits, progress, and data will be permanently deleted.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter password to confirm',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: passwordController.text,
                );
                await user!.reauthenticateWithCredential(credential);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .delete();
                await user!.delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Account deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}