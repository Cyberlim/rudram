import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';

class DesktopLuxuryProductsPage extends StatefulWidget {
  const DesktopLuxuryProductsPage({super.key});

  @override
  State<DesktopLuxuryProductsPage> createState() =>
      _DesktopLuxuryProductsPageState();
}

class _DesktopLuxuryProductsPageState extends State<DesktopLuxuryProductsPage> {
  final ScrollController _scrollController = ScrollController();

  static const Color goldColor = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF070707);
  static const Color panelBg = Color(0xFF111111);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const DesktopHeader(isDark: true),
            _buildHeroPodiumSection(), // 1
            _buildMarqueeSection(), // 2
            _buildRankedBestSellers(), // 3
            _buildCollectionsGrid(), // 4
            _buildSignatureSeries(), // New 1
            _buildMasterpieceGallery(), // New 2
            _buildVintageHeritage(), // 7
            _buildImmersiveCarousel(), // 8
            _buildBentoCollection(), // 9
            _buildArtisanMosaic(), // 10
            _buildExclusiveHighlight(), // 11
            const DesktopFooterSection(), // 12
          ],
        ),
      ),
    );
  }

  // 1. HERO PODIUM SECTION
  Widget _buildHeroPodiumSection() {
    final heroImages = [
      'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766819231/bdce46f2878768991dd902d32d17224e_qmx8i1.png',
      'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766819464/639405c2eae7718d7bb5208334553852_adyzvc.png',
      'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766819037/65658780be0da96b8f8c6a69491f6c96_1_idsakd.png',
      'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766819464/639405c2eae7718d7bb5208334553852_adyzvc.png',
      'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766819231/bdce46f2878768991dd902d32d17224e_qmx8i1.png',
    ];

    return SizedBox(
      height: 750,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing Arches
          Positioned(
            top: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArch(200, 450, opacity: 0.05),
                const SizedBox(width: 30),
                _buildArch(260, 500, opacity: 0.1),
                const SizedBox(width: 40),
                _buildArch(380, 650, opacity: 0.25, isBright: true),
                const SizedBox(width: 40),
                _buildArch(260, 500, opacity: 0.1),
                const SizedBox(width: 30),
                _buildArch(200, 450, opacity: 0.05),
              ],
            ),
          ),

          // Carousel and Podium
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 450,
                width: double.infinity,
                child: CarouselSlider.builder(
                  itemCount: heroImages.length,
                  options: CarouselOptions(
                    height: 450,
                    viewportFraction: 0.2, // Show 5 items
                    initialPage: 2, // Focus on center
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 1000,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (index == 2) // Center item glow
                            BoxShadow(
                              color: goldColor.withValues(alpha: 0.1),
                              blurRadius: 80,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Image.network(
                        heroImages[index],
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_not_supported,
                          color: goldColor,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 5),
              // STATIC Product Info (Always Visible)
              Column(
                children: [
                  Text(
                    "DÉZEL PRESTIGE EDITION",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => const Icon(
                        Icons.star_rounded,
                        color: goldColor,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Podium Base
              _buildPodiumBase(320),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArch(
    double width,
    double height, {
    double opacity = 0.2,
    bool isBright = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: goldColor.withValues(alpha: opacity),
          width: isBright ? 2 : 1,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width / 2),
          topRight: Radius.circular(width / 2),
        ),
        boxShadow: isBright
            ? [
                BoxShadow(
                  color: goldColor.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildPodiumBase(double width) {
    return Column(
      children: [
        Container(
          width: width,
          height: 15,
          decoration: BoxDecoration(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: goldColor.withValues(alpha: 0.2)),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: width + 40,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. MARQUEE SECTION
  Widget _buildMarqueeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(color: goldColor.withValues(alpha: 0.1)),
          Container(
            color: darkBg,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "DÉZEL BEST SELLERS",
              style: GoogleFonts.outfit(
                color: goldColor,
                fontSize: 14,
                letterSpacing: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. RANKED BEST SELLERS
  Widget _buildRankedBestSellers() {
    final rankedItems = [
      {
        'rank': '1',
        'name': 'ROYAL BRIDAL',
        'img':
            'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/74/fe/af/74feaf18dd253a8953fd6c395a16b054.jpg',
      },
      {
        'rank': '2',
        'name': 'GOLDEN HERITAGE',
        'img':
            'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/19/f9/82/19f9825b3f01e13681bd1e70dc04058e.jpg',
      },
      {
        'rank': '3',
        'name': 'EMERALD LUXE',
        'img':
            'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/98/00/de/9800dee429c9e0eba846dda12f1f2569.jpg',
      },
      {
        'rank': '4',
        'name': 'DIAMOND GRACE',
        'img':
            'https://images.weserv.nl/?url=https://i.pinimg.com/736x/d6/0b/0b/d60b0b58fb7d204fb158d46404397967.jpg',
      },
    ];

    return SizedBox(
      height: 850, // Increased height to prevent all overflow issues
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: rankedItems.length,
        options: CarouselOptions(
          height: 800,
          viewportFraction: 0.35,
          enlargeCenterPage: true,
          autoPlay: true,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 4),
        ),
        itemBuilder: (context, index, realIndex) {
          final item = rankedItems[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Constrain column
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 480, // Larger image container
                      margin: const EdgeInsets.only(top: 25),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: panelBg,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: ClipRRect(
                        child: Image.network(
                          item['img']!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.auto_awesome,
                            color: Colors.white12,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: goldColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 10),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['rank']!,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  item['name']!,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. COLLECTIONS GRID
  Widget _buildCollectionsGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          Text(
            "LUXURY COLLECTIONS",
            style: GoogleFonts.outfit(
              color: goldColor,
              letterSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              _buildCategoryCard(
                "Women's",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/e4/76/3c/e4763c8d28dc6fcd71694d8c089effcf.jpg",
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Unisex",
                false,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/cc/07/2d/cc072de8156a5ebeb75d1b920384698c.jpg",
                isTall: true,
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Women's",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/76/dc/a9/76dca998414af3a99890e1eab5a69f22.jpg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New Section 1: Signature Series
  Widget _buildSignatureSeries() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
      child: Column(
        children: [
          Text(
            "SIGNATURE SERIES",
            style: GoogleFonts.outfit(
              color: goldColor,
              letterSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              _buildCategoryCard(
                "Royal",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/76/dc/a9/76dca998414af3a99890e1eab5a69f22.jpg",
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Midnight",
                false,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/e4/76/3c/e4763c8d28dc6fcd71694d8c089effcf.jpg",
                isTall: true,
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Oud Luxury",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/cc/07/2d/cc072de8156a5ebeb75d1b920384698c.jpg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New Section 2: Masterpiece Gallery
  Widget _buildMasterpieceGallery() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
      child: Column(
        children: [
          Text(
            "MASTERPIECE GALLERY",
            style: GoogleFonts.outfit(
              color: goldColor,
              letterSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              _buildCategoryCard(
                "Artisan",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/cc/07/2d/cc072de8156a5ebeb75d1b920384698c.jpg",
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Imperial",
                false,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/76/dc/a9/76dca998414af3a99890e1eab5a69f22.jpg",
                isTall: true,
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Noir Elite",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/e4/76/3c/e4763c8d28dc6fcd71694d8c089effcf.jpg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New Section 3: Vintage Heritage
  Widget _buildVintageHeritage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
      child: Column(
        children: [
          Text(
            "VINTAGE HERITAGE",
            style: GoogleFonts.outfit(
              color: goldColor,
              letterSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              _buildCategoryCard(
                "Legacy",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/e4/76/3c/e4763c8d28dc6fcd71694d8c089effcf.jpg",
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Ancestral",
                false,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/cc/07/2d/cc072de8156a5ebeb75d1b920384698c.jpg",
                isTall: true,
              ),
              const SizedBox(width: 20),
              _buildCategoryCard(
                "Timeless",
                true,
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/76/dc/a9/76dca998414af3a99890e1eab5a69f22.jpg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    bool isSquare,
    String url, {
    bool isTall = false,
  }) {
    return Expanded(
      child: Container(
        height: isTall ? 450 : 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(width: 30, height: 1, color: goldColor),
                ],
              ),
            ),
            if (isTall)
              const Positioned(
                top: 20,
                right: 20,
                child: Icon(Icons.auto_awesome, color: goldColor, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  // 8. IMMERSIVE BANNER CAROUSEL
  Widget _buildImmersiveCarousel() {
    final banners = [
      'https://images.weserv.nl/?url=https://i.pinimg.com/736x/74/81/84/7481840659c2f4d4fb7fb37bda11e094.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/736x/8a/89/1e/8a891e3c2884bb28825ac85a8889896f.jpg',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 80),
      child: CarouselSlider.builder(
        itemCount: banners.length,
        options: CarouselOptions(
          height: 600,
          viewportFraction: 0.85,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 6),
        ),
        itemBuilder: (context, index, realIndex) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(banners[index]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: const EdgeInsets.all(80),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "THE ART OF SCENT",
                  style: GoogleFonts.outfit(
                    color: goldColor,
                    letterSpacing: 8,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "EXPLORE THE\nSIGNATURE EDITION",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 40),
                _buildGoldBttn("VIEW COLLECTION"),
              ],
            ),
          );
        },
      ),
    );
  }

  // 9. MODERN BENTO COLLECTION
  Widget _buildBentoCollection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          Text(
            "CURATED COLLECTIONS",
            style: GoogleFonts.outfit(
              color: goldColor,
              fontSize: 14,
              letterSpacing: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            height: 700,
            child: Row(
              children: [
                // Big Left
                Expanded(
                  flex: 6,
                  child: _buildBentoItem(
                    "THE NOIR SERIES",
                    "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/91/ca/3691cae92f4258bd5a2035ac6e7227c1.jpg",
                    isLarge: true,
                  ),
                ),
                const SizedBox(width: 20),
                // Stacked Right
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildBentoItem(
                          "ESSENTIAL OILS",
                          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/9d/33/79/9d337952a714d6708e27f37a87dc649d.jpg",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildBentoItem(
                          "INCENSE LUXE",
                          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/19/e0/9b/19e09ba506b58e7236ba9854070edfdb.jpg",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10. ARTISAN MOSAIC
  Widget _buildArtisanMosaic() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
      child: SizedBox(
        height: 450,
        child: Row(
          children: [
            Expanded(
              child: _buildBentoItem(
                "CEREMONY",
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/74/81/84/7481840659c2f4d4fb7fb37bda11e094.jpg",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildBentoItem(
                "ELEGANCE",
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/8a/89/1e/8a891e3c2884bb28825ac85a8889896f.jpg",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildBentoItem(
                "HERITAGE",
                "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/91/ca/3691cae92f4258bd5a2035ac6e7227c1.jpg",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 11. EXCLUSIVE HIGHLIGHT
  Widget _buildExclusiveHighlight() {
    return Container(
      width: double.infinity,
      height: 500,
      margin: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: panelBg,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1200&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: goldColor, size: 40),
          const SizedBox(height: 30),
          Text(
            "THE EXCLUSIVE EXPERIENCE",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 20),
          Container(width: 80, height: 1, color: goldColor),
          const SizedBox(height: 20),
          Text(
            "JOIN THE CIRCLE OF DEZEL FOR PRIVATE RELEASES",
            style: GoogleFonts.outfit(
              color: goldColor.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 50),
          _buildGoldBttn("BECOME A MEMBER"),
        ],
      ),
    );
  }

  Widget _buildBentoItem(String title, String url, {bool isLarge = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: isLarge ? 28 : 20,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 40, height: 1, color: goldColor),
        ],
      ),
    );
  }

  Widget _buildGoldBttn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: goldColor.withValues(alpha: 0.6)),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: goldColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
