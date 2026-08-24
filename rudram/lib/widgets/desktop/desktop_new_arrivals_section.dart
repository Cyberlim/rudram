import 'package:flutter/material.dart';
import '../../screens/desktop/desktop_shop_page.dart';

class DesktopNewArrivalsSection extends StatelessWidget {
  const DesktopNewArrivalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              "New Arrivals",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Large Vertical Card
              Expanded(
                flex: 3,
                child: _buildImageCard(
                  context: context,
                  height: 520,
                  image:
                      "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/d5/84/6d/d5846d57b1e589218ae13ca3f4779c9b.jpg",
                ),
              ),
              const SizedBox(width: 20),
              // Right Column
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // Top Row: 2 Medium Horizontal Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageCard(
                            context: context,
                            height: 250,
                            image:
                                "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/a2/d1/53/a2d153c12d7c1216c406500543686ceb.jpg",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildImageCard(
                            context: context,
                            height: 250,
                            image:
                                "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/55/5f/81/555f8192d281f652159bbf59a2bb673c.jpg",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Bottom Row: 2 Medium Horizontal Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageCard(
                            context: context,
                            height: 250,
                            image:
                                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildImageCard(
                            context: context,
                            height: 250,
                            image:
                                "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/96/79/ff/9679ff249d0ff1011189db389b573a34.jpg",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required BuildContext context,
    required double height,
    required String image,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DesktopShopPage()),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
