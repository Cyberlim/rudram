import 'package:flutter/material.dart';

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop/Tablet: Use Row
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _addSpacing(children, spacing),
          );
        } else {
          // Mobile: Use Column
          // Automatically unwrap Expanded/Flexible to prevent layout errors inside a scrollable Column
          final columnChildren = children.map((child) {
            if (child is Expanded) return child.child;
            if (child is Flexible) return child.child;
            return child;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _addSpacing(columnChildren, runSpacing, isVertical: true),
          );
        }
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double gap, {bool isVertical = false}) {
    if (widgets.isEmpty) return [];
    List<Widget> result = [];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(isVertical ? SizedBox(height: gap) : Expanded(child: SizedBox(width: gap, child: Container()))); // We just use normal SizedBox since we already might have Expanded children.
        // Wait, if we use SizedBox inside a Row with Expanded children, it works fine.
      }
    }
    
    // Actually, spacing between Expanded widgets should just be a fixed SizedBox
    List<Widget> safeResult = [];
    for (int i = 0; i < widgets.length; i++) {
      safeResult.add(widgets[i]);
      if (i < widgets.length - 1) {
        safeResult.add(isVertical ? SizedBox(height: gap) : SizedBox(width: gap));
      }
    }
    return safeResult;
  }
}
