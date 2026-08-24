import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/luxury_screen.dart';
import '../utils/globals.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome back",
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "Faran_uxui",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text("👋", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Luxury Mode Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LuxuryScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "LUXE",
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  Globals.appScaffoldKey.currentState?.openEndDrawer();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                ),
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.textGrey,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
