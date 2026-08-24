import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'product_card.dart';

class BestSellersSection extends StatelessWidget {
  BestSellersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Best Sellers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
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
        SizedBox(
          height: 250,
          child: StreamBuilder<List<ProductItem>>(
            stream: FirestoreService().getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const Center(
                  child: Text("No products yet", style: TextStyle(color: Colors.grey)),
                );
              }
              // For "best sellers", you could sort or filter here. We'll just limit to 5.
              final bestSellers = products.take(5).toList();

              return ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: bestSellers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(width: 160, child: ProductCard(product: bestSellers[index])),
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
