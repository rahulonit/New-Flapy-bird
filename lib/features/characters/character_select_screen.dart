import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';
import '../../domain/player_save.dart';
import '../../domain/profile_content.dart';
import '../../domain/trail_content.dart';
import '../profile/profile_avatar.dart';
import '../trails/trail_preview.dart';

enum _Tab { flyers, worlds, trails, identity, powerUps }

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});
  @override
  ConsumerState<CharacterSelectScreen> createState() => _State();
}

class _State extends ConsumerState<CharacterSelectScreen> {
  _Tab tab = _Tab.flyers;

  @override
  Widget build(BuildContext context) {
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'COLLECTIONS',
              subtitle: 'YOUR COMPLETE INVENTORY',
              coins: save.coins,
              gems: save.gems,
              onBack: context.pop,
            ),
            const SizedBox(height: GameUiDesign.space4),
            _Tabs(
              selected: tab,
              counts: {
                _Tab.flyers: save.ownedCharacterIds.length,
                _Tab.worlds: save.ownedWorldIds.length,
                _Tab.trails: save.ownedTrailIds.length,
                _Tab.identity: profileAvatars.length + profileFrames.length,
                _Tab.powerUps: save.shieldCount + save.scoreBoosterCount,
              },
              onSelected: (value) => setState(() => tab = value),
            ),
            const SizedBox(height: GameUiDesign.space3),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(GameUiDesign.space3),
                decoration: GameUiDesign.panelDecoration(
                  accent: AppColors.cyan,
                  opacity: .84,
                  glowing: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CollectionSectionHeader(
                      title: _sectionTitle,
                      description: _sectionDescription,
                      count: _ownedCount(save),
                      total: _totalCount,
                    ),
                    const SizedBox(height: GameUiDesign.space2),
                    Divider(
                      color: AppColors.cyan.withValues(alpha: .45),
                      height: 3,
                    ),
                    const SizedBox(height: GameUiDesign.space2),
                    Expanded(child: _content(save)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _sectionTitle => switch (tab) {
    _Tab.flyers => 'YOUR FLYERS',
    _Tab.worlds => 'DISCOVERED WORLDS',
    _Tab.trails => 'FLIGHT TRAILS',
    _Tab.identity => 'PILOT IDENTITY',
    _Tab.powerUps => 'POWER-UP INVENTORY',
  };

  String get _sectionDescription => switch (tab) {
    _Tab.flyers => 'Choose an owned flyer to use in your next run.',
    _Tab.worlds => 'Select an unlocked world as your active home theme.',
    _Tab.trails => 'Equip a purchased trail behind your flyer.',
    _Tab.identity => 'Customize the avatar and frame shown on your profile.',
    _Tab.powerUps => 'Review consumables available during gameplay.',
  };

  int _ownedCount(PlayerSave save) => switch (tab) {
    _Tab.flyers => save.ownedCharacterIds.length,
    _Tab.worlds => save.ownedWorldIds.length,
    _Tab.trails => save.ownedTrailIds.length,
    _Tab.identity => profileAvatars.length + profileFrames.length,
    _Tab.powerUps => save.shieldCount + save.scoreBoosterCount,
  };

  int get _totalCount => switch (tab) {
    _Tab.flyers => characters.length,
    _Tab.worlds => worlds.length,
    _Tab.trails => trails.length,
    _Tab.identity => profileAvatars.length + profileFrames.length,
    _Tab.powerUps => 2,
  };

  Widget _content(PlayerSave save) => switch (tab) {
    _Tab.flyers => _Grid(
      count: characters.length,
      builder: (i) {
        final item = characters[i];
        final owned = save.ownedCharacterIds.contains(item.id);
        return _Card(
          name: item.name,
          owned: owned,
          selected: save.selectedCharacterId == item.id,
          preview: Image.asset(item.previewAsset, fit: BoxFit.contain),
          onTap: owned
              ? () => ref
                    .read(playerSaveProvider.notifier)
                    .selectCharacter(item.id)
              : null,
        );
      },
    ),
    _Tab.worlds => _Grid(
      count: worlds.length,
      builder: (i) {
        final item = worlds[i];
        final owned = save.ownedWorldIds.contains(item.id);
        return _Card(
          name: item.name,
          owned: owned,
          selected: save.selectedWorldId == item.id,
          preview: Image.asset(item.cardAsset, fit: BoxFit.cover),
          onTap: owned
              ? () => ref.read(playerSaveProvider.notifier).selectWorld(item.id)
              : null,
        );
      },
    ),
    _Tab.trails => _Grid(
      count: trails.length,
      builder: (i) {
        final item = trails[i];
        final owned = save.ownedTrailIds.contains(item.id);
        return _Card(
          name: item.name,
          owned: owned,
          selected: save.selectedTrailId == item.id,
          preview: TrailPreview(trail: item, height: 110),
          onTap: owned
              ? () => ref.read(playerSaveProvider.notifier).selectTrail(item.id)
              : null,
        );
      },
    ),
    _Tab.identity => _Identity(save: save, ref: ref),
    _Tab.powerUps => _PowerUps(
      shields: save.shieldCount,
      boosters: save.scoreBoosterCount,
    ),
  };
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });
  final _Tab selected;
  final Map<_Tab, int> counts;
  final ValueChanged<_Tab> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 108,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(GameUiDesign.radiusLarge),
      border: Border.all(color: AppColors.cyan, width: 4),
      boxShadow: GameUiDesign.glow(AppColors.cyan),
    ),
    child: Row(
      children: _Tab.values.map((item) {
        final active = selected == item;
        final data = switch (item) {
          _Tab.flyers => (Icons.flight_rounded, 'FLYERS'),
          _Tab.worlds => (Icons.public_rounded, 'WORLDS'),
          _Tab.trails => (Icons.auto_awesome_rounded, 'TRAILS'),
          _Tab.identity => (Icons.badge_rounded, 'IDENTITY'),
          _Tab.powerUps => (Icons.bolt_rounded, 'POWER-UPS'),
        };
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              button: true,
              selected: active,
              label: '${data.$2}, ${counts[item] ?? 0} collected',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(item),
                  borderRadius: BorderRadius.circular(23),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: active ? GameUiDesign.primaryGradient : null,
                      color: active
                          ? null
                          : AppColors.surface.withValues(alpha: .38),
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: active
                            ? AppColors.gold
                            : AppColors.border.withValues(alpha: .42),
                        width: active ? 4 : 2,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: .32),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: active ? 1.12 : 1,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                data.$1,
                                size: 40,
                                color: active ? AppColors.gold : AppColors.cyan,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  data.$2,
                                  style: GameUiDesign.tabLabelStyle.copyWith(
                                    color: active
                                        ? Colors.white
                                        : AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(minWidth: 38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.gold
                                    : AppColors.secondarySurface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: active
                                      ? AppColors.orange
                                      : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${counts[item] ?? 0}',
                                textAlign: TextAlign.center,
                                style: GameUiDesign.itemMetadataStyle.copyWith(
                                  color: active
                                      ? AppColors.background
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: active ? 96 : 0,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: active
                                  ? GameUiDesign.glow(AppColors.gold)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

class _CollectionSectionHeader extends StatelessWidget {
  const _CollectionSectionHeader({
    required this.title,
    required this.description,
    required this.count,
    required this.total,
  });
  final String title;
  final String description;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GameUiDesign.sectionTitleStyle),
            Text(
              description,
              style: GameUiDesign.itemMetadataStyle.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.gold, width: 3),
        ),
        child: Text(
          '$count / $total OWNED',
          style: GameUiDesign.cardHeadingStyle.copyWith(color: AppColors.gold),
        ),
      ),
    ],
  );
}

