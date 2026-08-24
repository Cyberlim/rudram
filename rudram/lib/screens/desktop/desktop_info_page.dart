import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import '../../utils/app_colors.dart';

class DesktopInfoPage extends StatelessWidget {
  const DesktopInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.doc('web_settings/about').get(),
        builder: (context, snapshot) {
          final Map<String, dynamic> data = snapshot.data?.exists == true
              ? snapshot.data!.data() as Map<String, dynamic>
              : {};

          return SingleChildScrollView(
            child: Column(
              children: [
                const DesktopHeader(),
                _buildHeroBanner(data),
                _buildStorySection(data),
                _buildCoreValues(data),
                _buildArtisansSection(data),
                const DesktopFooterSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _get(Map<String, dynamic> data, String key, String fallback) =>
      (data[key] as String?)?.isNotEmpty == true ? data[key] as String : fallback;

  Widget _buildHeroBanner(Map<String, dynamic> data) {
    final image = _get(data, 'heroBannerImage', 'https://images.unsplash.com/photo-1599643478524-fb66f70a9a18?q=80&w=2070');
    final tagline = _get(data, 'heroTagline', 'OUR HERITAGE');
    final title = _get(data, 'heroTitle', 'A Legacy of Trust & Purity');

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/banner_2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tagline,
                style: const TextStyle(letterSpacing: 6, color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorySection(Map<String, dynamic> data) {
    final image = _get(data, 'storyImage', 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=2070');
    final tagline = _get(data, 'storyTagline', 'THE JOURNEY');
    final year = _get(data, 'storyYear', '1985');
    final p1 = _get(data, 'storyParagraph1', 'At Rudram Jewels, we believe in the timeless beauty of handcrafted excellence.');
    final p2 = _get(data, 'storyParagraph2', 'Every piece of jewelry we create is a testament to our commitment to purity.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 120),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(image, height: 500, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tagline, style: const TextStyle(letterSpacing: 4, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(
                  "Crafting Timeless Masterpieces Since $year.",
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 30),
                Text("$p1\n\n$p2", style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValues(Map<String, dynamic> data) {
    final values = [
      {
        'icon': Icons.diamond_outlined,
        'title': _get(data, 'value1Title', 'Uncompromising Purity'),
        'desc': _get(data, 'value1Desc', 'We source only the highest grade precious metals and certified gemstones.'),
      },
      {
        'icon': Icons.handshake_outlined,
        'title': _get(data, 'value2Title', 'Ethical Sourcing'),
        'desc': _get(data, 'value2Desc', 'Our supply chain is fully transparent, ensuring conflict-free and sustainable practices.'),
      },
      {
        'icon': Icons.architecture,
        'title': _get(data, 'value3Title', 'Master Craftsmanship'),
        'desc': _get(data, 'value3Desc', 'Generations of artisanal expertise go into every intricate detail of our designs.'),
      },
      {
        'icon': Icons.support_agent,
        'title': _get(data, 'value4Title', 'Lifetime Support'),
        'desc': _get(data, 'value4Desc', 'We stand by our creations with lifetime maintenance and dedicated customer care.'),
      },
    ];

    return Container(
      color: const Color(0xFFF8F9FA),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 120),
      child: Column(
        children: [
          const Text("OUR PROMISE", style: TextStyle(letterSpacing: 4, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("The Core Values", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: values.map((v) => _buildValueCard(v['icon'] as IconData, v['title'] as String, v['desc'] as String)).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String description) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryOrange),
            ),
            const SizedBox(height: 30),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisansSection(Map<String, dynamic> data) {
    final artisans = [
      {
        'name': _get(data, 'artisan1Name', 'Vikram Singh'),
        'role': _get(data, 'artisan1Role', 'Master Goldsmith'),
        'image': _get(data, 'artisan1Image', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000'),
      },
      {
        'name': _get(data, 'artisan2Name', 'Aarti Sharma'),
        'role': _get(data, 'artisan2Role', 'Lead Designer'),
        'image': _get(data, 'artisan2Image', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1000'),
      },
      {
        'name': _get(data, 'artisan3Name', 'Rajesh Patel'),
        'role': _get(data, 'artisan3Role', 'Gemologist'),
        'image': _get(data, 'artisan3Image', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 120),
      child: Column(
        children: [
          const Text("THE CREATORS", style: TextStyle(letterSpacing: 4, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Meet The Artisans", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Row(
            children: artisans.asMap().entries.map((entry) {
              final a = entry.value;
              return [
                _buildArtisanCard(a['image']!, a['name']!, a['role']!),
                if (entry.key < artisans.length - 1) const SizedBox(width: 40),
              ];
            }).expand((x) => x).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildArtisanCard(String imageUrl, String name, String role) {
    return Expanded(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imageUrl, height: 350, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 350, color: Colors.grey[200])),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(role, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
