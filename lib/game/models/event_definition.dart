/// Seasonal economics are authored per decision, independent of its wording.
class PetitionEconomy {
  const PetitionEconomy.investment(this.seasonalRevenue) : isRecovery = false;
  const PetitionEconomy.recovery(this.seasonalRevenue) : isRecovery = true;
  final int seasonalRevenue;
  final bool isRecovery;
}

class EventChoice {
  const EventChoice(
    this.label,
    this.hint,
    this.effects, {
    this.cost = 0,
    this.grainCost = 0,
    this.points = 0,
    this.followup = '',
    this.delay = 0,
    this.laterEffects = const {},
    this.laterFailureEffects = const {},
    this.successChance = 100,
    this.economy,
    this.troops = 0,
    this.combat = '',
    this.naval = false,
    this.nativeResources = false,
    this.currencyNative = false,
  });
  final String label, hint, followup;
  final Map<String, int> effects, laterEffects, laterFailureEffects;
  final int cost, grainCost, points, delay, successChance;
  final PetitionEconomy? economy;
  final int troops;
  final String combat;
  final bool naval;
  final bool nativeResources;
  final bool currencyNative;
}

class EventDefinition {
  const EventDefinition(
    this.id,
    this.title,
    this.body,
    this.category,
    this.choices, {
    this.condition = 'any',
    this.cooldown = 16,
    this.minWeek = 1,
    this.family = '',
    this.trigger = '',
  });
  final String id, title, body, category, condition, family, trigger;
  final List<EventChoice> choices;
  final int cooldown, minWeek;
}
