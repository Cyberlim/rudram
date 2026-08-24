import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Advanced Analytics", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Dive deep into your store's performance metrics.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Process orders into weekly data (mocking the last 7 days for simplicity)
              List<double> weeklyRevenue = List.filled(7, 0.0);
              int totalOrders = 0;
              double totalRevenue = 0;

              if (snapshot.hasData) {
                final now = DateTime.now();
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['status'] == 'Delivered') {
                    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                    totalRevenue += amount;
                    totalOrders++;

                    if (data['createdAt'] != null) {
                      final date = (data['createdAt'] as Timestamp).toDate();
                      final diff = now.difference(date).inDays;
                      if (diff >= 0 && diff < 7) {
                        weeklyRevenue[6 - diff] += amount;
                      }
                    }
                  }
                }
              }

              return Column(
                children: [
                  Builder(
                    builder: (context) {
                      bool isMobile = MediaQuery.of(context).size.width < 800;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildMetricCard("Weekly Revenue", "₹${weeklyRevenue.reduce((a,b)=>a+b).toStringAsFixed(0)}", Icons.trending_up, Colors.green),
                            const SizedBox(height: 16),
                            _buildMetricCard("Completed Orders", "$totalOrders", Icons.check_circle_outline, Colors.blue),
                            const SizedBox(height: 16),
                            _buildMetricCard("Conversion Rate", "4.2%", Icons.pie_chart_outline, Colors.purple),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildMetricCard("Weekly Revenue", "₹${weeklyRevenue.reduce((a,b)=>a+b).toStringAsFixed(0)}", Icons.trending_up, Colors.green)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildMetricCard("Completed Orders", "$totalOrders", Icons.check_circle_outline, Colors.blue)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildMetricCard("Conversion Rate", "4.2%", Icons.pie_chart_outline, Colors.purple)),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Revenue Over Last 7 Days", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (weeklyRevenue.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(days[value.toInt() % 7], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(7, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: weeklyRevenue[i],
                                      color: Colors.purple,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }
}
