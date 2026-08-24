import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'profile/notifications_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/addresses_screen.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late ScrollController _scrollController;
  late Animation<double> _avatarPositionAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _contentSlideAnimation;

  double _scrollOffset = 0.0;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _avatarPositionAnimation = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceController.forward();
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_uploadingPhoto) return;

    // Check Cloudinary is configured
    if (!CloudinaryService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloudinary not configured yet. Add your cloud name and preset.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
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
      String? photoUrl;
      final auth = context.read<AppAuthProvider>();
      final uid = auth.user?.uid ?? 'unknown';

      // readAsBytes() works on both web and mobile via XFile
      final bytes = await picked.readAsBytes();
      photoUrl = await CloudinaryService.uploadBytes(
        bytes,
        picked.name,
        folder: 'rudram/profiles',
        publicId: 'profile_$uid',
      );

      if (photoUrl != null && mounted) {
        // Optimise to 400px avatar
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
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload failed. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // We rely on Theme.of(context) so no direct provider access needed here for styling
    // unless logic depends on it. background color handled by Scaffold default from Theme.

    return Scaffold(
      // Background handled by Theme (white/black)
      body: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: -_scrollOffset * 0.5,
                left: 0,
                right: 0,
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryOrange.withValues(alpha: 0.9),
                        AppColors.primaryOrangeLight.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: _circleOverlay(200, 0.1),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: _circleOverlay(150, 0.08),
                      ),
                    ],
                  ),
                ),
              ),
              CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          200 + (_avatarPositionAnimation.value * screenHeight),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -50),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: _pickAndUploadPhoto,
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: 'profile_avatar',
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(
                                          context.watch<AppAuthProvider>().photoUrl ??
                                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(context.watch<AppAuthProvider>().displayName)}&background=F37A20&color=fff&size=200',
                                        ),
                                      ),
                                    ),
                                    // Upload loading overlay
                                    if (_uploadingPhoto)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black45,
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Camera icon badge
                                    if (!_uploadingPhoto)
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryOrange,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.watch<AppAuthProvider>().displayName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.watch<AppAuthProvider>().email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _contentOpacityAnimation,
                      child: SlideTransition(
                        position: _contentSlideAnimation,
                        child: _buildProfileContent(context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ), // Bottom padding
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _circleOverlay(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            delay: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildStatsRow(context),
              const SizedBox(height: 24),
              _buildQuickActionsCarousel(context),
              const SizedBox(height: 24),
              _buildMenuSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final opacity = (1 - (_scrollOffset / 100)).clamp(0.3, 1.0);
    final int ordersCount = context.watch<OrdersProvider>().orders.length;
    final int wishlistCount = context.watch<WishlistProvider>().items.length;

    return Opacity(
      opacity: opacity,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              ordersCount.toString(),
              "Orders",
              Icons.shopping_bag_outlined,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              wishlistCount.toString(),
              "Wishlist",
              Icons.favorite_outline,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              "₹4.2K",
              "Rewards",
              Icons.card_giftcard_outlined,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildActionCard(
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
              const SizedBox(width: 12),
              _buildActionCard(
                context,
                "Addresses",
                Icons.location_on_outlined,
                Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddressesScreen()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionCard(
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
            ],
          ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.8), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
                  color: Colors.purple.withValues(alpha: 0.1),
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
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
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
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
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
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
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
        const SizedBox(height: 100), // Padding to clear bottom nav bar
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
                    color: Colors.black.withValues(alpha: 0.04),
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
                color: color.withValues(alpha: 0.1),
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
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.4), size: 20),
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
        color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15),
      ),
    );
  }
}
