import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/gift_guide_screen.dart';

class GiftGuideSection extends StatelessWidget {
  const GiftGuideSection({super.key});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {
        'title': 'For Her',
        'image':
            'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=500',
        'color': const Color(0xFFFFE4E1),
      },
      {
        'title': 'For Him',
        'image':
            'https://images.unsplash.com/photo-1617038224558-28ad3fb558a7?w=500',
        'color': const Color(0xFFF0F8FF),
      },
      {
        'title': 'Wedding',
        'image':
            'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=500',
        'color': const Color(0xFFFFF5E6),
      },
      {
        'title': 'Anniversary',
        'image':
            'https://images.unsplash.com/photo-1622398925373-3f91b1e275f5?w=500',
        'color': const Color(0xFFF5FFFA),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gift Guide",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GiftGuideScreen(),
                    ),
                  );
                },
                child: const Text(
                  "See All",
                  style: TextStyle(color: AppColors.primaryOrange),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GiftGuideScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: gifts[index]['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            gifts[index]['image'] as String,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.card_giftcard),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            gifts[index]['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
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
