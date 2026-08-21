import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';
import '../../domain/player_level.dart';
import '../../domain/player_save.dart';
import '../../domain/profile_content.dart';
import '../../domain/trail_content.dart';
import '../trails/trail_preview.dart';
import 'profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value ?? const PlayerSave();
    final level = PlayerLevelProgress.fromSave(save);

    return Scaffold(
      body: Stack(
        children: [
          GameScreenBackground(
            asset: worldById(save.selectedWorldId).backgroundAsset,
          ),
          SafeArea(
            left: false,
            right: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenAspect =
                    constraints.maxWidth / constraints.maxHeight;
                final logicalWidth = screenAspect > (16 / 9)
                    ? GameUiDesign.canvasHeight * screenAspect
                    : GameUiDesign.canvasWidth;
                return Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: logicalWidth,
                      height: GameUiDesign.canvasHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(GameUiDesign.pageMargin),
                        child: Column(
                          children: [
                            GameScreenHeader(
                              title: 'PLAYER PROFILE',
                              subtitle: 'PILOT STATS & CUSTOMIZATION',
                              coins: save.coins,
                              gems: save.gems,
                              onBack: () => context.pop(),
                            ),
                            const SizedBox(height: GameUiDesign.space4),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 560,
                                    child: _ProfileSummary(
                                      save: save,
                                      level: level,
                                    ),
                                  ),
                                  const SizedBox(width: GameUiDesign.space4),
                                  Expanded(
                                    child: _CustomizationPanel(
                                      save: save,
                                      onAvatarSelected: (id) => ref
                                          .read(playerSaveProvider.notifier)
                                          .selectProfileAvatar(id),
                                      onFrameSelected: (id) => ref
                                          .read(playerSaveProvider.notifier)
                                          .selectProfileFrame(id),
                                      onTrailSelected: (id) => ref
                                          .read(playerSaveProvider.notifier)
                                          .selectTrail(id),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.save, required this.level});
  final PlayerSave save;
  final PlayerLevelProgress level;

  @override
  Widget build(BuildContext context) => GameGlassPanel(
    opacity: GameUiDesign.glassOpacity,
    child: Column(
      children: [
        ProfileAvatar(
          avatarId: save.selectedProfileAvatarId,
          frameId: save.selectedProfileFrameId,
          size: 280,
        ),
        const Text('PLAYER ONE', style: GameUiDesign.homeHeaderPrimaryStyle),
        Text('LEVEL ${level.level}', style: GameUiDesign.screenSubtitleStyle),
        const SizedBox(height: GameUiDesign.space2),
        LinearProgressIndicator(
          value: level.progress,
          minHeight: 16,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: AppColors.background,
          valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
        ),
        const SizedBox(height: GameUiDesign.space1),
        Text(
          level.level >= PlayerLevelProgress.maxLevel
              ? 'MAX LEVEL'
              : '${level.currentLevelXp} / ${level.nextLevelXp} XP',
          style: GameUiDesign.itemLabelStyle.copyWith(
            color: AppColors.mutedText,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: GameUiDesign.space3),
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.15,
            crossAxisSpacing: GameUiDesign.space2,
            mainAxisSpacing: GameUiDesign.space2,
            children: [
              _StatTile('BEST SCORE', '${save.bestScore}', AppColors.gold),
              _StatTile('TOTAL RUNS', '${save.totalRuns}', AppColors.cyan),
              _StatTile('COINS', '${save.coins}', AppColors.gold),
              _StatTile('DIAMONDS', '${save.gems}', AppColors.pink),
              _StatTile(
                'CHARACTERS',
                '${save.ownedCharacterIds.length}',
                AppColors.purple,
              ),
              _StatTile(
                'WORLDS',
                '${save.ownedWorldIds.length}',
                AppColors.green,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.accent);
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: GameUiDesign.space2,
      vertical: GameUiDesign.space1,
    ),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: accent,
      radius: GameUiDesign.radiusMedium,
      strokeWidth: 2,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GameUiDesign.largeValueStyle.copyWith(color: accent),
        ),
        Text(label, maxLines: 1, style: GameUiDesign.itemLabelStyle),
      ],
    ),
  );
}

class _CustomizationPanel extends StatefulWidget {
  const _CustomizationPanel({
    required this.save,
    required this.onAvatarSelected,
    required this.onFrameSelected,
    required this.onTrailSelected,
  });
  final PlayerSave save;
  final ValueChanged<String> onAvatarSelected;
  final ValueChanged<String> onFrameSelected;
  final ValueChanged<String> onTrailSelected;

  @override
  State<_CustomizationPanel> createState() => _CustomizationPanelState();
}

class _CustomizationPanelState extends State<_CustomizationPanel> {
  _ProfileTab _selectedTab = _ProfileTab.overview;

  Widget _buildWorldMastery(PlayerSave save) {
    final allWorlds = worlds;
    return SizedBox(
      height: 220,
      child: GameScrollArea(
        axis: Axis.horizontal,
        builder: (context, controller) => ListView.separated(
          controller: controller,
          primary: false,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: GameUiDesign.space3),
          itemCount: allWorlds.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: GameUiDesign.space2),
          itemBuilder: (context, index) {
            final world = allWorlds[index];
            final score = save.worldScores[world.id] ?? 0;
            final unlocked = save.ownedWorldIds.contains(world.id);
            return Container(
              width: 232,
              clipBehavior: Clip.antiAlias,
              decoration: GameUiDesign.solidPanelDecoration(
                accent: unlocked ? AppColors.gold : AppColors.border,
                radius: GameUiDesign.radiusMedium,
                strokeWidth: unlocked
                    ? GameUiDesign.strongBorderWidth
                    : GameUiDesign.borderWidth,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(world.cardAsset, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.96),
                        ],
                        stops: const [0.28, 0.78],
                      ),
                    ),
                  ),
                  if (!unlocked)
                    ColoredBox(color: Colors.black.withValues(alpha: 0.52)),
                  Padding(
                    padding: const EdgeInsets.all(GameUiDesign.space2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          world.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: GameUiDesign.cardHeadingStyle.copyWith(
                            color: unlocked
                                ? Colors.white
                                : AppColors.mutedText,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: GameUiDesign.space1),
                        if (unlocked)
                          Text(
                            'BEST  $score',
                            style: GameUiDesign.cardHeadingStyle.copyWith(
                              color: AppColors.gold,
                            ),
                          )
                        else
                          const Icon(
                            Icons.lock,
                            color: AppColors.mutedText,
                            size: 32,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievements(PlayerSave save) {
    // Simple static achievements for now
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _AchievementBadge(
          'Iron Wings',
          '100+ Runs',
          save.totalRuns >= 100,
          Icons.flight_takeoff,
        ),
        _AchievementBadge(
          'Coin Hoarder',
          '5,000+ Coins',
          save.coins >= 5000,
          Icons.monetization_on,
        ),
        _AchievementBadge(
          'Neon Survivor',
          '10k Score',
          save.bestScore >= 10000,
          Icons.military_tech,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => GameGlassPanel(
    opacity: GameUiDesign.glassOpacity,
    child: Column(
      children: [
        _ProfileTabBar(
          selected: _selectedTab,
          onSelected: (tab) => setState(() => _selectedTab = tab),
        ),
        const SizedBox(height: GameUiDesign.space3),
        Container(
          height: 3,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.cyan, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: GameUiDesign.space3),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(_selectedTab),
              child: GameScrollArea(
                builder: (context, controller) => SingleChildScrollView(
                  controller: controller,
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    right: 28,
                    bottom: GameUiDesign.space6,
                  ),
                  child: _buildSelectedTab(),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSelectedTab() => switch (_selectedTab) {
    _ProfileTab.overview => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('WORLD MASTERY'),
        const SizedBox(height: GameUiDesign.space2),
        _buildWorldMastery(widget.save),
        const SizedBox(height: GameUiDesign.space4),
        const _SectionTitle('MEDALS & ACHIEVEMENTS'),
        const SizedBox(height: GameUiDesign.space2),
        _buildAchievements(widget.save),
        const SizedBox(height: GameUiDesign.space4),
        _SettingsStatus(save: widget.save),
      ],
    ),
    _ProfileTab.identity => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('CHOOSE PROFILE PICTURE'),
        const SizedBox(height: GameUiDesign.space2),
        _ChoiceRow(
          values: profileAvatars,
          selectedId: widget.save.selectedProfileAvatarId,
          avatarId: widget.save.selectedProfileAvatarId,
          frameId: widget.save.selectedProfileFrameId,
          selectingAvatar: true,
          onSelected: widget.onAvatarSelected,
        ),
        const SizedBox(height: GameUiDesign.space6),
        const _SectionTitle('CHOOSE PROFILE FRAME'),
        const SizedBox(height: GameUiDesign.space2),
        _ChoiceRow(
          values: profileFrames,
          selectedId: widget.save.selectedProfileFrameId,
          avatarId: widget.save.selectedProfileAvatarId,
          frameId: widget.save.selectedProfileFrameId,
          selectingAvatar: false,
          onSelected: widget.onFrameSelected,
        ),
      ],
    ),
    _ProfileTab.trails => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('ACTIVATE BIRD TRAIL'),
        const SizedBox(height: GameUiDesign.space2),
        _TrailChoiceRow(save: widget.save, onSelected: widget.onTrailSelected),
      ],
    ),
  };
}

enum _ProfileTab { overview, identity, trails }

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({required this.selected, required this.onSelected});

  final _ProfileTab selected;
  final ValueChanged<_ProfileTab> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ProfileTabButton(
          label: 'OVERVIEW',
          icon: Icons.dashboard_rounded,
          selected: selected == _ProfileTab.overview,
          onTap: () => onSelected(_ProfileTab.overview),
        ),
      ),
      const SizedBox(width: GameUiDesign.space2),
      Expanded(
        child: _ProfileTabButton(
          label: 'IDENTITY',
          icon: Icons.account_circle_rounded,
          selected: selected == _ProfileTab.identity,
          onTap: () => onSelected(_ProfileTab.identity),
        ),
      ),
      const SizedBox(width: GameUiDesign.space2),
      Expanded(
        child: _ProfileTabButton(
          label: 'TRAILS',
          icon: Icons.auto_awesome_rounded,
          selected: selected == _ProfileTab.trails,
          onTap: () => onSelected(_ProfileTab.trails),
        ),
      ),
    ],
  );
}

class _ProfileTabButton extends StatelessWidget {
  const _ProfileTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GameUiDesign.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 88,
        decoration: selected
            ? GameUiDesign.solidPanelDecoration(
                accent: AppColors.gold,
                radius: GameUiDesign.radiusMedium,
                strokeWidth: GameUiDesign.strongBorderWidth,
              )
            : GameUiDesign.panelDecoration(
                accent: AppColors.border,
                radius: GameUiDesign.radiusMedium,
                strokeWidth: GameUiDesign.borderWidth,
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.gold : AppColors.cyan,
              size: 42,
            ),
            const SizedBox(width: GameUiDesign.space2),
            Text(
              label,
              style: GameUiDesign.tabLabelStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TrailChoiceRow extends StatelessWidget {
  const _TrailChoiceRow({required this.save, required this.onSelected});

  final PlayerSave save;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: trails.map((trail) {
      final owned = save.ownedTrailIds.contains(trail.id);
      final selected = save.selectedTrailId == trail.id;
      return InkWell(
        onTap: owned ? () => onSelected(trail.id) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: GameUiDesign.solidPanelDecoration(
            accent: selected
                ? AppColors.green
                : owned
                ? AppColors.border
                : Colors.white24,
            radius: 20,
            strokeWidth: selected ? 4 : 2,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TrailPreview(trail: trail),
                    if (!owned)
                      const Icon(Icons.lock, color: Colors.white70, size: 38),
                    if (selected)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.green,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                trail.name,
                maxLines: 1,
                style: GameUiDesign.itemLabelStyle.copyWith(
                  color: owned ? Colors.white : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: GameUiDesign.sectionTitleStyle);
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selectedId,
    required this.avatarId,
    required this.frameId,
    required this.selectingAvatar,
    required this.onSelected,
  });
  final List<ProfileVisual> values;
  final String selectedId;
  final String avatarId;
  final String frameId;
  final bool selectingAvatar;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: values.map((value) {
      final selected = value.id == selectedId;
      return InkWell(
        onTap: () => onSelected(value.id),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 152,
          height: 152,
          padding: const EdgeInsets.all(8),
          decoration: GameUiDesign.solidPanelDecoration(
            accent: selected ? AppColors.gold : AppColors.border,
            radius: 24,
            strokeWidth: selected ? 4 : 2,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProfileAvatar(
                avatarId: selectingAvatar ? value.id : avatarId,
                frameId: selectingAvatar ? frameId : value.id,
                size: 120,
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 27),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

class _AchievementBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool unlocked;
  final IconData icon;
  const _AchievementBadge(this.title, this.subtitle, this.unlocked, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 145,
      decoration: GameUiDesign.solidPanelDecoration(
        accent: unlocked ? AppColors.green : AppColors.border,
        radius: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: unlocked ? AppColors.green : AppColors.mutedText,
            size: 44,
          ),
          const SizedBox(height: GameUiDesign.space1),
          Text(
            title,
            style: GameUiDesign.itemLabelStyle.copyWith(
              color: unlocked ? Colors.white : AppColors.mutedText,
            ),
          ),
          Text(
            subtitle,
            style: GameUiDesign.itemMetadataStyle.copyWith(
              color: unlocked ? AppColors.cyan : AppColors.mutedText,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsStatus extends StatelessWidget {
  const _SettingsStatus({required this.save});
  final PlayerSave save;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: AppColors.purple,
      radius: GameUiDesign.radiusMedium,
      strokeWidth: 2,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Status('MUSIC', save.musicEnabled),
        _Status('SOUND', save.sfxEnabled),
        _Status('HAPTICS', save.hapticsEnabled),
        _Status('HINTS', save.hintsEnabled),
      ],
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status(this.label, this.enabled);
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        enabled ? Icons.check_circle : Icons.cancel,
        color: enabled ? AppColors.green : AppColors.pink,
        size: 28,
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: GameUiDesign.tabLabelStyle.copyWith(color: Colors.white),
      ),
    ],
  );
}
