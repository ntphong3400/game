import 'currency_format.dart';
import 'dart:convert';

/// Upgrade the quantitative 0.21 save once. Legacy 0-100 military saves and
/// explicit historical fixtures retain their old denomination.
Map<String, dynamic> migrateGoldSave(Map<String, dynamic> source) {
  if (source['population'] == null || source.containsKey('goldStandard')) {
    return source;
  }
  final j = Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
  void scale(Map data, List<String> fields) {
    for (final key in fields) {
      if (data[key] is num) data[key] = (data[key] as num).toInt() * 100;
    }
  }

  scale(j, [
    'treasury',
    'debt',
    'lastIncome',
    'lastExpense',
    'lastTaxRevenue',
    'taxCredit',
  ]);
  if (j['deltas'] is Map) scale(j['deltas'], ['treasury', 'debt']);
  for (final w in j['financialWeeks'] as List? ?? []) {
    scale(w, [
      'openingBalance',
      'openingDebt',
      'closingBalance',
      'closingDebt',
    ]);
    for (final e in w['entries'] as List? ?? []) {
      scale(e, [
        'amount',
        'requiredAmount',
        'debtChange',
        'balanceAfter',
        'debtAfter',
      ]);
    }
  }
  for (final o in j['obligations'] as List? ?? []) {
    scale(o, ['amount', 'income']);
  }
  for (final a in j['chains'] as List? ?? []) {
    scale(a, ['investedValue', 'cashSpent']);
    a['currencyScale'] = 100;
    if (a['resourceCosts'] is Map) {
      scale(a['resourceCosts'], ['treasury', 'debt']);
      final costs = a['resourceCosts'] as Map;
      if (costs.containsKey('treasury')) {
        costs['gold'] = costs.remove('treasury');
      }
      if (costs.containsKey('debt')) costs['goldDebt'] = costs.remove('debt');
    }
  }
  for (final r in j['outcomes'] as List? ?? []) {
    if (r['changes'] is Map) scale(r['changes'], ['Ngân khố', 'Nợ chi trả']);
    if (r['detail'] is String) {
      r['detail'] = convertAuthoredMoneyText(r['detail']);
    }
  }
  for (final entry in j['journal'] as List? ?? []) {
    if (entry['text'] is String) {
      entry['text'] = convertAuthoredMoneyText(entry['text']);
    }
  }
  for (final w in j['financialWeeks'] as List? ?? []) {
    for (final e in w['entries'] as List? ?? []) {
      if (e['detail'] is String) {
        e['detail'] = convertAuthoredMoneyText(e['detail']);
      }
    }
  }
  for (final pending in j['pending'] as List? ?? []) {
    if (pending['detail'] is String) {
      pending['detail'] = convertAuthoredMoneyText(pending['detail']);
    }
  }
  j['goldStandard'] = true;
  j['goldMigrationVersion'] = 1;
  return j;
}
