import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'step_1_account.dart';
import 'step_2_business.dart';
import 'step_3_kyc.dart';
import 'step_4_bank.dart';
import 'step_5_shipping.dart';
import 'step_6_review.dart';

class VendorRegistrationScreen extends StatefulWidget {
  final String initialVendorTier;
  
  const VendorRegistrationScreen({
    super.key,
    this.initialVendorTier = "Normal",
  });

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // --- Step 1: Account Controllers ---
  final _formKey1 = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: "Jane Vendor");
  final _emailController = TextEditingController(text: "vendor1@example.com");
  final _mobileController = TextEditingController(text: "9876543210");
  final _passwordController = TextEditingController(text: "Password123!");
  final _confirmPasswordController = TextEditingController(text: "Password123!");

  // --- Step 2: Business Details Controllers ---
  final _formKey2 = GlobalKey<FormState>();
  final _storeNameController = TextEditingController(text: "Sparkle Gems");
  String _businessType = "Individual"; // Default value
  late String _vendorTier; // Vendor type: Normal or VIP
  final _descriptionController = TextEditingController(text: "We sell premium handcrafted jewelry and precious stones.");
  final _addressController = TextEditingController(text: "123 Diamond Street, Market Area");
  final _cityController = TextEditingController(text: "Mumbai");
  final _stateController = TextEditingController(text: "Maharashtra");
  final _pinCodeController = TextEditingController(text: "400001");

  // --- Step 3: KYC Controllers ---
  final _formKey3 = GlobalKey<FormState>();
  final _kycAadhaarController = TextEditingController(text: "123456789012");
  final _kycPanController = TextEditingController(text: "ABCDE1234F");
  final _kycGstController = TextEditingController(text: "22AAAAA0000A1Z5");

  // --- Step 4: Bank Controllers ---
  final _formKey4 = GlobalKey<FormState>();
  final _bankHolderNameController = TextEditingController(text: "Jane Doe");
  final _bankAccountNumberController = TextEditingController(text: "0987654321123");
  final _bankIfscController = TextEditingController(text: "SBIN0001234");
  final _bankNameController = TextEditingController(text: "State Bank of India");

  // --- Step 5: Shipping Controllers ---
  final _formKey5 = GlobalKey<FormState>();
  final _pickupAddressController = TextEditingController(text: "123 Diamond Street, Market Area, Mumbai 400001");
  final _warehouseAddressController = TextEditingController(text: "456 Silver Lane, Industrial Estate, Mumbai 400002");
  final _shippingProviderController = TextEditingController(text: "Delhivery");
  final _processingTimeController = TextEditingController(text: "1-2 business days");
  final _returnAddressController = TextEditingController(text: "123 Diamond Street, Market Area, Mumbai 400001");
  final _returnPolicyController = TextEditingController(text: "7-day return policy for unused items in original packaging.");

  // --- VIP Qualification Controllers ---
  final _vipReasonController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _customerBaseController = TextEditingController();
  final _ordersPerMonthController = TextEditingController();
  final _premiumBrandsController = TextEditingController();
  final _physicalStoreCountController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _previousPlatformsController = TextEditingController();
  final _marketplaceRatingsController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _storeUrlController = TextEditingController();

  // --- File Upload State ---
  XFile? _profilePhoto;
  XFile? _storeLogo;
  XFile? _storeBanner;
  XFile? _idProof;
  XFile? _businessCert;
  XFile? _gstCert;
  XFile? _bankProof;

  // --- Step 6: Review ---
  bool _termsAccepted = true; // Pre-checked for dev
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _vendorTier = widget.initialVendorTier;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _storeNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _kycAadhaarController.dispose();
    _kycPanController.dispose();
    _kycGstController.dispose();
    _bankHolderNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankIfscController.dispose();
    _bankNameController.dispose();
    _pickupAddressController.dispose();
    _warehouseAddressController.dispose();
    _shippingProviderController.dispose();
    _processingTimeController.dispose();
    _returnAddressController.dispose();
    _returnPolicyController.dispose();
    
    _vipReasonController.dispose();
    _turnoverController.dispose();
    _customerBaseController.dispose();
    _ordersPerMonthController.dispose();
    _premiumBrandsController.dispose();
    _physicalStoreCountController.dispose();
    _yearsExperienceController.dispose();
    _previousPlatformsController.dispose();
    _marketplaceRatingsController.dispose();
    _certificationsController.dispose();
    _storeUrlController.dispose();
    super.dispose();
  }

  final List<String> _stepTitles = [
    "Account Details",
    "Business Details",
    "KYC Verification",
    "Bank & Payout Details",
    "Shipping Details",
    "Review & Submit"
  ];

  final List<String> _stepSubtitles = [
    "Create your account",
    "Store & business information",
    "Identity & business docs",
    "Bank account information",
    "Pickup & return address",
    "Review and submit"
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.storefront_outlined,
    Icons.verified_user_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.local_shipping_outlined,
    Icons.fact_check_outlined,
  ];

  void _goToNextStep() {
    bool isValid = false;
    if (_currentStep == 0) isValid = _formKey1.currentState!.validate();
    else if (_currentStep == 1) isValid = _formKey2.currentState!.validate();
    else if (_currentStep == 2) isValid = _formKey3.currentState!.validate();
    else if (_currentStep == 3) isValid = _formKey4.currentState!.validate();
    else if (_currentStep == 4) isValid = _formKey5.currentState!.validate();

    if (isValid && _currentStep < 5) {
      if (_currentStep == 0 && _passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red));
        return;
      }
      
      // Image Validations
      if (_currentStep == 1 && (_storeLogo == null || _storeBanner == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload both Store Logo and Banner"), backgroundColor: Colors.red));
        return;
      }
      if (_currentStep == 2) {
        if (_idProof == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload ID Proof"), backgroundColor: Colors.red));
          return;
        }
        if (_businessType != "Individual" && _businessCert == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload Business Registration Certificate"), backgroundColor: Colors.red));
          return;
        }
      }
      if (_currentStep == 3 && _bankProof == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload Cancelled Cheque / Bank Proof"), backgroundColor: Colors.red));
        return;
      }

      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<String?> _uploadToCloudinary(XFile? image) async {
    if (image == null) return null;
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloudinary configuration missing in .env')),
      );
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name.isNotEmpty ? image.name : 'document.png',
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      }
      return null;
    } catch (e) {
      print("Exception during Cloudinary upload: $e");
      return null;
    }
  }

  Future<void> _submitRegistration() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please accept the terms to continue"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // 1. Create Auth Account if not logged in
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        user = userCredential.user;
      }

      if (user != null) {
        // 2. Upload Documents
        String? profilePhotoUrl = await _uploadToCloudinary(_profilePhoto);
        String? storeLogoUrl = await _uploadToCloudinary(_storeLogo);
        String? storeBannerUrl = await _uploadToCloudinary(_storeBanner);
        String? idProofUrl = await _uploadToCloudinary(_idProof);
        String? businessCertUrl = await _uploadToCloudinary(_businessCert);
        String? gstCertUrl = await _uploadToCloudinary(_gstCert);
        String? bankProofUrl = await _uploadToCloudinary(_bankProof);

        // 3. Save Vendor Data to Firestore
        await FirebaseFirestore.instance.collection('vendors').doc(user.uid).set({
          // Account
          'ownerName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _mobileController.text.trim(),
          // Business
          'storeName': _storeNameController.text.trim(),
          'businessType': _businessType,
          'description': _descriptionController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pinCode': _pinCodeController.text.trim(),
          // KYC
          'kycAadhaar': _kycAadhaarController.text.trim(),
          'kycPan': _kycPanController.text.trim(),
          'kycGst': _kycGstController.text.trim(),
          // Bank
          'bankHolderName': _bankHolderNameController.text.trim(),
          'bankAccountNumber': _bankAccountNumberController.text.trim(),
          'bankIfsc': _bankIfscController.text.trim(),
          'bankName': _bankNameController.text.trim(),
          // Shipping
          'pickupAddress': _pickupAddressController.text.trim(),
          'warehouseAddress': _warehouseAddressController.text.trim(),
          'shippingProvider': _shippingProviderController.text.trim(),
          'processingTime': _processingTimeController.text.trim(),
          'returnAddress': _returnAddressController.text.trim(),
          'returnPolicy': _returnPolicyController.text.trim(),
          // Status
          'vendorTier': _vendorTier,
          'status': _vendorTier == 'VIP' ? 'pending' : 'approved',  // VIP requires admin approval
          'isKycVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          // VIP Details
          if (_vendorTier == 'VIP') 'vipDetails': {
            'reason': _vipReasonController.text.trim(),
            'turnover': _turnoverController.text.trim(),
            'customerBase': _customerBaseController.text.trim(),
            'ordersPerMonth': _ordersPerMonthController.text.trim(),
            'premiumBrands': _premiumBrandsController.text.trim(),
            'physicalStoreCount': _physicalStoreCountController.text.trim(),
            'yearsExperience': _yearsExperienceController.text.trim(),
            'previousPlatforms': _previousPlatformsController.text.trim(),
            'marketplaceRatings': _marketplaceRatingsController.text.trim(),
            'certifications': _certificationsController.text.trim(),
            'storeUrl': _storeUrlController.text.trim(),
          },
          // Documents
          'profilePhotoUrl': profilePhotoUrl,
          'storeLogoUrl': storeLogoUrl,
          'storeBannerUrl': storeBannerUrl,
          'idProofUrl': idProofUrl,
          'businessCertUrl': businessCertUrl,
          'gstCertUrl': gstCertUrl,
          'bankProofUrl': bankProofUrl,
        });

        // 4. Navigation handled by AuthWrapper via main.dart
        if (mounted) Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration failed"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildLeftSidebar(),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      if (!isDesktop) _buildHorizontalStepper(), // For mobile/tablet
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(), // Disable swipe
                          children: [
                            SingleChildScrollView(
                              child: _buildFormContainer(Step1Account(
                                formKey: _formKey1,
                                fullNameController: _fullNameController,
                                emailController: _emailController,
                                mobileController: _mobileController,
                                passwordController: _passwordController,
                                confirmPasswordController: _confirmPasswordController,
                                profilePhoto: _profilePhoto,
                                onProfilePhotoSelected: (file) => setState(() => _profilePhoto = file),
                              )),
                            ),
                            SingleChildScrollView(
                              child: _buildFormContainer(Step2Business(
                                formKey: _formKey2,
                                storeNameController: _storeNameController,
                                businessType: _businessType,
                                onBusinessTypeChanged: (val) => setState(() => _businessType = val),
                                vendorTier: _vendorTier,
                                onVendorTierChanged: (val) => setState(() => _vendorTier = val),
                                descriptionController: _descriptionController,
                                addressController: _addressController,
                                cityController: _cityController,
                                stateController: _stateController,
                                pinCodeController: _pinCodeController,
                                vipReasonController: _vipReasonController,
                                turnoverController: _turnoverController,
                                customerBaseController: _customerBaseController,
                                ordersPerMonthController: _ordersPerMonthController,
                                premiumBrandsController: _premiumBrandsController,
                                physicalStoreCountController: _physicalStoreCountController,
                                yearsExperienceController: _yearsExperienceController,
                                previousPlatformsController: _previousPlatformsController,
                                marketplaceRatingsController: _marketplaceRatingsController,
                                certificationsController: _certificationsController,
                                storeUrlController: _storeUrlController,
                                storeLogo: _storeLogo,
                                onLogoSelected: (file) => setState(() => _storeLogo = file),
                                storeBanner: _storeBanner,
                                onBannerSelected: (file) => setState(() => _storeBanner = file),
                              )),
                            ),
                            SingleChildScrollView(
                              child: _buildFormContainer(Step3Kyc(
                                formKey: _formKey3,
                                businessType: _businessType,
                                aadhaarController: _kycAadhaarController,
                                panController: _kycPanController,
                                gstController: _kycGstController,
                                idProofDoc: _idProof,
                                onIdProofSelected: (file) => setState(() => _idProof = file),
                                businessCertDoc: _businessCert,
                                onBusinessCertSelected: (file) => setState(() => _businessCert = file),
                                gstCertDoc: _gstCert,
                                onGstCertSelected: (file) => setState(() => _gstCert = file),
                              )),
                            ),
                            SingleChildScrollView(
                              child: _buildFormContainer(Step4Bank(
                                formKey: _formKey4,
                                holderNameController: _bankHolderNameController,
                                accountNumberController: _bankAccountNumberController,
                                ifscController: _bankIfscController,
                                bankNameController: _bankNameController,
                                bankProofDoc: _bankProof,
                                onBankProofSelected: (file) => setState(() => _bankProof = file),
                              )),
                            ),
                            SingleChildScrollView(
                              child: _buildFormContainer(Step5Shipping(
                                formKey: _formKey5,
                                pickupAddressController: _pickupAddressController,
                                warehouseAddressController: _warehouseAddressController,
                                shippingProviderController: _shippingProviderController,
                                processingTimeController: _processingTimeController,
                                returnAddressController: _returnAddressController,
                                returnPolicyController: _returnPolicyController,
                              )),
                            ),
                            SingleChildScrollView(
                              child: _buildFormContainer(Step6Review(
                                fullName: _fullNameController.text,
                                email: _emailController.text,
                                mobile: _mobileController.text,
                                storeName: _storeNameController.text,
                                businessType: _businessType,
                                address: _addressController.text,
                                termsAccepted: _termsAccepted,
                                onTermsChanged: (val) => setState(() => _termsAccepted = val ?? false),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) _buildRightSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _goToPreviousStep,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  child: const Text("Back"),
                )
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : (_currentStep == 5 ? _submitRegistration : _goToNextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC09947),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep == 5 ? "Submit Registration" : "Save & Continue ->"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E2F), // Dark background for logo
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.diamond, color: Color(0xFFC09947))),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("JewelCraft", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Vendor Registration", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text("Already have an account? ", style: GoogleFonts.inter(color: Colors.grey.shade600)),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Text("Login", style: GoogleFonts.inter(color: const Color(0xFFC09947), fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("REGISTRATION STEPS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          ...List.generate(6, (index) {
            bool isActive = _currentStep == index;
            bool isCompleted = _currentStep > index;
            return _buildSidebarStep(index, isActive, isCompleted);
          }),
        ],
      ),
    );
  }

  Widget _buildSidebarStep(int index, bool isActive, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isActive ? 12 : 0),
      decoration: isActive ? BoxDecoration(
        color: const Color(0xFFFDFBF7), // Light gold tint
        border: Border.all(color: const Color(0xFFC09947).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFC09947) : (isCompleted ? Colors.green : Colors.grey.shade100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text("${index + 1}", style: GoogleFonts.inter(color: isActive ? Colors.white : Colors.grey.shade500, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stepTitles[index], style: GoogleFonts.inter(fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? Colors.black : Colors.grey.shade700)),
                Text(_stepSubtitles[index], style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInfoCard(
            title: "Why Register as a Vendor?",
            icon: Icons.storefront,
            items: [
              "Sell your jewelry to thousands of customers",
              "Manage your products and orders efficiently",
              "Secure payments and timely payouts",
              "Grow your business with our platform",
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: "Required Information",
            icon: Icons.info_outline,
            items: [
              "Identity Proof (Aadhaar / PAN)",
              "Business Documents (GST / Registration)",
              "Bank Account Details",
              "Store / Business Information",
            ],
            subtitle: "Please keep the following documents ready for a smooth verification process.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<String> items, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC09947), size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          ],
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 8),
                  child: Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                ),
                Expanded(child: Text(item, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    return Container(
      height: 80,
      color: Colors.white,
      child: Center(
        child: Text("Stepper for mobile (Todo)"),
      ),
    );
  }
}
