import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/data_models.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../services/firestore_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import 'desktop_orders_page.dart';

const Map<String, List<String>> _indiaStates = {
  "Andhra Pradesh": ["Visakhapatnam", "Vijayawada", "Guntur", "Nellore"],
  "Assam": ["Guwahati", "Silchar", "Dibrugarh"],
  "Bihar": ["Patna", "Gaya", "Bhagalpur", "Muzaffarpur"],
  "Delhi": ["New Delhi", "North Delhi", "South Delhi"],
  "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
  "Haryana": ["Faridabad", "Gurugram", "Panipat", "Ambala"],
  "Karnataka": ["Bengaluru", "Mysuru", "Hubballi", "Mangaluru"],
  "Kerala": ["Thiruvananthapuram", "Kochi", "Kozhikode", "Thrissur"],
  "Madhya Pradesh": ["Bhopal", "Indore", "Gwalior", "Jabalpur"],
  "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
  "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela", "Puri"],
  "Punjab": ["Ludhiana", "Amritsar", "Jalandhar", "Patiala"],
  "Rajasthan": ["Jaipur", "Jodhpur", "Udaipur", "Kota"],
  "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai", "Tiruchirappalli"],
  "Telangana": ["Hyderabad", "Warangal", "Nizamabad", "Karimnagar"],
  "Uttar Pradesh": ["Lucknow", "Kanpur", "Agra", "Varanasi", "Noida"],
  "West Bengal": ["Kolkata", "Howrah", "Darjeeling", "Siliguri"],
};

enum CheckoutStep { cart, address, payment, success }

enum PaymentMethod { card, upi, cod }

class DesktopCheckoutPage extends StatefulWidget {
  final List<ProductItem> cartItems;
  const DesktopCheckoutPage({super.key, required this.cartItems});

  @override
  State<DesktopCheckoutPage> createState() => _DesktopCheckoutPageState();
}

class _DesktopCheckoutPageState extends State<DesktopCheckoutPage> {
  CheckoutStep _currentStep = CheckoutStep.cart;
  bool _showAddressForm = false;
  PaymentMethod _selectedMethod = PaymentMethod.card;

  final _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Map<String, dynamic>? _selectedAddress;
  Map<String, dynamic>? _selectedPaymentMethod;
  final String _fallbackPaymentMethod = 'COD';

