import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:typed_data';
import '../widgets/vip_application_modal.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController(text: "1");
  final _descriptionController = TextEditingController();
  
  String _selectedMainCategory = "General";
  String _selectedSubCategory = "General";
  
  Map<String, List<String>> _appCategories = {'Loading...': ['Loading...']};
  bool _isLoadingCategories = true;

  List<XFile> _selectedImages = [];
  bool _isUploading = false;
  
  bool _isVipVendor = false;
  bool _addToLuxurySection = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchVendorTier();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _currentPriceController.dispose();
    _oldPriceController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').where('status', isEqualTo: 'Active').get();
      final Map<String, List<String>> fetchedCategories = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? 'Unknown';
        final subcats = (data['subcategories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['General'];
        fetchedCategories[name] = subcats.isNotEmpty ? subcats : ['General'];
      }
      
      if (fetchedCategories.isEmpty) {
        fetchedCategories['General'] = ['General'];
      }
      
      setState(() {
        _appCategories = fetchedCategories;
        _selectedMainCategory = _appCategories.keys.first;
        _selectedSubCategory = _appCategories[_selectedMainCategory]!.first;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        _appCategories = {'General': ['General']};
        _selectedMainCategory = 'General';
        _selectedSubCategory = 'General';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _fetchVendorTier() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('vendors').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _isVipVendor = data['vendorTier'] == 'VIP';
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<String?> _uploadToCloudinary(XFile image) async {
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
        filename: image.name.isNotEmpty ? image.name : 'image.png',
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

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.')),
      );
      return;
    }

    if (Firebase.app().options.projectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase configuration missing! Please restart the app.')),
      );
      return;
    }

    setState(() { _isUploading = true; });

    try {
      List<String> imageUrls = [];
      for (var img in _selectedImages) {
        String? url = await _uploadToCloudinary(img);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) throw Exception("Failed to upload any images");

      final productData = {
        'title': _titleController.text,
        'currentPrice': double.tryParse(_currentPriceController.text) ?? 0.0,
        'oldPrice': double.tryParse(_oldPriceController.text) ?? 0.0,
        'discount': _discountController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 1,
        'description': _descriptionController.text,
        'mainCategory': _selectedMainCategory,
        'category': _selectedSubCategory,
        'image': imageUrls.first,
        'images': imageUrls,
        'bgColor': 0xFFEEEEEE,
        'createdAt': FieldValue.serverTimestamp(),
        'vendorId': FirebaseAuth.instance.currentUser?.uid,
        'isLuxury': _addToLuxurySection,
      };

      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 10));
        }
      } catch (authError) {
        print("Auth error (ignoring if rules are public): $authError");
      }

      final docRef = await FirebaseFirestore.instance.collection('products').add(productData).timeout(const Duration(seconds: 15));
      
      if (_addToLuxurySection) {
        await FirebaseFirestore.instance.collection('luxury_products').doc(docRef.id).set({
          'title': _titleController.text,
          'price': "₹${_currentPriceController.text}",
          'image': imageUrls.first,
          'active': false, // Admin needs to approve it or make it active
          'order': 99,
          'category': _selectedSubCategory ?? 'All',
          'createdAt': FieldValue.serverTimestamp(),
          'vendorId': FirebaseAuth.instance.currentUser?.uid,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
      }
    } finally {
      if (mounted) setState(() { _isUploading = false; });
    }
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4C1D95), // Deep purple
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _customInputDecoration(String label, {String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      labelStyle: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2), // Purple
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Add New Product', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION 1: Product Images
                        _buildSectionTitle("1. Product Images", "Upload clear images of your product"),
                        
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF), // Very light purple
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6), // Purple border
                                width: 1.5,
                                style: BorderStyle.solid, // Flutter doesn't support dashed borders natively without a package, using solid for now
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8B5CF6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 28),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Drag & drop images here",
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text("or", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _pickImage,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF7C3AED),
                                    side: const BorderSide(color: Color(0xFF7C3AED)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: const Text("Choose Files"),
                                ),
                                const SizedBox(height: 16),
                                Text("JPG, PNG or WEBP (Max. 5MB) each\nYou can upload up to 5 images",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(_selectedImages.length, (index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: kIsWeb
                                          ? FutureBuilder<Uint8List>(
                                              future: _selectedImages[index].readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                                return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                              },
                                            )
                                          : const Icon(Icons.image, color: Colors.grey),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],

                        const SizedBox(height: 40),
                        
                        // SECTION 2: Product Type
                        _buildSectionTitle("2. Product Type", "Select whether this is a normal or luxury product"),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProductTypeSelector(
                                title: "Normal Product",
                                icon: Icons.shopping_bag_outlined,
                                isSelected: !_addToLuxurySection,
                                onTap: () {
                                  setState(() => _addToLuxurySection = false);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProductTypeSelector(
                                title: "Luxury Product",
                                icon: Icons.diamond_outlined,
                                isSelected: _addToLuxurySection,
                                onTap: () {
                                  if (_isVipVendor) {
                                    setState(() => _addToLuxurySection = true);
                                  } else {
                                    // Prompt to become VIP
                                    VipApplicationModal.show(context, onSuccess: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Your VIP application has been submitted and is under review!')),
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // SECTION 3: Product Details
                        _buildSectionTitle("3. Product Details", ""),
                        TextFormField(
                          controller: _titleController,
                          decoration: _customInputDecoration('Product Title', hint: 'Enter product title'),
                          validator: (v) => v!.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 24),
                        isMobile ? Column(
                          children: [
                            TextFormField(
                              controller: _currentPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _customInputDecoration('Current Price (₹)', hint: 'Enter current price', prefixIcon: const Icon(Icons.currency_rupee, size: 18)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _oldPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _customInputDecoration('Old Price (₹)', hint: 'Enter old price', prefixIcon: const Icon(Icons.currency_rupee, size: 18)),
                            ),
                          ],
                        ) : Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _currentPriceController,
                                keyboardType: TextInputType.number,
                                decoration: _customInputDecoration('Current Price (₹)', hint: 'Enter current price', prefixIcon: const Icon(Icons.currency_rupee, size: 18)),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _oldPriceController,
                                keyboardType: TextInputType.number,
                                decoration: _customInputDecoration('Old Price (₹)', hint: 'Enter old price', prefixIcon: const Icon(Icons.currency_rupee, size: 18)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                        
                        // SECTION 4: Categories & Discount
                        _buildSectionTitle("4. Categories", ""),
                        isMobile ? Column(
                          children: [
                            TextFormField(
                              controller: _discountController,
                              decoration: _customInputDecoration('Discount (%)', hint: 'Enter discount', prefixIcon: const Icon(Icons.percent, size: 18)),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: _customInputDecoration('Quantity', hint: 'Stock amount', prefixIcon: const Icon(Icons.inventory_2, size: 18)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedMainCategory,
                              decoration: _customInputDecoration('Main Category'),
                              items: _appCategories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedMainCategory = v!;
                                  _selectedSubCategory = _appCategories[v]!.first;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedSubCategory,
                              decoration: _customInputDecoration('Sub Category'),
                              items: _appCategories[_selectedMainCategory]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedSubCategory = v!;
                                });
                              },
                            ),
                          ],
                        ) : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _discountController,
                                decoration: _customInputDecoration('Discount (%)', hint: 'Enter discount', prefixIcon: const Icon(Icons.percent, size: 18)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: _customInputDecoration('Quantity', hint: 'Stock amount', prefixIcon: const Icon(Icons.inventory_2, size: 18)),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedMainCategory,
                                decoration: _customInputDecoration('Main Category'),
                                items: _appCategories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedMainCategory = v!;
                                    _selectedSubCategory = _appCategories[v]!.first;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedSubCategory,
                                decoration: _customInputDecoration('Sub Category'),
                                items: _appCategories[_selectedMainCategory]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedSubCategory = v!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // SECTION 5: Product Description
                        _buildSectionTitle("5. Product Description", "Provide a detailed description of your product (optional)"),
                        StatefulBuilder(
                          builder: (context, setState) {
                            bool isHovered = false;
                            return MouseRegion(
                              onEnter: (_) => setState(() => isHovered = true),
                              onExit: (_) => setState(() => isHovered = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: isHovered 
                                      ? [const Color(0xFFF3E8FF), const Color(0xFFE0E7FF)] 
                                      : [Colors.white, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: isHovered ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                                    width: isHovered ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    if (isHovered)
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      )
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 6,
                                  style: GoogleFonts.inter(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Enter an engaging product description here...',
                                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 48),

                        // Note: Luxury switch logic is now handled at the top, so we removed SECTION 5 from here.


                        // Actions
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _submitProduct,
                              icon: _isUploading ? const SizedBox.shrink() : const Icon(Icons.add, color: Colors.white, size: 18),
                              label: _isUploading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Add Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED), // Purple
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProductTypeSelector({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (title.contains("Luxury") ? const Color(0xFFFDFBF7) : const Color(0xFFF3E8FF))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (title.contains("Luxury") ? const Color(0xFFC09947) : const Color(0xFF8B5CF6))
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: title.contains("Luxury") 
                    ? const Color(0xFFC09947).withOpacity(0.1) 
                    : const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? (title.contains("Luxury") ? const Color(0xFFC09947) : const Color(0xFF8B5CF6))
                  : Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected 
                    ? (title.contains("Luxury") ? const Color(0xFFC09947) : const Color(0xFF8B5CF6))
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
