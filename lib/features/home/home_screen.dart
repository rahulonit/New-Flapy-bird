import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../application/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(playerSaveProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/MysticForest_world_assets/MtsticForest.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/world-atlas.png', fit: BoxFit.cover),
            ),
          ),
          
          // UI Layer scaled to 1920x1080 canvas
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 1920,
                    height: 1080,
                    child: Stack(
                      children: [
                        // Left Edge Vertical Tabs
                        Positioned(
                          left: 0,
                          top: 250,
                          child: Column(
                            children: [
                              _buildVerticalTab('WORLDS', Icons.language, () => context.push('/worlds')),
                              const SizedBox(height: 16),
                              _buildVerticalTab('LEADERBOARD', Icons.leaderboard, () => context.push('/leaderboard')),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Bar
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildProfileCard(),
                                  Image.asset(
                                    'assets/Flapverse 3d Logo.png',
                                    height: 200,
                                    errorBuilder: (_, __, ___) => const SizedBox(height: 200),
                                  ),
                                  _buildCurrencyBar(context, saveAsync),
                                ],
                              ),
                              
                              // Center Area
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Left Column (Missions, Shop)
                                  Column(
                                    children: [
                                      _buildSidePanel(
                                        'MISSIONS',
                                        'assets/Icons/Daily calender.png',
                                        badge: '3',
                                        onTap: () => context.push('/missions'),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildSidePanel(
                                        'HANGAR SHOP',
                                        'assets/Dimond Chest.png',
                                        badge: 'SALE',
                                        onTap: () => context.push('/shop'),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 48),
                                  
                                  // Center Bird Display
                                  Container(
                                    width: 500,
                                    height: 500,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: AppColors.gold, width: 8),
                                      boxShadow: [
                                        BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage('assets/world-atlas.png'),
                                        fit: BoxFit.cover,
                                        opacity: 0.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/flying-bird-3d-flap.png',
                                          height: 350,
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: AppColors.green, width: 2),
                                            ),
                                            child: const Column(
                                              children: [
                                                Text('ACTIVE WORLD', style: TextStyle(color: AppColors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                                                Text('MYSTIC FOREST', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 48),
                                  
                                  // Right Column (Map, Collections)
                                  Column(
                                    children: [
                                      _buildSidePanel(
                                        'WORLD MAP',
                                        'assets/Icons/World.png',
                                        isLocked: true,
                                        onTap: () => context.push('/worlds'),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildSidePanel(
                                        'COLLECTIONS',
                                        'assets/Coin Chest.png',
                                        onTap: () => context.push('/characters'),
                                      ),
                                    ],
                                  ),
                                ],
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
                                    width: 600,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(color: Colors.white, width: 6),
                                      boxShadow: [
                                        BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                                      ],
                                      gradient: LinearGradient(
                                        colors: [AppColors.gold.withOpacity(0.8), AppColors.gold],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('START FLIGHT:', style: TextStyle(color: AppColors.background, fontSize: 24, fontWeight: FontWeight.bold)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('PLAY', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 4)),
                                            Icon(Icons.play_arrow, color: Colors.white, size: 80),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text('NEXT UNLOCK: CLOUD PEAKS > IN 5 DAYS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              ],
                            ),
                          ),
                        ),
                        
                        // Daily Reward Chest
                        Positioned(
                          bottom: 40,
                          right: 80,
                          child: GestureDetector(
                            onTap: () => context.push('/rewards'),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/Dimond Chest.png',
                                  width: 250,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.wallet_giftcard, size: 150, color: AppColors.pink),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.gold, width: 2),
                                  ),
                                  child: const Text('DAILY REWARD:\nTAP TO CLAIM', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }

  Widget _buildVerticalTab(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(32)),
          border: Border.all(color: AppColors.cyan, width: 3),
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: 400,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: AppColors.gold, width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cyan, width: 3),
              image: const DecorationImage(image: AssetImage('assets/flying-bird-3d-flap.png'), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 24),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PLAYER ONE', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Text('LEVEL 15 • SKY PILOT', style: TextStyle(color: AppColors.cyan, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBar(BuildContext context, AsyncValue<dynamic> saveAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: AppColors.cyan, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/Coin Chest.png', width: 48, errorBuilder: (_,__,___) => const Icon(Icons.monetization_on, color: AppColors.gold, size: 48)),
          const SizedBox(width: 16),
          Text('${saveAsync.value?.coins ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
          const Icon(Icons.add, color: AppColors.gold, size: 32),
          
          const SizedBox(width: 48),
          
          Image.asset('assets/Dimond Chest.png', width: 48, errorBuilder: (_,__,___) => const Icon(Icons.diamond, color: AppColors.pink, size: 48)),
          const SizedBox(width: 16),
          Text('${saveAsync.value?.gems ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
          const Icon(Icons.add, color: AppColors.gold, size: 32),
          
          const SizedBox(width: 48),
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(String title, String imageAsset, {String? badge, bool isLocked = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 400,
            height: 230,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cyan, width: 4),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    if (isLocked) const Icon(Icons.lock, color: Colors.grey, size: 32),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Image.asset(imageAsset, errorBuilder: (_,__,___) => const Icon(Icons.image, size: 80, color: Colors.white54)),
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
