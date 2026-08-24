import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../orders_screen.dart';
import '../wishlist_screen.dart';
import '../wallet_screen.dart';
import 'desktop_notifications_page.dart';
import 'desktop_settings_page.dart';
import 'desktop_help_support_page.dart';

class DesktopProfilePage extends StatefulWidget {
  const DesktopProfilePage({super.key});

  @override
  State<DesktopProfilePage> createState() => _DesktopProfilePageState();
}

class _DesktopProfilePageState extends State<DesktopProfilePage> {
  bool _uploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    if (_uploadingPhoto) return;

    if (!CloudinaryService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloudinary not configured yet.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final auth = context.read<AppAuthProvider>();
      final uid = auth.user?.uid ?? 'unknown';

      final bytes = await picked.readAsBytes();
      final photoUrl = await CloudinaryService.uploadBytes(
        bytes,
        picked.name,
        folder: 'rudram/profiles',
        publicId: 'profile_$uid',
      );

      if (photoUrl != null && mounted) {
        final optimisedUrl = CloudinaryService.toOptimisedUrl(
          photoUrl,
          width: 400,
          height: 400,
        );
        await auth.updateProfilePhoto(optimisedUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated! ✨'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AppAuthProvider>();
    final nameController = TextEditingController(text: auth.displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Display Name",
            border: OutlineInputBorder(),
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
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const DesktopHeader(cartCount: 0),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar
                  SizedBox(
                    width: 350,
                    child: _buildMenuSection(context),
                  ),
                  const SizedBox(width: 40),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(context),
                        const SizedBox(height: 40),
                        _buildQuickActions(context),
                        const SizedBox(height: 40),
                        _buildProfileStats(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAndUploadPhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryOrangeLight,
                  backgroundImage: auth.photoUrl != null
                      ? NetworkImage(auth.photoUrl!)
                      : null,
                  child: auth.photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                if (_uploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                if (!_uploadingPhoto)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryOrange,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  auth.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    foregroundColor: Colors.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "My Orders",
                Icons.receipt_long_outlined,
                Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionCard(
                context,
                "Addresses",
                Icons.location_on_outlined,
                Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Addresses coming soon!")),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionCard(
                context,
                "Payment",
                Icons.payment_outlined,
                Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WalletScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    {VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    final orderCount = context.watch<OrdersProvider>().orders.length;
    final wishlistCount = context.watch<WishlistProvider>().items.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Orders", orderCount.toString()),
          _buildDividerVert(),
          _buildStatItem("Wishlist", wishlistCount.toString()),
          _buildDividerVert(),
          _buildStatItem("Coupons", "3"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerVert() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final int wishlistCount = context.watch<WishlistProvider>().items.length;

    return Column(
      children: [
        _buildMenuGroup(
          "SHOPPING & ACCOUNT",
          [
            _buildMenuItem(
              context,
              Icons.history_outlined,
              "Order History",
              Colors.blue,
              subtitle: "View your recent purchases.",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            _buildDivider(context),
            _buildMenuItem(
              context,
              Icons.favorite_border,
              "My Wishlist",
              Colors.red,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              },
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$wishlistCount items",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildMenuGroup(
          "SYSTEM & PREFERENCES",
          [
            _buildMenuItem(
              context,
              Icons.dark_mode_outlined,
              "Dark Mode",
              Colors.deepPurple,
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeColor: Colors.white,
                activeTrackColor: Colors.black87,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ),
            _buildDivider(context),
            _buildMenuItem(
              context,
              Icons.notifications_outlined,
              "Notifications",
              Colors.orange,
              subtitle: "Manage your alert preferences.",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DesktopNotificationsPage()),
                );
              },
            ),
            _buildDivider(context),
            _buildMenuItem(
              context,
              Icons.settings_outlined,
              "Settings",
              Colors.grey,
              subtitle: "Account security and app data.",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DesktopSettingsPage()),
                );
              },
            ),
          ],
        ),
        _buildMenuGroup(
          "SUPPORT & LOGOUT",
          [
            _buildMenuItem(
              context,
              Icons.help_outline,
              "Help & Support",
              Colors.green,
              subtitle: "Contact us or view FAQs.",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DesktopHelpSupportPage()),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.logout,
              "Logout",
              Colors.red,
              solidBackground: true,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AppAuthProvider>().signOut();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> children) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
              ],
              border: isDark ? Border.all(color: Colors.white12) : null,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    String? subtitle,
    Widget? trailing,
    bool solidBackground = false,
    VoidCallback? onTap,
  }) {
    if (solidBackground) {
      return InkWell(
        onTap: onTap ?? () {},
        child: Container(
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.15),
      ),
    );
  }
}
