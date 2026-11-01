import '../../models/number_format.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/investigation_rules.dart';
import '../../logic/currency_rules.dart';
import 'imperial_dialog.dart';
import 'imperial_theme.dart';

Future<bool?> chooseCovertInvestigation(
  BuildContext context, {
  required String targetId,
  required Listenable changes,
  required GameState Function() currentState,
  required Future<bool> Function(String, String, String) send,
}) async {
  String? spyId;
  var funding = 20;
  final accepted = await showDialog<bool>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, update) => AnimatedBuilder(
                animation: changes,
                builder: (context, _) {
                  final s = currentState();
                  final target =
                      [
                        ...s.court,
                        ...s.officialsPool,
                      ].where((c) => c.id == targetId).firstOrNull;
                  final spies =
                      s.court
                          .where((c) => c.role == 'Mật thám' && c.available)
                          .toList();
                  final spy = spies.where((c) => c.id == spyId).firstOrNull;
                  final reason =
                      target == null
                          ? 'Mục tiêu không còn hiện diện.'
                          : covertBlocked(s, target, spy, funding);
                  return ImperialAlertDialog(
                    key: const ValueKey('covert-investigation-dialog'),
                    title: Text(
                      formatGameNumbers(
                        'Điều tra kín · ${target?.name ?? 'Nhân vật'}',
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn mật thám và tổng kinh phí. Chi 1 hành động, nhận báo cáo sau 2 mùa. Mật thám bận trong thời gian điều tra.',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const ValueKey('investigation-spy'),
                          value: spies.any((c) => c.id == spyId) ? spyId : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Mật thám',
                          ),
                          items: [
                            for (final c in spies)
                              DropdownMenuItem(
                                value: c.id,
                                enabled:
                                    target != null &&
                                    covertSpyBlocked(s, c, target) == null,
                                child: Text(
                                  formatGameNumbers(
                                    '${c.name} · ${courtGradeName(c.grade)} · NL ${c.abilityLabel}${target == null || covertSpyBlocked(s, c, target) == null ? '' : ' · ${covertSpyBlocked(s, c, target)}'}',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) => update(() => spyId = value),
                        ),
                        if (spies.isEmpty)
                          const Text(
                            'Không có người giữ chức Mật thám.',
                            style: TextStyle(color: terracotta),
                          ),
                        const SizedBox(height: 12),
                        for (final budget in covertFunding)
                          RadioListTile<int>(
                            key: ValueKey('investigation-funding-$budget'),
                            value: budget,
                            groupValue: funding,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              formatGameNumbers(
                                '${budget == 20
                                    ? 'Thăm dò'
                                    : budget == 40
                                    ? 'Mở rộng tai mắt'
                                    : 'Điều tra chuyên sâu'} · ${moneyText(s, covertCost(s, budget))}',
                              ),
                            ),
                            subtitle: Text(
                              formatGameNumbers(
                                spy == null || target == null
                                    ? 'Chọn mật thám để xem tỷ lệ.'
                                    : 'Thành công ${covertChance(spy, target, budget)}% · Thất bại sống sót ${((100 - covertChance(spy, target, budget)) * (100 - investigationDeathRisk(target)) / 100).toStringAsFixed(1)}% · Tử vong ${((100 - covertChance(spy, target, budget)) * investigationDeathRisk(target) / 100).toStringAsFixed(1)}%',
                              ),
                            ),
                            onChanged:
                                (value) => update(() => funding = value!),
                          ),
                        if (spy != null && target != null)
                          Text(
                            formatGameNumbers(
                              'Phẩm mật thám +${spyGradeBonus(spy)} điểm %. Độ khó mục tiêu −${investigationDifficulty(target)} điểm %. Tử vong nếu thất bại: ${investigationDeathRisk(target)}%.',
                            ),
                          ),
                        const SizedBox(height: 10),
                        const Text(
                          'Mật thám có thể tử nạn vĩnh viễn. Thất bại mất kinh phí, giữ hồ sơ cũ. Chỉ báo cáo thành công mới tạo bằng chứng hiệu lực một năm.',
                          style: TextStyle(color: terracotta, fontSize: 12),
                        ),
                        if (reason != null)
                          Text(
                            formatGameNumbers(reason),
                            style: const TextStyle(color: terracotta),
                          ),
                      ],
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        key: const ValueKey('confirm-investigation'),
                        onPressed:
                            reason == null
                                ? () => Navigator.pop(context, true)
                                : null,
                        child: const Text('Phái mật thám'),
                      ),
                    ],
                  );
                },
              ),
        ),
  );
  if (accepted != true) return null;
  return send(
    'investigate',
    targetId,
    jsonEncode({'spy': spyId, 'funding': funding}),
  );
}
