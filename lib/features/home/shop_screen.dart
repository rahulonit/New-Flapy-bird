import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/audio_service.dart';
import '../../core/theme.dart';
import '../../domain/game_content.dart';
import '../../domain/player_save.dart';
import '../../domain/trail_content.dart';
import '../trails/trail_preview.dart';

enum _ShopTab { featured, trails, powerUps, exchange }

typedef _CharacterPrice = ({int coins, int gems});

const _characterPrices = <String, _CharacterPrice>{
  'neon_bird': (coins: 500, gems: 0),
  'nox': (coins: 8000, gems: 0),
  'ember': (coins: 22000, gems: 0),
  'byte': (coins: 25000, gems: 75),
  'rocket': (coins: 45000, gems: 175),
  'ufo': (coins: 55000, gems: 175),
};

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});
  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  static _ShopTab _lastTab = _ShopTab.featured;
  late _ShopTab selectedTab = _lastTab;
  String? _busyKey;

  @override
  Widget build(BuildContext context) {
    final save = ref.watch(playerSaveProvider).value ?? const PlayerSave();
    final media = MediaQuery.of(context);
    final shopMedia = media.copyWith(textScaler: const TextScaler.linear(1.40));
    return Scaffold(
      body: GameMenuShell(
        backgroundAsset: worldById(save.selectedWorldId).backgroundAsset,
        child: Column(
          children: [
            GameScreenHeader(
              title: 'HANGAR SHOP',
              subtitle: 'UPGRADE YOUR FLIGHT',
              coins: save.coins,
              gems: save.gems,
              onBack: context.pop,
            ),
            const SizedBox(height: GameUiDesign.space4),
            MediaQuery(
              data: shopMedia,
              child: _ShopTabs(
                selected: selectedTab,
                counts: {
                  _ShopTab.featured: save.ownedCharacterIds.length,
                  _ShopTab.trails: save.ownedTrailIds.length,
                  _ShopTab.powerUps: save.shieldCount + save.scoreBoosterCount,
                },
                onSelected: (value) => setState(() {
                  selectedTab = value;
                  _lastTab = value;
                }),
              ),
            ),
            const SizedBox(height: GameUiDesign.space3),
            Expanded(
              child: MediaQuery(
                data: shopMedia,
                child: GameGlassPanel(opacity: .84, child: _content(save)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(PlayerSave save) => switch (selectedTab) {
    _ShopTab.featured => _CharacterShop(
      save: save,
      busyKey: _busyKey,
      onBuy: (character, price) => _purchase(
        'character_${character.id}',
        () => ref
            .read(playerSaveProvider.notifier)
            .purchaseCharacter(
              character.id,
              coins: price.coins,
              gems: price.gems,
            ),
        '${character.name} ADDED TO COLLECTIONS',
      ),
      onEquip: (id) =>
          ref.read(playerSaveProvider.notifier).selectCharacter(id),
    ),
    _ShopTab.trails => _TrailsShop(
      save: save,
      busyKey: _busyKey,
      onBuy: (trail) => _purchase(
        'trail_${trail.id}',
        () => ref
            .read(playerSaveProvider.notifier)
            .purchaseTrail(trail.id, coins: trail.price),
        '${trail.name} ADDED TO COLLECTIONS',
      ),
      onEquip: (id) => ref.read(playerSaveProvider.notifier).selectTrail(id),
    ),
    _ShopTab.powerUps => _ActionShop(
      title: 'POWER-UPS',
      subtitle: 'BUY CONSUMABLES FOR YOUR NEXT FLIGHT',
      children: [
        _ShopAction(
          iconAsset: 'assets/Icons/Heart.png',
          label: 'SHIELD',
          description: 'Absorbs one obstacle collision.',
          owned: save.shieldCount,
          price: 20,
          currency: _Currency.gems,
          balance: save.gems,
          color: AppColors.cyan,
          loading: _busyKey == 'shield',
          onTap: () => _purchase(
            'shield',
            ref.read(playerSaveProvider.notifier).purchaseShield,
            'SHIELD ADDED TO INVENTORY',
          ),
        ),
        _ShopAction(
          iconAsset: 'assets/Icons/Flash.png',
          label: 'SCORE BOOSTER',
          description: 'Boosts scoring for the active run.',
          owned: save.scoreBoosterCount,
          price: 40,
          currency: _Currency.gems,
          balance: save.gems,
          color: AppColors.orange,
          loading: _busyKey == 'booster',
          onTap: () => _purchase(
            'booster',
            ref.read(playerSaveProvider.notifier).purchaseScoreBooster,
            'BOOSTER ADDED TO INVENTORY',
          ),
        ),
      ],
    ),
    _ShopTab.exchange => _ExchangeShop(
      coins: save.coins,
      gems: save.gems,
      busyKey: _busyKey,
      onCoinsToGems: () => _confirmExchange(
        title: 'EXCHANGE COINS?',
        detail: '1,000 COINS  →  100 DIAMONDS',
        action: () => _purchase(
          'coins_to_gems',
          ref.read(playerSaveProvider.notifier).buyDiamonds,
          '100 DIAMONDS RECEIVED',
        ),
      ),
      onGemsToCoins: () => _confirmExchange(
        title: 'EXCHANGE DIAMONDS?',
        detail:
            '100 DIAMONDS  →  750 COINS\nRates are not reversible at equal value.',
        action: () => _purchase(
          'gems_to_coins',
          ref.read(playerSaveProvider.notifier).exchangeDiamonds,
          '750 COINS RECEIVED',
        ),
      ),
    ),
  };

  Future<void> _purchase(
    String key,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    if (_busyKey != null) return;
    setState(() => _busyKey = key);
    final success = await action();
    if (!mounted) return;
    setState(() => _busyKey = null);
    if (success) AudioService.playCoin();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            success
                ? successMessage
                : 'INSUFFICIENT BALANCE OR ITEM ALREADY OWNED',
            style: GameUiDesign.itemLabelStyle,
          ),
          backgroundColor: success ? AppColors.green : AppColors.pink,
        ),
      );
  }

  Future<void> _confirmExchange({
    required String title,
    required String detail,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.cyan, width: 4),
        ),
        title: Text(title, style: GameUiDesign.sectionTitleStyle),
        content: Text(detail, style: GameUiDesign.itemLabelStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }
}

class _ShopTabs extends StatelessWidget {
  const _ShopTabs({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });
  final _ShopTab selected;
  final Map<_ShopTab, int> counts;
  final ValueChanged<_ShopTab> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: AppColors.cyan, width: 4),
      boxShadow: GameUiDesign.glow(AppColors.cyan),
    ),
    child: Row(
      children: _ShopTab.values.map((item) {
        final active = selected == item;
        final data = switch (item) {
          _ShopTab.featured => ('assets/Icons/Gift box.png', 'CHARACTERS'),
          _ShopTab.trails => ('assets/Icons/Right wing.png', 'TRAILS'),
          _ShopTab.powerUps => ('assets/Icons/Flash.png', 'POWER-UPS'),
          _ShopTab.exchange => ('assets/Icons/Dimond.png', 'EXCHANGE'),
        };
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              button: true,
              selected: active,
              label: data.$2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(item),
                  borderRadius: BorderRadius.circular(23),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      gradient: active ? GameUiDesign.primaryGradient : null,
                      color: active
                          ? null
                          : AppColors.surface.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: active
                            ? AppColors.gold
                            : AppColors.border.withValues(alpha: .45),
                        width: active ? 4 : 2,
                      ),
                      boxShadow: active
                          ? GameUiDesign.glow(AppColors.gold)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              data.$1,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  data.$2,
                                  style: GameUiDesign.tabLabelStyle.copyWith(
                                    color: active
                                        ? Colors.white
                                        : AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ),
                            if (counts[item] case final count?) ...[
                              const SizedBox(width: 10),
                              _CountBadge(value: count, active: active),
                            ],
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: active ? 105 : 0,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(5),
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
        );
      }).toList(),
    ),
  );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value, required this.active});
  final int value;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 38),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: active ? AppColors.gold : AppColors.secondarySurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: active ? AppColors.orange : AppColors.border,
        width: 2,
      ),
    ),
    child: Text(
      '$value',
      textAlign: TextAlign.center,
      style: GameUiDesign.itemMetadataStyle.copyWith(
        color: active ? AppColors.background : Colors.white,
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, this.subtitle, {this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GameUiDesign.sectionTitleStyle),
            Text(
              subtitle,
              style: GameUiDesign.itemMetadataStyle.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class _CharacterShop extends StatelessWidget {
  const _CharacterShop({
    required this.save,
    required this.busyKey,
    required this.onBuy,
    required this.onEquip,
  });
  final PlayerSave save;
  final String? busyKey;
  final void Function(CharacterContent, _CharacterPrice) onBuy;
  final ValueChanged<String> onEquip;
  @override
  Widget build(BuildContext context) {
    final products = characters.where((item) => item.id != 'default').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          'CHARACTER HANGAR',
          'BUY AND EQUIP FLYERS FROM ONE PLACE',
          trailing: _OwnedProgress(
            '${save.ownedCharacterIds.length} / ${characters.length} OWNED',
          ),
        ),
        const SizedBox(height: GameUiDesign.space3),
        Expanded(
          child: GameScrollArea(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final item = products[index];
                final price =
                    _characterPrices[item.id] ?? (coins: 1000, gems: 0);
                final owned = save.ownedCharacterIds.contains(item.id);
                final selected = save.selectedCharacterId == item.id;
                return SizedBox(
                  width: 330,
                  child: _CharacterProductCard(
                    character: item,
                    price: price,
                    coinBalance: save.coins,
                    gemBalance: save.gems,
                    owned: owned,
                    selected: selected,
                    loading: busyKey == 'character_${item.id}',
                    onTap: owned
                        ? () => onEquip(item.id)
                        : () => onBuy(item, price),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterProductCard extends StatelessWidget {
  const _CharacterProductCard({
    required this.character,
    required this.price,
    required this.coinBalance,
    required this.gemBalance,
    required this.owned,
    required this.selected,
    required this.loading,
    required this.onTap,
  });
  final CharacterContent character;
  final _CharacterPrice price;
  final int coinBalance;
  final int gemBalance;
  final bool owned;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final affordable = coinBalance >= price.coins && gemBalance >= price.gems;
    final shortages = <String>[
      if (coinBalance < price.coins) '${price.coins - coinBalance} COINS',
      if (gemBalance < price.gems) '${price.gems - gemBalance} DIAMONDS',
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: GameUiDesign.solidPanelDecoration(
        accent: selected
            ? AppColors.green
            : owned
            ? AppColors.cyan
            : AppColors.gold,
        radius: 28,
        strokeWidth: selected ? 5 : 3,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _RarityBadge(
              selected ? 'EQUIPPED' : 'EPIC',
              selected ? AppColors.green : AppColors.purple,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: .12),
                    boxShadow: GameUiDesign.glow(
                      selected ? AppColors.green : AppColors.cyan,
                    ),
                  ),
                ),
                Image.asset(character.previewAsset, fit: BoxFit.contain),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(character.name, style: GameUiDesign.cardHeadingStyle),
          ),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                owned
                    ? 'READY FOR FLIGHT'
                    : affordable
                    ? 'AVAILABLE'
                    : 'NEED ${shortages.join(' + ')}',
                maxLines: 1,
                style: GameUiDesign.itemMetadataStyle.copyWith(
                  color: owned
                      ? AppColors.cyan
                      : affordable
                      ? AppColors.green
                      : AppColors.pink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _PurchaseButton(
            label: selected
                ? 'EQUIPPED'
                : owned
                ? 'EQUIP'
                : 'BUY',
            price: owned ? null : price.coins,
            currency: _Currency.coins,
            secondaryPrice: owned || price.gems == 0 ? null : price.gems,
            secondaryCurrency: _Currency.gems,
            enabled: !selected && (owned || affordable),
            loading: loading,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _TrailsShop extends StatelessWidget {
  const _TrailsShop({
    required this.save,
    required this.busyKey,
    required this.onBuy,
    required this.onEquip,
  });
  final PlayerSave save;
  final String? busyKey;
  final ValueChanged<TrailContent> onBuy;
  final ValueChanged<String> onEquip;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeading(
        'BIRD TRAILS',
        'BUY AND EQUIP YOUR FLIGHT EFFECT',
        trailing: _OwnedProgress(
          '${save.ownedTrailIds.length} / ${trails.length} OWNED',
        ),
      ),
      const SizedBox(height: GameUiDesign.space3),
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 1; index < trails.length; index++) ...[
              if (index > 1) const SizedBox(width: 24),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final trail = trails[index];
                    final owned = save.ownedTrailIds.contains(trail.id);
                    return _TrailProductCard(
                      trail: trail,
                      balance: save.coins,
                      owned: owned,
                      active: save.selectedTrailId == trail.id,
                      loading: busyKey == 'trail_${trail.id}',
                      onTap: owned
                          ? () => onEquip(trail.id)
                          : () => onBuy(trail),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

enum _Currency { coins, gems }

class _ActionShop extends StatelessWidget {
  const _ActionShop({
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeading(title, subtitle),
      const SizedBox(height: GameUiDesign.space4),
      Expanded(
        child: Row(
          children: children
              .map(
                (child) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

class _ShopAction extends StatelessWidget {
  const _ShopAction({
    required this.iconAsset,
    required this.label,
    required this.description,
    required this.owned,
    required this.price,
    required this.currency,
    required this.balance,
    required this.color,
    required this.loading,
    required this.onTap,
  });
  final String iconAsset;
  final String label;
  final String description;
  final int owned;
  final int price;
  final _Currency currency;
  final int balance;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final affordable = balance >= price;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: GameUiDesign.solidPanelDecoration(
        accent: color,
        radius: 32,
        strokeWidth: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                iconAsset,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              Positioned(
                right: -18,
                top: -8,
                child: _CountBadge(value: owned, active: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GameUiDesign.sectionTitleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GameUiDesign.itemMetadataStyle.copyWith(
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            affordable
                ? 'BALANCE READY'
                : 'NEED ${price - balance} MORE ${currency == _Currency.coins ? 'COINS' : 'DIAMONDS'}',
            style: GameUiDesign.itemMetadataStyle.copyWith(
              color: affordable ? AppColors.green : AppColors.pink,
            ),
          ),
          const SizedBox(height: 20),
          _PurchaseButton(
            label: 'BUY',
            price: price,
            currency: currency,
            enabled: affordable,
            loading: loading,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _ExchangeShop extends StatelessWidget {
  const _ExchangeShop({
    required this.coins,
    required this.gems,
    required this.busyKey,
    required this.onCoinsToGems,
    required this.onGemsToCoins,
  });
  final int coins;
  final int gems;
  final String? busyKey;
  final VoidCallback onCoinsToGems;
  final VoidCallback onGemsToCoins;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionHeading(
        'CURRENCY EXCHANGE',
        'CHOOSE A DIRECTION - EXCHANGE RATES ARE NOT REVERSIBLE',
      ),
      const SizedBox(height: 32),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: _ExchangeCard(
                fromAsset: 'assets/Icons/Coin.png',
                from: '1,000 COINS',
                toAsset: 'assets/Icons/Dimond.png',
                to: '100 DIAMONDS',
                affordable: coins >= 1000,
                shortage: '${1000 - coins} MORE COINS',
                loading: busyKey == 'coins_to_gems',
                onTap: onCoinsToGems,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _ExchangeCard(
                fromAsset: 'assets/Icons/Dimond.png',
                from: '100 DIAMONDS',
                toAsset: 'assets/Icons/Coin.png',
                to: '750 COINS',
                affordable: gems >= 100,
                shortage: '${100 - gems} MORE DIAMONDS',
                loading: busyKey == 'gems_to_coins',
                onTap: onGemsToCoins,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ExchangeCard extends StatelessWidget {
  const _ExchangeCard({
    required this.fromAsset,
    required this.from,
    required this.toAsset,
    required this.to,
    required this.affordable,
    required this.shortage,
    required this.loading,
    required this.onTap,
  });
  final String fromAsset;
  final String from;
  final String toAsset;
  final String to;
  final bool affordable;
  final String shortage;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(36),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: affordable ? AppColors.cyan : AppColors.mutedText,
      radius: 32,
      strokeWidth: 4,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(fromAsset, width: 120, height: 120),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 70,
                color: AppColors.cyan,
              ),
            ),
            Image.asset(toAsset, width: 120, height: 120),
          ],
        ),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('$from  →  $to', style: GameUiDesign.sectionTitleStyle),
        ),
        const SizedBox(height: 12),
        Text(
          affordable ? 'READY TO EXCHANGE' : 'NEED $shortage',
          style: GameUiDesign.itemMetadataStyle.copyWith(
            color: affordable ? AppColors.green : AppColors.pink,
          ),
        ),
        const SizedBox(height: 24),
        _PurchaseButton(
          label: 'EXCHANGE',
          enabled: affordable,
          loading: loading,
          onTap: onTap,
        ),
      ],
    ),
  );
}

class _TrailProductCard extends StatelessWidget {
  const _TrailProductCard({
    required this.trail,
    required this.balance,
    required this.owned,
    required this.active,
    required this.loading,
    required this.onTap,
  });
  final TrailContent trail;
  final int balance;
  final bool owned;
  final bool active;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: GameUiDesign.solidPanelDecoration(
      accent: active
          ? AppColors.green
          : owned
          ? AppColors.cyan
          : trail.colors.first,
      radius: 24,
      strokeWidth: active ? 5 : 3,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TrailPreview(trail: trail, height: 130),
        const SizedBox(height: 10),
        Text(
          'LIVE PREVIEW',
          style: GameUiDesign.itemMetadataStyle.copyWith(
            color: trail.colors.first,
          ),
        ),
        const SizedBox(height: 22),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(trail.name, style: GameUiDesign.cardHeadingStyle),
        ),
        Text(
          active
              ? 'ACTIVE TRAIL'
              : owned
              ? 'OWNED'
              : balance >= trail.price
              ? 'AVAILABLE'
              : 'NEED ${trail.price - balance} MORE COINS',
          textAlign: TextAlign.center,
          style: GameUiDesign.itemMetadataStyle.copyWith(
            color: active
                ? AppColors.green
                : owned
                ? AppColors.cyan
                : balance >= trail.price
                ? AppColors.green
                : AppColors.pink,
          ),
        ),
        const SizedBox(height: 18),
        _PurchaseButton(
          label: active
              ? 'ACTIVE'
              : owned
              ? 'EQUIP'
              : 'BUY',
          price: owned ? null : trail.price,
          currency: _Currency.coins,
          enabled: !active && (owned || balance >= trail.price),
          loading: loading,
          onTap: onTap,
        ),
      ],
    ),
  );
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.label,
    required this.onTap,
    this.price,
    this.currency,
    this.secondaryPrice,
    this.secondaryCurrency,
    this.enabled = true,
    this.loading = false,
  });
  final String label;
  final int? price;
  final _Currency? currency;
  final int? secondaryPrice;
  final _Currency? secondaryCurrency;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 96,
    child: ElevatedButton(
      onPressed: enabled && !loading ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        disabledBackgroundColor: AppColors.secondarySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: enabled ? AppColors.orange : AppColors.mutedText,
            width: 3,
          ),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.white,
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: GameUiDesign.itemLabelStyle),
                  if (price != null) ...[
                    const SizedBox(width: 12),
                    Image.asset(
                      currency == _Currency.gems
                          ? 'assets/Icons/Dimond.png'
                          : 'assets/Icons/Coin.png',
                      width: 38,
                      height: 38,
                    ),
                    const SizedBox(width: 6),
                    Text('$price', style: GameUiDesign.itemLabelStyle),
                  ],
                  if (secondaryPrice != null) ...[
                    const SizedBox(width: 10),
                    const Text('+', style: GameUiDesign.itemLabelStyle),
                    const SizedBox(width: 10),
                    Image.asset(
                      secondaryCurrency == _Currency.gems
                          ? 'assets/Icons/Dimond.png'
                          : 'assets/Icons/Coin.png',
                      width: 38,
                      height: 38,
                    ),
                    const SizedBox(width: 6),
                    Text('$secondaryPrice', style: GameUiDesign.itemLabelStyle),
                  ],
                ],
              ),
            ),
    ),
  );
}

class _OwnedProgress extends StatelessWidget {
  const _OwnedProgress(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .75),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.gold, width: 3),
    ),
    child: Text(
      label,
      style: GameUiDesign.itemMetadataStyle.copyWith(color: AppColors.gold),
    ),
  );
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      boxShadow: GameUiDesign.glow(color),
    ),
    child: Text(label, style: GameUiDesign.itemMetadataStyle),
  );
}
