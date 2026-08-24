import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DesktopExclusiveOffersSection extends StatelessWidget {
  const DesktopExclusiveOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic height calculation: Scale with width but cap at 600px
        double sectionHeight = constraints.maxWidth * 0.45;
        if (sectionHeight > 600) sectionHeight = 600;
        if (sectionHeight < 400) sectionHeight = 400;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Exclusive Collection",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: sectionHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Left Vertical - SHOP RINGS (Video)
                    Expanded(
                      flex: 3,
                      child: _VideoBannerCard(
                        title: "SHOP RINGS",
                        videoUrl:
                            "https://v1.pinimg.com/videos/mc/720p/bd/1f/61/bd1f61106e313044434aa2f8a9d872ae.mp4",
                      ),
                    ),
                    const SizedBox(width: 20),

                    // 2. Middle Column
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // Middle Top - SHOP BRACELETS (Horizontal)
                          Expanded(
                            flex: 1,
                            child: _ImageBannerCard(
                              title: "SHOP BRACELETS",
                              imageUrl:
                                  "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/71/6a/8b/716a8b16f3d1e1f7d2f9d8f9f8f9f8f9.jpg", // Placeholder high quality
                              fallbackUrl:
                                  "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=800",
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Middle Bottom - Shop Necklaces & Shop Earrings (Two Squares)
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ImageBannerCard(
                                    title: "SHOP NECKLACES",
                                    imageUrl:
                                        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/c1/8c/d1/c18cd1b1c1b1c1b1c1b1c1b1c1b1c1b1.jpg",
                                    fallbackUrl:
                                        "https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=800",
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _ImageBannerCard(
                                    title: "SHOP EARRINGS",
                                    imageUrl:
                                        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/e1/8e/d1/e18ed1e1e1e1e1e1e1e1e1e1e1e1e1e1.jpg",
                                    fallbackUrl:
                                        "https://images.unsplash.com/photo-1635767798638-3e25273a8236?w=800",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // 3. Right Vertical - SHOP CHARM (Video)
                    Expanded(
                      flex: 3,
                      child: _VideoBannerCard(
                        title: "SHOP CHARM",
                        videoUrl:
                            "https://v1.pinimg.com/videos/mc/720p/c2/0d/33/c20d334a9bfe93f8e9b6be3615c0c5a3.mp4",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoBannerCard extends StatefulWidget {
  final String title;
  final String videoUrl;

  const _VideoBannerCard({required this.title, required this.videoUrl});

  @override
  State<_VideoBannerCard> createState() => _VideoBannerCardState();
}

class _VideoBannerCardState extends State<_VideoBannerCard> {
  late VideoPlayerController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              Container(color: const Color(0xFFF5F5F5)),

            // Overlay with Title
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.3),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: _isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(height: 2, width: 60, color: Theme.of(context).cardColor),
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

class _ImageBannerCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String fallbackUrl;

  const _ImageBannerCard({
    required this.title,
    required this.imageUrl,
    required this.fallbackUrl,
  });

  @override
  State<_ImageBannerCard> createState() => _ImageBannerCardState();
}

class _ImageBannerCardState extends State<_ImageBannerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.network(widget.fallbackUrl, fit: BoxFit.cover),
            ),

            // Overlay with Title
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.3),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: _isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(height: 2, width: 40, color: Theme.of(context).cardColor),
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
