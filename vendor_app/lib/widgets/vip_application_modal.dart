import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VipApplicationModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const VipApplicationModal({super.key, required this.onSuccess});

  static void show(BuildContext context, {required VoidCallback onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VipApplicationModal(onSuccess: onSuccess),
    );
  }

  @override
  State<VipApplicationModal> createState() => _VipApplicationModalState();
}

class _VipApplicationModalState extends State<VipApplicationModal> {
  final _formKey = GlobalKey<FormState>();
  final _turnoverController = TextEditingController();
  final _experienceController = TextEditingController();
  final _reasonController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _turnoverController.dispose();
    _experienceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create VIP request object
        final vipDetails = {
          'annualTurnover': _turnoverController.text,
          'yearsOfExperience': _experienceController.text,
          'reason': _reasonController.text,
          'appliedAt': FieldValue.serverTimestamp(),
        };

        // Update vendor doc with pending status and details
        await FirebaseFirestore.instance.collection('vendors').doc(user.uid).update({
          'vipRequestStatus': 'pending',
          'vipDetails': vipDetails,
        });

        if (mounted) {
          Navigator.of(context).pop(); // Close modal
          widget.onSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC09947).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star, color: Color(0xFFC09947), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Become a VIP Vendor",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "VIP Vendors have exclusive access to list products in the Luxury Catalog. Please provide some details about your business to apply.",
                style: GoogleFonts.inter(color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              
              // Turnover
              Text("Annual Turnover (Approx)", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _turnoverController,
                decoration: _inputDecoration("e.g. ₹50 Lakhs"),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 16),

              // Experience
              Text("Years of Experience", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g. 5"),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 16),

              // Reason
              Text("Why do you want to list Luxury Products?", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: _inputDecoration("Briefly describe your luxury inventory..."),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC09947),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Submit Application", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFC09947))),
    );
  }
}
