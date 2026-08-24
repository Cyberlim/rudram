import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OurFeaturesSection extends StatelessWidget {
  const OurFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Fast Delivery',
        'subtitle': 'Within 24hrs',
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Secure Payment',
        'subtitle': '100% Safe',
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'title': 'Certified',
        'subtitle': 'BIS Hallmark',
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': '24/7 Support',
        'subtitle': 'Always Here',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((feature) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  feature['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
