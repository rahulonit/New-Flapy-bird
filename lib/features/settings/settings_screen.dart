import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/world-atlas.png', fit: BoxFit.cover)),
          Center(
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSettingSwitch('Music', save.musicEnabled, (v) {
                    ref.read(playerSaveProvider.notifier).save(save.copyWith(musicEnabled: v));
                  }),
                  const SizedBox(height: 32),
                  _buildSettingSwitch('Sound Effects', save.sfxEnabled, (v) {
                    ref.read(playerSaveProvider.notifier).save(save.copyWith(sfxEnabled: v));
                  }),
                  const SizedBox(height: 32),
                  _buildSettingSwitch('Haptics / Vibration', save.hapticsEnabled, (v) {
                    ref.read(playerSaveProvider.notifier).save(save.copyWith(hapticsEnabled: v));
                  }),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24)),
                    onPressed: () {},
                    child: const Text('RESTORE PURCHASES', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.cyan,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: AppColors.surface,
        ),
      ],
    );
  }
}
