import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InstaFamilySection extends StatelessWidget {
  const InstaFamilySection({super.key});

  @override
  Widget build(BuildContext context) {
    // 9 images for 3x3 grid
    final images = [
      'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=300',
      'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=300',
      'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=300',
      'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=300',
      'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=300',
      'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=300',
      'https://images.unsplash.com/photo-1629224316810-9d8805b95076?w=300',
      'https://images.unsplash.com/photo-1603561596112-0a132b722304?w=300',
      'https://images.unsplash.com/photo-1543294001-f7cd5d7fb516?w=300',
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              const Text(
                "@RUDRAM_JEWELLERY",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Join our Insta Family",
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  130, // 3 cols on mobile (~390/3=130), many on desktop
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
