import 'dart:ui';

import 'package:flutter/material.dart';

/// Single source of truth for the visual language used throughout Flapverse.
abstract final class GameUiDesign {
  static const double canvasWidth = 1920;
  static const double canvasHeight = 1080;
  // Home establishes the app-wide edge rhythm: controls sit close to the safe
  // area while their own panels provide internal breathing room.
  static const double pageMargin = 5;

  static const double space1 = 8;
  static const double space2 = 16;
  static const double space3 = 24;
  static const double space4 = 32;
  static const double space5 = 40;
  static const double space6 = 48;
  static const double space8 = 64;

  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 32;
  static const double radiusPill = 60;
  static const double borderWidth = 3;
  static const double strongBorderWidth = 4;

  static const double glassOpacity = 0.48;
  static const double strongSurfaceOpacity = 0.92;
  static const double blurSigma = 14;

  static const double metadataSize = 18;
  static const double bodySize = 22;
  static const double buttonSize = 32;
  static const double cardTitleSize = 30;
  static const double screenTitleSize = 44;
  static const double scoreSize = 80;
  static const double homeHeaderHeight = 120;
  static const double homeHeaderPrimarySize = 42;
  static const double homeHeaderSecondarySize = 28;
  static const double walletValueSize = 46;
  static const double menuIconSize = 100;
  static const double menuTextSize = 42;

