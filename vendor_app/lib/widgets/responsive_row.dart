import 'package:flutter/material.dart';

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // If the screen width is less than 768px, treat it as mobile/tablet and stack vertically.
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          final bool isLast = child == children.last;
          
          // Unwrap Expanded/Flexible if present to avoid layout errors in Column
          Widget realChild = child;
          if (child is Expanded) {
            realChild = child.child;
          } else if (child is Flexible) {
            realChild = child.child;
          }
          
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
            child: SizedBox(
              width: double.infinity,
              child: realChild,
            ),
          );
        }).toList(),
      );
    }

    // On Desktop, display in a row with Expanded to share width evenly
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) {
        final bool isLast = child == children.last;
        
        // If it's already Expanded/Flexible, don't wrap it again
        if (child is Expanded || child is Flexible) {
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: child,
          );
        }
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: child,
          ),
        );
      }).toList(),
    );
  }
}
