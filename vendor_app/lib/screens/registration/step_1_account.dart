import '../../widgets/responsive_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Step1Account extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  
  // File Upload
  final XFile? profilePhoto;
  final Function(XFile?) onProfilePhotoSelected;

  const Step1Account({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.mobileController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.profilePhoto,
    required this.onProfilePhotoSelected,
  });

  @override
  State<Step1Account> createState() => _Step1AccountState();
}

class _Step1AccountState extends State<Step1Account> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onProfilePhotoSelected(image);
      }
    } catch (e) {
      debugPrint("Error picking profile photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Details", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text("Create your account to get started", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 32),

          ResponsiveRow(
            children: [
              _buildTextField("Full Name *", "Enter your full name", widget.fullNameController, Icons.person_outline),
              
              _buildTextField("Email Address *", "Enter your email address", widget.emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            ],
          ),
          const SizedBox(height: 24),
          
          ResponsiveRow(
            children: [
              Expanded(
                child: _buildTextField("Mobile Number *", "Enter mobile number", widget.mobileController, Icons.phone_outlined, keyboardType: TextInputType.phone, prefixText: "+91 "),
              ),
              
              Expanded(
                child: _buildPasswordField("Password *", "Create a strong password", widget.passwordController, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          ResponsiveRow(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildPasswordField("Confirm Password *", "Confirm your password", widget.confirmPasswordController, _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                    const SizedBox(height: 16),
                    _buildPasswordStrengthBox(),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Profile Photo (Optional)", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: widget.profilePhoto != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, size: 32, color: Colors.green),
                                    const SizedBox(height: 8),
                                    Text("Selected", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green)),
                                    Text(widget.profilePhoto!.name, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text("Upload Photo", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text("JPG, PNG up to 2MB", style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, String? prefixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            prefixText: prefixText,
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC09947))), // Gold focus
          ),
          validator: (value) => value!.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscureText, VoidCallback toggleObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
              onPressed: toggleObscure,
            ),
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
            if (value!.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Minimum 8 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light green tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Password must contain:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildCheckItem("At least 8 characters"),
              _buildCheckItem("One number"),
              _buildCheckItem("One uppercase letter"),
              _buildCheckItem("One special character"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(color: Colors.green.shade700, fontSize: 12)),
      ],
    );
  }
}
