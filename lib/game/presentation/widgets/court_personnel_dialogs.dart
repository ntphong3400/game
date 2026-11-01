import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/game_state.dart';
import '../../logic/court_rules.dart';
import '../../logic/management_rules.dart';
import 'management_dialogs.dart';
import '../../logic/currency_rules.dart';
import 'imperial_dialog.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';
import 'court_grade_badge.dart';

typedef CourtSend =
    Future<bool> Function(String type, String target, String option);

Future<void> confirmCourtDismissal(
  BuildContext context,
  GameState s,
  CourtOffice office,
  CourtSend send,
) async {
  final holder = courtOfficeHolder(s, office);
  if (holder == null) return;
  final blocked = courtDismissalBlocked(s, office);
  final penalty = courtVacancyEffects(office);
  final accepted = await showDialog<bool>(
    context: context,
    builder:
        (context) => ImperialAlertDialog(
          title: Text(
            formatGameNumbers('Cho ${holder.name} thôi chức, hồi hương?'),
          ),
          width: 520,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(
                  'Thôi chức ${office.role} (${courtGradeName(office.grade)}). Vị trí để trống tới khi bệ hạ bổ nhiệm người mới.',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Người hồi hương được lưu trong danh sách chờ với trạng thái Đã hồi hương, giữ nguyên phẩm, công trạng và quan hệ.',
              ),
              const SizedBox(height: 12),
              Text(
                formatGameNumbers(
                  'Chi 1 hành động, không chi ngân khố. Ổn định triều đình −${courtOfficeDisruption(office)}; phe ${holder.faction} −4.${holder.influence >= 60 ? ' Phe người cũ còn phản ứng vào mùa sau.' : ''}',
                ),
              ),
              if (penalty.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  formatGameNumbers('Mỗi mùa bỏ trống: $penalty'),
                  key: const ValueKey('court-dismiss-penalty'),
                  style: const TextStyle(color: terracotta),
                ),
              ],
              if (s.stability <= courtOfficeDisruption(office))
                const Text(
                  'CẢNH BÁO: cho hồi hương lúc này làm ổn định về 0 và kết thúc lượt chơi.',
                  style: TextStyle(color: terracotta),
                ),
              Text(
                formatGameNumbers(
                  courtOfficeAuthority(office) == 0
                      ? 'Chức này không yêu cầu uy quyền để hồi hương.'
                      : 'Yêu cầu uy quyền trên ${courtOfficeAuthority(office)} · Hiện tại ${s.authority}.',
                ),
              ),
              if (blocked != null)
                Text(
                  formatGameNumbers(blocked),
                  style: const TextStyle(color: terracotta),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              key: const ValueKey('confirm-court-dismissal'),
              onPressed:
                  blocked == null ? () => Navigator.pop(context, true) : null,
              child: const Text('Cho hồi hương'),
            ),
          ],
        ),
  );
  if (accepted == true) await send('dismiss-office', office.id, '');
}

