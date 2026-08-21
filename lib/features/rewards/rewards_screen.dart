import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _selectedTab = 0;
  bool _claiming = false;

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _weekKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final weekOne = firstThursday.subtract(
      Duration(days: firstThursday.weekday - DateTime.monday),
    );
    final week = (thursday.difference(weekOne).inDays ~/ 7) + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerSaveProvider.notifier).ensureDailyReset();
    });
    final saveAsync = ref.watch(playerSaveProvider);
    final save = saveAsync.value;
    final world = worldById(save?.selectedWorldId ?? 'default');
    final now = DateTime.now();
    final dailyClaimed = save?.lastDailyRewardDate == _dayKey(now);
    final weeklyClaimed = save?.lastWeeklyRewardKey == _weekKey(now);
    final dailyTasks = [
      _RewardTask(
        'PLAY 10 GAMES',
        'assets/Icons/Go.png',
        save?.missionCounters['games'] ?? 0,
        10,
      ),
      _RewardTask(
        'PASS 100 OBSTACLES',
        'assets/Icons/Flag.png',
        save?.missionCounters['obstacles'] ?? 0,
        100,
      ),
      _RewardTask(
        'COLLECT 100 COINS',
        'assets/Icons/Coin.png',
        save?.missionCounters['coins'] ?? 0,
        100,
      ),
      _RewardTask(
        'WATCH 10 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save?.missionCounters['ads'] ?? 0,
        10,
        rewardId: 'ads',
        coinReward: 100,
        claimed: save?.claimedMissionIds.contains('ads') ?? false,
      ),
      _RewardTask(
        'WATCH 20 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save?.missionCounters['ads'] ?? 0,
        20,
        rewardId: 'ads_20',
        progressKey: 'ads',
        coinReward: 150,
        gemReward: 5,
        claimed: save?.claimedMissionIds.contains('ads_20') ?? false,
      ),
    ];
    final weeklyTasks = [
      _RewardTask(
        'PLAY 200 GAMES',
        'assets/Icons/Go.png',
        save?.weeklyMissionCounters['games'] ?? 0,
        200,
      ),
      _RewardTask(
        'PASS 700 OBSTACLES',
        'assets/Icons/Flag.png',
        save?.weeklyMissionCounters['obstacles'] ?? 0,
        700,
      ),
      _RewardTask(
        'SCORE 300,000 POINTS',
        'assets/Icons/Full go with wings.png',
        save?.weeklyMissionCounters['score'] ?? 0,
        300000,
      ),
      _RewardTask(
        'COLLECT 700 COINS',
        'assets/Icons/Coin.png',
        save?.weeklyMissionCounters['coins'] ?? 0,
        700,
      ),
      _RewardTask(
        'WATCH 140 REWARDED ADS',
        'assets/Icons/vidoe2x.png',
        save?.weeklyMissionCounters['ads'] ?? 0,
        140,
        rewardId: 'ads',
        coinReward: 1000,
        gemReward: 50,
        weekly: true,
        claimed: save?.claimedWeeklyMissionIds.contains('ads') ?? false,
      ),
    ];
    final dailyBonusTasks = dailyTasks.where((task) => !task.individualReward);
    final weeklyBonusTasks = weeklyTasks.where(
      (task) => !task.individualReward,
    );
    final dailyReady = dailyBonusTasks.every((task) => task.complete);
    final weeklyReady = weeklyBonusTasks.every((task) => task.complete);
    final selectedTasks = _selectedTab == 0 ? dailyTasks : weeklyTasks;
    final selectedClaimed = _selectedTab == 0 ? dailyClaimed : weeklyClaimed;
    final selectedReady = _selectedTab == 0 ? dailyReady : weeklyReady;
    final selectedBonusTasks = _selectedTab == 0
        ? dailyBonusTasks.toList()
        : weeklyBonusTasks.toList();

    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: world.backgroundAsset,
        blurBackground: true,
        child: Column(
          children: [
            _Header(
              coins: save?.coins ?? 0,
              gems: save?.gems ?? 0,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: GameUiDesign.space4),
            _Tabs(
              selected: _selectedTab,
              dailyAvailable: dailyReady && !dailyClaimed,
              weeklyAvailable: weeklyReady && !weeklyClaimed,
              onSelected: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 610,
                    child: _RewardSummary(
                      daily: _selectedTab == 0,
                      artwork: _selectedTab == 0
                          ? world.homeCheckAsset
                          : 'assets/Icons/Gift box.png',
                      claimed: selectedClaimed,
                      ready: selectedReady,
                      claiming: _claiming || saveAsync.isLoading,
                      completed: selectedBonusTasks
                          .where((task) => task.complete)
                          .length,
                      total: selectedBonusTasks.length,
                      onClaim: _claim,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: _TaskList(
                      daily: _selectedTab == 0,
                      tasks: selectedTasks,
                      claimed: selectedClaimed,
                      onPlay: () => context.push('/play'),
                      onClaimMission: _claimMission,
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

  Future<void> _claim() async {
    if (_claiming) return;
    setState(() => _claiming = true);
    final daily = _selectedTab == 0;
    final notifier = ref.read(playerSaveProvider.notifier);
    final granted = daily
        ? await notifier.claimDailyReward()
        : await notifier.claimWeeklyReward();
    if (!mounted) return;
    setState(() => _claiming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? daily
                    ? 'DAILY REWARD: +200 COINS'
                    : 'WEEKLY REWARD: +1,500 COINS  +50 DIAMONDS'
              : 'Complete every task before claiming this reward.',
        ),
        backgroundColor: granted ? AppColors.green : AppColors.pink,
      ),
    );
  }

  Future<void> _claimMission(_RewardTask task) async {
    if (task.rewardId == null || _claiming) return;
    setState(() => _claiming = true);
    final notifier = ref.read(playerSaveProvider.notifier);
    final granted = task.weekly
        ? await notifier.claimWeeklyMission(
            task.progressKey,
            task.target,
            task.coinReward,
            gems: task.gemReward,
          )
        : await notifier.claimMission(
            task.rewardId!,
            task.target,
            task.coinReward,
            gems: task.gemReward,
            progressKey: task.progressKey,
          );
    if (!mounted) return;
    setState(() => _claiming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? '+${task.coinReward} COINS${task.gemReward > 0 ? '  +${task.gemReward} DIAMONDS' : ''}'
              : 'MISSION REWARD IS NOT READY',
        ),
        backgroundColor: granted ? AppColors.green : AppColors.pink,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.coins,
    required this.gems,
    required this.onBack,
  });
  final int coins;
  final int gems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => GameScreenHeader(
    title: 'REWARD CENTER',
    subtitle: 'COMPLETE TASKS - EARN PRIZES',
    coins: coins,
    gems: gems,
    onBack: onBack,
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.dailyAvailable,
    required this.weeklyAvailable,
    required this.onSelected,
  });
  final int selected;
  final bool dailyAvailable;
  final bool weeklyAvailable;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 108,
    width: 920,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(GameUiDesign.radiusLarge),
      border: Border.all(color: AppColors.cyan, width: 4),
      boxShadow: GameUiDesign.glow(AppColors.cyan),
    ),
    child: Row(
      children: [
        Expanded(
          child: _tab(
            'DAILY',
            'assets/Icons/Daily calender.png',
            0,
            dailyAvailable,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _tab(
            'WEEKLY',
            'assets/Icons/Weekly calender.png',
            1,
            weeklyAvailable,
          ),
        ),
      ],
    ),
  );

  Widget _tab(String label, String asset, int value, bool available) {
    final active = selected == value;
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(value),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: active ? GameUiDesign.primaryGradient : null,
              color: active ? null : AppColors.surface.withValues(alpha: .38),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: active
                    ? AppColors.gold
                    : AppColors.border.withValues(alpha: .5),
                width: active ? 4 : 2,
              ),
              boxShadow: active ? GameUiDesign.glow(AppColors.gold) : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      asset,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$label REWARDS',
                      style: GameUiDesign.tabLabelStyle.copyWith(
                        color: active ? Colors.white : AppColors.mutedText,
                      ),
                    ),
                    if (available) ...[
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'READY',
                          style: GameUiDesign.itemMetadataStyle,
                        ),
                      ),
                    ],
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: active ? 130 : 0,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardSummary extends StatelessWidget {
  const _RewardSummary({
    required this.daily,
    required this.artwork,
    required this.claimed,
    required this.ready,
    required this.claiming,
    required this.completed,
    required this.total,
    required this.onClaim,
  });
  final bool daily;
  final String artwork;
  final bool claimed;
  final bool ready;
  final bool claiming;
  final int completed;
  final int total;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final accent = claimed
        ? AppColors.green
        : daily
        ? AppColors.cyan
        : AppColors.purple;
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: GameUiDesign.panelDecoration(
        accent: accent,
        opacity: 0.88,
        radius: 28,
        glowing: ready && !claimed,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                daily ? 'DAILY BONUS' : 'WEEKLY BONUS',
                style: GameUiDesign.cardTitleStyle,
              ),
              _StatusBadge(claimed: claimed, ready: ready),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Image.asset(
                artwork,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.card_giftcard, size: 210, color: accent),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Prize(
                asset: 'assets/Icons/Coin.png',
                value: daily ? '200' : '1,500',
                label: 'COINS',
              ),
              if (!daily) ...[
                const SizedBox(width: 36),
                const _Prize(
                  asset: 'assets/Icons/Dimond.png',
                  value: '50',
                  label: 'DIAMONDS',
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation(
              ready ? AppColors.green : AppColors.cyan,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed OF $total TASKS COMPLETE',
            style: GameUiDesign.itemMetadataStyle.copyWith(
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 22),
          _ClaimButton(
            claimed: claimed,
            ready: ready,
            loading: claiming,
            onTap: onClaim,
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.daily,
    required this.tasks,
    required this.claimed,
    required this.onPlay,
    required this.onClaimMission,
  });
  final bool daily;
  final List<_RewardTask> tasks;
  final bool claimed;
  final VoidCallback onPlay;
  final ValueChanged<_RewardTask> onClaimMission;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(30),
    decoration: GameUiDesign.panelDecoration(
      accent: AppColors.cyan,
      opacity: 0.86,
      radius: 28,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  daily ? 'TODAY\'S TASKS' : 'THIS WEEK\'S TASKS',
                  style: GameUiDesign.cardTitleStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  daily ? 'Resets every day' : 'Resets every Monday',
                  style: GameUiDesign.itemMetadataStyle.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _TaskTypeBadge(
                      label: 'BONUS REQUIREMENT',
                      color: AppColors.cyan,
                    ),
                    SizedBox(width: 10),
                    _TaskTypeBadge(
                      label: 'EXTRA REWARD',
                      color: AppColors.purple,
                    ),
                  ],
                ),
              ],
            ),
            _MetalButton(
              label: 'PLAY NOW',
              asset: 'assets/Icons/Go.png',
              onTap: onPlay,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GameScrollArea(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(right: GameUiDesign.space3),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) => SizedBox(
                height: 128,
                child: _TaskCard(
                  task: tasks[index],
                  number: index + 1,
                  onClaim: () => onClaimMission(tasks[index]),
                ),
              ),
            ),
          ),
        ),
        if (claimed) ...[
          const SizedBox(height: 18),
          Center(
            child: Text(
              'BONUS COLLECTED - COME BACK NEXT RESET',
              style: GameUiDesign.itemMetadataStyle.copyWith(
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _TaskTypeBadge extends StatelessWidget {
  const _TaskTypeBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color, width: 2),
    ),
    child: Text(
      label,
      style: GameUiDesign.itemMetadataStyle.copyWith(
        color: color,
        fontSize: 15,
      ),
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.number,
    required this.onClaim,
  });
  final _RewardTask task;
  final int number;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: task.complete ? AppColors.green : AppColors.border,
        width: 3,
      ),
      boxShadow: task.complete
          ? GameUiDesign.glow(AppColors.green)
          : GameUiDesign.panelShadow,
    ),
    child: Row(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            gradient: task.complete
                ? const LinearGradient(
                    colors: [AppColors.green, Color(0xFF168A10)],
                  )
                : GameUiDesign.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: task.complete
              ? const Icon(Icons.check, color: Colors.white, size: 38)
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(task.asset, fit: BoxFit.contain),
                ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'TASK $number',
                    style: GameUiDesign.itemMetadataStyle.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TaskTypeBadge(
                    label: task.individualReward ? 'EXTRA' : 'BONUS',
                    color: task.individualReward
                        ? AppColors.purple
                        : AppColors.cyan,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GameUiDesign.itemLabelStyle,
                    ),
                  ),
                  Text(
                    '${task.shownCurrent} / ${task.formattedTarget}',
                    style: GameUiDesign.itemMetadataStyle.copyWith(
                      color: task.complete ? AppColors.green : AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: task.progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation(
                  task.complete ? AppColors.green : AppColors.cyan,
                ),
              ),
            ],
          ),
        ),
        if (task.individualReward) ...[
          const SizedBox(width: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Icons/Coin.png', width: 34, height: 34),
              Text(
                '${task.coinReward}',
                style: GameUiDesign.itemMetadataStyle.copyWith(
                  color: AppColors.gold,
                ),
              ),
              if (task.gemReward > 0) ...[
                const SizedBox(width: 8),
                Image.asset('assets/Icons/Dimond.png', width: 32, height: 32),
                Text(
                  '${task.gemReward}',
                  style: GameUiDesign.itemMetadataStyle.copyWith(
                    color: AppColors.purple,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 145,
            height: 54,
            child: ElevatedButton(
              onPressed: task.claimed || !task.complete ? null : onClaim,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  task.claimed
                      ? 'CLAIMED'
                      : task.complete
                      ? 'CLAIM'
                      : 'LOCKED',
                  style: GameUiDesign.itemMetadataStyle,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _RewardTask {
  const _RewardTask(
    this.label,
    this.asset,
    this.current,
    this.target, {
    this.rewardId,
    this.progressKey = 'ads',
    this.coinReward = 0,
    this.gemReward = 0,
    this.weekly = false,
    this.claimed = false,
  });
  final String label;
  final String asset;
  final int current;
  final int target;
  final String? rewardId;
  final String progressKey;
  final int coinReward;
  final int gemReward;
  final bool weekly;
  final bool claimed;
  bool get individualReward => rewardId != null;
  bool get complete => current >= target;
  double get progress => (current / target).clamp(0, 1).toDouble();
  String get shownCurrent => _format(current.clamp(0, target));
  String get formattedTarget => _format(target);
  static String _format(int value) {
    final text = value.toString();
    return text.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.claimed, required this.ready});
  final bool claimed;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = claimed
        ? AppColors.green
        : ready
        ? AppColors.gold
        : AppColors.primaryBlue;
    final label = claimed
        ? 'CLAIMED'
        : ready
        ? 'READY!'
        : 'IN PROGRESS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GameUiDesign.glow(color),
      ),
      child: Text(label, style: GameUiDesign.itemMetadataStyle),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.claimed,
    required this.ready,
    required this.loading,
    required this.onTap,
  });
  final bool claimed;
  final bool ready;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: ready && !claimed && !loading,
    child: GestureDetector(
      onTap: ready && !claimed && !loading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: ready && !claimed ? GameUiDesign.goldGradient : null,
          color: ready && !claimed ? null : AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ready && !claimed ? Colors.white : AppColors.border,
            width: 4,
          ),
          boxShadow: ready && !claimed
              ? GameUiDesign.glow(AppColors.gold)
              : GameUiDesign.panelShadow,
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    claimed
                        ? Icons.check_circle
                        : ready
                        ? Icons.card_giftcard
                        : Icons.lock,
                    size: 38,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    claimed
                        ? 'REWARD CLAIMED'
                        : ready
                        ? 'CLAIM REWARD'
                        : 'COMPLETE ALL TASKS',
                    style: GameUiDesign.itemLabelStyle,
                  ),
                ],
              ),
      ),
    ),
  );
}

class _Prize extends StatelessWidget {
  const _Prize({required this.asset, required this.value, required this.label});
  final String asset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(asset, width: 66, height: 66),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GameUiDesign.cardHeadingStyle.copyWith(
              color: AppColors.gold,
            ),
          ),
          Text(label, style: GameUiDesign.itemMetadataStyle),
        ],
      ),
    ],
  );
}

class _MetalButton extends StatelessWidget {
  const _MetalButton({
    required this.label,
    required this.asset,
    required this.onTap,
  });
  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(28),
    child: Ink(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: GameUiDesign.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cyan, width: 3),
        boxShadow: GameUiDesign.glow(AppColors.cyan),
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 34, height: 34, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Text(label, style: GameUiDesign.itemMetadataStyle),
        ],
      ),
    ),
  );
}
