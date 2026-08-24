import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'product_card.dart';

class NewArrivalsSection extends StatelessWidget {
  NewArrivalsSection({super.key});

  final List<ProductItem> products = [
    ProductItem(
      title: "Pearl Earring Set",
      currentPrice: 42500,
      oldPrice: 57900,
      discount: "30% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
      bgColor: const Color(0xFFFFF8DC), // Cream
    ),
    ProductItem(
      title: "Gold Chain Necklace",
      currentPrice: 68500,
      oldPrice: 80000,
      discount: "15% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
      bgColor: const Color(0xFFFFD700), // Gold
    ),
    ProductItem(
      title: "Diamond Studs",
      currentPrice: 95000,
      oldPrice: 118000,
      discount: "20% Off",
      image:
          "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
      bgColor: const Color(0xFFE8E8E8), // Light grey
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "New Arrivals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
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
          child: StreamBuilder<List<ProductItem>>(
            stream: FirestoreService().getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              
              final liveProducts = snapshot.data ?? [];
              if (liveProducts.isEmpty) {
                return const Center(child: Text("No products available"));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: liveProducts.length > 5 ? 5 : liveProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 160,
                      child: ProductCard(product: liveProducts[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
