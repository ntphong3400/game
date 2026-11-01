import 'dart:math';
import 'package:flutter/material.dart';

/// Original vector artwork: no runtime network or raster dependencies.
class PalaceArt extends StatelessWidget {
  const PalaceArt({super.key, this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PalacePainter(dark));
}

class _PalacePainter extends CustomPainter {
  _PalacePainter(this.dark);
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 600, size.height / 300);
    final p = Paint();
    final ink = dark ? const Color(0xFFB5BCA6) : const Color(0xFF65705A);
    p.color = const Color(0xFFBE9B5D).withValues(alpha: dark ? .25 : .18);
    canvas.drawCircle(const Offset(440, 94), 64, p);
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFFBE9B5D).withValues(alpha: .3);
    canvas.drawCircle(const Offset(440, 94), 77, p);
    p.style = PaintingStyle.fill;
    for (var layer = 0; layer < 3; layer++) {
      p.color = ink.withValues(alpha: .05 + layer * .035);
      final path = Path()..moveTo(0, 230.0 + layer * 15);
      for (var x = 0; x <= 620; x += 20) {
        path.lineTo(
          x.toDouble(),
          205 + layer * 22 + sin(x / 85 + layer * 1.7) * (24 - layer * 5),
        );
      }
      path
        ..lineTo(620, 300)
        ..lineTo(0, 300)
        ..close();
      canvas.drawPath(path, p);
    }
    void roof(double x, double y, double w, double h, double opacity) {
      p.color = ink.withValues(alpha: opacity);
      final roof =
          Path()
            ..moveTo(x, y + h)
            ..quadraticBezierTo(x + w * .22, y + h, x + w * .36, y)
            ..lineTo(x + w * .64, y)
            ..quadraticBezierTo(x + w * .78, y + h, x + w, y + h)
            ..quadraticBezierTo(x + w * .84, y + h + 10, x + w * .5, y + h + 7)
            ..quadraticBezierTo(x + w * .16, y + h + 10, x, y + h)
            ..close();
      canvas.drawPath(roof, p);
    }

    void hall(double x, double y, double w, double h, double opacity) {
      p.color = ink.withValues(alpha: opacity * .6);
      canvas.drawRect(Rect.fromLTWH(x + w * .16, y + 24, w * .68, h - 24), p);
      for (var i = 0; i < 5; i++) {
        p.color = ink.withValues(alpha: opacity);
        canvas.drawRect(
          Rect.fromLTWH(x + w * (.2 + i * .14), y + 29, 3, h - 29),
          p,
        );
      }
      roof(x, y, w, 22, opacity);
      p.color = ink.withValues(alpha: opacity * .7);
      canvas.drawRect(Rect.fromLTWH(x - 8, y + h, w + 16, 5), p);
    }

    hall(198, 204, 110, 57, .25);
    hall(464, 200, 112, 61, .25);
    hall(284, 162, 202, 99, .52);
    roof(310, 139, 150, 22, .57);
    p.color = ink.withValues(alpha: .46);
    canvas.drawRect(const Rect.fromLTWH(356, 117, 58, 23), p);
    roof(337, 100, 96, 20, .59);
    p.color = ink.withValues(alpha: .57);
    canvas.drawRect(const Rect.fromLTWH(381, 85, 2, 17), p);
    for (var step = 0; step < 4; step++) {
      p.color = ink.withValues(alpha: .15 + step * .03);
      canvas.drawRect(
        Rect.fromLTWH(348.0 - step * 8, 266.0 + step * 5, 76.0 + step * 16, 3),
        p,
      );
    }
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: .35);
    for (final bird in [
      const Offset(240, 104),
      const Offset(264, 92),
      const Offset(284, 111),
    ]) {
      final path =
          Path()
            ..moveTo(bird.dx - 6, bird.dy + 1)
            ..quadraticBezierTo(bird.dx - 2, bird.dy - 3, bird.dx, bird.dy + 1)
            ..quadraticBezierTo(bird.dx + 2, bird.dy - 3, bird.dx + 6, bird.dy);
      canvas.drawPath(path, p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PalacePainter oldDelegate) =>
      oldDelegate.dark != dark;
}
