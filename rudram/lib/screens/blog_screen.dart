import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/app_colors.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  static const _localAssets = [
    'assets/images/royal_ruby_collection.jpg',
    'assets/images/diamond_jewelry_care.jpg',
    'assets/images/wedding_jewelry_trends.jpg',
    'assets/images/gold_purity_guide.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final blogs = [
      {
        'title': 'How to Care for Diamond Jewelry',
        'date': 'Oct 24, 2023',
        'author': 'Rohit Kumar',
        'readTime': '5 min read',
        'image':
            'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600',
        'excerpt':
            'Learn the best practices to maintain the brilliance and longevity of your precious diamond jewelry pieces.',
        'category': 'Care Tips',
      },
      {
        'title': 'Top 5 Wedding Jewelry Trends',
        'date': 'Sep 15, 2023',
        'author': 'Priya Sharma',
        'readTime': '7 min read',
        'image':
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600',
        'excerpt':
            'Discover the latest trends in wedding jewelry for 2024, from classic gold to contemporary designs.',
        'category': 'Trends',
      },
      {
        'title': 'Choosing the Perfect Engagement Ring',
        'date': 'Aug 10, 2023',
        'author': 'Amit Patel',
        'readTime': '6 min read',
        'image':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600',
        'excerpt':
            'A comprehensive guide to selecting the ideal engagement ring that matches your style and budget.',
        'category': 'Guide',
      },
      {
        'title': 'Guide to Gold Purity',
        'date': 'Jul 05, 2023',
        'author': 'Sneha Reddy',
        'readTime': '4 min read',
        'image':
            'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600',
        'excerpt':
            'Understanding different karats of gold and what they mean for your jewelry purchases.',
        'category': 'Education',
      },
      {
        'title': 'Gemstone Meanings and Symbolism',
        'date': 'Jun 20, 2023',
        'author': 'Kavita Singh',
        'readTime': '8 min read',
        'image':
            'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?w=600',
        'excerpt':
            'Explore the fascinating world of gemstones and their cultural significance across different traditions.',
        'category': 'Culture',
      },
      {
        'title': 'Jewelry Styling Tips for Every Occasion',
        'date': 'May 15, 2023',
        'author': 'Neha Kapoor',
        'readTime': '5 min read',
        'image':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600',
        'excerpt':
            'Master the art of accessorizing with these expert tips for various events and occasions.',
        'category': 'Style',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Blog',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () {},
                ),
              ],
            ),

            // Blog Posts Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= blogs.length) return null;
                  final blog = blogs[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildBlogCard(context, blog, index),
                      ),
                    ),
                  );
                }, childCount: blogs.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(
    BuildContext context,
    Map<String, String> blog,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Category Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  _localAssets[index % _localAssets.length],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    blog['category']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  blog['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Excerpt
                Text(
                  blog['excerpt']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Meta Info Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryOrange.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        blog['author']![0],
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog['author']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            blog['date']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            blog['readTime']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Read More Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetailScreen(blog: blog),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Read More',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
