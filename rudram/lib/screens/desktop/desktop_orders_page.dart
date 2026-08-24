import 'package:flutter/material.dart';
import '../../models/data_models.dart';
import '../../widgets/desktop/desktop_header.dart';
import 'desktop_order_detail_page.dart';

class DesktopOrdersPage extends StatefulWidget {
  const DesktopOrdersPage({super.key});

  @override
  State<DesktopOrdersPage> createState() => _DesktopOrdersPageState();
}

class _DesktopOrdersPageState extends State<DesktopOrdersPage> {
  String _selectedStatus = "On Shipping";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          const DesktopHeader(cartCount: 0),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 100,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Orders",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSidebar(),
                      const SizedBox(width: 40),
                      Expanded(child: _buildOrdersList()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStatusItem("On Shipping", 2),
          _buildStatusItem("Arrived", 2),
          _buildStatusItem("Canceled", 1),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, int count) {
    bool isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Column(
      children: [
        _buildOrderCard("CTH-89765"),
        const SizedBox(height: 25),
        _buildOrderCard("CTH-81719"),
      ],
    );
  }

  Widget _buildOrderCard(String orderId) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order ID",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Estimated arrival 28 May 2024",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "On Deliver",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Icon(
                Icons.location_city_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text(
                "Illinois, United States",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "-----------",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                "George's House, Indonesia",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildOrderItem(globalShopProducts[0]),
          const SizedBox(height: 15),
          _buildOrderItem(globalShopProducts[1]),
          const Divider(height: 60),
          Row(
            children: [
              Text(
                "Total: ₹849.000 (2 Items)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DesktopOrderDetailPage(orderId: orderId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(ProductItem item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(item.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "₹${item.currentPrice.toInt()}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const Text(
                  "M",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
