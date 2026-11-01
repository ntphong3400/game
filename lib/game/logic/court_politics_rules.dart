import 'currency_rules.dart';
import '../models/game_state.dart';

/// Grievances are personal, public, and evolve independently of affection.
int discontentChange(GameState s, Courtier c) {
  final mood = s.factions[c.faction] ?? 50;
  final pressure =
      (c.affection < 25
          ? 4
          : c.affection < 40
          ? 2
          : 0) +
      (mood < 30
          ? 3
          : mood < 40
          ? 1
          : 0) +
      (c.strain >= 60 ? 2 : 0) +
      s.neglectedWeeks.clamp(0, 3) +
      (s.debt > money(s, 30) ? 1 : 0);
  // Seasons need a stronger buildup than legacy weekly turns. Positive
  // pressure is faster; ordinary calming retains its existing pace.
  if (pressure > 0) return pressure * (s.seasonal ? 3 : 1);
  return c.personalities.contains(Personality.resentful) ? -1 : -2;
}

bool hasPlotMotive(Courtier c) =>
    c.discontent >= discontentPlotThreshold && c.loyalty < 57;

bool isCoupPlot(Courtier c) =>
    hasPlotMotive(c) && (c.politicalAmbition ?? 0) > 60;

int plotProgressPerTurn(GameState s, Courtier c) =>
    (s.seasonal ? 4 : 1) +
    ((c.discontent - c.loyalty) ~/ (s.seasonal ? 15 : 18)).clamp(0, 100) +
    (isCoupPlot(c) ? (c.politicalAmbition! - 60) ~/ 15 : 0) +
    (s.stability < 35 ? 2 : 0) +
    (s.authority < 30 ? 2 : 0) +
    s.neglectedWeeks.clamp(0, 4);
