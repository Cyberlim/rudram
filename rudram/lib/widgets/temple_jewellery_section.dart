import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import 'product_card.dart';

class TempleJewellerySection extends StatelessWidget {
  TempleJewellerySection({super.key});

  final List<ProductItem> products = [
    ProductItem(
      title: "Lakshmi Haram",
      currentPrice: 156000,
      oldPrice: 175000,
      discount: "10% Off",
      image:
          "https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?w=500",
      bgColor: const Color(0xFFFFD700),
    ),
    ProductItem(
      title: "Antique Jhumka",
      currentPrice: 65000,
      oldPrice: 72000,
      discount: "8% Off",
      image:
          "https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500",
      bgColor: const Color(0xFFFFF8DC),
    ),
    ProductItem(
      title: "Temple Bangle",
      currentPrice: 88000,
      oldPrice: 95000,
      discount: "7% Off",
      image:
          "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500",
      bgColor: const Color(0xFFDAA520),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Temple Jewellery",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
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

