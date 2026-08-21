import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    final bestScore = save?.bestScore ?? 0;
    final rank = (1000 - bestScore ~/ 100).clamp(1, 1000);
    final entries = [
      const _RankEntry(1, 'PLAYERONE', 15400),
      const _RankEntry(2, 'FLAPMASTER', 14200),
      const _RankEntry(3, 'CYBERBIRD', 12800),
      _RankEntry(rank, 'YOU', bestScore, player: true),
    ];
    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(
          save?.selectedWorldId ?? 'default',
        ).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'LEADERBOARD',
              subtitle: 'GLOBAL PILOT RANKINGS',
              coins: save?.coins ?? 0,
              gems: save?.gems ?? 0,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 500,
                    child: Container(
                      padding: const EdgeInsets.all(34),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.gold,
                        opacity: 0.88,
                        glowing: true,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/Icons/Flag.png', height: 230),
                          const SizedBox(height: 24),
                          const Text(
                            'YOUR RANK',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '#$rank',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 92,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _format(bestScore),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'BEST SCORE',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.cyan,
                        opacity: 0.86,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOP PILOTS',
                            style: GameUiDesign.cardTitleStyle,
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < entries.length;
                                  index++
                                ) ...[
                                  Expanded(
                                    child: _RankCard(entry: entries[index]),
                                  ),
                                  if (index != entries.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.entry});
  final _RankEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.player
        ? AppColors.gold
        : entry.rank <= 3
        ? AppColors.cyan
        : AppColors.border;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: GameUiDesign.solidPanelDecoration(accent: color, radius: 22),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: color,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.secondarySurface,
            child: Image.asset(
              entry.player
                  ? 'assets/Icons/Go.png'
                  : 'assets/Icons/Full go with wings.png',
              width: 54,
              height: 54,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Image.asset('assets/Icons/Coin.png', width: 42, height: 42),
          const SizedBox(width: 10),
          Text(
            _format(entry.score),
            style: TextStyle(
              color: entry.player ? AppColors.gold : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankEntry {
  const _RankEntry(this.rank, this.name, this.score, {this.player = false});
  final int rank;
  final String name;
  final int score;
  final bool player;
}

String _format(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);
