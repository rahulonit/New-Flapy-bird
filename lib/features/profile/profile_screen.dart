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
                        _ProfileHeader(
                          coins: save.coins,
                          gems: save.gems,
                          onBack: () => context.pop(),
                        ),
                        const SizedBox(height: 28),
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
                              const SizedBox(width: 28),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.coins,
    required this.gems,
    required this.onBack,
  });
  final int coins;
  final int gems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => GameScreenHeader(
    title: 'PLAYER PROFILE',
    subtitle: 'PILOT STATS & CUSTOMIZATION',
    coins: coins,
    gems: gems,
    onBack: onBack,
  );
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.save, required this.level});
  final PlayerSave save;
  final PlayerLevelProgress level;

  @override
  Widget build(BuildContext context) => GameGlassPanel(
    opacity: 0.78,
    child: Column(
      children: [
        ProfileAvatar(
          avatarId: save.selectedProfileAvatarId,
          frameId: save.selectedProfileFrameId,
          size: 280,
        ),
        const Text(
          'PLAYER ONE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Text(
          'LEVEL ${level.level}',
          style: const TextStyle(
            color: AppColors.cyan,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: level.progress,
          minHeight: 16,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: AppColors.background,
          valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
        ),
        const SizedBox(height: 8),
        Text(
          level.level >= PlayerLevelProgress.maxLevel
              ? 'MAX LEVEL'
              : '${level.currentLevelXp} / ${level.nextLevelXp} XP',
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.15,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
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
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          style: TextStyle(
            color: accent,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameGlassPanel(
    opacity: 0.78,
    child: Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 12,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(right: 28, bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('CHOOSE PROFILE PICTURE'),
            const SizedBox(height: 16),
            _ChoiceRow(
              values: profileAvatars,
              selectedId: widget.save.selectedProfileAvatarId,
              avatarId: widget.save.selectedProfileAvatarId,
              frameId: widget.save.selectedProfileFrameId,
              selectingAvatar: true,
              onSelected: widget.onAvatarSelected,
            ),
            const SizedBox(height: 34),
            const _SectionTitle('CHOOSE PROFILE FRAME'),
            const SizedBox(height: 16),
            _ChoiceRow(
              values: profileFrames,
              selectedId: widget.save.selectedProfileFrameId,
              avatarId: widget.save.selectedProfileAvatarId,
              frameId: widget.save.selectedProfileFrameId,
              selectingAvatar: false,
              onSelected: widget.onFrameSelected,
            ),
            const SizedBox(height: 34),
            const _SectionTitle('ACTIVATE BIRD TRAIL'),
            const SizedBox(height: 16),
            _TrailChoiceRow(
              save: widget.save,
              onSelected: widget.onTrailSelected,
            ),
            const SizedBox(height: 34),
            _SettingsStatus(save: widget.save),
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
          width: 184,
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
                style: TextStyle(
                  color: owned ? Colors.white : AppColors.mutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: GameUiDesign.menuTextSize,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    ),
  );
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
          width: 184,
          height: 184,
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
                size: 164,
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
