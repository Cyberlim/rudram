import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Messages", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMessageItem(
                "Neha Sharma",
                "Hi, is the Gold Necklace customizable?",
                "10 mins ago",
                true,
                "https://images.weserv.nl/?url=https://i.pravatar.cc/150?img=1"
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildMessageItem(
                "Rahul Verma",
                "Thanks! I received the order today. It's beautiful.",
                "2 hours ago",
                false,
                "https://images.weserv.nl/?url=https://i.pravatar.cc/150?img=11"
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildMessageItem(
                "Aarti Singh",
                "Can you expedite the shipping for my order #ORD-1890?",
                "Yesterday",
                false,
                "https://images.weserv.nl/?url=https://i.pravatar.cc/150?img=5"
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(String name, String message, String time, bool isUnread, String avatarUrl) {
    return Container(
      color: isUnread ? Colors.purple.withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
          radius: 24,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(name, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey, fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal)),
        ),
        trailing: isUnread ? Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
        ) : null,
      ),
    );
  }
}
