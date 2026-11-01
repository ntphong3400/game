import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import '../../data/content.dart';
import '../../logic/personnel_rules.dart';
import '../../models/game_state.dart';
import 'imperial_room.dart';
import 'imperial_assets.dart';
import 'memorial_paper.dart';
import 'imperial_theme.dart';
import 'kingdom_style.dart';
import 'kingdom_dossier.dart';
import 'outcome_panel.dart';
import 'reign_panel.dart';
import 'imperial_dialog.dart';
import '../../logic/reign_rules.dart';
import '../../logic/population_rules.dart';

class KingdomPanel extends StatefulWidget {
  const KingdomPanel({
    super.key,
    required this.state,
    required this.busy,
    required this.actions,
    required this.onAction,
    required this.blockedReason,
    required this.send,
    this.readState,
    this.isBusy,
  });
  final GameState state;
  final bool busy;
  final List<ActionDefinition> actions;
  final Future<void> Function(ActionDefinition) onAction;
  final String? Function(ActionDefinition) blockedReason;
  final ReignCommand send;
  // Detail routes can outlive a parent frame while a command is committed.
  final GameState Function()? readState;
  final bool Function()? isBusy;

  @override
  State<KingdomPanel> createState() => _KingdomPanelState();
}

class _KingdomPanelState extends State<KingdomPanel> {
  GameState get s => widget.readState?.call() ?? widget.state;

  static const _titles = {
    1: 'Đang thực hiện',
    2: 'Nghĩa vụ và ảnh hưởng đang hiệu lực',
    3: 'Đối sách khẩn cấp',
    4: 'Kết quả đã nhận',
  };

