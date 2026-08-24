import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';

class DesktopBlogSection extends StatefulWidget {
  const DesktopBlogSection({super.key});

  @override
  State<DesktopBlogSection> createState() => _DesktopBlogSectionState();
}

class _DesktopBlogSectionState extends State<DesktopBlogSection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, String>> blogs = [
    {
      'title': 'The Art of Choosing Perfect Wedding Jewelry',
      'date': 'December 20, 2024',
      'category': 'Wedding Guide',
      'excerpt':
          'Discover the timeless pieces that will make your special day even more memorable...',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg',
    },
    {
      'title': '2024 Jewelry Trends: What\'s Hot This Season',
      'date': 'December 18, 2024',
      'category': 'Trends',
      'excerpt':
          'From minimalist designs to bold statement pieces, explore what\'s trending...',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg',
    },
    {
      'title': 'Caring for Your Precious Gemstones',
      'date': 'December 15, 2024',
      'category': 'Care Tips',
      'excerpt':
          'Learn the best practices to keep your jewelry sparkling for generations...',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg',
    },
    {
      'title': 'Sustainable Luxury: Our Commitment',
      'date': 'December 10, 2024',
      'category': 'Ethics',
      'excerpt':
          'How we source our diamonds and gold responsibly to protect our planet...',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg',
    },
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
                    "From The Blog",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Latest trends, stories and jewelry care tips",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _carouselController.previousPage(),
                  ),
                  const SizedBox(width: 10),
                  _buildNavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _carouselController.nextPage(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Carousel content
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: (blogs.length / 3).ceil(),
          options: CarouselOptions(
            height: 480,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            autoPlay: false,
          ),
          itemBuilder: (context, index, realIndex) {
            final int start = index * 3;
            return Row(
              children: List.generate(3, (i) {
                final int currentIdx = start + i;
                if (currentIdx < blogs.length) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 30),
                      child: _BlogCard(blog: blogs[currentIdx]),
                    ),
                  );
                } else {
                  return const Expanded(child: SizedBox());
                }
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)), size: 20),
      ),
    );
  }
}

class _BlogCard extends StatefulWidget {
  final Map<String, String> blog;

  const _BlogCard({required this.blog});

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.04),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 15 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    widget.blog['image']!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
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
                      widget.blog['category']!,
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                if (_isHovered)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.blog['date']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.blog['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.blog['excerpt']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "READ MORE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isHovered
                              ? AppColors.primaryOrange
                              : Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _isHovered
                            ? AppColors.primaryOrange
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
