import 'package:flutter/material.dart';
import '../../models/data_models.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import 'desktop_product_detail_page.dart';

class DesktopCategoryProductsPage extends StatefulWidget {
  final String categoryTitle;

  const DesktopCategoryProductsPage({super.key, required this.categoryTitle});

  @override
  State<DesktopCategoryProductsPage> createState() =>
      _DesktopCategoryProductsPageState();
}

class _DesktopCategoryProductsPageState
    extends State<DesktopCategoryProductsPage> {
  final List<ProductItem> allProducts = [
    const ProductItem(
      title: "Royal Emerald Diamond Set",
      currentPrice: 85000.00,
      oldPrice: 125000.00,
      discount: "-32%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    ),
    const ProductItem(
      title: "Sapphire Drop Earrings",
      currentPrice: 42000.00,
      oldPrice: 55000.00,
      discount: "-25%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
    ),
    const ProductItem(
      title: "Infinity Gold Bracelet",
      currentPrice: 35000.00,
      oldPrice: 45000.00,
      discount: "-22%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
    ),
    const ProductItem(
      title: "Classic Solitaire Ring",
      currentPrice: 95000.00,
      oldPrice: 110000.00,
      discount: "-15%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
    ),
    const ProductItem(
      title: "Rose Gold Pendant",
      currentPrice: 28000.00,
      oldPrice: 35000.00,
      discount: "-20%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
    ),
    const ProductItem(
      title: "Bridal Meenakari Set",
      currentPrice: 125000.00,
      oldPrice: 155000.00,
      discount: "-19%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/54/26/f3/5426f37ee3738c45aa2e07091c6ea709.jpg",
    ),
    const ProductItem(
      title: "Diamond Stud Earrings",
      currentPrice: 15000.00,
      oldPrice: 25000.00,
      discount: "-40%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/a2/d1/53/a2d153c12d7c1216c406500543686ceb.jpg",
    ),
    const ProductItem(
      title: "Gold Choker Necklace",
      currentPrice: 45000.00,
      oldPrice: 60000.00,
      discount: "-25%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/55/5f/81/555f8192d281f652159bbf59a2bb673c.jpg",
    ),
    const ProductItem(
      title: "Pearl Drop Necklace",
      currentPrice: 22000.00,
      oldPrice: 30000.00,
      discount: "-26%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter products based on category title for realism
    List<ProductItem> filteredProducts = allProducts.where((p) {
      if (widget.categoryTitle.toLowerCase().contains("necklace")) {
        return p.title.toLowerCase().contains("necklace") ||
            p.title.toLowerCase().contains("set") ||
            p.title.toLowerCase().contains("choker") ||
            p.title.toLowerCase().contains("pendant");
      } else if (widget.categoryTitle.toLowerCase().contains("earring")) {
        return p.title.toLowerCase().contains("earring") ||
            p.title.toLowerCase().contains("drop") ||
            p.title.toLowerCase().contains("stud");
      } else if (widget.categoryTitle.toLowerCase().contains("ring")) {
        return p.title.toLowerCase().contains("ring") ||
            p.title.toLowerCase().contains("solitaire");
      } else if (widget.categoryTitle.toLowerCase().contains("bracelet") ||
          widget.categoryTitle.toLowerCase().contains("bangle")) {
        return p.title.toLowerCase().contains("bracelet") ||
            p.title.toLowerCase().contains("bangle");
      }
      return true; // Show all if no direct match
    }).toList();

    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(),

            // Hero Banner for Category
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage(
                    "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/18/22/ee/1822eef2f6cc34174e52b9d9e6857d33.jpg",
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.categoryTitle.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 2, width: 100, color: Colors.white),
                    const SizedBox(height: 15),
                    Text(
                      "Exquisite collection of handcrafted ${widget.categoryTitle.toLowerCase()}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 100,
                vertical: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs & Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                ),
                                child: Text(
                                  "Home",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: Colors.grey,
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  "Categories",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(
                                widget.categoryTitle,
                                style: TextStyle(
                                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "${filteredProducts.length} Products Found",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                            ),
                          ),
                        ],
                      ),
                      // Sorting Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Sort by: Featured",
                              style: TextStyle(
                                fontSize: 14,
                                color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.keyboard_arrow_down, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Product Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 40,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _CategoryProductCard(
                        product: filteredProducts[index],
                      );
                    },
                  ),
                ],
              ),
            ),

            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }
}

class _CategoryProductCard extends StatefulWidget {
  final ProductItem product;
  const _CategoryProductCard({required this.product});

  @override
  State<_CategoryProductCard> createState() => _CategoryProductCardState();
}

class _CategoryProductCardState extends State<_CategoryProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DesktopProductDetailPage(product: widget.product),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              // Image Box
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.product.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.image_outlined, size: 40),
                            ),
                      ),
                      if (_isHovered)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Text(
                      widget.product.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹${widget.product.currentPrice.toInt()}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.discount,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${widget.product.oldPrice.toInt()}",
                          style: const TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
