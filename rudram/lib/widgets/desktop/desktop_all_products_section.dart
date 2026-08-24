import 'package:flutter/material.dart';
import '../../models/data_models.dart';
import '../../screens/shop_screen.dart';
import '../product_card.dart';

class DesktopAllProductsSection extends StatelessWidget {
  DesktopAllProductsSection({super.key});

  final List<ProductItem> products = [
    ProductItem(
      title: "Royal Emerald Diamond Set",
      currentPrice: 85000.00,
      oldPrice: 125000.00,
      discount: "-32%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    ),
    ProductItem(
      title: "Sapphire Drop Earrings",
      currentPrice: 42000.00,
      oldPrice: 55000.00,
      discount: "-25%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
    ),
    ProductItem(
      title: "Infinity Gold Bracelet",
      currentPrice: 35000.00,
      oldPrice: 45000.00,
      discount: "-22%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
    ),
    ProductItem(
      title: "Classic Solitaire Ring",
      currentPrice: 95000.00,
      oldPrice: 110000.00,
      discount: "-15%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
    ),
    ProductItem(
      title: "Rose Gold Pendant",
      currentPrice: 28000.00,
      oldPrice: 35000.00,
      discount: "-20%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
    ),
    ProductItem(
      title: "Gold Choker Necklace",
      currentPrice: 45000.00,
      oldPrice: 60000.00,
      discount: "-25%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/55/5f/81/555f8192d281f652159bbf59a2bb673c.jpg",
    ),
    ProductItem(
      title: "Pearl Drop Necklace",
      currentPrice: 22000.00,
      oldPrice: 30000.00,
      discount: "-26%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg",
    ),
    ProductItem(
      title: "Royal Emerald Diamond Set",
      currentPrice: 85000.00,
      oldPrice: 125000.00,
      discount: "-32%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore Our Collection",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Discover jewelry that resonates with your soul",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopScreen()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              childAspectRatio: 1.0,
              crossAxisSpacing: 24,
              mainAxisSpacing: 30,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
