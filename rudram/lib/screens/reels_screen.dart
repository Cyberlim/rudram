import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'luxury_product_details_screen.dart';

class ReelsScreen extends StatefulWidget {
  final int initialIndex;
  const ReelsScreen({super.key, this.initialIndex = 0});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  PageController? _pageController;
  List<Map<String, dynamic>> _reelsData = [];
  bool _isLoading = true;

  // Cache controllers: Key is the page index
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    try {
      final reels = await FirestoreService().getActiveReels().first;
      if (mounted) {
        setState(() {
          _reelsData = reels;
          _isLoading = false;
        });

        if (_reelsData.isNotEmpty) {
          _pageController = PageController(initialPage: widget.initialIndex);
          _initializeControllerAtIndex(_currentPage);
          _initializeControllerAtIndex(_currentPage + 1);
          _initializeControllerAtIndex(_currentPage + 2);
          _playControllerAtIndex(_currentPage);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeControllerAtIndex(int index) async {
    if (_controllers.containsKey(index) || _reelsData.isEmpty) return;

    final url = _reelsData[index % _reelsData.length]['videoUrl'] as String;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    _controllers[index] = controller;

    // Initialize without blocking
    await controller.initialize();
    controller.setLooping(true);
    // Ensure UI rebuilds when init completes
    if (mounted) setState(() {});
  }

  void _playControllerAtIndex(int index) {
    final controller = _controllers[index];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
    } else {
      // If not ready, it will auto-play when rebuilt with initialized state
      // or we can add a listener. For now, simple check.
      controller?.addListener(() {
        if (controller.value.isInitialized &&
            !_controllers[index]!.value.isPlaying &&
            _currentPage == index) {
          controller.play();
        }
      });
    }
  }

  void _stopControllerAtIndex(int index) {
    final controller = _controllers[index];
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    // 1. Play current
    _playControllerAtIndex(index);

    // 2. Stop previous
    _stopControllerAtIndex(index - 1);
    // Also stop next if we swiped back
    _stopControllerAtIndex(index + 1);

    // 3. Preload next 2 reels
    _initializeControllerAtIndex(index + 1);
    _initializeControllerAtIndex(index + 2);

    // 4. Dispose far previous (keep immediate previous for smooth back swipe)
    _disposeControllerAtIndex(index - 2);
    // Dispose far next (if user jumped or swiped fast backwards)
    _disposeControllerAtIndex(index + 3);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      );
    }
    if (_reelsData.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text("No Reels Available", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          // Ensure controller exists (fallback if fast scroll)
          if (!_controllers.containsKey(index)) {
            _initializeControllerAtIndex(index);
          }

          final reelData = _reelsData[index % _reelsData.length];

          return ReelPlayerItem(
            // Key is important to preserve state
            key: ValueKey(index),
            controller: _controllers[index],
            reelData: reelData,
          );
        },
      ),
    );
  }
}

class ReelPlayerItem extends StatefulWidget {
  final VideoPlayerController? controller;
  final Map<String, dynamic> reelData;

  const ReelPlayerItem({super.key, this.controller, required this.reelData});

  @override
  State<ReelPlayerItem> createState() => _ReelPlayerItemState();
}

class _ReelPlayerItemState extends State<ReelPlayerItem> {
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    // Use the controller's volume state if available, or default
    _isMuted = widget.controller?.value.volume == 0;
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _shareContent() {
    // ignore: deprecated_member_use
    Share.share(
      "Check out this exquisite piece from Rudram!\n\n"
      "${widget.reelData['productName']} - ${widget.reelData['productPrice']}\n"
      "Watch the video: ${widget.reelData['videoUrl']}\n\n"
      "#Rudram #Luxury #Jewelry",
      subject: "${widget.reelData['productName']} - Rudram",
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isInitialized = controller != null && controller.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        isInitialized
            ? GestureDetector(
                onTap: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                  setState(() {});
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              ),

        if (isInitialized && !controller.value.isPlaying)
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 60,
            ),
          ),

        // Gradient & Overlays
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),

        // Mute Toggle Icon
        if (isInitialized)
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              onPressed: _toggleMute,
            ),
          ),

        // Back Button
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Right Actions
        Positioned(
          right: 16,
          bottom: 140,
          child: Column(
            children: [
              _buildAction(Icons.favorite, "1.2k", onTap: () {}),
              const SizedBox(height: 16),
              _buildAction(Icons.share, "Share", onTap: _shareContent),
            ],
          ),
        ),

        // Bottom Product Card (Rectangular Card UI)
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.reelData['productImage'] ?? "https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?w=200",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.reelData['productName'] ?? "Luxury Product",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.reelData['productPrice'] ?? "₹0",
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions (Add to Cart & See Detail)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: AppColors.primaryOrange,
                      ),
                      tooltip: "Add to Cart",
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added ${widget.reelData['productName']} to Cart"),
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Product Details
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LuxuryProductDetailsScreen(
                              product: {
                                'title': widget.reelData['productName'] ?? 'Luxury Product',
                                'price': widget.reelData['productPrice'] ?? '₹0',
                                'image': widget.reelData['productImage'] ?? '',
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 36), // Compact button
                      ),
                      child: const Text(
                        "See Detail",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
