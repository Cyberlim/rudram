import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import 'product_card.dart';

class FlashSaleSection extends StatelessWidget {
  FlashSaleSection({super.key});

  final List<ProductItem> products = [
    ProductItem(
      title: "Gold Diamond Necklace",
      currentPrice: 93000,
      oldPrice: 99000,
      discount: "8% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
      bgColor: const Color(0xFFFFD700), // Gold color
    ),
    ProductItem(
      title: "Diamond Solitaire Ring",
      currentPrice: 124800,
      oldPrice: 139900,
      discount: "12% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
      bgColor: const Color(0xFFC0C0C0), // Silver color
    ),
    ProductItem(
      title: "Gold Bracelet Set",
      currentPrice: 83000,
      oldPrice: 89900,
      discount: "8% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
      bgColor: const Color(0xFFDAA520), // Goldenrod
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                "Flash Sales",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD50000),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "12:20:27",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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

        // List
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 160,
                  child: ProductCard(product: products[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
