import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFF37A20);
  static const Color primaryOrangeLight = Color(0xFFFFAB73);
  static const Color primaryLight = Color(0xFFFFF3E0);

  static const Color background = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color searchBarBg = Color(0xFFF5F5F5);
  static const Color iconColor = Color(0xFF555555);

  static const Color badgeRed = Color(0xFFFF3D00);
  static const Color starYellow = Color(0xFFFFC107);

  static const Color categoryBg = Color(0xFFEFEFEF);

  // Banner Gradient
  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE0D1), Color(0xFFFFF0E5)],
  );
}
