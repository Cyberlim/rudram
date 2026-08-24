import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

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
                  Text("Promo & Coupons", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Manage discount codes and promotional offers.", style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Coupon", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
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
                final codes = ["DIWALI20", "NEWUSER50", "FLASH10", "SUMMER15"];
                final discounts = ["20% OFF", "Flat ₹500 OFF", "10% OFF", "15% OFF"];
                final conditions = ["Min. spend ₹5000", "First order only", "No min. spend", "Selected items only"];
                final active = [true, true, false, false];
                final expiry = ["Expires in 5 days", "No expiry", "Expired on May 1st", "Expired on Mar 15th"];
                
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      
                      Widget codeBox = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        decoration: BoxDecoration(
                          color: active[index] ? Colors.purple.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: active[index] ? Colors.purple.withOpacity(0.3) : Colors.grey[300]!, style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Text(
                            codes[index], 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: active[index] ? Colors.purple : Colors.grey, letterSpacing: 2)
                          ),
                        ),
                      );

                      Widget detailsBox = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(discounts[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: active[index] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(active[index] ? "Active" : "Expired", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active[index] ? Colors.green : Colors.red)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(conditions[index], style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(expiry[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      );
                      
                      Widget usageBox = Row(
                        mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Usage", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 4),
                              Text("142 / 500", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 32),
                          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.grey), onPressed: (){})
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            codeBox,
                            const SizedBox(height: 16),
                            detailsBox,
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 8),
                            usageBox,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          codeBox,
                          const SizedBox(width: 24),
                          Expanded(child: detailsBox),
                          usageBox,
                        ],
                      );
                    }
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
