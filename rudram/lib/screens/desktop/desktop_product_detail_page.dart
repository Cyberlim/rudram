import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../models/data_models.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../providers/rooms_provider.dart';
import '../../providers/cart_provider.dart';
import 'desktop_checkout_page.dart';

enum ProductViewMode { gallery, carousel, video }

class DesktopProductDetailPage extends StatefulWidget {
  final ProductItem product;
  const DesktopProductDetailPage({super.key, required this.product});

  @override
  State<DesktopProductDetailPage> createState() =>
      _DesktopProductDetailPageState();
}

class _DesktopProductDetailPageState extends State<DesktopProductDetailPage> {
  late String _selectedImage;
  late List<String> _galleryImages;
  ProductViewMode _currentMode = ProductViewMode.gallery;
  bool _isCartOpen = false;
  void _addToCart(ProductItem product) {
    context.read<CartProvider>().addItem(product);
    setState(() {
      _isCartOpen = true;
    });
  }

  void _showRoomSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final rooms = context.watch<RoomsProvider>().rooms;
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "SELECT A ROOM",
            style: TextStyle(
              color: Color(0xFFD4AF37),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: rooms.isEmpty
              ? const Text(
                  "No rooms found. Go to Rooms page to create one.",
                  style: TextStyle(color: Colors.black54),
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
                          style: const TextStyle(color: Colors.black),
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
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black,
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
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.product.image;
    _galleryImages = [
      widget.product.image,
      "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
      "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
      "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
      "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
      "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
      "https://images.weserv.nl/?url=https://i.pinimg.com/736x/54/26/f3/5426f37ee3738c45aa2e07091c6ea709.jpg",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                DesktopHeader(
                  onCartTap: () => setState(() => _isCartOpen = true),
                ),
                _ProductHeroSection(
                  product: widget.product,
                  selectedImage: _selectedImage,
                  galleryImages: _galleryImages,
                  currentMode: _currentMode,
                  onImageSelected: (img) {
                    setState(() {
                      _selectedImage = img;
                      _currentMode = ProductViewMode.gallery;
                    });
                  },
                  onModeChanged: (mode) {
                    setState(() {
                      _currentMode = mode;
                    });
                  },
                  onAddToCart: () => _addToCart(widget.product),
                  onAddToRoom: _showRoomSelectionDialog,
                ),
                const _ProductStudioGallery(),
                const _ProductTabsSection(),
                const SizedBox(height: 100),
                const _ProductCarouselSection(
                  title: "YOU MAY ALSO LIKE",
                  subtitle: "Related Masterpieces",
                ),
                const SizedBox(height: 100),
                const _ProductCarouselSection(
                  title: "BEST SELLERS",
                  subtitle: "Most Loved Masterpieces",
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          if (_isCartOpen)
            GestureDetector(
              onTap: () => setState(() => _isCartOpen = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            right: _isCartOpen ? 0 : -450,
            top: 0,
            bottom: 0,
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return _CartSidebar(
                  items: cart.items.map((e) => e.product).toList(),
                  onClose: () => setState(() => _isCartOpen = false),
                  onRemove: (product) {
                    cart.removeItem(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHeroSection extends StatelessWidget {
  final ProductItem product;
  final String selectedImage;
  final List<String> galleryImages;
  final ProductViewMode currentMode;
  final Function(String) onImageSelected;
  final Function(ProductViewMode) onModeChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToRoom;

  const _ProductHeroSection({
    required this.product,
    required this.selectedImage,
    required this.galleryImages,
    required this.currentMode,
    required this.onImageSelected,
    required this.onModeChanged,
    required this.onAddToCart,
    required this.onAddToRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      color: const Color(0xFFFBFBFF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerticalSidebar(),
          const SizedBox(width: 50),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeButton("GALLERY", ProductViewMode.gallery),
                      _buildModeButton("360° VIEW", ProductViewMode.carousel),
                      _buildModeButton("WATCH VIDEO", ProductViewMode.video),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildDynamicDisplay(),
                const SizedBox(height: 25),
                if (currentMode == ProductViewMode.gallery) _buildThumbnails(),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(flex: 5, child: _buildDetailedProductInfo(context)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, ProductViewMode mode) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF818CF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: isSelected ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicDisplay() {
    switch (currentMode) {
      case ProductViewMode.gallery:
        return _buildMainImage();
      case ProductViewMode.carousel:
        return _buildVerticalCarousel();
      case ProductViewMode.video:
        return _buildVideoPlaceholder();
    }
  }

  Widget _buildMainImage() {
    return Hero(
      tag: 'product_${product.image}',
      child: Container(
        height: 450,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(selectedImage, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildVerticalCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 450,
        viewportFraction: 0.9,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        scrollDirection: Axis.vertical,
        enlargeCenterPage: true,
      ),
      items: galleryImages.map((img) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(img, fit: BoxFit.cover),
        );
      }).toList(),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            product.image,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "LOADING PRODUCT VIDEO...",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnails() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          final img = galleryImages[index];
          final isSelected = img == selectedImage;
          return GestureDetector(
            onTap: () => onImageSelected(img),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF818CF8)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(img, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalSidebar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _verticalText("100% natural"),
        const SizedBox(height: 40),
        _verticalText("no side effect"),
        const SizedBox(height: 40),
        _verticalText("healthy"),
        const SizedBox(height: 80),
        const Icon(Icons.share, size: 18, color: Colors.black54),
        const SizedBox(height: 20),
        const Text(
          "f",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.alternate_email, size: 18, color: Colors.black54),
      ],
    );
  }

  Widget _verticalText(String text) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black38,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDetailedProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PREMIUM COLLECTION",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF818CF8).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          product.title.toUpperCase(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: index < 4
                      ? const Color(0xFFFBBF24)
                      : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "4.8 (124 reviews)",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "Masterfully designed with precision and soul. This piece embodies the perfect harmony of contemporary elegance and timeless craftsmanship.",
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.8),
        ),
        const SizedBox(height: 40),
        Text(
          "₹${product.currentPrice.toInt()}",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final qty = cart.getQuantity(product);
                  if (qty > 0) {
                    return Container(
                      height: 56, // matching height
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF818CF8)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Color(0xFF818CF8)),
                            onPressed: () => cart.updateQuantity(product, qty - 1),
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Color(0xFF818CF8)),
                            onPressed: () => cart.updateQuantity(product, qty + 1),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildActionButton(
                    "ADD TO CART",
                    const Color(0xFF818CF8),
                    Colors.white,
                    Icons.shopping_bag_outlined,
                    onTap: () {
                      onAddToCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} added to cart!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                "ADD TO ROOM",
                Colors.white,
                const Color(0xFFD4AF37),
                Icons.meeting_room_outlined,
                onTap: onAddToRoom,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                "BUY NOW",
                const Color(0xFF1E293B),
                Colors.white,
                Icons.bolt_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DesktopCheckoutPage(cartItems: [product]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color bg,
    Color text,
    IconData icon, {
    VoidCallback? onTap,
    bool isOutlined = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(15),
        border: isOutlined ? Border.all(color: text, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isOutlined ? text : Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isOutlined ? text : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductStudioGallery extends StatelessWidget {
  const _ProductStudioGallery();
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ProductTabsSection extends StatelessWidget {
  const _ProductTabsSection();
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ProductCarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ProductCarouselSection({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _CartSidebar extends StatelessWidget {
  final List<ProductItem> items;
  final VoidCallback onClose;
  final Function(ProductItem) onRemove;
  const _CartSidebar({
    required this.items,
    required this.onClose,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      color: Colors.white,
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CART",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Image.network(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.title),
                  subtitle: Text("₹${item.currentPrice}"),
                  trailing: IconButton(
                    onPressed: () => onRemove(item),
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DesktopCheckoutPage(cartItems: items),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
            ),
            child: const Text(
              "CHECKOUT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