  static const LinearGradient screenOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x14031A3A), Color(0x00000000), Color(0x57020B20)],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryBlue, Color(0xFF004FAF)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD84A), AppColors.gold, AppColors.orange],
  );

  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x99000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.32),
      blurRadius: 22,
      spreadRadius: 2,
    ),
    ...panelShadow,
  ];

  static BoxDecoration panelDecoration({
    Color accent = AppColors.cyan,
    double opacity = glassOpacity,
    double radius = radiusLarge,
    double strokeWidth = strongBorderWidth,
    bool glowing = false,
  }) => BoxDecoration(
    color: AppColors.secondarySurface.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent, width: strokeWidth),
    boxShadow: glowing ? glow(accent) : panelShadow,
  );

  static BoxDecoration solidPanelDecoration({
    Color accent = AppColors.border,
    double radius = radiusLarge,
    double strokeWidth = strongBorderWidth,
  }) => BoxDecoration(
    color: AppColors.surface.withValues(alpha: strongSurfaceOpacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent, width: strokeWidth),
    boxShadow: panelShadow,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    color: AppColors.white,
    fontSize: cardTitleSize,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    shadows: [
      Shadow(color: Color(0xDD000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );

  static const TextStyle homeHeaderPrimaryStyle = TextStyle(
    color: AppColors.white,
    fontSize: homeHeaderPrimarySize,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle homeHeaderSecondaryStyle = TextStyle(
    color: AppColors.cyan,
    fontSize: homeHeaderSecondarySize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle walletValueStyle = TextStyle(
    color: AppColors.white,
    fontSize: walletValueSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle homeEyebrowStyle = TextStyle(
    color: AppColors.green,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  static const TextStyle homeValueStyle = TextStyle(
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  static const TextStyle homeTabStyle = TextStyle(
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle homeMenuItemStyle = TextStyle(
    color: AppColors.white,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
    height: 1.05,
    shadows: [
      Shadow(color: Color(0xDD000000), blurRadius: 7, offset: Offset(0, 2)),
    ],
  );

  static const TextStyle homeMenuBadgeStyle = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle homeCtaEyebrowStyle = TextStyle(
    color: AppColors.background,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  static const TextStyle homeCtaStyle = TextStyle(
    color: AppColors.white,
    fontSize: 60,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
  );

  static const TextStyle homeFooterStyle = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    shadows: [Shadow(color: Color(0xCC000000), blurRadius: 6)],
  );

  // Semantic typography roles shared by full-screen game interfaces.
  // Screens should consume these roles instead of declaring local font sizes.
  static const TextStyle screenTitleStyle = TextStyle(
    color: AppColors.white,
    fontSize: screenTitleSize,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    shadows: [
      Shadow(color: Color(0xDD000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );

  static const TextStyle screenSubtitleStyle = TextStyle(
    color: AppColors.green,
    fontSize: homeHeaderSecondarySize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const TextStyle sectionTitleStyle = homeMenuItemStyle;
  static const TextStyle tabLabelStyle = homeHeaderSecondaryStyle;
  static const TextStyle largeValueStyle = walletValueStyle;

  static const TextStyle itemLabelStyle = TextStyle(
    color: AppColors.white,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle itemMetadataStyle = TextStyle(
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle cardHeadingStyle = TextStyle(
    color: AppColors.white,
    fontSize: cardTitleSize,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    shadows: [
      Shadow(color: Color(0xDD000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );

  static BoxDecoration homePrimaryCtaDecoration() => BoxDecoration(
    gradient: goldGradient,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: AppColors.white, width: strongBorderWidth),
    boxShadow: glow(AppColors.gold),
  );

  static BoxDecoration homeHeaderDecoration({Color accent = AppColors.cyan}) =>
      BoxDecoration(
        color: AppColors.surface.withValues(alpha: strongSurfaceOpacity),
        borderRadius: BorderRadius.circular(radiusPill),
        border: Border.all(color: accent, width: borderWidth),
        boxShadow: glow(accent),
      );
}

abstract final class AppColors {
  static const Color background = Color(0xFF051A3A);
  static const Color surface = Color(0xFF082955);
  static const Color secondarySurface = Color(0xFF0B3970);
  static const Color border = Color(0xFF159DFF);
  static const Color cyan = Color(0xFF14D9FF);
  static const Color primaryBlue = Color(0xFF008CFF);
  static const Color purple = Color(0xFF8C3EFF);
  static const Color pink = Color(0xFFED36E8);
  static const Color gold = Color(0xFFFFB800);
  static const Color orange = Color(0xFFFF8A00);
  static const Color green = Color(0xFF45D21D);
  static const Color mutedText = Color(0xFFA8C2DF);
  static const Color white = Colors.white;
}

class GameGlassPanel extends StatelessWidget {
  const GameGlassPanel({
    required this.child,
    super.key,
    this.accent = AppColors.cyan,
    this.padding = const EdgeInsets.all(GameUiDesign.space3),
    this.opacity = GameUiDesign.glassOpacity,
    this.radius = GameUiDesign.radiusLarge,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: GameUiDesign.blurSigma,
        sigmaY: GameUiDesign.blurSigma,
      ),
      child: Container(
        padding: padding,
        decoration: GameUiDesign.panelDecoration(
          accent: accent,
          opacity: opacity,
          radius: radius,
        ),
        child: child,
      ),
    ),
  );
}

/// Shared full-screen artwork and readability overlay used by menu screens.
class GameScreenBackground extends StatelessWidget {
  const GameScreenBackground({
    super.key,
    this.asset = 'assets/world-atlas.png',
    this.fit = BoxFit.cover,
  });

  final String asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: fit),
        const DecoratedBox(
          decoration: BoxDecoration(gradient: GameUiDesign.screenOverlay),
        ),
      ],
    ),
  );
}

/// Shared landscape shell used by all non-gameplay menu screens.
class GameMenuShell extends StatelessWidget {
  const GameMenuShell({
    required this.child,
    super.key,
    this.backgroundAsset = 'assets/world-atlas.png',
    this.blurBackground = false,
  });

  final Widget child;
  final String backgroundAsset;
  final bool blurBackground;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        backgroundAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/world-atlas.png', fit: BoxFit.cover),
      ),
      if (blurBackground)
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const ColoredBox(color: Color(0x22051A3A)),
          ),
        ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66020B20), Color(0xA6051A3A)],
          ),
        ),
      ),
      SafeArea(
        left: false,
        right: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenAspect = constraints.maxWidth / constraints.maxHeight;
            final logicalWidth = screenAspect > (16 / 9)
                ? GameUiDesign.canvasHeight * screenAspect
                : GameUiDesign.canvasWidth;
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: logicalWidth,
                  height: GameUiDesign.canvasHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(GameUiDesign.pageMargin),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class GameScreenHeader extends StatelessWidget {
  const GameScreenHeader({
    required this.title,
    required this.onBack,
    super.key,
    this.subtitle,
    this.coins,
    this.gems,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final int? coins;
  final int? gems;

  @override
  Widget build(BuildContext context) {
    final physicalScale =
        MediaQuery.sizeOf(context).height / GameUiDesign.canvasHeight;
    final controlSize = 52 / physicalScale;
    final walletWidth = 240 / physicalScale;
    final walletHeight = 52 / physicalScale;
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox.square(
              dimension: controlSize,
              child: FittedBox(
                fit: BoxFit.fill,
                child: GameAssetIconButton(
                  asset: 'assets/Icons/back.png',
                  semanticLabel: 'Back',
                  size: GameUiDesign.menuIconSize,
                  onTap: onBack,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: GameUiDesign.space1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: GameUiDesign.screenTitleStyle),
                if (subtitle != null)
                  Text(subtitle!, style: GameUiDesign.screenSubtitleStyle),
              ],
            ),
          ),
          if (coins != null || gems != null)
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: walletWidth,
                height: walletHeight,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: GameCurrencyBar(coins: coins, gems: gems),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GameCurrencyBar extends StatelessWidget {
  const GameCurrencyBar({super.key, this.coins, this.gems});

  final int? coins;
  final int? gems;

  @override
  Widget build(BuildContext context) => Container(
    width: 650,
    height: 140,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: GameUiDesign.homeHeaderDecoration(),
    child: Row(
      children: [
        if (coins != null)
          Expanded(child: _currency('assets/Icons/Coin.png', coins!)),
        if (coins != null && gems != null)
          Container(
            width: 3,
            height: 80,
            color: AppColors.border.withValues(alpha: 0.55),
          ),
        if (gems != null)
          Expanded(child: _currency('assets/Icons/Dimond.png', gems!)),
      ],
    ),
  );

  Widget _currency(String asset, int value) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(asset, width: 100, height: 100, fit: BoxFit.contain),
      const SizedBox(width: GameUiDesign.space2),
      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatGameNumber(value),
            style: GameUiDesign.largeValueStyle,
          ),
        ),
      ),
    ],
  );
}

class GameAssetIconButton extends StatelessWidget {
  const GameAssetIconButton({
    required this.asset,
    required this.onTap,
    super.key,
    this.semanticLabel,
    this.size = GameUiDesign.menuIconSize,
  });

  final String asset;
  final VoidCallback onTap;
  final String? semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Ink(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.04),
        decoration: GameUiDesign.homeHeaderDecoration(),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    ),
  );
}

class GameWalletPill extends StatelessWidget {
  const GameWalletPill({required this.asset, required this.value, super.key});

  final String asset;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    constraints: const BoxConstraints(minWidth: 220),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: GameUiDesign.homeHeaderDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 82, height: 82, fit: BoxFit.contain),
        const SizedBox(width: 12),
        Text(
          _formatGameNumber(value),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

String _formatGameNumber(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

typedef GameScrollBuilder =
    Widget Function(BuildContext context, ScrollController controller);

/// One scroll behavior for every menu collection. It owns and disposes its
/// controller, exposes a draggable scrollbar, and avoids Android overscroll
/// bounce inside the scaled landscape canvas.
class GameScrollArea extends StatefulWidget {
  const GameScrollArea({
    required this.builder,
    super.key,
    this.axis = Axis.vertical,
    this.thumbVisibility = true,
  });

  final GameScrollBuilder builder;
  final Axis axis;
  final bool thumbVisibility;

  @override
  State<GameScrollArea> createState() => _GameScrollAreaState();
}

class _GameScrollAreaState extends State<GameScrollArea> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: _controller,
    thumbVisibility: widget.thumbVisibility,
    trackVisibility: widget.thumbVisibility,
    interactive: true,
    thickness: 12,
    radius: const Radius.circular(8),
    scrollbarOrientation: widget.axis == Axis.horizontal
        ? ScrollbarOrientation.bottom
        : ScrollbarOrientation.right,
    child: widget.builder(context, _controller),
  );
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primaryBlue,
  fontFamily: 'Chakra Petch',
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryBlue,
    secondary: AppColors.cyan,
    tertiary: AppColors.gold,
    surface: AppColors.surface,
    error: AppColors.pink,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontFamily: 'Chakra Petch',
      fontSize: GameUiDesign.screenTitleSize,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: AppColors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: AppColors.white,
      fontSize: GameUiDesign.bodySize,
    ),
    bodyMedium: TextStyle(
      color: AppColors.mutedText,
      fontSize: GameUiDesign.metadataSize,
    ),
    labelLarge: TextStyle(
      color: AppColors.white,
      fontSize: GameUiDesign.bodySize,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(96, 72),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      textStyle: const TextStyle(
        fontSize: GameUiDesign.buttonSize,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameUiDesign.radiusMedium),
        side: const BorderSide(
          color: AppColors.border,
          width: GameUiDesign.borderWidth,
        ),
      ),
    ),
  ),
);
