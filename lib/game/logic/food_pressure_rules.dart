import 'dart:math' as math;
import '../models/game_state.dart';
import '../models/event_definition.dart';
import 'population_rules.dart';
import '../data/expanded_events.dart' show eventEffectText;
import '../data/reign_content.dart';

bool isProductionCrisis(GameState s, MajorMission m) =>
    s.foodPressureEnabled &&
    ['disaster', 'economy'].contains(majorDefinition(m.kind).group);
int crisisProductionPercent(MajorMission m, int choice) =>
    choice == 1 ? (m.severity >= 4 ? 15 : 12) : (m.severity >= 4 ? 30 : 25);
bool isOrdinaryProductionDisaster(EventDefinition e) =>
    e.category == 'Thiên tai' || e.id == 'flood' || e.trigger == 'flood';
String ordinaryDisasterHint(GameState s, EventDefinition e, int index) =>
    !s.foodPressureEnabled || !isOrdinaryProductionDisaster(e) || index == 0
        ? ''
        : index == e.choices.length - 1
        ? 'Bỏ mặc làm năng suất giảm 25% mùa này và mùa sau; mùa sau sẽ trình nhu cầu cứu trợ.'
        : 'Ứng phó một phần: năng suất giảm 12% trong mùa này.';
String crisisProductionHint(GameState s, MajorMission m, int choice) =>
    !isProductionCrisis(s, m) || choice == 0
        ? ''
        : 'Năng suất giảm ${crisisProductionPercent(m, choice)}% ${choice == 1 ? 'trong mùa này' : 'trong mùa này và mùa sau; mùa sau sẽ trình nhu cầu cứu trợ'}. '
            'Tổng ảnh hưởng đến nông nghiệp giới hạn 35%, không sửa ngược mùa đã chốt.';

int warProductionLoss(GameState s) {
  if (!s.foodPressureEnabled) return 0;
  final enemy = s.warfare?.active;
  if (enemy == null) return 0;
  return s.week - enemy.warStarted >= 2 || enemy.advantage <= -30 ? 20 : 10;
}

/// Independent shocks multiply; the combined agricultural loss is capped at 35%.
double foodProductionLoss(GameState s) {
  if (!s.foodPressureEnabled) return 0;
  var remaining = 1 - warProductionLoss(s) / 100;
  for (final effect in s.foodDisruptions.where((e) => e.active(s.week))) {
    remaining *= 1 - effect.percent / 100;
  }
  return math.min(35, (1 - remaining) * 100);
}

String foodPressureHint(GameState s) {
  if (!s.foodPressureEnabled) return '';
  final effects = s.foodDisruptions.where((e) => e.active(s.week));
  return 'Gián đoạn mùa này giảm ${foodProductionLoss(s).toStringAsFixed(1)}% năng suất '
      '(giới hạn 35%). Dân phu đang huy động ${whole(s.population!.campaignWorkers)} người. '
      '${warProductionLoss(s) == 0 ? '' : 'Chiến tranh: giảm ${warProductionLoss(s)}%. '}'
      '${effects.map((e) => '${e.title}: −${e.percent}%, đến hết ${s.date(e.until)}').join('; ')}';
}

