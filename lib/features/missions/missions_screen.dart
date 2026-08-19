import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(playerSaveProvider);
    final save = saveAsync.value;
    if (save == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Dummy logic for extracting real mission stats out of the save
    final gamesPlayed = save.totalRuns; // Simplification
    final score = save.bestScore; 
    
    // Using hardcoded targets but mapping to actual save stats
    final play3GamesProgress = gamesPlayed.clamp(0, 3);
    final passObstaclesProgress = (gamesPlayed * 5).clamp(0, 50); // mock calculation
    final scoreProgress = score.clamp(0, 10000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('DAILY MISSIONS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
              width: 800,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cyan, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMissionRow('Play 3 Games', play3GamesProgress, 3, 100),
                  const Divider(color: AppColors.border, height: 48, thickness: 2),
                  _buildMissionRow('Pass 50 Obstacles', passObstaclesProgress, 50, 250),
                  const Divider(color: AppColors.border, height: 48, thickness: 2),
                  _buildMissionRow('Score 10,000 Points', scoreProgress, 10000, 500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow(String title, int current, int target, int reward) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Progress: $current / $target', style: const TextStyle(color: AppColors.cyan, fontSize: 24)),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          onPressed: current >= target ? () {} : null, // Would call EconomyService to grant coins here
          child: Text('CLAIM $reward', style: const TextStyle(fontSize: 24, color: AppColors.background, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}
