import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import 'imperial_dialog.dart';
import '../../logic/population_rules.dart';
import '../../data/content.dart';
import '../../models/game_state.dart';
import '../../logic/petition_assignment_rules.dart';
import '../../logic/chain_settlement_rules.dart';
import '../../logic/court_personnel_rules.dart';
import '../../logic/court_rules.dart';
import '../../data/court_personnel_petitions.dart';
import 'imperial_theme.dart';
import 'imperial_assets.dart';
import 'petition_art.dart';
import 'petition_impacts.dart';
import '../../data/expanded_events.dart' show eventEffectText;

class PetitionDecision extends StatefulWidget {
  const PetitionDecision({
    super.key,
    required this.state,
    required this.petition,
    required this.pickAssignee,
    required this.onConfirm,
    required this.onReadLater,
    this.inDialog = false,
    this.busy = false,
  });
  final GameState state;
  final Petition petition;
  final Future<String?> Function(EventDefinition, EventChoice) pickAssignee;
  final Future<bool> Function(int, String) onConfirm;
  final VoidCallback onReadLater;
  final bool inDialog, busy;
  @override
  State<PetitionDecision> createState() => _PetitionDecisionState();
}

class _PetitionDecisionState extends State<PetitionDecision> {
  GameState get s => widget.state;
  Petition get petition => widget.petition;
  CourtPersonnelMatter? get matter =>
      courtMatterForEvent(s, petition.definitionId);
  EventDefinition get e =>
      matter == null
          ? eventForState(s, petition.definitionId)
          : courtPersonnelEvent(s, matter!, nomineeId: assigneeId);
  StoryArc? get arc =>
      s.chains.where((a) => a.id == petition.storyId).firstOrNull;
  bool get settlement => arc != null && usesChainSettlement(arc!);
  int? selected;
  String assigneeId = '';
  bool submitting = false;
  Courtier? person() => s.court.where((c) => c.id == assigneeId).firstOrNull;

  // Existing eligibility checks, now with a visible reason for each disabled
  // choice. Selection and expansion never send a game command.
  String? blockedReason(int index) {
    if (index < 0) {
      return settlement && s.points >= 1
          ? null
          : 'Cần 1 hành động để xác nhận.';
    }
    if (matter != null) {
      return courtPersonnelChoiceBlocked(
        s,
        matter!,
        index,
        nomineeId: assigneeId,
      );
    }
    final c = e.choices[index];
    if (s.population != null && c.troops > s.population!.availableSoldiers) {
      return 'Cần ${whole(c.troops)} quân rảnh; hiện có ${whole(s.population!.availableSoldiers)}.';
    }
    if (settlement) {
      final reason = chainSettlementChoiceBlocked(s, arc!, index);
      if (reason != null) return reason;
    }
    if (s.treasury < c.cost) {
      return 'Thiếu ${c.cost - s.treasury} ${moneyUnit(s)} để chọn phương án này.';
    }
    if (s.grain < c.grainCost) {
      return 'Thiếu ${c.grainCost - s.grain} lương thực để chọn phương án này.';
    }
    final points = petitionPoints(s, c);
    if (s.points < points) return 'Cần $points hành động để xác nhận.';
    return null;
  }

  bool enabled(int index) => blockedReason(index) == null;

  String detailHint(int index) {
    final c = e.choices[index];
    var hint = petitionChoiceHint(s, e, c, person: person());
    if (petitionCanAssign(s, c)) {
      final chance = petitionChance(s, e, c, person());
      // The assignee control below owns the person and current probability.
      // Keep conditional outcomes in the explanation without repeating it.
      final suffix =
          ' · ${person()?.name ?? 'Không giao ai'}: $chance% thành công';
      if (hint.endsWith(suffix)) {
        hint = hint.substring(0, hint.length - suffix.length);
      }
      hint = hint.replaceAll('$chance% thành công', 'Nếu thành công');
    }
    final numeric = {
      for (final effect in c.effects.entries)
        if (PetitionImpacts.labels.containsKey(effect.key) ||
            effect.key.startsWith('faction:') ||
            effect.key.startsWith('affection:'))
          s
              .authoredText(eventEffectText({effect.key: effect.value}))
              .toLowerCase(),
      'chi ${c.cost}',
      'chi ${c.cost} ${moneyUnit(s)}',
      'xuất ${c.grainCost} lương thực',
      '${petitionPoints(s, c)} hành động',
      'không đổi chỉ số ngay',
    };
    return hint
        .split(' · ')
        .where((part) {
          final normalized =
              part.trim().replaceFirst(RegExp(r'\.$'), '').toLowerCase();
          return !numeric.contains(normalized);
        })
        .join(' · ');
  }