/// Apply once to already-native amounts, shared by preview and execution.
EventDefinition foodCostEvent(GameState s, EventDefinition e) {
  if (!s.foodPressureEnabled || e.foodCostsNative) return e;
  final choices = <EventChoice>[];
  for (var i = 0; i < e.choices.length; i++) {
    final c = e.choices[i];
    final food = (c.grainCost * 1.25).ceil();
    final effects = Map<String, int>.of(c.effects);
    // Last, unfunded fallback losses are consequences, not a voluntary expense.
    final loss = effects['food'] ?? 0;
    if (loss < 0 &&
        (i < e.choices.length - 1 || c.cost > 0 || c.grainCost > 0)) {
      effects['food'] = -(-loss * 1.25).ceil();
    }
    var hint = c.hint;
    if (food != c.grainCost) {
      for (final old in {whole(c.grainCost), '${c.grainCost}'}) {
        hint = hint.replaceAll(
          RegExp('(?<![\\d.])${RegExp.escape(old)}(?=\\s+tạ)'),
          whole(food),
        );
      }
    }
    if (effects['food'] != c.effects['food']) {
      hint = hint.replaceAll(
        eventEffectText({'food': loss}),
        eventEffectText({'food': effects['food']!}),
      );
    }
    if (['flood', 'hunger'].contains(e.id) && c.grainCost > 0) {
      hint +=
          ' Tối đa ${whole(math.min(c.grainCost, remainingFoodConsumption(s)))} tạ khẩu phần '
          'được đối trừ tiêu dùng toàn quốc khi khép mùa; hậu cần là chi phí bổ sung.';
    }
    choices.add(
      EventChoice(
        c.label,
        hint,
        effects,
        cost: c.cost,
        grainCost: food,
        points: c.points,
        followup: c.followup,
        delay: c.delay,
        laterEffects: c.laterEffects,
        laterFailureEffects: c.laterFailureEffects,
        successChance: c.successChance,
        economy: c.economy,
        troops: c.troops,
        combat: c.combat,
        naval: c.naval,
        nativeResources: c.nativeResources,
        currencyNative: c.currencyNative,
      ),
    );
  }
  return EventDefinition(
    e.id,
    e.title,
    e.body,
    e.category,
    choices,
    condition: e.condition,
    cooldown: e.cooldown,
    minWeek: e.minWeek,
    family: e.family,
    trigger: e.trigger,
    foodCostsNative: true,
  );
}

bool isFoodRecoveryEvent(String id) => id.startsWith('food_recovery:');
String foodRecoveryId(FoodDisruption e) => 'food_recovery:${e.id}';
bool foodRecoveryDue(GameState s, FoodDisruption e) =>
    s.foodPressureEnabled &&
    e.active(s.week) &&
    e.start < s.week &&
    e.lastReliefTurn < s.week;
int recoveryRations(GameState s, FoodDisruption e) =>
    foodAmount(s.population!.population * .9 * e.percent / 100);

EventDefinition? foodRecoveryEvent(GameState s, String id) {
  if (!isFoodRecoveryEvent(id)) return null;
  final effect =
      s.foodDisruptions.where((e) => foodRecoveryId(e) == id).firstOrNull;
  if (effect == null) return null;
  final base = recoveryRations(s, effect), full = (base * 1.25).ceil();
  return EventDefinition(
    id,
    'Tiếp tục cứu trợ: ${effect.title}',
    'Hậu quả còn ảnh hưởng sản xuất đến hết ${s.date(effect.until)}. '
        'Quyết định hỗ trợ mùa này; không tự xuất lương khi chuyển mùa. '
        'Khẩu phần đã cấp được đối trừ tiêu dùng toàn quốc; phần vận chuyển và hao hụt là chi phí bổ sung.',
    'Dân sinh',
    [
      EventChoice(
        'Cứu trợ đầy đủ và khôi phục sản xuất',
        'Xuất ${whole(full)} tạ, gồm ${whole(base)} tạ khẩu phần và ${whole(full - base)} tạ hậu cần. '
            'Dừng tổn thất sản xuất từ mùa này; lòng dân +2; 1 hành động.',
        const {'people': 2},
        grainCost: full,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Cứu trợ một phần',
        'Xuất ${whole((full / 2).ceil())} tạ; khẩu phần ${whole((base / 2).ceil())} tạ được đối trừ. '
            'Giảm một nửa tổn thất sản xuất còn lại; 1 hành động.',
        const {},
        grainCost: (full / 2).ceil(),
        points: 1,
        nativeResources: true,
      ),
      const EventChoice(
        'Chưa cấp cứu trợ',
        'Không xuất lương; giữ tổn thất sản xuất theo lịch, lòng dân −2; 1 hành động khi chủ động ngự phê.',
        {'people': -2},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'storyOnly',
    foodCostsNative: true,
  );
}
