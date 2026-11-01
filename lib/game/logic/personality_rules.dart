import '../models/game_state.dart';
import 'currency_rules.dart';

/// Actual execution sees all traits. Public estimates see discovered traits and
/// neutral values for uninvestigated loyalty/integrity, never hidden information.
class PersonalityAssessment {
  PersonalityAssessment(
    Courtier officer,
    GameState? state, {
    this.knownOnly = false,
  }) : officer = Courtier.fromJson(officer.toJson()),
       factionMood = state?.factions[officer.faction] ?? 50,
       tax = state?.effectiveTax,
       scarce =
           state != null &&
           (state.treasury < money(state, 80) || state.grain < 30);
  final Courtier officer;
  final int factionMood;
  final int? tax;
  final bool scarce;
  final bool knownOnly;
  bool has(Personality p) =>
      (knownOnly ? officer.knownPersonalities : officer.personalities).contains(
        p,
      );
  int get integrity =>
      knownOnly && !officer.investigated ? 50 : officer.integrity;
  int get loyalty => knownOnly && !officer.investigated ? 50 : officer.loyalty;
  double get cooperation {
    final factionWeight =
        has(Personality.impartial)
            ? .08
            : has(Personality.partisan)
            ? .45
            : .25;
    final personalWeight = has(Personality.resentful) ? .5 : .35;
    final relation =
        (loyalty * .4 +
            officer.affection * personalWeight +
            factionMood * factionWeight) /
        (.4 + personalWeight + factionWeight);
    return (relation - officer.discontent * .2).clamp(0, 100);
  }

  int get cooperationModifier => ((cooperation - 50) * .4).round();

  int successModifier(String task, int fit) {
    var value = cooperationModifier;
    if (has(Personality.dutiful)) value += 4 + officer.strain ~/ 20;
    if (has(Personality.negligent)) value -= 12;
    if (has(Personality.cautious)) value += 4;
    if (has(Personality.reckless)) value -= 5;
    if (has(Personality.decisive)) {
      value += ['train', 'security', 'relief', 'repair'].contains(task) ? 7 : 2;
    }
    if (has(Personality.disciplined)) value += 4;
    if (has(Personality.flexible)) {
      if (fit == 20) value += 10;
      if (scarce) {
        value += 4;
      }
    }
    if (has(Personality.conservative)) value += fit == 100 ? 5 : -8;
    if (has(Personality.upright)) {
      if (task == 'security') value += 7;
      if (task == 'collect_arrears' || tax == 2) value -= 5;
    }
    if (has(Personality.diplomatic) &&
        ['diplomacy', 'mediate'].contains(task)) {
      value += 10;
    }
    if (has(Personality.hotTempered)) {
      value +=
          task == 'train'
              ? 6
              : ['diplomacy', 'mediate'].contains(task)
              ? -12
              : -2;
    }
    if (has(Personality.compassionate)) {
      if (['relief', 'farm', 'buy_grain', 'repair'].contains(task)) value += 7;
      if (task == 'collect_arrears' || tax == 2) value -= 7;
    }
    if (has(Personality.familyFirst)) value += factionMood >= 60 ? 4 : -4;
    if (has(Personality.fameSeeking)) {
      value +=
          ['repair', 'farm', 'commerce', 'train', 'security'].contains(task)
              ? 5
              : 0;
    }
    return value;
  }

  int rewardModifier(String task) =>
      (has(Personality.dutiful) ? 6 : 0) +
      (has(Personality.negligent) ? -15 : 0) +
      (has(Personality.cautious) ? -5 : 0) +
      (has(Personality.reckless) ? 15 : 0) +
      (has(Personality.compassionate) && ['relief', 'farm'].contains(task)
          ? 10
          : 0);

  int get severeMargin => (15 +
          (has(Personality.cautious) ? 12 : 0) -
          (has(Personality.reckless) ? 10 : 0))
      .clamp(5, 35);
  int get corruptionChance => ((70 - integrity) * .7 +
          (has(Personality.greedy) ? 18 : 0) +
          (has(Personality.familyFirst) ? 8 : 0) -
          (has(Personality.honest) ? 25 : 0) -
          (has(Personality.impartial) ? 8 : 0))
      .round()
      .clamp(0, 70);
  int get lossPercent =>
      (15 + (100 - integrity) ~/ 3 + (has(Personality.greedy) ? 10 : 0)).clamp(
        15,
        60,
      );
  int get sabotageChance =>
      officer.discontent >= discontentPlotThreshold && loyalty < 57
          ? ((officer.discontent - 50) / 4).round().clamp(0, 15)
          : 0;
}

String personalityWorkHint(GameState s, Courtier c) {
  final mood = s.factions[c.faction] ?? 50;
  final risk = PersonalityAssessment(c, s, knownOnly: true).corruptionChance;
  return 'Phe ${c.faction}: $mood/100 · thiện cảm ${c.affection}/100 · bất mãn ${c.discontent}/100. '
      '${c.discontent >= discontentPlotThreshold ? 'Bất mãn cao làm giảm hợp tác; trung thành thấp có nguy cơ cố ý phá việc. ' : ''}'
      'Đã biết: ${c.knownPersonalityText}. '
      'Ước tính nguy cơ thất thoát: ${risk >= 30
          ? 'cao'
          : risk >= 10
          ? 'vừa'
          : 'thấp'}. '
      '${c.allPersonalitiesKnown && c.investigated ? 'Đã xác minh phẩm chất.' : 'Dự báo chỉ dựa trên điều đã biết; phẩm chất chưa rõ có thể đổi kết quả.'}';
}
