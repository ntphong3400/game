import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/presentation/widgets/equal_height_grid.dart';

void main() {
  testWidgets('all rows follow the tallest card and shrink when it changes', (
    tester,
  ) async {
    Future<void> show(List<double> heights) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: EqualHeightGrid(
                key: const ValueKey('grid'),
                columns: 2,
                spacing: 10,
                children: [
                  for (var i = 0; i < heights.length; i++)
                    SizedBox(
                      key: ValueKey('card-$i'),
                      height: heights[i],
                      child: TextButton(
                        onPressed: () {},
                        child: Text('Card $i'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await show([60, 80, 140]);
    for (var i = 0; i < 3; i++) {
      expect(
        tester.getSize(find.byKey(ValueKey('card-$i'))),
        const Size(195, 140),
      );
    }
    expect(tester.getSize(find.byKey(const ValueKey('grid'))).height, 290);
    expect(tester.getTopLeft(find.byKey(const ValueKey('card-2'))).dy, 150);
    await tester.tap(find.text('Card 2'));
    expect(tester.takeException(), isNull);

    await show([60, 80, 40]);
    for (var i = 0; i < 3; i++) {
      expect(tester.getSize(find.byKey(ValueKey('card-$i'))).height, 80);
    }
    await show([60]);
    expect(tester.getSize(find.byKey(const ValueKey('card-0'))).height, 60);
    await show([]);
    expect(tester.getSize(find.byKey(const ValueKey('grid'))).height, 0);
    expect(tester.takeException(), isNull);
  });
}
