import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AppAuthProvider>();
    final success = await auth.verifyEmailOTPAndRegister(
      widget.email,
      widget.password,
      widget.name,
      _otpController.text.trim(),
    );

    if (success && mounted) {
      // The auth status will automatically switch to authenticated and redirect to Home
      Navigator.of(context).popUntil((route) => route.isFirst); 
    } else if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F1E19)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 64, color: Color(0xFFC69C6D)),
                    const SizedBox(height: 24),
                    Text(
                      "Check Your Email",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F1E19),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We've sent a 6-digit verification code to\n${widget.email}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: GoogleFonts.inter(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "••••••",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFC69C6D), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length != 6) {
                          return "Please enter a 6-digit code";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Consumer<AppAuthProvider>(
                      builder: (context, auth, _) {
                        final isLoading = auth.status == AuthStatus.loading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF0F1E19),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    "Verify & Create Account",
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
