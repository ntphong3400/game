import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'imperial_theme.dart';

/// Native paper contours scale with the content and keep the entire face a
/// keyboard/touch target. Only decorative layers are offset; text stays flat.
class MemorialPaper extends StatelessWidget {
  const MemorialPaper({
    super.key,
    required this.child,
    required this.readKey,
    this.onOpen,
  });
  final Widget child;
  final Key readKey;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(1, 1, 8, 11),
    child: CustomPaint(
      painter: const _PaperLayers(),
      foregroundPainter: const _PaperCorners(),
      child: Material(
        color: const Color(0xFFF8EED5),
        clipBehavior: Clip.antiAlias,
        shape: const _PaperShape(),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8E7), Color(0xFFF0E0B9)],
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/imperial/parchment.webp'),
              fit: BoxFit.cover,
              opacity: .5,
            ),
          ),
          child: InkWell(
            key: readKey,
            onTap: onOpen,
            excludeFromSemantics: true,
            child: child,
          ),
        ),
      ),
    ),
  );
}

Path _paperContour(Rect rect, {double phase = 0}) {
  final w = rect.width, h = rect.height;
  final path = Path()..moveTo(12, 2);
  for (double x = 14; x < w - 12; x += 7) {
    path.lineTo(
      x,
      1.6 + math.sin(x * .4 + phase) * .8 + math.sin(x * .13) * .5,
    );
  }
  path.lineTo(w - 11, 2);
  path.quadraticBezierTo(w - 2, 1, w - 2, 12);
  for (double y = 14; y < h - 12; y += 7) {
    path.lineTo(w - 1.8 + math.sin(y * .39 + phase) * .8, y);
  }
  path.lineTo(w - 2, h - 12);
  path.quadraticBezierTo(w - 1, h - 3, w - 12, h - 2);
  for (double x = w - 14; x > 12; x -= 7) {
    path.lineTo(x, h - 1.8 + math.sin(x * .37 + phase) * .8);
  }
  path.lineTo(12, h - 2);
  path.quadraticBezierTo(2, h - 1, 2, h - 12);
  for (double y = h - 14; y > 12; y -= 7) {
    path.lineTo(1.7 + math.sin(y * .43 + phase) * .7, y);
  }
  path.lineTo(2, 12);
  path.quadraticBezierTo(1, 2, 12, 2);
  path.close();
  return path.shift(rect.topLeft);
}

class _PaperShape extends ShapeBorder {
  const _PaperShape();
  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(2);
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _paperContour(rect);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _paperContour(rect.deflate(2));
  @override
  ShapeBorder scale(double t) => this;
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      _paperContour(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0xFFC1A36D),
    );
    canvas.drawPath(
      _paperContour(rect.deflate(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .6
        ..color = const Color(0x55FFF8E7),
    );
  }
}

class _PaperLayers extends CustomPainter {
  const _PaperLayers();
  @override
  void paint(Canvas canvas, Size size) {
    const layers = [
      (Offset(4, 8), Color(0xFFD5BF95)),
      (Offset(1, 6), Color(0xFFE5CEA4)),
      (Offset(3, 3), Color(0xFFF1DFBA)),
    ];
    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final path = _paperContour(layer.$1 & size, phase: i * 1.7);
      if (i == 0) canvas.drawShadow(path, const Color(0x99704719), 3, false);
      canvas.drawPath(path, Paint()..color = layer.$2);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB99A65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7,
      );
      // Thin offset fibres make the exposed edges read as separate sheets.
      canvas.drawLine(
        Offset(14, size.height + layer.$1.dy - 3),
        Offset(size.width - 13, size.height + layer.$1.dy - 3),
        Paint()
          ..color = const Color(0x66FFF5DD)
          ..strokeWidth = .6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaperCorners extends CustomPainter {
  const _PaperCorners();
  @override
  void paint(Canvas canvas, Size size) {
    void corner(double x, double y, double sx, double sy) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(sx, sy);
      final path =
          Path()
            ..moveTo(0, 25)
            ..lineTo(0, 7)
            ..quadraticBezierTo(0, 0, 7, 0)
            ..lineTo(25, 0)
            ..quadraticBezierTo(20, 4, 14, 5)
            ..cubicTo(7, 5, 4, 9, 5, 14)
            ..quadraticBezierTo(4, 20, 0, 25)
            ..close();
      canvas.drawShadow(path, const Color(0x66704719), 1, false);
      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE1C17A), Color(0xFF9E7132), Color(0xFFD9B76A)],
          ).createShader(const Rect.fromLTWH(0, 0, 25, 25)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF8C642F)
          ..strokeWidth = .8,
      );
      final curl =
          Path()
            ..moveTo(2, 20)
            ..quadraticBezierTo(4, 7, 13, 3)
            ..cubicTo(22, 0, 22, 8, 16, 8)
            ..cubicTo(9, 8, 9, 18, 5, 16)
            ..quadraticBezierTo(2, 14, 6, 10);
      canvas.drawPath(
        curl,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFF5D998)
          ..strokeWidth = 1.1,
      );
      canvas.restore();
    }

    corner(6, 6, 1, 1);
    corner(size.width - 6, 6, -1, 1);
    corner(6, size.height - 6, 1, -1);
    corner(size.width - 6, size.height - 6, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PendingMemorialNote extends StatelessWidget {
  const PendingMemorialNote({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: const _InkUnderline(),
    child: const Padding(
      padding: EdgeInsets.only(left: 3, right: 3, bottom: 5),
      child: Text(
        'Chờ ngự phê',
        style: TextStyle(
          fontFamily: 'Charm',
          fontSize: 19,
          height: 1.35,
          color: Color(0xFF765030),
        ),
      ),
    ),
  );
}

class _InkUnderline extends CustomPainter {
  const _InkUnderline();
  @override
  void paint(Canvas canvas, Size size) {
    final stroke =
        Path()
          ..moveTo(7, size.height - 3)
          ..quadraticBezierTo(
            size.width * .6,
            size.height - 5,
            size.width - 4,
            size.height - 7,
          );
    canvas.drawPath(
      stroke,
      Paint()
        ..color = const Color(0xBB765030)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ApprovedMemorialSeal extends StatelessWidget {
  const ApprovedMemorialSeal({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đã ngự phê',
    child: CustomPaint(
      painter: const _SealFrame(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_vintage_outlined, size: 24, color: terracotta),
            SizedBox(height: 5),
            Text(
              'ĐÃ NGỰ PHÊ',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: terracotta,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SealFrame extends CustomPainter {
  const _SealFrame();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _paperContour((Offset.zero & size).deflate(1), phase: 2),
      Paint()
        ..color = terracotta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawPath(
      _paperContour((Offset.zero & size).deflate(6), phase: 4),
      Paint()
        ..color = terracotta.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
