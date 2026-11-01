import '../data/reign_content.dart';
import '../data/expanded_events.dart' show eventEffectText;
import '../models/game_state.dart';
import 'currency_rules.dart';
import '../models/event_definition.dart';
import 'population_rules.dart';

bool usesChainSettlement(StoryArc arc) => arc.settlementVersion >= 1;
ChainDefinition chainDefinitionFor(StoryArc arc) =>
    usesChainSettlement(arc)
        ? chainDefinition(arc.kind)
        : legacyChainDefinition(arc.kind);

bool harmonyConsort(Courtier c) =>
    c.available && c.isConsort && c.inHarem && !c.queen && c.age >= 18;

List<(Courtier, Courtier)> harmonyPairs(GameState s) {
  final people = s.court.where(harmonyConsort).toList();
  return [
    for (var i = 0; i < people.length; i++)
      for (var j = i + 1; j < people.length; j++)
        if (people[i].faction != people[j].faction) (people[i], people[j]),
  ];
}

String? harmonyUnavailable(GameState s, StoryArc arc) {
  if (arc.participantIds.length != 2 ||
      arc.participantFactions.length != 2 ||
      arc.participantIds.toSet().length != 2 ||
      arc.participantFactions.toSet().length != 2) {
    return 'Cần hai phi tần đã nhập cung, thuộc hai phe khác nhau. Hãy dừng chuỗi để quyết toán.';
  }
  for (var i = 0; i < 2; i++) {
    final c = s.court.where((c) => c.id == arc.participantIds[i]).firstOrNull;
    if (c == null ||
        !harmonyConsort(c) ||
        c.faction != arc.participantFactions[i]) {
      return 'Phi tần liên quan đã rời vị trí hoặc đổi phe; dừng chuỗi để quyết toán, không tự thay người.';
    }
  }
  return null;
}

String chainParticipantName(GameState s, StoryArc arc, int index) {
  final id = arc.participantIds.length > index ? arc.participantIds[index] : '';
  final c = s.court.where((c) => c.id == id).firstOrNull;
  final faction =
      arc.participantFactions.length > index
          ? arc.participantFactions[index]
          : '?';
  return '${c?.name ?? 'Phi tần ${index == 0 ? 'A' : 'B'}'} (phe $faction)';
}

String chainParticipantText(GameState s, StoryArc arc, String text) => text
    .replaceAll('{A}', chainParticipantName(s, arc, 0))
    .replaceAll('{B}', chainParticipantName(s, arc, 1));

Map<String, int> chainChoiceEffects(StoryArc arc, EventChoice c) => {
  for (final e in c.effects.entries)
    if (!['faction:A', 'faction:B'].contains(e.key)) e.key: e.value,
  if (arc.participantFactions.length == 2)
    for (var i = 0; i < 2; i++)
      if (c.effects.containsKey(i == 0 ? 'faction:A' : 'faction:B'))
        'faction:${arc.participantFactions[i]}':
            c.effects[i == 0 ? 'faction:A' : 'faction:B']!,
};

bool chainChoiceAbandons(StoryArc arc, int index) =>
    arc.kind != 'haremHarmony' && index == 0;
int chainStepValue(StoryArc arc) =>
    chainDefinition(
      arc.kind,
    ).stages[arc.stage].choices[arc.kind == 'haremHarmony' ? 2 : 1].cost *
    arc.currencyScale;

int _resourceValue(GameState s, String key) => switch (key) {
  'authority' => s.authority,
  'stability' => s.stability,
  'people' => s.people,
  'army' => s.army,
  'health' => s.health,
  'grain' => s.grain,
  'treasury' || 'gold' => s.treasury,
  'levee' => s.levee,
  _ when key.startsWith('faction:') => s.factions[key.substring(8)] ?? 0,
  _ => 0,
};

String? chainSettlementChoiceBlocked(GameState s, StoryArc arc, int index) {
  if (s.points < 1) return 'Cần 1 hành động để xác nhận.';
  if (chainChoiceAbandons(arc, index)) return null;
  if (arc.kind == 'haremHarmony') {
    final reason = harmonyUnavailable(s, arc);
    if (reason != null) return reason;
  }
  final c = chainDefinition(arc.kind).stages[arc.stage].choices[index];
  if (s.treasury < money(s, c.cost)) {
    return 'Không đủ ngân khố để cấp ${moneyText(s, money(s, c.cost))}.';
  }
  for (final e in chainChoiceEffects(
    arc,
    c,
  ).entries.where((e) => e.value < 0)) {
    final remaining =
        _resourceValue(s, e.key) +
        (e.key == 'treasury' ? money(s, e.value) : e.value);
    final terminal = [
      'authority',
      'stability',
      'people',
      'army',
      'health',
    ].contains(e.key);
    if (remaining < 0 || (terminal && remaining == 0)) {
      return 'Không đủ chỉ số để trả đầy đủ: ${eventEffectText({e.key: e.value})}. Các chỉ số sống còn phải còn trên 0.';
    }
  }
  return null;
}

StoryArc projectedChainChoice(StoryArc arc, int index) {
  final next = StoryArc.fromJson(arc.toJson());
  if (!chainChoiceAbandons(arc, index)) {
    next.completedSteps++;
    next.investedValue += chainStepValue(arc);
    next.decisions = [...next.decisions, index];
  }
  return next;
}

