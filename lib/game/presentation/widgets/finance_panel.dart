import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import '../../logic/finance_rules.dart';
import '../../logic/development_rules.dart';
import 'imperial_theme.dart';
import 'resource_ledger_panel.dart';

/// Money-specific data and notes; all ledger layout is shared with Kho Lương.
class FinancePanel extends StatelessWidget {
  const FinancePanel({super.key, required this.state, this.flat = false});
  final GameState state;
  final bool flat;
  GameState get s => state;
  static String signed(int n) =>
      n > 0
          ? '+$n'
          : n < 0
          ? '−${-n}'
          : '0';
  Widget text(String value, {String? key, Color color = muted}) => Text(
    formatGameNumbers(value),
    key: key == null ? null : ValueKey(key),
    style: TextStyle(fontSize: 11, color: color),
  );
  Widget heading(String label) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: gold, letterSpacing: .6),
    ),
  );
  Widget line(
    String title,
    String amount,
    String detail, {
    bool warning = false,
  }) => ResourceLedgerLine(title, amount, detail, warning: warning);
  Widget entry(FinanceEntry e) {
    final label =
        e.amount != 0
            ? signed(e.amount)
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
    return line(
      e.title,
      label,
      s.calendarText(
        '${e.detail}$payment$debt\nNgân khố sau khoản này: ${e.balanceAfter}; nợ: ${e.debtAfter}.',
      ),
      warning: e.debtChange > 0,
    );
  }

  List<Widget> actualItems(List<FinanceEntry> entries) => [
    heading('ĐÃ GHI SỔ'),
    if (entries.isEmpty) text('Chưa ghi nhận khoản tiền nào trong nhóm này.'),
    for (final e in entries) entry(e),
  ];
  @override
  Widget build(BuildContext context) => ResourceLedgerPanel(
    prefix: 'finance',
    title: 'Sổ ngân khố',
    unit: moneyUnit(s),
    periodName: s.periodName,
    currentTurn: s.week,
    periods: {for (final w in s.financialWeeks) w.week: w.closed},
    date: s.date,
    dataFor: dataFor,
    flat: flat,
    itemLabel: 'Khoản tiền',
    netLabel: 'Tiền tăng / giảm',
    balanceLabel: 'Tiền còn lại',
    emptyEntries: 'Kỳ này chưa có khoản tiền nào phát sinh.',
  );

  ResourceLedgerData dataFor(int week) {
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
    int? sum(List<FinanceEntry> list) =>
        report == null ? null : list.fold<int>(0, (n, e) => n + e.amount);
    return ResourceLedgerData(
      hasRecord: report != null,
      closed: report?.closed == true,
      partial: report?.partial == true,
      opening: report?.openingBalance,
      balance: report?.closingBalance ?? (current ? s.treasury : null),
      projectedBalance: forecast?.closingBalance,
      income: report?.income,
      expense: report?.expense,
      projectedNet:
          forecast == null ? null : forecast.totalIncome - forecast.paidExpense,
      notices: [
        if (report == null) ...[
          const SizedBox(height: 12),
          text(
            'Chưa có sổ chi tiết cho kỳ này. Các khoản sẽ được ghi từ hành động tiếp theo; thu/chi trước đó không được dựng lại.',
          ),
          if (s.completedWeeks > 0 && s.financialWeeks.isEmpty)
            text(
              'Số tổng cũ của kỳ thường lệ gần nhất: thu ${s.lastIncome}, thực chi ${s.lastExpense}; chưa gồm nhiệm vụ và sự kiện.',
            ),
        ],
        if (report?.partial == true) ...[
          const SizedBox(height: 12),
          text(
            '${s.periodTitle} này chỉ ghi từ lúc cập nhật game. Các khoản trước đó chưa có dữ liệu chi tiết.',
            color: terracotta,
          ),
        ],
      ],
      rows: [
        ResourceLedgerRow(
          'income',
          'Tiền thu vào',
          sum(income),
          forecast?.totalIncome,
          actualKey: 'finance-total-income',
          details: [
            ...actualItems(income),
            if (forecast != null) ...[
              heading('SẮP TỚI · THU THƯỜNG LỆ'),
              for (final item in forecast.income)
                line(item.title, '+${item.amount}', item.detail),
            ],
          ],
        ),
        ResourceLedgerRow(
          'other',
          'Chi công việc & phát sinh',
          sum(other),
          null,
          details: [
            ...actualItems(other),
            text(
              'Gồm công việc, quyết định, sự kiện và các khoản ngoài chi thường lệ. Phần sắp tới chưa dự tính các khoản này.',
            ),
          ],
        ),
        ResourceLedgerRow(
          'regular',
          'Chi thường lệ',
          sum(regular),
          forecast == null
              ? null
              : -(forecast.paidExpense - forecast.repayment),
          details: [
            ...actualItems(regular),
            if (forecast != null) ...[
              heading('SẮP TỚI · THEO THỨ TỰ ƯU TIÊN'),
              text(
                'Cần trả ${forecast.requiredExpense} · trả được ${forecast.paidExpense - forecast.repayment} · thiếu ${forecast.shortfall}.',
                color: ink,
              ),
              for (var i = 0; i < forecast.expenses.length; i++)
                line(
                  forecast.expenses[i].title,
                  '−${forecast.payable[i]}',
                  '${forecast.expenses[i].detail} Cần trả ${forecast.expenses[i].amount} · trả được ${forecast.payable[i]} · còn thiếu ${forecast.expenses[i].amount - forecast.payable[i]}.',
                  warning: forecast.payable[i] < forecast.expenses[i].amount,
                ),
            ],
          ],
        ),
        ResourceLedgerRow(
          'repayment',
          'Trả nợ',
          sum(repayments),
          forecast == null ? null : -forecast.repayment,
          details: [
            ...actualItems(repayments),
            if (forecast != null)
              text(
                'Dự kiến trả ${forecast.repayment}. Sau chi thường lệ, trả tối đa ${money(s, 10)} ${moneyUnit(s)} nợ/${s.periodName} và giữ lại ít nhất ${money(s, 20)} ${moneyUnit(s)} trong ngân khố.',
              ),
          ],
        ),
      ],
      beforeEntries: [
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
            child: text(
              s.warfare == null
                  ? 'Thiếu ${forecast.shortfall} ${moneyUnit(s)} chi thường lệ sẽ thành nợ và gây mất chỉ số ở khoản chưa trả đủ.'
                  : 'Thiếu ${forecast.shortfall} ${moneyUnit(s)} ở các khoản đến hạn. Chi thường lệ thiếu ghi vào nợ chi trả; triều cống thiếu ghi riêng trong hòa ước tại Quân sự.',
              key: 'finance-shortfall',
              color: terracotta,
            ),
          ),
        if (report != null) ...[
          const SizedBox(height: 8),
          text(
            'Nợ phát sinh: +${report.newDebt} · Nợ giảm: −${report.debtReduction}',
          ),
          const SizedBox(height: 8),
          text(
            '${report.partial ? 'Lúc bắt đầu ghi' : 'Đầu ${s.periodName}'} ${report.openingBalance} + thu ${report.income} − chi ${report.expense} = ${report.closed ? 'cuối ${s.periodName}' : 'đang có'} ${report.closingBalance}.',
            key: 'finance-reconciliation',
          ),
          text(
            'Nợ ${report.openingDebt} + phát sinh ${report.newDebt} − giảm ${report.debtReduction} = ${report.closingDebt}.',
          ),
        ],
      ],
      entries: report == null ? null : entries.map(entry).toList(),
      afterEntries: [
        if (forecast != null) ...[
          const SizedBox(height: 10),
          text(
            '“Sắp tới” chỉ tính thu chi thường lệ cuối ${s.date(s.week)}; chưa ghi vào ngân khố. Công việc, tấu chương và sự kiện đến hạn có thể làm số thực tế thay đổi. Chi bằng thóc không tính thành chi tiền.',
            key: 'finance-projection',
          ),
          if (s.seasonal) ...[
            const Divider(height: 26),
            const Text(
              'Thuế vụ Thu — kế hoạch thu năm',
              key: ValueKey('annual-tax-plan'),
              style: TextStyle(fontFamily: 'Lora', fontSize: 14),
            ),
            text(
              'Tạm tính kỳ ${s.date(s.nextTaxTurn)}: +${annualTaxRevenue(s, year: s.nextTaxYear)} ${moneyUnit(s)}, theo lòng dân hiện tại; đã gồm +${money(s, economyAnnualBonus(s))} ${moneyUnit(s)} từ kinh tế cấp ${s.economyLevel}. ${s.autumnTaxDue ? 'Khoản này có trong dự toán cuối mùa Thu.' : 'Không có thuế trong dự toán mùa này; số dự kiến chưa được cộng vào ngân khố.'}',
              key: 'annual-tax-estimate',
            ),
          ],
        ],
      ],
    );
  }
}
