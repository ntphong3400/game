import '../../models/number_format.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../app/game_controller.dart';
import '../../models/game_state.dart';
import '../../logic/frontier_rules.dart';
import '../../logic/population_rules.dart';
import '../../logic/warfare_rules.dart';
import 'frontier_routes.dart';
import '../../logic/management_rules.dart';
import 'management_panel.dart';
import 'imperial_theme.dart';
import 'warfare_panel.dart';

class FrontierPanel extends StatelessWidget {
  const FrontierPanel({
    super.key,
    required this.state,
    required this.controller,
    required this.countryId,
    required this.place,
    required this.onNavigate,
  });
  final GameState state;
  final GameController controller;
  final String countryId, place;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final s = state, p = s.population!;
    final n = s.warfare!.neighbors.firstWhere((n) => n.id == countryId);
    final d = FrontierDefense(s, n);
    final missions =
        s.warfare!.missions
            .where((m) => m.countryId == countryId && liveMission(m))
            .toList();
    return ListView(
      key: ValueKey('frontier-panel-$countryId-$place'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
      children: [
        if (s.managementVersion > 0 && ['camp', 'command'].contains(place))
          ManagementCard(
            state: s,
            post: ManagementPost(place, countryId),
            busy: controller.busy,
            send:
                (type, target, option) =>
                    controller.act(type, target: target, option: option),
          ),
        Text(
          formatGameNumbers('${garrisonNames[countryId]} · đối diện ${n.name}'),
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        _forecast(d),
        const SizedBox(height: 18),
        if (place == 'camp') ...[
          _metrics([
            ('Quân thuộc đồn trú', whole(p.stationed(countryId))),
            ('Đang xuất trận', whole(p.away(countryId))),
            ('Có thể điều động', whole(p.availableAt(countryId))),
            ('Đang bảo vệ cửa ải', whole(d.troops)),
            ('Huấn luyện', '${p.trainingAt(countryId).toStringAsFixed(1)}/100'),
            ('Quân khí', '${p.equipmentPercent.toStringAsFixed(1)}%'),
            ('Sĩ khí', '${p.moraleAt(countryId).toStringAsFixed(1)}/100'),
            ('Tiếp tế', '${p.logistics.toStringAsFixed(1)}/100'),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Huấn luyện và sĩ khí là chỉ số riêng của ải; quân khí và tiếp tế dùng chung toàn quân. Quân điều đến mang theo chất lượng từ nơi xuất phát. Quân đang xuất trận vẫn thuộc nơi đóng quân nhưng không thể điều chuyển.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
          const Text(
            'Tuyển quân tại Quốc sự; tân binh tập kết ở Kinh Thành.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          TransferTroops(
            state: s,
            controller: controller,
            destination: countryId,
          ),
          const SizedBox(height: 16),
          _heading('Phân bổ quân triều đình'),
          for (final id in garrisonNames.keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                formatGameNumbers(
                  '${garrisonNames[id]}: ${whole(p.stationed(id))} quân · rảnh ${whole(p.availableAt(id))}',
                ),
              ),
            ),
          Text(
            formatGameNumbers(
              'Tổng ${whole(p.soldiers)} quân · rảnh ${whole(p.availableSoldiers)}',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => onNavigate('military'),
                child: const Text('Xem tổng quan quân đội'),
              ),
              OutlinedButton(
                onPressed: () => _capitalTransfer(context),
                child: const Text('Điều quân về Kinh Thành'),
              ),
            ],
          ),
        ],
        if (place == 'command') ...[
          _metrics([
            ('Tình hình', neighborStatus(n)),
            ('Quan hệ', '${n.relation}'),
            ('Ưu thế mặt trận', '${n.advantage}'),
            ('Chiến dịch đang mở', '${missions.length}'),
          ]),
          const SizedBox(height: 18),
          _heading('Tướng và tiến độ chiến dịch'),
          if (missions.isEmpty)
            const Text('Chưa có chiến dịch đang thực hiện.'),
          for (final m in missions)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatGameNumbers(m.title),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatGameNumbers(
                        m.status == 'open'
                            ? 'Chờ xuất quân · hạn cuối ${s.date(m.deadline)}'
                            : '${m.status == 'returning' ? 'Đang trở về' : 'Đang thực hiện'} · về cuối ${s.date(m.due)}',
                      ),
                    ),
                    if (m.officerId.isNotEmpty)
                      Text(
                        formatGameNumbers(
                          'Chủ tướng: ${s.court.where((c) => c.id == m.officerId).firstOrNull?.name ?? 'Không còn trong triều'}',
                        ),
                      ),
                    if (m.deputyId.isNotEmpty)
                      Text(
                        formatGameNumbers(
                          'Phó tướng: ${s.court.where((c) => c.id == m.deputyId).firstOrNull?.name ?? 'Không còn trong triều'}',
                        ),
                      ),
                    if (m.intervention)
                      const Text(
                        'Có quân báo xin tiếp tế đang chờ xử lý.',
                        style: TextStyle(color: terracotta),
                      ),
                  ],
                ),
              ),
            ),
          OutlinedButton(
            onPressed: () => onNavigate(frontierRoute(countryId, 'gate')),
            child: const Text('Đến Cửa Ải để ra lệnh tác chiến'),
          ),
          WarfarePanel(
            state: s,
            controller: controller,
            countryId: countryId,
            showMissions: false,
          ),
        ],
        if (place == 'gate') ...[
          _metrics([
            ('Quân ta bảo vệ', whole(d.troops)),
            ('Quân địch tại mặt trận', whole(n.enemyTroops)),
            ('Chất lượng địch', '${n.enemyQuality}/100'),
            (
              'Tăng viện gần nhất',
              n.lastReinforcementYear == 0
                  ? 'Chưa có'
                  : '+${whole(n.lastReinforcement)}',
            ),
            ('Sức phòng thủ', whole(d.defense.round())),
            ('Sức ép đối phương', whole(d.pressure.round())),
          ]),
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(
              'Lợi thế thành ải ×1,35 · sức ép ${neighborStatus(n).toLowerCase()} ×${d.situation.toStringAsFixed(2)} · quan hệ ×${d.relation.toStringAsFixed(2)}.',
            ),
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const Text(
            'Quân địch đang giao chiến thuộc cùng lực lượng mặt trận; tổn thất được trừ khi quân báo về.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          WarfarePanel(
            state: s,
            controller: controller,
            countryId: countryId,
            showDiplomacy: false,
            showReports: false,
          ),
          if (n.status != 'war') ...[
            const SizedBox(height: 16),
            const Text(
              'Biên giới đang hòa bình. Theo dõi tình hình hoặc xử lý ngoại giao tại Phủ Trấn Thủ.',
            ),
            OutlinedButton(
              onPressed: () => onNavigate(frontierRoute(countryId, 'command')),
              child: const Text('Đến Phủ Trấn Thủ'),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _capitalTransfer(BuildContext context) => showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Điều quân về Kinh Thành'),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: TransferTroops(
                state: state,
                controller: controller,
                destination: 'capital',
                initialSource: countryId,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
  );
  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      formatGameNumbers(text),
      style: const TextStyle(fontFamily: 'Lora', fontSize: 18, color: forest),
    ),
  );
  Widget _forecast(FrontierDefense d) => Container(
    key: const ValueKey('frontier-defense-forecast'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: d.penalty > 0 ? const Color(0xFFF5E2D4) : const Color(0xFFE4EBDD),
      border: Border.all(color: d.penalty > 0 ? terracotta : forest),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatGameNumbers(d.label),
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 18,
            color: d.penalty > 0 ? terracotta : forest,
          ),
        ),
        const SizedBox(height: 4),
        Text(formatGameNumbers(d.forecast)),
      ],
    ),
  );
  Widget _metrics(List<(String, String)> values) => LayoutBuilder(
    builder: (context, bounds) {
      final columns =
          bounds.maxWidth < 260
              ? 1
              : bounds.maxWidth < 850
              ? 2
              : 4;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final v in values)
            Container(
              width: (bounds.maxWidth - (columns - 1) * 10) / columns,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x77FFF8E8),
                border: Border.all(color: const Color(0x55927A56)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatGameNumbers(v.$1),
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatGameNumbers(v.$2),
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 21,
                      color: forest,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class TransferTroops extends StatefulWidget {
  const TransferTroops({
    super.key,
    required this.state,
    required this.controller,
    required this.destination,
    this.initialSource,
  });
  final GameState state;
  final GameController controller;
  final String destination;
  final String? initialSource;
  @override
  State<TransferTroops> createState() => _TransferTroopsState();
}

class _TransferTroopsState extends State<TransferTroops> {
  late String source =
      widget.initialSource ??
      garrisonNames.keys.firstWhere((id) => id != widget.destination);
  int count = 2000;
  String? error;
  bool sending = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.controller.state ?? widget.state, p = s.population!;
    final blocked = transferBlocked(s, source, widget.destination, count);
    final warning = transferWarning(s, source, count);
    final locked = widget.controller.busy || sending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              formatGameNumbers(
                'Điều quân đến ${garrisonNames[widget.destination]}',
              ),
              style: const TextStyle(fontFamily: 'Lora', fontSize: 20),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const ValueKey('transfer-source'),
              value: source,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Nguồn quân'),
              items: [
                for (final id in garrisonNames.keys.where(
                  (id) => id != widget.destination,
                ))
                  DropdownMenuItem(
                    value: id,
                    child: Text(
                      formatGameNumbers(
                        '${garrisonNames[id]} · rảnh ${whole(p.availableAt(id))}',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged:
                  locked
                      ? null
                      : (id) => setState(() {
                        source = id!;
                        error = null;
                      }),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in transferSizes)
                  ChoiceChip(
                    key: ValueKey('transfer-size-$value'),
                    label: Text(formatGameNumbers('${whole(value)} quân')),
                    selected: count == value,
                    onSelected:
                        !locked && p.availableAt(source) >= value
                            ? (_) => setState(() {
                              count = value;
                              error = null;
                            })
                            : null,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              formatGameNumbers(
                '${garrisonNames[source]}: ${whole(p.stationed(source))} → ${whole(p.stationed(source) - count)} quân',
              ),
            ),
            Text(
              formatGameNumbers(
                '${garrisonNames[widget.destination]}: ${whole(p.stationed(widget.destination))} → ${whole(p.stationed(widget.destination) + count)} quân',
              ),
            ),
            const Text('Tốn 1 hành động · đến ngay · tổng quân số giữ nguyên.'),
            if (warning.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  formatGameNumbers(warning),
                  style: const TextStyle(color: terracotta),
                ),
              ),
            if (blocked != null)
              Text(
                formatGameNumbers(blocked),
                style: const TextStyle(color: terracotta),
              ),
            if (error != null)
              Text(
                formatGameNumbers(error!),
                style: const TextStyle(color: terracotta),
              ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('transfer-review'),
              onPressed:
                  blocked == null && !locked ? () => _review(s, warning) : null,
              child: const Text('Điều quân'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(GameState s, String warning) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận điều quân'),
            content: SingleChildScrollView(
              child: Text(
                formatGameNumbers(
                  'Điều ${whole(count)} quân từ ${garrisonNames[source]} đến ${garrisonNames[widget.destination]}.\n'
                  '${garrisonNames[source]}: ${whole(s.population!.stationed(source))} → ${whole(s.population!.stationed(source) - count)}\n'
                  '${garrisonNames[widget.destination]}: ${whole(s.population!.stationed(widget.destination))} → ${whole(s.population!.stationed(widget.destination) + count)}\n'
                  'Tốn 1 hành động, quân đến ngay.\n$warning',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Để sau'),
              ),
              FilledButton(
                key: const ValueKey('transfer-confirm'),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
    if (accepted != true || !mounted) return;
    setState(() => sending = true);
    final ok = await widget.controller.act(
      'transfer',
      target: widget.destination,
      option: jsonEncode({'from': source, 'count': count}),
    );
    if (!mounted) return;
    setState(() {
      sending = false;
      error = ok ? null : widget.controller.error;
    });
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatGameNumbers(
              'Đã điều ${whole(count)} quân đến ${garrisonNames[widget.destination]}.',
            ),
          ),
        ),
      );
    }
  }
}
