import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class CharacterSelectScreen extends ConsumerWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(playerSaveProvider);
    final ownedCharacters = saveAsync.value?.ownedCharacterIds ?? [];
    final ownsNeon = ownedCharacters.contains('neon_bird');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('SELECT CHARACTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCharCard('CLASSIC', 'assets/flying-bird-3d-flap.png', true),
                const SizedBox(width: 32),
                _buildCharCard('NEON BIRD', 'assets/neon-bird-cutout.png', ownsNeon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharCard(String name, String asset, bool unlocked) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.secondarySurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: unlocked ? AppColors.gold : Colors.grey, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, height: 150, errorBuilder: (_,__,___) => const Icon(Icons.person, size: 100)),
          const SizedBox(height: 32),
          Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.grey, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (!unlocked)
            const Text('LOCKED', style: TextStyle(color: AppColors.pink, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
