import 'package:flutter/material.dart';
import '../screens/reels_screen.dart';
import '../screens/celebrity_style_screen.dart';
import '../screens/luxury_screen.dart';
import '../screens/ai_stylist_screen.dart';

class FeatureCarouselSection extends StatelessWidget {
  const FeatureCarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Luxury',
        'icon': Icons.diamond,
        'color': const Color.fromARGB(
          255,
          10,
          10,
          10,
        ), // Light amber/gold shade
        'iconColor': const Color(0xFFFFD700), // Golden
        'isHighlighted': true,
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LuxuryScreen()),
        ),
      },
      {
        'title': 'Reels',
        'icon': Icons.play_circle_fill,
        'color': const Color(0xFFE8F5E9), // Light green shade
        'iconColor': const Color(0xFF4CAF50), // Green
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReelsScreen()),
        ),
      },
      {
        'title': 'Celebrity\nStyle',
        'icon': Icons.star,
        'color': const Color(0xFFFFF3E0), // Light orange shade
        'iconColor': const Color(0xFFFF9800), // Orange
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CelebrityStyleScreen()),
        ),
      },
      {
        'title': 'AI\nStylist',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFE1F5FE), // Light blue shade
        'iconColor': const Color(0xFF2196F3), // Blue
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiStylistScreen()),
        ),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: features.map((feature) {
          final isHighlighted = feature['isHighlighted'] == true;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: feature['route'] as VoidCallback,
                child: AspectRatio(
                  aspectRatio: 1, // Makes it square
                  child: Container(
                    decoration: BoxDecoration(
                      color: feature['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (feature['color'] as Color).withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: isHighlighted ? 12 : 8,
                          offset: Offset(0, isHighlighted ? 5 : 3),
                        ),
                      ],
                      border: isHighlighted
                          ? Border.all(
                              color: const Color(0xFFFFD700), // Golden border
                              width: 2.5,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomPaint(painter: DotPatternPainter()),
                          ),
                        ),
                        // Featured badge
                        if (isHighlighted)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                feature['icon'] as IconData,
                                color:
                                    feature['iconColor'] as Color? ??
                                    Colors.grey.shade700,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feature['title'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isHighlighted
                                      ? const Color.fromARGB(
                                          255,
                                          255,
                                          189,
                                          24,
                                        ) // Dark gold for Luxury
                                      : Colors.grey.shade800,
                                  fontSize: 11,
                                  fontWeight: isHighlighted
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Custom painter for dot pattern background
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    const dotRadius = 1.5;
    const spacing = 8.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