class _Grid extends StatelessWidget {
  const _Grid({required this.count, required this.builder});
  final int count;
  final Widget Function(int) builder;
  @override
  Widget build(BuildContext context) => GameScrollArea(
    builder: (context, controller) => GridView.builder(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(right: GameUiDesign.space3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.05,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: count,
      itemBuilder: (context, index) => builder(index),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.name,
    required this.owned,
    required this.selected,
    required this.preview,
    this.onTap,
  });
  final String name;
  final bool owned;
  final bool selected;
  final Widget preview;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Ink(
      padding: const EdgeInsets.all(GameUiDesign.space2),
      decoration: GameUiDesign.solidPanelDecoration(
        accent: selected
            ? AppColors.gold
            : owned
            ? AppColors.cyan
            : AppColors.mutedText,
        radius: 24,
        strokeWidth: selected ? 5 : 3,
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: AppColors.background.withValues(alpha: .34),
                    child: Opacity(opacity: owned ? 1 : .32, child: preview),
                  ),
                ),
                if (!owned)
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                if (selected)
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 46,
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GameUiDesign.cardHeadingStyle,
            ),
          ),
          Text(
            selected
                ? 'EQUIPPED'
                : owned
                ? 'OWNED - TAP TO EQUIP'
                : 'LOCKED',
            style: GameUiDesign.itemMetadataStyle.copyWith(
              color: selected
                  ? AppColors.gold
                  : owned
                  ? AppColors.cyan
                  : AppColors.pink,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Identity extends StatelessWidget {
  const _Identity({required this.save, required this.ref});
  final PlayerSave save;
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Visuals(
          title: 'PROFILE PICTURES',
          values: profileAvatars,
          selectedId: save.selectedProfileAvatarId,
          preview: (v) => ProfileAvatar(
            avatarId: v.id,
            frameId: save.selectedProfileFrameId,
          ),
          onTap: (id) =>
              ref.read(playerSaveProvider.notifier).selectProfileAvatar(id),
        ),
      ),
      const SizedBox(width: GameUiDesign.space3),
      Expanded(
        child: _Visuals(
          title: 'PROFILE FRAMES',
          values: profileFrames,
          selectedId: save.selectedProfileFrameId,
          preview: (v) => ProfileAvatar(
            avatarId: save.selectedProfileAvatarId,
            frameId: v.id,
          ),
          onTap: (id) =>
              ref.read(playerSaveProvider.notifier).selectProfileFrame(id),
        ),
      ),
    ],
  );
}

