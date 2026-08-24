import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'luxury_home_content.dart';
import 'luxury_shop_screen.dart';
import 'luxury_concierge_screen.dart';
import 'luxury_wishlist_screen.dart';
import 'luxury_profile_screen.dart';
import 'watch_and_shop_screen.dart';
import 'reels_screen.dart';

class LuxuryScreen extends StatefulWidget {
  const LuxuryScreen({super.key});

  @override
  State<LuxuryScreen> createState() => _LuxuryScreenState();
}

class _LuxuryScreenState extends State<LuxuryScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  // Screen mapping: 0:Home, 1:Shop, 2:Wishlist, 3:Profile.
  List<Widget> get _screens => [
    const LuxuryHomeContent(),
    const LuxuryShopScreen(),
    const LuxuryWishlistScreen(),
    const LuxuryProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );
    _loadingController.repeat(reverse: true);

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _loadingController.stop();
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _showMenuSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "E X C L U S I V E   A C C E S S",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  letterSpacing: 3,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.video_library_outlined,
                      "Watch & Shop",
                      "Immersive video shopping",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WatchAndShopScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.play_circle_outline,
                      "Reels Gallery",
                      "Discover trends",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReelsScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.chat_bubble_outline,
                      "Concierge Service",
                      "24/7 Personal Assistance",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LuxuryConciergeScreen(),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    _buildMenuItem(
                      context,
                      Icons.settings_outlined,
                      "Settings",
                      "App preferences",
                      () {},
                    ),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      "Support",
                      "FAQs & Contact",
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
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Playfair Display',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFFD4AF37),
        size: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FadeTransition(
            opacity: _loadingAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: Color(0xFFD4AF37),
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  "R U D R A M",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 8,
                    fontSize: 24,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "L U X U R Y",
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                    letterSpacing: 4,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[900],
                    color: const Color(0xFFD4AF37),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,

      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () => _showMenuSlider(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.black, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          height: 75,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Tabs (Home, Shop)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: GNav(
                        rippleColor: Colors.grey[800]!,
                        hoverColor: Colors.grey[900]!,
                        gap: 4, 
                        activeColor: const Color(0xFFD4AF37),
                        iconSize: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        duration: const Duration(milliseconds: 300),
                        tabBackgroundColor: const Color(0xFF1A1A1A),
                        color: Colors.grey[600],
                        tabs: const [
                          GButton(icon: Icons.home_filled, text: 'Home'),
                          GButton(icon: Icons.storefront, text: 'Shop'),
                        ],
                        selectedIndex: _selectedIndex < 2 ? _selectedIndex : -1,
                        onTabChange: (index) => setState(() => _selectedIndex = index),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 40), 

                // Right Tabs (Wishlist, Profile)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: GNav(
                        rippleColor: Colors.grey[800]!,
                        hoverColor: Colors.grey[900]!,
                        gap: 4,
                        activeColor: const Color(0xFFD4AF37),
                        iconSize: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        duration: const Duration(milliseconds: 300),
                        tabBackgroundColor: const Color(0xFF1A1A1A),
                        color: Colors.grey[600],
                        tabs: const [
                          GButton(icon: Icons.favorite_border, text: 'Wishlist'),
                          GButton(icon: Icons.person_outline, text: 'Profile'),
                        ],
                        selectedIndex: _selectedIndex >= 2 ? _selectedIndex - 2 : -1,
                        onTabChange: (index) => setState(() => _selectedIndex = index + 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
    );
  }
}
