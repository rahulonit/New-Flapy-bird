import 'package:flutter/material.dart';

import '../../domain/trail_content.dart';

class TrailPreview extends StatelessWidget {
  const TrailPreview({required this.trail, super.key, this.height = 58});

  final TrailContent trail;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _TrailPreviewPainter(trail.colors)),
  );
}

class _TrailPreviewPainter extends CustomPainter {
  const _TrailPreviewPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) {
      final paint = Paint()
        ..color = Colors.white38
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(size.width * 0.18, size.height / 2),
        Offset(size.width * 0.82, size.height / 2),
        paint,
      );
      return;
    }
    for (var i = 0; i < 12; i++) {
      final progress = i / 11;
      final color = colors[i % colors.length];
      final radius = 3 + (progress * 8);
      final paint = Paint()
        ..color = color.withValues(alpha: 0.25 + progress * 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        Offset(size.width * (0.12 + progress * 0.76), size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPreviewPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
