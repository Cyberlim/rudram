import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesktopMarqueeSection extends StatefulWidget {
  const DesktopMarqueeSection({super.key});

  @override
  State<DesktopMarqueeSection> createState() => _DesktopMarqueeSectionState();
}

class _DesktopMarqueeSectionState extends State<DesktopMarqueeSection> {
  final ScrollController _horizontalController = ScrollController();
  ScrollPosition? _verticalPosition;

  // List of items to display in the marquee
  final List<String> _items = [
    "RUDRAM EXCLUSIVE",
    "•",
    "LIFETIME WARRANTY",
    "•",
    "PAN INDIA SHIPPING",
    "•",
    "100% HALLMARK GOLD",
    "•",
    "CERTIFIED DIAMONDS",
    "•",
    "SECURE PAYMENTS",
    "•",
    "BEST DESIGNS",
    "•",
    "CUSTOMIZATION AVAILABLE",
    "•",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _verticalPosition = Scrollable.of(context).position;
    _verticalPosition?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _removeListener();
    _horizontalController.dispose();
    super.dispose();
  }

  void _removeListener() {
    _verticalPosition?.removeListener(_onScroll);
  }

  void _onScroll() {
    if (_horizontalController.hasClients && _verticalPosition != null) {
      // Parallax effect: Horizontal scroll moves as vertical scroll moves
      // Speed factor: 1.5 horizontal pixels per 1 vertical pixel
      final double targetOffset = _verticalPosition!.pixels * 1.5;

      // We don't limit the maxScrollExtent to allow infinite-like feeling,
      // but ListView has limits. We use loop in builder to simulate infinite.
      // Jumping to offset allows seamless scrolling.
      _horizontalController.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200, // Increased height slightly
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF818CF8).withOpacity(0.08),
            const Color(0xFFC084FC).withOpacity(0.08),
            const Color(0xFF818CF8).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: const Color(0xFF818CF8).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: ListView.builder(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final text = _items[index % _items.length];
          return _buildMarqueeItem(text);
        },
      ),
    );
  }

  Widget _buildMarqueeItem(String text) {
    if (text == "•") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
            ).createShader(bounds),
            child: const Icon(Icons.star, size: 45, color: Colors.white),
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          text,
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF1E293B).withOpacity(0.8),
            fontSize: 100, // Large and premium
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
