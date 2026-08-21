class WorldContent {
  final String id;
  final String name;
  final String backgroundAsset;
  final String cardAsset;
  final String homeCheckAsset;
  final String gameOverBaseAsset;
  final String gameOverAsset;
  final String playPanelAsset;
  final String? videoAsset;

  const WorldContent({
    required this.id,
    required this.name,
    required this.backgroundAsset,
    required this.cardAsset,
    required this.homeCheckAsset,
    required this.gameOverBaseAsset,
    required this.gameOverAsset,
    required this.playPanelAsset,
    this.videoAsset,
  });
}

class CharacterContent {
  final String id;
  final String name;
  final String asset;
  final String previewAsset;

  const CharacterContent({
    required this.id,
    required this.name,
    required this.asset,
    required this.previewAsset,
  });
}

const worlds = <WorldContent>[
  WorldContent(
    id: 'default',
    name: 'MYSTIC FOREST',
    backgroundAsset: 'assets/MysticForest_world_assets/MtsticForest.png',
    cardAsset: 'assets/MysticForest_world_assets/MysticForest-poster.jpg',
    homeCheckAsset: 'assets/MysticForest_world_assets/Home check box.png',
    gameOverBaseAsset: 'assets/MysticForest_world_assets/gameoverbase.png',
    gameOverAsset: 'assets/MysticForest_world_assets/Gameover.png',
    playPanelAsset: 'assets/MysticForest_world_assets/Play.png',
    videoAsset: 'assets/MysticForest_world_assets/MtsticForest.mp4',
  ),
  WorldContent(
    id: 'metro',
    name: 'METRO CITY',
    backgroundAsset: 'assets/Metro_city/MetroCity.png',
    cardAsset: 'assets/Metro_city/MetroCity-poster.jpg',
    homeCheckAsset: 'assets/Metro_city/Home check box.png',
    gameOverBaseAsset: 'assets/Metro_city/gameoverbase.png',
    gameOverAsset: 'assets/Metro_city/Gameover.png',
    playPanelAsset: 'assets/Metro_city/Play.png',
    videoAsset: 'assets/Metro_city/MetroCity-pingpong.mp4',
  ),
  WorldContent(
    id: 'cyber',
    name: 'CYBER CITY',
    backgroundAsset: 'assets/Cyber_city/Play.png',
    cardAsset: 'assets/Cyber_city/Home check box.png',
    homeCheckAsset: 'assets/Cyber_city/Home check box.png',
    gameOverBaseAsset: 'assets/Cyber_city/gameoverbase.png',
    gameOverAsset: 'assets/Cyber_city/Gameover.png',
    playPanelAsset: 'assets/Cyber_city/Play.png',
  ),
  WorldContent(
    id: 'ocean',
    name: 'OCEAN REALM',
    backgroundAsset: 'assets/Ocean_Realm/Home check box.png',
    cardAsset: 'assets/Ocean_Realm/Home check box.png',
    homeCheckAsset: 'assets/Ocean_Realm/Home check box.png',
    gameOverBaseAsset: 'assets/Ocean_Realm/gameoverbase.png',
    gameOverAsset: 'assets/Ocean_Realm/Gameover.png',
    playPanelAsset: 'assets/Ocean_Realm/Play.png',
    videoAsset: 'assets/Ocean_Realm/Ocean Realm.mp4',
  ),
  WorldContent(
    id: 'space',
    name: 'SPACE ODYSSEY',
    backgroundAsset: 'assets/SpaceOdyssey/SpaceOdyssey-poster.jpg',
    cardAsset: 'assets/SpaceOdyssey/SpaceOdyssey-poster.jpg',
    homeCheckAsset: 'assets/SpaceOdyssey/Home check box.png',
    gameOverBaseAsset: 'assets/SpaceOdyssey/gameoverbase.png',
    gameOverAsset: 'assets/SpaceOdyssey/Gameover.png',
    playPanelAsset: 'assets/SpaceOdyssey/Play.png',
    videoAsset: 'assets/SpaceOdyssey/SpaceOdyssey-pingpong.mp4',
  ),
];

const characters = <CharacterContent>[
  CharacterContent(
    id: 'default',
    name: 'CLASSIC BIRD',
    asset: 'assets/flying-bird-3d-flap.png',
    previewAsset: 'assets/neon-bird-cutout.png',
  ),
  CharacterContent(
    id: 'neon_bird',
    name: 'NEON BIRD',
    asset: 'assets/neon-bird-cutout.png',
    previewAsset: 'assets/neon-bird-cutout.png',
  ),
];

WorldContent worldById(String id) {
  for (final world in worlds) {
    if (world.id == id) return world;
  }
  return worlds.first;
}

CharacterContent characterById(String id) {
  for (final character in characters) {
    if (character.id == id) return character;
  }
  return characters.first;
}
