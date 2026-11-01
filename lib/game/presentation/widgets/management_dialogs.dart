import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/management_rules.dart';
import '../../logic/court_rules.dart';
import 'imperial_dialog.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';

Future<void> chooseManagementAppointment(
  BuildContext context,
  GameState s,
  ManagementPost post,
  Future<bool> Function(String, String, String) send, {
  Courtier? preferredCandidate,
}) async {
  final candidates =
      [...s.court, ...s.officialsPool]
          .where(
            (c) =>
                c.available &&
                !c.isConsort &&
                c.id != managementHolder(s, post)?.id,
          )
          .toList()
        ..sort((a, b) {
          final eligible = (managementCandidateBlocked(s, a, post) == null
                  ? 0
                  : 1)
              .compareTo(
                managementCandidateBlocked(s, b, post) == null ? 0 : 1,
              );
          return eligible != 0 ? eligible : b.ability.compareTo(a.ability);
        });
  final id =
      preferredCandidate?.id ??
      await showDialog<String>(
        context: context,
        builder:
            (context) => ImperialSimpleDialog(
              title: Text(
                formatGameNumbers('Bổ nhiệm ${post.role} · ${post.areaName}'),
              ),
              children: [
                Text(
                  formatGameNumbers(
                    '${post.group} · ${post.senior ? 'Lục phẩm trở lên' : 'Không yêu cầu phẩm vị'}. Mỗi người chỉ quản lý một vị trí, vẫn được nhận nhiệm vụ.',
                  ),
                ),
                const SizedBox(height: 12),
                for (final c in candidates)
                  ImperialDialogOption(
                    key: ValueKey('manager-candidate-${post.id}-${c.id}'),
                    leading: CharacterPortrait(
                      person: c,
                      width: 40,
                      height: 50,
                    ),
                    onPressed:
                        managementCandidateBlocked(s, c, post) == null
                            ? () => Navigator.pop(context, c.id)
                            : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatGameNumbers(
                            '${c.name} · ${courtGradeName(c.grade)}',
                          ),
                        ),
                        Text(
                          formatGameNumbers(
                            '${c.role} · Năng lực ${c.abilityLabel} · Thiện cảm ${c.affection}',
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          formatGameNumbers(
                            managementCandidateBlocked(s, c, post) ??
                                'Có thể bổ nhiệm',
                          ),
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      );
  if (id == null || !context.mounted) return;
  final candidate = courtPerson(s, id);
  if (candidate == null) return;
  final old = managementHolder(s, post);
  final source = courtOfficeFor(s, id);
  final reason =
      managementCandidateBlocked(s, candidate, post) ??
      (s.points < 1
          ? 'Cần 1 hành động.'
          : s.treasury < 1000
          ? 'Cần 1.000 ngân lượng.'
          : null);
  final accepted = await showDialog<bool>(
    context: context,
    builder:
        (context) => ImperialAlertDialog(
          title: Text(formatGameNumbers('Bổ nhiệm ${candidate.name}?')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(
                  '${candidate.name} → ${post.role} · ${post.areaName}',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Chi 1.000 ngân lượng và 1 hành động. Người được bổ nhiệm +5 thiện cảm.',
              ),
              if (old != null)
                Text(
                  formatGameNumbers(
                    '${old.name} −10 thiện cảm; trở thành quan chưa giữ chức, giữ nguyên ${courtGradeName(old.grade)}. Nhiệm vụ đang thực hiện vẫn tiếp tục.',
                  ),
                ),
              if (source != null)
                Text(
                  formatGameNumbers(
                    'Chức ${source.role} sẽ bỏ trống.${managementPost(source.id) == null ? '' : ' ${managementPost(source.id)!.areaName}: ${managementPost(source.id)!.effect(vacant: true)}.'}',
                  ),
                  style: const TextStyle(color: terracotta),
                ),
              const SizedBox(height: 10),
              Text(
                formatGameNumbers(
                  '${post.effect()}. Cần năng lực >${post.abilityThreshold} và thiện cảm >${post.affectionThreshold}.',
                ),
              ),
              Text(formatGameNumbers(post.growthLabel)),
              if (reason != null)
                Text(
                  formatGameNumbers(reason),
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
              key: ValueKey('confirm-manager-${post.id}'),
              onPressed:
                  reason == null ? () => Navigator.pop(context, true) : null,
              child: const Text('Bổ nhiệm'),
            ),
          ],
        ),
  );
  if (accepted == true) await send('appoint-manager', post.id, candidate.id);
}
