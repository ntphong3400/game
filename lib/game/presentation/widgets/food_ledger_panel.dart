import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import '../../logic/food_ledger_rules.dart';
import '../../logic/population_rules.dart';
import 'imperial_theme.dart';
import 'resource_ledger_panel.dart';

class FoodLedgerPanel extends StatelessWidget {
  const FoodLedgerPanel({super.key, required this.state, this.flat = false});
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
  Widget entry(FoodEntry e) {
    final extra = [
      if (e.overflow > 0)
        'Không nhập được do đầy kho: ${whole(e.overflow)} ${foodUnit(s)}; không tính là xuất kho.',
      if (e.shortfall > 0)
        'Cần xuất ${whole(-e.requested)} · thực xuất ${whole(-e.amount)} · còn thiếu ${whole(e.shortfall)} ${foodUnit(s)}.',
      if (e.prepaid > 0)
        'Đã cấp trước ${whole(e.prepaid)} ${foodUnit(s)} khẩu phần. Không phải nguồn nhập kho.',
      if (e.applied > 0)
        'Đã đối trừ ${whole(e.applied)} trong khẩu phần ${whole(e.rationNeed)} ${foodUnit(s)}. Phần còn lại mới trừ kho.',
      if (e.expired > 0)
        'Kết thúc ${whole(e.expired)} ${foodUnit(s)} đối trừ chưa dùng, không chuyển sang mùa sau.',
    ];
    return ResourceLedgerLine(
      e.title,
      signed(e.amount),
      '${e.detail}\n${extra.join('\n')}\nTồn sau khoản này: ${whole(e.balanceAfter)} ${foodUnit(s)}.',
      warning: e.shortfall > 0 || e.overflow > 0,
    );
  }

  List<Widget> actualItems(List<FoodEntry> entries) => [
    if (entries.isEmpty) text('Chưa có khoản phát sinh trong nhóm này.'),
    for (final e in entries) entry(e),
  ];
  @override
  Widget build(BuildContext context) => ResourceLedgerPanel(
    prefix: 'food',
    title: 'Sổ kho lương',
    unit: foodUnit(s),
    currentTurn: s.week,
    periodName: s.periodName,
    periods: {for (final w in s.foodWeeks) w.week: w.closed},
    date: s.date,
    flat: flat,
    dataFor: dataFor,
    itemLabel: 'Khoản lương thực',
    netLabel: 'Lương tăng / giảm',
    balanceLabel: 'Lương còn lại',
    emptyEntries: 'Kỳ này chưa có khoản lương thực phát sinh.',
  );

