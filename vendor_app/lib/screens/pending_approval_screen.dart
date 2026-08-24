import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond_outlined, color: Color(0xFFC09947), size: 32),
                  const SizedBox(width: 12),
                  Text(
                    "JewelCraft",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A1C40),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 56),

              // Animated Status Card
              Container(
                width: 480,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Clock Icon with circular progress indicator style
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: null,
                            strokeWidth: 4,
                            color: const Color(0xFFC09947).withOpacity(0.3),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC09947).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.hourglass_top_rounded, size: 40, color: Color(0xFFC09947)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Application Under Review",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Thank you for registering as a vendor! Our team is reviewing your application and documents. You will be notified once approved.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Status Steps
                    _buildStep(Icons.check_circle, "Application Submitted", "Your details have been received", true),
                    _buildStepConnector(),
                    _buildStep(Icons.manage_search, "Under Review", "Admin is reviewing your documents", true, isActive: true),
                    _buildStepConnector(),
                    _buildStep(Icons.verified_outlined, "Approval Decision", "You'll be notified via email", false),
                    _buildStepConnector(),
                    _buildStep(Icons.store, "Start Selling", "Dashboard access granted", false),

                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Typical review time: 1–2 business days.",
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text("Sign Out"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String subtitle, bool isDone, {bool isActive = false}) {
    Color iconColor = isDone ? Colors.green : (isActive ? const Color(0xFFC09947) : Colors.grey.shade300);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: isDone || isActive ? const Color(0xFF1E293B) : Colors.grey)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        if (isDone && !isActive)
          const Icon(Icons.check, color: Colors.green, size: 16),
        if (isActive)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC09947)),
          ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 19, top: 4, bottom: 4),
      child: Container(width: 2, height: 24, color: Colors.grey.shade200),
    );
  }
}
