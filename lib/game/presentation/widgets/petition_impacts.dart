import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../data/content.dart';
import '../../models/game_state.dart';
import 'imperial_assets.dart';
import 'imperial_theme.dart';

/// Display-only values from the already resolved choice. No random rolls,
/// save writes, or future/conditional rewards are folded into immediate effects.
class PetitionImpacts extends StatelessWidget {
  const PetitionImpacts({super.key, required this.state, required this.choice});
  final GameState state;
  final EventChoice choice;

  static const labels = {
    'treasury': 'Ngân khố',
    'gold': 'Ngân khố',
    'goldDebt': 'Nợ',
    'grain': 'Lương thực',
    'food': 'Lương thực',
    'training': 'Huấn luyện',
    'equipment': 'Quân khí',
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
  Widget _icon(String key) {
    if (key.startsWith('faction:') || key.startsWith('affection:')) {
      return const ImperialIcon('faction', size: 27);
    }
    final imperial = switch (key) {
      'points' => 'action',
      'treasury' || 'cost' || 'gold' || 'debt' || 'goldDebt' => 'treasury',
      'grain' || 'food' || 'grainCost' => 'grain',
      'population' ||
      'settlers' ||
      'refugees' ||
      'returnees' ||
      'displaced' => 'citizens',
      'people' || 'authority' || 'stability' || 'health' => key,
      'army' ||
      'troops' ||
      'war' ||
      'training' ||
      'equipment' ||
      'morale' ||
      'logistics' => 'army',
      'disease' => 'illness',
      'levee' || 'fatigue' || 'stress' || 'illness' || 'rest' || 'revel' => key,
      'plotReduce' => 'scroll',
      _ => 'decision',
    };
    return ImperialIcon(imperial, size: 27);
  }

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
          label: state.goldStandard ? 'Ngân khố' : 'Chi tiền',
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
        final textScale = MediaQuery.textScalerOf(context).scale(18) / 18;
        final columns = bounds.maxWidth >= 520 * textScale ? 2 : 1;
        final itemWidth =
            columns == 1
                ? bounds.maxWidth
                : ((bounds.maxWidth - 12 * (columns - 1)) / columns)
                    .clamp(0.0, 320 * textScale)
                    .toDouble();

        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final entry in values)
              Container(
                key: ValueKey('petition-impact-row-${entry.key}'),
                width: itemWidth,
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: paper.withValues(alpha: .35),
                  border: Border.all(color: line.withValues(alpha: .6)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    _icon(entry.key),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formatGameNumbers(entry.label),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 13,
                          color: ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (itemWidth - 20) * .45,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatGameNumbers(
                            '${entry.value > 0
                                ? '+'
                                : entry.value < 0
                                ? '−'
                                : ''}${entry.value.abs()}',
                          ),
                          key: ValueKey('petition-impact-${entry.key}'),
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 18,
                            height: 1.3,
                            color: _color(entry.key, entry.value),
                          ),
                        ),
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
