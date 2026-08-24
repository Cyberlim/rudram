import 'package:flutter/material.dart';

class LuxuryConciergeScreen extends StatelessWidget {
  const LuxuryConciergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PRIVATE CONCIERGE",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  letterSpacing: 4,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "At Your Service",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Playfair Display',
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Dedicated to fulfilling your every request.",
                style: TextStyle(color: Colors.grey[400]),
              ),

              const SizedBox(height: 48),

              // Contact Options
              _buildContactOption(
                Icons.call,
                "Direct Line",
                "Connect with your personal manager instantly.",
              ),
              const SizedBox(height: 16),
              _buildContactOption(
                Icons.chat_bubble_outline,
                "Secure Chat",
                "Encrypted messaging for privacy.",
              ),
              const SizedBox(height: 16),
              _buildContactOption(
                Icons.video_call_outlined,
                "Video Consultation",
                "View pieces live from our showroom.",
              ),

              const SizedBox(height: 48),

              const Text(
                "APPOINTMENTS",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(0),
                  color: const Color(0xFF111111),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upcoming Viewing",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Fri, Dec 15 • 11:00 AM",
                              style: TextStyle(color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("MANAGE BOOKING"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
        ],
      ),
    );
  }
}
