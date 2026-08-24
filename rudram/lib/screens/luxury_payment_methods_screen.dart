import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class LuxuryPaymentMethodsScreen extends StatefulWidget {
  const LuxuryPaymentMethodsScreen({super.key});

  @override
  State<LuxuryPaymentMethodsScreen> createState() => _LuxuryPaymentMethodsScreenState();
}

class _LuxuryPaymentMethodsScreenState extends State<LuxuryPaymentMethodsScreen> {
  final _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  void _showAddPaymentMethodSheet() {
    final formKey = GlobalKey<FormState>();
    String cardType = "Visa";
    String cardNumber = "";
    String expiry = "";
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
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
                        color: Color(0xFFD4AF37),
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: cardType,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Card Type",
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                      ),
                      items: ["Visa", "Mastercard", "American Express"].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => cardType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Card Number (Last 4 digits)",
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                      ),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Expiry Date (MM/YY)",
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        return null;
                      },
                      onSaved: (val) => expiry = val!,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Set as Default", style: TextStyle(color: Colors.white)),
                      value: isDefault,
                      onChanged: (val) => setSheetState(() => isDefault = val),
                      activeColor: const Color(0xFFD4AF37),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: const Text("SAVE PAYMENT METHOD", style: TextStyle(fontWeight: FontWeight.bold)),
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

  String _getCardIconUrl(String type) {
    switch (type.toLowerCase()) {
      case 'mastercard':
        return "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1000px-Mastercard-logo.svg.png";
      case 'visa':
        return "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2000px-Visa_Inc._logo.svg.png";
      case 'american express':
        return "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/American_Express_logo.svg/1000px-American_Express_logo.svg.png";
      default:
        return "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1000px-Mastercard-logo.svg.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          "Payment Methods",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SAVED CARDS",
              style: TextStyle(
                color: Color(0xFFD4AF37),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _uid == null
                  ? const Center(child: Text("Please sign in.", style: TextStyle(color: Colors.white)))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestoreService.getUserPaymentMethods(_uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                        }
                        final methods = snapshot.data ?? [];
                        if (methods.isEmpty) {
                          return const Center(
                            child: Text("No saved payment methods.", style: TextStyle(color: Colors.grey)),
                          );
                        }
                        return ListView.builder(
                          itemCount: methods.length,
                          itemBuilder: (context, index) {
                            final method = methods[index];
                            final isDefault = method['isDefault'] == true;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDefault ? const Color(0xFFD4AF37) : Colors.grey[800]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Image.network(
                                    _getCardIconUrl(method['type'] ?? 'Visa'),
                                    width: 40,
                                    errorBuilder: (c, e, s) => const Icon(Icons.credit_card, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method['type'] ?? 'Card',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "•••• ${method['last4'] ?? '****'}",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        if (method['expiry'] != null)
                                          Text(
                                            "Expires: ${method['expiry']}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isDefault)
                                    const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                      onPressed: () {
                                        _firestoreService.removePaymentMethod(_uid, method['id']);
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _showAddPaymentMethodSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("ADD NEW PAYMENT METHOD", style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
