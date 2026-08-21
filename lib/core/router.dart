import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/home/shop_screen.dart';
import '../features/gameplay/gameplay_screen.dart';
import '../features/characters/character_select_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/levels/level_map_screen.dart';
import '../features/worlds/world_select_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) => GameplayScreen(
        key: ValueKey(state.uri.toString()),
        levelNumber:
            int.tryParse(state.uri.queryParameters['level'] ?? '') ?? 1,
        returnToLevelMap: state.uri.queryParameters['from'] == 'levels',
      ),
    ),
    GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
    GoRoute(
      path: '/worlds',
      builder: (context, state) => const LevelMapScreen(),
    ),
    GoRoute(
      path: '/world-select',
      builder: (context, state) => const WorldSelectScreen(),
    ),
    GoRoute(
      path: '/levels/:worldId',
      builder: (context, state) =>
          LevelMapScreen(worldId: state.pathParameters['worldId'] ?? 'default'),
    ),
    GoRoute(
      path: '/characters',
      builder: (context, state) => const CharacterSelectScreen(),
    ),
    GoRoute(
      path: '/missions',
      builder: (context, state) => const MissionsScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
