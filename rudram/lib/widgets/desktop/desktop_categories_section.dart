import 'package:flutter/material.dart';
import '../../screens/desktop/desktop_category_products_page.dart';

import 'package:google_fonts/google_fonts.dart';

class DesktopCategoriesSection extends StatelessWidget {
  const DesktopCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Necklace Sets',
        'items': '250+ items',
        'icon': Icons.brightness_7_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774694/necklace_fuicra.png',
      },
      {
        'title': 'Earrings',
        'items': '500+ items',
        'icon': Icons.album_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774694/earrings_cbp4ay.png',
      },
      {
        'title': 'Gold Rings',
        'items': '180+ items',
        'icon': Icons.circle_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/ring_vcnnve.png',
      },
      {
        'title': 'Bangles',
        'items': '120+ items',
        'icon': Icons.adjust_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/holding-hands_fnhthw.png',
      },
      {
        'title': 'Bracelets',
        'items': '95+ items',
        'icon': Icons.all_out_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/bracelet_vlsdjb.png',
      },
      {
        'title': 'Pendants',
        'items': '150+ items',
        'icon': Icons.pentagon_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/pendant_zoy3sh.png',
      },
      {
        'title': 'Nose Pins',
        'items': '60+ items',
        'icon': Icons.grain_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774692/necklace_1_wzk1bs.png',
      },
      {
        'title': 'Mangalsutras',
        'items': '110+ items',
        'icon': Icons.auto_awesome_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/jewelry_qexcwa.png',
      },
      {
        'title': 'Gold Coins',
        'items': '30+ items',
        'icon': Icons.monetization_on_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774692/coins_p8bqjy.png',
      },
      {
        'title': 'Silver Jewellery',
        'items': '200+ items',
        'icon': Icons.diamond_outlined,
        'imageUrl':
            'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766774693/medal_ssqxlf.png',
      },
    ];

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              "Shop By Category",
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              5,
              (index) => Expanded(
                child: _buildCategoryItem(context, categories[index]),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              5,
              (index) => Expanded(
                child: _buildCategoryItem(context, categories[index + 5]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return _CategoryItem(category: category);
  }
}

class _CategoryItem extends StatefulWidget {
  final Map<String, dynamic> category;

  const _CategoryItem({super.key, required this.category});

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesktopCategoryProductsPage(
              categoryTitle: widget.category['title']!,
            ),
          ),
        );
      },
      onHover: (value) {
        setState(() {
          _isHovered = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white
              : const Color.fromARGB(0, 255, 255, 255),
          border: const Border(
            right: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      10,
                      10,
                      10,
                    ).withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 64,
              height: 64,
              transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFFF0E5FF) // Light purple tint on hover
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(50),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.category['imageUrl'] != null
                  ? Image.network(
                      widget.category['imageUrl']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        widget.category['icon'] as IconData,
                        color: const Color(0xFF4F46E5),
                        size: 28,
                      ),
                    )
                  : Icon(
                      widget.category['icon'] as IconData,
                      color: const Color(0xFF4F46E5),
                      size: 28,
                    ),
            ),
            const SizedBox(height: 16),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isHovered
                    ? const Color(0xFF4F46E5) // Premium Blue on hover
                    : const Color(0xFF333333),
                letterSpacing: 0.5,
              ),
              child: Text(
                widget.category['title']!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.category['items']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
