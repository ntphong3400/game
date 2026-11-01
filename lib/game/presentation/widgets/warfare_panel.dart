import '../../models/number_format.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../app/game_controller.dart';
import '../../models/game_state.dart';
import '../../logic/warfare_rules.dart';
import '../../logic/frontier_rules.dart';
import '../../logic/population_rules.dart';
import '../../logic/currency_rules.dart';
import 'imperial_theme.dart';

class WarfarePanel extends StatelessWidget {
  const WarfarePanel({
    super.key,
    required this.state,
    required this.controller,
    this.countryId,
    this.showDiplomacy = true,
    this.showRelations = true,
    this.showTreaties = true,
    this.showMissions = true,
    this.showReports = true,
  });
  final GameState state;
  final GameController controller;
  final String? countryId;
  final bool showDiplomacy,
      showRelations,
      showTreaties,
      showMissions,
      showReports;
  Future<bool> send(
    String target,
    Map<String, dynamic> data, {
    String leader = '',
  }) => controller.act(
    'war',
    target: target,
    option: jsonEncode(data),
    assigneeId: leader,
  );

  Future<void> confirm(
    BuildContext context,
    String title,
    String detail,
    String target,
    Map<String, dynamic> data,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(formatGameNumbers(title)),
            content: SingleChildScrollView(
              child: Text(formatGameNumbers(detail)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Để sau'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
    if (ok == true) {
      final success = await send(target, data);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              formatGameNumbers(controller.error ?? 'Chưa thực hiện được.'),
            ),
          ),
        );
      }
    }
  }

  Future<void> deploy(BuildContext context, WarMission mission) async {
    double ratio = warTroopRatios(mission).first;
    String leaderId = '', deputyId = '', tactic = 'balanced';
    String? error;
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, update) {
              final s = controller.state!;
              final leaders = warOfficers(s, naval: mission.naval);
              final leader = leaders.where((c) => c.id == leaderId).firstOrNull;
              final deputy = leaders.where((c) => c.id == deputyId).firstOrNull;
              final troops = warTroops(mission, ratio);
              final quote =
                  leader == null
                      ? null
                      : WarPreview(
                        s,
                        mission,
                        troops,
                        leader,
                        deputy,
                        tactic: tactic,
                      );
              final blocked = warDeployBlocked(
                s,
                mission,
                ratio,
                leader,
                deputy,
              );
              return AlertDialog(
                title: Text(formatGameNumbers(mission.title)),
                content: SizedBox(
                  width: 560,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatGameNumbers(
                            '${garrisonNames[missionGarrison(mission)]} · quân địch: ${whole(mission.enemyTroops)} · quân có thể điều động: ${whole(missionAvailable(s, mission))}',
                          ),
                        ),
                        if (mission.kind == 'siege')
                          const Text(
                            'Công thành bắt buộc ít nhất 200% quân địch.',
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final value in warTroopRatios(mission))
                              ChoiceChip(
                                key: ValueKey('war-ratio-$value'),
                                label: Text(
                                  formatGameNumbers(
                                    '${(value * 100).round()}% · ${whole(warTroops(mission, value))} quân',
                                  ),
                                ),
                                selected: ratio == value,
                                onSelected:
                                    warTroops(mission, value) <=
                                            missionAvailable(s, mission)
                                        ? (_) => update(() {
                                          ratio = value;
                                          error = null;
                                        })
                                        : null,
                              ),
                          ],
                        ),
                        for (final value in warTroopRatios(mission))
                          if (warTroops(mission, value) >
                              missionAvailable(s, mission))
                            Text(
                              formatGameNumbers(
                                '${(value * 100).round()}%: thiếu ${whole(warTroops(mission, value) - missionAvailable(s, mission))} quân',
                              ),
                              style: const TextStyle(color: terracotta),
                            ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: const ValueKey('war-leader'),
                          value:
                              leaders.any((c) => c.id == leaderId)
                                  ? leaderId
                                  : '',
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: formatGameNumbers(
                              mission.naval
                                  ? 'Chủ tướng / đô đốc'
                                  : 'Chủ tướng',
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Chọn chỉ huy'),
                            ),
                            for (final c in leaders)
                              DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  formatGameNumbers(
                                    '${c.name} · năng lực ${c.abilityLabel} · thiện cảm ${c.affection}',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              (value) => update(() {
                                leaderId = value!;
                                if (deputyId == leaderId) deputyId = '';
                                error = null;
                              }),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: ValueKey('war-deputy-$leaderId'),
                          value:
                              leaders.any(
                                    (c) => c.id == deputyId && c.id != leaderId,
                                  )
                                  ? deputyId
                                  : '',
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Phó tướng (tùy chọn)',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Không giao phó tướng'),
                            ),
                            for (final c in leaders.where(
                              (c) => c.id != leaderId,
                            ))
                              DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  formatGameNumbers(
                                    '${c.name} · năng lực ${c.abilityLabel} · thiện cảm ${c.affection}',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              (value) => update(() {
                                deputyId = value!;
                                error = null;
                              }),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: tactic,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Đối sách',
                          ),
                          items: [
                            for (final e in warTactics.entries)
                              DropdownMenuItem(
                                value: e.key,
                                child: Text(formatGameNumbers(e.value)),
                              ),
                          ],
                          onChanged:
                              (v) => update(() {
                                tactic = v!;
                              }),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Thận trọng: sức tiến công ×0,95, thương vong cơ sở ×0,8. Chủ động: sức tiến công ×1,10, thương vong cơ sở ×1,2.',
                        ),
                        if (quote == null)
                          const Text(
                            'Chọn số quân và tướng để dự tính cơ hội thắng.',
                          )
                        else ...[
                          Text(
                            formatGameNumbers(
                              'Cơ hội thắng: ${quote.winChance.toStringAsFixed(1)}%',
                            ),
                            key: const ValueKey('war-win-chance'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Giao chiến: ${quote.tacticalChance}% · nguy cơ tự ý rút quân: ${quote.withdrawal}%',
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Chỉ huy ${quote.command.toStringAsFixed(1)}/100 · thiện cảm phối hợp ${quote.affection.toStringAsFixed(1)}/100',
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Nếu thắng: mất ${whole(quote.winLossMin)}–${whole(quote.winLossMax)} quân. Nếu thua: ${whole(quote.defeatLoss)} quân.',
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Nếu tự ý rút lui: mất ${whole(quote.retreatLossMin)}–${whole(quote.retreatLossMax)} quân; nhiệm vụ thất bại.',
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Chi ${moneyText(s, quote.cost)}, ${whole(quote.food)} tạ, 1 hành động. Hoàn tất cuối ${s.date(s.week + mission.duration - 1)}.',
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Đã cấp trước ${whole(warFoodCredit(troops))} tạ khẩu phần thường lệ; không thu trùng khi khép mùa.',
                            ),
                          ),
                          if (mission.duration == 2)
                            const Text(
                              'Nhiệm vụ dài có yêu cầu tiếp tế giữa chừng. Theo dõi Quân sự trước khi khép mùa.',
                            ),
                          Text(
                            formatGameNumbers(
                              'Còn ${whole(missionAvailable(s, mission) - troops)} quân có thể điều động.',
                            ),
                          ),
                          if (missionAvailable(s, mission) - troops <
                              s.population!.soldiers * .2)
                            const Text(
                              'Lực lượng ở nhà xuống thấp, có thể không đủ xử lý tập kích hoặc cứu viện.',
                              style: TextStyle(color: terracotta),
                            ),
                        ],
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
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Để sau'),
                  ),
                  FilledButton(
                    key: const ValueKey('war-confirm-deploy'),
                    onPressed:
                        blocked == null && !controller.busy
                            ? () async {
                              final ok = await send(mission.id, {
                                'action': 'deploy',
                                'ratio': ratio,
                                'deputy': deputyId,
                                'tactic': tactic,
                              }, leader: leaderId);
                              if (!ctx.mounted) return;
                              if (ok) {
                                Navigator.pop(ctx);
                              } else {
                                update(() {
                                  error = controller.error;
                                });
                              }
                            }
                            : null,
                    child: const Text('Xác nhận xuất quân'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state, w = s.warfare;
    if (w == null) return const SizedBox.shrink();
    Widget section(String text) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(
        formatGameNumbers(text),
        style: const TextStyle(fontSize: 18, fontFamily: 'Lora'),
      ),
    );
    Widget action(
      String label,
      String target,
      Map<String, dynamic> data, {
      String? detail,
      bool enabled = true,
      Key? key,
    }) => OutlinedButton(
      key: key,
      onPressed:
          enabled && !controller.busy
              ? () => confirm(context, label, detail ?? label, target, data)
              : null,
      child: Text(formatGameNumbers(label)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDiplomacy) ...[
          section(
            showRelations && showTreaties
                ? 'Chiến tranh và ngoại giao'
                : showRelations
                ? 'Bang giao'
                : 'Hòa đàm và hòa ước',
          ),
          const Text(
            'Ba nước lân cận; chỉ một cuộc chiến cùng lúc. Thắng để ký hòa ước triều cống, không sáp nhập lãnh thổ.',
          ),
          for (final n in w.neighbors.where(
            (n) => countryId == null || n.id == countryId,
          ))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      formatGameNumbers('${n.name} · ${n.direction}'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatGameNumbers(
                        '${neighborStatus(n)} · quan hệ ${n.relation} · ưu thế ${n.advantage}',
                      ),
                    ),
                    if (n.cooldownUntil > s.week)
                      Text(
                        formatGameNumbers(
                          'Bảo hộ hòa bình đến ${s.date(n.cooldownUntil)}',
                        ),
                      ),
                    if (showRelations &&
                        n.status != 'war' &&
                        n.status != 'treaty')
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          action(
                            'Tuyên chiến',
                            n.id,
                            {'action': 'declare'},
                            key: ValueKey('war-declare-${n.id}'),
                            enabled:
                                w.active == null && n.cooldownUntil <= s.week,
                            detail:
                                'Mở chiến tranh với ${n.name}, 1 hành động. Có thể xuất quân trên nhiều nhiệm vụ; quân và tướng đang bận không được dùng trùng.',
                          ),
                          action(
                            'Giao hảo',
                            n.id,
                            {'action': 'envoy'},
                            detail:
                                'Chi ${moneyText(s, money(s, 10))}, 1 hành động; quan hệ +12.',
                          ),
                        ],
                      ),
                    if (showTreaties && n.status == 'war') ...[
                      const Text(
                        'Hòa đàm: mỗi sứ đoàn tốn 1 hành động. Yêu cầu đối phương cống: phí 1.000 lượng vàng; cầu hòa: phí 2.000 lượng vàng.',
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          action(
                            'Đình chiến (${treatyDemandChance(n, 'armistice')}%)',
                            n.id,
                            {'action': 'negotiate', 'tier': 'armistice'},
                            detail:
                                'Đình chiến 4 mùa, không bên nào triều cống. Đối phương có thể từ chối.',
                          ),
                          for (final tier in ['light', 'medium', 'heavy'])
                            action(
                              'Đòi cống ${tributeNames[tier]} (${treatyDemandChance(n, tier)}%)',
                              n.id,
                              {'action': 'negotiate', 'tier': tier},
                              enabled: treatyDemandChance(n, tier) > 0,
                              detail:
                                  'Yêu cầu nhận ${whole(tributeGold(tier))} lượng vàng/năm × ${tributeYears(tier)} năm. Kỳ đầu sau 4 mùa. Không được hoàn phí nếu bị từ chối.',
                            ),
                          action(
                            'Cầu hòa, nộp triều cống',
                            n.id,
                            {
                              'action': 'negotiate',
                              'tier':
                                  n.advantage <= -70
                                      ? 'heavy'
                                      : n.advantage <= -30
                                      ? 'medium'
                                      : 'light',
                              'surrender': true,
                            },
                            detail:
                                'Nộp ${whole(n.advantage <= -70
                                    ? 17000
                                    : n.advantage <= -30
                                    ? 10000
                                    : 5000)} lượng vàng/năm; thời hạn ${n.advantage < -29 ? 3 : 2} năm. Kỳ đầu sau 4 mùa. Quân sống sót trở về theo lịch.',
                          ),
                        ],
                      ),
                    ],
                    if (showTreaties && n.oldPayable > 0)
                      action(
                        'Trả nợ hòa ước cũ: ${whole(n.oldPayable)} lượng vàng',
                        n.id,
                        {'action': 'oldPay'},
                      ),
                    if (showTreaties && n.oldReceivable > 0)
                      action(
                        'Đòi cống cũ: ${whole(n.oldReceivable)} lượng vàng',
                        n.id,
                        {'action': 'oldCollect'},
                        detail:
                            'Chi 500 lượng vàng, 1 hành động; 70% cơ hội thu khoản cống cũ.',
                      ),
                    if (showTreaties && n.treaty != null) ...[
                      Text(
                        formatGameNumbers(
                          '${n.treaty!.broken
                              ? 'Hòa ước đã bị phá'
                              : n.treaty!.completed || n.status == 'peace'
                              ? 'Hòa ước đã hết hiệu lực'
                              : 'Hòa ước ${tributeNames[n.treaty!.tier]}'}: ${n.treaty!.receiving ? 'nhận' : 'nộp'} ${whole(n.treaty!.annualGold)} lượng vàng/năm.',
                        ),
                      ),
                      if (n.treaty!.tier != 'armistice')
                        Text(
                          formatGameNumbers(
                            'Đã xử lý ${n.treaty!.paidInstallments}/${n.treaty!.installments} kỳ${n.treaty!.paidInstallments < n.treaty!.installments && !n.treaty!.broken ? '; kỳ tiếp theo cuối ${s.date(n.treaty!.nextDue)}' : ''}.',
                          ),
                        ),
                      if (n.treaty!.arrears > 0) ...[
                        Text(
                          formatGameNumbers(
                            'Cống còn thiếu: ${whole(n.treaty!.arrears)} lượng vàng${n.treaty!.graceUntil > 0 ? '; hạn cuối ${s.date(n.treaty!.graceUntil)}' : ''}.',
                          ),
                          style: const TextStyle(color: terracotta),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (!n.treaty!.receiving)
                              action(
                                'Trả bù',
                                n.id,
                                {'action': 'pay'},
                                detail:
                                    'Trả ${whole(n.treaty!.arrears)} lượng vàng còn thiếu, 1 hành động.',
                              ),
                            if (!n.treaty!.broken && n.treaty!.extensions < 1)
                              action('Gia hạn một mùa', n.id, {
                                'action': 'extend',
                              }),
                            if (n.treaty!.receiving)
                              action('Miễn khoản thiếu', n.id, {
                                'action': 'forgive',
                              }),
                            if (n.treaty!.receiving)
                              action(
                                'Gây sức ép đòi cống',
                                n.id,
                                {'action': 'pressure'},
                                detail:
                                    'Chi 500 lượng vàng, 1 hành động; 70% cơ hội thu khoản còn thiếu.',
                              ),
                            if (!n.treaty!.receiving && !n.treaty!.broken)
                              action(
                                'Khước từ trả cống',
                                n.id,
                                {'action': 'refuse'},
                                detail:
                                    'Phá hòa ước, quan hệ −25; nguy cơ tái chiến từ mùa sau. Khoản còn thiếu vẫn tồn tại.',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (showMissions) ...[
          section('Nhiệm vụ chiến tranh'),
          if (!w.missions.any(
            (m) =>
                (countryId == null || m.countryId == countryId) &&
                liveMission(m),
          ))
            const Text('Chưa có nhiệm vụ chiến tranh đang mở.'),
          for (final m in w.missions.where(
            (m) =>
                (countryId == null || m.countryId == countryId) &&
                liveMission(m),
          ))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      formatGameNumbers(m.title),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatGameNumbers(
                        '${w.neighbors.firstWhere((n) => n.id == m.countryId).name} · ${whole(m.enemyTroops)} quân địch',
                      ),
                    ),
                    if (m.status == 'open') ...[
                      Text(
                        formatGameNumbers(
                          'Hạn nhận: cuối ${s.date(m.deadline)} · thời gian ${m.duration} mùa. ${m.kind == 'capital' ? 'Bỏ mặc hoặc phòng thủ thất bại: mất nước.' : 'Bỏ qua: ưu thế −${m.advantageValue}.'}',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          FilledButton(
                            key: ValueKey('war-open-${m.id}'),
                            onPressed:
                                !controller.busy
                                    ? () => deploy(context, m)
                                    : null,
                            child: const Text('Chọn quân và tướng'),
                          ),
                          action(
                            'Bỏ mục tiêu',
                            m.id,
                            {'action': 'decline'},
                            detail:
                                m.kind == 'capital'
                                    ? 'Bỏ bảo vệ kinh thành sẽ mất nước. Có thể cầu hòa để giữ quốc gia.'
                                    : 'Chấp nhận thất bại nhiệm vụ; ưu thế −${m.advantageValue}.',
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        formatGameNumbers(
                          '${whole(m.troops)} quân · ${m.status == 'returning' ? 'đang rút về' : 'đang làm nhiệm vụ'} · về cuối ${s.date(m.due)}',
                        ),
                      ),
                      Text(
                        formatGameNumbers(
                          'Chủ tướng: ${s.court.where((c) => c.id == m.officerId).firstOrNull?.name ?? 'Không còn trong triều'}${m.deputyId.isEmpty ? '' : ' · phó tướng: ${s.court.where((c) => c.id == m.deputyId).firstOrNull?.name ?? 'Không còn trong triều'}'}',
                        ),
                      ),
                      if (m.intervention) ...[
                        const Text(
                          'Đường tiếp tế gặp khó khăn. Cần tiếp tế hoặc rút quân; bỏ mặc khiến nhiệm vụ thất bại.',
                          style: TextStyle(color: terracotta),
                        ),
                        action(
                          'Cấp tiếp tế',
                          m.id,
                          {'action': 'intervene'},
                          detail:
                              'Chi 1.000 lượng vàng, ${whole(warMissionFood(m.troops))} tạ, 1 hành động.',
                        ),
                      ],
                      if (m.status == 'deployed')
                        action(
                          'Rút quân',
                          m.id,
                          {'action': 'withdraw'},
                          detail:
                              'Bỏ mục tiêu, mất ưu thế và chịu tổn thất khi rút lui. Kinh phí không hoàn; quân trở về theo lịch.',
                        ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (showReports &&
            w.reports.any(
              (r) => countryId == null || r['countryId'] == countryId,
            )) ...[
          section('Quân báo gần nhất'),
          for (final report in w.reports
              .where((r) => countryId == null || r['countryId'] == countryId)
              .take(8))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                formatGameNumbers(
                  '${s.date(report['week'] as int)} · ${report['title']}\n${report['detail']}',
                ),
              ),
            ),
        ],
      ],
    );
  }
}
