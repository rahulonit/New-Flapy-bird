import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    final bestScore = save?.bestScore ?? 0;
    
    // Simple mock rank calculation
    int rank = 1000 - (bestScore ~/ 100);
    if (rank < 1) rank = 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('GLOBAL LEADERBOARD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                border: Border.all(color: AppColors.gold, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRankRow(1, 'PlayerOne', 15400),
                  const Divider(color: AppColors.border, height: 24, thickness: 2),
                  _buildRankRow(2, 'FlapMaster', 14200),
                  const Divider(color: AppColors.border, height: 24, thickness: 2),
                  _buildRankRow(3, 'CyberBird', 12800),
                  const Divider(color: AppColors.border, height: 24, thickness: 2),
                  _buildRankRow(rank, 'You', bestScore, isCurrentPlayer: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankRow(int rank, String name, int score, {bool isCurrentPlayer = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('#$rank', style: TextStyle(color: isCurrentPlayer ? AppColors.gold : AppColors.cyan, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 32),
            Text(name, style: TextStyle(color: isCurrentPlayer ? AppColors.gold : Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
        Text('$score', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
