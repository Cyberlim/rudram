import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class LuxuryShippingAddressesScreen extends StatefulWidget {
  const LuxuryShippingAddressesScreen({super.key});

  @override
  State<LuxuryShippingAddressesScreen> createState() => _LuxuryShippingAddressesScreenState();
}

class _LuxuryShippingAddressesScreenState extends State<LuxuryShippingAddressesScreen> {
  final _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  void _showAddAddressSheet() {
    final formKey = GlobalKey<FormState>();
    String name = "";
    String street = "";
    String city = "";
    String zip = "";
    String country = "";
    String phone = "";
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
                          color: Color(0xFFD4AF37),
                          fontFamily: 'Playfair Display',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Full Name"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Street Address"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => street = val!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration("City"),
                              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                              onSaved: (val) => city = val!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration("ZIP Code"),
                              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                              onSaved: (val) => zip = val!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Country"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => country = val!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Phone Number"),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        onSaved: (val) => phone = val!,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Set as Default", style: TextStyle(color: Colors.white)),
                        value: isDefault,
                        onChanged: (val) => setSheetState(() => isDefault = val),
                        activeThumbColor: const Color(0xFFD4AF37),
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
                                await _firestoreService.addAddress(_uid, {
                                  'name': name,
                                  'street': street,
                                  'city': city,
                                  'zip': zip,
                                  'country': country,
                                  'phone': phone,
                                  'isDefault': isDefault,
                                });
                              }
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text("SAVE ADDRESS", style: TextStyle(fontWeight: FontWeight.bold)),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          "Shipping Addresses",
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
            Expanded(
              child: _uid == null
                  ? const Center(child: Text("Please sign in.", style: TextStyle(color: Colors.white)))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestoreService.getUserAddresses(_uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                        }
                        final addresses = snapshot.data ?? [];
                        if (addresses.isEmpty) {
                          return const Center(
                            child: Text("No saved addresses.", style: TextStyle(color: Colors.grey)),
                          );
                        }
                        return ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address = addresses[index];
                            final isDefault = address['isDefault'] == true;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDefault ? const Color(0xFFD4AF37) : Colors.grey[800]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (isDefault)
                                        const Text(
                                          "DEFAULT ADDRESS",
                                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 1),
                                        )
                                      else
                                        const SizedBox(),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                        onPressed: () {
                                          _firestoreService.removeAddress(_uid, address['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                  if (isDefault) const SizedBox(height: 12),
                                  Text(
                                    address['name'] ?? 'Name',
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(address['street'] ?? '', style: const TextStyle(color: Colors.grey)),
                                  Text("${address['city'] ?? ''}, ${address['zip'] ?? ''}", style: const TextStyle(color: Colors.grey)),
                                  Text(address['country'] ?? '', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text(address['phone'] ?? '', style: const TextStyle(color: Colors.grey)),
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
              onPressed: _showAddAddressSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("ADD NEW ADDRESS", style: TextStyle(color: Colors.white)),
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
