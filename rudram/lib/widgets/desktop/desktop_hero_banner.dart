import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/firestore_service.dart';

class DesktopHeroBanner extends StatefulWidget {
  const DesktopHeroBanner({super.key});

  @override
  State<DesktopHeroBanner> createState() => _DesktopHeroBannerState();
}

class _DesktopHeroBannerState extends State<DesktopHeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<DesktopBannerItem> _banners = [];
  StreamSubscription? _bannerSub;

  @override
  void initState() {
    super.initState();
    
    _bannerSub = FirestoreService().getActiveBanners().listen((bannersData) {
      if (!mounted) return;
      final newBanners = bannersData.where((b) => b['placement'] == 'Hero').map((b) {
        Color color1 = _parseColor(b['color1'] ?? '#FFE0D1');
        Color color2 = _parseColor(b['color2'] ?? '#FFF0E5');
        return DesktopBannerItem(
          imageUrl: b['imageUrl'] ?? '',
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color1, color2],
          ),
          useAssetImage: false,
        );
      }).toList();
      
      setState(() {
        _banners = newBanners;
      });
    });

    _startAutoPlay();
  }

  Color _parseColor(String hexCode) {
    hexCode = hexCode.replaceAll('#', '');
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }
    return Color(int.parse(hexCode, radix: 16));
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerSub?.cancel();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 70% of screen height as requested, minus some padding if needed,
    // but user asked for "hero section in 70vh".
    double height = MediaQuery.of(context).size.height * 0.7;

    if (_banners.isEmpty) {
      return Container(
        height: height,
        margin: const EdgeInsets.only(left: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      );
    }

    return Container(
      height: height,
      margin: const EdgeInsets.only(left: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                return _buildBannerContent(_banners[index]);
              },
            ),
          ),

          // Indicators
          Positioned(
            bottom: 30, // Adjusted to not overlap with text bottom content
            right: 40, // Moved to right for better visibility with bottom text
            child: Row(
              children: List.generate(
                _banners.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerContent(DesktopBannerItem banner) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: banner.gradient),
      child: Stack(
        children: [
          // Image - Full Cover
          Positioned.fill(
            child: banner.useAssetImage
                ? Image.asset(banner.imageUrl, fit: BoxFit.cover)
                : Image.network(banner.imageUrl, fit: BoxFit.cover),
          ),

          // No gradient or text as requested
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryOrange : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class DesktopBannerItem {
  final String imageUrl;
  final LinearGradient gradient;
  final bool useAssetImage;

  DesktopBannerItem({
    required this.imageUrl,
    required this.gradient,
    this.useAssetImage = false,
  });
}
