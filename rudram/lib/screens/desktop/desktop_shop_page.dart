import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/data_models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/desktop/desktop_header.dart';
import 'desktop_product_detail_page.dart';

// ─── Sort Options ───────────────────────────────────────────────
enum _SortOption { defaultOrder, priceLow, priceHigh, newest, discount }

class DesktopShopPage extends StatefulWidget {
  final String initialSearchQuery;
  const DesktopShopPage({super.key, this.initialSearchQuery = ""});

  @override
  State<DesktopShopPage> createState() => _DesktopShopPageState();
}

class _DesktopShopPageState extends State<DesktopShopPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;

  // ── Data ──────────────────────────────────────────
  List<ProductItem> _allProducts = [];
  bool _isLoading = true;
  StreamSubscription? _productSub;

  // ── Filters ────────────────────────────────────────
  String _selectedCategory = "All";
  String _searchQuery = "";
  RangeValues _priceRange = const RangeValues(0, 1000000);
  Set<String> _selectedOccasions = {};
  Set<String> _selectedGenders = {};
  Set<String> _selectedColors = {};
  Set<String> _selectedDiscounts = {};
  int? _minRating;
  _SortOption _sortOption = _SortOption.defaultOrder;

  // Sort dropdown state
  String _sortLabel = "Default";

  // ── Filter definitions ────────────────────────────
  static const List<String> _categories = [
    "All", "Rings", "Necklace", "Earrings", "Bracelet", "Watch", "Gold", "Silver"
  ];

  static const List<String> _occasions = [
    "Bridal", "Casual Wear", "Party Wear", "Office Wear", "Wedding", "Daily Wear"
  ];

  static const List<String> _genders = ["Women", "Men", "Unisex", "Kids"];

  static const Map<String, Color> _colorMap = {
    "Gold": Color(0xFFFFD700),
    "Rose Gold": Color(0xFFB76E79),
    "Silver": Color(0xFFC0C0C0),
    "White Gold": Color(0xFFE8E8E8),
  };

  static const List<String> _discountOptions = [
    "50% or more", "40% or more", "30% or more", "20% or more", "10% or more"
  ];

  // ── Computed list ──────────────────────────────────
  List<ProductItem> get _filteredProducts {
    List<ProductItem> result = List.from(_allProducts);

    // Category
    if (_selectedCategory != "All") {
      result = result.where((p) {
        final cat = p.category.isNotEmpty ? p.category : p.title;
        return cat.toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // Search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) {
        return p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Price range
    result = result.where((p) =>
      p.currentPrice >= _priceRange.start && p.currentPrice <= _priceRange.end,
    ).toList();

    // Discount filter (parse from product.discount string e.g. "-32%")
    if (_selectedDiscounts.isNotEmpty) {
      result = result.where((p) {
        final raw = p.discount.replaceAll(RegExp(r'[^0-9]'), '');
        final pct = int.tryParse(raw) ?? 0;
        return _selectedDiscounts.any((d) {
          final minPct = int.tryParse(d.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return pct >= minPct;
        });
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case _SortOption.defaultOrder:
        break;
      case _SortOption.priceLow:
        result.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case _SortOption.priceHigh:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case _SortOption.newest:
        result = result.reversed.toList();
        break;
      case _SortOption.discount:
        result.sort((a, b) {
          final aD = int.tryParse(a.discount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bD = int.tryParse(b.discount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return bD.compareTo(aD);
        });
        break;
    }

    return result;
  }

  bool get _hasActiveFilters =>
      _selectedCategory != "All" ||
      _priceRange.start > 0 ||
      _priceRange.end < 1000000 ||
      _selectedOccasions.isNotEmpty ||
      _selectedGenders.isNotEmpty ||
      _selectedColors.isNotEmpty ||
      _selectedDiscounts.isNotEmpty ||
      _minRating != null ||
      _sortOption != _SortOption.defaultOrder;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scrollController = ScrollController();
    _subscribeToProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _productSub?.cancel();
    super.dispose();
  }

  void _subscribeToProducts() {
    _productSub = FirestoreService().getProducts().listen((products) {
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = "All";
      _priceRange = const RangeValues(0, 1000000);
      _selectedOccasions.clear();
      _selectedGenders.clear();
      _selectedColors.clear();
      _selectedDiscounts.clear();
      _minRating = null;
      _sortOption = _SortOption.defaultOrder;
      _sortLabel = "Default";
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const DesktopHeader(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left Sidebar ────────────────────────
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        right: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade100),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 30, right: 20, bottom: 40),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ──────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Filters",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF405870),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_hasActiveFilters)
                                  GestureDetector(
                                    onTap: _resetFilters,
                                    child: Text(
                                      "Clear all",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.indigo.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // ── Categories ───────────────
                          _buildSidebarSection(
                            "Categories",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return _sidebarItem(
                                  label: cat,
                                  isSelected: isSelected,
                                  onTap: () => setState(() => _selectedCategory = cat),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Price ────────────────────
                          _buildSidebarSection(
                            "Price",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹${_priceRange.start.round()}",
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    ),
                                    Text(
                                      "₹${_priceRange.end.round()}",
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF818CF8),
                                    inactiveTrackColor: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                                    thumbColor: isDark ? Colors.grey.shade300 : Colors.white,
                                    overlayColor: const Color(0xFF818CF8).withOpacity(0.1),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                      elevation: 4,
                                    ),
                                    trackHeight: 3,
                                  ),
                                  child: RangeSlider(
                                    values: _priceRange,
                                    min: 0,
                                    max: 1000000,
                                    divisions: 100,
                                    onChanged: (v) => setState(() => _priceRange = v),
                                  ),
                                ),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("₹0", style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                                    Text("₹10,00,000", style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Occasion ─────────────────
                          _buildSidebarSection(
                            "Occasion",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _occasions.map((occ) {
                                final isSelected = _selectedOccasions.contains(occ);
                                return _sidebarCheckItem(
                                  label: occ,
                                  isSelected: isSelected,
                                  onTap: () => setState(() {
                                    if (isSelected) {
                                      _selectedOccasions.remove(occ);
                                    } else {
                                      _selectedOccasions.add(occ);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Gender ───────────────────
                          _buildSidebarSection(
                            "Gender",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _genders.map((g) {
                                final isSelected = _selectedGenders.contains(g);
                                return _sidebarCheckItem(
                                  label: g,
                                  isSelected: isSelected,
                                  onTap: () => setState(() {
                                    if (isSelected) {
                                      _selectedGenders.remove(g);
                                    } else {
                                      _selectedGenders.add(g);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Color ────────────────────
                          _buildSidebarSection(
                            "Colors",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _colorMap.entries.map((e) {
                                final isSelected = _selectedColors.contains(e.key);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      if (isSelected) {
                                        _selectedColors.remove(e.key);
                                      } else {
                                        _selectedColors.add(e.key);
                                      }
                                    }),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF818CF8) : Colors.white,
                                            border: Border.all(
                                              color: isSelected ? const Color(0xFF818CF8) : Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, size: 11, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: e.value,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          e.key,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSelected ? const Color(0xFF405870) : const Color(0xFF94A3B8),
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Customer Rating ───────────
                          _buildSidebarSection(
                            "Customer Rating",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [4, 3, 2, 1].map((rating) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _minRating = _minRating == rating ? null : rating;
                                    }),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: _minRating == rating ? const Color(0xFF818CF8) : Colors.white,
                                            border: Border.all(
                                              color: _minRating == rating
                                                  ? const Color(0xFF818CF8)
                                                  : Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: _minRating == rating
                                              ? const Icon(Icons.check, size: 11, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Row(
                                          children: List.generate(5, (i) => Icon(
                                            Icons.star,
                                            size: 14,
                                            color: i < rating
                                                ? const Color(0xFFFCD34D)
                                                : const Color(0xFFF1F5F9),
                                          )),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "& above",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Discount ─────────────────
                          _buildSidebarSection(
                            "Discount",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _discountOptions.map((d) {
                                final isSelected = _selectedDiscounts.contains(d);
                                return _sidebarCheckItem(
                                  label: d,
                                  isSelected: isSelected,
                                  onTap: () => setState(() {
                                    if (isSelected) {
                                      _selectedDiscounts.remove(d);
                                    } else {
                                      _selectedDiscounts.add(d);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),
                          if (_hasActiveFilters)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _resetFilters,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF818CF8)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Clear All Filters",
                                  style: TextStyle(
                                    color: Color(0xFF818CF8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Right Content ─────────────────────────
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/18/22/ee/1822eef2f6cc34174e52b9d9e6857d33.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Toolbar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isLoading
                                  ? "Loading products..."
                                  : "SHOWING ${filtered.length} OF ${_allProducts.length} RESULTS",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            _buildSortDropdown(),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Product Grid / States
                        if (_isLoading)
                          const SizedBox(
                            height: 400,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF818CF8),
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          SizedBox(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.white12 : Colors.grey.shade200),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No products found",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Try adjusting your filters",
                                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey.shade400),
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton.icon(
                                    onPressed: _resetFilters,
                                    icon: const Icon(Icons.refresh, color: Color(0xFF818CF8)),
                                    label: const Text(
                                      "Clear all filters",
                                      style: TextStyle(color: Color(0xFF818CF8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 25,
                              mainAxisSpacing: 35,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildAnimatedProductCard(index, filtered[index]);
                            },
                          ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<_SortOption>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (opt) {
        setState(() {
          _sortOption = opt;
          switch (opt) {
            case _SortOption.defaultOrder: _sortLabel = "Default"; break;
            case _SortOption.priceLow: _sortLabel = "Price: Low to High"; break;
            case _SortOption.priceHigh: _sortLabel = "Price: High to Low"; break;
            case _SortOption.newest: _sortLabel = "Newest"; break;
            case _SortOption.discount: _sortLabel = "Best Discount"; break;
          }
        });
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: _SortOption.defaultOrder, child: Text("Default")),
        const PopupMenuItem(value: _SortOption.priceLow, child: Text("Price: Low to High")),
        const PopupMenuItem(value: _SortOption.priceHigh, child: Text("Price: High to Low")),
        const PopupMenuItem(value: _SortOption.newest, child: Text("Newest")),
        const PopupMenuItem(value: _SortOption.discount, child: Text("Best Discount")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text("Sort by: $_sortLabel", style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.white : Colors.black87),
          ],
        ),
      ),
    );
  }

  // ── Sidebar helpers ────────────────────────────────
  Widget _buildSidebarSection(String title, Widget content) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF405870),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          content,
          const SizedBox(height: 8),
          Divider(color: const Color(0xFFF1F5F9), thickness: 0.5),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected 
              ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
              : (isDark ? Colors.white70 : const Color(0xFF94A3B8)),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _sidebarCheckItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF818CF8) : (isDark ? Colors.grey.shade900 : Colors.white),
                border: Border.all(
                  color: isSelected ? const Color(0xFF818CF8) : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? (isDark ? Colors.white : const Color(0xFF405870)) : (isDark ? Colors.white70 : const Color(0xFF94A3B8)),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProductCard(int index, ProductItem product) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.04).clamp(0.0, 0.6),
            (index * 0.04 + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ).value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - progress)),
            child: _DesktopShopProductCard(product: product),
          ),
        );
      },
    );
  }
}

// ─── Product Card ───────────────────────────────────────────────
class _DesktopShopProductCard extends StatefulWidget {
  final ProductItem product;
  const _DesktopShopProductCard({required this.product});

  @override
  State<_DesktopShopProductCard> createState() => _DesktopShopProductCardState();
}

class _DesktopShopProductCardState extends State<_DesktopShopProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DesktopProductDetailPage(product: widget.product),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic))
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isHovered
                        ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product_${widget.product.id}_${widget.product.image}',
                        child: Image.network(
                          widget.product.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                      if (widget.product.discount.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.product.discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_isHovered)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.04),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "₹${widget.product.currentPrice.toInt()}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF333333),
                          ),
                        ),
                        if (widget.product.oldPrice > widget.product.currentPrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            "₹${widget.product.oldPrice.toInt()}",
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
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
