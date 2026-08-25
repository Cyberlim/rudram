import 'package:flutter/material.dart';
import 'luxury_order_history_screen.dart';
import 'luxury_payment_methods_screen.dart';
import 'luxury_shipping_addresses_screen.dart';
import 'luxury_notification_preferences_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LuxuryProfileScreen extends StatelessWidget {
  const LuxuryProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final userName = auth.displayName;
    final userPhoto = auth.photoUrl ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userPhoto),
              ),
              const SizedBox(height: 24),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Playfair Display',
                  fontSize: 32,
                ),
              ),
              const Text(
                "ELITE MEMBER",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  letterSpacing: 3,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 48),

              // Membership Card
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37),
                      Color(0xFFFEE190),
                      Color(0xFFB88A00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFD4AF37),
                      blurRadius: 20,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.diamond, size: 32),
                        Text(
                          "RUDRAM PRIVÉ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "8839  ••••  ••••  1029",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "VALID THRU 12/28",
                              style: TextStyle(fontSize: 12),
                            ),
                            Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1000px-Mastercard-logo.svg.png",
                              width: 40,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.credit_card),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              _buildSettingsTile(
                "Order History",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LuxuryOrderHistoryScreen())),
              ),
              _buildSettingsTile(
                "Payment Methods",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LuxuryPaymentMethodsScreen())),
              ),
              _buildSettingsTile(
                "Shipping Addresses",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LuxuryShippingAddressesScreen())),
              ),
              _buildSettingsTile(
                "Notification Preferences",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LuxuryNotificationPreferencesScreen())),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  await context.read<AppAuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text(
                  "LOG OUT",
                  style: TextStyle(
                    color: Colors.red,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
