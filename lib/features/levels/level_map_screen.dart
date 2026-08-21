import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';
import '../../domain/level_content.dart';

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({this.worldId, super.key});

  final String? worldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value;
    if (save == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final world = worldById(worldId ?? save.selectedWorldId);

    final worldOwned = save.ownedWorldIds.contains(world.id);
    final completed = completedLevelsFor(save.worldCompletedLevels, world.id);
    final levels = levelsForWorld(world.id);

    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: world.backgroundAsset,
        child: Stack(
          children: [
            Positioned.fill(
              top: 118,
              child: worldOwned
                  ? _LevelPath(
                      levels: levels,
                      completedLevels: completed,
                      onLevelSelected: (level) async {
                        await ref
                            .read(playerSaveProvider.notifier)
                            .selectWorld(world.id);
                        if (context.mounted) {
                          context.push(
                            '/play?level=${level.number}&from=levels',
                          );
                        }
                      },
                    )
                  : const _WorldLockedMessage(),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: .72),
                        Colors.transparent,
                        AppColors.background.withValues(alpha: .34),
                      ],
                      stops: const [0, .24, 1],
                    ),
                  ),
                ),
              ),
            ),
            GameScreenHeader(
              title: '${world.name} MAP',
              subtitle: '$completed / $levelsPerWorld LEVELS COMPLETED',
              coins: save.coins,
              gems: save.gems,
              onBack: () => context.pop(),
            ),
            Positioned(
              left: 48,
              bottom: 32,
              child: _MapLegend(completed: completed),
            ),
            Positioned(
              right: 48,
              bottom: 32,
              child: Text(
                'SWIPE TO EXPLORE  •  TAP AN UNLOCKED LEVEL TO PLAY',
                style: GameUiDesign.homeFooterStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPath extends StatelessWidget {
  const _LevelPath({
    required this.levels,
    required this.completedLevels,
    required this.onLevelSelected,
  });

  final List<GameLevel> levels;
  final int completedLevels;
  final ValueChanged<GameLevel> onLevelSelected;

  static const _verticalPattern = <double>[0.72, 0.46, 0.66, 0.34, 0.56, 0.25];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final nodeSize = math.min(142.0, constraints.maxHeight * 0.19);
      final horizontalStep = math.max(190.0, nodeSize * 1.55);
      final contentWidth = math.max(
        constraints.maxWidth,
        180 + ((levels.length - 1) * horizontalStep),
      );
      final points = List.generate(
        levels.length,
        (index) => Offset(
          90 + (index * horizontalStep),
          _verticalPattern[index % _verticalPattern.length] *
              constraints.maxHeight,
        ),
        growable: false,
      );
      return GameScrollArea(
        axis: Axis.horizontal,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          primary: false,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: GameUiDesign.space3),
          child: SizedBox(
            width: contentWidth,
            height: constraints.maxHeight - GameUiDesign.space3,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LevelRoutePainter(
                      points: points,
                      completedLevels: completedLevels,
                    ),
                  ),
                ),
                for (var index = 0; index < levels.length; index++)
                  Positioned(
                    left: points[index].dx - (nodeSize / 2),
                    top: points[index].dy - (nodeSize / 2),
                    width: nodeSize,
                    height: nodeSize,
                    child: _LevelNode(
                      level: levels[index],
                      completed: levels[index].number <= completedLevels,
                      unlocked: levels[index].number <= completedLevels + 1,
                      current: levels[index].number == completedLevels + 1,
                      onTap: () => onLevelSelected(levels[index]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.completed,
    required this.unlocked,
    required this.current,
    required this.onTap,
  });

  final GameLevel level;
  final bool completed;
  final bool unlocked;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = completed
        ? AppColors.gold
        : current
        ? AppColors.green
        : unlocked
        ? AppColors.cyan
        : AppColors.mutedText;
    return Semantics(
      button: unlocked,
      label: unlocked
          ? 'Level ${level.number}, target ${level.targetScore}'
          : 'Level ${level.number}, locked',
      child: InkWell(
        onTap: unlocked ? onTap : null,
        customBorder: const CircleBorder(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 10,
              right: 10,
              bottom: 2,
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(90, 28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: .9),
                      const Color(0xFF020A20),
                    ],
                  ),
                  border: Border.all(color: accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: current ? .65 : .28),
                      blurRadius: current ? 24 : 12,
                      spreadRadius: current ? 4 : 1,
                    ),
                    const BoxShadow(
                      color: Color(0xCC000000),
                      blurRadius: 12,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              bottom: 24,
              child: Transform.translate(
                offset: Offset(0, current ? -7 : -2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: unlocked
                        ? const RadialGradient(
                            center: Alignment(-.3, -.45),
                            radius: .9,
                            colors: [
                              Color(0xFF53C9FF),
                              Color(0xFF225DCE),
                              Color(0xFF061642),
                            ],
                            stops: [0, .38, 1],
                          )
                        : const RadialGradient(
                            center: Alignment(-.3, -.45),
                            colors: [Color(0xFF59657A), Color(0xFF151B2A)],
                          ),
                    border: Border.all(
                      color: accent,
                      width: current ? 7 : GameUiDesign.strongBorderWidth,
                    ),
                    boxShadow: current || completed
                        ? GameUiDesign.glow(accent)
                        : GameUiDesign.panelShadow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (unlocked)
                        Text(
                          '${level.number}',
                          style: GameUiDesign.largeValueStyle.copyWith(
                            color: completed ? AppColors.gold : Colors.white,
                          ),
                        )
                      else
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 48,
                        ),
                      if (completed)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 2,
                          child: Text(
                            '★★★',
                            textAlign: TextAlign.center,
                            style: GameUiDesign.homeFooterStyle.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      if (current)
                        Positioned(
                          bottom: 4,
                          child: Text(
                            'PLAY',
                            style: GameUiDesign.itemMetadataStyle.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ),
                    ],
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

class _LevelRoutePainter extends CustomPainter {
  const _LevelRoutePainter({
    required this.points,
    required this.completedLevels,
  });

  final List<Offset> points;
  final int completedLevels;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lockedRoute = Paint()
      ..color = AppColors.mutedText.withValues(alpha: 0.40)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final activeRoute = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.orange, AppColors.gold, AppColors.cyan],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dashed = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Path routePath(int lastPoint) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var index = 1; index <= lastPoint; index++) {
        final previous = points[index - 1];
        final next = points[index];
        final midpointX = (previous.dx + next.dx) / 2;
        path.cubicTo(
          midpointX,
          previous.dy,
          midpointX,
          next.dy,
          next.dx,
          next.dy,
        );
      }
      return path;
    }

    final fullPath = routePath(points.length - 1);
    final activeEnd = math.min(completedLevels, points.length - 1);
    final unlockedPath = routePath(activeEnd);
    canvas.drawPath(fullPath, shadow);
    canvas.drawPath(fullPath, lockedRoute);
    canvas.drawPath(unlockedPath, activeRoute);

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      for (var step = 1; step < 5; step++) {
        final t = step / 5;
        canvas.drawCircle(Offset.lerp(start, end, t)!, 4, dashed);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LevelRoutePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.completedLevels != completedLevels;
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.completed});
  final int completed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: GameUiDesign.panelDecoration(
      accent: AppColors.cyan,
      opacity: .78,
      radius: GameUiDesign.radiusPill,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.map_rounded, color: AppColors.cyan, size: 38),
        const SizedBox(width: 12),
        Text(
          'LEVEL ${math.min(completed + 1, levelsPerWorld)}',
          style: GameUiDesign.itemLabelStyle,
        ),
        const SizedBox(width: 20),
        const Icon(Icons.star_rounded, color: AppColors.gold, size: 34),
        Text(
          '$completed / $levelsPerWorld',
          style: GameUiDesign.itemMetadataStyle.copyWith(color: AppColors.gold),
        ),
      ],
    ),
  );
}

class _WorldLockedMessage extends StatelessWidget {
  const _WorldLockedMessage();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_rounded, color: AppColors.mutedText, size: 120),
        const SizedBox(height: GameUiDesign.space3),
        const Text('WORLD LOCKED', style: GameUiDesign.sectionTitleStyle),
        const SizedBox(height: GameUiDesign.space2),
        Text(
          'UNLOCK THIS WORLD BEFORE SELECTING LEVELS',
          style: GameUiDesign.itemLabelStyle.copyWith(
            color: AppColors.mutedText,
          ),
        ),
      ],
    ),
  );
}
