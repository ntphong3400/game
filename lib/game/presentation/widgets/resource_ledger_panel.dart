import 'package:flutter/material.dart';
import '../../models/number_format.dart';
import 'imperial_theme.dart';
import 'petition_art.dart';

Widget _number(String value, {Key? key, Color? color}) => FittedBox(
  fit: BoxFit.scaleDown,
  alignment: Alignment.centerRight,
  child: Text(
    formatGameNumbers(value),
    key: key,
    maxLines: 1,
    textAlign: TextAlign.right,
    style: TextStyle(fontSize: 12, color: color),
  ),
);

class ResourceLedgerRow {
  const ResourceLedgerRow(
    this.id,
    this.label,
    this.actual,
    this.projected, {
    required this.details,
    this.actualKey,
  });
  final String id, label;
  final int? actual, projected;
  final String? actualKey;
  final List<Widget> details;
}

/// Presentation data only. Each resource owns its accounting and projections.
class ResourceLedgerData {
  const ResourceLedgerData({
    required this.hasRecord,
    required this.closed,
    required this.partial,
    required this.opening,
    required this.balance,
    required this.projectedBalance,
    required this.income,
    required this.expense,
    required this.projectedNet,
    required this.rows,
    this.notices = const [],
    this.beforeEntries = const [],
    this.entries,
    this.afterEntries = const [],
  });
  final bool hasRecord, closed, partial;
  final int? opening, balance, projectedBalance, income, expense, projectedNet;
  final List<ResourceLedgerRow> rows;
  final List<Widget> notices, beforeEntries, afterEntries;
  final List<Widget>? entries;
}

class ResourceLedgerPanel extends StatefulWidget {
  const ResourceLedgerPanel({
    super.key,
    required this.prefix,
    required this.title,
    required this.unit,
    required this.periodName,
    required this.currentTurn,
    required this.periods,
    required this.date,
    required this.dataFor,
    required this.itemLabel,
    required this.netLabel,
    required this.balanceLabel,
    required this.emptyEntries,
    this.flat = false,
  });
  final String prefix,
      title,
      unit,
      periodName,
      itemLabel,
      netLabel,
      balanceLabel,
      emptyEntries;
  final int currentTurn;
  final Map<int, bool> periods;
  final String Function(int) date;
  final ResourceLedgerData Function(int) dataFor;
  final bool flat;
  @override
  State<ResourceLedgerPanel> createState() => _ResourceLedgerPanelState();
}

