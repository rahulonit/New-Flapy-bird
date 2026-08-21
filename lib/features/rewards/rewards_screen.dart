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
        'PLAY 5 GAMES',
        'assets/Icons/Go.png',
        save?.missionCounters['games'] ?? 0,
        5,
      ),
      _RewardTask(
        'PASS 10 OBSTACLES',
        'assets/Icons/Flag.png',
        save?.missionCounters['obstacles'] ?? 0,
        10,
      ),
      _RewardTask(
        'COLLECT 30 COINS',
        'assets/Icons/Coin.png',
        save?.missionCounters['coins'] ?? 0,
        30,
      ),
    ];
    final weeklyTasks = [
      _RewardTask(
        'PLAY 30 GAMES',
        'assets/Icons/Go.png',
        save?.weeklyMissionCounters['games'] ?? 0,
        30,
      ),
      _RewardTask(
        'PASS 300 OBSTACLES',
        'assets/Icons/Flag.png',
        save?.weeklyMissionCounters['obstacles'] ?? 0,
        300,
      ),
      _RewardTask(
        'SCORE 100,000 POINTS',
        'assets/Icons/Full go with wings.png',
        save?.weeklyMissionCounters['score'] ?? 0,
        100000,
      ),
      _RewardTask(
        'COLLECT 300 COINS',
        'assets/Icons/Coin.png',
        save?.weeklyMissionCounters['coins'] ?? 0,
        300,
      ),
    ];
    final dailyReady = dailyTasks.every((task) => task.complete);
    final weeklyReady = weeklyTasks.every((task) => task.complete);
    final selectedTasks = _selectedTab == 0 ? dailyTasks : weeklyTasks;
    final selectedClaimed = _selectedTab == 0 ? dailyClaimed : weeklyClaimed;
    final selectedReady = _selectedTab == 0 ? dailyReady : weeklyReady;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(world.backgroundAsset, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99020B20), Color(0xB8051A3A)],
              ),
            ),
          ),
          SafeArea(
            left: false,
            right: false,
            child: Center(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: GameUiDesign.canvasWidth,
                  height: GameUiDesign.canvasHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(GameUiDesign.pageMargin),
                    child: Column(
                      children: [
                        _Header(
                          coins: save?.coins ?? 0,
                          gems: save?.gems ?? 0,
                          onBack: () => context.pop(),
                        ),
                        const SizedBox(height: 24),
                        _Tabs(
                          selected: _selectedTab,
                          dailyAvailable: dailyReady && !dailyClaimed,
                          weeklyAvailable: weeklyReady && !weeklyClaimed,
                          onSelected: (tab) =>
                              setState(() => _selectedTab = tab),
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
                                  completed: selectedTasks
                                      .where((task) => task.complete)
                                      .length,
                                  total: selectedTasks.length,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _RoundIconButton(onTap: onBack),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('REWARD CENTER', style: GameUiDesign.homeHeaderPrimaryStyle),
            Text(
              'COMPLETE TASKS • EARN PRIZES',
              style: GameUiDesign.homeEyebrowStyle,
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Wallet(asset: 'assets/Icons/Coin.png', value: coins),
              const SizedBox(width: 16),
              _Wallet(asset: 'assets/Icons/Dimond.png', value: gems),
            ],
          ),
        ),
      ],
    ),
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
    height: 88,
    width: 720,
    padding: const EdgeInsets.all(8),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: AppColors.border,
      radius: GameUiDesign.radiusPill,
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
        const SizedBox(width: 10),
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
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(GameUiDesign.radiusPill),
        child: Ink(
          decoration: BoxDecoration(
            gradient: active ? GameUiDesign.primaryGradient : null,
            color: active ? null : AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(GameUiDesign.radiusPill),
            border: Border.all(
              color: active ? AppColors.cyan : AppColors.border,
              width: 3,
            ),
            boxShadow: active ? GameUiDesign.glow(AppColors.cyan) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, width: 42, height: 42, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Text(label, style: GameUiDesign.homeTabStyle),
              if (available) ...[
                const SizedBox(width: 12),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
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
            style: GameUiDesign.homeEyebrowStyle,
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
  });
  final bool daily;
  final List<_RewardTask> tasks;
  final bool claimed;
  final VoidCallback onPlay;

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
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
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
          child: Column(
            children: [
              for (var index = 0; index < tasks.length; index++) ...[
                Expanded(
                  child: _TaskCard(task: tasks[index], number: index + 1),
                ),
                if (index != tasks.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        if (claimed) ...[
          const SizedBox(height: 18),
          const Center(
            child: Text(
              '✓ BONUS COLLECTED — COME BACK NEXT RESET',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.number});
  final _RewardTask task;
  final int number;

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
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${task.shownCurrent} / ${task.formattedTarget}',
                    style: TextStyle(
                      color: task.complete ? AppColors.green : AppColors.gold,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
      ],
    ),
  );
}

class _RewardTask {
  const _RewardTask(this.label, this.asset, this.current, this.target);
  final String label;
  final String asset;
  final int current;
  final int target;
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
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
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ],
  );
}

class _Wallet extends StatelessWidget {
  const _Wallet({required this.asset, required this.value});
  final String asset;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    constraints: const BoxConstraints(minWidth: 220),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: GameUiDesign.homeHeaderDecoration(),
    child: Row(
      children: [
        Image.asset(asset, width: 82, height: 82),
        const SizedBox(width: 12),
        Text(
          _RewardTask._format(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: Ink(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: GameUiDesign.primaryGradient,
        border: Border.all(color: AppColors.cyan, width: 3),
        boxShadow: GameUiDesign.glow(AppColors.cyan),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset('assets/Icons/back.png', fit: BoxFit.contain),
      ),
    ),
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}
