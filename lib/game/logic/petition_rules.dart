import '../data/expanded_events.dart' show eventEffectText;
import '../models/event_definition.dart';
import '../models/game_state.dart';
import 'currency_rules.dart';
import 'dart:math' as math;

const _higherIsBetter = {
  'treasury',
  'grain',
  'people',
  'authority',
  'army',
  'stability',
  'health',
  'levee',
  'plotReduce',
};
const _lowerIsBetter = {'debt', 'fatigue', 'stress', 'illness', 'war', 'siege'};
const petitionAuditCost = 20;
const petitionAuditMinimum = 60;
const petitionAuditMaximum = 90;
const _specialEffects = {
  'repair': 'Bắt đầu tu bổ đê; kết quả tùy người phụ trách',
  'peace': 'Chấm dứt chiến tranh và giải vây',
  'taxNormal': 'Chọn mức thuế vừa cho kỳ thu tới',
  'revealCandidates': 'Thêm ứng viên hậu cung vào danh sách tiến cử',
  'recruitConsort':
      'Nhận ứng viên làm tú nữ (chưa nhập cung) · cùng phe +3, phe đối lập −5',
  'rejectConsort': 'Phe đối lập +3, cùng phe −5',
};
String _effectHint(Map<String, int> effects) => [
  if (effects.keys.any((k) => !_specialEffects.containsKey(k)))
    eventEffectText(
      Map.fromEntries(
        effects.entries.where((e) => !_specialEffects.containsKey(e.key)),
      ),
    ),
  for (final key in effects.keys)
    if (_specialEffects.containsKey(key)) _specialEffects[key]!,
  if (effects.isEmpty) 'Không đổi chỉ số ngay',
].join(' · ');

const _followupHints = {
  'school': 'Lòng dân +4, uy quyền +1',
  'trade': 'Doanh thu 70–95 tiền, chưa trừ vốn đã chi',
  'weapons': 'Quân lực +8',
  'audit':
      'Nếu xác minh được: thu hồi $petitionAuditMinimum–$petitionAuditMaximum tiền, uy quyền +2; có thể chưa đủ chứng cứ',
  'security':
      'Nếu xác minh được: mỗi âm mưu giảm tối đa 6; có thể chưa đủ chứng cứ',
  'envoy': 'Kết quả tùy người phụ trách Ngoại giao; có thể thất bại',
};

bool _benefit(String key, int value) =>
    ((_higherIsBetter.contains(key) ||
            key.startsWith('faction:') ||
            key.startsWith('affection:')) &&
        value > 0) ||
    (_lowerIsBetter.contains(key) && value < 0);

bool _drawback(String key, int value) =>
    !['treasury', 'grain', 'debt'].contains(key) &&
    (((_higherIsBetter.contains(key) ||
                key.startsWith('faction:') ||
                key.startsWith('affection:')) &&
            value < 0) ||
        (_lowerIsBetter.contains(key) && value > 0) ||
        (key == 'revel' && value > 0));

/// Includes the current closing tick: recovery next season, investment W + 2.
int petitionDelay(GameState s, EventChoice c) {
  if (!s.seasonal) return c.delay;
  if (c.economy != null) return c.economy!.isRecovery ? 2 : 3;
  if (c.followup == 'trade') return 3;
  // Diplomatic decisions with incidental money retain their existing cadence.
  if ((c.laterEffects['gold'] ?? c.laterEffects['treasury'] ?? 0) > 0) {
    return 5;
  }
  if (['audit', 'security'].contains(c.followup)) return 2;
  return s.workTurns(c.delay);
}