class _ResourceLedgerPanelState extends State<ResourceLedgerPanel> {
  int? selected;
  final expanded = <String>{};
  String get prefix => widget.prefix;
  static String signed(int n) =>
      n > 0
          ? '+$n'
          : n < 0
          ? '−${-n}'
          : '0';
  static String cell(int? n) => n == null || n == 0 ? '—' : signed(n);
  @override
  Widget build(BuildContext context) {
    final turns =
        {widget.currentTurn, ...widget.periods.keys}.toList()
          ..sort((a, b) => b.compareTo(a));
    final turn = turns.contains(selected) ? selected! : widget.currentTurn;
    final d = widget.dataFor(turn), current = turn == widget.currentTurn;
    final forecast = d.projectedBalance != null;
    final content = Column(
      key: ValueKey('$prefix-ledger-book'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('01', style: TextStyle(color: gold, fontSize: 11)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(fontFamily: 'Lora', fontSize: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('$prefix-week-selector'),
          value: turn,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Kỳ ghi sổ (${widget.periodName})',
            isDense: true,
          ),
          items: [
            for (final t in turns)
              DropdownMenuItem(
                value: t,
                child: Text(
                  formatGameNumbers(
                    '${widget.date(t)} · ${widget.periods[t] == true
                        ? 'đã chốt'
                        : t == widget.currentTurn
                        ? 'đang ghi'
                        : 'đã ghi'}',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged:
              (v) => setState(() {
                selected = v == widget.currentTurn ? null : v;
                expanded.clear();
              }),
        ),
        const SizedBox(height: 10),
        Text(
          '${d.closed
              ? 'Đã chốt sổ'
              : current
              ? 'Đang ghi sổ'
              : 'Sổ đã ghi'} · Đơn vị: ${widget.unit}',
          style: const TextStyle(fontSize: 11, color: forest),
        ),
        const SizedBox(height: 14),
        const PetitionRule(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _metric(
                d.partial ? 'Lúc bắt đầu ghi' : 'Đầu ${widget.periodName}',
                d.opening,
                'opening-balance',
              ),
            ),
            Expanded(
              child: _metric(
                current && !d.closed ? 'Hiện có' : 'Cuối ${widget.periodName}',
                d.balance,
                'current-balance',
                color: forest,
              ),
            ),
            if (forecast)
              Expanded(
                child: _metric(
                  'Dự kiến cuối ${widget.periodName}',
                  d.projectedBalance,
                  'closing-estimate',
                  color: gold,
                ),
              ),
          ],
        ),
        ...d.notices,
        const SizedBox(height: 18),
        columns(
          Text(
            widget.itemLabel,
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          const Text(
            'Đã ghi sổ\nĐã phát sinh',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: forest),
          ),
          forecast
              ? const Text(
                'Sắp tới\nDự kiến',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: gold),
              )
              : null,
        ),
        const Divider(height: 16),
        for (final row in d.rows) _row(row, forecast),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: columns(
            Text(
              widget.netLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            _number(
              d.hasRecord ? signed((d.income ?? 0) - (d.expense ?? 0)) : '—',
              key: ValueKey('$prefix-actual-net'),
            ),
            forecast
                ? _number(
                  signed(d.projectedNet ?? 0),
                  key: ValueKey('$prefix-projected-net'),
                )
                : null,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: forest.withValues(alpha: .09),
            border: Border.symmetric(
              horizontal: BorderSide(color: forest.withValues(alpha: .3)),
            ),
          ),
          child: columns(
            Text(
              widget.balanceLabel,
              style: const TextStyle(fontSize: 12, color: forest),
            ),
            _balance(
              d.balance,
              current && !d.closed ? 'Hiện có' : 'Cuối ${widget.periodName}',
              'actual',
            ),
            forecast
                ? _balance(
                  d.projectedBalance,
                  'Cuối ${widget.periodName}',
                  'projected',
                )
                : null,
          ),
        ),
        ...d.beforeEntries,
        if (d.entries != null)
          ExpansionTile(
            key: ValueKey('$prefix-entries-$turn'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              'Chi tiết theo thứ tự phát sinh (${d.entries!.length} khoản)',
              style: const TextStyle(fontSize: 12),
            ),
            children:
                d.entries!.isEmpty
                    ? [
                      Text(
                        widget.emptyEntries,
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ]
                    : d.entries!,
          ),
        ...d.afterEntries,
      ],
    );
    return widget.flat
        ? content
        : Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: paper,
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(6),
          ),
          child: content,
        );
  }

  Widget _balance(int? value, String label, String suffix) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _number(
        '${value ?? '—'}',
        key: ValueKey('$prefix-balance-$suffix'),
        color: forest,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, color: forest),
      ),
    ],
  );

  Widget _metric(
    String label,
    int? value,
    String suffix, {
    Color color = ink,
  }) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatGameNumbers(label),
          style: const TextStyle(fontSize: 11, color: muted),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatGameNumbers('${value ?? '—'}'),
            key: ValueKey('$prefix-$suffix'),
            maxLines: 1,
            style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: color),
          ),
        ),
      ],
    ),
  );
  static Widget columns(Widget label, Widget actual, Widget? projected) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 5, child: label),
      const SizedBox(width: 6),
      Expanded(flex: 3, child: actual),
      if (projected != null) ...[
        const SizedBox(width: 8),
        Expanded(flex: 3, child: projected),
      ],
    ],
  );
  Widget _row(ResourceLedgerRow row, bool forecast) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextButton(
        key: ValueKey('$prefix-row-${row.id}'),
        onPressed:
            () => setState(() {
              expanded.contains(row.id)
                  ? expanded.remove(row.id)
                  : expanded.add(row.id);
            }),
        style: TextButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 44),
          shape: const RoundedRectangleBorder(),
        ),
        child: columns(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                expanded.contains(row.id)
                    ? Icons.arrow_drop_down
                    : Icons.arrow_right,
                size: 16,
                color: gold,
              ),
              Expanded(
                child: Text(
                  formatGameNumbers(row.label),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          _number(
            cell(row.actual),
            key: row.actualKey == null ? null : ValueKey(row.actualKey!),
          ),
          forecast
              ? _number(
                cell(row.projected),
                key: ValueKey('$prefix-future-${row.id}'),
              )
              : null,
        ),
      ),
      if (expanded.contains(row.id))
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.details,
          ),
        ),
      const Divider(height: 1),
    ],
  );
}

class ResourceLedgerLine extends StatelessWidget {
  const ResourceLedgerLine(
    this.title,
    this.amount,
    this.detail, {
    super.key,
    this.warning = false,
  });
  final String title, amount, detail;
  final bool warning;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                formatGameNumbers(title),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _number(amount, color: warning ? terracotta : forest),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatGameNumbers(detail),
          style: const TextStyle(fontSize: 11, color: muted),
        ),
      ],
    ),
  );
}
