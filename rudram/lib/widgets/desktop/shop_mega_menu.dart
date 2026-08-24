import 'package:flutter/material.dart';

class ShopMegaMenu extends StatelessWidget {
  const ShopMegaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border(
          top: BorderSide(color: const Color(0xFF3B82F6), width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: Who we are
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "Who we are"),
                const SizedBox(height: 20),
                _buildMenuItem(context: context, 
                  icon: Icons.star_outline,
                  title: "Vision & Values",
                  subtitle: "Praesent sagittis Curbitur",
                  iconColor: Colors.green.shade100,
                  iconColorForeground: Colors.green,
                ),
                _buildMenuItem(context: context, 
                  icon: Icons.pie_chart_outline,
                  title: "Leadership Team",
                  subtitle: "Lorem ipsum dolor sit met",
                  iconColor: Colors.green.shade50,
                  iconColorForeground: Colors.green,
                ),
                _buildMenuItem(context: context, 
                  icon: Icons.folder_open_outlined,
                  title: "Annual Reports",
                  subtitle: "Quisque sed pretiumonl",
                  iconColor: Colors.green.shade50,
                  iconColorForeground: Colors.green,
                ),
                _buildMenuItem(context: context, 
                  icon: Icons.help_outline,
                  title: "Frequently Asked",
                  subtitle: "Fusce tincias Snsectetur",
                  iconColor: Colors.green.shade50,
                  iconColorForeground: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Column 2: Ready to Get Involved & What We Do
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "Ready to Get Involved"),
                const SizedBox(height: 20),
                _buildMenuItem(context: context, 
                  icon: Icons.volunteer_activism_outlined,
                  title: "Volunteer Opportunities",
                  subtitle: "Oraesent sagittis Curbitur",
                  iconColor: Colors.green.shade50,
                  iconColorForeground: Colors.green,
                ),
                const SizedBox(height: 30),
                _buildSectionHeader(context, "What We Do"),
                const SizedBox(height: 20),
                _buildMenuItem(context: context, 
                  icon: Icons.menu_book_outlined,
                  title: "Programs and Services",
                  subtitle: "Hendrerit vel enim at porta",
                  iconColor: Colors.grey.shade100,
                  iconColorForeground: Colors.grey.shade700,
                ),
                _buildMenuItem(context: context, 
                  icon: Icons.handshake_outlined,
                  title: "Current Active Projects",
                  subtitle: "Tincidunt condmentum risus",
                  iconColor: Colors.grey.shade100,
                  iconColorForeground: Colors.grey.shade700,
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Column 3: Active Campaign Card
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "Active Campaign"),
                const SizedBox(height: 20),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED), // Light orange/beige bg
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400&auto=format&fit=crop', // Charity/Kids image
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Uplifting Every Child's Future",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Column 4: Resources & Contact Us
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "Resources"),
                const SizedBox(height: 20),
                _buildTextLink(context, "Publications"),
                _buildTextLink(context, "Transparency"),
                _buildTextLink(context, "Research & Insights"),
                _buildTextLink(context, "Downloads"),

                const SizedBox(height: 40),

                _buildSectionHeader(context, "Contact Us"),
                const SizedBox(height: 20),
                _buildTextLink(context, "Get in Touch"),
                _buildTextLink(context, "Find Us"),
                _buildTextLink(context, "Support Center"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMenuItem({required BuildContext context, 
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconColorForeground,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColorForeground, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLink(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
