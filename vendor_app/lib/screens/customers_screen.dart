import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer Directory", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("View and manage your loyal customer base.", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.download, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text("Export", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: Text("No customers found.", style: TextStyle(color: Colors.grey))),
                  );
                }

                // Aggregate orders by customer
                Map<String, Map<String, dynamic>> customerStats = {};
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['deliveryDetails'] as Map<String, dynamic>?)?['name'] ?? 'Unknown';
                  final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
                  
                  if (!customerStats.containsKey(name)) {
                    customerStats[name] = {'orders': 0, 'totalSpent': 0.0};
                  }
                  
                  customerStats[name]!['orders'] += 1;
                  customerStats[name]!['totalSpent'] += amount;
                }

                final customers = customerStats.entries.toList()
                  ..sort((a, b) => b.value['totalSpent'].compareTo(a.value['totalSpent']));

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final name = customer.key;
                    final ordersCount = customer.value['orders'];
                    final totalSpent = customer.value['totalSpent'];
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: Text(name.isNotEmpty ? name[0] : 'U', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Lifetime Value: ₹${totalSpent.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("$ordersCount Orders", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 16),
                          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.grey), onPressed: () {}),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
