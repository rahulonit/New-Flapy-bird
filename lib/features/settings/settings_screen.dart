import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/audio_service.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void updateAudio({bool? music, bool? sfx, bool? haptics}) {
      final updated = save.copyWith(
        musicEnabled: music ?? save.musicEnabled,
        sfxEnabled: sfx ?? save.sfxEnabled,
        hapticsEnabled: haptics ?? save.hapticsEnabled,
      );
      ref.read(playerSaveProvider.notifier).save(updated);
      AudioService.configure(
        music: updated.musicEnabled,
        sfx: updated.sfxEnabled,
        haptics: updated.hapticsEnabled,
      );
    }

    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'SETTINGS',
              subtitle: 'PERSONALIZE YOUR FLIGHT',
              coins: save.coins,
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 500,
                    child: Container(
                      padding: const EdgeInsets.all(36),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.purple,
                        opacity: 0.88,
                        glowing: true,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/Icons/Setting.png', height: 270),
                          const SizedBox(height: 28),
                          const Text(
                            'GAME SETTINGS',
                            textAlign: TextAlign.center,
                            style: GameUiDesign.cardTitleStyle,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Changes save automatically and apply immediately.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(34),
                      decoration: GameUiDesign.panelDecoration(
                        accent: AppColors.cyan,
                        opacity: 0.88,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: _SettingCard(
                              asset: 'assets/Icons/Music.png',
                              title: 'MUSIC',
                              subtitle: 'Background soundtrack',
                              value: save.musicEnabled,
                              onChanged: (value) => updateAudio(music: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: _SettingCard(
                              asset: 'assets/Icons/Sound effects.png',
                              title: 'SOUND EFFECTS',
                              subtitle: 'Flaps, coins and impacts',
                              value: save.sfxEnabled,
                              onChanged: (value) => updateAudio(sfx: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: _SettingCard(
                              asset: 'assets/Icons/Haptics.png',
                              title: 'HAPTICS',
                              subtitle: 'Vibration feedback',
                              value: save.hapticsEnabled,
                              onChanged: (value) => updateAudio(haptics: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: _SettingCard(
                              asset: 'assets/Icons/Control Hints.png',
                              title: 'CONTROL HINTS',
                              subtitle: 'Show tap guidance',
                              value: save.hintsEnabled,
                              onChanged: (value) => ref
                                  .read(playerSaveProvider.notifier)
                                  .save(save.copyWith(hintsEnabled: value)),
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

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String asset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    button: true,
    label: title,
    child: InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: GameUiDesign.solidPanelDecoration(
          accent: value ? AppColors.cyan : AppColors.mutedText,
          radius: 24,
        ),
        child: Row(
          children: [
            Image.asset(
              asset,
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
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              value
                  ? 'assets/Icons/OnSwitch.png'
                  : 'assets/Icons/OffSwitch.png',
              width: 130,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    ),
  );
}
