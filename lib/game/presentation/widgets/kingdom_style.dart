import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_theme.dart';
import 'petition_art.dart';

class KingdomSection extends StatelessWidget {
  const KingdomSection({
    super.key,
    required this.number,
    required this.title,
    required this.child,
    this.count,
    this.subtitle,
    this.headerKey,
  });
  final String number, title;
  final String? subtitle;
  final int? count;
  final Widget child;
  final Key? headerKey;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: paper.withValues(alpha: .22),
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          key: headerKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 10),
              child: Text(
                formatGameNumbers(number),
                style: const TextStyle(color: gold, fontSize: 11),
              ),
            ),
            Expanded(
              child: Text(
                formatGameNumbers(title),
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 20,
                  height: 1.3,
                ),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              KingdomPill('$count'),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            formatGameNumbers(subtitle!),
            style: const TextStyle(fontSize: 11, color: muted, height: 1.6),
          ),
        ],
        const SizedBox(height: 12),
        const PetitionRule(),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// Fine paper/brass trim for native buttons. All labels remain live text.
class KingdomButtonFrame extends StatelessWidget {
  const KingdomButtonFrame({
    super.key,
    required this.child,
    this.selected = false,
  });
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ButtonTrim(selected), child: child);
}

class _ButtonTrim extends CustomPainter {
  const _ButtonTrim(this.selected);
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final path =
        Path()
          ..moveTo(10, 1)
          ..quadraticBezierTo(4, 4, 1, 9)
          ..lineTo(2, size.height - 9)
          ..quadraticBezierTo(6, size.height - 5, 10, size.height - 2)
          ..lineTo(size.width - 10, size.height - 1)
          ..quadraticBezierTo(
            size.width - 4,
            size.height - 4,
            size.width - 1,
            size.height - 10,
          )
          ..lineTo(size.width - 2, 9)
          ..quadraticBezierTo(size.width - 6, 5, size.width - 10, 2)
          ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors:
              selected
                  ? [forest, const Color(0xFF12392D)]
                  : [const Color(0xFFFFFAEA), const Color(0xFFF2E3C3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB99A65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9,
    );
    for (final (x, y, dx, dy) in [
      (4.0, 4.0, 1.0, 1.0),
      (size.width - 4, 4.0, -1.0, 1.0),
      (4.0, size.height - 4, 1.0, -1.0),
      (size.width - 4, size.height - 4, -1.0, -1.0),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(dx, dy);
      canvas.drawPath(
        Path()
          ..moveTo(0, 12)
          ..quadraticBezierTo(1, 2, 12, 0)
          ..quadraticBezierTo(5, 0, 0, 0)
          ..close(),
        Paint()..color = const Color(0xFFC4A365),
      );
      canvas.drawPath(
        Path()
          ..moveTo(1, 9)
          ..quadraticBezierTo(3, 3, 9, 1),
        Paint()
          ..color = const Color(0xFFF5D998)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ButtonTrim oldDelegate) =>
      selected != oldDelegate.selected;
}

class KingdomPill extends StatelessWidget {
  const KingdomPill(this.text, {super.key, this.icon, this.color = forest});
  final String text;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            formatGameNumbers(text),
            style: TextStyle(fontSize: 10, color: color, height: 1.5),
          ),
        ),
      ],
    ),
  );
}

class KingdomEmpty extends StatelessWidget {
  const KingdomEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title, detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: gold, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(title),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatGameNumbers(detail),
                style: const TextStyle(fontSize: 11, color: muted, height: 1.7),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
