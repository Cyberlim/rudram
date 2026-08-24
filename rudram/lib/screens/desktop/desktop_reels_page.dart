import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:video_player/video_player.dart';

class DesktopReelsPage extends StatefulWidget {
  const DesktopReelsPage({super.key});

  @override
  State<DesktopReelsPage> createState() => _DesktopReelsPageState();
}

class _DesktopReelsPageState extends State<DesktopReelsPage>
    with TickerProviderStateMixin {
  late FixedExtentScrollController _leftScrollController;
  late CarouselSliderController _rightCarouselController;
  late AnimationController _bubbleController;
  late AnimationController _lightBeamController;
  late ScrollController _mainScrollController;
  final List<VideoPlayerController> _videoControllers = [];
  bool _isMuted = false;
  bool _isPaused = false;
  bool _isDarkMode = false; // Local Dark Mode state for Reels

  final List<Map<String, String>> reels = [
    {
      'title': 'BULGARI MEDITERRANEA',
      'subtitle': '22 August 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.mp4',
      'price': '₹ 1,25,000',
      'likes': '12k',
      'comments': '450',
    },
    {
      'title': 'TANISHQ DIAMONDS',
      'subtitle': '15 Sept 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.mp4',
      'price': '₹ 85,000',
      'likes': '8k',
      'comments': '210',
    },
    {
      'title': 'GOLD JHUMKA',
      'subtitle': '05 Oct 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.mp4',
      'price': '₹ 45,000',
      'likes': '15k',
      'comments': '890',
    },
    {
      'title': 'TIMELESS KASUMALA',
      'subtitle': '12 Nov 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.mp4',
      'price': '₹ 2,50,000',
      'likes': '5k',
      'comments': '120',
    },
    {
      'title': 'ANNE HATHAWAY LOOK',
      'subtitle': '20 Dec 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714691/Anne_Hathaway_Bulgari_Mediterranea_High_Jewelry_Collection_wcgszq.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714691/Anne_Hathaway_Bulgari_Mediterranea_High_Jewelry_Collection_wcgszq.mp4',
      'price': '₹ 5,00,000',
      'likes': '25k',
      'comments': '1.2k',
    },
    {
      'title': 'ZENDAYA STYLE',
      'subtitle': '28 Dec 2023',
      'thumbnail':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714564/Zendaya_Bulgari_Mediterranea_High_Jewelry_Collection_jbwa8d.jpg',
      'video':
          'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714564/Zendaya_Bulgari_Mediterranea_High_Jewelry_Collection_jbwa8d.mp4',
      'price': '₹ 3,75,000',
      'likes': '18k',
      'comments': '950',
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = (reels.length / 2).floor();
    _leftScrollController = FixedExtentScrollController(
      initialItem: _currentIndex,
    );
    _rightCarouselController = CarouselSliderController();
    _mainScrollController = ScrollController();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _lightBeamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Initialize Video Controllers
    for (var reel in reels) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(reel['video']!),
      );
      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0); // Sound ON
      _videoControllers.add(controller);
      controller.initialize().then((_) {
        if (mounted &&
            _videoControllers.indexOf(controller) == _currentIndex &&
            !_isPaused) {
          controller.play();
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _mainScrollController.dispose();
    _bubbleController.dispose();
    _lightBeamController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onLeftItemChanged(int index) {
    // Handle infinite looping index
    int realIndex = index % reels.length;
    if (_currentIndex != realIndex) {
      _handleReelSwitch(realIndex);
      _rightCarouselController.animateToPage(
        realIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onRightPageChanged(int index, CarouselPageChangedReason reason) {
    if (_currentIndex != index) {
      _handleReelSwitch(index);
      _leftScrollController.animateToItem(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleReelSwitch(int newIndex) {
    // Pause previous video
    _videoControllers[_currentIndex].pause();
    setState(() => _currentIndex = newIndex);
    // Play next video
    if (!_isPaused) {
      _videoControllers[_currentIndex].play();
    }
  }

  void _togglePlay() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _videoControllers[_currentIndex].pause();
      } else {
        _videoControllers[_currentIndex].play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      for (var controller in _videoControllers) {
        controller.setVolume(_isMuted ? 0.0 : 1.0);
      }
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color scaffoldBg = _isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BubblePainter(_bubbleController.value, _isDarkMode),
                );
              },
            ),
          ),

          WebSmoothScroll(
            controller: _mainScrollController,
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const DesktopHeader(),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      double screenHeight = math.max(
                        800.0,
                        MediaQuery.of(context).size.height - 100,
                      );

                      // Dimensions for Projection
                      double thumbHeight = 160;
                      double reefHeight = screenHeight * 0.72;

                      return Stack(
                        children: [
                          // Highlight Projection Painter (The Light)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _lightBeamController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: ProjectionPainter(
                                    _lightBeamController.value,
                                    screenWidth,
                                    screenHeight,
                                    thumbHeight,
                                    reefHeight,
                                    !_isDarkMode, // pass isLight flag
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            height: screenHeight,
                            width: screenWidth,
                            child: Row(
                              children: [
                                // Left Side: Thumbnails
                                Expanded(
                                  flex: 4,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: -screenWidth * 0.08,
                                        top: 0,
                                        bottom: 0,
                                        width: screenWidth * 0.35,
                                        child: ListWheelScrollView.useDelegate(
                                          controller: _leftScrollController,
                                          itemExtent: thumbHeight,
                                          diameterRatio: 2.5,
                                          offAxisFraction: -0.1,
                                          perspective: 0.003,
                                          physics:
                                              const FixedExtentScrollPhysics(),
                                          onSelectedItemChanged:
                                              _onLeftItemChanged,
                                          childDelegate:
                                              ListWheelChildLoopingListDelegate(
                                                children: List.generate(
                                                  reels.length,
                                                  (index) {
                                                    final isSelected =
                                                        index == _currentIndex;
                                                    return _buildThumbnailItem(
                                                      reels[index],
                                                      isSelected,
                                                      screenWidth,
                                                    );
                                                  },
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Center-Right Info Positioned exactly between thumb and reel
                                Expanded(
                                  flex: 6,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: screenWidth * 0.03,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: _buildCurrentItemInfo(
                                            screenWidth,
                                          ),
                                        ),
                                      ),
                                      // Right Side: Reel Carousel
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: screenWidth * 0.45,
                                          height: screenHeight * 0.95,
                                          child: CarouselSlider.builder(
                                            carouselController:
                                                _rightCarouselController,
                                            itemCount: reels.length,
                                            options: CarouselOptions(
                                              height: screenHeight * 0.9,
                                              viewportFraction: 0.7,
                                              initialPage: _currentIndex,
                                              enlargeCenterPage: true,
                                              enlargeFactor: 0.2,
                                              scrollDirection: Axis.vertical,
                                              onPageChanged:
                                                  _onRightPageChanged,
                                              enableInfiniteScroll: true,
                                              autoPlay: !_isPaused,
                                              autoPlayInterval: const Duration(
                                                seconds: 8,
                                              ),
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                            ),
                                            itemBuilder:
                                                (context, index, realIndex) {
                                                  double cardHeight =
                                                      reefHeight;
                                                  double cardWidth =
                                                      cardHeight / 2;
                                                  return Center(
                                                    child: SizedBox(
                                                      width: cardWidth,
                                                      height: cardHeight,
                                                      child: _buildReelCard(
                                                        reels[index],
                                                        cardWidth,
                                                        cardHeight,
                                                        index,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const DesktopFooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailItem(
    Map<String, String> reel,
    bool isSelected,
    double screenWidth,
  ) {
    double itemWidth = isSelected ? screenWidth * 0.12 : screenWidth * 0.09;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: itemWidth,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(
                  0xFF38BDF8,
                ).withOpacity(_isDarkMode ? 0.5 : 0.3),
                blurRadius: 15,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(reel['thumbnail']!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildCurrentItemInfo(double screenWidth) {
    final currentReel = reels[_currentIndex];
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = _isDarkMode ? Colors.white70 : const Color(0xFF64748B);
    final cardColor = _isDarkMode
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: screenWidth * 0.22,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentReel['title']!.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          currentReel['subtitle']!,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "${currentReel['likes']} Likes • ${currentReel['comments']} Comments",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  _buildIconAction(Icons.favorite_outline),
                  const SizedBox(width: 15),

                  // Theme Toggle
                  InkWell(
                    onTap: _toggleDarkMode,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isDarkMode
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        color: _isDarkMode
                            ? Colors.orangeAccent
                            : Colors.indigoAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Controls Section
                  InkWell(
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconAction(IconData icon) {
    return Icon(
      icon,
      color: _isDarkMode ? Colors.white38 : const Color(0xFF94A3B8),
      size: 22,
    );
  }

  Widget _buildReelCard(
    Map<String, String> reel,
    double width,
    double height,
    int index,
  ) {
    final controller = _videoControllers[index];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller.value.isInitialized)
                VideoPlayer(controller)
              else
                Image.network(reel['thumbnail']!, fit: BoxFit.cover),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Starts From",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            reel['price']!,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  BubblePainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    // 3D Corner Bubble 1 (Top Left) - Soft Blue
    _draw3DSphere(
      canvas,
      Offset(size.width * 0.1, size.height * 0.1),
      180,
      const Color(0xFF60A5FA),
      animationValue,
    );

    // 3D Corner Bubble 2 (Bottom Right) - Soft Pink
    _draw3DSphere(
      canvas,
      Offset(size.width * 0.9, size.height * 0.85),
      250,
      const Color(0xFFF472B6),
      -animationValue, // Rotate opposite direction
    );

    // 3D Corner Bubble 3 (Top Right) - Soft Purple/Indigo
    _draw3DSphere(
      canvas,
      Offset(size.width * 0.85, size.height * 0.15),
      120,
      const Color(0xFF818CF8),
      animationValue * 0.8,
    );

    // 3D Corner Bubble 4 (Bottom Left) - Soft Cyan/Teal
    _draw3DSphere(
      canvas,
      Offset(size.width * 0.15, size.height * 0.8),
      140,
      const Color(0xFF2DD4BF),
      animationValue * 1.2,
    );
  }

  void _draw3DSphere(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double anim,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dynamic light focus point
    double angle = anim * 2 * math.pi;

    // Base Gradient (The Body)
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          color.withOpacity(isDarkMode ? 0.1 : 0.15),
          color.withOpacity(isDarkMode ? 0.02 : 0.05),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, basePaint);

    // 3D Highlight (The "Glow")
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        focal: Alignment(math.cos(angle) * 0.5, math.sin(angle) * 0.5),
        focalRadius: 0.1,
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
          color.withOpacity(0.0),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, highlightPaint);

    // Internal Shimmer (Depth/3D Effect)
    final shimmerPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.6,
        colors: [
          Colors.white.withOpacity(isDarkMode ? 0.05 : 0.1),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProjectionPainter extends CustomPainter {
  final double animation;
  final double screenWidth;
  final double screenHeight;
  final double thumbHeight;
  final double reelHeight;
  final bool isLight;

  ProjectionPainter(
    this.animation,
    this.screenWidth,
    this.screenHeight,
    this.thumbHeight,
    this.reelHeight,
    this.isLight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Points calculation
    double centerY = screenHeight / 2;
    double thumbX = screenWidth * 0.12;
    double reelX = screenWidth * 0.75; // Approx center of reel carousel

    double thumbTop = centerY - (thumbHeight / 2);
    double thumbBottom = centerY + (thumbHeight / 2);

    double reelTop = centerY - (reelHeight / 2);
    double reelBottom = centerY + (reelHeight / 2);

    final path = Path()
      ..moveTo(thumbX, thumbTop)
      ..lineTo(reelX, reelTop)
      ..lineTo(reelX, reelBottom)
      ..lineTo(thumbX, thumbBottom)
      ..close();

    final paint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              const Color(0xFF38BDF8).withOpacity(isLight ? 0.05 : 0.08),
              const Color(0xFF38BDF8).withOpacity(isLight ? 0.01 : 0.02),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromPoints(Offset(thumbX, centerY), Offset(reelX, centerY)),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Glowing border on the left
    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(isLight ? 0.2 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    double curveX = thumbX + 20; // Offset for curve
    final curvePath = Path()
      ..moveTo(curveX, thumbTop - 20)
      ..quadraticBezierTo(curveX + 20, centerY, curveX, thumbBottom + 20);

    canvas.drawPath(curvePath, borderPaint);

    // Shimmering light passing through
    final shimmerPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(isLight ? 0.15 : 0.1),
              Colors.transparent,
            ],
            stops: [
              math.max(0.0, animation - 0.2),
              animation,
              math.min(1.0, animation + 0.2),
            ],
          ).createShader(
            Rect.fromPoints(Offset(thumbX, centerY), Offset(reelX, centerY)),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