  ResourceLedgerData dataFor(int turn) {
    final report = s.foodWeeks.where((w) => w.week == turn).firstOrNull;
    final current = turn == s.week;
    final forecast =
        current && !s.ended && report?.closed != true && s.population != null
            ? FoodProjection(s)
            : null;
    final entries = report?.entries ?? <FoodEntry>[];
    final income = entries.where((e) => e.amount > 0).toList();
    final other =
        entries
            .where(
              (e) =>
                  e.amount < 0 &&
                  ![
                    'consumption',
                    'disaster',
                    'adjustment',
                  ].contains(e.category),
            )
            .toList();
    final consumption =
        entries.where((e) => e.category == 'consumption').toList();
    final loss =
        entries
            .where(
              (e) =>
                  e.amount < 0 &&
                  ['disaster', 'adjustment'].contains(e.category),
            )
            .toList();
    int? sum(List<FoodEntry> list) =>
        report == null ? null : list.fold<int>(0, (n, e) => n + e.amount);
    return ResourceLedgerData(
      hasRecord: report != null,
      closed: report?.closed == true,
      partial: report?.partial == true,
      opening: report?.openingBalance,
      balance: report?.closingBalance ?? (current ? s.grain : null),
      projectedBalance: forecast?.closingBalance,
      income: report?.income,
      expense: report?.expense,
      projectedNet: forecast?.net,
      notices: [
        if (report == null) ...[
          const SizedBox(height: 12),
          text(
            'Chưa có sổ lương chi tiết cho kỳ này. Sổ bắt đầu từ hành động tiếp theo; các khoản quá khứ không được dựng lại.',
          ),
        ],
        if (report?.partial == true) ...[
          const SizedBox(height: 12),
          text(
            'Kỳ này chỉ ghi từ lúc bắt đầu theo dõi hoặc có chênh lệch dữ liệu ngoài sổ. Phần trước đó không có lịch sử chi tiết.',
            color: terracotta,
          ),
        ],
      ],
      rows: [
        ResourceLedgerRow(
          'income',
          'Lương nhập / tăng kho',
          sum(income),
          forecast?.harvestReceived,
          actualKey: 'food-total-income',
          details: [
            ...actualItems(income),
            if (forecast != null)
              ResourceLedgerLine(
                'Thu hoạch dự kiến',
                signed(forecast.harvestReceived),
                forecast.harvestDue
                    ? 'Tổng vụ gặt tạm tính ${whole(forecast.grossHarvest)} tạ; có thể dao động ${whole(forecast.lowHarvest)}–${whole(forecast.highHarvest)} theo thời tiết. Chỉ tính phần còn chỗ trong kho.'
                    : 'Mùa này không có thu hoạch tự động.',
              ),
          ],
        ),
        ResourceLedgerRow(
          'other',
          'Xuất công việc & phát sinh',
          sum(other),
          null,
          actualKey: 'food-task-expense',
          details: actualItems(other),
        ),
        ResourceLedgerRow(
          'regular',
          'Tiêu dùng dân cư & quân đội',
          sum(consumption),
          forecast == null ? null : -forecast.consumption,
          actualKey: 'food-consumption',
          details: [
            ...actualItems(consumption),
            if (forecast != null)
              ResourceLedgerLine(
                'Khẩu phần còn phải cấp',
                signed(-forecast.consumption),
                'Nhu cầu ${whole(forecast.rationNeed)} − đã cấp trước ${whole(forecast.prepaid)} = còn phải cấp ${whole(forecast.remainingNeed)} tạ. Thiếu dự kiến ${whole(forecast.shortfall)} tạ.',
                warning: forecast.shortfall > 0,
              ),
          ],
        ),
        ResourceLedgerRow(
          'loss',
          'Thiệt hại & điều chỉnh giảm',
          sum(loss),
          null,
          actualKey: 'food-losses',
          details: actualItems(loss),
        ),
      ],
      beforeEntries: [
        const SizedBox(height: 14),
        text(
          'Sức chứa ${whole(report?.capacity ?? foodCapacity(s))} ${foodUnit(s)}${current && s.population != null ? ' · Dự trữ ${foodDays(s)} ngày' : ''}.',
          key: 'food-capacity',
        ),
        const Divider(height: 22),
        const Text(
          'Đối chiếu khẩu phần — không phải nhập kho',
          style: TextStyle(fontFamily: 'Lora', fontSize: 14),
        ),
        if (report != null) ...[
          text(
            'Đã cấp trước: ${whole(report.prepaid)} ${foodUnit(s)}${report.openingPrepaid > 0 ? ' (gồm ${whole(report.openingPrepaid)} đã có lúc bắt đầu ghi)' : ''}.',
            key: 'food-prepaid',
          ),
          text(
            'Đã đối trừ vào tiêu dùng: ${whole(report.applied)} ${foodUnit(s)}.',
            key: 'food-prepaid-applied',
          ),
          text(
            'Còn chờ đối trừ: ${whole(report.outstanding)} · kết thúc chưa dùng: ${whole(report.expired)} ${foodUnit(s)}.',
            key: 'food-prepaid-outstanding',
          ),
          text(
            'Không nhập được do đầy kho: ${whole(report.overflow)} ${foodUnit(s)}; không tính vào nhập hoặc xuất thực tế.',
            key: 'food-overflow',
          ),
          if (report.shortfall > 0)
            text(
              'Thiếu thực tế khi xuất: ${whole(report.shortfall)} ${foodUnit(s)}.',
              key: 'food-shortfall',
              color: terracotta,
            ),
          const SizedBox(height: 8),
          text(
            '${report.partial ? 'Lúc bắt đầu ghi' : 'Đầu ${s.periodName}'} ${report.openingBalance} + nhập/tăng ${report.income} − xuất/giảm ${report.expense} = ${report.closed ? 'cuối ${s.periodName}' : 'đang có'} ${report.closingBalance}.',
            key: 'food-reconciliation',
          ),
        ],
        if (forecast != null) ...[
          const SizedBox(height: 8),
          text(
            'Dự kiến đối trừ ${whole(forecast.prepaid)} tạ; phần còn phải cấp ${whole(forecast.remainingNeed)} tạ.',
            key: 'food-prepaid-estimate',
          ),
          if (forecast.overflow > 0)
            text(
              'Dự kiến ${whole(forecast.overflow)} tạ vượt kho khi thu hoạch, trước tiêu dùng mùa Thu.',
              key: 'food-overflow-estimate',
              color: terracotta,
            ),
          if (forecast.shortfall > 0)
            text(
              'Dự kiến thiếu ${whole(forecast.shortfall)} tạ khẩu phần; cần bổ sung kho trước khi khép mùa.',
              key: 'food-shortfall-estimate',
              color: terracotta,
            ),
        ],
      ],
      entries: report == null ? null : entries.map(entry).toList(),
      afterEntries: [
        if (forecast != null) ...[
          const SizedBox(height: 10),
          text(
            '“Sắp tới” là dự toán cuối ${s.date(s.week)} theo dữ liệu hiện tại, thời tiết 100%, có hao mòn đê và mẫu lao động mùa này. Thu hoạch nhập trước tiêu dùng; chưa gồm công việc, tấu chương, sự kiện đến hạn hoặc thay đổi dân cư. Xem sổ không phát sinh giao dịch.',
            key: 'food-projection',
          ),
        ],
      ],
    );
  }
}
