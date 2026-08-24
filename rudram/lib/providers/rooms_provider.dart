import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/data_models.dart';

class RoomsProvider with ChangeNotifier {
  // Admin-seeded rooms (from 'rooms' collection)
  List<Room> _adminRooms = [];
  // User-created rooms (from 'user_rooms' collection)
  List<Room> _userRooms = [];
  bool _isLoading = true;

  List<Room> get rooms => [..._adminRooms];
  List<Room> get userRooms => [..._userRooms];
  // Combined for the UI: admin rooms first, then user's own rooms
  List<Room> get allRooms => [..._adminRooms, ..._userRooms];
  bool get isLoading => _isLoading;

  RoomsProvider() {
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // 1. Fetch admin-seeded rooms
      final adminSnap = await FirebaseFirestore.instance
          .collection('rooms')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      _adminRooms = adminSnap.docs.map((doc) {
        final data = doc.data();
        return Room(
          id: doc.id,
          name: data['name'] ?? '',
          image: data['image'] ?? '',
        );
      }).toList();

      // 2. Fetch user-created rooms (only if logged in)
      if (currentUser != null) {
        final userSnap = await FirebaseFirestore.instance
            .collection('user_rooms')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        _userRooms = userSnap.docs.map((doc) {
          final data = doc.data();
          return Room(
            id: doc.id,
            name: data['name'] ?? '',
            image: data['image'] ?? '',
            userId: data['userId'],
            userName: data['userName'],
            userEmail: data['userEmail'],
          );
        }).toList();
      } else {
        _userRooms = [];
      }
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called when user creates their own room from the web app
  Future<void> addRoom(String name, String image) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final newRoom = Room(
      id: DateTime.now().toString(),
      name: name,
      image: image,
      userId: currentUser?.uid,
      userName: currentUser?.displayName,
      userEmail: currentUser?.email,
      createdAt: DateTime.now(),
    );
    _userRooms.add(newRoom);
    notifyListeners();

    // Save to 'user_rooms' Firestore collection (separate from admin rooms)
    try {
      final docRef = await FirebaseFirestore.instance.collection('user_rooms').add({
        'name': name,
        'image': image,
        'userId': currentUser?.uid ?? 'anonymous',
        'userName': currentUser?.displayName ?? 'Guest',
        'userEmail': currentUser?.email ?? '',
        'userPhotoUrl': currentUser?.photoURL ?? '',
        'productCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the in-memory room with the real Firestore ID
      final idx = _userRooms.indexWhere((r) => r.id == newRoom.id);
      if (idx >= 0) {
        _userRooms[idx] = Room(
          id: docRef.id,
          name: name,
          image: image,
          userId: currentUser?.uid,
          userName: currentUser?.displayName,
          userEmail: currentUser?.email,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error saving user room: $e');
    }
  }

  void addProductToRoom(String roomId, ProductItem product) {
    // Check user_rooms first
    int roomIndex = _userRooms.indexWhere((r) => r.id == roomId);
    if (roomIndex >= 0) {
      final room = _userRooms[roomIndex];
      final updatedProducts = [...room.products, product];
      _userRooms[roomIndex] = Room(
        id: room.id,
        name: room.name,
        image: room.image,
        products: updatedProducts,
        userId: room.userId,
        userName: room.userName,
        userEmail: room.userEmail,
      );
      notifyListeners();
      return;
    }
    // Fallback to admin rooms
    roomIndex = _adminRooms.indexWhere((r) => r.id == roomId);
    if (roomIndex >= 0) {
      final room = _adminRooms[roomIndex];
      final updatedProducts = [...room.products, product];
      _adminRooms[roomIndex] = Room(
        id: room.id,
        name: room.name,
        image: room.image,
        products: updatedProducts,
      );
      notifyListeners();
    }
  }
}
