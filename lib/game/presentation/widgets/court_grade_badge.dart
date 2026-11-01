import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';

/// Personal rank has a stable seal, colour and number, independent of office.
class CourtGradeBadge extends StatelessWidget {
  const CourtGradeBadge(this.grade, {super.key});
  final int grade;

  @override
  Widget build(BuildContext context) {
    final (background, highlight, foreground, border, seal) = switch (grade) {
      1 => (
        const Color(0xFF6E1625),
        const Color(0xFF9E2B38),
        const Color(0xFFFFE5A6),
        const Color(0xFFD6AC53),
        Icons.workspace_premium,
      ),
      2 => (
        const Color(0xFF172953),
        const Color(0xFF314873),
        const Color(0xFFFFF0CA),
        const Color(0xFFC9A66B),
        Icons.stars,
      ),
      3 => (
        const Color(0xFF503169),
        const Color(0xFF73508C),
        const Color(0xFFFFF1D9),
        const Color(0xFFC5A0D0),
        Icons.shield,
      ),
      4 => (
        const Color(0xFF18483A),
        const Color(0xFF2B6652),
        const Color(0xFFE4F1DF),
        const Color(0xFF8CB89A),
        Icons.account_balance,
      ),
      5 => (
        const Color(0xFF12525C),
        const Color(0xFF287680),
        const Color(0xFFE3F4EF),
        const Color(0xFF80B8BD),
        Icons.auto_stories,
      ),
      6 => (
        const Color(0xFF365980),
        const Color(0xFF4C76A2),
        const Color(0xFFECF3FC),
        const Color(0xFF9DB9D4),
        Icons.description,
      ),
      7 => (
        const Color(0xFF865026),
        const Color(0xFFAA6B38),
        const Color(0xFFFFF0D7),
        const Color(0xFFD8AE7A),
        Icons.gavel,
      ),
      8 => (
        const Color(0xFFE6D4B6),
        const Color(0xFFF4E8D1),
        const Color(0xFF654727),
        const Color(0xFFB18B58),
        Icons.edit_note,
      ),
      _ => (
        const Color(0xFFDEE3E1),
        const Color(0xFFEEF0ED),
        const Color(0xFF46564F),
        const Color(0xFFA2ADA7),
        Icons.person_outline,
      ),
    };
    return Tooltip(
      message: formatGameNumbers('Phẩm cá nhân: ${courtGradeName(grade)}'),
      child: Semantics(
        label: formatGameNumbers('${courtGradeName(grade)} · Phẩm cá nhân'),
        excludeSemantics: true,
        child: Container(
          key: ValueKey('court-grade-seal-$grade'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [background, highlight]),
            border: Border.all(color: border, width: grade == 1 ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                grade <= 2
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
              Icon(seal, color: foreground, size: 16),
              const SizedBox(width: 6),
              Text(
                formatGameNumbers(courtGradeName(grade)),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: foreground.withValues(alpha: .12),
                  border: Border.all(color: foreground.withValues(alpha: .5)),
                ),
                child: Text(
                  formatGameNumbers(grade >= 1 && grade <= 9 ? '$grade' : '—'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
