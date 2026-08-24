import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'Priya S.',
        'review':
            'The necklace I bought was stunning! Exactly as shown in the picture.',
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        'rating': 5,
      },
      {
        'name': 'Rahul M.',
        'review':
            'Great quality and fast delivery. My wife loved the anniversary gift.',
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        'rating': 5,
      },
      {
        'name': 'Anjali K.',
        'review': 'Beautiful craftsmanship. Will definitely purchase again.',
        'image':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        'rating': 4,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Customer Love",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            reviews[index]['image'] as String,
                          ),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviews[index]['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (starIndex) => Icon(
                                  Icons.star,
                                  size: 14,
                                  color:
                                      starIndex <
                                          (reviews[index]['rating'] as int)
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reviews[index]['review'] as String,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
