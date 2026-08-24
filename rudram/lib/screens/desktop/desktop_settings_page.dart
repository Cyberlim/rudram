import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/desktop/desktop_header.dart';

class DesktopSettingsPage extends StatefulWidget {
  const DesktopSettingsPage({super.key});

  @override
  State<DesktopSettingsPage> createState() => _DesktopSettingsPageState();
}

class _DesktopSettingsPageState extends State<DesktopSettingsPage> {
  bool _pushNotifications = true;
  bool _emailPromotions = false;
  String _selectedLanguage = 'English';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Bio",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Select Language", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Hindi', 'Gujarati', 'Marathi'].map((lang) {
              return RadioListTile<String>(
                title: Text(lang, style: const TextStyle(fontWeight: FontWeight.w500)),
                value: lang,
                groupValue: _selectedLanguage,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) {
                  setState(() => _selectedLanguage = val!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const DesktopHeader(cartCount: 0),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildSectionHeader("Account"),
                      _buildSettingsCard([
                        _buildSettingsRow(
                          icon: Icons.person_outline,
                          iconColor: Colors.blue,
                          title: "Edit Profile Name",
                          onTap: () => _showEditProfileDialog(context),
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Icons.lock_outline,
                          iconColor: Colors.purple,
                          title: "Change Password",
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                      ]),

                      const SizedBox(height: 32),
                      _buildSectionHeader("Preferences"),
                      _buildSettingsCard([
                        _buildSettingsRow(
                          icon: Icons.dark_mode_outlined,
                          iconColor: Colors.deepPurple,
                          title: "Dark Mode",
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) => themeProvider.toggleTheme(value),
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.black87,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Icons.language_outlined,
                          iconColor: Colors.teal,
                          title: "Language",
                          subtitle: _selectedLanguage,
                          onTap: _showLanguageDialog,
                        ),
                      ]),

                      const SizedBox(height: 32),
                      _buildSectionHeader("Notifications"),
                      _buildSettingsCard([
                        _buildSettingsRow(
                          icon: Icons.notifications_active_outlined,
                          iconColor: Colors.orange,
                          title: "Push Notifications",
                          subtitle: "Order updates and alerts",
                          trailing: Switch(
                            value: _pushNotifications,
                            onChanged: (val) => setState(() => _pushNotifications = val),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primaryOrange,
                          ),
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Icons.email_outlined,
                          iconColor: Colors.blue,
                          title: "Email Promotions",
                          subtitle: "Special offers and news",
                          trailing: Switch(
                            value: _emailPromotions,
                            onChanged: (val) => setState(() => _emailPromotions = val),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primaryOrange,
                          ),
                        ),
                      ]),

                      const SizedBox(height: 32),
                      _buildSectionHeader("Danger Zone", color: Colors.red),
                      _buildSettingsCard([
                        _buildSettingsRow(
                          icon: Icons.delete_forever_outlined,
                          iconColor: Colors.red,
                          title: "Delete Account",
                          titleColor: Colors.red,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text("Delete Account?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                content: const Text(
                                  "This action is permanent and cannot be undone. All your data will be lost.",
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Account deletion requested.")),
                                      );
                                    },
                                    child: const Text("Delete Account"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ]),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.grey[500],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: titleColor != null ? FontWeight.bold : FontWeight.w600,
                      color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.5), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 80, right: 24),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15),
      ),
    );
  }
}
