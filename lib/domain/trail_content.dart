import 'package:flutter/material.dart';

class TrailContent {
  const TrailContent({
    required this.id,
    required this.name,
    required this.colors,
    required this.price,
  });

  final String id;
  final String name;
  final List<Color> colors;
  final int price;
}

const trails = <TrailContent>[
  TrailContent(id: 'none', name: 'NO TRAIL', colors: [], price: 0),
  TrailContent(
    id: 'cyan_pulse',
    name: 'CYAN PULSE',
    colors: [Color(0xFF14D9FF), Color(0xFF008CFF), Colors.white],
    price: 400,
  ),
  TrailContent(
    id: 'fire_burst',
    name: 'FIRE BURST',
    colors: [Color(0xFFFFD84A), Color(0xFFFF8A00), Color(0xFFFF304F)],
    price: 750,
  ),
  TrailContent(
    id: 'royal_plasma',
    name: 'ROYAL PLASMA',
    colors: [Color(0xFFED36E8), Color(0xFF8C3EFF), Color(0xFF14D9FF)],
    price: 1200,
  ),
  TrailContent(
    id: 'golden_comet',
    name: 'GOLDEN COMET',
    colors: [Color(0xFFFFFFFF), Color(0xFFFFD84A), Color(0xFFFFB800)],
    price: 2000,
  ),
];

TrailContent trailById(String id) =>
    trails.firstWhere((trail) => trail.id == id, orElse: () => trails.first);
