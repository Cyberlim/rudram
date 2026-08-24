import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../services/firestore_service.dart';
import 'order_success_screen.dart';

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

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Map<String, dynamic>? _selectedAddress;
  Map<String, dynamic>? _selectedPaymentMethod;
  String _fallbackPaymentMethod = 'COD'; // Used if user hasn't selected a saved method

  @override
  void initState() {
    super.initState();
    // Pre-select default address and payment method if available
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

  void _placeOrder(CartProvider cart) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final ordersProvider = Provider.of<OrdersProvider>(
      context,
      listen: false,
    );

    // Save cart items and total before clearing
    final List<CartItem> orderItems = List<CartItem>.from(cart.items);
    final orderTotal = cart.total;

    final deliveryDetails = {
      'name': _selectedAddress!['name'],
      'phone': _selectedAddress!['phone'],
      'address': _selectedAddress!['street'],
      'city': _selectedAddress!['city'],
      'pincode': _selectedAddress!['zip'],
    };

    String paymentMethodStr = 'COD';
    if (_selectedPaymentMethod != null) {
      paymentMethodStr = '${_selectedPaymentMethod!['type']} ending in ${_selectedPaymentMethod!['last4']}';
    } else {
      paymentMethodStr = _fallbackPaymentMethod;
    }

    // Save order to local storage
    await ordersProvider.addOrder(
      cartItems: orderItems,
      totalAmount: orderTotal,
      paymentMethod: paymentMethodStr,
      deliveryDetails: deliveryDetails,
    );

    // Clear cart after order
    cart.clearCart();

    // Navigate to success screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderItems: orderItems,
            totalAmount: orderTotal,
          ),
        ),
      );
    }
  }

  void _showAddAddressSheet() {
    final formKey = GlobalKey<FormState>();
    String name = "";
    String street = "";
    String city = "";
    String zip = "";
    String state = _indiaStates.keys.first;
    String phone = "";
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ADD NEW ADDRESS",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: _inputDecoration("Full Name"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration("Street Address"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => street = val!,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration("State"),
                        initialValue: state,
                        items: _indiaStates.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              state = val;
                              city = _indiaStates[val]!.first; // Reset city on state change
                            });
                          }
                        },
                        onSaved: (val) => state = val!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: _inputDecoration("District / City"),
                              initialValue: _indiaStates[state]!.contains(city) ? city : _indiaStates[state]!.first,
                              items: _indiaStates[state]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(() {
                                    city = val;
                                  });
                                }
                              },
                              onSaved: (val) => city = val!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: _inputDecoration("ZIP Code"),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                              onSaved: (val) => zip = val!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _inputDecoration("Phone Number"),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Required";
                          if (val.length != 10) return "Enter 10 digit number";
                          return null;
                        },
                        onSaved: (val) => phone = val!,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Set as Default"),
                        value: isDefault,
                        onChanged: (val) => setSheetState(() => isDefault = val),
                        activeThumbColor: AppColors.primaryOrange,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              if (_uid != null) {
                                await _firestoreService.addAddress(_uid, {
                                  'name': name,
                                  'street': street,
                                  'city': city,
                                  'zip': zip,
                                  'country': state,
                                  'phone': phone,
                                  'isDefault': isDefault,
                                });
                              }
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text("SAVE ADDRESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPaymentMethodSheet() {
    final formKey = GlobalKey<FormState>();
    String cardType = "Visa";
    String cardNumber = "";
    String expiry = "";
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ADD NEW PAYMENT METHOD",
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: cardType,
                      dropdownColor: Colors.white,
                      decoration: _inputDecoration("Card Type"),
                      items: ["Visa", "Mastercard", "American Express"].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => cardType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration("Card Number (Last 4 digits)"),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: (val) {
                        if (val == null || val.trim().length != 4) return "Enter 4 digits";
                        return null;
                      },
                      onSaved: (val) => cardNumber = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration("Expiry Date (MM/YY)"),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        return null;
                      },
                      onSaved: (val) => expiry = val!,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Set as Default"),
                      value: isDefault,
                      onChanged: (val) => setSheetState(() => isDefault = val),
                      activeThumbColor: AppColors.primaryOrange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            if (_uid != null) {
                              await _firestoreService.addPaymentMethod(_uid, {
                                'type': cardType,
                                'last4': cardNumber,
                                'expiry': expiry,
                                'isDefault': isDefault,
                              });
                            }
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text("SAVE PAYMENT METHOD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryOrange),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                _buildSectionTitle('Order Items'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: cart.items.map((item) {
                      return _buildOrderItem(item);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Delivery Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Delivery Details'),
                    TextButton.icon(
                      onPressed: _showAddAddressSheet,
                      icon: const Icon(Icons.add, color: AppColors.primaryOrange, size: 20),
                      label: const Text(
                        "Add New",
                        style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAddressesSection(),

                const SizedBox(height: 24),

                // Payment Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Payment Method'),
                    TextButton.icon(
                      onPressed: _showAddPaymentMethodSheet,
                      icon: const Icon(Icons.add, color: AppColors.primaryOrange, size: 20),
                      label: const Text(
                        "Add Card",
                        style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPaymentMethodsSection(),

                const SizedBox(height: 24),

                // Price Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('Subtotal', cart.subtotal),
                      const SizedBox(height: 12),
                      _buildPriceRow('Tax (GST 18%)', cart.tax),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Shipping',
                        cart.shipping,
                        isFree: cart.shipping == 0,
                      ),
                      const Divider(height: 24),
                      _buildPriceRow('Total', cart.total, isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressesSection() {
    if (_uid == null) {
      return const Text("Please sign in to view saved addresses.");
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getUserAddresses(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No saved addresses.", style: TextStyle(color: Colors.grey)),
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
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primaryOrange : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${address['street']}, ${address['city']}, ${address['zip']}\n${address['country']}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Phone: ${address['phone']}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

  Widget _buildPaymentMethodsSection() {
    if (_uid == null) {
      return const Text("Please sign in to view saved payment methods.");
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getUserPaymentMethods(_uid),
      builder: (context, snapshot) {
        final methods = snapshot.data ?? [];
        
        return Column(
          children: [
            // Always show COD
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = null;
                  _fallbackPaymentMethod = 'COD';
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_selectedPaymentMethod == null && _fallbackPaymentMethod == 'COD') 
                        ? AppColors.primaryOrange 
                        : Colors.grey.shade300,
                    width: (_selectedPaymentMethod == null && _fallbackPaymentMethod == 'COD') ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      (_selectedPaymentMethod == null && _fallbackPaymentMethod == 'COD') 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_off,
                      color: (_selectedPaymentMethod == null && _fallbackPaymentMethod == 'COD') ? AppColors.primaryOrange : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.money, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text(
                      'Cash on Delivery',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            
            // Saved Cards
            if (methods.isNotEmpty)
              ListView.builder(
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
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.primaryOrange : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.credit_card, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${method['type']} ending in ${method['last4']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Expires ${method['expiry']}",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isFree = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade700,
          ),
        ),
        Text(
          isFree ? 'FREE' : '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isFree
                ? Colors.green
                : isTotal
                ? AppColors.primaryOrange
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

