import 'package:flutter/material.dart';
import '../../screens/desktop/desktop_shop_page.dart';
import '../../screens/home_screen.dart';
import '../../screens/desktop/desktop_luxury_products_page.dart';
import '../../screens/desktop/desktop_rooms_page.dart';
import '../../screens/desktop/desktop_inspiration_page.dart';
import '../../screens/desktop/desktop_latest_page.dart';
import '../../screens/desktop/desktop_info_page.dart';
import '../../screens/desktop/desktop_reels_page.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../screens/desktop/desktop_profile_page.dart';
import '../../utils/globals.dart';
import '../../screens/luxury_wishlist_screen.dart';

class DesktopHeader extends StatelessWidget {
  final int cartCount;
  final VoidCallback? onCartTap;
  final bool isDark;

  const DesktopHeader({
    super.key,
    this.cartCount = 0,
    this.onCartTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    bool effectiveIsDark = isDark || isDarkTheme;
    
    Color bgColor = effectiveIsDark ? const Color(0xFF070707) : Colors.white;
    Color textColor = effectiveIsDark ? Colors.white : const Color(0xFF333333);
    Color iconColor = effectiveIsDark ? Colors.white : Colors.black87;
    Color searchBg = effectiveIsDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: effectiveIsDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Logo Approximation
          _buildLogo(context),

          const SizedBox(width: 40),

          // 2. Navigation Links
          _buildNavLink(context, 'Shop', isShop: true, textColor: textColor),
          _buildNavLink(
            context,
            'Products',
            isProducts: true,
            textColor: textColor,
          ),
          _buildNavLink(context, 'Rooms', isRooms: true, textColor: textColor),
          _buildNavLink(
            context,
            'Inspiration',
            isInspiration: true,
            textColor: textColor,
          ),
          _buildNavLink(
            context,
            'Latest',
            isLatest: true,
            textColor: textColor,
          ),
          _buildNavLink(context, 'Reels', isReels: true, textColor: textColor),
          _buildNavLink(context, 'Info', isInfo: true, textColor: textColor),

          const SizedBox(width: 40),

          // 3. Pill-shaped Search Bar
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: effectiveIsDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(color: textColor),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DesktopShopPage(
                                  initialSearchQuery: value.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'What are you looking for?',
                          hintStyle: TextStyle(
                            color: effectiveIsDark ? Colors.white24 : Colors.black38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 40),

          // 4. Action Icons
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DesktopProfilePage(),
              ));
            },
            child: _buildActionIcon(Icons.person_outline, color: iconColor),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LuxuryWishlistScreen(),
              ));
            },
            child: _buildActionIcon(Icons.favorite_outline, color: iconColor),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: onCartTap ?? () {
              Globals.appScaffoldKey.currentState?.openEndDrawer();
            },
            child: _buildCartIcon(context, iconColor: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'RUDRAM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String title, {
    bool isShop = false,
    bool isProducts = false,
    bool isRooms = false,
    bool isInspiration = false,
    bool isLatest = false,
    bool isReels = false,
    bool isInfo = false,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: () {
          Widget? targetPage;
          if (isShop) {
            targetPage = const DesktopShopPage();
          } else if (isProducts) {
            targetPage = const DesktopLuxuryProductsPage();
          } else if (isRooms) {
            targetPage = const DesktopRoomsPage();
          } else if (isInspiration) {
            targetPage = const DesktopInspirationPage();
          } else if (isLatest) {
            targetPage = const DesktopLatestPage();
          } else if (isReels) {
            targetPage = const DesktopReelsPage();
          } else if (isInfo) {
            targetPage = const DesktopInfoPage();
          }

          if (targetPage != null) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    targetPage!,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 0.05);
                      const end = Offset.zero;
                      const curve = Curves.easeOutCubic;

                      var slideTween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var fadeTween = Tween(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: curve));

                      return FadeTransition(
                        opacity: animation.drive(fadeTween),
                        child: SlideTransition(
                          position: animation.drive(slideTween),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        },
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {required Color color}) {
    return Icon(icon, size: 24, color: color);
  }

  Widget _buildCartIcon(BuildContext context, {required Color iconColor}) {
    final int count = context.watch<CartProvider>().itemCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.shopping_bag_outlined, size: 24, color: iconColor),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFF4848), // Red badge
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
