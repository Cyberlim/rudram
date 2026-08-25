import 'package:flutter/material.dart';
import '../../models/data_models.dart';

class DesktopCategoriesSidebar extends StatefulWidget {
  const DesktopCategoriesSidebar({super.key});

  @override
  State<DesktopCategoriesSidebar> createState() =>
      _DesktopCategoriesSidebarState();
}

class _DesktopCategoriesSidebarState extends State<DesktopCategoriesSidebar> {
  // Duplicating the data for standalone desktop widget functioning
  final List<CategoryItem> categories = [
    CategoryItem(
      title: "Necklaces",
      imagePath: "assets/images/categories/necklaces.jpg",
      color: Colors.blue.shade50,
    ),
    CategoryItem(
      title: "Earrings",
      imagePath: "assets/images/categories/earrings.jpg",
      color: Colors.green.shade50,
    ),
    CategoryItem(
      title: "Rings",
      imagePath: "assets/images/categories/rings.jpg",
      color: Colors.pink.shade50,
    ),
    CategoryItem(
      title: "Bracelets",
      imagePath: "assets/images/categories/bracelets.jpg",
      color: Colors.cyan.shade50,
    ),
    CategoryItem(
      title: "Bangles",
      imagePath: "assets/images/categories/bangles.jpg",
      color: Colors.yellow.shade50,
    ),
    CategoryItem(
      title: "Pendants",
      imagePath: "assets/images/categories/pendants.jpg",
      color: Colors.purple.shade50,
    ),
    CategoryItem(
      title: "Mangalsutras",
      imagePath: "assets/images/categories/mangalsutras.jpg",
      color: Colors.orange.shade50,
    ),
    CategoryItem(
      title: "Gold Coins",
      imagePath: "assets/images/categories/coins.jpg",
      color: Colors.red.shade50,
    ),
    CategoryItem(
      title: "Silver",
      imagePath: "assets/images/categories/silver.jpg",
      color: Colors.indigo.shade50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Match Hero Banner height (70% of screen)
    double height = MediaQuery.of(context).size.height * 0.7;

    return Container(
      width: 260,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Row()),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(categories[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryItem category, int index) {
    return InkWell(
      onTap: () {},
      hoverColor: category.color.withValues(alpha: 0.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: category.imagePath != null
                  ? Image.asset(category.imagePath!, width: 18, height: 18, fit: BoxFit.contain)
                  : Icon(category.icon, size: 18, color: _getIconColor(index)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(int index) {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFF4F46E5),
      const Color(0xFF00BCD4),
      const Color(0xFFFFC107),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF673AB7),
      const Color(0xFF795548),
    ];
    return colors[index % colors.length];
  }
}
