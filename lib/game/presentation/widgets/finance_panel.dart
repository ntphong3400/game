import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/finance_rules.dart';
import '../../logic/development_rules.dart';
import 'imperial_theme.dart';
import 'petition_art.dart';

/// Reads posted cash and the existing budget calculation without changing either.
/// The treasury pane owns scrolling; the widget also supports unbounded parents.
class FinancePanel extends StatefulWidget {
  const FinancePanel({super.key, required this.state, this.flat = false});
  final GameState state;
  final bool flat;
  @override
  State<FinancePanel> createState() => _FinancePanelState();
}

class _FinancePanelState extends State<FinancePanel> {
  GameState get s => widget.state;
  int? selectedWeek;
  final expanded = <String>{};
  String _signed(int amount) =>
      amount > 0
          ? '+$amount'
          : amount < 0
          ? '−${-amount}'
          : '0';
  String _cash(int? amount) =>
      amount == null || amount == 0 ? '—' : _signed(amount);

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final weeks =
        {s.week, ...s.financialWeeks.map((w) => w.week)}.toList()
          ..sort((a, b) => b.compareTo(a));
    final week = weeks.contains(selectedWeek) ? selectedWeek! : s.week;
    final report = s.financialWeeks.where((w) => w.week == week).firstOrNull;
    final current = week == s.week;
    final forecast =
        current && !s.ended && report?.closed != true
            ? BudgetProjection(s)
            : null;
    final entries = report?.entries ?? <FinanceEntry>[];
    final income = entries.where((e) => e.amount > 0).toList();
    final other =
        entries
            .where(
              (e) =>
                  e.amount < 0 &&
                  e.category != 'budget' &&
                  e.category != 'debt',
            )
            .toList();
    final regular =
        entries.where((e) => e.amount < 0 && e.category == 'budget').toList();
    final repayments =
        entries.where((e) => e.amount < 0 && e.category == 'debt').toList();
    int? sum(List<FinanceEntry> items) =>
        report == null ? null : items.fold<int>(0, (a, e) => a + e.amount);
    final actualBalance =
        report?.closingBalance ?? (current ? s.treasury : null);
    final content = Column(
      key: const ValueKey('finance-ledger-book'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Text('01', style: TextStyle(color: gold, fontSize: 11)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sổ ngân khố',
                style: TextStyle(fontFamily: 'Lora', fontSize: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: const ValueKey('finance-week-selector'),
          value: week,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: formatGameNumbers('Kỳ ghi sổ (${s.periodName})'),
            isDense: true,
          ),
          items: [
            for (final value in weeks)
              DropdownMenuItem(
                value: value,
                child: Text(
                  formatGameNumbers(
                    '${s.date(value)} · ${s.financialWeeks.where((w) => w.week == value).firstOrNull?.closed == true
                        ? 'đã chốt'
                        : value == s.week
                        ? 'đang ghi'
                        : 'đã ghi'}',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged:
              (value) => setState(() {
                selectedWeek = value == s.week ? null : value;
                expanded.clear();
              }),
        ),
        const SizedBox(height: 10),
        Text(
          formatGameNumbers(
            '${report?.closed == true
                ? 'Đã chốt sổ'
                : current
                ? 'Đang ghi sổ'
                : 'Sổ đã ghi'} · Đơn vị: ${moneyUnit(s)}',
          ),
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
                report?.partial == true
                    ? 'Lúc bắt đầu ghi'
                    : 'Đầu ${s.periodName}',
                report?.openingBalance,
                'finance-opening-balance',
              ),
            ),
            Expanded(
              child: _metric(
                current && report?.closed != true
                    ? 'Hiện có'
                    : 'Cuối ${s.periodName}',
                actualBalance,
                'finance-current-balance',
                color: forest,
              ),
            ),
            if (forecast != null)
              Expanded(
                child: _metric(
                  'Dự kiến cuối ${s.periodName}',
                  forecast.closingBalance,
                  'finance-closing-estimate',
                  color: gold,
                ),
              ),
          ],
        ),
        if (report == null) ...[
          const SizedBox(height: 12),
          const Text(
            'Chưa có sổ chi tiết cho kỳ này. Các khoản sẽ được ghi từ hành động tiếp theo; thu/chi trước đó không được dựng lại.',
            style: TextStyle(fontSize: 11, color: muted),
          ),
          if (s.completedWeeks > 0 && s.financialWeeks.isEmpty)
            Text(
              formatGameNumbers(
                'Số tổng cũ của kỳ thường lệ gần nhất: thu ${s.lastIncome}, thực chi ${s.lastExpense}; chưa gồm nhiệm vụ và sự kiện.',
              ),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
        ],
        if (report?.partial == true) ...[
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(
              '${s.periodTitle} này chỉ ghi từ lúc cập nhật game. Các khoản trước đó chưa có dữ liệu chi tiết.',
            ),
            style: const TextStyle(fontSize: 11, color: terracotta),
          ),
        ],
        const SizedBox(height: 18),
        _columns(
          const Text(
            'Khoản tiền',
            style: TextStyle(fontSize: 11, color: muted),
          ),
          const Text(
            'Đã ghi sổ\nĐã phát sinh',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: forest),
          ),
          forecast == null
              ? null
              : const Text(
                'Sắp tới\nDự kiến',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: gold),
              ),
        ),
        const Divider(height: 16),
        _row(
          'income',
          'Tiền thu vào',
          sum(income),
          forecast?.totalIncome,
          actualKey: 'finance-total-income',
          hasForecast: forecast != null,
          details: [
            ..._actualItems(income),
            if (forecast != null) ...[
              _detailLabel('SẮP TỚI · THU THƯỜNG LỆ'),
              for (final item in forecast.income)
                _line(item.title, '+${item.amount}', item.detail),
            ],
          ],
        ),
        _row(
          'other',
          'Chi công việc & phát sinh',
          sum(other),
          null,
          hasForecast: forecast != null,
          details: [
            ..._actualItems(other),
            const Text(
              'Gồm công việc, quyết định, sự kiện và các khoản ngoài chi thường lệ. Phần sắp tới chưa dự tính các khoản này.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
        _row(
          'regular',
          'Chi thường lệ',
          sum(regular),
          forecast == null
              ? null
              : -(forecast.paidExpense - forecast.repayment),
          hasForecast: forecast != null,
          details: [
            ..._actualItems(regular),
            if (forecast != null) ...[
              _detailLabel('SẮP TỚI · THEO THỨ TỰ ƯU TIÊN'),
              Text(
                formatGameNumbers(
                  'Cần trả ${forecast.requiredExpense} · trả được ${forecast.paidExpense - forecast.repayment} · thiếu ${forecast.shortfall}.',
                ),
                style: const TextStyle(fontSize: 11),
              ),
              for (var i = 0; i < forecast.expenses.length; i++)
                _line(
                  forecast.expenses[i].title,
                  '−${forecast.payable[i]}',
                  '${forecast.expenses[i].detail} Cần trả ${forecast.expenses[i].amount} · trả được ${forecast.payable[i]} · còn thiếu ${forecast.expenses[i].amount - forecast.payable[i]}.',
                  warning: forecast.payable[i] < forecast.expenses[i].amount,
                ),
            ],
          ],
        ),
        _row(
          'repayment',
          'Trả nợ',
          sum(repayments),
          forecast == null ? null : -forecast.repayment,
          hasForecast: forecast != null,
          details: [
            ..._actualItems(repayments),
            if (forecast != null)
              Text(
                formatGameNumbers(
                  'Dự kiến trả ${forecast.repayment}. Sau chi thường lệ, trả tối đa ${money(s, 10)} ${moneyUnit(s)} nợ/${s.periodName} và giữ lại ít nhất ${money(s, 20)} ${moneyUnit(s)} trong ngân khố.',
                ),
                style: const TextStyle(fontSize: 11, color: muted),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _columns(
            Text(
              'Tiền tăng / giảm',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              formatGameNumbers(
                report == null ? '—' : _signed(report.income - report.expense),
              ),
              key: const ValueKey('finance-actual-net'),
              textAlign: TextAlign.right,
            ),
            forecast == null
                ? null
                : Text(
                  formatGameNumbers(
                    _signed(forecast.totalIncome - forecast.paidExpense),
                  ),
                  key: const ValueKey('finance-projected-net'),
                  textAlign: TextAlign.right,
                ),
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
          child: _columns(
            const Text(
              'Tiền còn lại',
              style: TextStyle(fontSize: 12, color: forest),
            ),
            Text(
              formatGameNumbers(
                '${actualBalance ?? '—'}\n${current && report?.closed != true ? 'Hiện có' : 'Cuối ${s.periodName}'}',
              ),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: forest),
            ),
            forecast == null
                ? null
                : Text(
                  formatGameNumbers(
                    '${forecast.closingBalance}\nCuối ${s.periodName}',
                  ),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: forest),
                ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          formatGameNumbers(
            'Nợ chi trả: ${current ? 'hiện tại ${s.debt}' : 'cuối ${s.periodName} ${report?.closingDebt ?? '—'}'}${forecast == null ? '' : ' → dự kiến ${forecast.closingDebt}'}',
          ),
          key: const ValueKey('finance-debt-summary'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        if (forecast != null && forecast.shortfall > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              formatGameNumbers(
                s.warfare == null
                    ? 'Thiếu ${forecast.shortfall} ${moneyUnit(s)} chi thường lệ sẽ thành nợ và gây mất chỉ số ở khoản chưa trả đủ.'
                    : 'Thiếu ${forecast.shortfall} ${moneyUnit(s)} ở các khoản đến hạn. Chi thường lệ thiếu ghi vào nợ chi trả; triều cống thiếu ghi riêng trong hòa ước tại Quân sự.',
              ),
              key: const ValueKey('finance-shortfall'),
              style: const TextStyle(fontSize: 11, color: terracotta),
            ),
          ),
        if (report != null) ...[
          const SizedBox(height: 8),
          Text(
            formatGameNumbers(
              'Nợ phát sinh: +${report.newDebt} · Nợ giảm: −${report.debtReduction}',
            ),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          const SizedBox(height: 8),
          Text(
            formatGameNumbers(
              '${report.partial ? 'Lúc bắt đầu ghi' : 'Đầu ${s.periodName}'} ${report.openingBalance} + thu ${report.income} − chi ${report.expense} = ${report.closed ? 'cuối ${s.periodName}' : 'đang có'} ${report.closingBalance}.',
            ),
            key: const ValueKey('finance-reconciliation'),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          Text(
            formatGameNumbers(
              'Nợ ${report.openingDebt} + phát sinh ${report.newDebt} − giảm ${report.debtReduction} = ${report.closingDebt}.',
            ),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          ExpansionTile(
            key: ValueKey('finance-entries-$week'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              formatGameNumbers(
                'Chi tiết theo thứ tự phát sinh (${entries.length} khoản)',
              ),
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              if (entries.isEmpty)
                const Text(
                  'Kỳ này chưa có khoản tiền nào phát sinh.',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              for (final entry in entries) _entry(entry),
            ],
          ),
        ],
        if (forecast != null) ...[
          const SizedBox(height: 10),
          Text(
            formatGameNumbers(
              '“Sắp tới” chỉ tính thu chi thường lệ cuối ${s.date(s.week)}; chưa ghi vào ngân khố. Công việc, tấu chương và sự kiện đến hạn có thể làm số thực tế thay đổi. Chi bằng thóc không tính thành chi tiền.',
            ),
            key: const ValueKey('finance-projection'),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          if (s.seasonal) ...[
            const Divider(height: 26),
            const Text(
              'Thuế vụ Thu — kế hoạch thu năm',
              key: ValueKey('annual-tax-plan'),
              style: TextStyle(fontFamily: 'Lora', fontSize: 14),
            ),
            Text(
              formatGameNumbers(
                'Tạm tính kỳ ${s.date(s.nextTaxTurn)}: +${annualTaxRevenue(s, year: s.nextTaxYear)} ${moneyUnit(s)}, theo lòng dân hiện tại; đã gồm +${money(s, economyAnnualBonus(s))} ${moneyUnit(s)} từ kinh tế cấp ${s.economyLevel}. ${s.autumnTaxDue ? 'Khoản này có trong dự toán cuối mùa Thu.' : 'Không có thuế trong dự toán mùa này; số dự kiến chưa được cộng vào ngân khố.'}',
              ),
              key: const ValueKey('annual-tax-estimate'),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ],
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

  Widget _metric(String label, int? value, String key, {Color color = ink}) =>
      Padding(
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
                key: ValueKey(key),
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 27,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
  Widget _columns(Widget label, Widget actual, Widget? projected) => Row(
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
  Widget _row(
    String id,
    String label,
    int? actual,
    int? projected, {
    required bool hasForecast,
    String? actualKey,
    required List<Widget> details,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextButton(
        key: ValueKey('finance-row-$id'),
        onPressed:
            () => setState(() {
              expanded.contains(id) ? expanded.remove(id) : expanded.add(id);
            }),
        style: TextButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 44),
          shape: const RoundedRectangleBorder(),
        ),
        child: _columns(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                expanded.contains(id)
                    ? Icons.arrow_drop_down
                    : Icons.arrow_right,
                size: 16,
                color: gold,
              ),
              Expanded(
                child: Text(
                  formatGameNumbers(label),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          Text(
            formatGameNumbers(_cash(actual)),
            key: actualKey == null ? null : ValueKey(actualKey),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12),
          ),
          hasForecast
              ? Text(
                formatGameNumbers(_cash(projected)),
                key: ValueKey('finance-future-$id'),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              )
              : null,
        ),
      ),
      if (expanded.contains(id))
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: details,
          ),
        ),
      const Divider(height: 1),
    ],
  );
  List<Widget> _actualItems(List<FinanceEntry> entries) => [
    _detailLabel('ĐÃ GHI SỔ'),
    if (entries.isEmpty)
      const Text(
        'Chưa ghi nhận khoản tiền nào trong nhóm này.',
        style: TextStyle(fontSize: 11, color: muted),
      ),
    for (final entry in entries) _entry(entry),
  ];
  Widget _detailLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Text(
      formatGameNumbers(label),
      style: const TextStyle(fontSize: 10, color: gold, letterSpacing: .6),
    ),
  );
  Widget _entry(FinanceEntry e) {
    final label =
        e.amount != 0
            ? _signed(e.amount)
            : e.debtChange > 0
            ? (e.requiredAmount > 0 ? 'Chưa trả' : 'Nợ tăng')
            : e.debtChange < 0
            ? 'Nợ giảm'
            : '0';
    final payment =
        e.requiredAmount > 0
            ? '\nCần trả ${e.requiredAmount} · đã chi ${-e.amount} · chưa trả ${e.requiredAmount + e.amount}.'
            : '';
    final debt =
        e.debtChange == 0
            ? ''
            : '\nNợ ${e.debtChange > 0 ? '+' : ''}${e.debtChange}.';
    return _line(
      e.title,
      label,
      widget.state.calendarText(
        '${e.detail}$payment$debt\nNgân khố sau khoản này: ${e.balanceAfter}; nợ: ${e.debtAfter}.',
      ),
      warning: e.debtChange > 0,
    );
  }

  Widget _line(
    String title,
    String amount,
    String detail, {
    bool warning = false,
  }) => Padding(
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
              child: Text(
                formatGameNumbers(amount),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: warning ? terracotta : forest,
                ),
              ),
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
