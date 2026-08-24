import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'category_details_screen.dart';
import 'dart:math';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load categories"));
          }
          
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          // Ensure selected index is valid
          if (_selectedIndex >= categories.length) {
            _selectedIndex = 0;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              Container(
                width: 90,
                color: const Color(0xFFF5F5F5),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              cat['icon'] ?? '🏷️',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat['name'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? AppColors.primaryOrange : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main Content (Subcategories)
              Expanded(
                child: _buildCategoryContent(categories[_selectedIndex]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(Map<String, dynamic> category) {
    final subcategories = (category['subcategories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          category['name'] ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (subcategories.isEmpty)
          const Text("No subcategories available.", style: TextStyle(color: Colors.grey))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final sub = subcategories[index];
              return _buildSubcategoryCard(sub);
            },
          ),
      ],
    );
  }

  Widget _buildSubcategoryCard(String title) {
    // Generate a random gradient color based on the title length so it looks varied
    final colors = [
      [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
      [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
      [const Color(0xFFFCCB90), const Color(0xFFD57EEB)],
      [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    ];
    final seed = title.length % colors.length;
    final gradient = LinearGradient(colors: colors[seed], begin: Alignment.topLeft, end: Alignment.bottomRight);

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: colors[seed][0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
