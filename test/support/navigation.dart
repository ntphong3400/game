import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/game_routes.dart';

/// Business-flow tests open sections through their public URLs. Map entrances,
/// contextual HUD links and back buttons have separate navigation UI tests.
Future<void> openSection(WidgetTester tester, String section) async {
  const labels = {
    'Giang Sơn': 'citadel',
    'Triều chính': 'court',
    'Quốc sự': 'kingdom',
    'Ngân khố': 'treasury',
    'Triều thần': 'people',
    'Hậu cung': 'harem',
    'Long thể': 'health',
    'Sử ký': 'journal',
    'Bảng xếp hạng': 'scores',
  };
  GoRouter.of(
    tester.element(find.byType(GameShell)),
  ).go(GameLocation.pathFor(labels[section] ?? section));
  await tester.pumpAndSettle();
}
