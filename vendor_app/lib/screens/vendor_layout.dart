import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'earnings_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';
import 'analytics_screen.dart';
import 'inventory_screen.dart';
import 'reviews_screen.dart';
import 'coupons_screen.dart';
import '../services/notification_service.dart';

class VendorLayout extends StatefulWidget {
  final Map<String, dynamic> vendorData;
  const VendorLayout({super.key, required this.vendorData});

  @override
  State<VendorLayout> createState() => _VendorLayoutState();
}

class _VendorLayoutState extends State<VendorLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const DashboardContent(),          // 0
    const ProductsScreen(),            // 1
    const OrdersScreen(),              // 2
    const EarningsScreen(),            // 3
    const AnalyticsScreen(),           // 4
    const InventoryScreen(),           // 5
    const ReviewsScreen(),             // 6
    const CouponsScreen(),             // 7
    const SettingsScreen(),            // 8
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // If we're on mobile and the drawer is open, close it
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7FE),
      // Only show drawer on mobile/tablet
      drawer: isDesktop
          ? null
          : Drawer(
              child: VendorSidebar(
                vendorData: widget.vendorData,
                selectedIndex: _selectedIndex,
                onItemSelected: _onItemSelected,
              ),
            ),
      body: Row(
        children: [
          // Sidebar fixed on desktop
          if (isDesktop)
            VendorSidebar(
              vendorData: widget.vendorData,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          Expanded(
            child: Column(
              children: [
                // TopBar is slightly different on mobile vs desktop
                VendorTopBar(
                  vendorData: widget.vendorData,
                  isDesktop: isDesktop,
                  onMenuTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedIndex < 3 ? _selectedIndex : 0, // Fallback to 0 if an unlisted option is selected
              onTap: _onItemSelected,
              selectedItemColor: const Color(0xFF2A1C40),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
              ],
            )
          : null,
    );
  }
}

class VendorTopBar extends StatelessWidget {
  final Map<String, dynamic> vendorData;
  final bool isDesktop;
  final VoidCallback onMenuTap;
  
  const VendorTopBar({
    super.key, 
    required this.vendorData, 
    required this.isDesktop,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    String ownerName = vendorData['ownerName'] ?? 'Vendor';
    String businessType = vendorData['businessType'] ?? 'Vendor';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: onMenuTap,
            )
          else
            const Icon(Icons.menu, color: Colors.transparent), // Placeholder for spacing
          
          if (isDesktop) const SizedBox(width: 24),
          
          // Search Bar (Hide on very small mobile if space is tight, but we'll try to show it)
          if (MediaQuery.of(context).size.width > 400)
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            )
          else 
            const Spacer(),
            
          const SizedBox(width: 16),
          // Actions and Profile
          Row(
            children: [
              // Notifications
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                },
                borderRadius: BorderRadius.circular(20),
                child: StreamBuilder<int>(
                  stream: NotificationService().getUnreadCount(vendorData['uid'] ?? vendorData['vendorId'] ?? 'vendor123'),
                  builder: (context, snapshot) {
                    int count = snapshot.data ?? 0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.notifications_none, color: Colors.black87),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                              child: Text(count > 9 ? '9+' : count.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          )
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
                },
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.chat_bubble_outline, color: Colors.black87),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                        child: const Text("2", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.pink.shade100,
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(businessType, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                  ],
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class VendorSidebar extends StatelessWidget {
  final Map<String, dynamic> vendorData;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const VendorSidebar({
    super.key,
    required this.vendorData,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    String ownerName = vendorData['ownerName'] ?? 'Vendor';
    String businessType = vendorData['businessType'] ?? 'Vendor';
    bool isKycVerified = vendorData['isKycVerified'] ?? false;

    return Container(
      width: 260,
      color: const Color(0xFF2A1846),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined,
                    color: Color(0xFFFFD700), size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jwellry",
                      style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: const Color(0xFFFFD700)),
                    ),
                    const Text("Vendor Panel",
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(Icons.dashboard, "Dashboard", 0),
                _buildNavItem(Icons.inventory_2_outlined, "Products", 1, hasDropdown: true),
                _buildNavItem(Icons.shopping_bag_outlined, "Orders", 2, badge: "12"),
                _buildNavItem(Icons.account_balance_wallet_outlined, "Earnings", 3),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 8),
                  child: Divider(color: Colors.white24),
                ),
                _buildNavItem(Icons.analytics_outlined, "Analytics", 4),
                _buildNavItem(Icons.inventory, "Inventory", 5),
                _buildNavItem(Icons.star_outline, "Reviews", 6, badge: "18"),
                _buildNavItem(Icons.local_offer_outlined, "Coupons", 7),
                _buildNavItem(Icons.settings_outlined, "Store Settings", 8),
              ],
            ),
          ),

          // Bottom Profile Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.pink.shade100,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(businessType, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      if (isKycVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 10),
                              SizedBox(width: 4),
                              Text("Verified", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index, {String? badge, bool hasDropdown = false}) {
    bool isActive = selectedIndex == index;
    Color primaryColor = const Color(0xFFFFD700);

    return InkWell(
      onTap: () {
        if (index <= 8) {
          onItemSelected(index);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? primaryColor : Colors.white70, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? primaryColor : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            if (hasDropdown)
              const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
