import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/data_models.dart';
import '../services/gemini_service.dart';
import '../utils/app_colors.dart';

class AiStylistScreen extends StatefulWidget {
  const AiStylistScreen({super.key});

  @override
  State<AiStylistScreen> createState() => _AiStylistScreenState();
}

class _AiStylistScreenState extends State<AiStylistScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isThinking = false;
  bool _showProducts = false;
  String _errorMessage = '';

  late AnimationController _pulseController;
  late AnimationController _moveController;
  late AnimationController _thinkingController;
  late AnimationController _bubbleController;
  late AnimationController _scaleController;
  late AnimationController _expandController;

  late Animation<Offset> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;
  final List<BubbleData> _bubbles = [];

  List<ProductItem> _recommendedProducts = [];
  final GeminiService _gemini = GeminiService();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _moveAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2.0)).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
        );

    _thinkingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOutCubic),
    );

    _initBubbles();
  }

  void _initBubbles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _bubbles.add(
        BubbleData(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 30 + 20,
          speed: random.nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _moveController.dispose();
    _thinkingController.dispose();
    _bubbleController.dispose();
    _scaleController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _onAvatarLongPressStart(LongPressStartDetails details) {
    if (!_showProducts) {
      _moveController.forward();
      setState(() => _isListening = true);
      _scaleController.forward();
    }
  }

  void _onAvatarLongPressEnd(LongPressEndDetails details) {
    if (_isListening) {
      // Show prompt dialog instead of voice
      setState(() {
        _isListening = false;
      });
      _moveController.reverse();
      _scaleController.reverse();
      _showStylePromptDialog();
    }
  }

  /// Opens a text input dialog, then calls Gemini with the user's prompt.
  Future<void> _showStylePromptDialog() async {
    final TextEditingController promptCtrl = TextEditingController();
    final String? prompt = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        Color(0xFF6366F1),
                        Color(0xFFEC4899),
                      ]),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Stylist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Describe the occasion or style you\'re shopping for:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptCtrl,
                autofocus: true,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'e.g. "A traditional wedding", "Office look", "Anniversary gift"',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF6366F1), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, null),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white60)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(ctx, promptCtrl.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ask AI ✨',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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

    if (prompt == null || prompt.isEmpty) return;

    // Start thinking animation
    setState(() => _isThinking = true);
    _expandController.forward();

    try {
      final products = await _gemini.getStyleRecommendations(prompt);
      if (mounted) {
        setState(() {
          _recommendedProducts = products;
          _isThinking = false;
          _showProducts = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _errorMessage = 'Could not get recommendations. Please try again.';
        });
        _expandController.reverse();
        _showSnackError(_errorMessage);
      }
    }
  }

  void _showSnackError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetState() {
    setState(() {
      _showProducts = false;
      _isListening = false;
      _isThinking = false;
      _recommendedProducts = [];
    });
    _moveController.reverse();
    _scaleController.reverse();
    _expandController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomBarHeight = screenHeight * 0.2;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _showProducts
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              title: const Text(
                'AI Stylist',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Stack(
        children: [
          if (!_showProducts)
            Positioned.fill(
              bottom: bottomBarHeight,
              child: _buildInstructions(),
            ),

          if (!_showProducts)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomBarHeight,
              child: _buildBottomBar(bottomBarHeight),
            ),

          // Fullscreen Expansion Circle
          if (_isThinking || _showProducts)
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final maxDim = math.max(screenWidth, screenHeight);
                final size = _expandAnimation.value * maxDim * 1.5;

                return Positioned.fill(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: size,
                          height: size,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                                Color(0xFFEC4899),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Thinking indicator
                      if (_isThinking && !_showProducts)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Styling your look...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_showProducts)
                        Positioned.fill(child: _buildProductsGrid()),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double height) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
        ),

        AnimatedBuilder(
          animation: _bubbleController,
          builder: (context, child) {
            return CustomPaint(
              painter: BubblePainter(
                bubbles: _bubbles,
                animation: _bubbleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        SlideTransition(
          position: _moveAnimation,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPressStart: _onAvatarLongPressStart,
              onLongPressEnd: _onAvatarLongPressEnd,
              onTap: _showStylePromptDialog, // Also respond to taps
              child: SizedBox(
                width: 150,
                height: 150,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildAvatar(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Your AI Jewellery Stylist',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tap or long-press the AI avatar below to describe your occasion and get personalised jewellery recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick prompt chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildPromptChip('👰 Wedding'),
              _buildPromptChip('🎁 Gift'),
              _buildPromptChip('💼 Office'),
              _buildPromptChip('🎉 Party'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label) {
    return GestureDetector(
      onTap: () async {
        setState(() => _isThinking = true);
        _expandController.forward();
        try {
          final products = await _gemini.getStyleRecommendations(label);
          if (mounted) {
            setState(() {
              _recommendedProducts = products;
              _isThinking = false;
              _showProducts = true;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isThinking = false);
            _expandController.reverse();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowSize = 30.0 + (_pulseController.value * 15.0);
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                blurRadius: glowSize,
                spreadRadius: glowSize * 0.3,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/gif.gif',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _resetState,
                ),
                const Expanded(
                  child: Text(
                    'AI Recommendations ✨',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _resetState();
                    Future.delayed(const Duration(milliseconds: 500),
                        _showStylePromptDialog);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text('Ask Again'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _recommendedProducts.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween<double>(begin: -100, end: 0),
                  curve: Curves.bounceOut,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: _buildProductCard(_recommendedProducts[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${product.title}'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.image,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(Icons.diamond_outlined,
                          size: 40, color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  );
                },
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${product.currentPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.discount,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366F1),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bubble Painter (same as before)
// ──────────────────────────────────────────────
class BubblePainter extends CustomPainter {
  final List<BubbleData> bubbles;
  final double animation;

  BubblePainter({required this.bubbles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      bubble.y = (bubble.y - bubble.speed * 0.01) % 1.0;
      if (bubble.y < 0) bubble.y = 1.0;

      final center = Offset(bubble.x * size.width, bubble.y * size.height);
      canvas.drawCircle(center, bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}
