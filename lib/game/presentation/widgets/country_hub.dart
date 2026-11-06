import 'package:flutter/material.dart';

import '../../logic/warfare_rules.dart';
import '../../models/game_state.dart';
import 'country_routes.dart';
import 'giang_son_page.dart';

const countryBackgroundAssets = {
  'north': 'assets/images/country-north-watercolor.webp',
  'west': 'assets/images/country-west-watercolor.webp',
  'south': 'assets/images/country-south-watercolor.webp',
};

class CountryHub extends StatelessWidget {
  const CountryHub({
    super.key,
    required this.state,
    required this.countryId,
    required this.busy,
    required this.onNavigate,
    required this.onEndTurn,
    required this.onOvertime,
  });

  final GameState state;
  final String countryId;
  final bool busy;
  final ValueChanged<String> onNavigate;
  final VoidCallback onEndTurn, onOvertime;

  @override
  Widget build(BuildContext context) {
    final section = 'country-$countryId';
    final artwork = countryBackgroundAssets[countryId]!;
    final locations = [
      (
        'palace',
        'Vương cung',
        'Bang giao · Giao hảo · Tuyên chiến',
        countryId == 'south'
            ? const Offset(.49, .27)
            : countryId == 'west'
            ? const Offset(.48, .20)
            : const Offset(.48, .25),
      ),
      (
        'embassy',
        'Sứ quán',
        'Hòa đàm · Hòa ước · Triều cống',
        const Offset(.24, .65),
      ),
      (
        'border',
        'Biên thành',
        'Binh lực đối phương · Chiến dịch · Quân báo',
        countryId == 'south'
            ? const Offset(.81, .59)
            : countryId == 'west'
            ? const Offset(.80, .51)
            : const Offset(.81, .55),
      ),
    ];
    final country =
        state.warfare?.neighbors.where((n) => n.id == countryId).firstOrNull;
    final missions = state.warfare?.missions.where(
      (m) => m.countryId == countryId,
    );
    int alerts(String place) => switch (place) {
      'embassy' => (country?.treaty?.arrears ?? 0) > 0 ? 1 : 0,
      'border' =>
        missions?.where((m) => m.status == 'open' || m.intervention).length ??
            0,
      _ => 0,
    };
    return GiangSonPage(
      state: state,
      busy: busy,
      section: section,
      artwork: artwork,
      artworkKey: ValueKey('country-background-$countryId'),
      aspectRatio: 1.6,
      onNavigate: onNavigate,
      onEndTurn: state.seasonal ? null : onEndTurn,
      onOvertime: onOvertime,
      mapStatus: _countryStatus(state, countryId),
      destinations: GiangSonDestinations(
        onNavigate: onNavigate,
        places: [
          for (final (id, label, description, anchor) in locations)
            GiangSonDestination(
              id: 'country-location-$id',
              label: label,
              description: description,
              route: countryRoute(countryId, id),
              artwork: artwork,
              artworkFocus: Alignment(anchor.dx * 2 - 1, anchor.dy * 2 - 1),
              count: alerts(id),
              countLabel: 'cảnh báo',
            ),
        ],
      ),
    );
  }
}

String _countryStatus(GameState state, String countryId) {
  final country =
      state.warfare?.neighbors.where((n) => n.id == countryId).firstOrNull;
  if (country == null) return 'Chưa có thông tin bang giao trong bản lưu này';
  String signed(int value) => value > 0 ? '+$value' : '$value';
  return '${country.direction} · ${neighborStatus(country)}\n'
      'Quan hệ ${signed(country.relation)} · Ưu thế của ta ${signed(country.advantage)}';
}
