import '../../widgets/responsive_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Step2Business extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController storeNameController;
  final String businessType;
  final Function(String) onBusinessTypeChanged;
  final TextEditingController descriptionController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pinCodeController;
  final String vendorTier;
  final Function(String) onVendorTierChanged;
  
  // VIP Fields
  final TextEditingController vipReasonController;
  final TextEditingController turnoverController;
  final TextEditingController customerBaseController;
  final TextEditingController ordersPerMonthController;
  final TextEditingController premiumBrandsController;
  final TextEditingController physicalStoreCountController;
  final TextEditingController yearsExperienceController;
  final TextEditingController previousPlatformsController;
  final TextEditingController marketplaceRatingsController;
  final TextEditingController certificationsController;
  final TextEditingController storeUrlController;
  
  // File Uploads
  final XFile? storeLogo;
  final Function(XFile?) onLogoSelected;
  final XFile? storeBanner;
  final Function(XFile?) onBannerSelected;

  const Step2Business({
    super.key,
    required this.formKey,
    required this.storeNameController,
    required this.businessType,
    required this.onBusinessTypeChanged,
    required this.descriptionController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.pinCodeController,
    required this.vendorTier,
    required this.onVendorTierChanged,
    required this.vipReasonController,
    required this.turnoverController,
    required this.customerBaseController,
    required this.ordersPerMonthController,
    required this.premiumBrandsController,
    required this.physicalStoreCountController,
    required this.yearsExperienceController,
    required this.previousPlatformsController,
    required this.marketplaceRatingsController,
    required this.certificationsController,
    required this.storeUrlController,
    this.storeLogo,
    required this.onLogoSelected,
    this.storeBanner,
    required this.onBannerSelected,
  });

  @override
  State<Step2Business> createState() => _Step2BusinessState();
}

class _Step2BusinessState extends State<Step2Business> {
  final List<String> _businessTypes = [
    "Individual",
    "Proprietorship",
    "Partnership",
    "Private Limited",
    "LLP"
  ];
  
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLogo) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (isLogo) {
          widget.onLogoSelected(image);
        } else {
          widget.onBannerSelected(image);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Business Details", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text("Store & business information", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 32),

          ResponsiveRow(
            children: [
              _buildTextField("Store / Brand Name *", "Enter your store name", widget.storeNameController, Icons.storefront_outlined),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Business Type *", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: widget.businessType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC09947))),
                      ),
                      items: _businessTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.inter(fontSize: 14)));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) widget.onBusinessTypeChanged(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vendor Tier *", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: widget.vendorTier,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC09947))),
                ),
                items: ["Normal", "VIP"].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.inter(fontSize: 14)));
                }).toList(),
                onChanged: (value) {
                  if (value != null) widget.onVendorTierChanged(value);
                },
              ),
              const SizedBox(height: 4),
              Text(
                widget.vendorTier == "VIP" 
                    ? "VIP vendors require admin approval. VIP vendors can add products to the Luxury Section." 
                    : "Normal vendors are auto-approved but cannot add Luxury products.",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.amber.shade700, fontStyle: FontStyle.italic),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          _buildTextField("Business Description *", "Tell us about your products", widget.descriptionController, Icons.description_outlined, maxLines: 3),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildImageUploadBox("Store Logo", "JPG, PNG (1:1 aspect ratio)", widget.storeLogo, () => _pickImage(true)),
              
              _buildImageUploadBox("Store Banner", "JPG, PNG (16:9 aspect ratio)", widget.storeBanner, () => _pickImage(false)),
            ],
          ),
          const SizedBox(height: 24),

          _buildTextField("Business Address *", "Enter complete address", widget.addressController, Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 24),

          ResponsiveRow(
            children: [
              _buildTextField("City *", "City", widget.cityController, Icons.location_city_outlined),
              
              _buildTextField("State *", "State", widget.stateController, Icons.map_outlined),
              
              _buildTextField("PIN Code *", "123456", widget.pinCodeController, Icons.pin_drop_outlined, keyboardType: TextInputType.number),
            ],
          ),
          
          if (widget.vendorTier == "VIP") ...[
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC09947).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFC09947)),
                      
                      Text("VIP Qualification Information", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFC09947))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Help us understand your premium status. These details will be reviewed by admin.", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 32),
                  
                  _buildTextField("Why do you want to join as a VIP vendor? *", "Explain your motivation", widget.vipReasonController, Icons.text_snippet_outlined, maxLines: 3),
                  const SizedBox(height: 24),
                  
                  ResponsiveRow(
                    children: [
                      _buildTextField("Current Annual Turnover *", "e.g. 5 Crores", widget.turnoverController, Icons.account_balance_wallet_outlined),
                      
                      _buildTextField("Number of Orders per Month *", "e.g. 500", widget.ordersPerMonthController, Icons.shopping_cart_outlined, keyboardType: TextInputType.number),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  ResponsiveRow(
                    children: [
                      _buildTextField("Existing Customer Base", "e.g. 10,000+", widget.customerBaseController, Icons.groups_outlined),
                      
                      _buildTextField("Years of Market Experience *", "e.g. 5", widget.yearsExperienceController, Icons.timeline_outlined, keyboardType: TextInputType.number),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextField("Premium Brands Represented", "List brands separated by commas", widget.premiumBrandsController, Icons.diamond_outlined),
                  const SizedBox(height: 24),
                  
                  ResponsiveRow(
                    children: [
                      _buildTextField("Physical Store Count", "e.g. 3", widget.physicalStoreCountController, Icons.store_outlined, keyboardType: TextInputType.number),
                      
                      _buildTextField("Existing Online Store URL", "https://...", widget.storeUrlController, Icons.link_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextField("Previous E-commerce Platforms", "e.g. Amazon, Flipkart", widget.previousPlatformsController, Icons.web_outlined),
                  const SizedBox(height: 24),
                  
                  ResponsiveRow(
                    children: [
                      _buildTextField("Marketplace Ratings", "e.g. 4.8/5 on Amazon", widget.marketplaceRatingsController, Icons.star_border_outlined),
                      
                      _buildTextField("Certifications / Awards", "e.g. Best Retailer 2023", widget.certificationsController, Icons.emoji_events_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey, size: 20) : null,
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

  Widget _buildImageUploadBox(String title, String subtitle, XFile? file, VoidCallback onTap) {
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
                        const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text("Select Image", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFFC09947))),
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
