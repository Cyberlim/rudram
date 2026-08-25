import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';
import 'otp_screen.dart';
// Just redirecting to home upon skip for now

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AppAuthProvider>();
    bool success;

    if (_isLogin) {
      success = await auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (!success && mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } else {
      success = await auth.initiateEmailOTPRegistration(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
            ),
          ),
        );
      } else if (!success && mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
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
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Stack(
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
                        color: const Color(0xFFE8DCC4).withValues(alpha: 0.3),
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
                                  Text(
                                    "Skip",
                                    style: GoogleFonts.cormorantGaramond(
                                      color: const Color(0xFFC69C6D),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFFC69C6D),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLogoSection(),
                                const SizedBox(height: 16),
                                _buildTitleSection(),
                                const SizedBox(height: 24),
                                _buildEmailAuthForm(),
                                const SizedBox(height: 16),
                                _buildDivider(),
                                const SizedBox(height: 16),
                                _buildGoogleButton(),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Section (Create Account)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            children: [
                              Text(
                                _isLogin
                                    ? "New to JewelCraft?"
                                    : "Already have an account?",
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin ? "Create an account" : "Sign in instead",
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFC69C6D),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFFC69C6D),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                        const Color(0xFF0F1E19).withValues(alpha: 0.8),
                        const Color(0xFFC69C6D).withValues(alpha: 0.2),
                      ],
                    ),
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
                              const Icon(
                                Icons.diamond_outlined,
                                color: Color(0xFFC69C6D),
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "JewelCraft",
                                    style: GoogleFonts.cormorantGaramond(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "TIMELESS BEAUTY, ALWAYS YOURS",
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFC69C6D),
                                      fontSize: 10,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 80),
                          Text(
                            "More Than\nJewelry,\nA Story Forever",
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: 56,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Discover exquisite collections,\ncrafted with trust, elegance,\nand tradition.",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 60),
                          _buildDesktopFeatureItem(
                            Icons.diamond_outlined,
                            "Authentic & Certified",
                            "Hallmarked jewelry you can trust",
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopFeatureItem(
                            Icons.shopping_bag_outlined,
                            "Secure Shopping",
                            "Your safety, our priority",
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopFeatureItem(
                            Icons.favorite_border,
                            "Exclusive Collections",
                            "Designed for life's special moments",
                          ),
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
                      const Icon(
                        Icons.diamond_outlined,
                        color: Color(0xFFC69C6D),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Trusted by thousands\nof jewelry lovers",
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 16),
                        _buildTitleSection(),
                        const SizedBox(height: 16),
                        _buildEmailAuthForm(),
                        const SizedBox(height: 12),
                        _buildDivider(),
                        const SizedBox(height: 12),
                        _buildGoogleButton(),
                        const SizedBox(height: 12),
                        Text(
                          "Secure • Fast • Easy",
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniFeature(
                              Icons.verified_user_outlined,
                              "Your data\nis safe",
                            ),
                            _buildMiniFeature(
                              Icons.bolt_outlined,
                              "Quick\naccess",
                            ),
                            _buildMiniFeature(
                              Icons.person_outline,
                              "Personalized\nexperience",
                            ),
                            _buildMiniFeature(
                              Icons.diamond_outlined,
                              "Discover\nexclusive collections",
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTerms(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "New to JewelCraft?"
                                  : "Already have an account?",
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? "Create an account"
                                    : "Sign in instead",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFC69C6D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDesktopFeatureItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFC69C6D).withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, color: const Color(0xFFC69C6D), size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC69C6D), size: 24),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.grey.shade600,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        const Icon(Icons.diamond_outlined, color: Color(0xFFC69C6D), size: 36),
        const SizedBox(height: 8),
        Text(
          "JewelCraft",
          style: GoogleFonts.cormorantGaramond(
            color: const Color(0xFF0F1E19),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Timeless Beauty, Crafted for You",
          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          _isLogin ? "Welcome Back" : "Create Account",
          style: GoogleFonts.cormorantGaramond(
            color: const Color(0xFF0F1E19),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isLogin
              ? "Sign in to continue your journey"
              : "Join JewelCraft for exclusive access",
          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
        ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureCol(
            Icons.verified_user_outlined,
            "Secure Shopping",
            "Safe & Trusted",
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildFeatureCol(
            Icons.diamond_outlined,
            "Certified Jewelry",
            "Hallmarked & Authentic",
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildFeatureCol(
            Icons.support_agent_outlined,
            "24/7 Support",
            "We're Here to Help",
          ),
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
              border: Border.all(
                color: const Color(0xFFC69C6D).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: const Color(0xFFC69C6D), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F1E19),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC69C6D)),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC69C6D)),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC69C6D)),
              ),
            ),
            obscureText: true,
            validator: (v) =>
                v!.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          if (_isLogin) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Consumer<AppAuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.status == AuthStatus.loading
                      ? null
                      : _submitEmailAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF0F1E19),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.status == AuthStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? "Sign In" : "Create Account",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          ),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFFC69C6D),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.g_mobiledata, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue with Google",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F1E19),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (MediaQuery.of(context).size.width >= 900) ...[
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or",
            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          "By continuing, you agree to our",
          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Terms & Conditions",
              style: GoogleFonts.inter(
                color: const Color(0xFFC69C6D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              " and ",
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              "Privacy Policy",
              style: GoogleFonts.inter(
                color: const Color(0xFFC69C6D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
