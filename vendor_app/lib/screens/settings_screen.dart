import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/vip_application_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers for basic info
  final _storeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ownerNameController = TextEditingController();
  
  String _vendorTier = "Normal";

  // Controllers for store details
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();

  // Controllers for social media
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('vendors').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _storeNameController.text = data['storeName'] ?? '';
            _ownerNameController.text = data['ownerName'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _emailController.text = data['email'] ?? user.email ?? '';
            
            // Check VIP request status first, then fallback to current vendorTier
            if (data['vipRequestStatus'] == 'pending') {
              _vendorTier = 'pending';
            } else {
              _vendorTier = data['vendorTier'] ?? 'Normal';
            }
            
            _addressController.text = data['address'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _taxIdController.text = data['taxId'] ?? '';
            _websiteController.text = data['website'] ?? '';
            _instagramController.text = data['instagram'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('vendors').doc(user.uid).update({
            'storeName': _storeNameController.text.trim(),
            'ownerName': _ownerNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'description': _descriptionController.text.trim(),
            'taxId': _taxIdController.text.trim(),
            'website': _websiteController.text.trim(),
            'instagram': _instagramController.text.trim(),
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Profile updated successfully!"),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(24),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: $e"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(24),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Form(
      key: _formKey,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vendor Profile", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text("Manage your store details and public presence.", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save, size: 18, color: Colors.white),
                      label: const Text("Save Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),

            // Profile Banner and Avatar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Cover Image
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(
                            image: NetworkImage("https://images.unsplash.com/photo-1573408301145-b98c46544859?q=80&w=2000&auto=format&fit=crop"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          label: const Text("Edit Cover", style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            backgroundColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      // Avatar
                      Positioned(
                        bottom: -40,
                        left: 32,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.purple.shade50,
                                  backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=150&auto=format&fit=crop"),
                                ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56), // Space for avatar overlap
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_storeNameController.text.isEmpty ? "Store Name" : _storeNameController.text, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Flexible(child: Text("Verified Vendor Account", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront, color: Colors.green.shade700, size: 16),
                              const SizedBox(width: 8),
                              Text("Store Active", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Forms Layout (2 columns on desktop, 1 on mobile)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildBasicInfoCard(),
                        const SizedBox(height: 24),
                        _buildSocialMediaCard(),
                        const SizedBox(height: 24),
                        _buildVendorTierCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildStoreDetailsCard(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildBasicInfoCard(),
                  const SizedBox(height: 24),
                  _buildStoreDetailsCard(),
                  const SizedBox(height: 24),
                  _buildSocialMediaCard(),
                  const SizedBox(height: 24),
                  _buildVendorTierCard(),
                ],
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: "Basic Information",
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField("Owner Name", "Enter full name", _ownerNameController, prefixIcon: Icons.person),
          const SizedBox(height: 16),
          _buildTextField("Store Name", "Enter store name", _storeNameController, prefixIcon: Icons.store),
          const SizedBox(height: 16),
          _buildTextField("Email Address", "contact@example.com", _emailController, prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField("Phone Number", "+91 0000000000", _phoneController, prefixIcon: Icons.phone, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildStoreDetailsCard() {
    return _buildCard(
      title: "Store Details",
      icon: Icons.business_center_outlined,
      child: Column(
        children: [
          _buildTextField("Tax ID / GSTIN", "Enter registration number", _taxIdController, prefixIcon: Icons.receipt),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Business Address", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Enter full business address",
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Store Description", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tell your customers about your store...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return _buildCard(
      title: "Social Links",
      icon: Icons.link,
      child: Column(
        children: [
          _buildTextField("Website", "https://", _websiteController, prefixIcon: Icons.language),
          const SizedBox(height: 16),
          _buildTextField("Instagram Username", "@username", _instagramController, prefixIcon: Icons.camera_alt_outlined),
        ],
      ),
    );
  }

  Widget _buildVendorTierCard() {
    bool isVip = _vendorTier == "VIP";
    return _buildCard(
      title: "Vendor Tier",
      icon: Icons.stars,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isVip ? const Color(0xFFC09947).withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isVip ? const Color(0xFFC09947) : Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isVip ? Icons.star : Icons.storefront, 
                         color: isVip ? const Color(0xFFC09947) : Colors.grey.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isVip ? "VIP Vendor" : "Normal Vendor",
                      style: GoogleFonts.inter(
                        color: isVip ? const Color(0xFFC09947) : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isVip 
                ? "You have access to the exclusive Luxury Catalog. You can add luxury products from the Add Product screen."
                : _vendorTier == "Pending VIP" || _vendorTier == "pending" // Check if it's pending (we stored 'vipRequestStatus' as 'pending' earlier)
                  ? "Your application for VIP Vendor is currently under review by our admin team."
                  : "Upgrade to VIP to access the exclusive Luxury Catalog and add luxury products.",
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
          ),
          if (!isVip) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    VipApplicationModal.show(context, onSuccess: () {
                      _loadProfileData(); // Reload profile to get updated status
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your VIP application has been submitted and is under review!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  }
                },
                icon: const Icon(Icons.upgrade, color: Colors.white),
                label: const Text("Apply for VIP Vendor Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC09947),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {IconData? prefixIcon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
          ),
        ),
      ],
    );
  }
}
