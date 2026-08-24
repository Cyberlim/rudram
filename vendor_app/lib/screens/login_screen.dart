import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration/vendor_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMsg = '';
  bool _obscureText = true;

  // Colors based on the new UI
  final Color darkGreen = const Color(0xFF0F3224);
  final Color primaryGreen = const Color(0xFF144A36);
  final Color lightGreen = const Color(0xFFEBF5F0);
  final Color goldAccent = const Color(0xFFD4AF37);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Main.dart stream builder will automatically navigate to VendorLayout
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMsg = e.message ?? "Authentication failed.";
      });
    } catch (e) {
      setState(() {
        _errorMsg = "An unexpected error occurred.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 5,
              child: _buildLeftPanel(),
            ),
          Expanded(
            flex: 6,
            child: _buildRightPanel(isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Stack(
        children: [
          // Optional: Add a subtle background image here if desired
          Positioned(
            right: -50,
            bottom: -50,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.diamond_outlined, size: 400, color: goldAccent),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Icon(Icons.diamond, color: goldAccent, size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JewelCraft",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                        Text(
                          "Timeless Beauty, Crafted for You",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Text(
                  "Empower Your",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Jewelry Business",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    color: goldAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Manage your store, products, orders,\ncustomers and earnings – all in one place.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                _buildFeatureItem(
                  icon: Icons.storefront,
                  title: "Complete Store Control",
                  subtitle: "Add products, manage inventory & track orders",
                ),
                _buildFeatureItem(
                  icon: Icons.bar_chart,
                  title: "Real-time Insights",
                  subtitle: "View sales, earnings and growth analytics anytime",
                ),
                _buildFeatureItem(
                  icon: Icons.security,
                  title: "Secure & Reliable",
                  subtitle: "Bank-level security to keep your data safe",
                ),
                _buildFeatureItem(
                  icon: Icons.headset_mic_outlined,
                  title: "Dedicated Support",
                  subtitle: "24/7 support to help you grow your business",
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: goldAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDesktop) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.storefront, size: 40, color: primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "Welcome to Vendor Portal",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Sign in to manage your jewelry store",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (_errorMsg.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMsg,
                                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Text("Email Address", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 20),
                        hintText: "Enter your email address",
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGreen)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          "Forgot Password?",
                          style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGreen)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Sign In to Dashboard", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR", style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: primaryGreen),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Secure Login",
                                  style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  "Your data is protected with 256-bit encryption",
                                  style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Choose Registration Type", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 24),
                                      ListTile(
                                        leading: Icon(Icons.storefront, color: primaryGreen),
                                        title: Text("Normal Vendor", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                        subtitle: Text("Standard store features and auto-approval.", style: GoogleFonts.inter(fontSize: 12)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorRegistrationScreen(initialVendorTier: "Normal")));
                                        },
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: Icon(Icons.star, color: goldAccent),
                                        title: Text("VIP Vendor", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: goldAccent)),
                                        subtitle: Text("Access to luxury catalog. Requires admin approval.", style: GoogleFonts.inter(fontSize: 12)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorRegistrationScreen(initialVendorTier: "VIP")));
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "Sign Up",
                                style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 14, color: primaryGreen),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterItem(Icons.verified_user_outlined, "Trusted by 5000+", "Vendors"),
                    const SizedBox(width: 40),
                    _buildFooterItem(Icons.lock_outline, "100% Secure", "Platform"),
                    const SizedBox(width: 40),
                    _buildFooterItem(Icons.trending_up, "Grow Your Business", "With JewelCraft"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: primaryGreen),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
