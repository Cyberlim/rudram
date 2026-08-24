import 'dart:async';
import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'product_card.dart';

class DealsOfTheDaySection extends StatefulWidget {
  const DealsOfTheDaySection({super.key});

  @override
  State<DealsOfTheDaySection> createState() => _DealsOfTheDaySectionState();
}

class _DealsOfTheDaySectionState extends State<DealsOfTheDaySection> {
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 5, minutes: 23, seconds: 45);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                "Deals of the Day",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(_timeLeft),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 310,
          child: StreamBuilder<List<ProductItem>>(
            stream: FirestoreService().getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const Center(
                  child: Text("No deals today", style: TextStyle(color: Colors.grey)),
                );
              }
              
              // For "deals", maybe just reverse or take a subset
              final deals = products.reversed.take(5).toList();

              return ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  return SizedBox(width: 160, child: ProductCard(product: deals[index]));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
