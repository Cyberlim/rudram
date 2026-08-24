import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        _buildExpansionTile(
          "How do I care for my jewelry?",
          "Clean using mild soap and warm water with a soft brush.",
        ),
        _buildExpansionTile(
          "What is the return policy?",
          "We offer a 30-day return policy for all unworn items.",
        ),
        _buildExpansionTile(
          "Do you offer international shipping?",
          "Yes, we ship to over 50 countries worldwide.",
        ),
        _buildExpansionTile(
          "Is the gold certified?",
          "All our gold jewelry is BIS Hallmarked for purity.",
        ),
      ],
    );
  }

  Widget _buildExpansionTile(String title, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
