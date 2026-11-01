import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/presentation/widgets/imperial_dialog.dart';

void main() {
  for (final size in [
    const Size(1440, 1000),
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 568),
  ]) {
    for (final chooser in [false, true]) {
      testWidgets(
        '${chooser ? 'chooser' : 'confirmation'} keeps controls visible while scrolling at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          String? result;
          await tester.pumpWidget(
            MaterialApp(
              builder:
                  (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(1.3)),
                    child: child!,
                  ),
              home: Builder(
                builder:
                    (context) => Scaffold(
                      body: TextButton(
                        onPressed: () async {
                          result = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final rows = [
                                for (var i = 0; i < 20; i++)
                                  ImperialDialogOption(
                                    onPressed:
                                        i == 0
                                            ? null
                                            : () =>
                                                Navigator.pop(context, '$i'),
                                    child: Text(
                                      'Triều thần $i · Năng lực 82 · An ninh\n'
                                      'Đúng chuyên môn · ước tính thành công 95%.',
                                    ),
                                  ),
                              ];
                              return chooser
                                  ? ImperialSimpleDialog(
                                    title: const Text('Chọn người phụ trách'),
                                    children: rows,
                                  )
                                  : ImperialAlertDialog(
                                    title: const Text('Xác nhận giao việc'),
                                    content: SizedBox(
                                      width: 520,
                                      child: SingleChildScrollView(
                                        child: Column(children: rows),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      FilledButton(
                                        onPressed:
                                            () => Navigator.pop(context, 'ok'),
                                        child: const Text('Ban lệnh'),
                                      ),
                                    ],
                                  );
                            },
                          );
                        },
                        child: const Text('Mở'),
                      ),
                    ),
              ),
            ),
          );
          await tester.tap(find.text('Mở'));
          await tester.pumpAndSettle();
          final header = find.byKey(const ValueKey('imperial-dialog-header'));
          final footer = find.byKey(const ValueKey('imperial-dialog-actions'));
          final close = find.byKey(const ValueKey('close-imperial-dialog'));
          final initialHeader = tester.getRect(header);
          final initialFooter = tester.getRect(footer);
          expect(initialHeader.top, greaterThanOrEqualTo(0));
          expect(initialFooter.bottom, lessThanOrEqualTo(size.height));
          expect(tester.takeException(), isNull);

          // Disabled choices cannot close the dialog or produce a result.
          await tester.tap(find.textContaining('Triều thần 0 ·'));
          await tester.pumpAndSettle();
          expect(result, isNull);
          expect(header, findsOneWidget);

          await tester.ensureVisible(find.textContaining('Triều thần 19 ·'));
          await tester.pumpAndSettle();
          expect(tester.getRect(header), initialHeader);
          expect(tester.getRect(footer), initialFooter);
          expect(close.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (chooser) {
            await tester.tap(close);
            await tester.pumpAndSettle();
            expect(result, isNull);
          } else {
            await tester.tap(find.text('Ban lệnh'));
            await tester.pumpAndSettle();
            expect(result, 'ok');
          }
          expect(header, findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
