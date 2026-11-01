import 'dart:convert';
import 'dart:io';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/models/portraits.dart';

void main() {
  final court = initialCourt();
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert([
      for (final id in [...haremPortraitIds, ...officialPortraitIds])
        () {
          final person =
              court.where((c) => c.resolvedPortraitId == id).firstOrNull;
          final female = id.startsWith('harem');
          final age = person?.age ?? (female ? 25 : 40);
          return {
            'id': id,
            'name': person?.name,
            'role': person?.displayRole,
            'age': age,
            'referenceCell': portraitAgeFor(age).index,
            'female': female,
          };
        }(),
    ]),
  );
}
