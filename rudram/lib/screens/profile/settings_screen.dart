import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../services/firestore_service.dart';
import '../home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailPromotions = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final auth = context.read<AppAuthProvider>();
    if (auth.user != null) {
      final profile = await FirestoreService().getUserProfile(auth.user!.uid);
      if (profile != null && mounted) {
        setState(() {
          _pushNotifications = profile['pushNotifications'] ?? true;
          _emailPromotions = profile['emailPromotions'] ?? false;
          _selectedLanguage = profile['language'] ?? 'English';
        });
      }
    }
  }

  Future<void> _savePreference({bool? push, bool? email, String? lang}) async {
    final auth = context.read<AppAuthProvider>();
    if (auth.user != null) {
      await FirestoreService().updateUserProfile(
        uid: auth.user!.uid,
        pushNotifications: push,
        emailPromotions: email,
        language: lang,
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) async {
    final auth = context.read<AppAuthProvider>();
    final user = auth.user;
    if (user == null) return;

    // Fetch existing profile data
    final profile = await FirestoreService().getUserProfile(user.uid);
    
    final nameController = TextEditingController(text: auth.displayName);
    final phoneController = TextEditingController(text: profile?['phone'] ?? '');
    final bioController = TextEditingController(text: profile?['bio'] ?? '');

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Display Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await auth.updateProfile(nameController.text.trim());
                await auth.updateExtendedProfile(
                  phone: phoneController.text.trim(),
                  bio: bioController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final auth = context.read<AppAuthProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (currentPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                final success = await auth.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(auth.errorMessage ?? 'Failed to change password'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Hindi', 'Gujarati', 'Marathi'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                _savePreference(lang: val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Account"),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: const Text("Edit Profile Name"),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showEditProfileDialog(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.purple),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionHeader("Preferences"),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined, color: Colors.deepPurple),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.black87,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language_outlined, color: Colors.teal),
              title: const Text("Language"),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showLanguageDialog,
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader("Notifications"),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: Colors.orange),
              title: const Text("Push Notifications"),
              subtitle: const Text("Order updates and alerts"),
              trailing: Switch(
                value: _pushNotifications,
                onChanged: (val) {
                  setState(() => _pushNotifications = val);
                  _savePreference(push: val);
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryOrange,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.blue),
              title: const Text("Email Promotions"),
              subtitle: const Text("Special offers and news"),
              trailing: Switch(
                value: _emailPromotions,
                onChanged: (val) {
                  setState(() => _emailPromotions = val);
                  _savePreference(email: val);
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryOrange,
              ),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader("Danger Zone"),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: const Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Account?", style: TextStyle(color: Colors.red)),
                    content: const Text("This action is permanent and cannot be undone. All your data will be lost."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final auth = context.read<AppAuthProvider>();
                          final success = await auth.deleteAccount();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Account deleted successfully.")),
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          } else if (mounted && auth.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
