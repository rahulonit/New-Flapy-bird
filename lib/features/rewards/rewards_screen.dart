import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('DAILY REWARDS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/world-atlas.png', fit: BoxFit.cover)),
          Center(
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.pink, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Icons/Daily calender.png', width: 150, errorBuilder: (_,__,___) => const Icon(Icons.calendar_today, size: 100, color: AppColors.pink)),
                  const SizedBox(height: 32),
                  const Text('DAY 1 REWARD', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text('500 COINS', style: TextStyle(fontSize: 32, color: AppColors.gold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                      backgroundColor: AppColors.green,
                    ),
                    onPressed: () async {
                      // Grant reward via EconomyService
                      final economyService = ref.read(economyServiceProvider);
                      final updated = await economyService.grantCoins(500);
                      ref.read(playerSaveProvider.notifier).save(updated);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Claimed 500 Coins!'), backgroundColor: AppColors.green),
                        );
                        context.pop();
                      }
                    },
                    child: const Text('CLAIM', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
