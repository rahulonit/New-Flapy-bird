import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class WorldSelectScreen extends ConsumerWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              title: 'WORLD MAP',
              subtitle: 'CHOOSE YOUR NEXT UNIVERSE',
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GameScrollArea(
                axis: Axis.horizontal,
                builder: (context, controller) => ListView.separated(
                  controller: controller,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                  itemCount: worlds.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 28),
                  itemBuilder: (context, index) {
                    final world = worlds[index];
                    final unlocked = save.ownedWorldIds.contains(world.id);
                    final selected = save.selectedWorldId == world.id;
                    return _WorldCard(
                      world: world,
                      unlocked: unlocked,
                      selected: selected,
                      onTap: unlocked
                          ? () => ref
                                .read(playerSaveProvider.notifier)
                                .selectWorld(world.id)
                          : null,
                      onUnlock: unlocked
                          ? null
                          : () async {
                              final success = await ref
                                  .read(playerSaveProvider.notifier)
                                  .unlockWorldWithDiamonds(world.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '${world.name} UNLOCKED!'
                                          : '5,000 DIAMONDS REQUIRED',
                                    ),
                                    backgroundColor: success
                                        ? AppColors.green
                                        : AppColors.pink,
                                  ),
                                );
                              }
                            },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final WorldContent world;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onUnlock;

  const _WorldCard({
    required this.world,
    required this.unlocked,
    required this.selected,
    required this.onTap,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: unlocked,
      selected: selected,
      label: world.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 300,
          decoration: GameUiDesign.panelDecoration(
            accent: selected
                ? AppColors.gold
                : unlocked
                ? AppColors.cyan
                : Colors.grey,
            opacity: GameUiDesign.strongSurfaceOpacity,
            radius: GameUiDesign.space3,
            strokeWidth: selected ? 6 : GameUiDesign.strongBorderWidth,
            glowing: selected,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      unlocked ? Colors.transparent : Colors.black54,
                      BlendMode.srcATop,
                    ),
                    child: Image.asset(
                      world.cardAsset,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      world.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.grey,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!unlocked) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: onUnlock,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 58),
                          backgroundColor: AppColors.purple,
                        ),
                        child: const Text(
                          '💎 5,000 UNLOCK',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      selected
                          ? 'SELECTED'
                          : unlocked
                          ? 'TAP TO SELECT'
                          : 'LOCKED',
                      style: TextStyle(
                        color: selected ? AppColors.gold : AppColors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
