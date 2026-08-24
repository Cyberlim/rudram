import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';
import '../luxury_home_content.dart'; // Just redirecting to home upon skip for now

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AppAuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _skip() {
    // Navigate to Home or Pop
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Light cream background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Decorative background shapes
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8DCC4).withOpacity(0.3),
            ),
          ),
        ),
        
        SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Skip", style: GoogleFonts.cormorantGaramond(color: const Color(0xFFC69C6D), fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, color: Color(0xFFC69C6D), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildLogoSection(),
                      const SizedBox(height: 40),
                      _buildTitleSection(),
                      const SizedBox(height: 40),
                      _buildFeaturesRow(),
                      const SizedBox(height: 40),
                      _buildGoogleButton(),
                      const SizedBox(height: 30),
                      _buildDivider(),
                      const SizedBox(height: 30),
                      _buildTerms(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom Section (Create Account)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Text("New to JewelCraft?", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _handleGoogleSignIn, // Both login and signup use google
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Create an account", style: GoogleFonts.inter(color: const Color(0xFFC69C6D), fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, color: Color(0xFFC69C6D), size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side - Image & Marketing
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF0F1E19), // Dark green background
            child: Stack(
              children: [
                // A decorative gradient instead of image since we don't have the asset
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0F1E19),
                        const Color(0xFF0F1E19).withOpacity(0.8),
                        const Color(0xFFC69C6D).withOpacity(0.2),
                      ]
                    )
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.diamond_outlined, color: Color(0xFFC69C6D), size: 40),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("JewelCraft", style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                  Text("TIMELESS BEAUTY, ALWAYS YOURS", style: GoogleFonts.inter(color: const Color(0xFFC69C6D), fontSize: 10, letterSpacing: 2)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 80),
                          Text("More Than\nJewelry,\nA Story Forever", style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 56, height: 1.1, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 24),
                          Text("Discover exquisite collections,\ncrafted with trust, elegance,\nand tradition.", style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.5)),
                          const SizedBox(height: 60),
                          _buildDesktopFeatureItem(Icons.diamond_outlined, "Authentic & Certified", "Hallmarked jewelry you can trust"),
                          const SizedBox(height: 24),
                          _buildDesktopFeatureItem(Icons.shopping_bag_outlined, "Secure Shopping", "Your safety, our priority"),
                          const SizedBox(height: 24),
                          _buildDesktopFeatureItem(Icons.favorite_border, "Exclusive Collections", "Designed for life's special moments"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Right Side - Auth Box
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFFFAF9F6),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  right: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.diamond_outlined, color: Color(0xFFC69C6D), size: 16),
                      const SizedBox(width: 8),
                      Text("Trusted by thousands\nof jewelry lovers", style: GoogleFonts.cormorantGaramond(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10)),
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 40),
                        Text("Welcome Back", style: GoogleFonts.cormorantGaramond(color: const Color(0xFF0F1E19), fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text("Sign in with your Google account\nto continue your journey with JewelCraft.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 15, height: 1.5)),
                        const SizedBox(height: 40),
                        _buildGoogleButton(),
                        const SizedBox(height: 24),
                        Text("Secure • Fast • Easy", style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12)),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniFeature(Icons.verified_user_outlined, "Your data\nis safe"),
                            _buildMiniFeature(Icons.bolt_outlined, "Quick\naccess"),
                            _buildMiniFeature(Icons.person_outline, "Personalized\nexperience"),
                            _buildMiniFeature(Icons.diamond_outlined, "Discover\nexclusive collections"),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildTerms(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC69C6D).withOpacity(0.5)),
          ),
          child: Icon(icon, color: const Color(0xFFC69C6D), size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildMiniFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC69C6D), size: 24),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 11, height: 1.3)),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        const Icon(Icons.diamond_outlined, color: Color(0xFFC69C6D), size: 48),
        const SizedBox(height: 12),
        Text("JewelCraft", style: GoogleFonts.cormorantGaramond(color: const Color(0xFF0F1E19), fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Timeless Beauty, Crafted for You", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 30, height: 1, color: const Color(0xFFC69C6D)),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC69C6D))),
            const SizedBox(width: 8),
            Container(width: 30, height: 1, color: const Color(0xFFC69C6D)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text("Welcome Back", style: GoogleFonts.cormorantGaramond(color: const Color(0xFF0F1E19), fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Sign in to continue your journey", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }

  Widget _buildFeaturesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureCol(Icons.verified_user_outlined, "Secure Shopping", "Safe & Trusted"),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildFeatureCol(Icons.diamond_outlined, "Certified Jewelry", "Hallmarked & Authentic"),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildFeatureCol(Icons.support_agent_outlined, "24/7 Support", "We're Here to Help"),
        ],
      ),
    );
  }

  Widget _buildFeatureCol(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFAF9F6),
              border: Border.all(color: const Color(0xFFC69C6D).withOpacity(0.3)),
            ),
            child: Icon(icon, color: const Color(0xFFC69C6D), size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF0F1E19), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.status == AuthStatus.loading;
        
        return InkWell(
          onTap: isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]
            ),
            child: isLoading
                ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFC69C6D), strokeWidth: 2)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text("Continue with Google", style: GoogleFonts.inter(color: const Color(0xFF0F1E19), fontSize: 16, fontWeight: FontWeight.w600)),
                      if (MediaQuery.of(context).size.width >= 900) ...[
                        const SizedBox(width: 20),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      ]
                    ],
                  ),
          ),
        );
      }
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("or", style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14)),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text("By continuing, you agree to our", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Terms & Conditions", style: GoogleFonts.inter(color: const Color(0xFFC69C6D), fontSize: 12, fontWeight: FontWeight.w600)),
            Text(" and ", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
            Text("Privacy Policy", style: GoogleFonts.inter(color: const Color(0xFFC69C6D), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}
