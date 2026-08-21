import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'flapverse_game.dart';
import '../../core/audio_service.dart';
import '../../application/providers.dart';
import '../../domain/game_content.dart';
import '../../domain/player_level.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with WidgetsBindingObserver {
  late final FlapverseGame _game;
  bool _isLeaving = false;
  bool _gameMounted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final save = ref.read(playerSaveProvider).value;
    final world = worldById(save?.selectedWorldId ?? 'default');
    final character = characterById(save?.selectedCharacterId ?? 'default');
    AudioService.configure(
      music: save?.musicEnabled ?? true,
      sfx: save?.sfxEnabled ?? true,
      haptics: save?.hapticsEnabled ?? true,
    );
    _game = FlapverseGame(
      backgroundAsset: world.backgroundAsset,
      gameOverAsset: world.gameOverAsset,
      playPanelAsset: world.playPanelAsset,
      gameOverBaseAsset: world.gameOverBaseAsset,
      birdAsset: character.asset,
      selectedTrailId: save?.selectedTrailId ?? 'none',
      hasShield: false,
      hasScoreBooster: false,
    );
    // Register listener for game over event
    _game.onGameOver = () async {
      final currentScore = _game.scoreNotifier.value;

      // Basic end-of-run persist via EconomyService
      // Wait, we can directly update the save
      await ref
          .read(playerSaveProvider.notifier)
          .recordRun(
            score: currentScore,
            obstacles: _game.obstaclesPassedNotifier.value,
            collectedCoins: _game.collectedCoinsNotifier.value,
          );
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shutdownGameplay();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isLeaving) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _game.pauseGameplay();
      if (!_game.overlays.isActive('GameOverMenu') &&
          !_game.overlays.isActive('PauseMenu')) {
        _game.overlays.add('PauseMenu');
      }
    } else if (state == AppLifecycleState.resumed &&
        (_game.overlays.isActive('PauseMenu') ||
            _game.overlays.isActive('GameOverMenu'))) {
      AudioService.pauseBgm();
    }
  }

  void _shutdownGameplay() {
    if (_isLeaving) return;
    _isLeaving = true;
    _game.shutdown();
  }

  Future<void> _quitToMenu() async {
    if (_isLeaving) return;
    _shutdownGameplay();
    if (mounted) {
      setState(() => _gameMounted = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) context.go('/');
  }

  Future<void> _activateShield(int remaining) async {
    if (remaining <= 0) {
      _showPowerUpMessage('NO SHIELDS REMAINING');
      return;
    }
    if (!_game.isPlaying) {
      _showPowerUpMessage('START FLYING TO ACTIVATE');
      return;
    }
    if (!_game.activateShield()) {
      _showPowerUpMessage('SHIELD ALREADY ACTIVE');
      return;
    }
    await ref.read(playerSaveProvider.notifier).consumeShield();
  }

  Future<void> _activateBooster(int remaining) async {
    if (remaining <= 0) {
      _showPowerUpMessage('NO SCORE BOOSTERS REMAINING');
      return;
    }
    if (!_game.isPlaying) {
      _showPowerUpMessage('START FLYING TO ACTIVATE');
      return;
    }
    if (!_game.activateScoreBooster()) {
      _showPowerUpMessage('BOOSTER ALREADY ACTIVE');
      return;
    }
    await ref.read(playerSaveProvider.notifier).consumeScoreBooster();
  }

  void _showPowerUpMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
          backgroundColor: AppColors.surface,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final save = ref.watch(playerSaveProvider).value;
    final bankCoins = save?.coins ?? 0;
    final shieldCount = save?.shieldCount ?? 0;
    final boosterCount = save?.scoreBoosterCount ?? 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quitToMenu();
      },
      child: !_gameMounted
          ? const Scaffold(backgroundColor: AppColors.background)
          : Scaffold(
              body: Stack(
                children: [
                  GameWidget(
                    game: _game,
                    overlayBuilderMap: {
                      'PauseMenu': (context, FlapverseGame game) {
                        return Center(
                          child: Container(
                            width: 800,
                            height: 500,
                            padding: const EdgeInsets.fromLTRB(
                              150,
                              110,
                              150,
                              60,
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(game.playPanelAsset),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'PAUSED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 64),
                                  ),
                                  onPressed: () {
                                    game.overlays.remove('PauseMenu');
                                    game.resumeGameplay();
                                  },
                                  child: const Text(
                                    'RESUME',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 64),
                                    backgroundColor: AppColors.secondarySurface,
                                  ),
                                  onPressed: () => _quitToMenu(),
                                  child: const Text(
                                    'QUIT TO MENU',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      'GameOverMenu': (context, FlapverseGame game) {
                        return Consumer(
                          builder: (context, ref, _) {
                            final save = ref.watch(playerSaveProvider).value;
                            final level = save == null
                                ? null
                                : PlayerLevelProgress.fromSave(save);
                            return Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.all(48),
                                  decoration: GameUiDesign.solidPanelDecoration(
                                    accent: AppColors.pink,
                                    radius: GameUiDesign.space3,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        game.gameOverAsset,
                                        width: 400,
                                        errorBuilder: (_, _, _) =>
                                            const Text('GAME OVER'),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Score: ${game.scoreNotifier.value}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                        ),
                                      ),
                                      Text(
                                        'Coins Collected: ${game.collectedCoinsNotifier.value}',
                                        style: const TextStyle(
                                          color: AppColors.gold,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (level != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'LEVEL ${level.level}',
                                          style: const TextStyle(
                                            color: AppColors.cyan,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 280,
                                          child: LinearProgressIndicator(
                                            value: level.progress,
                                            minHeight: 10,
                                            backgroundColor:
                                                AppColors.background,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.cyan),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          level.level >=
                                                  PlayerLevelProgress.maxLevel
                                              ? 'MAX LEVEL'
                                              : '${level.xpToNextLevel} XP TO NEXT LEVEL',
                                          style: const TextStyle(
                                            color: AppColors.mutedText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(200, 64),
                                          backgroundColor: AppColors.gold,
                                        ),
                                        onPressed: () {
                                          game.overlays.remove('GameOverMenu');
                                          game.resetGame();
                                          game.isPlaying = true;
                                          game.bird.startFlying();
                                          game.resumeGameplay();
                                        },
                                        child: const Text(
                                          'RETRY',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: AppColors.background,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(200, 64),
                                          backgroundColor:
                                              AppColors.secondarySurface,
                                        ),
                                        onPressed: () => _quitToMenu(),
                                        child: const Text(
                                          'QUIT TO MENU',
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              decoration: GameUiDesign.panelDecoration(
                                accent: AppColors.cyan,
                                opacity: 0.82,
                                radius: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'SCORE  $score',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ValueListenableBuilder<int>(
                                    valueListenable:
                                        _game.collectedCoinsNotifier,
                                    builder: (context, collectedCoins, _) =>
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 7,
                                          ),
                                          decoration:
                                              GameUiDesign.solidPanelDecoration(
                                                accent: AppColors.gold,
                                                radius:
                                                    GameUiDesign.radiusMedium,
                                                strokeWidth: 2,
                                              ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/Icons/Coin.png',
                                                width: 32,
                                                height: 32,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '$bankCoins',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Text(
                                                'RUN +$collectedCoins',
                                                style: const TextStyle(
                                                  color: AppColors.gold,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: _game.shieldNotifier,
                              builder: (context, active, _) => _PowerUpAction(
                                asset: 'assets/Icons/Heart.png',
                                label: 'SHIELD',
                                remaining: shieldCount,
                                active: active,
                                color: AppColors.cyan,
                                onTap: () => _activateShield(shieldCount),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: _game.scoreBoosterNotifier,
                              builder: (context, active, _) => _PowerUpAction(
                                asset: 'assets/Icons/Flash.png',
                                label: 'SCORE BOOSTER',
                                remaining: boosterCount,
                                active: active,
                                color: AppColors.gold,
                                onTap: () => _activateBooster(boosterCount),
                              ),
                            ),
                          ],
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
                          icon: const Icon(
                            Icons.pause_circle_filled,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (!_game.overlays.isActive('PauseMenu') &&
                                !_game.overlays.isActive('GameOverMenu')) {
                              _game.pauseGameplay();
                              _game.overlays.add('PauseMenu');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PowerUpAction extends StatelessWidget {
  const _PowerUpAction({
    required this.asset,
    required this.label,
    required this.remaining,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String asset;
  final String label;
  final int remaining;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label, $remaining remaining',
    toggled: active,
    child: AnimatedOpacity(
      opacity: remaining > 0 || active ? 1 : 0.55,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 270,
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: GameUiDesign.panelDecoration(
              accent: active ? AppColors.green : color,
              opacity: 0.90,
              radius: 24,
              glowing: active,
            ),
            child: Row(
              children: [
                Image.asset(asset, width: 62, height: 62, fit: BoxFit.contain),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        active ? 'ACTIVE' : 'TAP TO ACTIVATE',
                        style: TextStyle(
                          color: active ? AppColors.green : color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Text(
                    '$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
