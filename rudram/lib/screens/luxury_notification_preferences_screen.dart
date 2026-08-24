import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class LuxuryNotificationPreferencesScreen extends StatefulWidget {
  const LuxuryNotificationPreferencesScreen({super.key});

  @override
  State<LuxuryNotificationPreferencesScreen> createState() => _LuxuryNotificationPreferencesScreenState();
}

class _LuxuryNotificationPreferencesScreenState extends State<LuxuryNotificationPreferencesScreen> {
  bool _emailOffers = true;
  bool _smsUpdates = false;
  bool _conciergeAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final auth = context.read<AppAuthProvider>();
    if (auth.user != null) {
      final profile = await FirestoreService().getUserProfile(auth.user!.uid);
      if (profile != null && mounted) {
        setState(() {
          _emailOffers = profile['luxuryEmailOffers'] ?? true;
          _smsUpdates = profile['luxurySmsUpdates'] ?? false;
          _conciergeAlerts = profile['luxuryConciergeAlerts'] ?? true;
        });
      }
    }
  }

  Future<void> _savePreference({bool? email, bool? sms, bool? concierge}) async {
    final auth = context.read<AppAuthProvider>();
    if (auth.user != null) {
      await FirestoreService().updateUserProfile(
        uid: auth.user!.uid,
        luxuryEmailOffers: email,
        luxurySmsUpdates: sms,
        luxuryConciergeAlerts: concierge,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSwitchTile("Exclusive Offers (Email)", "Receive early access to new collections.", _emailOffers, (v) {
              setState(() => _emailOffers = v);
              _savePreference(email: v);
            }),
            const Divider(color: Colors.grey, height: 32),
            _buildSwitchTile("Order Updates (SMS)", "Get real-time tracking for luxury deliveries.", _smsUpdates, (v) {
              setState(() => _smsUpdates = v);
              _savePreference(sms: v);
            }),
            const Divider(color: Colors.grey, height: 32),
            _buildSwitchTile("Concierge Alerts", "Messages from your personal luxury advisor.", _conciergeAlerts, (v) {
              setState(() => _conciergeAlerts = v);
              _savePreference(concierge: v);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFD4AF37),
      contentPadding: EdgeInsets.zero,
    );
  }
}
