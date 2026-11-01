import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../data/content.dart';
import '../../models/game_state.dart';
import 'imperial_theme.dart';

/// Display-only values from the already resolved choice. No random rolls,
/// save writes, or future/conditional rewards are folded into immediate effects.
class PetitionImpacts extends StatelessWidget {
  const PetitionImpacts({super.key, required this.state, required this.choice});
  final GameState state;
  final EventChoice choice;

  static const labels = {
    'treasury': 'Ngân khố',
    'gold': 'Ngân khố (lượng vàng)',
    'goldDebt': 'Nợ (lượng vàng)',
    'grain': 'Lương thực',
    'food': 'Lương thực (tạ)',
    'training': 'Huấn luyện',
    'equipment': 'Quân khí (bộ)',
    'morale': 'Sĩ khí',
    'logistics': 'Hậu cần',
    'population': 'Dân số lao động',
    'settlers': 'Lao động chờ nhận',
    'refugees': 'Lao động tị nạn chờ nhận',
    'returnees': 'Dân hồi hương',
    'displaced': 'Dân lưu tán',
    'troops': 'Quân số',
    'disease': 'Mức dịch bệnh',
    'people': 'Lòng dân',
    'authority': 'Uy quyền',
    'army': 'Quân lực',
    'stability': 'Ổn định triều đình',
    'health': 'Sức khỏe',
    'levee': 'Đê điều',
    'stress': 'Căng thẳng',
    'fatigue': 'Mệt mỏi',
    'illness': 'Mức bệnh',
    'war': 'Áp lực chiến tranh',
    'debt': 'Nợ chi trả',
    'revel': 'Lần hưởng lạc',
    'rest': 'Lần nghỉ',
    'plotReduce': 'Tiến độ âm mưu',
  };
  static IconData icon(String key) => switch (key) {
    'points' => Icons.history_edu_outlined,
    'treasury' || 'cost' || 'debt' => Icons.savings_outlined,
    'grain' || 'grainCost' => Icons.grass_outlined,
    'people' => Icons.groups_outlined,
    'authority' => Icons.workspace_premium_outlined,
    'army' || 'war' => Icons.shield_outlined,
    'health' || 'illness' => Icons.favorite_border,
    'levee' => Icons.water_outlined,
    'stability' => Icons.balance_outlined,
    'fatigue' || 'rest' => Icons.spa_outlined,
    'stress' => Icons.self_improvement_outlined,
    _ => Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final values = <({String key, String label, int value})>[
      (
        key: 'points',
        label: 'Hành động',
        value: -petitionPoints(state, choice),
      ),
      if (choice.cost > 0)
        (
          key: 'cost',
          label: state.goldStandard ? 'Chi (lượng vàng)' : 'Chi tiền',
          value: -choice.cost,
        ),
      if (choice.grainCost > 0)
        (key: 'grainCost', label: 'Xuất lương', value: -choice.grainCost),
      for (final effect in choice.effects.entries)
        if (labels.containsKey(effect.key) ||
            effect.key.startsWith('faction:') ||
            effect.key.startsWith('affection:'))
          (
            key: effect.key,
            label:
                labels[effect.key] ??
                (effect.key.startsWith('faction:')
                    ? 'Phe ${effect.key.substring(8)}'
                    : 'Thiện cảm phe ${effect.key.substring(10)}'),
            value: effect.key == 'plotReduce' ? -effect.value : effect.value,
          ),
    ];
    return LayoutBuilder(
      builder: (context, bounds) {
        final columns =
            bounds.maxWidth >= 560
                ? values.length.clamp(1, 4)
                : bounds.maxWidth >= 360
                ? values.length.clamp(1, 3)
                : bounds.maxWidth >= 240
                ? values.length.clamp(1, 2)
                : 1;
        final width = (bounds.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            for (final entry in values)
              SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 10),
                      child: Icon(
                        icon(entry.key),
                        size: 27,
                        color: const Color(0xFF6F7153),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatGameNumbers(entry.label),
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12,
                              color: ink,
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              '${entry.value > 0
                                  ? '+'
                                  : entry.value < 0
                                  ? '−'
                                  : ''}${entry.value.abs()}',
                            ),
                            key: ValueKey('petition-impact-${entry.key}'),
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 23,
                              height: 1.3,
                              color: _color(entry.key, entry.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Color _color(String key, int value) {
    if (value == 0) return muted;
    final inverse = [
      'stress',
      'fatigue',
      'illness',
      'war',
      'debt',
      'goldDebt',
      'revel',
      'plotReduce',
    ].contains(key);
    return (inverse ? value < 0 : value > 0) ? forest : terracotta;
  }
}

class ApprovalBrush extends CustomPainter {
  const ApprovalBrush();
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = terracotta
          ..strokeCap = StrokeCap.square
          ..strokeWidth = 3;
    canvas.drawLine(
      Offset(3, size.height - 3),
      Offset(size.width - 3, 3),
      paint,
    );
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width - 5, 1),
      paint,
    );
    canvas.drawLine(Offset(7, size.height), Offset(size.width, 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
