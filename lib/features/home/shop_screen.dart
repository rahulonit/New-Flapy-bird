import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../domain/player_save.dart';
import '../../domain/trail_content.dart';
import '../trails/trail_preview.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(playerSaveProvider).value ?? const PlayerSave();
    final ownsNeon = save.ownedCharacterIds.contains('neon_bird');
    return Scaffold(
      body: Stack(
        children: [
          const GameScreenBackground(),
          SafeArea(
            left: false,
            right: false,
            child: Center(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: GameUiDesign.canvasWidth,
                  height: GameUiDesign.canvasHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(GameUiDesign.pageMargin),
                    child: Column(
                      children: [
                        _ShopHeader(
                          coins: save.coins,
                          gems: save.gems,
                          onBack: context.pop,
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 520,
                                child: _ShopSidebar(
                                  save: save,
                                  ownsNeon: ownsNeon,
                                  onBuyCharacter: () async {
                                    final success = await ref
                                        .read(playerSaveProvider.notifier)
                                        .purchaseCharacter(
                                          'neon_bird',
                                          coins: 500,
                                        );
                                    if (context.mounted) {
                                      _showResult(context, success);
                                    }
                                  },
                                  onBuyDiamonds: () => ref
                                      .read(playerSaveProvider.notifier)
                                      .buyDiamonds(),
                                  onExchangeDiamonds: () => ref
                                      .read(playerSaveProvider.notifier)
                                      .exchangeDiamonds(),
                                  onBuyShield: () => ref
                                      .read(playerSaveProvider.notifier)
                                      .purchaseShield(),
                                  onBuyBooster: () => ref
                                      .read(playerSaveProvider.notifier)
                                      .purchaseScoreBooster(),
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: GameGlassPanel(
                                  opacity: 0.78,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'BIRD TRAILS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: GameUiDesign.menuTextSize,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const Text(
                                        'BUY HERE • ACTIVATE FROM PLAYER PROFILE',
                                        style: TextStyle(
                                          color: AppColors.mutedText,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      Expanded(
                                        child: GameScrollArea(
                                          builder: (context, controller) =>
                                              GridView.builder(
                                                controller: controller,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                padding: const EdgeInsets.only(
                                                  right: 24,
                                                ),
                                                itemCount: trails.length - 1,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 18,
                                                      mainAxisSpacing: 18,
                                                      childAspectRatio: 2.05,
                                                    ),
                                                itemBuilder: (context, index) {
                                                  final trail =
                                                      trails[index + 1];
                                                  final owned = save
                                                      .ownedTrailIds
                                                      .contains(trail.id);
                                                  return _TrailProductCard(
                                                    trail: trail,
                                                    owned: owned,
                                                    active:
                                                        save.selectedTrailId ==
                                                        trail.id,
                                                    onBuy: () async {
                                                      final success = await ref
                                                          .read(
                                                            playerSaveProvider
                                                                .notifier,
                                                          )
                                                          .purchaseTrail(
                                                            trail.id,
                                                            coins: trail.price,
                                                          );
                                                      if (context.mounted) {
                                                        _showResult(
                                                          context,
                                                          success,
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
          ),
        ],
      ),
    );
  }

  static void _showResult(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'PURCHASE SUCCESSFUL!' : 'NOT ENOUGH COINS'),
        backgroundColor: success ? AppColors.green : AppColors.pink,
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.coins,
    required this.gems,
    required this.onBack,
  });
  final int coins;
  final int gems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => GameScreenHeader(
    title: 'HANGAR SHOP',
    subtitle: 'UPGRADE YOUR FLIGHT',
    coins: coins,
    gems: gems,
    onBack: onBack,
  );
}

class _ShopSidebar extends StatelessWidget {
  const _ShopSidebar({
    required this.save,
    required this.ownsNeon,
    required this.onBuyCharacter,
    required this.onBuyDiamonds,
    required this.onExchangeDiamonds,
    required this.onBuyShield,
    required this.onBuyBooster,
  });

  final PlayerSave save;
  final bool ownsNeon;
  final VoidCallback onBuyCharacter;
  final Future<bool> Function() onBuyDiamonds;
  final Future<bool> Function() onExchangeDiamonds;
  final Future<bool> Function() onBuyShield;
  final Future<bool> Function() onBuyBooster;

  Future<void> _run(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final success = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'PURCHASE SUCCESSFUL!' : 'INSUFFICIENT BALANCE',
        ),
        backgroundColor: success ? AppColors.green : AppColors.pink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GameGlassPanel(
    opacity: 0.78,
    child: GameScrollArea(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(right: 24, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarTitle('DIAMOND EXCHANGE'),
            const SizedBox(height: 10),
            _ShopAction(
              iconAsset: 'assets/Icons/Dimond.png',
              label: 'BUY 100 DIAMONDS',
              detail: '1,000 COINS',
              color: AppColors.purple,
              onTap: () => _run(context, onBuyDiamonds),
            ),
            const SizedBox(height: 8),
            _ShopAction(
              iconAsset: 'assets/Icons/Coin.png',
              label: 'EXCHANGE 100 DIAMONDS',
              detail: 'GET 750 COINS',
              color: AppColors.gold,
              onTap: () => _run(context, onExchangeDiamonds),
            ),
            const SizedBox(height: 18),
            const _SidebarTitle('POWER-UPS'),
            const SizedBox(height: 10),
            _ShopAction(
              iconAsset: 'assets/Icons/Heart.png',
              label: 'SHIELD ×${save.shieldCount}',
              detail: '20 DIAMONDS',
              color: AppColors.cyan,
              onTap: () => _run(context, onBuyShield),
            ),
            const SizedBox(height: 8),
            _ShopAction(
              iconAsset: 'assets/Icons/Flash.png',
              label: 'SCORE BOOSTER ×${save.scoreBoosterCount}',
              detail: '40 DIAMONDS',
              color: AppColors.orange,
              onTap: () => _run(context, onBuyBooster),
            ),
            const SizedBox(height: 18),
            const _SidebarTitle('FEATURED CHARACTER'),
            Row(
              children: [
                Image.asset('assets/neon-bird-cutout.png', width: 130),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ownsNeon ? null : onBuyCharacter,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 72),
                      backgroundColor: AppColors.gold,
                    ),
                    child: Text(ownsNeon ? 'OWNED' : 'NEON BIRD • 500 COINS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SidebarTitle extends StatelessWidget {
  const _SidebarTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 25,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );
}

class _ShopAction extends StatelessWidget {
  const _ShopAction({
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
    required this.iconAsset,
  });

  final String label;
  final String detail;
  final Color color;
  final VoidCallback onTap;
  final String iconAsset;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: GameUiDesign.solidPanelDecoration(
          accent: color,
          radius: 18,
          strokeWidth: 2,
        ),
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              width: GameUiDesign.menuIconSize,
              height: GameUiDesign.menuIconSize,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
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

class _TrailProductCard extends StatelessWidget {
  const _TrailProductCard({
    required this.trail,
    required this.owned,
    required this.active,
    required this.onBuy,
  });
  final TrailContent trail;
  final bool owned;
  final bool active;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: active ? AppColors.green : trail.colors.first,
      radius: GameUiDesign.radiusMedium,
      strokeWidth: active ? 4 : 2,
    ),
    child: Row(
      children: [
        Expanded(child: TrailPreview(trail: trail, height: 90)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trail.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: owned ? null : onBuy,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 62),
                  backgroundColor: AppColors.gold,
                ),
                child: Text(
                  active
                      ? 'ACTIVE'
                      : owned
                      ? 'OWNED'
                      : '${trail.price} COINS',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
