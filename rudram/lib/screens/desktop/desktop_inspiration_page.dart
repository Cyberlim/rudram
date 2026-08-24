import 'package:flutter/material.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';

class DesktopInspirationPage extends StatelessWidget {
  const DesktopInspirationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(),
            _buildMoodBoard(),
            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBoard() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Text(
                "CURATED COLLECTIONS",
                style: TextStyle(letterSpacing: 4, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                "Style Inspiration",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: MasonryGrid(),
        ),
      ],
    );
  }
}

class MasonryGrid extends StatelessWidget {
  const MasonryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6d/46/6c/6d466c1653457173155f9ce0d286ed5a.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/ed/4b/0e/ed4b0e814a770d0f1c07dc02a07735b8.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/df/ef/a5/dfefa5d5dbfd0d4cc1987d8e7d77fe9a.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/7f/c9/67/7fc9678798dd797a2c39410e0595d7fb.jpg',
      'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/fc/ea/ab/fceaab40d8b3cc9fa5f5d9f5887d7b93.jpg',
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: images
          .map(
            (url) => Container(
              width: 400,
              height: 300 + (images.indexOf(url) % 2 == 0 ? 100 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
