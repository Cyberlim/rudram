import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Illustration / Box
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.orange.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.support_agent, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "How can we help you?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Our luxury concierge team is here 24/7.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Contact Options
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      context,
                      "Live Chat",
                      Icons.chat_bubble_outline,
                      Colors.blue,
                      onTap: () async {
                        // Clean phone number - remove spaces, dashes etc
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContactCard(
                      context,
                      "Email Us",
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
                ],
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context,
                "Call $whatsapp",
                Icons.phone_outlined,
                Colors.purple,
                isFullWidth: true,
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

          const SizedBox(height: 32),
          // FAQ Section
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
            ],
          );
        }
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String title, IconData icon, Color color, {bool isFullWidth = false, VoidCallback? onTap}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $title...')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: isFullWidth 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
