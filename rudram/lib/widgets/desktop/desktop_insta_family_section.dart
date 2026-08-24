import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';

class DesktopInstaFamilySection extends StatefulWidget {
  const DesktopInstaFamilySection({super.key});

  @override
  State<DesktopInstaFamilySection> createState() =>
      _DesktopInstaFamilySectionState();
}

class _DesktopInstaFamilySectionState extends State<DesktopInstaFamilySection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<String> images = [
    'https://images.weserv.nl/?url=https://i.pinimg.com/736x/7f/c9/67/7fc9678798dd797a2c39410e0595d7fb.jpg',
    'https://images.weserv.nl/?url=https://i.pinimg.com/736x/fc/ea/ab/fceaab40d8b3cc9fa5f5d9f5887d7b93.jpg',
    'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/df/ef/a5/dfefa5d5dbfd0d4cc1987d8e7d77fe9a.jpg',
    'https://images.weserv.nl/?url=https://i.pinimg.com/736x/63/74/6b/63746b1d386f2c19f665aa123a6faf6b.jpg',
    'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/ed/4b/0e/ed4b0e814a770d0f1c07dc02a07735b8.jpg',
    'https://images.weserv.nl/?url=https://i.pinimg.com/736x/7a/3f/5e/7a3f5e0e2b563091200608b92c83fa38.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 15),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#RudramFamily',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join our community of style icons. Tag us to be featured!',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildNavButton(
                      icon: Icons.chevron_left,
                      onTap: () => _carouselController.previousPage(),
                    ),
                    const SizedBox(width: 15),
                    _buildNavButton(
                      icon: Icons.chevron_right,
                      onTap: () => _carouselController.nextPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Carousel showing vertical images
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: images.length,
            options: CarouselOptions(
              height: 550, // Height for vertical cards
              viewportFraction: 0.22, // Shows about 4.5 items
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              padEnds: false,
              enlargeCenterPage: false,
            ),
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _InstaCard(imageUrl: images[index]),
              );
            },
          ),

          const SizedBox(height: 50),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.camera_alt_outlined),
            label: Text('Follow Us @RudramJewels'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 24),
      ),
    );
  }
}

class _InstaCard extends StatefulWidget {
  final String imageUrl;

  const _InstaCard({required this.imageUrl});

  @override
  State<_InstaCard> createState() => _InstaCardState();
}

class _InstaCardState extends State<_InstaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 10 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              // Hover overlay
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apps, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "View Post",
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Corner Icon
              Positioned(
                bottom: 15,
                right: 15,
                child: Icon(
                  Icons.favorite_rounded,
                  color: Theme.of(context).cardColor.withOpacity(0.9),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
