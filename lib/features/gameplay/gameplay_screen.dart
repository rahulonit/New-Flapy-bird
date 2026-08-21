import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'flapverse_game.dart';
import '../../core/audio_service.dart';
import '../../core/rewarded_ad_service.dart';
import '../../application/providers.dart';
import '../../domain/game_content.dart';
import '../../domain/level_content.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({
    super.key,
    this.levelNumber = 1,
    this.returnToLevelMap = false,
  });

  final int levelNumber;
  final bool returnToLevelMap;

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with WidgetsBindingObserver {
  static const double _compactHudScale = 0.40;

  late final FlapverseGame _game;
  bool _isLeaving = false;
  bool _gameMounted = true;
  bool _runRecorded = false;
  Future<void>? _runSave;
  late final String _worldId;
  bool _rewardAdBusy = false;
  bool _rewardDoubled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final save = ref.read(playerSaveProvider).value;
    final world = worldById(save?.selectedWorldId ?? 'default');
    _worldId = world.id;
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
      levelNumber: widget.levelNumber,
      targetScore: widget.returnToLevelMap
          ? levelTargetScore(widget.levelNumber)
          : null,
      difficulty: widget.returnToLevelMap
          ? LevelDifficulty.forLevel(widget.levelNumber)
          : LevelDifficulty.forLevel(1),
    );
    _game.onGameOver = () {
      _recordRun();
      _rewardDoubled = false;
      RewardedAdService.preload();
    };
    _game.onLevelComplete = _recordRun;
  }

  void _recordRun() {
    if (_runRecorded) return;
    _runRecorded = true;
    _runSave = ref
        .read(playerSaveProvider.notifier)
        .recordRun(
          score: _game.scoreNotifier.value,
          obstacles: _game.obstaclesPassedNotifier.value,
          collectedCoins: _game.collectedCoinsNotifier.value,
          earnedDiamonds: _earnedRunDiamonds,
          levelNumber: widget.returnToLevelMap ? widget.levelNumber : null,
        );
  }

  int get _earnedRunDiamonds => _game.scoreNotifier.value ~/ 10000;

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
          !_game.overlays.isActive('LevelCompleteMenu') &&
          !_game.overlays.isActive('PauseMenu')) {
        _game.overlays.add('PauseMenu');
      }
    } else if (state == AppLifecycleState.resumed &&
        (_game.overlays.isActive('PauseMenu') ||
            _game.overlays.isActive('GameOverMenu') ||
            _game.overlays.isActive('LevelCompleteMenu'))) {
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
    await _runSave;
    _shutdownGameplay();
    if (mounted) {
      setState(() => _gameMounted = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) {
      context.go(widget.returnToLevelMap ? '/levels/$_worldId' : '/');
    }
  }

  Future<void> _continueToNextLevel() async {
    if (_isLeaving || widget.levelNumber >= levelsPerWorld) return;
    await _runSave;
    _shutdownGameplay();
    if (mounted) {
      setState(() => _gameMounted = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) {
      final nextLevel = widget.levelNumber + 1;
      context.go('/play?level=$nextLevel&from=levels');
    }
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

  Future<void> _doubleRunReward() async {
    if (_rewardAdBusy || _rewardDoubled) return;
    final reward = _game.collectedCoinsNotifier.value;
    final diamonds = _earnedRunDiamonds;
    if (reward <= 0 && diamonds <= 0) {
      _showPowerUpMessage('EARN A RUN REWARD BEFORE DOUBLING');
      return;
    }
    setState(() => _rewardAdBusy = true);
    await _runSave;
    final earned = await RewardedAdService.show();
    if (!mounted) return;
    if (earned) {
      await ref.read(playerSaveProvider.notifier).recordRewardedAdWatched();
      await ref
          .read(playerSaveProvider.notifier)
          .grantRunBonusRewards(coins: reward, gems: diamonds);
      if (!mounted) return;
      setState(() {
        _rewardDoubled = true;
        _rewardAdBusy = false;
      });
      _showPowerUpMessage(
        'REWARD DOUBLED! +$reward COINS  +$diamonds DIAMONDS',
      );
    } else {
      setState(() => _rewardAdBusy = false);
      _showPowerUpMessage('AD NOT COMPLETED - REWARD NOT CHANGED');
    }
  }

  Future<void> _retryGame() async {
    await _runSave;
    _runRecorded = false;
    _runSave = null;
    _rewardDoubled = false;
    _rewardAdBusy = false;
    _game.overlays.remove('GameOverMenu');
    _game.resetGame();
    _game.isPlaying = true;
    _game.bird.startFlying();
    _game.resumeGameplay();
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
                      'LevelCompleteMenu': (context, FlapverseGame game) =>
                          _LevelCompleteOverlay(
                            levelNumber: widget.levelNumber,
                            score: game.scoreNotifier.value,
                            targetScore: levelTargetScore(widget.levelNumber),
                            hasNextLevel: widget.levelNumber < levelsPerWorld,
                            onContinue: _continueToNextLevel,
                            onLevelMap: _quitToMenu,
                          ),
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
                                  child: Text(
                                    widget.returnToLevelMap
                                        ? 'LEVEL MAP'
                                        : 'QUIT TO MENU',
                                    style: GameUiDesign.itemLabelStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      'GameOverMenu': (context, FlapverseGame game) {
                        return _GameOverOverlay(
                          game: game,
                          levelNumber: widget.levelNumber,
                          showTarget: widget.returnToLevelMap,
                          rewardDoubled: _rewardDoubled,
                          adBusy: _rewardAdBusy,
                          onHome: _quitToMenu,
                          onRetry: _retryGame,
                          onDoubleReward: _doubleRunReward,
                        );
                      },
                    },
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: _compactHudScale,
                          alignment: Alignment.topLeft,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _game.scoreNotifier,
                            builder: (context, score, child) => Container(
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
                                  if (widget.returnToLevelMap) ...[
                                    Text(
                                      'LEVEL ${widget.levelNumber}  •  TARGET ${levelTargetScore(widget.levelNumber)}',
                                      style: GameUiDesign.itemMetadataStyle
                                          .copyWith(color: AppColors.cyan),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Transform.scale(
                          scale: _compactHudScale,
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
                                !_game.overlays.isActive('GameOverMenu') &&
                                !_game.overlays.isActive('LevelCompleteMenu')) {
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

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.game,
    required this.levelNumber,
    required this.showTarget,
    required this.rewardDoubled,
    required this.adBusy,
    required this.onHome,
    required this.onRetry,
    required this.onDoubleReward,
  });

  final FlapverseGame game;
  final int levelNumber;
  final bool showTarget;
  final bool rewardDoubled;
  final bool adBusy;
  final VoidCallback onHome;
  final VoidCallback onRetry;
  final VoidCallback onDoubleReward;

  @override
  Widget build(BuildContext context) {
    final coins = game.collectedCoinsNotifier.value;
    final diamonds = game.scoreNotifier.value ~/ 10000;
    return ColoredBox(
      color: const Color(0xB805102C),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 1500,
            height: 930,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: .72,
                    child: Image.asset(
                      game.gameOverBaseAsset,
                      width: 1050,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(90, 40, 90, 72),
                  padding: const EdgeInsets.fromLTRB(64, 28, 64, 44),
                  decoration: GameUiDesign.panelDecoration(
                    accent: AppColors.cyan,
                    opacity: .88,
                    radius: 40,
                    strokeWidth: 5,
                    glowing: true,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        game.gameOverAsset,
                        width: 570,
                        height: 190,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Text(
                          'GAME OVER',
                          style: GameUiDesign.largeValueStyle.copyWith(
                            color: AppColors.pink,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _ResultPanel(
                                label: 'SCORE',
                                value: '${game.scoreNotifier.value}',
                                color: AppColors.gold,
                                footer: showTarget
                                    ? 'LEVEL $levelNumber TARGET: ${levelTargetScore(levelNumber)}'
                                    : 'BEST FLIGHT RESULT',
                              ),
                            ),
                            const SizedBox(width: GameUiDesign.space4),
                            Expanded(
                              child: _ResultPanel(
                                label: rewardDoubled
                                    ? 'DOUBLED REWARD'
                                    : 'RUN REWARD',
                                value: rewardDoubled
                                    ? '${coins * 2}'
                                    : '$coins',
                                secondaryValue: rewardDoubled
                                    ? '${diamonds * 2}'
                                    : '$diamonds',
                                secondaryIconAsset: 'assets/Icons/Dimond.png',
                                color: rewardDoubled
                                    ? AppColors.green
                                    : AppColors.cyan,
                                footer: rewardDoubled
                                    ? '+$coins COINS  +$diamonds DIAMONDS CLAIMED'
                                    : 'EARN 1 DIAMOND PER 10,000 SCORE',
                                iconAsset: 'assets/Icons/Coin.png',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GameUiDesign.space4),
                      Row(
                        children: [
                          Expanded(
                            child: _GameOverButton(
                              asset: 'assets/Icons/Home.png',
                              label: showTarget ? 'LEVEL MAP' : 'HOME',
                              color: AppColors.purple,
                              onTap: onHome,
                            ),
                          ),
                          const SizedBox(width: GameUiDesign.space3),
                          Expanded(
                            child: _GameOverButton(
                              asset: 'assets/Icons/Retry.png',
                              label: 'RETRY',
                              color: AppColors.primaryBlue,
                              primary: true,
                              onTap: onRetry,
                            ),
                          ),
                          const SizedBox(width: GameUiDesign.space3),
                          Expanded(
                            child: _GameOverButton(
                              asset: 'assets/Icons/vidoe2x.png',
                              label: rewardDoubled
                                  ? 'REWARD DOUBLED'
                                  : adBusy
                                  ? 'LOADING AD...'
                                  : 'DOUBLE REWARD',
                              subtitle: rewardDoubled
                                  ? 'CLAIMED'
                                  : 'WATCH AD x2',
                              color: AppColors.green,
                              enabled:
                                  !adBusy &&
                                  !rewardDoubled &&
                                  (coins > 0 || diamonds > 0),
                              onTap: onDoubleReward,
                            ),
                          ),
                        ],
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
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.label,
    required this.value,
    required this.color,
    required this.footer,
    this.iconAsset,
    this.secondaryValue,
    this.secondaryIconAsset,
  });
  final String label;
  final String value;
  final Color color;
  final String footer;
  final String? iconAsset;
  final String? secondaryValue;
  final String? secondaryIconAsset;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(GameUiDesign.space3),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: color,
      radius: 28,
      strokeWidth: 4,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GameUiDesign.cardHeadingStyle.copyWith(color: color),
        ),
        const SizedBox(height: GameUiDesign.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null) ...[
              Image.asset(iconAsset!, width: 72, height: 72),
              const SizedBox(width: GameUiDesign.space2),
            ],
            Text(
              value,
              style: GameUiDesign.largeValueStyle.copyWith(color: color),
            ),
            if (secondaryValue != null) ...[
              const SizedBox(width: GameUiDesign.space4),
              if (secondaryIconAsset != null) ...[
                Image.asset(secondaryIconAsset!, width: 68, height: 68),
                const SizedBox(width: GameUiDesign.space2),
              ],
              Text(
                secondaryValue!,
                style: GameUiDesign.largeValueStyle.copyWith(
                  color: AppColors.purple,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: GameUiDesign.space2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(footer, style: GameUiDesign.itemMetadataStyle),
        ),
      ],
    ),
  );
}

class _GameOverButton extends StatelessWidget {
  const _GameOverButton({
    required this.asset,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.primary = false,
  });
  final String asset;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
  final bool primary;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: enabled ? 1 : .58,
    duration: const Duration(milliseconds: 180),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: primary ? 124 : 116,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: GameUiDesign.solidPanelDecoration(
            accent: color,
            radius: 24,
            strokeWidth: primary ? 6 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, width: 74, height: 74, fit: BoxFit.contain),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label, style: GameUiDesign.itemLabelStyle),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GameUiDesign.itemMetadataStyle.copyWith(
                          color: color,
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
}

class _LevelCompleteOverlay extends StatefulWidget {
  const _LevelCompleteOverlay({
    required this.levelNumber,
    required this.score,
    required this.targetScore,
    required this.hasNextLevel,
    required this.onContinue,
    required this.onLevelMap,
  });

  final int levelNumber;
  final int score;
  final int targetScore;
  final bool hasNextLevel;
  final VoidCallback onContinue;
  final VoidCallback onLevelMap;

  @override
  State<_LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<_LevelCompleteOverlay> {
  bool _showContinuePrompt = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showContinuePrompt = true);
    });
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.background.withValues(alpha: 0.78),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: 0.35 + (value * 0.65),
            child: Opacity(opacity: value.clamp(0, 1), child: child),
          ),
          child: Container(
            width: 900,
            constraints: const BoxConstraints(minHeight: 620),
            padding: const EdgeInsets.all(GameUiDesign.space6),
            decoration: GameUiDesign.panelDecoration(
              accent: AppColors.gold,
              opacity: 0.96,
              radius: GameUiDesign.radiusLarge,
              strokeWidth: 8,
              glowing: true,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hasNextLevel
                      ? 'LEVEL ${widget.levelNumber} COMPLETE!'
                      : 'WORLD COMPLETE!',
                  textAlign: TextAlign.center,
                  style: GameUiDesign.homeCtaStyle.copyWith(
                    color: AppColors.gold,
                    fontSize: 68,
                  ),
                ),
                const SizedBox(height: GameUiDesign.space2),
                const _CelebrationStars(),
                const SizedBox(height: GameUiDesign.space3),
                Text(
                  'SCORE  ${widget.score}',
                  style: GameUiDesign.largeValueStyle,
                ),
                Text(
                  'TARGET  ${widget.targetScore}',
                  style: GameUiDesign.itemLabelStyle.copyWith(
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(height: GameUiDesign.space4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: !_showContinuePrompt
                      ? const SizedBox(
                          key: ValueKey('celebrating'),
                          height: 108,
                          child: Center(
                            child: Text(
                              'AWESOME FLIGHT!',
                              style: GameUiDesign.sectionTitleStyle,
                            ),
                          ),
                        )
                      : Column(
                          key: const ValueKey('actions'),
                          children: [
                            Text(
                              widget.hasNextLevel
                                  ? 'CONTINUE TO LEVEL ${widget.levelNumber + 1}?'
                                  : 'ALL 30 LEVELS COMPLETED!',
                              style: GameUiDesign.itemLabelStyle,
                            ),
                            const SizedBox(height: GameUiDesign.space3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: widget.onLevelMap,
                                  icon: const Icon(Icons.map_rounded, size: 34),
                                  label: const Text('LEVEL MAP'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(280, 82),
                                    backgroundColor: AppColors.primaryBlue,
                                    textStyle: GameUiDesign.itemLabelStyle,
                                  ),
                                ),
                                if (widget.hasNextLevel) ...[
                                  const SizedBox(width: GameUiDesign.space3),
                                  ElevatedButton.icon(
                                    onPressed: widget.onContinue,
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 38,
                                    ),
                                    label: const Text('NEXT LEVEL'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(300, 82),
                                      backgroundColor: AppColors.green,
                                      foregroundColor: AppColors.background,
                                      textStyle: GameUiDesign.itemLabelStyle,
                                    ),
                                  ),
                                ],
                              ],
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
  );
}

class _CelebrationStars extends StatelessWidget {
  const _CelebrationStars();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.star_rounded, color: AppColors.gold, size: 100),
      Icon(Icons.star_rounded, color: AppColors.gold, size: 140),
      Icon(Icons.star_rounded, color: AppColors.gold, size: 100),
    ],
  );
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
