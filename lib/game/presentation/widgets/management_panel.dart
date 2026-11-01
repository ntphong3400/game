import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/management_rules.dart';
import 'management_dialogs.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';

class ManagementCard extends StatelessWidget {
  const ManagementCard({
    super.key,
    required this.state,
    required this.post,
    required this.busy,
    required this.send,
  });
  final GameState state;
  final ManagementPost post;
  final bool busy;
  final Future<bool> Function(String, String, String) send;

  @override
  Widget build(BuildContext context) {
    final holder = managementHolder(state, post);
    final direction = managementDirection(state, post);
    final progress = managementOffice(state, post)?.passiveProgress ?? 0;
    return Card(
      key: ValueKey('management-card-${post.id}'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              formatGameNumbers('${post.role} · ${post.areaName}'),
              style: const TextStyle(
                fontFamily: 'Lora',
                fontSize: 19,
                color: forest,
              ),
            ),
            const SizedBox(height: 10),
            if (holder != null)
              Row(
                children: [
                  CharacterPortrait(person: holder, width: 44, height: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatGameNumbers(holder.name),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatGameNumbers(
                            '${courtGradeName(holder.grade)} · Năng lực ${holder.abilityLabel} · Thiện cảm ${holder.affection}',
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Text('Bỏ trống', style: TextStyle(color: terracotta)),
            const SizedBox(height: 10),
            Text(
              formatGameNumbers(
                direction < 0 ? post.effect(vacant: true) : post.effect(),
              ),
              style: TextStyle(color: direction == 1 ? forest : terracotta),
            ),
            Text(
              formatGameNumbers(
                direction == 1
                    ? 'Đang kích hoạt'
                    : direction < 0
                    ? 'Khuyết người: áp dụng tác động âm'
                    : 'Chưa đủ điều kiện: không cộng, không trừ',
              ),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              formatGameNumbers(
                'Cần năng lực >${post.abilityThreshold} và thiện cảm >${post.affectionThreshold}.',
              ),
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            if (post.interval > 1)
              Text(
                formatGameNumbers(
                  'Tích lũy chu kỳ: $progress/${post.interval} mùa.',
                ),
                style: const TextStyle(fontSize: 12, color: muted),
              ),
            Text(
              formatGameNumbers(
                '${post.growthLabel}. Nhiệm vụ có thể giúp vượt giới hạn.',
              ),
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            Text(
              formatGameNumbers(
                '${post.group} · ${post.senior ? 'Lục phẩm trở lên' : 'Không yêu cầu phẩm vị'}. Vẫn được nhận nhiệm vụ.',
              ),
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: ValueKey('change-manager-${post.id}'),
              onPressed:
                  busy || state.ended
                      ? null
                      : () => chooseManagementAppointment(
                        context,
                        state,
                        post,
                        send,
                      ),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Thay đổi người quản lý'),
            ),
            const Text(
              '1.000 ngân lượng · 1 hành động · Người cũ −10, người mới +5 thiện cảm',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
