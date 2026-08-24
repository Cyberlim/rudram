import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_screen.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 24),
          const StatsGridRow(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 11, child: SalesOverviewCard()),
                SizedBox(width: 24),
                Expanded(flex: 9, child: RecentOrdersTableCard()),
              ],
            )
          else
            Column(
              children: const [
                SalesOverviewCard(),
                SizedBox(height: 24),
                RecentOrdersTableCard(),
              ],
            ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 1, child: EarningsOverviewCard()),
                SizedBox(width: 24),
                Expanded(flex: 1, child: StorePerformanceCard()),
              ],
            )
          else
            Column(
              children: const [
                EarningsOverviewCard(),
                SizedBox(height: 24),
                StorePerformanceCard(),
              ],
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text("Good Morning, Kuldeep! ", style: GoogleFonts.inter(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Text("✨", style: TextStyle(fontSize: isMobile ? 20 : 24)),
              ],
            ),
            const SizedBox(height: 4),
            const Text("Here's what's happening with your store today.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new, size: 16, color: Colors.black87),
              label: const Text("View Store", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text("Add Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A1846),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
              ),
            )
          ],
        )
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// STATS GRID
// ─────────────────────────────────────────────────────────
class StatsGridRow extends StatelessWidget {
  const StatsGridRow({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;
    bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : (isMobile ? 1 : 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 2.2 : (isMobile ? 2.5 : 1.5),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            double totalRevenue = 0;
            int totalOrders = 0;
            Set<String> uniqueCustomers = {};
            
              if (snapshot.hasData) {
              totalOrders = snapshot.data!.docs.length;
              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                if (data['status'] == 'Delivered') {
                  totalRevenue += (data['totalAmount'] ?? 0);
                }
                final customerName = (data['deliveryDetails'] as Map<String, dynamic>?)?['name'] ?? '';
                uniqueCustomers.add(customerName);
              }
            }

            return _buildStatCard(
              "Total Revenue", "₹${totalRevenue.toStringAsFixed(0)}", "+ 18.6% vs last 30 days",
              Icons.currency_rupee, const Color(0xFFF3E8FF), const Color(0xFF9333EA),
            );
          }
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Total Orders", count.toString(), "+ 13.2% vs last 30 days",
              Icons.shopping_cart_outlined, const Color(0xFFFFEDD5), const Color(0xFFEA580C),
            );
          }
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Total Products", count.toString(), "+ 7.4% vs last 30 days",
              Icons.diamond_outlined, const Color(0xFFE0E7FF), const Color(0xFF4F46E5),
            );
          }
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            Set<String> uniqueCustomers = {};
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                final customerName = (data['deliveryDetails'] as Map<String, dynamic>?)?['name'] ?? '';
                uniqueCustomers.add(customerName);
              }
            }
            return _buildStatCard(
              "Total Customers", uniqueCustomers.length.toString(), "+ 16.8% vs last 30 days",
              Icons.people_outline, const Color(0xFFFEF3C7), const Color(0xFFD97706),
            );
          }
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String trend, IconData icon, Color iconBg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(trend, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SALES OVERVIEW CHART
// ─────────────────────────────────────────────────────────
class SalesOverviewCard extends StatelessWidget {
  const SalesOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Sales Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Text("This Month", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text("Total Sales", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹2,45,680", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text("18.6% vs last year", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const labels = ['1 May', '5 May', '10 May', '15 May', '20 May', '25 May', '30 May'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10));
                        if (value == 1) return const Text('50K', style: TextStyle(color: Colors.grey, fontSize: 10));
                        if (value == 2) return const Text('1L', style: TextStyle(color: Colors.grey, fontSize: 10));
                        if (value == 3) return const Text('1.5L', style: TextStyle(color: Colors.grey, fontSize: 10));
                        if (value == 4) return const Text('2L', style: TextStyle(color: Colors.grey, fontSize: 10));
                        if (value == 5) return const Text('2.5L', style: TextStyle(color: Colors.grey, fontSize: 10));
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 0.8),
                      FlSpot(0.5, 2.2),
                      FlSpot(1, 1.2),
                      FlSpot(1.5, 1.6),
                      FlSpot(2, 1.8),
                      FlSpot(2.5, 3.2),
                      FlSpot(3, 3.4),
                      FlSpot(3.5, 2.5),
                      FlSpot(4, 4.2),
                      FlSpot(4.5, 4.5),
                      FlSpot(5, 2.8),
                      FlSpot(5.5, 4.2),
                      FlSpot(6, 4.8),
                    ],
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.3),
                          const Color(0xFF8B5CF6).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RECENT ORDERS TABLE
// ─────────────────────────────────────────────────────────
class RecentOrdersTableCard extends StatelessWidget {
  const RecentOrdersTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("View All Orders", style: TextStyle(color: Colors.purple.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(5).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      
                      return DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                        dataRowHeight: 60,
                        horizontalMargin: 12,
                        columnSpacing: 24,
                        dividerThickness: 0.5,
                        columns: const [
                          DataColumn(label: Text("Order ID", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          DataColumn(label: Text("Customer", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          DataColumn(label: Text("Product", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          DataColumn(label: Text("Amount", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          DataColumn(label: Text("Status", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          DataColumn(label: Text("Date", style: TextStyle(color: Colors.grey, fontSize: 12))),
                        ],
                        rows: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final date = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now();
                          final formattedDate = "${date.day}/${date.month}/${date.year}";
                          
                          MaterialColor statusColor = Colors.orange;
                          if (data['status'] == 'Delivered') statusColor = Colors.green;
                          if (data['status'] == 'Cancelled') statusColor = Colors.red;
                          if (data['status'] == 'Shipped') statusColor = Colors.purple;
                          if (data['status'] == 'Processing') statusColor = Colors.blue;

                          final items = data['items'] as List<dynamic>? ?? [];
                          final productName = items.isNotEmpty ? (items[0]['title'] ?? 'Product') : 'Product';
                          final customerName = (data['deliveryDetails'] as Map<String, dynamic>?)?['name'] ?? 'Unknown';

                          final img = items.isNotEmpty ? (items[0]['image'] ?? '') : '';

                          return _buildOrderRow(
                            data['id'] ?? doc.id,
                            customerName,
                            productName,
                            img,
                            "₹${data['totalAmount'] ?? 0}",
                            data['status'] ?? 'Pending',
                            statusColor,
                            formattedDate
                          );
                        }).toList(),
                      );
                    }
                  ),
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildOrderRow(String id, String customer, String product, String img, String amount, String status, MaterialColor color, String date) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(Text(customer, style: const TextStyle(fontSize: 13))),
        DataCell(Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(6)),
              child: Image.network(img, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Text(product, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        )),
        DataCell(Text(amount, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: color.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM CARDS
// ─────────────────────────────────────────────────────────

class TopSellingCard extends StatelessWidget {
  const TopSellingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Top Selling Products", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("View All", style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').orderBy('soldCount', descending: true).limit(3).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildItem(
                      (index + 1).toString(),
                      data['title'] ?? 'Product',
                      data['category'] ?? 'Category',
                      "₹${data['currentPrice'] ?? 0}",
                      "${data['soldCount'] ?? 0}+ sold",
                      data['image'] ?? ''
                    );
                  },
                );
              }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(String rank, String title, String sub, String price, String sold, String img) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), shape: BoxShape.circle),
          child: Center(child: Text(rank, style: const TextStyle(color: Color(0xFFD97706), fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(8)), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img, fit: BoxFit.cover))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sold, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class LowStockCard extends StatelessWidget {
  const LowStockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Low Stock Alert", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("View All", style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').where('stock', isLessThan: 10).orderBy('stock').limit(3).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildItem(
                      data['title'] ?? 'Product',
                      data['category'] ?? 'Category',
                      "Stock: ${data['stock'] ?? 0}",
                      data['image'] ?? ''
                    );
                  },
                );
              }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(String title, String sub, String stock, String img) {
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(8)), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img, fit: BoxFit.cover))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(stock, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        const Text("Low", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
      ],
    );
  }
}

