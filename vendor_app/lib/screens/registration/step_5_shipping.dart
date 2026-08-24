import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Step5Shipping extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pickupAddressController;
  final TextEditingController warehouseAddressController;
  final TextEditingController shippingProviderController;
  final TextEditingController processingTimeController;
  final TextEditingController returnAddressController;
  final TextEditingController returnPolicyController;

  const Step5Shipping({
    super.key,
    required this.formKey,
    required this.pickupAddressController,
    required this.warehouseAddressController,
    required this.shippingProviderController,
    required this.processingTimeController,
    required this.returnAddressController,
    required this.returnPolicyController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shipping Details", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text("Pickup & return address configuration", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTextField("Pickup Address *", "Primary location for courier pickup", pickupAddressController, Icons.location_on_outlined, maxLines: 2)),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField("Warehouse Address (Optional)", "Secondary inventory location", warehouseAddressController, Icons.warehouse_outlined, maxLines: 2)),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTextField("Shipping Provider *", "e.g. Delhivery, BlueDart, Own Fleet", shippingProviderController, Icons.local_shipping_outlined)),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField("Estimated Processing Time *", "e.g. 1-2 business days", processingTimeController, Icons.timer_outlined)),
            ],
          ),
          const SizedBox(height: 24),

          _buildTextField("Return Address *", "Address for customer returns", returnAddressController, Icons.assignment_return_outlined, maxLines: 2),
          const SizedBox(height: 24),

          _buildTextField("Return Policy *", "Briefly describe your return policy", returnPolicyController, Icons.policy_outlined, maxLines: 3),
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
          validator: (value) {
            if (label.contains("*") && value!.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
