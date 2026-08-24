import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';
class OrderProduct {
  final String title;
  final String image;
  final double price;
  final int quantity;
  final double totalPrice;

  OrderProduct({
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'price': price,
        'quantity': quantity,
        'totalPrice': totalPrice,
      };

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
        title: json['title'],
        image: json['image'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}

class OrderItem {
  final String id;
  final String orderNumber;
  final String date;
  String status;
  final List<OrderProduct> items;
  final double totalAmount;
  final String paymentMethod;
  final Map<String, dynamic> deliveryDetails;

  OrderItem({
    this.id = '',
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.totalAmount,
    this.paymentMethod = 'COD',
    this.deliveryDetails = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'date': date,
        'status': status,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'deliveryDetails': deliveryDetails,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] ?? '',
        orderNumber: json['orderNumber'],
        date: json['date'],
        status: json['status'],
        items: (json['items'] as List)
            .map((item) => OrderProduct.fromJson(item))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] ?? 'COD',
        deliveryDetails: json['deliveryDetails'] ?? {},
      );

  factory OrderItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderItem(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      date: data['date'] ?? '',
      status: data['status'] ?? 'Processing',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'COD',
      deliveryDetails: data['deliveryDetails'] ?? {},
    );
  }
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  static const String _storageKey = 'orders';
  String? _currentUid;
  StreamSubscription? _ordersSub;

  List<OrderItem> get orders => _orders;

  OrdersProvider() {
    loadOrders();
  }

  void updateUid(String? uid) {
    if (_currentUid != uid) {
      _currentUid = uid;
      loadOrders();
    }
  }

  Future<void> loadOrders() async {
    _ordersSub?.cancel(); // Cancel any existing subscription to prevent leaks

    if (_currentUid != null) {
      // Sync from Firestore if authenticated
      _ordersSub = FirestoreService().getUserOrders(_currentUid!).listen((orders) {
        _orders = orders.map((o) => OrderItem(
          id: o.id,
          orderNumber: o.orderNumber,
          date: o.date,
          status: o.status,
          items: o.items.map((i) => OrderProduct(
            title: i.title,
            image: i.image,
            price: i.price,
            quantity: i.quantity,
            totalPrice: i.totalPrice,
          )).toList(),
          totalAmount: o.totalAmount,
          paymentMethod: o.paymentMethod,
          deliveryDetails: o.deliveryDetails,
        )).toList();
        notifyListeners();
      });
    } else {
      // Fallback to local storage for guests
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString(_storageKey);

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        _orders = decoded.map((item) => OrderItem.fromJson(item)).toList();
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> addOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    String paymentMethod = 'COD',
    Map<String, dynamic> deliveryDetails = const {},
  }) async {
    final orderNumber = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final date = DateTime.now().toString().split(' ')[0];

    final List<OrderProduct> orderProducts = cartItems.map((item) {
      return OrderProduct(
        title: item.product.title,
        image: item.product.image,
        price: item.product.currentPrice,
        quantity: item.quantity,
        totalPrice: item.totalPrice,
      );
    }).toList();

    final newOrder = OrderItem(
      orderNumber: orderNumber,
      date: date,
      status: 'Processing',
      items: orderProducts,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      deliveryDetails: deliveryDetails,
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    if (_currentUid != null) {
      // Create in Firestore
      await FirestoreService().createOrder(
        uid: _currentUid!,
        cartItems: cartItems,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        deliveryDetails: deliveryDetails,
      );
    } else {
      // Save locally
      await _saveOrders();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      _orders.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> updateOrderStatus(String orderNumber, String newStatus) async {
    final index = _orders.indexWhere(
      (order) => order.orderNumber == orderNumber,
    );
    if (index != -1) {
      _orders[index].status = newStatus;
      await _saveOrders();
      notifyListeners();
    }
  }

  Future<void> clearOrders() async {
    _orders = [];
    await _saveOrders();
    notifyListeners();
  }

  // Merge Firestore orders with local orders (called after sign-in)
  void mergeFirestoreOrders(List<OrderItem> firestoreOrders) {
    final localNums = _orders.map((o) => o.orderNumber).toSet();
    for (final order in firestoreOrders) {
      if (!localNums.contains(order.orderNumber)) {
        _orders.add(order);
      }
    }
    _orders.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }
}
