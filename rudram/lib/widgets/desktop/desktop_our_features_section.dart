import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class DesktopOurFeaturesSection extends StatelessWidget {
  const DesktopOurFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(32),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(context: context, 
              icon: Icons.verified_outlined,
              title: '100% Certified',
              subtitle: 'Authenticity certificates with every precious piece',
            ),
            _buildVerticalDivider(),
            _buildFeatureItem(context: context, 
              icon: Icons.local_shipping_outlined,
              title: 'Free Shipping',
              subtitle: 'Insured worldwide delivery on all orders',
            ),
            _buildVerticalDivider(),
            _buildFeatureItem(context: context, 
              icon: Icons.change_circle_outlined,
              title: 'Easy Exchange',
              subtitle: '10 Days hassle-free returns & easy exchange',
            ),
            _buildVerticalDivider(),
            _buildFeatureItem(context: context, 
              icon: Icons.support_agent_outlined,
              title: 'Personal Stylist',
              subtitle: 'Dedicated expert support for your selections',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey.shade200,
    );
  }

  Widget _buildFeatureItem({required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 30),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
