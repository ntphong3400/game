import '../../models/number_format.dart';
import 'package:flutter/material.dart';

class HaremRankBadge extends StatelessWidget {
  const HaremRankBadge(this.rank, {super.key});
  final String rank;

  @override
  Widget build(BuildContext context) {
    final (background, highlight, foreground, border, icon) = switch (rank) {
      'Hoàng hậu' => (
        const Color(0xFF741C31),
        const Color(0xFFA73950),
        const Color(0xFFFFE5A6),
        const Color(0xFFD6AC53),
        Icons.workspace_premium,
      ),
      'Phi tần' => (
        const Color(0xFF5C356F),
        const Color(0xFF84558E),
        const Color(0xFFFFF0DC),
        const Color(0xFFC7A4CE),
        Icons.local_florist,
      ),
      _ => (
        const Color(0xFFD9E8E1),
        const Color(0xFFEDF3EC),
        const Color(0xFF325C4A),
        const Color(0xFF90B3A1),
        Icons.spa_outlined,
      ),
    };
    return Tooltip(
      message: formatGameNumbers('Địa vị hậu cung: $rank'),
      child: Semantics(
        label: formatGameNumbers(rank),
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [background, highlight]),
            border: Border.all(
              color: border,
              width: rank == 'Hoàng hậu' ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                rank == 'Hoàng hậu'
                    ? [
                      BoxShadow(
                        color: background.withValues(alpha: .2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Text(
                formatGameNumbers(rank),
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
