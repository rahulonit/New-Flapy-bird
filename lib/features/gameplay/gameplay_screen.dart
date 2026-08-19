import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'flapverse_game.dart';
import '../../core/audio_service.dart';
import '../../application/providers.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late final FlapverseGame _game;

  @override
  void initState() {
    super.initState();
    _game = FlapverseGame();
    // Register listener for game over event
    _game.onGameOver = () async {
      final currentScore = _game.scoreNotifier.value;
      
      // Basic end-of-run persist via EconomyService
      // Wait, we can directly update the save
      final save = ref.read(playerSaveProvider).value;
      if (save != null) {
        final newBestScore = currentScore > save.bestScore ? currentScore : save.bestScore;
        final updated = save.copyWith(
          bestScore: newBestScore,
          coins: save.coins + (currentScore ~/ 100), // Give 1 coin per 100 points
          totalRuns: save.totalRuns + 1,
        );
        ref.read(playerSaveProvider.notifier).save(updated);
      }
    };
  }
  
  @override
  void dispose() {
    AudioService.stopBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'PauseMenu': (context, FlapverseGame game) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('PAUSED', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 64)),
                          onPressed: () {
                            game.resumeEngine();
                            game.overlays.remove('PauseMenu');
                          },
                          child: const Text('RESUME', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 64), backgroundColor: AppColors.secondarySurface),
                          onPressed: () {
                            context.go('/');
                          },
                          child: const Text('QUIT TO MENU', style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              'GameOverMenu': (context, FlapverseGame game) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.pink, width: 4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/Cyber_city/Gameover.png', width: 400, errorBuilder: (_,__,___) => const Text('GAME OVER')),
                        const SizedBox(height: 16),
                        Text('Score: ${game.scoreNotifier.value}', style: const TextStyle(color: Colors.white, fontSize: 32)),
                        Text('Coins Earned: ${game.scoreNotifier.value ~/ 100}', style: const TextStyle(color: AppColors.gold, fontSize: 24)),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 64), backgroundColor: AppColors.gold),
                          onPressed: () {
                            game.overlays.remove('GameOverMenu');
                            game.resetGame();
                            game.isPlaying = true;
                            game.bird.startFlying();
                          },
                          child: const Text('RETRY', style: TextStyle(fontSize: 24, color: AppColors.background)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 64), backgroundColor: AppColors.secondarySurface),
                          onPressed: () {
                            context.go('/');
                          },
                          child: const Text('QUIT TO MENU', style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: ValueListenableBuilder<int>(
                  valueListenable: _game.scoreNotifier,
                  builder: (context, score, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _game.comboNotifier,
                      builder: (context, combo, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('SCORE: $score', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            if (combo > 1)
                              Text('COMBO x$combo', style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.pause_circle_filled, color: Colors.white),
                  onPressed: () {
                    if (!_game.overlays.isActive('PauseMenu') && !_game.overlays.isActive('GameOverMenu')) {
                      _game.pauseEngine();
                      _game.overlays.add('PauseMenu');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
