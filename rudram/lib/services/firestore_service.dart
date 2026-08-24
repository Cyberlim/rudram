import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../models/wallet_transaction_model.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // USERS
  // ──────────────────────────────────────────────

  /// Creates a user profile if one doesn't exist
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': uid,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Updates an existing user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? phone,
    String? bio,
    bool? pushNotifications,
    bool? emailPromotions,
    String? language,
    bool? luxuryEmailOffers,
    bool? luxurySmsUpdates,
    bool? luxuryConciergeAlerts,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (pushNotifications != null) data['pushNotifications'] = pushNotifications;
    if (emailPromotions != null) data['emailPromotions'] = emailPromotions;
    if (language != null) data['language'] = language;
    if (luxuryEmailOffers != null) data['luxuryEmailOffers'] = luxuryEmailOffers;
    if (luxurySmsUpdates != null) data['luxurySmsUpdates'] = luxurySmsUpdates;
    if (luxuryConciergeAlerts != null) data['luxuryConciergeAlerts'] = luxuryConciergeAlerts;
    
    if (data.isNotEmpty) {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // ──────────────────────────────────────────────
  // ADDRESSES
  // ──────────────────────────────────────────────

  /// Stream of user addresses
  Stream<List<Map<String, dynamic>>> getUserAddresses(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Add a new address
  Future<void> addAddress(String uid, Map<String, dynamic> address) async {
    final addressesRef = _db.collection('users').doc(uid).collection('addresses');
    
    if (address['isDefault'] == true) {
      // Unset any existing default addresses
      final currentDefaults = await addressesRef.where('isDefault', isEqualTo: true).get();
      final batch = _db.batch();
      for (var doc in currentDefaults.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }
    
    await addressesRef.add(address);
  }

  /// Update an existing address
  Future<void> updateAddress(String uid, String addressId, Map<String, dynamic> address) async {
    final addressesRef = _db.collection('users').doc(uid).collection('addresses');
    
    if (address['isDefault'] == true) {
      // Unset any existing default addresses
      final currentDefaults = await addressesRef.where('isDefault', isEqualTo: true).get();
      final batch = _db.batch();
      for (var doc in currentDefaults.docs) {
        if (doc.id != addressId) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
      await batch.commit();
    }
    
    await addressesRef.doc(addressId).update(address);
  }

  /// Remove an address
  Future<void> removeAddress(String uid, String addressId) async {
    await _db.collection('users').doc(uid).collection('addresses').doc(addressId).delete();
  }

  /// Set an address as default
  Future<void> setDefaultAddress(String uid, String addressId) async {
    final addressesRef = _db.collection('users').doc(uid).collection('addresses');
    
    // Unset all first
    final allAddresses = await addressesRef.get();
    final batch = _db.batch();
    for (var doc in allAddresses.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // PAYMENT METHODS
  // ──────────────────────────────────────────────

  /// Stream of user payment methods
  Stream<List<Map<String, dynamic>>> getUserPaymentMethods(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Add a new payment method
  Future<void> addPaymentMethod(String uid, Map<String, dynamic> method) async {
    final methodsRef = _db.collection('users').doc(uid).collection('payment_methods');
    
    if (method['isDefault'] == true) {
      final currentDefaults = await methodsRef.where('isDefault', isEqualTo: true).get();
      final batch = _db.batch();
      for (var doc in currentDefaults.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }
    
    await methodsRef.add(method);
  }

  /// Remove a payment method
  Future<void> removePaymentMethod(String uid, String methodId) async {
    await _db.collection('users').doc(uid).collection('payment_methods').doc(methodId).delete();
  }

  /// Set a payment method as default
  Future<void> setDefaultPaymentMethod(String uid, String methodId) async {
    final methodsRef = _db.collection('users').doc(uid).collection('payment_methods');
    
    final allMethods = await methodsRef.get();
    final batch = _db.batch();
    for (var doc in allMethods.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == methodId});
    }
    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // PRODUCTS
  // ──────────────────────────────────────────────

  /// Stream of all products, optionally filtered by category.
  Stream<List<ProductItem>> getProducts({String? category}) {
    Query<Map<String, dynamic>> query = _db.collection('products');
    if (category != null && category.isNotEmpty && category != 'All') {
      if (category == 'Electronic') {
        query = query.where(Filter.or(
          Filter('category', isEqualTo: 'Electronic'),
          Filter('mainCategory', isEqualTo: 'Electronic'),
          Filter('category', isEqualTo: 'Electronics'),
          Filter('mainCategory', isEqualTo: 'Electronics'),
        ));
      } else {
        query = query.where(Filter.or(
          Filter('category', isEqualTo: category),
          Filter('mainCategory', isEqualTo: category),
        ));
      }
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => ProductItem.fromFirestore(doc)).toList());
  }

  /// Fetch a single product by its Firestore document ID.
  Future<ProductItem?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return ProductItem.fromFirestore(doc);
  }

  // ──────────────────────────────────────────────
  // ORDERS
  // ──────────────────────────────────────────────

  /// Stream of orders for the authenticated user, newest first.
  Stream<List<OrderItem>> getUserOrders(String uid) {
    return _db
        .collection('orders')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final orders = snap.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
      // Sort in Dart to avoid requiring a composite index in Firestore
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    });
  }

  /// Creates a new order document for the given user.
  Future<String> createOrder({
    required String uid,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
  }) async {
    final orderProducts = cartItems
        .map((item) => {
              'title': item.product.title,
              'image': item.product.image,
              'price': item.product.currentPrice,
              'quantity': item.quantity,
              'totalPrice': item.totalPrice,
            })
        .toList();

    final orderNumber = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);

    final docRef = await _db.collection('orders').add({
      'uid': uid,
      'orderNumber': orderNumber,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'Processing',
      'items': orderProducts,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'deliveryDetails': deliveryDetails,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Trigger Notification for Admin
    await createNotification(
      userId: 'admin',
      title: 'New Order Received',
      message: 'Order #$orderNumber has been placed for ₹$totalAmount.',
      type: 'order',
      data: {'orderId': docRef.id},
    );

    // Trigger Notification for Vendor
    await createNotification(
      userId: 'vendor123',
      title: 'New Order Received',
      message: 'Order #$orderNumber has been placed for ₹$totalAmount.',
      type: 'order',
      data: {'orderId': docRef.id},
    );

    // Get user details to notify user
    final userDoc = await _db.collection('users').doc(uid).get();
    final userName = userDoc.exists ? (userDoc.data()?['name'] ?? 'Customer') : 'Customer';

    // Trigger Notification for User (Confirmation)
    await createNotification(
      userId: uid,
      title: 'Order Confirmed!',
      message: 'Thank you $userName. Your order #$orderNumber is currently processing.',
      type: 'order',
      data: {'orderId': docRef.id},
    );

    return docRef.id;
  }

  /// Updates the status field on an order document.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});

    // Get order details to notify user
    final orderDoc = await _db.collection('orders').doc(orderId).get();
    if (orderDoc.exists) {
      final uid = orderDoc.data()?['uid'];
      final orderNumber = orderDoc.data()?['orderNumber'];
      if (uid != null && orderNumber != null) {
        await createNotification(
          userId: uid,
          title: 'Order Status Updated',
          message: 'Your order #$orderNumber is now $newStatus.',
          type: 'order',
          data: {'orderId': orderId},
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  // CART SYNC (per-user cloud cart)
  // ──────────────────────────────────────────────

  /// Persists the user's cart items to Firestore.
  Future<void> saveCart(String uid, List<CartItem> items) async {
    final cartData = items
        .map((item) => {
              'productId': item.product.id,
              'title': item.product.title,
              'currentPrice': item.product.currentPrice,
              'oldPrice': item.product.oldPrice,
              'discount': item.product.discount,
              'image': item.product.image,
              'category': item.product.category,
              'quantity': item.quantity,
            })
        .toList();

    await _db.collection('users').doc(uid).set(
      {'cart': cartData},
      SetOptions(merge: true),
    );
  }

  /// Loads the user's cart from Firestore.
  Future<List<CartItem>> loadCart(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return [];

    final data = doc.data();
    if (data == null || !data.containsKey('cart')) return [];

    final cartList = data['cart'] as List<dynamic>;
    return cartList.map((item) {
      final product = ProductItem(
        id: item['productId'] ?? '',
        title: item['title'],
        currentPrice: (item['currentPrice'] as num).toDouble(),
        oldPrice: (item['oldPrice'] as num).toDouble(),
        discount: item['discount'],
        image: item['image'],
        category: item['category'] ?? '',
      );
      return CartItem(product: product, quantity: item['quantity'] as int);
    }).toList();
  }

  /// Streams the user's cart from Firestore for real-time syncing.
  Stream<List<CartItem>> streamCart(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null || !data.containsKey('cart')) return [];

      final cartList = data['cart'] as List<dynamic>;
      return cartList.map((item) {
        final product = ProductItem(
          id: item['productId'] ?? '',
          title: item['title'],
          currentPrice: (item['currentPrice'] as num).toDouble(),
          oldPrice: (item['oldPrice'] as num).toDouble(),
          discount: item['discount'],
          image: item['image'],
          category: item['category'] ?? '',
        );
        return CartItem(product: product, quantity: item['quantity']);
      }).toList();
    });
  }

  // ──────────────────────────────────────────────
  // WISHLIST SYNC
  // ──────────────────────────────────────────────

  /// Persists the user's wishlist items to Firestore.
  Future<void> saveWishlist(String uid, List<ProductItem> items) async {
    final wishlistData = items
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'currentPrice': item.currentPrice,
              'oldPrice': item.oldPrice,
              'discount': item.discount,
              'image': item.image,
              'category': item.category,
            })
        .toList();

    await _db.collection('users').doc(uid).set(
      {'wishlist': wishlistData},
      SetOptions(merge: true),
    );
  }

  /// Loads the user's wishlist from Firestore.
  Future<List<ProductItem>> loadWishlist(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return [];

    final data = doc.data();
    if (data == null || !data.containsKey('wishlist')) return [];

    final wishlistList = data['wishlist'] as List<dynamic>;
    return wishlistList.map((item) {
      return ProductItem(
        id: item['id'] ?? '',
        title: item['title'],
        currentPrice: (item['currentPrice'] as num).toDouble(),
        oldPrice: (item['oldPrice'] as num).toDouble(),
        discount: item['discount'],
        image: item['image'],
        category: item['category'] ?? '',
      );
    }).toList();
  }

  // ──────────────────────────────────────────────
  // MARKETING (Banners & Celebrity Styles)
  // ──────────────────────────────────────────────

  /// Stream of active banners
  Stream<List<Map<String, dynamic>>> getActiveBanners() {
    return _db
      .collection('banners')
      .where('status', isEqualTo: 'Active')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList());
  }

  /// Streams all categories
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _db
        .collection('categories')
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Streams active Celebrity Styles
  Stream<List<Map<String, dynamic>>> getActiveCelebrityStyles() {
    return _db
        .collection('celebrityStyles')
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Streams products linked to a particular celebrity style
  Stream<List<ProductItem>> getProductsByStyleId(String styleId) {
    return _db
        .collection('celebrityStyles')
        .doc(styleId)
        .snapshots()
        .asyncMap((styleDoc) async {
      if (!styleDoc.exists) return <ProductItem>[];
      final data = styleDoc.data() as Map<String, dynamic>;
      final productIds = List<String>.from(data['productIds'] ?? []);
      if (productIds.isEmpty) return <ProductItem>[];

      final List<ProductItem> items = [];
      for (final pid in productIds) {
        final doc = await _db.collection('products').doc(pid).get();
        if (doc.exists) {
          final d = doc.data() as Map<String, dynamic>;
          items.add(ProductItem(
            id: doc.id,
            title: d['title'] ?? '',
            currentPrice: (d['currentPrice'] ?? 0).toDouble(),
            oldPrice: (d['oldPrice'] ?? 0).toDouble(),
            discount: d['discount'] ?? '',
            image: d['image'] ?? '',
            bgColor: const Color(0xFFFFF8DC),
          ));
        }
      }
      return items;
    });
  }

  /// Streams active Reels
  Stream<List<Map<String, dynamic>>> getActiveReels() {
    return _db
      .collection('reels')
      .where('status', isEqualTo: 'Active')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList());
  }

  // ──────────────────────────────────────────────
  // SEEDING (dev tool — call once)
  // ──────────────────────────────────────────────

  /// Seeds the hardcoded product list into Firestore once.
  Future<void> seedProducts() async {
    final batch = _db.batch();
    final col = _db.collection('products');

    for (final product in globalShopProducts) {
      final docRef = product.id.isNotEmpty ? col.doc(product.id) : col.doc();
      batch.set(docRef, {
        'title': product.title,
        'currentPrice': product.currentPrice,
        'oldPrice': product.oldPrice,
        'discount': product.discount,
        'image': product.image,
        'category': product.category,
        'bgColor': product.bgColor.value,
      });
    }

    await batch.commit();
  }

  /// Seeds the original banners and celebrity styles into Firestore
  Future<void> seedBannersAndStyles() async {
    final batch = _db.batch();

    // 1. Seed Banners
    final bannersCol = _db.collection('banners');
    final existingBanners = await bannersCol.limit(1).get();
    
    if (existingBanners.docs.isEmpty) {
      final bannersData = [
        {
          'title': 'Diwali Special',
          'imageUrl': 'assets/images/banner_1.jpg',
          'placement': 'Hero',
          'status': 'Active',
          'color1': '#FFE0D1',
          'color2': '#FFF0E5',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'New Arrivals',
          'imageUrl': 'assets/images/banner_2.jpg',
          'placement': 'Hero',
          'status': 'Active',
          'color1': '#E1D5F8',
          'color2': '#EEE5FF',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Wedding Collection',
          'imageUrl': 'assets/images/banner_3.jpg',
          'placement': 'Hero',
          'status': 'Active',
          'color1': '#FFE5E5',
          'color2': '#FFF5F5',
          'createdAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final b in bannersData) {
        batch.set(bannersCol.doc(), b);
      }
    }

    // 2. Seed Celebrity Styles
    final stylesCol = _db.collection('celebrityStyles');
    final existingStyles = await stylesCol.limit(1).get();

    if (existingStyles.docs.isEmpty) {
      final stylesData = [
        {
          'title': 'Red Carpet',
          'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Bollywood',
          'image': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=500',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Met Gala',
          'image': 'https://images.unsplash.com/photo-1546167889-0b4d5ff30be0?w=500',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Cannes',
          'image': 'https://images.unsplash.com/photo-1616091216791-a5360b5fc78a?w=500',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final s in stylesData) {
        batch.set(stylesCol.doc(), s);
      }
    }

    await batch.commit();
    print("Checked and seeded banners and styles if missing!");
  }

  // ──────────────────────────────────────────────
  // NOTIFICATIONS
  // ──────────────────────────────────────────────

  /// Get real-time stream of notifications for a specific user
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (data != null) 'data': data,
    });
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  /// Mark all notifications as read for a specific user
  Future<void> markAllNotificationsAsRead(String userId) async {
    final unreadDocs = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadDocs.docs.isNotEmpty) {
      final batch = _db.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  // ── WALLET METHODS ───────────────────────────────────────────

  Stream<Map<String, dynamic>> streamWalletBalances(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return {
          'walletBalance': 0.0,
          'cashbackBalance': 0.0,
          'rewardPoints': 0,
          'activeGiftVouchers': 0,
        };
      }
      final data = doc.data()!;
      return {
        'walletBalance': (data['walletBalance'] ?? 0.0).toDouble(),
        'cashbackBalance': (data['cashbackBalance'] ?? 0.0).toDouble(),
        'rewardPoints': (data['rewardPoints'] ?? 0).toInt(),
        'activeGiftVouchers': (data['activeGiftVouchers'] ?? 0).toInt(),
      };
    });
  }

  Stream<List<WalletTransaction>> streamWalletTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('wallet_transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WalletTransaction.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> processWalletTransaction({
    required String uid,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required String title,
  }) async {
    final batch = _db.batch();
    final userRef = _db.collection('users').doc(uid);
    
    // Update balance
    final balanceChange = type == TransactionType.credit ? amount : -amount;
    batch.set(userRef, {
      'walletBalance': FieldValue.increment(balanceChange),
    }, SetOptions(merge: true));

    // Add transaction record
    final txsRef = userRef.collection('wallet_transactions').doc();
    batch.set(txsRef, {
      'title': title,
      'date': FieldValue.serverTimestamp(),
      'amount': amount,
      'type': type.name,
      'category': category.name,
    });

    await batch.commit();
  }

  Future<void> seedDummyWalletData(String uid) async {
    final batch = _db.batch();
    
    final userRef = _db.collection('users').doc(uid);
    batch.set(userRef, {
      'walletBalance': 42500.0,
      'cashbackBalance': 2510.4,
      'rewardPoints': 5450,
      'activeGiftVouchers': 3,
    }, SetOptions(merge: true));

    final txsRef = userRef.collection('wallet_transactions');
    
    final tx1 = txsRef.doc();
    batch.set(tx1, {
      'title': 'Order #2938423',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      'amount': 8450.0,
      'type': 'debit',
      'category': 'order',
    });

    final tx2 = txsRef.doc();
    batch.set(tx2, {
      'title': 'Cashback Credited',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      'amount': 450.0,
      'type': 'credit',
      'category': 'cashback',
    });

    final tx3 = txsRef.doc();
    batch.set(tx3, {
      'title': 'Wallet Top-up',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 12))),
      'amount': 5000.0,
      'type': 'credit',
      'category': 'topup',
    });

    await batch.commit();
  }
}