class EarningsOverviewCard extends StatelessWidget {
  const EarningsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Earnings Overview", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("View All", style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Available Balance", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹1,25,430", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.purple.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text("Withdraw", style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Text("This Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Total Sales", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text("₹2,45,680", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Platform Fee", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text("-₹12,284", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF0F0F0))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Net Earnings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text("₹2,33,396", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class StorePerformanceCard extends StatelessWidget {
  const StorePerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Store Performance", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: const [
                    Text("This Month", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                    Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.grey),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetric(Icons.people_outline, "Visitors", "18,452", "+ 21.3%", const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
              _buildMetric(Icons.visibility_outlined, "Product Views", "32,145", "+ 14.7%", const Color(0xFFECFDF5), const Color(0xFF10B981)),
              _buildMetric(Icons.shopping_cart_outlined, "Add to Cart", "5,632", "+ 11.9%", const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
              _buildMetric(Icons.trending_up, "Conversion Rate", "8.94%", "+ 9.6%", const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String title, String value, String trend, Color bg, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.green, size: 10),
                  const SizedBox(width: 2),
                  Text(trend, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM BANNERS
// ─────────────────────────────────────────────────────────
class BottomBanners extends StatelessWidget {
  const BottomBanners({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    List<Widget> children = [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFFD97706)),
            const SizedBox(width: 12),
            const Expanded(child: Text("Complete your KYC to unlock more features and grow your business.", style: TextStyle(fontSize: 13))),
            if (!isMobile) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A1846), elevation: 0),
                child: const Text("Complete KYC", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 16),
              Text("Learn More →", style: TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
      if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF3E8FF), Colors.white]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.diamond, color: Color(0xFFD97706)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Limited Time Offer", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Add new collection & get 2% extra visibility!", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        children: children,
      );
    }
    return Row(
      children: [
        Expanded(child: children[0]),
        children[1],
        Expanded(child: children[2]),
      ],
    );
  }
}
