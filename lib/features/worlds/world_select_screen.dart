import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('SELECT WORLD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                _buildWorldCard('CYBER CITY', 'assets/Cyber_city/MetroCity.png', true),
                const SizedBox(width: 32),
                _buildWorldCard('MYSTIC FOREST', 'assets/MysticForest_world_assets/MtsticForest.png', false), // typo in asset name intended
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(String name, String asset, bool unlocked) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.secondarySurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: unlocked ? AppColors.cyan : Colors.grey, width: 4),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.map, size: 100)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.grey, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
