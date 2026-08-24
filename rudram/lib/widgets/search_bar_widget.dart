import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Find You needed...",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.textGrey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
