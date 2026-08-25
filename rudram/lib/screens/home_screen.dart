import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_tab.dart';
import 'cart_screen.dart';
import 'shop_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

import 'watch_and_shop_screen.dart';
import 'celebrity_style_screen.dart';
import 'desktop/desktop_home_screen.dart';
import '../widgets/responsive_layout.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(onSearchTap: () => _onItemTapped(1)),
      const ShopScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2 || index == 3) {
      final auth = context.read<AppAuthProvider>();
      if (!auth.isAuthenticated) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from Bottom/Right with Fade
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  void _showMenuSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "M O R E",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.play_circle_outline,
                      "Reels",
                      "Watch trends",
                      () => Navigator.push(
                        context,
                        _createRoute(const WatchAndShopScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.shopping_bag_outlined,
                      "Cart",
                      "View your bag",
                      () => Navigator.push(
                        context,
                        _createRoute(const CartScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.star_outline,
                      "Celebrity Style",
                      "Shop the trends",
                      () => Navigator.push(
                        context,
                        _createRoute(const CelebrityStyleScreen()),
                      ),
                    ),
                    const Divider(),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      "Help",
                      "Support center",
                      () {},
                    ),
                    _buildMenuItem(
                      context,
                      Icons.settings_outlined,
                      "Settings",
                      "Preferences",
                      () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryOrange, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      desktopBody: const DesktopHomeScreen(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      extendBody: true, // Content behind nav bar
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
