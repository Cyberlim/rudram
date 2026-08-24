import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import '../screens/category_details_screen.dart';
import '../screens/categories_screen.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final ScrollController _scrollController = ScrollController();

  final List<Color> _bgColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.pink.shade50,
    Colors.cyan.shade50,
    Colors.yellow.shade50,
    Colors.purple.shade50,
    Colors.orange.shade50,
    Colors.red.shade50,
    Colors.teal.shade50,
    Colors.indigo.shade50,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
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
          height: 240, // Increased height to prevent overflow
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService().getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const Center(child: Text("No categories found", style: TextStyle(color: Colors.grey)));
              }

              // Split categories into 2 rows for the horizontal scroll
              final int itemsPerRow = (categories.length / 2).ceil();
              final List<Map<String, dynamic>> firstRow = categories.take(itemsPerRow).toList();
              final List<Map<String, dynamic>> secondRow = categories.skip(itemsPerRow).toList();

              return ListView.builder(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: itemsPerRow,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildCategoryItem(firstRow[index], index),
                      const SizedBox(height: 12),
                      if (index < secondRow.length)
                        _buildCategoryItem(secondRow[index], index + itemsPerRow),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category, int globalIndex) {
    final title = category['name'] ?? 'Category';
    final icon = category['icon'] ?? '🏷️';
    final bgColor = _bgColors[globalIndex % _bgColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(categoryName: title),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34, // Fixed height to fit up to 2 lines of text
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
