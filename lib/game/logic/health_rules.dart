import 'currency_rules.dart';
import '../models/game_state.dart';
import 'personnel_rules.dart' show roleEffect;

const treatmentHealthRecovery = 2;
const treatmentFatigueRecovery = 12;

int treatmentIllnessRecovery(GameState s) {
  final doctor = s.officerForRole('Ngự y');
  return doctor == null
      ? 5
      : roleEffect(doctor, 'Y thuật', 8 + doctor.ability ~/ 10);
}

String treatmentActionDescription(
  GameState s, {
  required int baseCost,
  required int cost,
}) {
  return 'Chi $cost ${moneyUnit(s)} · 1 hành động · sức khỏe +$treatmentHealthRecovery · '
      'mức bệnh −${treatmentIllnessRecovery(s)} · mệt mỏi −$treatmentFatigueRecovery. '
      'Hiệu quả áp dụng ngay.';
}

int restFatigueRecovery(GameState s) => s.seasonal ? 16 : 19;
const restStressRecovery = 8;
const seasonalRevelFatigueRecovery = 16;
const seasonalRevelStressRecovery = 16;
const seasonalRepeatRevelFatiguePenalty = 8;
const seasonalRepeatRevelStressPenalty = 4;
const excessRevelFatigue = 7;

int revelFatigueRecovery(GameState s, int count) =>
    s.seasonal && count > 0
        ? count * seasonalRevelFatigueRecovery -
            (count * (count - 1) ~/ 2) * seasonalRepeatRevelFatiguePenalty
        : 0;

int revelStressRecovery(GameState s, int count) =>
    count <= 0
        ? 0
        : s.seasonal
        ? count * seasonalRevelStressRecovery -
            (count * (count - 1) ~/ 2) * seasonalRepeatRevelStressPenalty
        : count * 9;

String? careActionDescription(GameState s, String action) {
  final text = _baseCareActionDescription(s, action);
  return text == null ? null : authoredMoneyText(s, text);
}

String? _baseCareActionDescription(
  GameState s,
  String action,
) => switch (action) {
  'rest' =>
    'Miễn phí · 1 hành động · mệt mỏi −${restFatigueRecovery(s)} · căng thẳng −$restStressRecovery. Hiệu quả áp dụng khi khép ${s.periodName}.',
  'revel' when s.seasonal =>
    'Chi 18 tiền · 1 hành động · lần ${s.revelThisWeek + 1} mùa này: '
        'mệt mỏi ${_signed(-seasonalRevelFatigueRecovery + s.revelThisWeek * seasonalRepeatRevelFatiguePenalty)} · '
        'căng thẳng ${_signed(-seasonalRevelStressRecovery + s.revelThisWeek * seasonalRepeatRevelStressPenalty)}. '
        'Hiệu quả áp dụng khi khép mùa. Mỗi lần tiếp theo tăng thêm +$seasonalRepeatRevelFatiguePenalty mệt, +$seasonalRepeatRevelStressPenalty căng thẳng so với lần trước. '
        'Tiệc nhiều và hưởng lạc tích lũy vẫn gây hại sức khỏe.',
  'revel' =>
    'Chi 18 tiền · 1 hành động · căng thẳng −9. Hiệu quả áp dụng khi khép tuần. Từ lần 2: mệt +$excessRevelFatigue/lần và gây hại sức khỏe; hưởng lạc tích lũy vẫn gây hại.',
  _ => null,
};

String _signed(int value) =>
    value < 0
        ? '−${-value}'
        : value > 0
        ? '+$value'
        : '0';
