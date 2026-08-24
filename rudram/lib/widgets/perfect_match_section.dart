import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PerfectMatchSection extends StatelessWidget {
  const PerfectMatchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Necklaces',
        'subtitle': 'Match Your Style',
        'image':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=300',
        'color': const Color(0xFFFFE5B4),
      },
      {
        'title': 'Earrings',
        'subtitle': 'Perfect Pairs',
        'image':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=300',
        'color': const Color(0xFFE6E6FA),
      },
      {
        'title': 'Bracelets',
        'subtitle': 'Elegant Touch',
        'image':
            'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=300',
        'color': const Color(0xFFFFDAB9),
      },
      {
        'title': 'Rings',
        'subtitle': 'Shine Bright',
        'image':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=300',
        'color': const Color(0xFFFFF0F5),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Perfect Match",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: item['color'] as Color);
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
