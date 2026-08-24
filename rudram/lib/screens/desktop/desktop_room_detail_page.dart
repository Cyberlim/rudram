import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_models.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import 'desktop_product_detail_page.dart';

class DesktopRoomDetailPage extends StatelessWidget {
  final Room room;
  const DesktopRoomDetailPage({super.key, required this.room});

  static const Color goldColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(isDark: false),
            _buildHero(),
            _buildProductGrid(context),
            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(room.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ROOM COLLECTION",
                style: GoogleFonts.outfit(
                  color: goldColor,
                  letterSpacing: 8,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                room.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 10),
              Container(width: 60, height: 2, color: goldColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    if (room.products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(100),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              "NO PRODUCTS IN THIS ROOM YET",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade400,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 30,
          mainAxisSpacing: 50,
          childAspectRatio: 0.7,
        ),
        itemCount: room.products.length,
        itemBuilder: (context, index) {
          final product = room.products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductItem product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesktopProductDetailPage(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            product.title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "₹${product.currentPrice}",
            style: const TextStyle(
              color: goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
