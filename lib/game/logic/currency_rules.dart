import '../models/currency_format.dart';
export '../models/currency_format.dart';
import '../models/game_state.dart';
import '../models/event_definition.dart';

int moneyScale(GameState s) => s.goldStandard ? 100 : 1;
int money(GameState s, num base) =>
    (base.abs() * moneyScale(s)).ceil() * base.sign.toInt();
String moneyUnit(GameState s) => s.goldStandard ? 'lượng vàng' : 'tiền';
String moneyText(GameState s, num actual) =>
    '${moneyNumber(actual)} ${moneyUnit(s)}';

/// Only authored, old-denomination text enters this formatter. Already-native
/// transaction amounts must use moneyText or moneyUnit instead.
String authoredMoneyText(GameState s, String text) =>
    s.goldStandard ? convertAuthoredMoneyText(text) : text;

/// Authored treasury/debt effects are base denominations. Native gold keys
/// make repeated projection and delayed settlement safe and idempotent.
Map<String, int> currencyEffects(GameState s, Map<String, int> source) =>
    !s.goldStandard
        ? source
        : {
          for (final e in source.entries)
            (e.key == 'treasury'
                    ? 'gold'
                    : e.key == 'debt'
                    ? 'goldDebt'
                    : e.key):
                ['treasury', 'debt'].contains(e.key)
                    ? money(s, e.value)
                    : e.value,
        };

EventDefinition currencyEvent(GameState s, EventDefinition e) {
  if (!s.goldStandard) return e;
  return EventDefinition(
    e.id,
    e.title,
    authoredMoneyText(s, e.body),
    e.category,
    [
      for (final c in e.choices)
        if (c.currencyNative)
          c
        else
          EventChoice(
            authoredMoneyText(s, c.label),
            authoredMoneyText(s, c.hint),
            currencyEffects(s, c.effects),
            cost: money(s, c.cost),
            grainCost: c.grainCost,
            points: c.points,
            followup: c.followup,
            delay: c.delay,
            laterEffects: currencyEffects(s, c.laterEffects),
            laterFailureEffects: currencyEffects(s, c.laterFailureEffects),
            successChance: c.successChance,
            economy: c.economy,
            troops: c.troops,
            combat: c.combat,
            naval: c.naval,
            nativeResources: c.nativeResources,
            currencyNative: true,
          ),
    ],
    condition: e.condition,
    cooldown: e.cooldown,
    minWeek: e.minWeek,
    family: e.family,
    trigger: e.trigger,
    foodCostsNative: e.foodCostsNative,
  );
}