  Future<void> _open(int section) => showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder:
              (context, refresh) => ImperialAlertDialog(
                key: ValueKey('kingdom-detail-$section'),
                title: Text(
                  formatGameNumbers(_titles[section]!),
                  style: const TextStyle(fontFamily: 'Lora', fontSize: 22),
                ),
                width: 760,
                content:
                    section == 1
                        ? _ongoing(showHeading: false)
                        : section == 4
                        ? OutcomePanel(
                          reports: s.outcomes,
                          seasonal: s.seasonal,
                          showHeading: false,
                        )
                        : ReignPanel(
                          state: s,
                          busy: widget.isBusy?.call() ?? widget.busy,
                          showObligations: section == 2,
                          showEmergencies: section == 3,
                          showSectionHeaders: false,
                          send: (type, target, option) async {
                            await widget.send(type, target, option);
                            if (context.mounted) refresh(() {});
                          },
                        ),
                actions: [
                  OutlinedButton(
                    key: const ValueKey('close-kingdom-detail'),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Về Quốc sự'),
                  ),
                ],
              ),
        ),
  );

  Widget _header() => const Padding(
    padding: EdgeInsets.fromLTRB(4, 0, 4, 14),
    child: Row(
      children: [
        ImperialIcon('citadel', size: 44),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quốc sự',
                style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 1.2),
              ),
              SizedBox(height: 4),
              Text(
                'Ban lệnh, giao người, theo dõi thành quả.',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final orders = KingdomSection(
        number: '01',
        title: 'Ban hành công việc',
        subtitle: 'Chọn việc để xem tác dụng, rủi ro và giao quan phụ trách.',
        child: _orders(),
      );
      if (!bounds.hasBoundedHeight) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            _overview(compact: true, dense: false),
            const SizedBox(height: 12),
            orders,
          ],
        );
      }
      final wide = bounds.maxWidth >= 920 && bounds.maxHeight >= 360;
      if (wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: RoomPane(padding: 4, child: orders)),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: RepaintBoundary(
                        key: const ValueKey('kingdom-dossier-rail'),
                        child: _overview(compact: false, dense: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      final dense = bounds.maxHeight < 430;
      final horizontal = bounds.maxWidth >= 600 && dense;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!dense) _header(),
          _overview(compact: true, dense: dense, horizontal: horizontal),
          const SizedBox(height: 10),
          Expanded(child: RoomPane(padding: 4, child: orders)),
        ],
      );
    },
  );

  Widget _overview({
    required bool compact,
    required bool dense,
    bool horizontal = false,
  }) {
    if (!compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in [2, 3, 1, 4]) ...[
            if (section != 2) const SizedBox(height: 5),
            Expanded(
              child: KingdomDossier(
                section: section,
                title: _titles[section]!,
                badge:
                    section == 3
                        ? '${_count(3)}/3 có thể dùng'
                        : '${_count(section)}',
                summary: _summary(section),
                preview: _preview(section),
                onOpen: () => _open(section),
              ),
            ),
          ],
        ],
      );
    }
    final sections = [2, 3, 1, 4];
    final columns = horizontal ? 4 : 2;
    // Let content determine tile height, including larger accessibility text.
    final grid = Column(
      children: [
        for (var i = 0; i < sections.length; i += columns) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _overviewCard(
                      sections[i + j],
                      compact: true,
                      dense: dense,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
    return grid;
  }

  int _count(int section) => switch (section) {
    1 => s.projects.length + s.pending.length,
    2 => s.obligations.length,
    3 =>
      emergencyNames.keys
          .where((kind) => emergencyBlocked(s, kind) == null)
          .length,
    _ => s.outcomes.length,
  };

  String _summary(int section) => switch (section) {
    1 =>
      _count(1) == 0
          ? 'Chưa có công việc dài hạn.'
          : '${_count(1)} việc đang chờ hoàn tất',
    2 =>
      _count(2) == 0
          ? 'Chưa có nghĩa vụ đang hiệu lực.'
          : '${_count(2)} nghĩa vụ đang hiệu lực',
    3 => '${_count(3)}/3 đối sách có thể dùng',
    _ =>
      s.outcomes.isEmpty
          ? 'Chưa có báo cáo.'
          : '${s.outcomes.length} báo cáo · xem theo ${s.periodName}',
  };

  Widget _overviewCard(
    int section, {
    bool compact = false,
    bool dense = false,
  }) {
    final color = section == 3 ? terracotta : forest;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!dense) ...[
              SizedBox(
                width: 26,
                height: 33,
                child: KingdomDossierPainting(section: section),
              ),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                formatGameNumbers(
                  dense
                      ? switch (section) {
                        2 => 'Nghĩa vụ & ảnh hưởng',
                        3 => 'Đối sách khẩn cấp',
                        1 => 'Đang thực hiện',
                        _ => 'Kết quả đã nhận',
                      }
                      : _titles[section]!,
                ),
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: compact ? 11 : 15,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.chevron_right, size: 16, color: color),
          ],
        ),
        if (!dense) const SizedBox(height: 7),
        if (!dense)
          Text(
            formatGameNumbers(_summary(section)),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: dense ? 9 : 10,
              color: muted,
              height: 1.5,
            ),
          ),
        if (!compact) ...[
          const SizedBox(height: 9),
          Expanded(child: _preview(section)),
          const SizedBox(height: 6),
          Text(
            'Mở sổ →',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
    return TextButton(
      key: ValueKey('kingdom-open-$section'),
      onPressed: () => _open(section),
      style: TextButton.styleFrom(
        foregroundColor: ink,
        backgroundBuilder:
            (context, states, child) =>
                KingdomButtonFrame(child: child ?? const SizedBox()),
        padding: EdgeInsets.all(dense ? 8 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontFamily: 'BeVietnam'),
        alignment: Alignment.topLeft,
      ),
      child: body,
    );
  }

  Widget _preview(int section) {
    if (section == 2) {
      if (s.obligations.isEmpty) return _previewLine(_summary(2), muted);
      return _previewLines([
        for (final o in s.obligations.take(2))
          (
            '${o.title}${o.amount > 0
                ? ' · −${o.amount} ${moneyUnit(s)}/kỳ'
                : o.income > 0
                ? ' · +${o.income} ${moneyUnit(s)}/kỳ'
                : ''}',
            o.amount > 0 ? terracotta : forest,
          ),
      ]);
    }
    if (section == 3) {
      return _previewLines([
        ('Vay thế gia · Tuyển quân · Cầu hòa', ink),
        ('Xem điều kiện và nghĩa vụ trước khi ban lệnh.', muted),
      ]);
    }
    if (section == 1) {
      if (s.projects.isEmpty && s.pending.isEmpty) {
        return _previewLine(_summary(1), muted);
      }
      final project = s.projects.firstOrNull;
      final pending = s.pending.firstOrNull;
      return LayoutBuilder(
        builder:
            (context, bounds) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (project != null) ...[
                  _previewLine(
                    '${projectTitle(project.kind)} · ${project.progress}/${project.duration} kỳ',
                    forest,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 5),
                    child: LinearProgressIndicator(
                      value:
                          project.duration > 0
                              ? (project.progress / project.duration).clamp(
                                0.0,
                                1.0,
                              )
                              : 0,
                      minHeight: 4,
                      color: forest,
                      backgroundColor: line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
                if (pending != null &&
                    (project == null || bounds.maxHeight >= 52))
                  _previewLine(
                    '${pending.title.isNotEmpty ? pending.title : _pendingName(pending.kind)} · ${s.date(pending.dueWeek)}',
                    muted,
                  ),
              ],
            ),
      );
    }
    if (s.outcomes.isEmpty) return _previewLine(_summary(4), muted);
    final report = s.outcomes.reduce((a, b) => b.week >= a.week ? b : a);
    final changes = report.changes.entries
        .take(2)
        .map(
          (e) =>
              '${gameStatLabel(e.key)} ${e.value > 0 ? '+' : '−'}${e.value.abs()}',
        )
        .join(' · ');
    return _previewLines([
      (report.title, ink),
      (
        '${report.statusLabel}${changes.isEmpty ? '' : ' · $changes'}',
        report.status == 'success' ? forest : terracotta,
      ),
    ]);
  }

  Widget _previewLines(List<(String, Color)> lines) => LayoutBuilder(
    builder:
        (context, bounds) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (text, color) in lines.take(
              bounds.maxHeight >= 37 ? 2 : 1,
            ))
              _previewLine(text, color),
          ],
        ),
  );

  Widget _previewLine(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text(
      formatGameNumbers(text),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 11, color: color, height: 1.4),
    ),
  );

  Widget _orders() => LayoutBuilder(
    builder: (context, bounds) {
      final columns = bounds.maxWidth >= 520 ? 2 : 1;
      final artHeight =
          (((bounds.maxWidth - (columns - 1) * 10) / columns - 35) / 3.5).clamp(
            64.0,
            108.0,
          );
      return Column(
        children: [
          for (var i = 0; i < widget.actions.length; i += columns) ...[
            if (i > 0) const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 10),
                    Expanded(
                      child:
                          i + j < widget.actions.length
                              ? _order(widget.actions[i + j], artHeight)
                              : const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _order(ActionDefinition action, double artHeight) {
    final (icon, summary) = switch (action.id) {
      'govern' => (
        Icons.account_balance_outlined,
        'Củng cố uy quyền và ổn định triều đình.',
      ),
      'relief' => (
        Icons.volunteer_activism_outlined,
        'Cấp lương cứu đói, trấn an lòng dân.',
      ),
      'mediate' => (
        Icons.balance_outlined,
        'Xoa dịu bất mãn và hàn gắn các phe.',
      ),
      'train' => (
        Icons.shield_outlined,
        'Rèn quân sĩ, tăng sức mạnh quân đội.',
      ),
      'farm' => (Icons.grass_outlined, 'Mở thêm ruộng, vun nguồn lương thực.'),
      'security' => (
        Icons.security_outlined,
        'Ngăn âm mưu, giữ yên chốn cung đình.',
      ),
      _ => (
        Icons.public_outlined,
        action.icon == 'population'
            ? action.description
            : 'Cử sứ giả đàm phán, hạ nhiệt chiến sự.',
      ),
    };
    final reason = widget.blockedReason(action);
    return RepaintBoundary(
      key: ValueKey('kingdom-document-${action.id}'),
      child: MemorialPaper(
        readKey: ValueKey('kingdom-paper-${action.id}'),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              left: 5,
              top: 12,
              bottom: 12,
              width: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: forest,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: gold.withValues(alpha: .65),
                    width: .6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 6, 7, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: artHeight,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback:
                          (rect) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0, .65, 1],
                          ).createShader(rect),
                      child: Image.asset(
                        'assets/images/kingdom/${action.icon == 'population' ? (['recruit', 'demobilize', 'equipment', 'reward_army'].contains(action.id) ? 'train' : 'farm') : action.id}.webp',
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(icon, size: 15, color: forest),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formatGameNumbers(
                            taskSpecialties[action.id] ?? 'Triều chính',
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            color: forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatGameNumbers(action.title),
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 17,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      formatGameNumbers(summary),
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      KingdomPill(
                        '${actionCost(s, action)} ${moneyUnit(s)}',
                        icon: Icons.toll_outlined,
                        color: gold,
                      ),
                      if (actionGrainCost(s, action) > 0)
                        KingdomPill(
                          '${whole(actionGrainCost(s, action))} ${foodUnit(s)}',
                          icon: Icons.grass_outlined,
                          color: gold,
                        ),
                      const KingdomPill(
                        '1 hành động',
                        icon: Icons.directions_walk_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Tooltip(
                    message: formatGameNumbers(action.title),
                    child: OutlinedButton(
                      key: ValueKey('action-${action.id}'),
                      onPressed:
                          reason == null ? () => widget.onAction(action) : null,
                      style: OutlinedButton.styleFrom(
                        backgroundBuilder:
                            (context, states, child) => KingdomButtonFrame(
                              child: child ?? const SizedBox(),
                            ),
                        foregroundColor: forest,
                        side: BorderSide.none,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Xem & giao việc')),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 17),
                        ],
                      ),
                    ),
                  ),
                  if (reason != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      formatGameNumbers(reason),
                      style: const TextStyle(fontSize: 10, color: terracotta),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ongoing({bool showHeading = true}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.projects.isEmpty && s.pending.isEmpty)
          const KingdomEmpty(
            icon: Icons.pending_actions_outlined,
            title: 'Chưa có công việc dài hạn.',
            detail:
                'Hãy chọn người và giao việc. Tiến độ và ngày hoàn tất sẽ được ghi tại đây.',
          ),
        for (final p in s.projects)
          _workEntry(
            title:
                '${projectTitle(p.kind)} · ${s.court.where((c) => c.id == p.officerId).firstOrNull?.name ?? 'Người phụ trách'}',
            detail:
                '${p.progress}/${p.duration} kỳ · dự kiến cuối ${s.date(p.startedWeek + p.duration - 1)}',
            note:
                'Khi hoàn tất sẽ xét chuyên môn và năng lực; có thể thất bại.',
            progress:
                p.duration > 0 ? (p.progress / p.duration).clamp(0.0, 1.0) : 0,
          ),
        for (final p in s.pending)
          _workEntry(
            title:
                '${p.title.isNotEmpty ? p.title : _pendingName(p.kind)} · dự kiến cuối ${s.date(p.dueWeek)}${p.assignment == null ? '' : '\n${p.assignment!.personLabel} · ${p.assignment!.chance}% thành công'}',
          ),
      ],
    );
    return showHeading
        ? KingdomSection(
          number: '02',
          title: 'Đang thực hiện',
          count: _count(1),
          child: content,
        )
        : content;
  }

  Widget _workEntry({
    required String title,
    String? detail,
    String? note,
    double? progress,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7, right: 12),
          decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formatGameNumbers(title),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  color: forest,
                  backgroundColor: line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  formatGameNumbers(detail),
                  style: const TextStyle(fontSize: 11, color: forest),
                ),
              ],
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  formatGameNumbers(note),
                  style: const TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  String _pendingName(String key) => switch (key) {
    'envoy' => 'Sứ đoàn hòa đàm',
    'investigate' => 'Điều tra nhân vật',
    'audit' => 'Kiểm toán',
    'trade' => 'Thương lộ',
    'school' => 'Xây lớp học',
    'weapons' => 'Quân khí',
    'security' => 'Điều tra tin mật',
    _ => key,
  };
}
