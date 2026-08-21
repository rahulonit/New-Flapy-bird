import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class CharacterSelectScreen extends ConsumerWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selectedCharacter = characterById(save.selectedCharacterId);
    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'COLLECTIONS',
              subtitle: 'SELECT YOUR FLYER',
              coins: save.coins,
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(36),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.cyan,
                        opacity: 0.84,
                        glowing: true,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 500,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cyan.withValues(
                                      alpha: 0.14,
                                    ),
                                    boxShadow: GameUiDesign.glow(
                                      AppColors.cyan,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  selectedCharacter.previewAsset,
                                  height: 440,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            selectedCharacter.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'EPIC FLYER • READY FOR FLIGHT',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.gold,
                        opacity: 0.86,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR FLYERS',
                            style: GameUiDesign.cardTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap an unlocked character to equip it.',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: GameScrollArea(
                              builder: (context, controller) => GridView.builder(
                                controller: controller,
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.only(right: 24),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.9,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                    ),
                                itemCount: characters.length,
                                itemBuilder: (context, index) {
                                  final character = characters[index];
                                  final unlocked = save.ownedCharacterIds
                                      .contains(character.id);
                                  final selected =
                                      save.selectedCharacterId == character.id;
                                  return _CharacterCard(
                                    character: character,
                                    unlocked: unlocked,
                                    selected: selected,
                                    onTap: unlocked
                                        ? () => ref
                                              .read(playerSaveProvider.notifier)
                                              .selectCharacter(character.id)
                                        : null,
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
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });
  final CharacterContent character;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: unlocked,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: GameUiDesign.solidPanelDecoration(
          accent: selected
              ? AppColors.gold
              : unlocked
              ? AppColors.cyan
              : AppColors.mutedText,
          radius: 24,
          strokeWidth: selected ? 6 : 3,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      unlocked ? Colors.transparent : Colors.black54,
                      BlendMode.srcATop,
                    ),
                    child: Image.asset(
                      character.previewAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (!unlocked)
                    const Icon(Icons.lock, size: 68, color: Colors.white),
                  if (selected)
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.check_circle,
                        size: 46,
                        color: AppColors.green,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              character.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selected
                  ? 'EQUIPPED'
                  : unlocked
                  ? 'TAP TO EQUIP'
                  : 'LOCKED',
              style: TextStyle(
                color: selected
                    ? AppColors.gold
                    : unlocked
                    ? AppColors.cyan
                    : AppColors.pink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
