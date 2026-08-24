import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'registration/vendor_registration_screen.dart';
import 'pending_approval_screen.dart';
import 'vendor_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 1. If not authenticated, show Login Screen
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        final User user = authSnapshot.data!;

        // 2. If authenticated, listen to Firestore for real-time status changes
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('vendors').doc(user.uid).snapshots(),
          builder: (context, docSnapshot) {
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // No document in Firestore — go to Registration
            if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
              return const VendorRegistrationScreen();
            }

            final rawData = docSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            final String status = rawData['status'] ?? 'pending';

            // Merge Firebase Auth info as fallback for any missing fields
            final vendorData = {
              'ownerName': user.displayName ?? user.email ?? 'Vendor',
              'email': user.email ?? '',
              'businessType': 'Vendor',
              'isKycVerified': false,
              'storeName': '',
              ...rawData, // rawData overrides defaults if fields exist
            };

            // Route based on approval status
            switch (status) {
              case 'approved':
                return VendorLayout(vendorData: vendorData);
              case 'rejected':
                return _RejectedScreen(user: user);
              case 'pending':
              default:
                return const PendingApprovalScreen();
            }
          },
        );
      },
    );
  }
}

class _RejectedScreen extends StatelessWidget {
  final User user;
  const _RejectedScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.cancel_outlined, size: 40, color: Colors.red.shade400),
              ),
              const SizedBox(height: 24),
              const Text("Application Rejected", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Text(
                "Unfortunately, your vendor application was not approved. Please contact support for more information.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
