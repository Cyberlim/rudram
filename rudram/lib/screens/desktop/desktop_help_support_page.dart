import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/desktop/desktop_header.dart';

class DesktopHelpSupportPage extends StatelessWidget {
  const DesktopHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const DesktopHeader(cartCount: 0),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('settings').doc('support').snapshots(),
                    builder: (context, snapshot) {
                      String whatsapp = "+9118001234567";
                      String email = "support@rudram.com";
                      
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null) {
                          if (data['whatsapp'] != null && data['whatsapp'].toString().isNotEmpty) {
                            whatsapp = data['whatsapp'];
                          }
                          if (data['email'] != null && data['email'].toString().isNotEmpty) {
                            email = data['email'];
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Help & Support",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Hero Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber.shade300, Colors.orange.shade500],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.support_agent, size: 80, color: Colors.white),
                                SizedBox(height: 24),
                                Text(
                                  "How can we help you?",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Our luxury concierge team is here 24/7 to assist you with any inquiries.",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 48),

                          Text(
                            "Contact Us",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildContactCard(
                                  context,
                                  "Live Chat",
                                  "Chat on WhatsApp",
                                  Icons.chat_bubble_outline,
                                  Colors.blue,
                                  onTap: () async {
                                    final cleanPhone = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
                                    final uri = Uri.parse("https://wa.me/$cleanPhone");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
                                      }
                                    }
                                  }
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildContactCard(
                                  context,
                                  "Email Us",
                                  email,
                                  Icons.email_outlined,
                                  Colors.green,
                                  onTap: () async {
                                    final uri = Uri.parse("mailto:$email");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open email app')));
                                      }
                                    }
                                  }
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildContactCard(
                                  context,
                                  "Call Us",
                                  whatsapp,
                                  Icons.phone_outlined,
                                  Colors.purple,
                                  onTap: () async {
                                    final uri = Uri.parse("tel:$whatsapp");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open phone app')));
                                      }
                                    }
                                  }
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),

                          Text(
                            "Frequently Asked Questions",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildFAQItem(
                            context,
                            "How do I track my luxury order?",
                            "You can track your order in the 'My Orders' section of your profile. A tracking link is also sent to your registered email once the item ships.",
                          ),
                          _buildFAQItem(
                            context,
                            "What is your return policy?",
                            "We offer a 14-day return policy for all unaltered jewelry. Custom and engraved pieces are final sale.",
                          ),
                          _buildFAQItem(
                            context,
                            "Do you offer lifetime warranty?",
                            "Yes! All Rudram pieces come with a lifetime warranty for cleaning, polishing, and prong tightening.",
                          ),
                          _buildFAQItem(
                            context,
                            "Is the shipping insured?",
                            "Absolutely. Every shipment is fully insured until it is signed for by you at your delivery address.",
                          ),
                          
                          const SizedBox(height: 80),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
