import 'dart:math' as math;
import '../models/game_state.dart';
import 'reign_rules.dart';
import 'harem_rules.dart';
import 'population_rules.dart';
import 'currency_rules.dart';
import 'warfare_rules.dart';
import 'palace_rules.dart';
import 'development_rules.dart';
import 'court_rules.dart';

class BudgetItem {
  const BudgetItem(
    this.title,
    this.detail,
    this.amount, {
    this.separateArrears = false,
  });
  final bool separateArrears;
  final String title, detail;
  final int amount;
}

const taxLabels = ['nhẹ', 'vừa', 'cao'];
int annualTaxGross(GameState s) => money(
  s,
  (4 * (s.tax * 45 + s.people ~/ 3) + economyAnnualBonus(s)) *
      annualEconomicLaborFactor(s),
);
int annualTaxCredit(GameState s, {int? year}) =>
    s.taxCreditYear == (year ?? s.year) ? s.taxCredit : 0;
int annualTaxRevenue(GameState s, {int? year}) {
  final base = math.max(0, annualTaxGross(s) - annualTaxCredit(s, year: year));
  final seasons = courtTaxSeasonCount(s, year: year);
  return base + (base * seasons.abs() * .0075).floor() * seasons.sign;
}

int annualTaxSupportChange(GameState s) =>
    (s.tax == 0
        ? 4
        : s.tax == 2
        ? -8
        : 0) -
    (s.taxCreditYear == s.year ? s.taxSupportCredit : 0);
String taxPolicyHint(GameState s) =>
    'Mức đã chọn: ${taxLabels[s.tax]}; chốt khi khép ${s.date(s.nextTaxTurn)}. '
    'Trước thời điểm đó có thể đổi mức thuế; đổi vào mùa Đông sẽ áp dụng cho vụ Thu năm sau. '
    '${s.lastTaxYear == 0 ? 'Chưa thu thuế vụ Thu lần nào.' : 'Đã thu năm ${s.lastTaxYear}: mức ${taxLabels[s.lastTaxRate]}, ${s.lastTaxRevenue} ${moneyUnit(s)}.'}';

List<BudgetItem> budgetIncome(GameState s) => [
  for (final item in tributeReceipts(s))
    BudgetItem(
      'Triều cống từ ${item.country.name}',
      'Hòa ước: kỳ ${item.country.treaty!.paidInstallments + 1}/${item.country.treaty!.installments}.',
      item.amount,
    ),
  BudgetItem(
    'Thu cơ bản của vương quốc',
    s.population == null
        ? '${s.seasonal ? 'Nguồn thu phi thuế' : 'Nguồn thu nền cố định'}: ${money(s, s.seasonal ? 80 : 13)} ${moneyUnit(s)} mỗi ${s.periodName}.'
        : '${money(s, 80)} ${moneyUnit(s)} tham chiếu × hệ số lao động và ưu tiên sản xuất ${(economicLaborFactor(s) * 100).toStringAsFixed(2)}%.',
    s.population == null
        ? (s.seasonal ? 80 : 13)
        : money(s, 80 * economicLaborFactor(s)),
  ),
  for (final contribution in HaremBenefits(s).contributions.where(
    (c) => c.passive.benefit == HaremBenefit.treasury && c.amount > 0,
  ))
    BudgetItem(
      'Gia sản hậu cung: ${contribution.person.name}',
      '${authoredMoneyText(s, contribution.description)}. Hỗ trợ từ ${contribution.person.faction}; '
          'cần thiện cảm >70 và năng lực >60. Tổng tối đa ${money(s, 20)} ${moneyUnit(s)}/mùa, chưa trừ chi hậu cung.',
      money(s, contribution.amount),
    ),
  if (s.autumnTaxDue)
    BudgetItem(
      'Thuế vụ Thu năm ${s.year} · mức ${taxLabels[s.tax]}',
      'Thu một lần sau vụ mùa: ${s.tax} × ${money(s, 45)} × 4 mùa = ${money(s, s.tax * 180)}; '
          'thu theo lòng dân (${s.people} ÷ 3, lấy phần nguyên) × ${moneyScale(s)} × 4 = ${money(s, (s.people ~/ 3) * 4)}. '
          'Kinh tế cấp ${s.economyLevel}: +${money(s, economyAnnualBonus(s))} ${moneyUnit(s)}/năm. '
          '${s.population == null ? '' : 'Hệ số lao động và phân bổ sản xuất cả vụ ${(annualEconomicLaborFactor(s) * 100).toStringAsFixed(2)}%. '}'
          '${annualTaxCredit(s) > 0 ? 'Khấu trừ ${annualTaxCredit(s)} đã thu trong năm trước cập nhật. ' : ''}'
          '${s.hasCourtSystem ? 'Điều chỉnh Hộ bộ: ${(courtTaxSeasonCount(s) * .75).toStringAsFixed(2).replaceAll('.', ',')}%; tính cả mùa đủ điều kiện và mùa bỏ trống. ' : ''}'
          'Thực thu ${annualTaxRevenue(s)}; lòng dân ${annualTaxSupportChange(s) >= 0 ? '+' : ''}${annualTaxSupportChange(s)} khi chốt thuế.',
      annualTaxRevenue(s),
    ),
  if (!s.seasonal)
    BudgetItem(
      'Thuế ${['nhẹ', 'vừa', 'cao'][s.tax]}',
      'Mức thuế ${s.tax} × ${s.seasonal ? 45 : 8} = ${s.tax * (s.seasonal ? 45 : 8)}. Thuế cao làm giảm lòng dân mỗi ${s.periodName}.',
      s.tax * (s.seasonal ? 45 : 8),
    ),
  if (!s.seasonal)
    BudgetItem(
      'Thu thêm theo lòng dân',
      'Lòng dân ${s.people} ÷ ${s.seasonal ? 3 : 12}, lấy phần nguyên = ${s.people ~/ (s.seasonal ? 3 : 12)}. Lòng dân tốt giúp thu thuế hiệu quả hơn.',
      s.people ~/ (s.seasonal ? 3 : 12),
    ),
  for (final o in s.obligations.where(
    (o) => o.income > 0 && o.nextWeek <= s.week,
  ))
    BudgetItem(
      o.title,
      'Nguồn thu sau đại biến cố: ${o.income} ${moneyUnit(s)}/kỳ; còn ${o.remaining} kỳ gồm kỳ này.',
      o.income,
    ),
];

