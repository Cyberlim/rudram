import 'package:flutter/material.dart';
import 'shop_mega_menu.dart';

class DesktopNavBar extends StatefulWidget {
  const DesktopNavBar({super.key});

  @override
  State<DesktopNavBar> createState() => _DesktopNavBarState();
}

class _DesktopNavBarState extends State<DesktopNavBar> {
  String? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // All Departments - Fixed
              Container(
                width: 260,
                height: 52, // Fixed height to align
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: const Color(0xFF3B82F6), // Accent color for departments
                child: Row(
                  children: [
                    Icon(Icons.menu, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All Departments',
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Nav Items
              Expanded(
                child: Row(
                  children: [
                    _buildNavItem('Home', isSelected: true, hasDropdown: true),
                    _buildNavItem('Shop', hasDropdown: true),
                    _buildNavItem('Cell Phones', icon: Icons.phone_android),
                    _buildNavItem('Headphones', icon: Icons.headphones),
                    _buildNavItem('Blog'),
                    _buildNavItem('Contact'),
                  ],
                ),
              ),

              // Right side offer
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "WEEKEND SALE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "UP TO 70% OFF",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dropdown Overlay with Animation
          if (_hoveredItem != null)
            Positioned(
              top: 52,
              left: _getDropdownLeftOffset(_hoveredItem!),
              child: MouseRegion(
                onEnter: (_) => setState(() {}), // Keep open
                onExit: (_) => setState(() => _hoveredItem = null),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_hoveredItem), // Animate when item changes
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuad,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - value)), // Slide down
                        child: child,
                      ),
                    );
                  },
                  child: _buildDropdownContent(_hoveredItem!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String title, {
    bool isSelected = false,
    bool hasDropdown = false,
    IconData? icon,
  }) {
    bool isHovered = _hoveredItem == title;

    return MouseRegion(
      onEnter: (_) {
        if (hasDropdown) {
          setState(() => _hoveredItem = title);
        }
      },
      // No onExit here - let the dropdown handle closing
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF3B82F6), width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isHovered || isSelected
                    ? Color(0xFF3B82F6)
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isHovered || isSelected
                    ? Color(0xFF3B82F6)
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            if (hasDropdown)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isHovered || isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getDropdownLeftOffset(String item) {
    // "All Departments" (260) + Gap (20) = 280 start of Nav Items
    // "Home" is ~90-100px width.
    // "Shop" starts after Home.

    if (item == 'Home') return 280;
    if (item == 'Shop') return 370; // 280 + ~90 for Home
    return 0;
  }

  Widget _buildDropdownContent(String item) {
    if (item == 'Shop') {
      return const ShopMegaMenu();
    }

    // Default small dropdown for others
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownItem('$item Option 1'),
          _buildDropdownItem('$item Option 2'),
          _buildDropdownItem('$item Option 3'),
          _buildDropdownItem('$item Option 4'),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String text) {
    return HoverableDropdownItem(text: text);
  }
}

class HoverableDropdownItem extends StatefulWidget {
  final String text;
  const HoverableDropdownItem({super.key, required this.text});

  @override
  State<HoverableDropdownItem> createState() => _HoverableDropdownItemState();
}

class _HoverableDropdownItemState extends State<HoverableDropdownItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: _isHovering ? Colors.grey.shade50 : Colors.transparent,
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isHovering ? Color(0xFF3B82F6) : Theme.of(context).colorScheme.onSurface,
            fontWeight: _isHovering ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
