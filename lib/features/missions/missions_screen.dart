import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  bool weekly = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerSaveProvider.notifier).ensureDailyReset();
    });
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dailyMissions = [
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
      _Mission(
        'ads',
        'WATCH 10 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save.missionCounters['ads'] ?? 0,
        10,
        100,
      ),
      _Mission(
        'ads_20',
        'WATCH 20 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save.missionCounters['ads'] ?? 0,
        20,
        150,
        rewardGems: 5,
        progressKey: 'ads',
      ),
    ];
    final weeklyMissions = [
      _Mission(
        'ads',
        'WATCH 140 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save.weeklyMissionCounters['ads'] ?? 0,
        140,
        1000,
        rewardGems: 50,
        weekly: true,
      ),
    ];
    final missions = weekly ? weeklyMissions : dailyMissions;
    final completed = missions.where((mission) => mission.complete).length;

    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'MISSIONS',
              subtitle: 'DAILY & WEEKLY OBJECTIVES',
              coins: save.coins,
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: GameUiDesign.space4),
            _MissionTabs(
              weekly: weekly,
              onChanged: (value) => setState(() => weekly = value),
            ),
            const SizedBox(height: GameUiDesign.space3),
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
                          weekly
                              ? 'assets/Icons/Weekly calender.png'
                              : 'assets/Icons/Daily calender.png',
                          width: 78,
                          height: 78,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weekly
                                    ? 'THIS WEEK\'S MISSION BOARD'
                                    : 'TODAY\'S MISSION BOARD',
                                style: GameUiDesign.cardTitleStyle,
                              ),
                              Text(
                                weekly
                                    ? 'Resets every Monday.'
                                    : 'Resets every day.',
                                style: GameUiDesign.itemMetadataStyle.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$completed / ${missions.length} COMPLETE',
                          style: GameUiDesign.itemLabelStyle.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GameScrollArea(
                        builder: (context, controller) => ListView.separated(
                          controller: controller,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 24),
                          itemCount: missions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            final claimed = mission.weekly
                                ? save.claimedWeeklyMissionIds.contains(
                                    mission.id,
                                  )
                                : save.claimedMissionIds.contains(mission.id);
                            return SizedBox(
                              height: 150,
                              child: _MissionCard(
                                mission: mission,
                                claimed: claimed,
                                onGo: () => context.push('/play'),
                                onClaim: () => _claim(mission),
                              ),
                            );
                          },
                        ),
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

  Future<void> _claim(_Mission mission) async {
    final notifier = ref.read(playerSaveProvider.notifier);
    final success = mission.weekly
        ? await notifier.claimWeeklyMission(
            mission.progressKey,
            mission.target,
            mission.reward,
            gems: mission.rewardGems,
          )
        : await notifier.claimMission(
            mission.id,
            mission.target,
            mission.reward,
            gems: mission.rewardGems,
            progressKey: mission.progressKey,
          );
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+${mission.reward} COINS${mission.rewardGems > 0 ? '  +${mission.rewardGems} DIAMONDS' : ''}',
        ),
        backgroundColor: AppColors.green,
      ),
    );
  }
}

class _MissionTabs extends StatelessWidget {
  const _MissionTabs({required this.weekly, required this.onChanged});
  final bool weekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    width: 720,
    height: 90,
    padding: const EdgeInsets.all(7),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: AppColors.cyan,
      radius: GameUiDesign.radiusPill,
    ),
    child: Row(
      children: [
        Expanded(
          child: _tab(false, 'DAILY', 'assets/Icons/Daily calender.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _tab(true, 'WEEKLY', 'assets/Icons/Weekly calender.png'),
        ),
      ],
    ),
  );

  Widget _tab(bool value, String label, String asset) {
    final active = weekly == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(GameUiDesign.radiusPill),
      child: Ink(
        decoration: BoxDecoration(
          gradient: active ? GameUiDesign.primaryGradient : null,
          borderRadius: BorderRadius.circular(GameUiDesign.radiusPill),
          border: Border.all(
            color: active ? AppColors.gold : AppColors.border,
            width: active ? 4 : 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: 46, height: 46),
            const SizedBox(width: 14),
            Text(label, style: GameUiDesign.tabLabelStyle),
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
                Text(mission.label, style: GameUiDesign.cardHeadingStyle),
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
                        style: GameUiDesign.itemMetadataStyle.copyWith(
                          color: AppColors.cyan,
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
                style: GameUiDesign.itemLabelStyle.copyWith(
                  color: AppColors.gold,
                ),
              ),
              if (mission.rewardGems > 0) ...[
                const SizedBox(width: 14),
                Image.asset('assets/Icons/Dimond.png', width: 42, height: 42),
                const SizedBox(width: 6),
                Text(
                  '${mission.rewardGems}',
                  style: GameUiDesign.itemLabelStyle.copyWith(
                    color: AppColors.purple,
                  ),
                ),
              ],
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
                style: GameUiDesign.itemLabelStyle,
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
    this.reward, {
    this.rewardGems = 0,
    this.weekly = false,
    String? progressKey,
  }) : progressKey = progressKey ?? id;
  final String id;
  final String label;
  final String asset;
  final int current;
  final int target;
  final int reward;
  final int rewardGems;
  final bool weekly;
  final String progressKey;
  bool get complete => current >= target;
  double get progress => (current / target).clamp(0, 1).toDouble();
  String get shownCurrent => _format(current.clamp(0, target));
  String get formattedTarget => _format(target);
  static String _format(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
