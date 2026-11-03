import 'package:flutter/material.dart';
import '../../data/harem_quests.dart';
import '../../logic/currency_rules.dart';
import '../../logic/harem_rules.dart';
import '../../logic/court_rules.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'imperial_dialog.dart';
import 'imperial_room.dart';
import 'imperial_theme.dart';

class HaremQuestPanel extends StatelessWidget {
  const HaremQuestPanel({
    super.key,
    required this.state,
    required this.onSend,
    this.onPerson,
    this.onOffice,
    this.personId,
    this.busy = false,
  });
  final GameState state;
  final Future<bool> Function(String personId, String option) onSend;
  final ValueChanged<Courtier>? onPerson;
  final ValueChanged<CourtOffice>? onOffice;
  final String? personId;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final residents =
        state.court
            .where((c) => c.isConsort && c.available && c.inHarem)
            .toList();
    residents.sort(
      (a, b) =>
          a.id == b.id
              ? 0
              : a.id == personId
              ? -1
              : b.id == personId
              ? 1
              : a.id.compareTo(b.id),
    );
    final benefits = HaremBenefits(state);
    return RoomPane(
      key: const ValueKey('harem-quest-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Câu chuyện hậu cung',
            style: TextStyle(fontFamily: 'Lora', fontSize: 27),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tag('Hậu cung ${haremResidentCount(state)}/$haremLimit'),
              for (final benefit in HaremBenefit.values)
                Tag(
                  '${benefit.label}: +${benefit == HaremBenefit.treasury ? money(state, benefits.total(benefit)) : benefits.total(benefit)}'
                  '/${benefit == HaremBenefit.treasury ? money(state, benefit.cap) : benefit.cap}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(
              'Mở câu chuyện cá nhân ở thiện cảm ≥60; hoàn thành và thiện cảm >70 để đóng góp. '
              'Hoàng hậu có tuyến riêng ở thiện cảm ≥85. Tối đa một chương/người/mùa. '
              'Trì hoãn không bị phạt nhiệm vụ; sinh hoạt thường lệ vẫn tính.',
            ),
            style: const TextStyle(fontSize: 12),
          ),
          if (residents.length > haremLimit)
            const Text(
              'Bản lưu cũ vượt 10 người: khóa tuyển thêm; chỉ 10 người đóng góp, luôn gồm Hoàng hậu.',
              style: TextStyle(color: terracotta),
            ),
          const SizedBox(height: 12),
          if (residents.isEmpty) const Text('Chưa có người nhập cung.'),
          for (final c in residents) ...[
            Surface(
              padding: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatGameNumbers(
                          '${c.name} · ${c.displayRole} · Thiện cảm ${c.affection}',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 19,
                        ),
                      ),
                      if (onPerson != null)
                        TextButton(
                          onPressed: busy ? null : () => onPerson!(c),
                          child: const Text('Gặp nhân vật'),
                        ),
                    ],
                  ),
                  Text(
                    'Tính cách đã biết: ${c.knownPersonalityText}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    formatGameNumbers(haremPassivePreview(c, state: state)),
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (c.affection < 60 && haremQuestFor(state, c.id) == null)
                    const Text('Cần thiện cảm ≥60 để mở câu chuyện cá nhân.'),
                  for (final queen in [
                    false,
                    if (c.queen ||
                        haremQuestFor(state, c.id, queen: true) != null)
                      true,
                  ])
                    _quest(context, c, queen),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _quest(BuildContext context, Courtier c, bool queen) {
    final q = haremQuestFor(state, c.id, queen: queen);
    if (q == null) {
      return queen
          ? const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Tuyến Hoàng hậu mở sau câu chuyện cá nhân và khi thiện cảm ≥85.',
            ),
          )
          : const SizedBox.shrink();
    }
    final d = haremQuestDefinition(q.definitionId);
    final prefix = '${c.id}-${queen ? 'queen' : 'personal'}';
    final passive = haremPassives(c, asQueen: queen)[queen ? 1 : 0];
    final actual =
        HaremBenefits(state).contributions
            .where((x) => x.person.id == c.id && x.passive.queenBonus == queen)
            .firstOrNull;
    final amount = actual?.amount ?? 0;
    final forecast =
        passive.benefit == HaremBenefit.treasury
            ? money(state, amount)
            : amount;
    final status = haremPassiveBlocked(state, c, queen: queen);
    final office =
        state.courtOffices.where((o) => o.id == q.officeId).firstOrNull;
    final target = haremQuestPerson(state, q.targetId);
    final current = HaremBenefits(state);
    final projected = HaremBenefits(
      state,
      previewPersonId: c.id,
      previewQueen: queen,
      excludePersonId:
          d.objective == HaremObjective.removeConsort ? q.targetId : '',
    );
    final projectedAmount =
        projected.contributions
            .where((x) => x.person.id == c.id && x.passive.queenBonus == queen)
            .firstOrNull
            ?.amount ??
        0;
    final gain =
        projected.total(passive.benefit) - current.total(passive.benefit);
    final lost = current.contributions
        .where((x) => x.person.id == q.targetId && x.amount > 0)
        .map(
          (x) =>
              '${x.passive.benefit.label} +${x.passive.benefit == HaremBenefit.treasury ? money(state, x.amount) : x.amount}/mùa',
        )
        .join(', ');
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        key: ValueKey('harem-quest-$prefix'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${queen ? 'Hoàng hậu' : 'Cá nhân'} · ${d.id} · ${d.title}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            formatGameNumbers(
              'Tiến độ ${q.stage}/3 · ${d.conflict ? 'Tuyến xung đột' : 'Tuyến thông thường'}',
            ),
          ),
          Text(
            formatGameNumbers(
              'Đóng góp thực nhận hiện tại: +$forecast ${passive.benefit.label}/mùa. '
              '${status ?? (amount == 0 ? 'Đủ điều kiện nhưng đã chạm giới hạn hoặc vượt 10 người.' : 'Đang hoạt động.')}',
            ),
          ),
          Text(
            formatGameNumbers(
              'Khi đủ điều kiện: +${passive.benefit == HaremBenefit.treasury ? money(state, 10) : passive.value(c)} '
              '${passive.benefit.label}/mùa, chịu trần toàn hậu cung.',
            ),
          ),
          Text(
            formatGameNumbers(
              'Dự kiến sau hoàn thành và đủ thiện cảm: thực nhận '
              '+${passive.benefit == HaremBenefit.treasury ? money(state, projectedAmount) : projectedAmount}/mùa. '
              'Tổng ${passive.benefit.label} thay đổi ${gain >= 0 ? '+' : '−'}'
              '${passive.benefit == HaremBenefit.treasury ? money(state, gain.abs()) : gain.abs()}/mùa '
              'với những người đang hoạt động; không giả định họ cùng mở khóa trong tương lai.',
            ),
            style: const TextStyle(fontSize: 12, color: forest),
          ),
          if (q.choices.isNotEmpty)
            Text(
              formatGameNumbers(
                'Lựa chọn đã lưu: ${q.choices.join(' → ')}. '
                '${q.choices.last == 'A' ? 'Chương trước dùng kinh phí để thu xếp và hạn chế xáo trộn.' : 'Chương trước tiết giảm kinh phí và chấp nhận phản ứng chính trị.'}',
              ),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          if (d.conflict) ...[
            const SizedBox(height: 6),
            Text(formatGameNumbers(haremQuestGoal(state, c, q))),
            if (target != null && target.isConsort)
              Text(
                formatGameNumbers(
                  'Giá phải trả khi đưa ${target.name} ra khỏi cung: '
                  '${lost.isEmpty ? 'hiện không còn đóng góp thực nhận' : 'mất $lost'}; '
                  '${haremDemotionAffectionText(target)}, bất mãn +${haremDemotionLosses(target).discontent}, '
                  'phe ${target.faction} −${haremDemotionLosses(target).faction}. '
                  'Giảm ${moneyText(state, money(state, 6))} sinh hoạt/mùa.',
                ),
              ),
            if (target != null && !target.isConsort && office != null)
              Text(
                formatGameNumbers(
                  'Mục tiêu: ${target.name}, ${office.role}, ${courtGradeName(office.grade)}; '
                  'năng lực ${target.abilityLabel}, chuyên môn ${target.specialty}. '
                  'Thôi chức làm mất người đang đảm nhiệm; mức xáo trộn vị trí −${courtOfficeDisruption(office)} ổn định. '
                  'Phí bổ nhiệm, phản ứng phe và ảnh hưởng ghế trống được xem trước ở thao tác nhân sự riêng.',
                ),
              ),
            Text(
              formatGameNumbers(
                'Xác minh: ${q.verifiedSeasons}/${d.requiredSeasons} mùa đầy đủ. '
                'Phí, hành động và hậu quả thay nhân sự tính riêng; không được hoàn lại.',
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                if (target != null && target.available && onPerson != null)
                  TextButton(
                    onPressed: busy ? null : () => onPerson!(target),
                    child: const Text('Xem mục tiêu'),
                  ),
                if (office != null && onOffice != null)
                  TextButton(
                    onPressed: busy ? null : () => onOffice!(office),
                    child: const Text('Bổ nhiệm / điều chuyển'),
                  ),
              ],
            ),
          ],
          if (!q.completed && q.refusedUntil > 0) ...[
            Text(
              formatGameNumbers(
                'Đã từ chối. Tiếp tục cùng tuyến từ ${state.date(q.refusedUntil)}.',
              ),
            ),
            OutlinedButton(
              key: ValueKey('quest-resume-$prefix'),
              onPressed:
                  busy || state.week < q.refusedUntil || (queen && !c.queen)
                      ? null
                      : () => onSend(
                        c.id,
                        '${queen ? 'queen' : 'personal'}:resume',
                      ),
              child: const Text('Tiếp tục cùng tuyến'),
            ),
          ] else if (!q.completed) ...[
            const SizedBox(height: 8),
            Text(
              'Chương ${q.stage + 1}: ${d.chapters[q.stage].title}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(haremQuestText(state, c, q, d.chapters[q.stage].body)),
            const SizedBox(height: 8),
            for (final choice in ['A', if (!d.conflict) 'B']) ...[
              _choice(context, c, q, choice, prefix),
              const SizedBox(height: 6),
            ],
            if (d.conflict)
              TextButton(
                key: ValueKey('quest-refuse-$prefix'),
                onPressed:
                    busy || (queen && !c.queen)
                        ? null
                        : () => _confirm(context, c, q, 'refuse'),
                child: Text(
                  'Từ chối yêu cầu · thiện cảm ${c.affection == 100 ? 'giữ ở 100' : '−${queen ? 12 : 8}'}',
                ),
              ),
            const Text(
              'Có thể để lúc khác; tuyến và tiến độ được giữ nguyên.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _choice(
    BuildContext context,
    Courtier c,
    HaremQuest q,
    String choice,
    String prefix,
  ) {
    final d = haremQuestDefinition(q.definitionId);
    final blocked = haremChapterBlocked(state, c, q, choice);
    final label =
        choice == 'A'
            ? d.chapters[q.stage].choiceA
            : d.chapters[q.stage].choiceB;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          key: ValueKey('quest-choice-$prefix-$choice'),
          onPressed:
              busy || blocked != null
                  ? null
                  : () => _confirm(context, c, q, choice),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              formatGameNumbers(
                '$choice · $label\n${moneyText(state, haremChapterCost(state, q, choice))} · 1 hành động\n'
                '${haremChoiceConsequence(state, q, choice)}',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (blocked != null)
          Text(
            formatGameNumbers(blocked),
            style: const TextStyle(fontSize: 11, color: terracotta),
          ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    Courtier c,
    HaremQuest q,
    String choice,
  ) async {
    final d = haremQuestDefinition(q.definitionId);
    final refuse = choice == 'refuse';
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => ImperialAlertDialog(
            key: const ValueKey('harem-quest-confirmation'),
            title: Text(
              refuse ? 'Từ chối yêu cầu?' : d.chapters[q.stage].title,
            ),
            content: Text(
              formatGameNumbers(
                refuse
                    ? 'Thiện cảm ${c.affection == 100 ? 'giữ ở 100' : '−${q.queen ? 12 : 8}'}. '
                        'Không đổi tuyến; chờ hai mùa để tiếp tục. Phí đã trả không hoàn lại.'
                    : '${moneyText(state, haremChapterCost(state, q, choice))} · 1 hành động.\n'
                        '${haremChoiceConsequence(state, q, choice)}\n'
                        '${!d.conflict && choice == 'B' && q.stage == 2 && (d.stat == 'authority' ? state.authority : state.stability) <= d.statLoss ? 'Chỉ số sẽ về 0 và kết thúc lượt trị vì.' : ''}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Để lúc khác'),
              ),
              FilledButton(
                key: const ValueKey('confirm-harem-quest'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
    if (accepted == true) {
      await onSend(c.id, '${q.queen ? 'queen' : 'personal'}:$choice');
    }
  }
}
