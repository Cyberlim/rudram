import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/desktop/desktop_header.dart';

class DesktopNotificationsPage extends StatelessWidget {
  const DesktopNotificationsPage({super.key});

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays == 1) {
      return '1 day ago';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inHours == 1) {
      return '1 hour ago';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order': return Icons.local_shipping_outlined;
      case 'promo': return Icons.discount_outlined;
      case 'system': return Icons.info_outline;
      case 'payment': return Icons.receipt_long_outlined;
      default: return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'order': return Colors.green;
      case 'promo': return Colors.amber;
      case 'system': return Colors.blue;
      case 'payment': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AppAuthProvider>().user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Column(
          children: [
            const DesktopHeader(cartCount: 0),
            const Expanded(
              child: Center(child: Text("Please sign in to view notifications")),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const DesktopHeader(cartCount: 0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().getUserNotifications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final notifications = snapshot.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Notifications",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  await FirestoreService().markAllNotificationsAsRead(user.uid);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("All marked as read")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.done_all, color: Color(0xFF4F46E5)),
                                label: const Text(
                                  "Mark all as read",
                                  style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          if (notifications.isEmpty)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text("No new notifications"),
                            ))
                          else
                            ...notifications.map((notif) {
                              final isUnread = !(notif['isRead'] ?? true);
                              final type = notif['type'] ?? 'system';
                              final color = _getColorForType(type);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isUnread
                                      ? (isDark ? Colors.grey.shade900 : Colors.grey.shade50)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isUnread
                                        ? color.withValues(alpha: 0.5)
                                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                                  ),
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(24),
                                  onTap: () {
                                    if (isUnread) {
                                      FirestoreService().markNotificationAsRead(notif['id']);
                                    }
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(_getIconForType(type), color: color, size: 28),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif['title'] ?? 'Notification',
                                          style: TextStyle(
                                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                            fontSize: 18,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif['message'] ?? '',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            height: 1.5,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _formatTime(notif['createdAt'] as Timestamp?),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
