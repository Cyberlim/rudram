import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Reviews", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Manage your store's reputation and customer feedback.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          Builder(
            builder: (context) {
              bool isMobile = MediaQuery.of(context).size.width < 800;
              List<Widget> children = [
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Text("4.8", style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.amber : Colors.amber.withOpacity(0.5), size: 24)),
                      ),
                      const SizedBox(height: 8),
                      const Text("Based on 124 reviews", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                isMobile ? const SizedBox(height: 24) : const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _buildRatingBar(5, 0.8),
                      const SizedBox(height: 8),
                      _buildRatingBar(4, 0.15),
                      const SizedBox(height: 8),
                      _buildRatingBar(3, 0.03),
                      const SizedBox(height: 8),
                      _buildRatingBar(2, 0.01),
                      const SizedBox(height: 8),
                      _buildRatingBar(1, 0.01),
                    ],
                  ),
                ),
              ];
              
              if (isMobile) {
                return Column(children: children);
              }
              return Row(
                children: [
                  Expanded(child: children[0]),
                  children[1],
                  Expanded(flex: 2, child: children[2]),
                ],
              );
            }
          ),
          
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final names = ["Neha Sharma", "Aarti Singh", "Rohan Das", "Pooja Patel"];
                final products = ["Gold Necklace", "Diamond Ring", "Silver Bracelet", "Gold Earrings"];
                final reviews = [
                  "Absolutely stunning piece! The craftsmanship is incredible and it arrived much earlier than expected.",
                  "Very beautiful, but the size was slightly smaller than I anticipated. Still, great quality.",
                  "Perfect gift for my anniversary. The packaging was very premium.",
                  "I wear these every day. They haven't lost their shine at all!"
                ];
                final ratings = [5, 4, 5, 5];
                
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage("https://images.weserv.nl/?url=https://i.pravatar.cc/150?img=${index + 1}"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Text("2 days ago", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < ratings[index] ? Colors.amber : Colors.grey[300])),
                            ),
                            const SizedBox(height: 12),
                            Text(reviews[index], style: const TextStyle(color: Colors.black87, height: 1.5)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                              child: Text("Purchased: ${products[index]}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text("$stars star", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            color: Colors.amber,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text("${(percentage * 100).toInt()}%", style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}
