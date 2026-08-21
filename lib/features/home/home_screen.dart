import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';
import '../../domain/game_content.dart';
import '../../domain/player_level.dart';
import '../../domain/player_save.dart';
import '../../domain/profile_content.dart';
import '../profile/profile_avatar.dart';
import 'video_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(playerSaveProvider);
    final save = saveAsync.value;
    final activeWorld = worldById(save?.selectedWorldId ?? 'default');
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final dailyClaimed = save?.lastDailyRewardDate == today;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: activeWorld.videoAsset == null
                ? Image.asset(
                    activeWorld.backgroundAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/world-atlas.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : VideoBackground(
                    key: ValueKey(activeWorld.id),
                    assetPath: activeWorld.videoAsset!,
                    placeholderAsset: activeWorld.backgroundAsset,
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: GameUiDesign.screenOverlay),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FractionallySizedBox(
              widthFactor: 0.56,
              child: Image.asset(
                activeWorld.gameOverBaseAsset,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),

          // UI Layer scaled to 1920x1080 canvas
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: GameUiDesign.canvasWidth,
                    height: GameUiDesign.canvasHeight,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 40.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Bar
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Image.asset(
                                    'assets/Flapverse 3d Logo.png',
                                    height: 300,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox(height: 300),
                                  ),
                                ),
                              ),

                              // Center Area
                              Transform.translate(
                                offset: const Offset(0, -50),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 470,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: 430,
                                          height: 420,
                                          child: const Center(
                                            child: _FloatingBird(
                                              asset: 'assets/Bird.gif',
                                              height: 235,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // Bottom Area: Play Button & Daily Reward
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push('/play'),
                                  child: Container(
                                    width: 550,
                                    height: 145,
                                    decoration:
                                        GameUiDesign.homePrimaryCtaDecoration(),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'START FLIGHT:',
                                          style:
                                              GameUiDesign.homeCtaEyebrowStyle,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'PLAY',
                                              style: GameUiDesign.homeCtaStyle,
                                            ),
                                            Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 60,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'NEXT UNLOCK: CLOUD PEAKS > IN 5 DAYS',
                                  style: GameUiDesign.homeFooterStyle,
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
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width:
                    440 *
                    (MediaQuery.sizeOf(context).height /
                        GameUiDesign.canvasHeight),
                height:
                    632 *
                    (MediaQuery.sizeOf(context).height /
                        GameUiDesign.canvasHeight),
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.centerLeft,
                  child: _buildHomeMenuSection(context),
                ),
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 5,
            width: 200,
            height: 52,
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: FittedBox(
                fit: BoxFit.fill,
                child: _buildProfileCard(save),
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            width: 240,
            height: 52,
            child: FittedBox(
              fit: BoxFit.fill,
              child: _buildCurrencyBar(context, saveAsync),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.40,
            child: Semantics(
              button: true,
              label: dailyClaimed
                  ? 'Daily reward claimed today'
                  : 'Open daily reward',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/rewards'),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.asset(
                      activeWorld.homeCheckAsset,
                      height: MediaQuery.sizeOf(context).height * 0.40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.wallet_giftcard,
                        color: AppColors.pink,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: GameUiDesign.solidPanelDecoration(
                          accent: AppColors.gold,
                          radius: GameUiDesign.radiusSmall,
                          strokeWidth: 1.5,
                        ),
                        child: Text(
                          dailyClaimed
                              ? 'DAILY REWARD\nCLAIMED TODAY'
                              : 'DAILY REWARD\nTAP TO CLAIM',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildHomeMenuSection(BuildContext context) {
    final items = <_HomeMenuItemData>[
      const _HomeMenuItemData(
        label: 'MAP',
        asset: 'assets/Icons/World.png',
        route: '/worlds',
      ),
      const _HomeMenuItemData(
        label: 'COLLECTIONS',
        asset: 'assets/Icons/Gift box.png',
        route: '/characters',
      ),
      const _HomeMenuItemData(
        label: 'HANGAR SHOP',
        asset: 'assets/Icons/Shop.png',
        route: '/shop',
        badge: 'SALE',
      ),
      const _HomeMenuItemData(
        label: 'WORLDS',
        asset: 'assets/Icons/Go.png',
        route: '/world-select',
      ),
      const _HomeMenuItemData(
        label: 'LEADERBOARD',
        asset: 'assets/Icons/Flag.png',
        route: '/leaderboard',
      ),
    ];

    return SizedBox(
      width: 440,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisExtent: 120,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildMenuItem(item, () => context.push(item.route));
        },
      ),
    );
  }

  Widget _buildMenuItem(_HomeMenuItemData item, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameUiDesign.radiusMedium),
        child: Ink(
          decoration: GameUiDesign.solidPanelDecoration(
            radius: GameUiDesign.radiusMedium,
            strokeWidth: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  SizedBox.square(
                    dimension: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(item.asset, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GameUiDesign.homeMenuItemStyle,
                    ),
                  ),
                ],
              ),
              if (item.badge != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 42),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      item.badge!,
                      textAlign: TextAlign.center,
                      style: GameUiDesign.homeMenuBadgeStyle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(PlayerSave? save) {
    final level = PlayerLevelProgress.fromSave(save ?? const PlayerSave());
    return Container(
      width: 540,
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: GameUiDesign.homeHeaderDecoration(),
      child: Row(
        children: [
          ProfileAvatar(
            avatarId: save?.selectedProfileAvatarId ?? profileAvatars.first.id,
            frameId: save?.selectedProfileFrameId ?? profileFrames.first.id,
            size: 110,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'PLAYER ONE',
                    style: GameUiDesign.homeHeaderPrimaryStyle,
                  ),
                  Text(
                    level.level >= PlayerLevelProgress.maxLevel
                        ? 'LEVEL ${level.level} • MAX LEVEL'
                        : 'LEVEL ${level.level} • ${level.xpToNextLevel} XP TO NEXT',
                    style: GameUiDesign.homeHeaderSecondaryStyle,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 330,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: level.progress,
                        minHeight: 8,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.cyan,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBar(
    BuildContext context,
    AsyncValue<dynamic> saveAsync,
  ) {
    return Container(
      width: 650,
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: GameUiDesign.homeHeaderDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _buildCurrencyItem(
              asset: 'assets/Icons/Coin.png',
              value: '${saveAsync.value?.coins ?? 0}',
              accent: AppColors.gold,
              fallback: Icons.monetization_on,
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: AppColors.border.withValues(alpha: 0.55),
          ),
          Expanded(
            child: _buildCurrencyItem(
              asset: 'assets/Icons/Dimond.png',
              value: '${saveAsync.value?.gems ?? 0}',
              accent: AppColors.pink,
              fallback: Icons.diamond,
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: AppColors.border.withValues(alpha: 0.55),
          ),
          IconButton(
            tooltip: 'Settings',
            iconSize: 100,
            icon: Image.asset(
              'assets/Icons/Setting.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required String asset,
    required String value,
    required Color accent,
    required IconData fallback,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          asset,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(fallback, color: accent, size: 100),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GameUiDesign.walletValueStyle),
          ),
        ),
      ],
    );
  }
}

class _HomeMenuItemData {
  const _HomeMenuItemData({
    required this.label,
    required this.asset,
    required this.route,
    this.badge,
  });

  final String label;
  final String asset;
  final String route;
  final String? badge;
}

class _FloatingBird extends StatefulWidget {
  const _FloatingBird({required this.asset, required this.height});

  final String asset;
  final double height;

  @override
  State<_FloatingBird> createState() => _FloatingBirdState();
}

class _FloatingBirdState extends State<_FloatingBird>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _motion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _motion = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      child: Image.asset(widget.asset, height: widget.height),
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -8 + (_motion.value * 16)),
        child: Transform.rotate(
          angle: -0.025 + (_motion.value * 0.05),
          child: child,
        ),
      ),
    );
  }
}
