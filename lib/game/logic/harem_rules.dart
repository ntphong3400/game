import 'currency_rules.dart';
import '../models/game_state.dart';

const haremStatCap = 3;
const haremTreasuryCap = 20;
const queenPassiveAbility = 90;

const haremExpulsionFactionLoss = 2;
const haremExpulsionStabilityLoss = 0;

String haremStabilityEffectText(int loss) =>
    loss == 0 ? '$stabilityLabel không đổi' : '$stabilityLabel −$loss';

String haremDemotionAffectionText(Courtier c) =>
    c.affection == 100
        ? 'Thiện cảm giữ ở 100'
        : 'Thiện cảm −${haremDemotionLosses(c).affection}';

/// Losses are positive amounts; the engine and confirmation use the same values.
({int affection, int discontent, int faction, int stability})
haremDemotionLosses(Courtier c) =>
    c.queen
        ? (
          affection: c.affection == 100 ? 0 : 30,
          discontent: 30,
          faction: 12,
          stability: 8,
        )
        : (
          affection: c.affection == 100 ? 0 : 20,
          discontent: 20,
          faction: 8,
          stability: 0,
        );

String? haremDisciplineBlocked(Courtier c, {required bool expel}) {
  if (!c.available) return 'Nhân vật không còn hiện diện.';
  if (!c.isConsort) return 'Chỉ áp dụng cho nhân vật hậu cung.';
  if (expel && (c.inHarem || c.queen)) {
    return 'Chỉ trục xuất Tú nữ';
  }
  if (!expel && !c.inHarem) return 'Tú nữ không thể giáng chức';
  return null;
}

String? haremPromotionBlocked(GameState s, Courtier c) =>
    (s.cooldowns['harem-demotion:${c.id}'] ?? 0) > s.week
        ? 'Chỉ tuyển hoặc sắc phong lại từ ${s.date(s.cooldowns['harem-demotion:${c.id}']!)}.'
        : null;

enum HaremBenefit {
  authority('Uy quyền'),
  people('Lòng dân'),
  stability(stabilityLabel),
  treasury('Ngân khố');

  const HaremBenefit(this.label);
  final String label;
  int get cap => this == treasury ? haremTreasuryCap : haremStatCap;
}

class HaremPassive {
  const HaremPassive(this.benefit, {this.queenBonus = false});
  final HaremBenefit benefit;
  final bool queenBonus;

  bool eligible(Courtier c) =>
      c.isConsort &&
      c.available &&
      c.inHarem &&
      c.age >= 18 &&
      c.affection > 70 &&
      c.ability > 60 &&
      (!queenBonus || (c.queen && c.ability > queenPassiveAbility));

  int value(Courtier c) =>
      benefit == HaremBenefit.treasury
          ? 10
          : c.affection > 95
          ? 2
          : 1;
}

/// Passive identity is fixed by public character data and the stable ID. It
/// never consumes RNG or reveals a hidden personality, and survives reloads.
HaremBenefit primaryHaremBenefit(Courtier c) {
  final knownTrait = c.personalities.first;
  if (['Thế gia', 'Hoàng tộc'].contains(c.faction) &&
      (knownTrait == Personality.familyFirst ||
          personalitySeed(c.id) % 3 == 0)) {
    return HaremBenefit.treasury;
  }
  return switch (knownTrait) {
    Personality.compassionate ||
    Personality.honest ||
    Personality.impartial ||
    Personality.upright => HaremBenefit.people,
    Personality.decisive ||
    Personality.disciplined ||
    Personality.hotTempered ||
    Personality.fameSeeking ||
    Personality.reckless => HaremBenefit.authority,
    _ => HaremBenefit.stability,
  };
}

List<HaremPassive> haremPassives(Courtier c, {bool asQueen = false}) {
  if (!c.isConsort) return const [];
  final primary = primaryHaremBenefit(c);
  return [
    HaremPassive(primary),
    if (c.queen || asQueen)
      HaremPassive(
        primary == HaremBenefit.stability
            ? HaremBenefit.authority
            : HaremBenefit.stability,
        queenBonus: true,
      ),
  ];
}

class HaremContribution {
  const HaremContribution(
    this.person,
    this.passive,
    this.requested,
    this.amount,
  );
  final Courtier person;
  final HaremPassive passive;
  final int requested, amount;
  String get description =>
      '${person.name}${passive.queenBonus ? ' (Hoàng hậu · bổ sung)' : ''}: '
      '${passive.benefit.label} +$amount'
      '${amount < requested ? ' (gốc +$requested, giới hạn toàn hậu cung)' : ''}';
}

class HaremBenefits {
  HaremBenefits(GameState s) {
    if (!s.seasonal) return;
    final people =
        s.court.where((c) => c.isConsort && c.available && c.inHarem).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    for (final c in people) {
      for (final passive in haremPassives(c)) {
        if (!passive.eligible(c)) continue;
        final requested = passive.value(c);
        final amount = requested.clamp(
          0,
          passive.benefit.cap - total(passive.benefit),
        );
        contributions.add(HaremContribution(c, passive, requested, amount));
        _totals[passive.benefit] = total(passive.benefit) + amount;
      }
    }
  }

  final List<HaremContribution> contributions = [];
  final Map<HaremBenefit, int> _totals = {};
  int total(HaremBenefit benefit) => _totals[benefit] ?? 0;
  String get summary =>
      HaremBenefit.values.map((b) => '${b.label} +${total(b)}').join(' · ');
}

String haremPassivePreview(
  Courtier c, {
  bool asQueen = false,
  GameState? state,
}) {
  final lines = <String>[];
  for (final passive in haremPassives(c, asQueen: asQueen)) {
    final benefit = passive.benefit;
    final effect =
        benefit == HaremBenefit.treasury
            ? 'Gia sản gia tộc: +${state == null ? 10 : money(state, 10)} ${state?.goldStandard == true ? 'lượng vàng' : 'Ngân khố'}/mùa'
            : '+1 ${benefit.label}/mùa; thiện cảm >95: +2';
    final reason =
        !c.available
            ? 'đã rời hậu cung'
            : !c.inHarem
            ? 'sau khi nhập cung'
            : c.ability <= 60
            ? 'cần năng lực >60'
            : c.affection <= 70
            ? 'cần thiện cảm >70'
            : passive.queenBonus &&
                (!c.queen || c.ability <= queenPassiveAbility)
            ? 'cần là Hoàng hậu và năng lực >$queenPassiveAbility'
            : 'đang hoạt động';
    lines.add(
      '${passive.queenBonus ? 'Đóng góp bổ sung của Hoàng hậu: ' : ''}$effect ($reason).',
    );
  }
  if (!c.queen && !asQueen) {
    final extra = haremPassives(c, asQueen: true).last;
    lines.add(
      'Khi phong hậu, năng lực >$queenPassiveAbility: thêm ${extra.benefit.label}.',
    );
  }
  lines.add(
    'Điều kiện: đã nhập cung, thiện cảm >70 và năng lực >60.'
    '${c.queen || asQueen ? ' Đóng góp thứ hai cần năng lực >$queenPassiveAbility.' : ''}',
  );
  return lines.join('\n');
}
