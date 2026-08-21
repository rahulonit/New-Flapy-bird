import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerSaveProvider.notifier).ensureDailyReset();
    });
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final missions = [
      _Mission(
        'games',
        'PLAY 3 GAMES',
        'assets/Icons/Go.png',
        save.missionCounters['games'] ?? 0,
        3,
        100,
      ),
      _Mission(
        'obstacles',
        'PASS 50 OBSTACLES',
        'assets/Icons/Flag.png',
        save.missionCounters['obstacles'] ?? 0,
        50,
        250,
      ),
      _Mission(
        'score',
        'SCORE 10,000 POINTS',
        'assets/Icons/Full go with wings.png',
        save.missionCounters['score'] ?? 0,
        10000,
        500,
      ),
    ];
    final completed = missions.where((mission) => mission.complete).length;

    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'MISSIONS',
              subtitle: 'DAILY FLIGHT OBJECTIVES',
              coins: save.coins,
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(34),
                decoration: GameUiDesign.panelDecoration(
                  accent: AppColors.cyan,
                  opacity: 0.86,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/Icons/Daily calender.png',
                          width: 78,
                          height: 78,
                        ),
                        const SizedBox(width: 18),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TODAY\'S MISSION BOARD',
                                style: GameUiDesign.cardTitleStyle,
                              ),
                              Text(
                                'Complete objectives and claim coin rewards.',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$completed / ${missions.length} COMPLETE',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < missions.length;
                            index++
                          ) ...[
                            Expanded(
                              child: _MissionCard(
                                mission: missions[index],
                                claimed: save.claimedMissionIds.contains(
                                  missions[index].id,
                                ),
                                onGo: () => context.push('/play'),
                                onClaim: () async {
                                  final mission = missions[index];
                                  final success = await ref
                                      .read(playerSaveProvider.notifier)
                                      .claimMission(
                                        mission.id,
                                        mission.target,
                                        mission.reward,
                                      );
                                  if (context.mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '+${mission.reward} COINS',
                                        ),
                                        backgroundColor: AppColors.green,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            if (index != missions.length - 1)
                              const SizedBox(height: 18),
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
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.claimed,
    required this.onGo,
    required this.onClaim,
  });
  final _Mission mission;
  final bool claimed;
  final VoidCallback onGo;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final accent = claimed
        ? AppColors.green
        : mission.complete
        ? AppColors.gold
        : AppColors.border;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: GameUiDesign.solidPanelDecoration(accent: accent, radius: 24),
      child: Row(
        children: [
          Image.asset(
            mission.asset,
            width: GameUiDesign.menuIconSize,
            height: GameUiDesign.menuIconSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: mission.progress,
                        minHeight: 14,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation(
                          mission.complete ? AppColors.green : AppColors.cyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 170,
                      child: Text(
                        '${mission.shownCurrent} / ${mission.formattedTarget}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          Row(
            children: [
              Image.asset('assets/Icons/Coin.png', width: 46, height: 46),
              const SizedBox(width: 8),
              Text(
                '${mission.reward}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 28),
          SizedBox(
            width: 230,
            height: 74,
            child: ElevatedButton(
              onPressed: claimed
                  ? null
                  : mission.complete
                  ? onClaim
                  : onGo,
              style: ElevatedButton.styleFrom(
                backgroundColor: mission.complete
                    ? AppColors.green
                    : AppColors.primaryBlue,
              ),
              child: Text(
                claimed
                    ? 'CLAIMED'
                    : mission.complete
                    ? 'CLAIM'
                    : 'GO',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mission {
  const _Mission(
    this.id,
    this.label,
    this.asset,
    this.current,
    this.target,
    this.reward,
  );
  final String id;
  final String label;
  final String asset;
  final int current;
  final int target;
  final int reward;
  bool get complete => current >= target;
  double get progress => (current / target).clamp(0, 1).toDouble();
  String get shownCurrent => _format(current.clamp(0, target));
  String get formattedTarget => _format(target);
  static String _format(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
