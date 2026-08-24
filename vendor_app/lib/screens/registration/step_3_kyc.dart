import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Step3Kyc extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String businessType;
  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final TextEditingController gstController;

  // File Uploads
  final XFile? idProofDoc;
  final Function(XFile?) onIdProofSelected;
  final XFile? businessCertDoc;
  final Function(XFile?) onBusinessCertSelected;
  final XFile? gstCertDoc;
  final Function(XFile?) onGstCertSelected;

  const Step3Kyc({
    super.key,
    required this.formKey,
    required this.businessType,
    required this.aadhaarController,
    required this.panController,
    required this.gstController,
    this.idProofDoc,
    required this.onIdProofSelected,
    this.businessCertDoc,
    required this.onBusinessCertSelected,
    this.gstCertDoc,
    required this.onGstCertSelected,
  });

  Future<void> _pickDocument(Function(XFile?) onSelected) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? doc = await picker.pickImage(source: ImageSource.gallery);
      if (doc != null) {
        onSelected(doc);
      }
    } catch (e) {
      debugPrint("Error picking document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isIndividual = businessType == "Individual";

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("KYC & Business Verification", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(
            isIndividual ? "For Individual Registration" : "For Business Registration ($businessType)", 
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)
          ),
          const SizedBox(height: 32),

          if (isIndividual) ...[
            _buildTextField("Aadhaar / Government ID *", "Enter 12-digit Aadhaar number", aadhaarController, Icons.badge_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildTextField("PAN Card Number *", "Enter 10-character PAN", panController, Icons.credit_card_outlined),
            const SizedBox(height: 24),
            _buildFileUploadBox("ID Proof Document Upload *", "Upload Aadhaar/PAN copy (PDF, JPG up to 5MB)", idProofDoc, () => _pickDocument(onIdProofSelected)),
          ] else ...[
            _buildTextField("Business PAN Card *", "Enter 10-character Business PAN", panController, Icons.credit_card_outlined),
            const SizedBox(height: 24),
            _buildTextField("GSTIN (If applicable)", "Enter 15-character GST Number", gstController, Icons.receipt_long_outlined),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildFileUploadBox("Business Registration Certificate *", "Upload Certificate (PDF, JPG up to 5MB)", businessCertDoc, () => _pickDocument(onBusinessCertSelected)),
                
                _buildFileUploadBox("GST Certificate Upload", "Upload GST Cert (PDF, JPG up to 5MB)", gstCertDoc, () => _pickDocument(onGstCertSelected)),
              ],
            )
          ],
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green),
                
                Expanded(
                  child: Text(
                    "Your information is securely encrypted and used only for verification purposes to ensure trust on JewelCraft.",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC09947))),
          ),
          validator: (value) {
            if (label.contains("*") && value!.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFileUploadBox(String title, String subtitle, XFile? file, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: file != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 32, color: Colors.green),
                        const SizedBox(height: 8),
                        Text("Selected", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green)),
                        Text(file.name, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 32, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text("Select Document", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFFC09947))),
                        Text(subtitle, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
