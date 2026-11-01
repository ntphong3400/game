import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/models/number_format.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/outcome_panel.dart';

Future<(GameController, MemoryGameStore)> numberFixture() async {
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'An',
    runId: 'numbers',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  await store.update((a) {
    final s = a.active!;
    s.treasury = 1234567;
    s.grain = 4321000;
    s.journal.insert(
      0,
      Chronicle(
        s.week,
        'Đối chiếu ngân khố',
        'Chi 4500 lượng vàng; nhận 1000000 tạ; quân +12500.',
        'neutral',
      ),
    );
    s.financialWeeks.clear();
    s.financialWeeks.add(
      FinanceWeek(
        week: s.week,
        openingBalance: 1239067,
        openingDebt: 0,
        closingBalance: 1234567,
        closingDebt: 0,
        entries: [
          FinanceEntry(
            title: 'Mua lương',
            detail: 'Chi 4500 lượng vàng, nhận 200000 tạ.',
            category: 'action',
            amount: -4500,
            requiredAmount: 4500,
            debtChange: 0,
            balanceAfter: 1234567,
            debtAfter: 0,
          ),
        ],
      ),
    );
    s.outcomes.add(
      const OutcomeReport(
        id: 'numbers-report',
        week: 1,
        title: 'Hoàn tất vận lương',
        status: 'success',
        detail: 'Chi 4500 lượng vàng; nhận 1000000 tạ.',
        changes: {'Ngân khố': -4500, 'Lương thực': 1000000},
      ),
    );
    a.scores.add(
      ScoreEntry('old-score', 'Người đi trước', 1234567, seasonal: true),
    );
  });
  final controller = GameController(gateway);
  await controller.load();
  return (controller, store);
}

void expectFormattedText(WidgetTester tester) {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    if (text.data != null) {
      expect(
        text.data,
        formatGameNumbers(text.data!),
        reason: 'Unformatted display: ${text.data}',
      );
    }
  }
}

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'all resource screens group large values without changing saved state at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final (controller, store) = await numberFixture();
        addTearDown(controller.dispose);
        final before = (await store.read()).toJson();
        for (final route in [
          'citadel',
          'capital',
          'court',
          'treasury',
          'population',
          'military',
          'kingdom',
          'people',
          'harem',
          'health',
          'journal',
          'scores',
          'local-granary',
          'local-village',
          'frontier-north-camp',
          'frontier-west-gate',
          'country-south-palace',
        ]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            GameApp(controller: controller, initialRoute: route),
          );
          await tester.pumpAndSettle();
          expectFormattedText(tester);
          if (![
            'population',
            'journal',
            'scores',
            'local-village',
          ].contains(route)) {
            expect(
              find.textContaining('1.234.567'),
              findsWidgets,
              reason: route,
            );
          }
          expect(tester.takeException(), isNull, reason: route);
        }
        expect((await store.read()).toJson(), before);
        expect(controller.state!.treasury, 1234567);
        expect(controller.state!.grain, 4321000);
      },
    );
  }

  testWidgets(
    'saved report detail and signed resource deltas both use separators',
    (tester) async {
      const report = OutcomeReport(
        id: 'receipt',
        week: 1,
        title: 'Vận lương',
        status: 'success',
        detail: 'Chi 4500 lượng vàng; nhận 1000000 tạ.',
        changes: {'Ngân khố': -4500, 'Lương thực': 1000000},
      );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OutcomeCard(report: report))),
      );
      expect(find.textContaining('4.500 lượng vàng'), findsOneWidget);
      expect(find.textContaining('1.000.000 tạ'), findsOneWidget);
      expect(find.textContaining('−4.500'), findsOneWidget);
      expect(find.textContaining('+1.000.000'), findsOneWidget);
      expect(report.changes['Lương thực'], 1000000);
      expect(report.detail, contains('1000000'));
    },
  );
}
