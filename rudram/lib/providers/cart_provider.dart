import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.currentPrice * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: ProductItem.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
      );
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  static const String _storageKey = 'cart_items';
  String? _currentUid;
  StreamSubscription? _cartSub;

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.18; // 18% GST

  double get shipping => subtotal > 500 ? 0 : 50;

  double get total => subtotal + tax + shipping;

  CartProvider() {
    _loadCart();
  }

  void updateUid(String? uid) {
    if (_currentUid != uid) {
      _currentUid = uid;
      _loadCart();
    }
  }

  // ──────────────────────────────────────────────
  // Persistence: load from SharedPreferences or Firestore
  // ──────────────────────────────────────────────
  Future<void> _loadCart() async {
    try {
      _cartSub?.cancel(); // Cancel any existing subscription
      
      if (_currentUid != null) {
        // Listen to Firestore for real-time updates
        _cartSub = FirestoreService().streamCart(_currentUid!).listen((cloudItems) {
          _items.clear();
          _items.addAll(cloudItems);
          notifyListeners();
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String? json = prefs.getString(_storageKey);
        if (json != null) {
          final List<dynamic> decoded = jsonDecode(json);
          _items.clear();
          _items.addAll(decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)));
          notifyListeners();
        }
      }
    } catch (_) {
      // Ignore parse errors on corrupt data
    }
  }

  // Persist cart to SharedPreferences or Firestore
  Future<void> _saveCart() async {
    try {
      if (_currentUid != null) {
        await FirestoreService().saveCart(_currentUid!, _items);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final json = jsonEncode(_items.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, json);
      }
    } catch (_) {}
  }

  // ──────────────────────────────────────────────
  // Cart operations
  // ──────────────────────────────────────────────
  // Helper to match products (handles dummy data where id might be empty)
  bool _isSameProduct(ProductItem p1, ProductItem p2) {
    if (p1.id.isNotEmpty && p2.id.isNotEmpty) {
      return p1.id == p2.id;
    }
    return p1.title == p2.title;
  }

  void addItem(ProductItem product) {
    final existingIndex = _items.indexWhere(
      (item) => _isSameProduct(item.product, product),
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    _saveCart();
  }

  void removeItem(ProductItem product) {
    _items.removeWhere((item) => _isSameProduct(item.product, product));
    notifyListeners();
    _saveCart();
  }

  void updateQuantity(ProductItem product, int quantity) {
    final index = _items.indexWhere(
      (item) => _isSameProduct(item.product, product),
    );

    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
      _saveCart();
    }
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  bool isInCart(ProductItem product) {
    return _items.any((item) => _isSameProduct(item.product, product));
  }

  int getQuantity(ProductItem product) {
    final index = _items.indexWhere((item) => _isSameProduct(item.product, product));
    if (index >= 0) {
      return _items[index].quantity;
    }
    return 0;
  }
}
