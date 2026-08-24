import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../utils/lenis_scroll_physics.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';
import '../widgets/product_card.dart';

// ─────────────────────────────────────────────
// Enums for filter state
// ─────────────────────────────────────────────
enum SortOption { popular, newest, priceLow, priceHigh }

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // ─── Categories ────────────────────────────
  final List<CategoryItem> categories = [
    CategoryItem(title: "All", icon: Icons.grid_view, color: Colors.blue.shade50),
    CategoryItem(title: "Rings", icon: Icons.panorama_fish_eye, color: Colors.purple.shade50),
    CategoryItem(title: "Necks", icon: Icons.circle_outlined, color: Colors.amber.shade50),
    CategoryItem(title: "Earrings", icon: Icons.ac_unit, color: Colors.pink.shade50),
    CategoryItem(title: "Bracelets", icon: Icons.watch, color: Colors.teal.shade50),
    CategoryItem(title: "Watches", icon: Icons.watch_later_outlined, color: Colors.indigo.shade50),
    CategoryItem(title: "Gold", icon: Icons.monetization_on_outlined, color: Colors.yellow.shade50),
    CategoryItem(title: "Silver", icon: Icons.stars, color: Colors.grey.shade50),
  ];

  // ─── Data ──────────────────────────────────
  List<ProductItem> _allProducts = [];
  bool _isLoading = true;
  StreamSubscription? _productSub;

  // ─── Active filters (applied) ──────────────
  String _selectedCategory = "All";
  String _searchQuery = "";
  SortOption _appliedSort = SortOption.popular;
  RangeValues _appliedPriceRange = const RangeValues(0, 1000000);
  Set<String> _appliedOccasions = {};

  // ─── Pending filters (in modal) ────────────
  late SortOption _pendingSort;
  late RangeValues _pendingPriceRange;
  late Set<String> _pendingOccasions;

  final TextEditingController _searchController = TextEditingController();

  // ─── Computed list ─────────────────────────
  List<ProductItem> get _filteredProducts {
    List<ProductItem> result = List.from(_allProducts);

    // 1. Category filter
    if (_selectedCategory != "All") {
      result = result.where((p) {
        final cat = p.category.isNotEmpty ? p.category : p.title;
        return cat.toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // 2. Search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
    }

    // 3. Price range
    result = result.where((p) =>
      p.currentPrice >= _appliedPriceRange.start &&
      p.currentPrice <= _appliedPriceRange.end,
    ).toList();

    // 4. Occasion
    if (_appliedOccasions.isNotEmpty) {
      result = result.where((p) {
        return _appliedOccasions.any((occ) => 
          p.title.toLowerCase().contains(occ.toLowerCase()) || 
          p.category.toLowerCase().contains(occ.toLowerCase())
        );
      }).toList();
    }

    // 5. Sort
    switch (_appliedSort) {
      case SortOption.popular:
        // Keep Firestore order (default)
        break;
      case SortOption.newest:
        result = result.reversed.toList();
        break;
      case SortOption.priceLow:
        result.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case SortOption.priceHigh:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
    }

    return result;
  }

  bool get _hasActiveFilters =>
      _appliedSort != SortOption.popular ||
      _appliedPriceRange.start > 0 ||
      _appliedPriceRange.end < 1000000 ||
      _appliedOccasions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pendingSort = _appliedSort;
    _pendingPriceRange = _appliedPriceRange;
    _pendingOccasions = Set.from(_appliedOccasions);
    _subscribeToProducts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _productSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToProducts() {
    _productSub = FirestoreService().getProducts().listen((liveProducts) {
      if (mounted) {
        setState(() {
          _allProducts = liveProducts;
          _isLoading = false;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _selectCategory(String category) {
    if (_selectedCategory != category) {
      setState(() => _selectedCategory = category);
    }
  }

  void _showFilterModal(BuildContext context) {
    // Copy current applied filters into pending so modal opens with current state
    _pendingSort = _appliedSort;
    _pendingPriceRange = _appliedPriceRange;
    _pendingOccasions = Set.from(_appliedOccasions);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // ── Handle ─────────────────────────────
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ── Header ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter & Sort",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Close", style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // ── Scrollable content ─────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      children: [

                        // ── SORT BY ────────────────────────
                        const Text(
                          "Sort By",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: SortOption.values.map((opt) {
                            final label = _sortLabel(opt);
                            final selected = _pendingSort == opt;
                            return _modalChip(
                              label: label,
                              isSelected: selected,
                              onTap: () => setModalState(() => _pendingSort = opt),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 28),

                        // ── PRICE RANGE ────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Price Range",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₹${_pendingPriceRange.start.round()} – ₹${_pendingPriceRange.end.round()}",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: _pendingPriceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          activeColor: AppColors.primaryOrange,
                          inactiveColor: Colors.grey[200],
                          labels: RangeLabels(
                            "₹${_pendingPriceRange.start.round()}",
                            "₹${_pendingPriceRange.end.round()}",
                          ),
                          onChanged: (v) => setModalState(() => _pendingPriceRange = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹0",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              "₹10,00,000",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── OCCASION ──────────────────────
                        const Text(
                          "Occasion",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ["Wedding", "Party", "Daily Wear", "Office", "Gift"].map((occ) {
                            final selected = _pendingOccasions.contains(occ);
                            return _modalChip(
                              label: occ,
                              isSelected: selected,
                              onTap: () => setModalState(() {
                                if (selected) {
                                  _pendingOccasions.remove(occ);
                                } else {
                                  _pendingOccasions.add(occ);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // ── Action Buttons ─────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset everything
                              setModalState(() {
                                _pendingSort = SortOption.popular;
                                _pendingPriceRange = const RangeValues(0, 1000000);
                                _pendingOccasions.clear();
                              });
                              // Also apply immediately so grid resets
                              setState(() {
                                _appliedSort = SortOption.popular;
                                _appliedPriceRange = const RangeValues(0, 1000000);
                                _appliedOccasions.clear();
                              });
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("Reset", style: TextStyle(color: Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply pending state to active filters
                              setState(() {
                                _appliedSort = _pendingSort;
                                _appliedPriceRange = _pendingPriceRange;
                                _appliedOccasions = Set.from(_pendingOccasions);
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
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
      },
    );
  }

  String _sortLabel(SortOption opt) {
    switch (opt) {
      case SortOption.popular: return "Popular";
      case SortOption.newest: return "Newest";
      case SortOption.priceLow: return "Price: Low to High";
      case SortOption.priceHigh: return "Price: High to Low";
    }
  }

  Widget _modalChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryOrange : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const LenisScrollBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // ── HEADER ──────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── SEARCH BAR ──────────────────────────────
              SliverToBoxAdapter(child: _buildSearchBar()),

              // ── CATEGORIES ──────────────────────────────
              SliverToBoxAdapter(child: _buildCategoriesSlider()),

              // ── PRODUCT COUNT + ACTIVE FILTER BADGE ─────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filtered.length} items",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_hasActiveFilters)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _appliedSort = SortOption.popular;
                              _appliedPriceRange = const RangeValues(0, 1000000);
                              _appliedOccasions.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt, size: 14, color: AppColors.primaryOrange),
                                const SizedBox(width: 4),
                                Text(
                                  "Clear filters",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── PRODUCT GRID ─────────────────────────────
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No products found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your filters or search",
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 20),
                        if (_hasActiveFilters || _searchQuery.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _appliedSort = SortOption.popular;
                                _appliedPriceRange = const RangeValues(0, 1000000);
                                _appliedOccasions.clear();
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Clear all filters"),
                          ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: filtered[index]),
                      childCount: filtered.length,
                      addRepaintBoundaries: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Shop",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(height: 4),
              Text(
                "Find your perfect sparkle",
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jewelry...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                          child: const Icon(Icons.close, color: Colors.grey, size: 18),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              InkWell(
                onTap: () => _showFilterModal(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
              ),
              // Active filter indicator dot
              if (_hasActiveFilters)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategory == cat.title;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _selectCategory(cat.title),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryOrange : cat.color,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: AppColors.primaryOrange, width: 2)
                              : null,
                        ),
                        child: Icon(
                          cat.icon,
                          color: isSelected ? Colors.white : Colors.black87,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryOrange : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
