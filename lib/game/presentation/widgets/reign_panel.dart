import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import 'imperial_dialog.dart';
import '../../logic/population_rules.dart';
import '../../logic/personnel_rules.dart';
import '../../data/expanded_events.dart' show eventEffectText;
import '../../logic/reign_rules.dart';
import '../../models/game_state.dart';
import 'imperial_theme.dart';
import 'kingdom_style.dart';

typedef ReignCommand =
    Future<void> Function(String type, String target, String option);

class ReignPanel extends StatelessWidget {
  const ReignPanel({
    super.key,
    required this.state,
    required this.busy,
    required this.send,
    this.obligationsKey,
    this.emergencyKey,
    this.showObligations = true,
    this.showEmergencies = true,
    this.showSectionHeaders = true,
  });
  final GameState state;
  GameState get s => state;
  final bool busy;
  final bool showObligations, showEmergencies, showSectionHeaders;
  final ReignCommand send;
  final Key? obligationsKey, emergencyKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (showObligations)
        _section(
          headerKey: obligationsKey,
          number: '03',
          title: 'Nghĩa vụ và ảnh hưởng đang hiệu lực',
          count: state.obligations.length,
          child: Column(
            key: const ValueKey('obligations'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.obligations.isEmpty)
                const KingdomEmpty(
                  icon: Icons.balance_outlined,
                  title: 'Chưa có nghĩa vụ đang hiệu lực.',
                  detail:
                      'Khoản phải trả, nguồn thu và ảnh hưởng kéo dài sẽ được ghi tại đây.',
                ),
              for (final o in state.obligations) _obligation(o),
              if (state.obligations.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Khoản thu/chi được tính trong dự toán và sổ thu chi. Thiếu tiền sẽ ghi nợ; hết thời hạn nghĩa vụ không xóa khoản nợ đã phát sinh.',
                  style: TextStyle(fontSize: 10, color: muted, height: 1.7),
                ),
              ],
            ],
          ),
        ),
      if (showObligations && showEmergencies) const SizedBox(height: 16),
      if (showEmergencies)
        _section(
          headerKey: emergencyKey,
          number: '04',
          title: 'Đối sách khẩn cấp',
          subtitle: 'Giải quyết trước mắt, cân nhắc nghĩa vụ về sau.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final kind in emergencyNames.keys)
                if (kind != 'early_labor' || state.population != null)
                  _emergencyRow(context, kind),
            ],
          ),
        ),
    ],
  );

  Widget _section({
    required String number,
    required String title,
    required Widget child,
    Key? headerKey,
    int? count,
    String? subtitle,
  }) =>
      showSectionHeaders
          ? KingdomSection(
            number: number,
            title: title,
            headerKey: headerKey,
            count: count,
            subtitle: subtitle,
            child: child,
          )
          : child;

  Widget _obligation(Obligation o) {
    final color =
        o.amount > 0
            ? terracotta
            : o.income > 0
            ? forest
            : gold;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .045),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            o.amount > 0
                ? Icons.toll_outlined
                : o.income > 0
                ? Icons.savings_outlined
                : Icons.history_outlined,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatGameNumbers(o.title),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatGameNumbers(
                    'Từ cuối ${state.date(o.nextWeek)} · còn ${o.remaining} kỳ'
                    '${o.amount > 0 ? ' · chi ${o.amount} ${moneyUnit(s)}/kỳ (tổng còn ${o.amount * o.remaining})' : ''}'
                    '${o.income > 0 ? ' · thu +${o.income} ${moneyUnit(s)}/kỳ (tổng còn ${o.income * o.remaining})' : ''}'
                    '${o.effects.isNotEmpty ? '\n${o.kind == 'demand' ? 'Nếu không trả đủ: ' : 'Mỗi kỳ: '}${eventEffectText(o.effects)}' : ''}',
                  ),
                  style: TextStyle(fontSize: 11, color: color, height: 1.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emergencyRow(BuildContext context, String kind) {
    final blocked = emergencyBlocked(state, kind);
    final icon = switch (kind) {
      'borrow' => Icons.toll_outlined,
      'levy' => Icons.shield_outlined,
      _ => Icons.description_outlined,
    };
    final summary = switch (kind) {
      'borrow' =>
        'Nhận ${money(s, 120)} ${moneyUnit(s)} · hoàn trả tổng ${money(s, 150)} ${moneyUnit(s)}.',
      'levy' =>
        state.population == null
            ? 'Chi ${money(s, 15)} ${moneyUnit(s)} · quân lực +14 · lòng dân −4.'
            : 'Giao triều thần tuyển tối đa 10.000 quân; thất bại nhận 1.000.',
      'early_labor' => 'Lao động +1%; lòng dân −8, ổn định −5; chờ 4 mùa.',
      _ =>
        'Chi ${money(s, 20)} ${moneyUnit(s)} · chiến tranh −2 · có cống nạp.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            key: ValueKey('emergency-$kind'),
            onPressed:
                busy || blocked != null
                    ? null
                    : () => _emergency(context, kind),
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              backgroundBuilder:
                  (context, states, child) =>
                      KingdomButtonFrame(child: child ?? const SizedBox()),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: const TextStyle(fontFamily: 'BeVietnam', fontSize: 12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: blocked == null ? gold : muted.withValues(alpha: .5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatGameNumbers(emergencyNames[kind]!),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatGameNumbers(summary),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              blocked == null
                                  ? muted
                                  : muted.withValues(alpha: .65),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
          if (blocked != null) ...[
            const SizedBox(height: 5),
            Text(
              formatGameNumbers(blocked),
              style: const TextStyle(fontSize: 10, color: terracotta),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _emergency(BuildContext context, String kind) async {
    String? officer;
    final requiresOfficer = state.population != null && kind == 'levy';
    final selected = await showDialog<String>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, refresh) => ImperialAlertDialog(
                  title: Text(formatGameNumbers(emergencyNames[kind]!)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(formatGameNumbers(emergencyHint(state, kind))),
                        if (requiresOfficer) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            key: const ValueKey('levy-officer'),
                            value: officer,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Triều thần phụ trách',
                            ),
                            items: [
                              for (final c in taskOfficers(state, 'train'))
                                DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    formatGameNumbers(
                                      '${c.name} · ${actionSuccessChance(state, 'train', c)}%',
                                    ),
                                  ),
                                ),
                            ],
                            onChanged:
                                (value) => refresh(() => officer = value),
                          ),
                          if (officer != null) ...[
                            const SizedBox(height: 12),
                            Builder(
                              builder: (_) {
                                final person = state.court.firstWhere(
                                  (c) => c.id == officer,
                                );
                                final chance = actionSuccessChance(
                                  state,
                                  'train',
                                  person,
                                );
                                return Text(
                                  formatGameNumbers(
                                    'Thành công $chance%: nhận ${whole(emergencyRecruitmentCount(chance, true))} quân. '
                                    'Thất bại: 1.000 quân. Cả hai đều chi ${money(s, 15)} ${moneyUnit(s)} và 1.500 tạ.',
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      key: const ValueKey('confirm-emergency'),
                      onPressed:
                          requiresOfficer && officer == null
                              ? null
                              : () => Navigator.pop(ctx, officer ?? ''),
                      child: const Text('Ban lệnh'),
                    ),
                  ],
                ),
          ),
    );
    if (selected != null) await send('emergency', kind, selected);
  }
}