int chainMoneyPercent(int completed, [int version = 1]) =>
    (version >= 2
        ? const [0, 0, 40, 75, 140]
        : const [0, 0, 50, 100, 250])[completed.clamp(0, 4)];
int chainRewardPercent(int completed, [int version = 1]) =>
    (version >= 2
        ? const [0, 0, 15, 35, 100]
        : const [0, 0, 20, 40, 100])[completed.clamp(0, 4)];

Map<String, int> chainSettlementEffects(StoryArc arc) {
  final d = chainDefinition(arc.kind);
  if (d.economic) {
    final money =
        arc.investedValue *
        chainMoneyPercent(arc.completedSteps, arc.settlementVersion) ~/
        100;
    return {
      if (money > 0) (arc.currencyScale == 100 ? 'gold' : 'treasury'): money,
    };
  }
  final percent = chainRewardPercent(arc.completedSteps, arc.settlementVersion);
  return {
    for (final e in d.rewards.entries)
      if ((e.key != 'war' || arc.completedSteps == 4) &&
          e.value.abs() * percent ~/ 100 > 0)
        e.key:
            ((e.key == 'army' && arc.settlementVersion >= 2
                    ? e.value.abs() * .6
                    : e.value.abs()) *
                percent ~/
                100) *
            e.value.sign,
  };
}

Map<String, Map<String, int>> chainSettlementPersonEffects(StoryArc arc) {
  final d = chainDefinition(arc.kind);
  final ids =
      arc.kind == 'haremHarmony'
          ? arc.participantIds
          : [if (arc.subjectId.isNotEmpty) arc.subjectId];
  final percent = chainRewardPercent(arc.completedSteps, arc.settlementVersion);
  final favored =
      arc.decisions.where((i) => i == 0).length >= 3
          ? 0
          : arc.decisions.where((i) => i == 1).length >= 3
          ? 1
          : -1;
  return {
    for (var i = 0; i < ids.length; i++)
      ids[i]: {
        for (final e in d.personRewards.entries)
          if (e.value.abs() * percent ~/ 100 > 0)
            e.key:
                (() {
                  var amount = e.value;
                  if (arc.kind == 'haremHarmony' && favored >= 0) {
                    if (e.key == 'affection') amount = i == favored ? 12 : 3;
                    if (e.key == 'discontent') amount = i == favored ? -15 : -5;
                  }
                  return (amount.abs() * percent ~/ 100) * amount.sign;
                })(),
      },
  };
}

String chainSettlementRewardText(GameState s, StoryArc arc) {
  final texts = <String>[];
  final raw = chainSettlementEffects(arc);
  final effects =
      s.population == null
          ? raw
          : populationEffects(
            raw,
            context: 'Quyết toán: ${chainDefinition(arc.kind).title}',
            challenging: s.challengingEconomy,
          );
  if (effects.isNotEmpty) texts.add(eventEffectText(effects));
  for (final p in chainSettlementPersonEffects(arc).entries) {
    final c = s.court.where((c) => c.id == p.key && c.available).firstOrNull;
    if (c == null || p.value.isEmpty) continue;
    final labels = {
      'ability': 'năng lực',
      'affection': 'thiện cảm',
      'discontent': 'bất mãn',
      'loyalty': 'trung thành',
    };
    texts.add(
      '${c.name}: ${p.value.entries.map((e) => '${labels[e.key]} ${e.value >= 0 ? '+' : '−'}${e.value.abs()}').join(', ')}',
    );
  }
  if (arc.kind == 'exams' && arc.completedSteps == 4) {
    texts.add('Thêm 1 ứng viên năng lực 80–90 để tự bổ nhiệm');
  }
  return texts.isEmpty ? 'Không có phần thưởng.' : texts.join(' · ');
}

String chainSettlementSummary(GameState s, StoryArc arc) {
  final d = chainDefinition(arc.kind);
  final full = StoryArc.fromJson(arc.toJson())..completedSteps = 4;
  for (var i = arc.stage; i < 4; i++) {
    full.investedValue +=
        d.stages[i].choices[arc.kind == 'haremHarmony' ? 2 : 1].cost *
        arc.currencyScale;
  }
  final paid =
      arc.resourceCosts.isEmpty
          ? ''
          : '\nChỉ số đã đánh đổi: ${eventEffectText({for (final e in arc.resourceCosts.entries) e.key: -e.value})}.';
  return 'Đã hoàn thành ${arc.completedSteps}/4 · đã cấp ${arc.cashSpent} ${moneyUnit(s)} · tổng chi phí quy đổi ${arc.investedValue}.$paid\n'
      'Dừng hiện tại nhận: ${chainSettlementRewardText(s, arc)}\n'
      'Dự kiến hoàn thành 4/4: ${chainSettlementRewardText(s, full)}\n'
      '${d.economic ? 'Quyết toán trên vốn đã thực hiện' : 'Thưởng theo tiến độ'}: '
      '${[for (var n = 1; n <= 4; n++) '$n/4 = ${d.economic ? chainMoneyPercent(n, arc.settlementVersion) : chainRewardPercent(n, arc.settlementVersion)}%'].join(', ')}. '
      '${d.economic ? 'Tổng tiền nhận, chưa trừ vốn đã chi.' : 'Ứng viên và giảm chiến tranh chỉ mở ở 4/4.'}\n'
      'Chi phí trả ngay. Chỉ nhận phần thưởng khi dừng hoặc hoàn thành chuỗi; quá hạn sẽ dừng và quyết toán.';
}
