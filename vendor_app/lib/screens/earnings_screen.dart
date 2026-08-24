import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Earnings & Payouts", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Track your completed sales and revenue.", style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                label: const Text("Request Payout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'Delivered').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              double totalEarnings = 0;
              final docs = snapshot.hasData ? snapshot.data!.docs : [];
              
              for (var doc in docs) {
                totalEarnings += (doc.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Earnings Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A1846), Color(0xFF4C2B7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          "₹${totalEarnings.toStringAsFixed(0)}",
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildMiniStat("Completed Sales", "${docs.length}"),
                            const SizedBox(width: 48),
                            _buildMiniStat("Next Payout", "₹0"),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Transactions List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: docs.isEmpty 
                      ? const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Center(child: Text("No earnings yet.", style: TextStyle(color: Colors.grey))),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final amount = data['totalAmount'] ?? 0;
                            final date = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now();
                            
                            final items = data['items'] as List<dynamic>? ?? [];
                            final productName = items.isNotEmpty ? (items[0]['title'] ?? 'Product') : 'Product';

                            return ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.1),
                                child: const Icon(Icons.arrow_downward, color: Colors.green),
                              ),
                              title: Text("Sale: $productName", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Completed on ${date.day}/${date.month}/${date.year}"),
                              trailing: Text("+ ₹$amount", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                            );
                          },
                        ),
                  )
                ],
              );
            }
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