  Widget choiceDetails(int index) {
    final c = e.choices[index];
    final detail = detailHint(index);
    return Container(
      key: ValueKey('petition-details-$index'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: const Color(0x55C4CFAC),
        border: Border.all(color: const Color(0xFFB6C09D)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tác động khi ngự phê',
            style: TextStyle(fontFamily: 'Lora', fontSize: 14, color: forest),
          ),
          const SizedBox(height: 8),
          if (matter != null && courtMatterNeedsNominee(matter!, index)) ...[
            OutlinedButton(
              key: const ValueKey('personnel-nominee-picker'),
              onPressed:
                  widget.busy || submitting ? null : _pickPersonnelNominee,
              child: Text(
                formatGameNumbers(
                  courtPerson(s, assigneeId)?.name ?? 'Chọn người để bổ nhiệm',
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          PetitionImpacts(state: s, choice: c),
          if (matter != null &&
              (c.effects['stability'] ?? 0) < 0 &&
              s.stability + (c.effects['stability'] ?? 0) <= 0)
            const Text(
              'CẢNH BÁO: phương án này làm ổn định về 0 và kết thúc lượt chơi.',
              style: TextStyle(color: terracotta),
            ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              formatGameNumbers(detail),
              key: ValueKey('petition-choice-detail-$index'),
              style: const TextStyle(fontSize: 12, height: 1.7, color: muted),
            ),
          ],
          if (petitionCanAssign(s, c)) ...[
            const SizedBox(height: 14),
            Text(
              formatGameNumbers(
                'Người xử lý · chuyên môn ${petitionSpecialty(e, c)}',
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const ValueKey('petition-assignee'),
              onPressed:
                  widget.busy || submitting
                      ? null
                      : () async {
                        final id = await widget.pickAssignee(e, c);
                        if (id != null && mounted && selected == index) {
                          setState(() => assigneeId = id);
                        }
                      },
              child: Text(
                formatGameNumbers(
                  person()?.name ?? 'Không giao ai xử lý (mặc định)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatGameNumbers(
                'Tỷ lệ thành công: ${petitionChance(s, e, c, person())}%',
              ),
              key: const ValueKey('petition-success-chance'),
              style: const TextStyle(
                color: forest,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Giao người không tốn thêm hành động. Người được giao sẽ bận đến khi có kết quả. Để mặc định sẽ không tự chọn người thay bạn.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPersonnelNominee() async {
    final office = courtMatterOffice(s, matter!);
    if (office == null) return;
    final candidates =
        [...s.court, ...s.officialsPool]
            .where(
              (c) => c.available && !c.isConsort && c.id != office.holderId,
            )
            .toList()
          ..sort((a, b) => b.ability.compareTo(a.ability));
    String? candidateBlocked(Courtier c) =>
        courtOfficeHolder(s, office) == null
            ? vacancyNominationBlocked(s, c, office)
            : courtAppointmentBlocked(s, c, office);
    int candidateCost(Courtier c) =>
        courtOfficeHolder(s, office) == null
            ? vacancyPromotion(s, c, office).cost
            : courtAppointmentCost(s, c, office);
    final id = await showDialog<String>(
      context: context,
      builder:
          (context) => ImperialAlertDialog(
            title: Text(formatGameNumbers('Bổ nhiệm ${office.role}')),
            content: SizedBox(
              width: 500,
              height: 360,
              child: ListView(
                children: [
                  for (final c in candidates)
                    ListTile(
                      key: ValueKey('personnel-candidate-${c.id}'),
                      title: Text(
                        formatGameNumbers(
                          '${c.name} · ${courtGradeName(c.grade)}',
                        ),
                      ),
                      subtitle: Text(
                        formatGameNumbers(
                          '${c.specialty} · Năng lực ${c.ability} · Thiện cảm ${c.affection}\n'
                          '${candidateBlocked(c) ?? 'Phí ${moneyText(s, candidateCost(c))}'}',
                        ),
                      ),
                      enabled: candidateBlocked(c) == null,
                      onTap:
                          candidateBlocked(c) == null
                              ? () => Navigator.pop(context, c.id)
                              : null,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
            ],
          ),
    );
    if (id != null && mounted) setState(() => assigneeId = id);
  }

  Widget choice(int index) {
    final active = selected == index;
    final reason = blockedReason(index);
    final awaitingNominee =
        matter != null &&
        courtMatterNeedsNominee(matter!, index) &&
        assigneeId.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            key: ValueKey('petition-choice-$index'),
            onPressed:
                (reason != null && !awaitingNominee) ||
                        widget.busy ||
                        submitting
                    ? null
                    : () => setState(() {
                      if (selected != index) {
                        selected = index;
                        assigneeId = '';
                      }
                    }),
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              disabledForegroundColor: muted,
              textStyle: const TextStyle(
                fontFamily: 'BeVietnam',
                fontWeight: FontWeight.w400,
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              minimumSize: const Size(0, 46),
              backgroundColor:
                  active ? const Color(0xFFDCE3CD) : const Color(0x66FFF9ED),
              shape: RoundedRectangleBorder(
                borderRadius:
                    active
                        ? const BorderRadius.vertical(top: Radius.circular(6))
                        : BorderRadius.circular(6),
              ),
              backgroundBuilder:
                  (context, states, child) => child ?? const SizedBox.shrink(),
              side: BorderSide(color: active ? forest : line, width: 1),
            ),
            child: Semantics(
              selected: active,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    active
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: active ? forest : muted,
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    index == e.choices.length - 1
                        ? Icons.pause_circle_outline
                        : e.choices[index].cost > 0
                        ? Icons.savings_outlined
                        : petitionCategoryIcon(e.category),
                    size: 22,
                    color: muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatGameNumbers(e.choices[index].label),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (active)
                    const SizedBox(
                      width: 24,
                      height: 17,
                      child: CustomPaint(painter: ApprovalBrush()),
                    )
                  else
                    const Icon(Icons.expand_more, size: 18, color: muted),
                ],
              ),
            ),
          ),
          if (reason != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Text(
                formatGameNumbers(reason),
                key: ValueKey('petition-blocked-$index'),
                style: const TextStyle(fontSize: 12, color: terracotta),
              ),
            ),
          if (active) choiceDetails(index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.inDialog) ...[
          SizedBox(
            height: 120,
            width: double.infinity,
            child: PetitionPainting(category: e.category),
          ),
          Tag(e.category.toUpperCase()),
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(s.authoredText(petitionText(petition, s))),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(
              petition.deadline <= s.week
                  ? 'Hạn: cuối ${s.periodName} này'
                  : 'Còn ${petition.deadline - s.week + 1} ${s.periodName}',
            ),
            style: const TextStyle(color: terracotta, fontSize: 12),
          ),
          const SizedBox(height: 14),
          const PetitionRule(),
          const SizedBox(height: 10),
        ],
        const Text(
          'Ý chỉ của bệ hạ',
          style: TextStyle(fontFamily: 'Lora', fontSize: 20),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < e.choices.length; i++) choice(i),
        if (settlement && arc!.kind == 'haremHarmony') ...[
          OutlinedButton(
            key: const ValueKey('chain-stop'),
            onPressed:
                enabled(-1) && !widget.busy && !submitting
                    ? () => setState(() {
                      selected = -1;
                      assigneeId = '';
                    })
                    : null,
            child: Text(
              formatGameNumbers(
                '${selected == -1 ? '✓ ' : ''}Dừng chuỗi và quyết toán',
              ),
            ),
          ),
          if (!enabled(-1))
            Text(
              formatGameNumbers(blockedReason(-1)!),
              style: const TextStyle(fontSize: 12, color: terracotta),
            ),
          if (selected == -1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                formatGameNumbers(
                  '1 hành động · Quyết toán: ${chainSettlementRewardText(s, arc!)}',
                ),
                key: const ValueKey('chain-stop-details'),
              ),
            ),
          const SizedBox(height: 12),
        ],
        Text(
          formatGameNumbers(
            settlement
                ? 'Quá hạn: dừng chuỗi và quyết toán theo số bước đã hoàn thành; không thu thêm chi phí hay hoàn thành bước đang chờ.'
                : petition.isStory
                ? 'Quá hạn: áp dụng lựa chọn cuối cùng và quyết định diễn biến bản tấu sau.${petition.storyKind == 'major' ? ' Tổn thất có thể làm chỉ số về 0 và kết thúc triều đại.' : ''}'
                : 'Quá hạn: áp dụng lựa chọn cuối cùng.${['Khủng hoảng', 'Âm mưu'].contains(e.category) ? ' Bỏ mặc bản tấu này còn làm mất uy quyền và Ổn định triều đình.' : ''}',
          ),
          key: const ValueKey('petition-expiry-warning'),
          style: const TextStyle(fontSize: 12, color: terracotta),
        ),
      ],
    );
    final confirmation = FilledButton(
      key: const ValueKey('confirm-petition'),
      style: FilledButton.styleFrom(
        foregroundColor: const Color(0xFFFFF1CE),
        disabledForegroundColor: muted,
        textStyle: const TextStyle(
          fontFamily: 'Lora',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        minimumSize: const Size(0, 44),
        backgroundBuilder:
            (context, states, child) => ImperialSkin(
              asset:
                  states.contains(WidgetState.disabled) ? 'ivory' : 'crimson',
              edge: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: child,
              ),
            ),
      ),
      onPressed:
          selected == null || !enabled(selected!) || widget.busy || submitting
              ? null
              : () async {
                setState(() => submitting = true);
                try {
                  await widget.onConfirm(selected!, assigneeId);
                } finally {
                  if (mounted) setState(() => submitting = false);
                }
              },
      child: const Text('Xác nhận ngự phê'),
    );
    final later = TextButton(
      onPressed: submitting ? null : widget.onReadLater,
      child: const Text('Đọc sau'),
    );
    if (widget.inDialog) {
      return ImperialAlertDialog(
        title: Text(
          formatGameNumbers(e.title),
          style: const TextStyle(fontFamily: 'Lora', fontSize: 24),
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(child: content),
        ),
        actions: [later, confirmation],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        const SizedBox(height: 8),
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: 12,
          overflowSpacing: 8,
          children: [later, confirmation],
        ),
      ],
    );
  }
}