class _Visuals extends StatelessWidget {
  const _Visuals({
    required this.title,
    required this.values,
    required this.selectedId,
    required this.preview,
    required this.onTap,
  });
  final String title;
  final List<ProfileVisual> values;
  final String selectedId;
  final Widget Function(ProfileVisual) preview;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: GameUiDesign.sectionTitleStyle),
      const SizedBox(height: GameUiDesign.space2),
      Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: values.length,
          itemBuilder: (context, i) {
            final value = values[i];
            return _Card(
              name: 'STYLE ${i + 1}',
              owned: true,
              selected: value.id == selectedId,
              preview: preview(value),
              onTap: () => onTap(value.id),
            );
          },
        ),
      ),
    ],
  );
}

class _PowerUps extends StatelessWidget {
  const _PowerUps({required this.shields, required this.boosters});
  final int shields;
  final int boosters;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _PowerCard(
        icon: Icons.shield_rounded,
        name: 'SHIELD',
        quantity: shields,
        color: AppColors.cyan,
      ),
      const SizedBox(width: GameUiDesign.space4),
      _PowerCard(
        icon: Icons.bolt_rounded,
        name: 'SCORE BOOSTER',
        quantity: boosters,
        color: AppColors.gold,
      ),
    ],
  );
}

class _PowerCard extends StatelessWidget {
  const _PowerCard({
    required this.icon,
    required this.name,
    required this.quantity,
    required this.color,
  });
  final IconData icon;
  final String name;
  final int quantity;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 440,
    padding: const EdgeInsets.all(GameUiDesign.space4),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: color,
      radius: 32,
      strokeWidth: 4,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 130, color: color),
        Text(name, style: GameUiDesign.sectionTitleStyle),
        const SizedBox(height: GameUiDesign.space2),
        Text(
          'x $quantity',
          style: GameUiDesign.largeValueStyle.copyWith(color: color),
        ),
        Text('AVAILABLE', style: GameUiDesign.itemMetadataStyle),
      ],
    ),
  );
}