EventChoice seasonalPetitionChoice(GameState s, EventChoice c) {
  if (!s.seasonal || c.nativeResources) return c;
  Map<String, int> reduced(Map<String, int> source) => {
    for (final e in source.entries)
      e.key:
          !_benefit(e.key, e.value)
              ? e.value
              : e.key == 'plotReduce'
              ? (e.value * .4).floor().clamp(1, 4)
              : math.max(
                    1,
                    (e.value.abs() * (e.key == 'treasury' ? .75 : .65)).floor(),
                  ) *
                  e.value.sign,
  };
  final effects = reduced(c.effects);
  final later = reduced(c.laterEffects);
  final failure = Map<String, int>.of(c.laterFailureEffects);
  if (c.economy != null) {
    later['treasury'] = c.economy!.seasonalRevenue;
    if ((failure['treasury'] ?? 0) < 0) failure.remove('treasury');
    for (final key in ['people', 'authority', 'stability']) {
      if ((failure[key] ?? 0) < 0) failure[key] = -1;
    }
  }
  final immediateMoney = effects['treasury'] ?? 0;
  if (immediateMoney > 0 &&
      (effects['debt'] ?? 0) <= 0 &&
      (c.laterEffects['treasury'] ?? 0) <= 0 &&
      c.followup.isEmpty) {
    effects['treasury'] = (immediateMoney * 1.35 / 5).round() * 5;
  }
  final hasBenefit =
      c.effects.entries.any((e) => _benefit(e.key, e.value)) ||
      c.laterEffects.entries.any((e) => _benefit(e.key, e.value)) ||
      [
        'school',
        'trade',
        'weapons',
        'security',
        'audit',
        'envoy',
      ].contains(c.followup) ||
      c.effects.containsKey('repair');
  final hasDrawback =
      c.effects.entries.any((e) => _drawback(e.key, e.value)) ||
      c.laterEffects.entries.any((e) => _drawback(e.key, e.value));
  final riskyInvestment =
      (c.laterEffects['treasury'] ?? 0) > 0 && c.successChance < 100;
  // Safe, broadly beneficial decisions carry a real resource premium.
  var cost =
      c.followup == 'audit'
          ? petitionAuditCost
          : c.followup == 'trade'
          ? (c.cost * 1.5).ceil()
          : hasBenefit && !hasDrawback && !riskyInvestment && c.cost > 0
          ? (c.cost * 2).clamp(40, 999)
          : c.cost;
  if (s.challengingEconomy) {
    if (c.economy != null) {
      // Invest real working capital; repeated high-return micro-investments
      // must not outperform maintaining the kingdom without any exposure.
      cost = cost.clamp(25, 999);
      final ceiling = (cost * (c.economy!.isRecovery ? 2.2 : 1.7)).floor();
      later['treasury'] = c.economy!.seasonalRevenue.clamp(0, ceiling);
    } else if (hasBenefit &&
        !hasDrawback &&
        !riskyInvestment &&
        c.cost > 0 &&
        !['audit', 'trade'].contains(c.followup)) {
      cost = (c.cost * 1.5).ceil().clamp(30, 999);
    }
    // Remove the old blanket cash bonus, retaining the authored trade-offs.
    if (immediateMoney > 0 &&
        (effects['debt'] ?? 0) <= 0 &&
        (c.laterEffects['treasury'] ?? 0) <= 0 &&
        c.followup.isEmpty) {
      effects['treasury'] = immediateMoney;
    }
  }
  final grain =
      hasBenefit && !hasDrawback && c.grainCost > 0
          ? (c.grainCost * 1.5).ceil()
          : c.grainCost;
  if (hasBenefit && !hasDrawback && cost == 0 && grain == 0) {
    effects.update('stress', (v) => v + 2, ifAbsent: () => 2);
  }
  final due = s.date(s.week + petitionDelay(s, c) - 1);
  final hint = [
    if (cost > 0) 'Chi $cost',
    if (grain > 0) 'xuất $grain lương thực',
    _effectHint(effects),
    if (c.followup.isNotEmpty)
      'Nhận kết quả cuối $due: ${_followupHints[c.followup] ?? c.followup}',
    if (later.isNotEmpty)
      'Cuối $due: ${c.successChance}% thành công: ${_effectHint(later)}.'
          '${c.successChance < 100 ? ' Thất bại: ${_effectHint(failure)}.' : ''}',
  ].join(' · ');
  return EventChoice(
    c.label,
    hint,
    effects,
    cost: cost,
    grainCost: grain,
    points: c.points,
    followup: c.followup,
    delay: c.delay,
    laterEffects: later,
    laterFailureEffects: failure,
    successChance: c.successChance,
    economy: c.economy,
  );
}

/// Monetary preview only; other benefits/penalties remain in the choice hint.
String? petitionMoneyPreview(GameState s, EventChoice c) {
  if (!s.seasonal) return null;
  final direct = c.effects['gold'] ?? c.effects['treasury'] ?? 0;
  final later = c.laterEffects['gold'] ?? c.laterEffects['treasury'] ?? 0;
  final audit = c.followup == 'audit', trade = c.followup == 'trade';
  if (direct <= 0 && later <= 0 && !audit && !trade) return null;
  final capital = c.cost + (direct < 0 ? -direct : 0);
  if (later <= 0 && !audit && !trade) {
    return (c.effects['goldDebt'] ?? c.effects['debt'] ?? 0) > 0
        ? 'Nhận $direct ${moneyUnit(s)} ngay · phát sinh ${c.effects['goldDebt'] ?? c.effects['debt']} nợ.'
        : 'Tiền nhận ngay $direct · sau phí ${_signedMoney(direct - c.cost)}.';
  }
  final minimum =
      audit
          ? money(s, petitionAuditMinimum)
          : trade
          ? money(s, 70)
          : later;
  final maximum =
      audit
          ? money(s, petitionAuditMaximum)
          : trade
          ? money(s, 95)
          : later;
  String range(int low, int high) => low == high ? '$low' : '$low–$high';
  final due = s.date(s.week + petitionDelay(s, c) - 1);
  final risky = audit || c.successChance < 100;
  final failureMoney =
      c.laterFailureEffects['gold'] ?? c.laterFailureEffects['treasury'] ?? 0;
  final extraLoss = failureMoney < 0 ? -failureMoney : 0;
  return [
    'Vốn/phí ứng $capital ${moneyUnit(s)}',
    '${risky ? 'Thành công: ' : ''}nhận ${range(minimum, maximum)} ${moneyUnit(s)}, lãi sau vốn ${range(direct + minimum - c.cost, direct + maximum - c.cost)} ${moneyUnit(s)}',
    if (risky)
      'Thất bại: mất $capital ${moneyUnit(s)} đã ứng${extraLoss > 0 ? ', trừ thêm $extraLoss ${moneyUnit(s)}' : ', không phạt thêm ${moneyUnit(s)}'}',
    'Nhận kết quả cuối $due',
  ].join(' · ');
}

String _signedMoney(int value) => value >= 0 ? '+$value' : '$value';