Map<String, BudgetItem> budgetExpenses(GameState s) {
  final consorts = s.court.where((c) => c.available && c.inHarem).length;
  final saving = s.seasonal ? palaceUpkeepSaving(s) : 0;
  return {
    for (final item in tributePayments(s))
      'tribute:${item.country.id}': BudgetItem(
        'Triều cống ${item.country.name}',
        'Nghĩa vụ hằng năm, thiếu ghi riêng trong hòa ước.',
        item.amount,
        separateArrears: true,
      ),
    'army': BudgetItem(
      'Duy trì quân đội',
      s.population == null
          ? '${money(s, s.seasonal ? 45 : 12)} ${moneyUnit(s)} nền + chiến tranh mức ${s.war} × ${s.seasonal ? 12 : 3}.'
          : '(${money(s, 45)} ${moneyUnit(s)} + chiến tranh mức ${s.war} × ${money(s, 12)}) × ${whole(s.population!.serviceSoldiers)} quân đã phục vụ trong mùa / 50.000, làm tròn lên.',
      s.population == null
          ? (s.seasonal ? 45 + s.war * 12 : 12 + s.war * 3)
          : money(s, (45 + s.war * 12) * s.population!.serviceSoldiers / 50000),
    ),
    'people': BudgetItem(
      'Dân sinh thường lệ',
      '${money(s, s.seasonal ? 20 : 5)} ${moneyUnit(s)} mỗi ${s.periodName}; mở kho cứu tế chủ động được tính riêng.',
      money(s, s.seasonal ? 20 : 5),
    ),
    if (reignStage(s) > 0)
      'realm': BudgetItem(
        'Điều hành giai đoạn ${reignStageName(s)}',
        'Gánh nặng bộ máy tăng ${money(s, reignStage(s) * (s.seasonal ? 8 : 2))} ${moneyUnit(s)} mỗi ${s.periodName}.',
        money(s, reignStage(s) * (s.seasonal ? 8 : 2)),
      ),
    for (final o in s.obligations.where(
      (o) => o.amount > 0 && o.nextWeek <= s.week,
    ))
      'obligation:${o.id}': BudgetItem(
        o.title,
        'Kỳ này ${o.amount} ${moneyUnit(s)}; còn ${o.remaining} kỳ gồm kỳ này. Phần chưa trả ghi vào nợ chi trả.',
        o.amount,
      ),
    'court': BudgetItem(
      'Triều đình và hậu cung',
      '${money(s, s.seasonal ? 30 : 8)} ${moneyUnit(s)} nền + $consorts phi tần/hoàng hậu × ${money(s, s.seasonal ? 6 : 2)}.'
          '${saving > 0 ? ' Cung vụ tiết kiệm ${money(s, saving)} ${moneyUnit(s)} kỳ này.' : ''}',
      money(s, s.seasonal ? 30 + consorts * 6 - saving : 8 + consorts * 2),
    ),
  };
}

List<String> budgetPaymentOrder(GameState s) => [
  s.priority,
  s.priority == 'army' ? 'people' : 'army',
  'court',
  if (reignStage(s) > 0) 'realm',
  for (final o in s.obligations.where(
    (o) => o.amount > 0 && o.nextWeek <= s.week,
  ))
    'obligation:${o.id}',
  for (final item in tributePayments(s)) 'tribute:${item.country.id}',
];

int debtPayment(int debt, int balance, {int scale = 1}) =>
    debt > 0 && balance > 20 * scale
        ? math.min(debt, math.min(10 * scale, balance - 20 * scale))
        : 0;

class BudgetProjection {
  BudgetProjection(GameState s) {
    income = budgetIncome(s);
    final costs = budgetExpenses(s);
    expenses = [for (final key in budgetPaymentOrder(s)) costs[key]!];
    var cash = s.treasury + totalIncome;
    var debt = s.debt;
    for (final e in expenses) {
      final paid = math.min(cash, e.amount);
      payable.add(paid);
      cash -= paid;
      if (!e.separateArrears) debt += e.amount - paid;
    }
    repayment = debtPayment(debt, cash, scale: moneyScale(s));
    closingBalance = cash - repayment;
    closingDebt = debt - repayment;
  }
  late final List<BudgetItem> income, expenses;
  final List<int> payable = [];
  late final int repayment, closingBalance, closingDebt;
  int get totalIncome => income.fold(0, (sum, e) => sum + e.amount);
  int get requiredExpense => expenses.fold(0, (sum, e) => sum + e.amount);
  int get paidExpense => payable.fold(0, (sum, n) => sum + n) + repayment;
  int get shortfall => requiredExpense - payable.fold(0, (sum, n) => sum + n);
}
