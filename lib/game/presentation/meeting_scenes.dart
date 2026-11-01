import '../models/game_state.dart';
import '../logic/harem_rules.dart';
import '../logic/currency_rules.dart';
import '../logic/court_rules.dart';
import '../logic/management_rules.dart';
import '../logic/investigation_rules.dart';
import 'widgets/character_meeting_page.dart';
import 'meeting_assets.dart';

/// Full-body art follows the saved face, including recruits and replacements.
String meetingCharacterAsset(Courtier person) =>
    meetingCharacterAssets[person.resolvedPortraitId]!;

MeetingScene meetingSceneFor(Courtier person, {GameState? state}) {
  final harem = person.isConsort;
  final post =
      state == null
          ? null
          : managementPost(courtOfficeFor(state, person.id)?.id ?? '');
  return MeetingScene(
    backgroundAsset:
        harem
            ? 'assets/images/harem-interior.webp'
            : 'assets/images/people-interior.webp',
    characterAsset: meetingCharacterAsset(person),
    name: person.name,
    role: person.displayRole,
    grade: person.grade > 0 && !harem ? person.grade : null,
    haremRank: harem ? person.category : null,
    age: person.age,
    affection: person.affection,
    ability: person.abilityScore,
    contributions:
        state == null ? const [] : personMeetingContributions(person, state),
    contributionCondition:
        harem
            ? 'Điều kiện chung: đã nhập cung, thiện cảm >70 và năng lực >60.'
            : post != null
            ? 'Năng lực >${post.abilityThreshold}, thiện cảm >${post.affectionThreshold}. ${post.growthLabel}.'
            : 'Nhất phẩm: năng lực ≥90, thiện cảm ≥80. Nhị phẩm: năng lực ≥80, thiện cảm ≥70. Cần giữ chức trọn mùa.',
    contributionHint:
        harem && !person.inHarem && person.available
            ? 'Kích hoạt sau khi trở thành Phi tần'
            : null,
    contributionTitle: harem ? 'Đóng góp hậu cung' : 'Đóng góp chức vụ',
    investigatedPlot: person.lastInvestigation?.plot,
    investigatedDiscontent: person.lastInvestigation?.discontent,
    investigatedAt:
        person.lastInvestigation == null || state == null
            ? null
            : state.calendarText(
              '${state.date(person.lastInvestigation!.week)}${person.evidenceTurn == 0 ? '' : ' · Bằng chứng ${state.week >= evidenceExpires(state, person) ? 'đã hết hạn' : 'hiệu lực tới trước ${state.date(evidenceExpires(state, person))}'}'}',
            ),
    location:
        harem ? 'Cung Ngọc Hoa · Hậu cung' : 'Phủ Bá Quan · ${person.category}',
    description: _meetingIntroduction(person),
  );
}

List<MeetingContribution> personMeetingContributions(
  Courtier person,
  GameState state,
) {
  if (person.isConsort) return haremMeetingContributions(person, state);
  final office = courtOfficeFor(state, person.id);
  if (office == null || !state.hasCourtSystem) return const [];
  final post = managementPost(office.id);
  if (post != null) {
    final active = managementDirection(state, post) == 1;
    return [
      MeetingContribution(
        title: '${post.role} · ${post.areaName}',
        effect: post.effect(),
        summary: '${post.areaName}: ${post.effect()}',
        status:
            active
                ? 'Đang hoạt động'
                : 'Cần năng lực >${post.abilityThreshold}, thiện cảm >${post.affectionThreshold}',
        active: active,
      ),
    ];
  }
  final reason = courtPassiveBlocked(state, office);
  return [
    for (final benefit in courtPassives(office))
      MeetingContribution(
        title: 'Đóng góp chức ${office.role}',
        effect: '${benefit.label} ${benefit.effect}',
        summary: '${benefit.label} ${benefit.effect}',
        status: reason ?? 'Đang hoạt động',
        active: reason == null,
      ),
  ];
}

String _meetingIntroduction(Courtier person) {
  if (person.id == 'consort_lan') {
    return 'Ngọc Lan tính tình ôn hòa, giỏi thu xếp công việc. '
        'Nàng luôn giữ phong thái điềm đạm và chỉn chu trong cách ứng xử.';
  }
  return '${person.name} thuộc phe ${person.faction}, có sở trường ${person.specialty.toLowerCase()}. '
      'Qua những lần tiếp xúc, bệ hạ đã biết tính cách: ${person.knownPersonalityText.toLowerCase()}.';
}

List<MeetingContribution> haremMeetingContributions(
  Courtier person,
  GameState state,
) {
  if (!state.seasonal || !person.isConsort) return const [];
  final contributions = HaremBenefits(state).contributions;
  return [
    for (final passive in haremPassives(person))
      _haremContribution(person, state, passive, contributions),
  ];
}

MeetingContribution _haremContribution(
  Courtier person,
  GameState state,
  HaremPassive passive,
  List<HaremContribution> contributions,
) {
  final active = passive.eligible(person);
  final treasury = passive.benefit == HaremBenefit.treasury;
  String amount(int value) =>
      treasury ? '${moneyText(state, money(state, value))}/mùa' : '$value/mùa';
  final ability = passive.queenBonus ? queenPassiveAbility : 60;
  final missing = [
    if (person.age < 18) 'cần đủ 18 tuổi',
    if (person.affection <= 70) 'cần thiện cảm >70',
    if (person.ability <= ability) 'cần năng lực >$ability',
  ];
  var status =
      !person.available
          ? 'Không hoạt động · Đã rời hậu cung'
          : !person.inHarem
          ? 'Có thể kích hoạt sau khi trở thành Phi tần'
          : active
          ? 'Đang hoạt động'
          : 'Chưa kích hoạt · ${missing.join(', ')}';
  final actual =
      contributions
          .where(
            (c) =>
                c.person.id == person.id &&
                c.passive.queenBonus == passive.queenBonus,
          )
          .firstOrNull;
  if (active && actual != null && actual.amount < actual.requested) {
    status += ' · Thực nhận +${amount(actual.amount)} (giới hạn toàn hậu cung)';
  }
  return MeetingContribution(
    title:
        passive.queenBonus
            ? 'Đóng góp bổ sung của Hoàng hậu'
            : 'Đóng góp của Phi tần',
    effect:
        '${treasury ? 'Gia sản gia tộc' : passive.benefit.label} +${amount(passive.value(person))}',
    summary:
        '${treasury
            ? 'Ngân khố'
            : passive.benefit == HaremBenefit.stability
            ? 'Ổn định'
            : passive.benefit.label} +${amount(active && actual != null ? actual.amount : passive.value(person))}',
    status: status,
    condition:
        passive.queenBonus
            ? 'Điều kiện riêng: Hoàng hậu và năng lực >$ability.'
            : null,
    enhancement:
        !treasury && person.affection <= 95
            ? 'Thiện cảm >95: tăng lên +2/mùa.'
            : null,
    active: active,
  );
}
