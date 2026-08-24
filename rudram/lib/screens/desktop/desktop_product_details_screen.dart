import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/data_models.dart';
import '../../utils/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/rooms_provider.dart';
import '../../widgets/cart_sidebar.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';

class DesktopProductDetailsScreen extends StatefulWidget {
  final ProductItem product;

  const DesktopProductDetailsScreen({super.key, required this.product});

  @override
  State<DesktopProductDetailsScreen> createState() =>
      _DesktopProductDetailsScreenState();
}

class _DesktopProductDetailsScreenState
    extends State<DesktopProductDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _bgController;

  late Animation<Offset> _leftSlideAnimation;
  late Animation<Offset> _rightSlideAnimation;
  late Animation<double> _centerScaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _images = [
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product.image.isNotEmpty) {
      _images[0] = widget.product.image;
    }

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _leftSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _rightSlideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _centerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.product.title} added to cart!"),
        backgroundColor: AppColors.primaryOrange,
        behavior: SnackBarBehavior.floating,
        width: 300,
      ),
    );
  }

  void _showRoomSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final rooms = context.watch<RoomsProvider>().rooms;
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            "SELECT A ROOM",
            style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 2),
          ),
          content: rooms.isEmpty
              ? const Text(
                  "No rooms found. Go to Rooms page to create one.",
                  style: TextStyle(color: Colors.white70),
                )
              : SizedBox(
                  width: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(room.image),
                        ),
                        title: Text(
                          room.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          context.read<RoomsProvider>().addProductToRoom(
                            room.id,
                            widget.product,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added to ${room.name}!",
                                style: const TextStyle(color: Colors.black),
                              ),
                              backgroundColor: const Color(0xFFD4AF37),
                              behavior: SnackBarBehavior.floating,
                              width: 300,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      endDrawer: const CartSidebar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(),
            _buildMainContent(),
            const SizedBox(height: 80),
            _buildLuxurySection(),
            const SizedBox(height: 80),
            _buildGallerySection(),
            const SizedBox(height: 80),
            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      height: 800,
      width: double.infinity,
      color: const Color(0xFFEFF3EF), // Light greenish-grey background
      child: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BackgroundPainter(_bgController.value),
                );
              },
            ),
          ),

          // Main 3-Column Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
            child: Row(
              children: [
                // LEFT COLUMN: Text Info
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _leftSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.product.title,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Experience the benefits of timeless elegance with our precision-crafted jewelry, designed to last forever.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {}, // Navigate to products
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "VIEW PRODUCTS",
                              style: TextStyle(
                                color: Color(
                                  0xFF2C8A98,
                                ), // Teal-ish color from image
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Color Selection
                          const Text(
                            "Available Colors",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildColorCircle(
                                const Color(0xFF7CB342),
                              ), // Green
                              const SizedBox(width: 12),
                              _buildColorCircle(
                                const Color(0xFF5E35B1),
                              ), // Deep Purple
                              const SizedBox(width: 12),
                              _buildColorCircle(const Color(0xFFE53935)), // Red
                              const SizedBox(width: 12),
                              _buildColorCircle(
                                const Color(0xFF039BE5),
                              ), // Blue
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // CENTER COLUMN: Podium & Product
                Expanded(
                  flex: 5,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _centerScaleAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Gradient Circle for Emphasis
                          Container(
                            width: 450,
                            height: 450,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFA5D6A7).withOpacity(0.3),
                                  const Color(0xFF81C784).withOpacity(0.1),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),

                          // Floating Spheres (Decorative)
                          AnimatedBuilder(
                            animation: _bgController,
                            builder: (context, child) {
                              return Stack(
                                children: [
                                  Positioned(
                                    right: 40,
                                    top:
                                        150 +
                                        (_bgController.value * 20), // Float Y
                                    child: _buildFloatingSphere(40),
                                  ),
                                  Positioned(
                                    left: 60,
                                    bottom: 200 - (_bgController.value * 30),
                                    child: _buildFloatingSphere(60),
                                  ),
                                  Positioned(
                                    bottom: 80,
                                    right: 100 + (_bgController.value * 15),
                                    child: _buildFloatingSphere(25),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Podium (White Base)
                          Positioned(
                            bottom: 100,
                            child: Container(
                              width: 350,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  // Inner rim
                                  width: 340,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Product Image
                          Positioned(
                            bottom: 130, // Just sitting on the podium
                            child: Hero(
                              tag: widget.product.title,
                              child: Container(
                                height: 400, // Adjust based on need
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                child: Image.network(
                                  widget.product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            ),
                          ),

                          // Text overlay on bottle (optional, matches "DEEP WATER")
                          Positioned(
                            bottom: 180,
                            child: Text(
                              "RUDRAM",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 24,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // RIGHT COLUMN: Cards
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _rightSlideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PRE-ORDER",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "We are in the final stages of preparation. You can place your pre-order now.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "₹${widget.product.currentPrice}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C8A98), // Teal
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _addToCart,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "ADD TO CART",
                                    style: TextStyle(
                                      color: Color(0xFF2C3E50),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _showRoomSelectionDialog,
                                  icon: const Icon(
                                    Icons.meeting_room_outlined,
                                    size: 16,
                                  ),
                                  label: const Text("ADD TO ROOM"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFD4AF37),
                                    side: const BorderSide(
                                      color: Color(0xFFD4AF37),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Bottom Card (Image/Video Placeholder)
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    widget
                                        .product
                                        .image, // Use same image or different variant
                                    fit: BoxFit.cover,
                                    color: Colors.white.withOpacity(
                                      0.9,
                                    ), // Lighten it to look different
                                    colorBlendMode: BlendMode.modulate,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C3E50),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  right: -15,
                                  child: Transform.rotate(
                                    angle: -1.57,
                                    child: const Text(
                                      "PLAY VIDEO",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Foreground Foliage (Static images or shapes)
          // Skipping detailed foliage unless I have assets, but conceptually they go here
        ],
      ),
    );
  }

  Widget _buildFloatingSphere(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.5),
          radius: 0.8,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade500,
            Colors.grey.shade800,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: size / 2,
            offset: Offset(size / 4, size / 4),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildLuxurySection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF9F6),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LUXURY MEETS\nPRECISION",
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Every curve, every facet is a testament to our commitment to perfection. Hand-selected gemstones and precision-engineered settings ensure that your jewelry is not just an accessory, but a legacy.",
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "VIEW CERTIFICATION",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: 5,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=800",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -40,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Purity\nGuaranteed",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 60,
                          height: 4,
                          color: AppColors.primaryOrange,
                        ),
                      ],
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

  Widget _buildGallerySection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "OUR GALLERY",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 350,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Container(
                width: 400,
                margin: const EdgeInsets.only(right: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(_images[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Center point moves slightly
    final centerX = size.width * 0.5 + (animationValue * 50 - 25);
    final centerY = size.height * 0.5 + (animationValue * 30 - 15);

    // Circle 1
    paint.color = const Color(0xFFA5D6A7).withOpacity(0.05);
    canvas.drawCircle(Offset(centerX - 200, centerY - 100), 150, paint);

    // Circle 2
    paint.color = const Color(0xFF81C784).withOpacity(0.05);
    canvas.drawCircle(Offset(centerX + 200, centerY + 100), 200, paint);

    // Circle 3
    paint.color = const Color(0xFF2C3E50).withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      100 + (animationValue * 20),
      paint,
    );

    // Circle 4
    paint.color = const Color(0xFF2C8A98).withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      120 - (animationValue * 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
