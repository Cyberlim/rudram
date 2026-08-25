import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String get displayName => _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;

  AppAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateEmailOTPRegistration(String email, String password, String name) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Generate a random 6-digit OTP
      final otp = (100000 + DateTime.now().microsecondsSinceEpoch % 900000).toString();
      
      if (kDebugMode) {
        print('=============================================');
        print('OTP VERIFICATION CODE GENERATED: $otp');
        print('=============================================');
      }
      
      // Save the OTP to Firestore (otp_verifications collection)
      await FirebaseFirestore.instance.collection('otp_verifications').doc(email.toLowerCase()).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send via EmailJS
      final serviceId = dotenv.env['EMAILJS_SERVICE_ID'];
      final templateId = dotenv.env['EMAILJS_TEMPLATE_ID'];
      final publicKey = dotenv.env['EMAILJS_PUBLIC_KEY'];
      
      if (serviceId != null && templateId != null && publicKey != null && serviceId.isNotEmpty) {
        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(
          url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': publicKey,
            'template_params': {
              'to_email': email,
              'to_name': name,
              'otp_code': otp,
              'otp': otp,
              'code': otp,
              'message': otp,
            }
          }),
        );
        
        if (response.statusCode != 200) {
          print('EmailJS Error: ${response.body}');
        }
      } else {
        print('EmailJS keys are missing from .env. The OTP was generated but no email was sent.');
      }

      _status = AuthStatus.initial; // reset so we don't stay loading
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to initiate OTP: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailOTPAndRegister(String email, String password, String name, String enteredOtp) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Check the OTP from Firestore
      final doc = await FirebaseFirestore.instance.collection('otp_verifications').doc(email.toLowerCase()).get();
      if (!doc.exists) {
        throw Exception("No OTP request found for this email.");
      }
      
      final storedOtp = doc.data()?['otp'];
      if (storedOtp != enteredOtp) {
        throw Exception("Invalid OTP code.");
      }

      // If OTP matches, create the user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      _user = _auth.currentUser;

      if (_user != null) {
        await FirestoreService().createUserProfile(
          uid: _user!.uid,
          email: _user!.email ?? email,
          name: name,
        );
      }

      // Clean up the OTP document
      await FirebaseFirestore.instance.collection('otp_verifications').doc(email.toLowerCase()).delete();

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      User? user;

      if (kIsWeb) {
        // Use Firebase Auth native popup for web (more reliable, doesn't need separate Client ID)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCred = await _auth.signInWithPopup(googleProvider);
        user = userCred.user;
      } else {
        // Use google_sign_in for native platforms
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: dotenv.env['FIREBASE_WEB_CLIENT_ID'],
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCred = await _auth.signInWithCredential(credential);
        user = userCred.user;
      }
      
      if (user != null) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await _auth.currentUser?.reload();
      _user = _auth.currentUser;
      if (_user != null) {
        await FirestoreService().updateUserProfile(uid: _user!.uid, name: name);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateExtendedProfile({String? phone, String? bio}) async {
    try {
      if (_user != null) {
        await FirestoreService().updateUserProfile(uid: _user!.uid, phone: phone, bio: bio);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfilePhoto(String photoUrl) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
      await _auth.currentUser?.reload();
      _user = _auth.currentUser;
      if (_user != null) {
        await FirestoreService().updateUserProfile(uid: _user!.uid, photoUrl: photoUrl);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      if (e.code == 'requires-recent-login') {
         _errorMessage = 'Please log out and log back in to delete your account.';
      } else {
         _errorMessage = _mapFirebaseError(e);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Error: ${e.code} - ${e.message}';
    }
  }
}
