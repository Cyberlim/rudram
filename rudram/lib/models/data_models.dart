import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ──────────────────────────────────────────────
// Shared bubble data (used in profile + ai_stylist screens)
// ──────────────────────────────────────────────
class BubbleData {
  final double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  BubbleData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    this.opacity = 0.1,
  });
}

// ──────────────────────────────────────────────
// CategoryItem
// ──────────────────────────────────────────────
class CategoryItem {
  final String title;
  final IconData? icon;
  final String? imagePath;
  final Color color;

  const CategoryItem({
    required this.title,
    this.icon,
    this.imagePath,
    required this.color,
  });
}

// ──────────────────────────────────────────────
// ProductItem
// ──────────────────────────────────────────────
class ProductItem {
  final String id;
  final String title;
  final double currentPrice;
  final double oldPrice;
  final String discount;
  final String image; // URL or Asset path
  final Color bgColor;
  final String category;
  final List<String> images; // Array of image URLs

  const ProductItem({
    this.id = '',
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.discount,
    required this.image,
    this.images = const [],
    this.bgColor = const Color(0xFFEEEEEE),
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'currentPrice': currentPrice,
        'oldPrice': oldPrice,
        'discount': discount,
        'image': image,
        'images': images,
        'bgColor': bgColor.toARGB32(),
        'category': category,
      };

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
        oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0,
        discount: json['discount'] ?? '',
        image: json['image'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        bgColor: json['bgColor'] != null
            ? Color(json['bgColor'] as int)
            : const Color(0xFFEEEEEE),
        category: json['category'] ?? '',
      );

  factory ProductItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data() ?? {};
      return ProductItem(
        id: doc.id,
        title: data['title']?.toString() ?? 'Unnamed',
        currentPrice: (data['currentPrice'] as num?)?.toDouble() ?? 0.0,
        oldPrice: (data['oldPrice'] as num?)?.toDouble() ?? 0.0,
        discount: data['discount']?.toString() ?? '',
        image: data['image']?.toString() ?? '',
        images: List<String>.from(data['images'] ?? []),
        bgColor: _parseColor(data['bgColor']),
        category: data['category']?.toString() ?? 'All',
      );
    } catch (e) {
      return ProductItem(
        id: doc.id,
        title: 'Error Parsing Product: $e',
        currentPrice: 0,
        oldPrice: 0,
        discount: '',
        image: '',
        bgColor: Colors.red,
        category: 'All',
      );
    }
  }

  static Color _parseColor(dynamic colorVal) {
    if (colorVal == null) return const Color(0xFFEEEEEE);
    if (colorVal is int) return Color(colorVal);
    if (colorVal is String) {
      final parsed = int.tryParse(colorVal.replaceAll('#', '0xFF'));
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFFEEEEEE);
  }

  ProductItem copyWith({
    String? id,
    String? title,
    double? currentPrice,
    double? oldPrice,
    String? discount,
    String? image,
    Color? bgColor,
    String? category,
  }) =>
      ProductItem(
        id: id ?? this.id,
        title: title ?? this.title,
        currentPrice: currentPrice ?? this.currentPrice,
        oldPrice: oldPrice ?? this.oldPrice,
        discount: discount ?? this.discount,
        image: image ?? this.image,
        bgColor: bgColor ?? this.bgColor,
        category: category ?? this.category,
      );
}

// ──────────────────────────────────────────────
// Room
// ──────────────────────────────────────────────
class Room {
  final String id;
  final String name;
  final String image;
  final List<ProductItem> products;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final DateTime? createdAt;

  Room({
    required this.id,
    required this.name,
    required this.image,
    this.products = const [],
    this.userId,
    this.userName,
    this.userEmail,
    this.createdAt,
  });
}

// ──────────────────────────────────────────────
// Global seed data (also used by FirestoreService.seedProducts)
// ──────────────────────────────────────────────
final List<ProductItem> globalShopProducts = [
  const ProductItem(
    id: 'prod_001',
    title: "Royal Emerald Diamond Set",
    currentPrice: 85000.00,
    oldPrice: 125000.00,
    discount: "-32%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    category: "Sets",
  ),
  const ProductItem(
    id: 'prod_002',
    title: "Sapphire Drop Earrings",
    currentPrice: 42000.00,
    oldPrice: 55000.00,
    discount: "-25%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
    category: "Earrings",
  ),
  const ProductItem(
    id: 'prod_003',
    title: "Infinity Gold Bracelet",
    currentPrice: 35000.00,
    oldPrice: 45000.00,
    discount: "-22%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
    category: "Bracelets",
  ),
  const ProductItem(
    id: 'prod_004',
    title: "Classic Solitaire Ring",
    currentPrice: 95000.00,
    oldPrice: 110000.00,
    discount: "-15%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
    category: "Rings",
  ),
  const ProductItem(
    id: 'prod_005',
    title: "Rose Gold Pendant",
    currentPrice: 28000.00,
    oldPrice: 35000.00,
    discount: "-20%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
    category: "Necklaces",
  ),
  const ProductItem(
    id: 'prod_006',
    title: "Bridal Meenakari Set",
    currentPrice: 125000.00,
    oldPrice: 155000.00,
    discount: "-19%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/736x/54/26/f3/5426f37ee3738c45aa2e07091c6ea709.jpg",
    category: "Sets",
  ),
  const ProductItem(
    id: 'prod_007',
    title: "Diamond Stud Earrings",
    currentPrice: 15000.00,
    oldPrice: 25000.00,
    discount: "-40%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/a2/d1/53/a2d153c12d7c1216c406500543686ceb.jpg",
    category: "Earrings",
  ),
  const ProductItem(
    id: 'prod_008',
    title: "Gold Choker Necklace",
    currentPrice: 45000.00,
    oldPrice: 60000.00,
    discount: "-25%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/55/5f/81/555f8192d281f652159bbf59a2bb673c.jpg",
    category: "Necklaces",
  ),
  const ProductItem(
    id: 'prod_009',
    title: "Pearl Drop Necklace",
    currentPrice: 22000.00,
    oldPrice: 30000.00,
    discount: "-26%",
    image:
        "https://images.weserv.nl/?url=https://i.pinimg.com/736x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg",
    category: "Necklaces",
  ),
];
