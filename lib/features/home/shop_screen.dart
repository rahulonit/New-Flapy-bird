import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(playerSaveProvider);
    final economyService = ref.watch(economyServiceProvider);
    
    final ownedCharacters = saveAsync.value?.ownedCharacterIds ?? [];
    final ownsNeon = ownedCharacters.contains('neon_bird');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('FLAPVERSE SHOP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                border: Border.all(color: AppColors.cyan, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Coin Chest.png', width: 200),
                  const SizedBox(height: 24),
                  const Text('PREMIUM BIRD SKINS', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      backgroundColor: ownsNeon ? AppColors.secondarySurface : AppColors.gold,
                    ),
                    onPressed: ownsNeon ? null : () async {
                      final updated = await economyService.purchaseCharacter('neon_bird', 500); // 500 Coins
                      if (updated != null) {
                        ref.read(playerSaveProvider.notifier).save(updated);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Purchase Successful!'), backgroundColor: AppColors.green),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Not enough coins!'), backgroundColor: AppColors.pink),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/Coin Chest.png', width: 48), // Assuming coins instead of gems for now
                        const SizedBox(width: 16),
                        Text(ownsNeon ? 'OWNED' : 'BUY NEON BIRD - 500 COINS', style: TextStyle(fontSize: 24, color: ownsNeon ? Colors.white : AppColors.background, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
