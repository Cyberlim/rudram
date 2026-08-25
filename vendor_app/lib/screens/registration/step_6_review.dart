import '../../widgets/responsive_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Step6Review extends StatelessWidget {
  final String fullName;
  final String email;
  final String mobile;
  final String storeName;
  final String businessType;
  final String address;
  final bool termsAccepted;
  final Function(bool?) onTermsChanged;

  const Step6Review({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.storeName,
    required this.businessType,
    required this.address,
    required this.termsAccepted,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Review & Submit", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Text("Please review your information before final submission.", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 32),

        _buildSectionTitle("Account Information"),
        _buildReviewRow("Full Name", fullName.isEmpty ? "Not provided" : fullName),
        _buildReviewRow("Email Address", email.isEmpty ? "Not provided" : email),
        _buildReviewRow("Mobile Number", mobile.isEmpty ? "Not provided" : mobile),
        const SizedBox(height: 24),

        _buildSectionTitle("Business Information"),
        _buildReviewRow("Store Name", storeName.isEmpty ? "Not provided" : storeName),
        _buildReviewRow("Business Type", businessType),
        _buildReviewRow("Business Address", address.isEmpty ? "Not provided" : address),
        const SizedBox(height: 24),

        _buildSectionTitle("Verification & Bank"),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text("KYC Documents Uploaded", style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text("Bank Details Provided", style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: ResponsiveRow(
            children: [
              Checkbox(
                value: termsAccepted,
                onChanged: onTermsChanged,
                activeColor: const Color(0xFFC09947),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "I confirm that all information provided is accurate and authentic. I agree to JewelCraft's Vendor Terms of Service and Privacy Policy.",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ResponsiveRow(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
