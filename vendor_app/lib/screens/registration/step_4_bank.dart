import '../../widgets/responsive_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Step4Bank extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController holderNameController;
  final TextEditingController accountNumberController;
  final TextEditingController ifscController;
  final TextEditingController bankNameController;
  
  // File Upload
  final XFile? bankProofDoc;
  final Function(XFile?) onBankProofSelected;

  const Step4Bank({
    super.key,
    required this.formKey,
    required this.holderNameController,
    required this.accountNumberController,
    required this.ifscController,
    required this.bankNameController,
    this.bankProofDoc,
    required this.onBankProofSelected,
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bank & Payout Details", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text("This is required so the platform can send vendor earnings.", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 32),

          ResponsiveRow(
            children: [
              _buildTextField("Account Holder Name *", "Name as per bank records", holderNameController, Icons.person_outline),
              
              _buildTextField("Bank Name *", "e.g. State Bank of India", bankNameController, Icons.account_balance_outlined),
            ],
          ),
          const SizedBox(height: 24),
          
          ResponsiveRow(
            children: [
              _buildTextField("Bank Account Number *", "Enter account number", accountNumberController, Icons.numbers_outlined, keyboardType: TextInputType.number),
              
              _buildTextField("IFSC Code *", "Enter 11-character IFSC", ifscController, Icons.account_balance_wallet_outlined, textCapitalization: TextCapitalization.characters),
            ],
          ),
          const SizedBox(height: 24),

          _buildFileUploadBox("Cancelled Cheque / Bank Proof Upload *", "Upload Cheque or Passbook front page (PDF, JPG up to 5MB)", bankProofDoc, () => _pickDocument(onBankProofSelected)),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                
                Expanded(
                  child: Text(
                    "Ensure the bank account is in the name of the registered business or proprietor to avoid payout delays.",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, TextCapitalization textCapitalization = TextCapitalization.none}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
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
          validator: (value) => value!.isEmpty ? 'This field is required' : null,
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
                        const Icon(Icons.account_balance, size: 32, color: Colors.grey),
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
