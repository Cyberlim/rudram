import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';

class WishlistProvider with ChangeNotifier {
  final List<ProductItem> _items = [];
  static const String _storageKey = 'wishlist_items';
  String? _currentUid;

  List<ProductItem> get items => _items;

  WishlistProvider() {
    _loadWishlist();
  }

  void updateUid(String? uid) {
    if (_currentUid != uid) {
      _currentUid = uid;
      _loadWishlist();
    }
  }

  Future<void> _loadWishlist() async {
    try {
      if (_currentUid != null) {
        final cloudItems = await FirestoreService().loadWishlist(_currentUid!);
        _items.clear();
        _items.addAll(cloudItems);
        notifyListeners();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String? json = prefs.getString(_storageKey);
        if (json != null) {
          final List<dynamic> decoded = jsonDecode(json);
          _items.clear();
          _items.addAll(decoded.map((e) => ProductItem.fromJson(e as Map<String, dynamic>)));
          notifyListeners();
        }
      }
    } catch (_) {
      // Ignore parse errors on corrupt data
    }
  }

  Future<void> _saveWishlist() async {
    try {
      if (_currentUid != null) {
        await FirestoreService().saveWishlist(_currentUid!, _items);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final json = jsonEncode(_items.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, json);
      }
    } catch (_) {}
  }

  // Helper to match products (handles dummy data where id might be empty)
  bool _isSameProduct(ProductItem p1, ProductItem p2) {
    if (p1.id.isNotEmpty && p2.id.isNotEmpty) {
      return p1.id == p2.id;
    }
    return p1.title == p2.title;
  }

  void toggleWishlist(ProductItem product) {
    final existingIndex = _items.indexWhere((item) => _isSameProduct(item, product));
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(product);
    }
    notifyListeners();
    _saveWishlist();
  }

  void removeItem(ProductItem product) {
    _items.removeWhere((item) => _isSameProduct(item, product));
    notifyListeners();
    _saveWishlist();
  }

  bool isInWishlist(ProductItem product) {
    return _items.any((item) => _isSameProduct(item, product));
  }
}
