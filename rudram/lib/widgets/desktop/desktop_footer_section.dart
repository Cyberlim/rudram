import 'package:flutter/material.dart';
import '../../screens/desktop/desktop_shop_page.dart';
import '../../screens/blog_screen.dart';
import '../../screens/orders_screen.dart';
import '../../screens/desktop/desktop_info_page.dart';
import '../../screens/profile/help_support_screen.dart';
class DesktopFooterSection extends StatelessWidget {
  const DesktopFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 80,
        bottom: 40,
        left: 100,
        right: 100,
      ),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RUDRAM',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).cardColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Crafting timeless elegance for the modern soul. Every piece tells a story of tradition, luxury, and unmatched artistry.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildSocialIcon(context, Icons.facebook),
                        const SizedBox(width: 16),
                        _buildSocialIcon(
                          context,
                          Icons.camera_alt,
                        ), // Instagram placeholder
                        const SizedBox(width: 16),
                        _buildSocialIcon(
                          context,
                          Icons.near_me,
                        ), // Telegram/Twitter placeholder
                        const SizedBox(width: 16),
                        _buildSocialIcon(
                          context,
                          Icons.music_note,
                        ), // TikTok placeholder
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),

              // Links Columns
              Expanded(
                child: _buildFooterColumn(context, 'Shop', [
                  'New Arrivals',
                  'Best Sellers',
                  'Rings',
                  'Necklaces',
                  'Earrings',
                ]),
              ),
              Expanded(
                child: _buildFooterColumn(context, 'About', [
                  'Our Story',
                  'Craftsmanship',
                  'Designers',
                  'Sustainability',
                  'Blog',
                ]),
              ),
              Expanded(
                child: _buildFooterColumn(context, 'Support', [
                  'Contact Us',
                  'FAQs',
                  'Shipping policy',
                  'Returns',
                  'Track Order',
                ]),
              ),
            ],
          ),

          const SizedBox(height: 80),
          const Divider(color: Colors.white24),
          const SizedBox(height: 32),

          // Bottom Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2024 Rudram Jewels. All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Row(
                children: const [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Terms of Service',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                _handleFooterNavigation(context, item);
              },
              child: Text(
                item,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleFooterNavigation(BuildContext context, String item) {
    switch (item) {
      case 'New Arrivals':
      case 'Best Sellers':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DesktopShopPage()));
        break;
      case 'Rings':
      case 'Necklaces':
      case 'Earrings':
        Navigator.push(context, MaterialPageRoute(builder: (context) => DesktopShopPage(initialSearchQuery: item)));
        break;
      case 'Our Story':
      case 'Craftsmanship':
      case 'Designers':
      case 'Sustainability':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DesktopInfoPage()));
        break;
      case 'Blog':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BlogScreen()));
        break;
      case 'Contact Us':
      case 'FAQs':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
        break;
      case 'Track Order':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$item is coming soon!')),
        );
    }
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
