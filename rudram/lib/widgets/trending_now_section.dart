import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import 'product_card.dart';

class TrendingNowSection extends StatelessWidget {
  TrendingNowSection({super.key});

  final List<ProductItem> products = [
    ProductItem(
      title: "Layered Gold Chain",
      currentPrice: 78000,
      oldPrice: 95000,
      discount: "18% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
      bgColor: const Color(0xFFFFD700),
    ),
    ProductItem(
      title: "Statement Earrings",
      currentPrice: 45000,
      oldPrice: 55000,
      discount: "18% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
      bgColor: const Color(0xFFFF69B4),
    ),
    ProductItem(
      title: "Charm Bracelet",
      currentPrice: 35000,
      oldPrice: 42000,
      discount: "17% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
      bgColor: const Color(0xFF87CEEB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryOrange, size: 22),
              const SizedBox(width: 8),
              Text(
                "Trending Now",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "See all",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(width: 160, child: ProductCard(product: products[index])),
              );
            },
          ),
        ),
      ],
    );
  }
}

