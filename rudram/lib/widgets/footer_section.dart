import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A), // Dark footer
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RUDRAM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Exquisite jewelry for every occasion. Crafted with passion, worn with pride.",
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFooterLink("About Us"),
              const SizedBox(width: 24),
              _buildFooterLink("Contact"),
              const SizedBox(width: 24),
              _buildFooterLink("Stores"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFooterLink("Terms"),
              const SizedBox(width: 24),
              _buildFooterLink("Privacy"),
              const SizedBox(width: 24),
              _buildFooterLink("Returns"),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "© 2025 Rudram",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                children: [
                  Icon(Icons.facebook, color: Colors.white, size: 20),
                  SizedBox(width: 16),
                  Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  SizedBox(width: 16),
                  Icon(Icons.alternate_email, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