  // --- Form Controllers ---
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _selectedState = _indiaStates.keys.first;
  String _selectedCity = _indiaStates.values.first.first;
  final _cardNumberCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  static const _brand = Color(0xFFE65C00);
  static const _brandLight = Color(0xFFFFF3EC);
  static const _dark = Color(0xFF1A1A2E);
  static const _textGrey = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _cardBg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _firestoreService.getUserAddresses(_uid).first.then((addresses) {
        if (mounted && addresses.isNotEmpty) {
          setState(() {
            _selectedAddress = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
          });
        }
      });
      _firestoreService.getUserPaymentMethods(_uid).first.then((methods) {
        if (mounted && methods.isNotEmpty) {
          setState(() {
            _selectedPaymentMethod = methods.firstWhere((m) => m['isDefault'] == true, orElse: () => methods.first);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cvvCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  double get _subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + item.currentPrice);
  double get _deliveryFee => 150.0;
  double get _tax => _subtotal * 0.03;
  double get _total => _subtotal + _deliveryFee + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          DesktopHeader(cartCount: widget.cartItems.length),
          if (_currentStep != CheckoutStep.success) _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: _buildCurrentStepView(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEPPER ─────────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    final steps = [
      (label: 'Cart', step: CheckoutStep.cart),
      (label: 'Address', step: CheckoutStep.address),
      (label: 'Payment', step: CheckoutStep.payment),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.asMap().entries.expand((e) {
          final i = e.key;
          final s = e.value;
          final isCompleted = _currentStep.index > s.step.index;
          final isActive = _currentStep == s.step;
          return [
            _stepDot(s.label, s.step.index + 1, isCompleted, isActive),
            if (i < steps.length - 1) _stepLine(isCompleted),
          ];
        }).toList(),
      ),
    );
  }

  Widget _stepDot(String label, int num, bool done, bool active) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? _brand : _borderColor,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$num',
                    style: TextStyle(
                      color: active ? Colors.white : _textGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: active ? _dark : _textGrey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool done) {
    return Container(
      width: 60,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: done ? _brand : _borderColor,
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case CheckoutStep.cart:
        return _buildCartView();
      case CheckoutStep.address:
        return _buildAddressView();
      case CheckoutStep.payment:
        return _buildPaymentView();
      case CheckoutStep.success:
        return _buildSuccessView();
    }
  }

  // ─── STEP 1: CART ────────────────────────────────────────────────────────────
  Widget _buildCartView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shopping Cart',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _dark),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.cartItems.length} item${widget.cartItems.length == 1 ? '' : 's'} in your cart',
          style: const TextStyle(color: _textGrey),
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart Items
            Expanded(
              flex: 3,
              child: Column(
                children: widget.cartItems
                    .map((item) => _cartItemCard(item))
                    .toList(),
              ),
            ),
            const SizedBox(width: 30),
            // Summary
            Expanded(
              flex: 2,
              child: _buildOrderSummaryCard(
                primaryLabel: 'Proceed to Address',
                onPrimary: () => setState(() => _currentStep = CheckoutStep.address),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cartItemCard(ProductItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(item.image, fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(Icons.image_outlined, color: Colors.grey)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _dark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.category.isNotEmpty ? item.category : 'Jewelry',
                  style: const TextStyle(color: _textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Quantity
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _qtyBtn(Icons.remove),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                _qtyBtn(Icons.add),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '₹${item.currentPrice.toInt().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _dark),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 14, color: _textGrey),
      ),
    );
  }

  // ─── SHARED: ORDER SUMMARY CARD ──────────────────────────────────────────────
  Widget _buildOrderSummaryCard({required String primaryLabel, required VoidCallback onPrimary}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
          const SizedBox(height: 24),
          // Coupon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _brandLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _brand.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: _brand, size: 16),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Apply Coupon Code', style: TextStyle(color: _brand, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const Icon(Icons.chevron_right, color: _brand, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: _borderColor),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', '₹${_subtotal.toInt()}'),
          _summaryRow('Delivery Fee', '₹${_deliveryFee.toInt()}'),
          _summaryRow('GST (3%)', '₹${_tax.toInt()}'),
          const SizedBox(height: 8),
          const Divider(color: _borderColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _dark)),
              Text('₹${_total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _brand)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text('Secure checkout', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textGrey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _dark)),
        ],
      ),
    );
  }

  // ─── STEP 2: ADDRESS ─────────────────────────────────────────────────────────
  Widget _buildAddressView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _brandLight, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.location_on_outlined, color: _brand, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Shipping Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dark)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _showAddressForm = !_showAddressForm),
                      icon: Icon(_showAddressForm ? Icons.close : Icons.add, color: _brand, size: 20),
                      label: Text(
                        _showAddressForm ? "Cancel" : "Add New",
                        style: const TextStyle(color: _brand, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (_showAddressForm) ...[
                  _formRow([
                    _formField(
                      'Full Name',
                      controller: _nameCtrl,
                    ),
                    _formField(
                      'Phone Number',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _formRow([
                    _formField(
                      'Pincode',
                      controller: _pincodeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                    _formField('Area / Street', controller: _addressCtrl),
                  ]),
                  const SizedBox(height: 16),
                  _formRow([
                    _dropdownField(
                      'State',
                      value: _selectedState,
                      items: _indiaStates.keys.toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedState = val;
                            _selectedCity = _indiaStates[val]!.first;
                          });
                        }
                      },
                    ),
                    _dropdownField(
                      'City / District',
                      value: _indiaStates[_selectedState]!.contains(_selectedCity) ? _selectedCity : _indiaStates[_selectedState]!.first,
                      items: _indiaStates[_selectedState]!,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCity = val;
                          });
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_uid != null && _nameCtrl.text.isNotEmpty && _addressCtrl.text.isNotEmpty) {
                          await _firestoreService.addAddress(_uid, {
                            'name': _nameCtrl.text,
                            'street': _addressCtrl.text,
                            'city': _selectedCity,
                            'zip': _pincodeCtrl.text,
                            'country': _selectedState,
                            'phone': _phoneCtrl.text,
                            'isDefault': false,
                          });
                          setState(() {
                            _showAddressForm = false;
                            _nameCtrl.clear();
                            _phoneCtrl.clear();
                            _pincodeCtrl.clear();
                            _addressCtrl.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ] else
                  _buildAddressList(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Summary
        Expanded(
          flex: 2,
          child: _buildOrderSummaryCard(
            primaryLabel: 'Continue to Payment',
            onPrimary: () {
              if (_selectedAddress == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an address')));
                return;
              }
              setState(() => _currentStep = CheckoutStep.payment);
            },
          ),
        ),
      ],
    );
  }

  Widget _formRow(List<Widget> fields) {
    return Row(
      children: fields.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key > 0 ? 12 : 0),
            child: e.value,
          ),
        );
      }).toList(),
    );
  }

  Widget _formField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _brand, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(
    String label, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _brand, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressList() {
    if (_uid == null) {
      return const Text("Please sign in to view saved addresses.");
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getUserAddresses(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _brand));
        }
        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No saved addresses.", style: TextStyle(color: _textGrey)),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            final isSelected = _selectedAddress != null && _selectedAddress!['id'] == address['id'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? _brandLight : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _brand.withValues(alpha: 0.5) : _borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_off,
                      color: isSelected ? _brand : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _dark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${address['street']}, ${address['city']}, ${address['zip']}\n${address['country']}",
                            style: const TextStyle(color: _textGrey, height: 1.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Phone: ${address['phone']}",
                            style: const TextStyle(color: _textGrey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── STEP 3: PAYMENT ─────────────────────────────────────────────────────────
  Widget _buildPaymentView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Form
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _brandLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.payment_outlined, color: _brand, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dark)),
                  ],
                ),
                const SizedBox(height: 24),
                // Method Tabs
                Row(
                  children: [
                    _paymentTab(Icons.credit_card, 'Saved Cards', PaymentMethod.card),
                    const SizedBox(width: 12),
                    _paymentTab(Icons.add_card, 'New Card', PaymentMethod.upi), // Reuse UPI enum for New Card form to save lines
                    const SizedBox(width: 12),
                    _paymentTab(Icons.local_shipping_outlined, 'Cash on Delivery', PaymentMethod.cod),
                  ],
                ),
                const SizedBox(height: 28),
                const Divider(color: _borderColor),
                const SizedBox(height: 24),
                if (_selectedMethod == PaymentMethod.card) _buildSavedCardsList(),
                if (_selectedMethod == PaymentMethod.upi) _buildAddNewCardForm(),
                if (_selectedMethod == PaymentMethod.cod) _buildCodView(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _completeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: Text(
                      _selectedMethod == PaymentMethod.cod ? 'Place Order' : 'Pay ₹${_total.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Summary
        Expanded(
          flex: 2,
          child: _buildOrderSummaryCard(
            primaryLabel: 'Pay ₹${_total.toInt()}',
            onPrimary: _completeOrder,
          ),
        ),
      ],
    );
  }

  void _completeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please go back and select an address')));
      return;
    }
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    // Save cart items before we clear it
    final List<CartItem> cartItemsFromProvider = List<CartItem>.from(cartProvider.items);
    
    // In case user bypassed normal cart page directly (rare but possible), we map ProductItems back to CartItems if needed.
    // However, the cleanest way is just to read from CartProvider.
    
    final deliveryDetails = {
      'name': _selectedAddress!['name'],
      'phone': _selectedAddress!['phone'],
      'address': _selectedAddress!['street'],
      'city': _selectedAddress!['city'],
      'pincode': _selectedAddress!['zip'],
    };

    String paymentMethodStr = 'COD';
    if (_selectedMethod == PaymentMethod.card && _selectedPaymentMethod != null) {
      paymentMethodStr = '${_selectedPaymentMethod!['type']} ending in ${_selectedPaymentMethod!['last4']}';
    } else if (_selectedMethod == PaymentMethod.upi) {
      paymentMethodStr = 'New Card'; // Just for representation since we don't save it directly here
    }

    await ordersProvider.addOrder(
      cartItems: cartItemsFromProvider.isNotEmpty 
          ? cartItemsFromProvider 
          : widget.cartItems.map<CartItem>((p) => CartItem(product: p, quantity: 1)).toList(),
      totalAmount: _total,
      paymentMethod: paymentMethodStr,
      deliveryDetails: deliveryDetails,
    );

    cartProvider.clearCart();
    setState(() => _currentStep = CheckoutStep.success);
  }

  Widget _paymentTab(IconData icon, String label, PaymentMethod method) {
    final selected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? _brandLight : _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? _brand : _borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? _brand : _textGrey, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? _brand : _textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsList() {
    if (_uid == null) {
      return const Text("Please sign in to view saved cards.");
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getUserPaymentMethods(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _brand));
        }
        final methods = snapshot.data ?? [];
        if (methods.isEmpty) {
          return const Text("No saved cards found. Please select 'New Card' to add one.", style: TextStyle(color: _textGrey));
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            final isSelected = _selectedPaymentMethod != null && _selectedPaymentMethod!['id'] == method['id'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? _brandLight : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _brand.withValues(alpha: 0.5) : _borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_off,
                      color: isSelected ? _brand : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.credit_card, color: _textGrey, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${method['type']} ending in ${method['last4']}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _dark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Expires ${method['expiry']}",
                            style: const TextStyle(color: _textGrey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddNewCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formField('Card Number', controller: _cardNumberCtrl, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _formRow([
          _formField('Expiry Date (MM/YY)', controller: _expiryCtrl),
          _formField('CVV', controller: _cvvCtrl, keyboardType: TextInputType.number),
        ]),
        const SizedBox(height: 16),
        _formField('Name on Card', controller: TextEditingController()),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              if (_uid != null && _cardNumberCtrl.text.isNotEmpty && _expiryCtrl.text.isNotEmpty) {
                String last4 = _cardNumberCtrl.text.length >= 4 
                    ? _cardNumberCtrl.text.substring(_cardNumberCtrl.text.length - 4) 
                    : _cardNumberCtrl.text;
                await _firestoreService.addPaymentMethod(_uid, {
                  'type': 'Visa', // Hardcoded for simplicity here, could be inferred
                  'last4': last4,
                  'expiry': _expiryCtrl.text,
                  'isDefault': false,
                });
                setState(() {
                  _selectedMethod = PaymentMethod.card;
                  _cardNumberCtrl.clear();
                  _expiryCtrl.clear();
                  _cvvCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card Added')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Card', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _brandLight, shape: BoxShape.circle),
            child: const Icon(Icons.local_shipping_outlined, color: _brand, size: 32),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _dark)),
                SizedBox(height: 6),
                Text(
                  'Pay with cash when your order arrives at your doorstep. No additional charges.',
                  style: TextStyle(color: _textGrey, height: 1.5, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 4: SUCCESS ─────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSuccessIcon(),
            const SizedBox(height: 32),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _dark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your jewels are being prepared. You will receive a confirmation email shortly.',
              style: TextStyle(color: _textGrey, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Order Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _orderStat('ORDER ID', '#RD${DateTime.now().millisecond}09X', Icons.tag_outlined)),
                    VerticalDivider(color: Colors.grey.shade200, width: 32),
                    Expanded(child: _orderStat('ESTIMATED DELIVERY', 'In 5-7 Business Days', Icons.local_shipping_outlined)),
                    VerticalDivider(color: Colors.grey.shade200, width: 32),
                    Expanded(child: _orderStat('STATUS', 'Processing', Icons.timelapse_outlined)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Items
            if (widget.cartItems.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Items in your order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _dark)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.cartItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (_, i) {
                    final item = widget.cartItems[i];
                    return Container(
                      width: 150,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: Image.network(item.image, fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(Icons.image_outlined))),
                          const SizedBox(height: 8),
                          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('₹${item.currentPrice.toInt()}',
                              style: const TextStyle(color: _brand, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 16, color: _dark),
                    label: const Text('Continue Shopping', style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesktopOrdersPage())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: const Text('Track My Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _orderStat(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: _textGrey),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 0.8, color: _textGrey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _dark)),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (_, v, _) => Transform.scale(
        scale: v,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _brand.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _brand,
              ),
              child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
