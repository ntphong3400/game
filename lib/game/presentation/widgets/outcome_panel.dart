import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_dialog.dart';
import '../../models/game_state.dart';
import 'kingdom_style.dart';

const _muted = Color(0xFF788076);
const _forest = Color(0xFF3E5947);
const _warning = Color(0xFFA55F49);

class OutcomeCard extends StatelessWidget {
  const OutcomeCard({super.key, required this.report, this.seasonal = false});
  final OutcomeReport report;
  final bool seasonal;

  @override
  Widget build(BuildContext context) {
    final color = report.status == 'success' ? _forest : _warning;
    return Container(
      key: ValueKey('outcome-${report.id}'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatGameNumbers(report.title),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            formatGameNumbers(
              '${seasonal ? seasonDate(report.week) : 'Tuần ${report.week}'} · ${report.statusLabel}',
            ),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatGameNumbers(
              seasonal
                  ? gameStatText(
                    report.detail,
                  ).replaceAll(RegExp(r'\btuần\b(?! phủ)'), 'mùa')
                  : gameStatText(report.detail),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (report.changes.isEmpty)
            Text(
              'Không có thay đổi trực tiếp về tài nguyên hoặc chỉ số hiển thị.',
              style: TextStyle(fontSize: 11, color: _muted),
            )
          else ...[
            Text(
              'Tác động của kết quả:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final e in report.changes.entries)
                  Text(
                    formatGameNumbers(
                      '${gameStatLabel(e.key)} ${e.value > 0 ? '+' : '−'}${e.value.abs()}',
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

const outcomeExplanation =
    'Tác động riêng của từng kết quả, trước giới hạn chỉ số; chưa gồm thu/chi thường lệ và diễn biến khác trong tuần. Kinh phí đã cấp trước đó không trừ lại ở đây.';

class OutcomePanel extends StatefulWidget {
  const OutcomePanel({
    super.key,
    required this.reports,
    this.seasonal = false,
    this.showHeading = true,
  });
  final List<OutcomeReport> reports;
  final bool seasonal, showHeading;
  @override
  State<OutcomePanel> createState() => _OutcomePanelState();
}

class _OutcomePanelState extends State<OutcomePanel> {
  int? selectedWeek;
  @override
  Widget build(BuildContext context) {
    final weeks =
        widget.reports.map((r) => r.week).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
    final week =
        weeks.contains(selectedWeek) ? selectedWeek : weeks.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeading) ...[
          Text(
            'Kết quả đã nhận',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
        ],
        if (week == null)
          KingdomEmpty(
            icon: Icons.task_alt_outlined,
            title: 'Chưa có báo cáo.',
            detail:
                'Công việc và sự kiện đến hạn sẽ hiện popup sau khi sang ${widget.seasonal ? 'mùa' : 'tuần'}; kết quả được lưu tại đây để xem lại.',
          )
        else ...[
          DropdownButtonFormField<int>(
            key: const ValueKey('outcome-week-selector'),
            value: week,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: formatGameNumbers(
                'Xem kết quả theo ${widget.seasonal ? 'mùa' : 'tuần'}',
              ),
              isDense: true,
            ),
            items: [
              for (final w in weeks)
                DropdownMenuItem(
                  value: w,
                  child: Text(
                    formatGameNumbers(
                      'Kết quả cuối ${widget.seasonal ? seasonDate(w) : 'tuần $w'}',
                    ),
                  ),
                ),
            ],
            onChanged: (value) => setState(() => selectedWeek = value),
          ),
          const SizedBox(height: 14),
          ...widget.reports.reversed
              .where((r) => r.week == week)
              .map((r) => OutcomeCard(report: r, seasonal: widget.seasonal)),
          Text(
            formatGameNumbers(
              widget.seasonal
                  ? outcomeExplanation.replaceAll('tuần', 'mùa')
                  : outcomeExplanation,
            ),
            style: TextStyle(fontSize: 10, color: _muted),
          ),
        ],
      ],
    );
  }
}

Future<void> showOutcomeReports(
  BuildContext context,
  List<OutcomeReport> reports, {
  bool seasonal = false,
}) => showDialog<void>(
  context: context,
  builder:
      (context) => ImperialAlertDialog(
        key: const ValueKey('outcome-dialog'),
        title: Text(
          formatGameNumbers('Báo cáo kết quả · ${reports.length}'),
          style: const TextStyle(fontFamily: 'Lora', fontSize: 22),
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...reports.map(
                  (r) => OutcomeCard(report: r, seasonal: seasonal),
                ),
                Text(
                  formatGameNumbers(
                    seasonal
                        ? outcomeExplanation.replaceAll('tuần', 'mùa')
                        : outcomeExplanation,
                  ),
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
                const SizedBox(height: 8),
                Text(
                  'Xem lại tại Quốc sự → Kết quả đã nhận.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            key: const ValueKey('close-outcome-dialog'),
            onPressed: () => Navigator.pop(context),
            child: Text('Đã xem'),
          ),
        ],
      ),
);