Future<void> chooseCourtPromotion(
  BuildContext context,
  GameState initialState,
  Courtier person,
  CourtSend send, {
  Listenable? changes,
  GameState Function()? currentState,
}) async {
  int? target =
      [for (var g = person.grade - 1; g >= 1; g--) g]
          .where((g) => courtPromotionBlocked(initialState, person, g) == null)
          .firstOrNull;
  Widget panel(BuildContext context, StateSetter update) {
    final s = currentState?.call() ?? initialState;
    final c = courtPerson(s, person.id);
    final grades =
        c == null ? <int>[] : [for (var g = c.grade - 1; g >= 1; g--) g];
    if (target != null &&
        (c == null ||
            !grades.contains(target) ||
            courtPromotionBlocked(s, c, target!) != null)) {
      target = null;
    }
    final quote =
        c == null || target == null ? null : CourtPromotion(s, c, target!);
    return ImperialAlertDialog(
      key: const ValueKey('court-promotion-dialog'),
      width: 560,
      title: Text(formatGameNumbers('Thăng phẩm ${c?.name ?? person.name}')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c == null)
            const Text('Nhân vật không còn hiện diện, chưa thể thăng phẩm.')
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Hiện tại:'),
                CourtGradeBadge(
                  c.grade,
                  key: const ValueKey('promotion-current-grade'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatGameNumbers(
                'Năng lực ${c.abilityLabel}\nCông trạng ${c.merit} · Thành tích lớn ${c.majorMerits}\nNgân khố ${moneyText(s, s.treasury)} · ${s.points} hành động còn lại',
              ),
            ),
            const SizedBox(height: 12),
            if (grades.isEmpty)
              const Text(
                'Đã đạt Nhất phẩm — phẩm vị cao nhất.',
                key: ValueKey('promotion-highest'),
              )
            else ...[
              if (quote != null)
                Text(
                  formatGameNumbers(
                    'Lên ${courtGradeName(target!)}: Sử dụng ${quote.merit} công trạng · Còn lại ${c.merit - quote.merit}\n'
                    'Chi ${moneyText(s, quote.cost)} · 1 hành động\n'
                    'Thiện cảm +${quote.actualAffection(c)} · Bất mãn −${quote.actualDiscontent(c)}',
                  ),
                  key: const ValueKey('promotion-quote'),
                  style: const TextStyle(color: forest),
                )
              else
                const Text(
                  'Chọn một phẩm đủ điều kiện để xem trước và xác nhận.',
                  style: TextStyle(color: muted),
                ),
              const SizedBox(height: 12),
              for (final grade in grades)
                Builder(
                  builder: (context) {
                    final cost = CourtPromotion(s, c, grade);
                    final reason = courtPromotionBlocked(s, c, grade);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            target == grade
                                ? forest.withValues(alpha: .08)
                                : null,
                        border: Border.all(
                          color: target == grade ? forest : line,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: RadioListTile<int>(
                        key: ValueKey('promotion-option-$grade'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        value: grade,
                        groupValue: target,
                        onChanged:
                            reason == null
                                ? (g) => update(() => target = g)
                                : null,
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Opacity(
                                opacity: reason == null ? 1 : .5,
                                child: CourtGradeBadge(grade),
                              ),
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatGameNumbers(
                                '${cost.merit} công trạng · ${moneyText(s, cost.cost)} · 1 hành động',
                              ),
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              formatGameNumbers(
                                'Năng lực ≥${promotionAbility[grade]}${grade <= 3 ? ' · Thành tích lớn ≥${4 - grade}' : ''}',
                              ),
                              style: const TextStyle(fontSize: 11),
                            ),
                            if (reason != null)
                              Text(
                                formatGameNumbers(reason),
                                key: ValueKey('promotion-blocked-$grade'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: terracotta,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(formatGameNumbers(grades.isEmpty ? 'Đóng' : 'Hủy')),
        ),
        if (grades.isNotEmpty)
          FilledButton(
            key: const ValueKey('confirm-promotion'),
            onPressed:
                target == null ||
                        c == null ||
                        courtPromotionBlocked(s, c, target!) != null
                    ? null
                    : () => Navigator.pop(context, target),
            child: const Text('Xác nhận thăng phẩm'),
          ),
      ],
    );
  }

  final accepted = await showDialog<int>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, update) =>
                  changes == null
                      ? panel(context, update)
                      : AnimatedBuilder(
                        animation: changes,
                        builder: (context, _) => panel(context, update),
                      ),
        ),
  );
  if (accepted != null) await send('promote', person.id, '$accepted');
}

Future<void> chooseCourtAppointment(
  BuildContext context,
  GameState s,
  CourtOffice office,
  CourtSend send, {
  Courtier? preferredCandidate,
}) async {
  final post = managementPost(office.id);
  if (post != null) {
    await chooseManagementAppointment(
      context,
      s,
      post,
      send,
      preferredCandidate: preferredCandidate,
    );
    return;
  }
  final candidates =
      [...s.court, ...s.officialsPool]
          .where((c) => c.available && !c.isConsort && c.id != office.holderId)
          .toList()
        ..sort((a, b) {
          final eligible = (courtAppointmentBlocked(s, a, office) == null
                  ? 0
                  : 1)
              .compareTo(courtAppointmentBlocked(s, b, office) == null ? 0 : 1);
          if (eligible != 0) return eligible;
          return b.ability.compareTo(a.ability);
        });
  final id =
      preferredCandidate?.id ??
      await showDialog<String>(
        context: context,
        builder:
            (context) => ImperialSimpleDialog(
              title: Text(formatGameNumbers('Bổ nhiệm ${office.role}')),
              children: [
                Text(
                  formatGameNumbers(
                    'Yêu cầu ${courtGradeName(office.grade)} trở lên. Năng lực và thiện cảm quyết định kích hoạt passive; chuyên môn không đổi khi bổ nhiệm.',
                  ),
                ),
                const SizedBox(height: 12),
                for (final c in candidates)
                  ImperialDialogOption(
                    leading: CharacterPortrait(
                      person: c,
                      width: 48,
                      height: 58,
                    ),
                    onPressed:
                        courtAppointmentBlocked(s, c, office) == null
                            ? () => Navigator.pop(context, c.id)
                            : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatGameNumbers(
                            '${c.name} · ${courtGradeName(c.grade)}',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          formatGameNumbers(
                            '${c.displayRole} · ${c.specialty}\nNăng lực ${c.abilityLabel} · Thiện cảm ${c.affection}',
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          formatGameNumbers(
                            courtAppointmentBlocked(s, c, office) ??
                                'Phí ${moneyText(s, courtAppointmentCost(s, c, office))}',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                courtAppointmentBlocked(s, c, office) == null
                                    ? forest
                                    : muted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      );
  if (id == null || !context.mounted) return;
  final candidate = courtPerson(s, id)!,
      source = courtOfficeFor(s, id),
      old = courtOfficeHolder(s, office);
  final canSwap =
      source != null &&
      managementPost(source.id) == null &&
      old != null &&
      courtAppointmentBlocked(s, old, source) == null;
  var swap = false;
  var backfillId = '';
  final backfills =
      source == null || managementPost(source.id) != null
          ? <Courtier>[]
          : s.officialsPool
              .where(
                (c) =>
                    c.id != candidate.id &&
                    courtAppointmentBlocked(s, c, source) == null,
              )
              .toList();
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, update) {
            final price =
                courtAppointmentCost(s, candidate, office) +
                (swap ? courtAppointmentCost(s, old!, source!) : 0) +
                (backfillId.isNotEmpty
                    ? courtAppointmentCost(
                      s,
                      backfills.firstWhere((c) => c.id == backfillId),
                      source!,
                    )
                    : 0);
            final reason =
                courtAppointmentBlocked(s, candidate, office) ??
                (s.points < (swap || backfillId.isNotEmpty ? 2 : 1)
                    ? 'Không đủ hành động.'
                    : s.treasury < price
                    ? 'Ngân khố không đủ.'
                    : null);
            final benefits = courtPassives(office);
            final disruption = courtAppointmentDisruption(s, candidate, office);
            final eligible =
                candidate.ability >= (office.grade == 1 ? 90 : 80) &&
                candidate.affection >= (office.grade == 1 ? 80 : 70);
            return ImperialAlertDialog(
              width: 560,
              title: Text(formatGameNumbers('Bổ nhiệm ${candidate.name}?')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatGameNumbers(
                      '${candidate.name} → ${office.role} (${courtGradeName(office.grade)})\n${old == null ? 'Chức hiện đang trống.' : 'Thay ${old.name}.'}',
                    ),
                  ),
                  if (canSwap)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đổi chỗ hai quan'),
                      subtitle: Text(
                        formatGameNumbers(
                          '${old.name} nhận chức ${source.role} · 2 hành động',
                        ),
                      ),
                      value: swap,
                      onChanged:
                          (v) => update(() {
                            swap = v;
                            backfillId = '';
                          }),
                    ),
                  if (source != null && !swap && backfills.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: backfillId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: formatGameNumbers(
                          'Bổ khuyết chức ${source.role}',
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Để trống, bổ nhiệm sau'),
                        ),
                        for (final c in backfills)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              formatGameNumbers(
                                '${c.name} · ${courtGradeName(c.grade)}',
                              ),
                            ),
                          ),
                      ],
                      onChanged: (id) => update(() => backfillId = id ?? ''),
                    ),
                  if (source != null && !swap && backfillId.isEmpty)
                    Text(
                      formatGameNumbers(
                        '${source.role} sẽ bỏ trống, cần bổ khuyết. Ổn định triều đình −${courtOfficeDisruption(source)}.',
                      ),
                      style: const TextStyle(color: terracotta),
                    ),
                  if (old != null && !swap)
                    Text(
                      formatGameNumbers(
                        '${old.name} về danh sách chờ bổ nhiệm, giữ nguyên phẩm và công trạng.\nỔn định triều đình −${courtOfficeDisruption(office)}; phe người cũ có thể phản ứng.',
                      ),
                    ),
                  if (old != null && swap)
                    Text(
                      formatGameNumbers(
                        'Ổn định triều đình −${courtOfficeDisruption(office) + courtOfficeDisruption(source!)}; phản ứng phe phái tính cho cả hai lượt bổ nhiệm.',
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    formatGameNumbers(
                      'Chi ${moneyText(s, price)} · ${swap || backfillId.isNotEmpty ? 2 : 1} hành động · Uy quyền +1 · Tổng ổn định −$disruption.\nPhe ${candidate.faction} +5; phe đối lập −6; nếu khác phe, phe người bị thay −4.',
                    ),
                  ),
                  if (backfillId.isNotEmpty)
                    Text(
                      formatGameNumbers(
                        'Rời chức ${source!.role} gây xáo trộn ổn định −${courtOfficeDisruption(source)}; phe người bổ khuyết +5, phe đối lập −6.',
                      ),
                    ),
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      formatGameNumbers(
                        '${benefits.map((b) => '${b.label} ${b.effect}').join('\n')}\n'
                        '${eligible ? 'Đủ năng lực và thiện cảm.' : 'Chưa đủ năng lực/thiện cảm kích hoạt passive.'} Được xét từ ${s.date(s.week + 1)}.',
                      ),
                    ),
                  ],
                  if (reason != null)
                    Text(
                      formatGameNumbers(reason),
                      style: const TextStyle(color: terracotta),
                    ),
                  if (disruption >= s.stability)
                    const Text(
                      'CẢNH BÁO: thay người lúc này khiến ổn định triều đình về 0 và kết thúc lượt chơi.',
                      style: TextStyle(color: terracotta),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed:
                      reason == null
                          ? () => Navigator.pop(context, true)
                          : null,
                  child: const Text('Bổ nhiệm'),
                ),
              ],
            );
          },
        ),
  );
  if (confirmed == true) {
    await send(
      swap ? 'swap-office' : 'appoint-office',
      office.id,
      backfillId.isEmpty
          ? candidate.id
          : jsonEncode({'candidate': candidate.id, 'backfill': backfillId}),
    );
  }
}
