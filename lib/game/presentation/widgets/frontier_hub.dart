import 'package:flutter/material.dart';

import '../../logic/frontier_rules.dart';
import '../../models/game_state.dart';
import 'frontier_routes.dart';
import 'giang_son_page.dart';

const frontierBackgroundAssets = {
  'north': 'assets/images/frontier-north-watercolor.webp',
  'west': 'assets/images/frontier-west-watercolor.webp',
  'south': 'assets/images/frontier-watercolor.webp',
};

class FrontierHub extends StatelessWidget {
  const FrontierHub({
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
    final section = 'frontier-$countryId';
    final artwork = frontierBackgroundAssets[countryId]!;
    const locations = [
      (
        'gate',
        'Cửa Ải',
        'Tình hình địch · Chọn quân và tướng',
        Offset(.50, .27),
      ),
      ('camp', 'Doanh Trại', 'Quân đồn trú · Điều quân', Offset(.24, .62)),
      (
        'command',
        'Phủ Trấn Thủ',
        'Mặt trận · Quân báo · Ngoại giao',
        Offset(.77, .59),
      ),
    ];
    final country = state.warfare!.neighbors.firstWhere(
      (n) => n.id == countryId,
    );
    final missions = state.warfare!.missions.where(
      (m) => m.countryId == countryId,
    );
    int alerts(String place) => switch (place) {
      'camp' => FrontierDefense(state, country).penalty > 0 ? 1 : 0,
      'gate' =>
        missions.where((m) => m.status == 'open' || m.intervention).length,
      _ => missions.where((m) => m.intervention).length,
    };
    return GiangSonPage(
      state: state,
      busy: busy,
      section: section,
      artwork: artwork,
      artworkKey: ValueKey('frontier-background-$countryId'),
      aspectRatio: 1.5,
      onNavigate: onNavigate,
      onEndTurn: state.seasonal ? null : onEndTurn,
      onOvertime: onOvertime,
      destinations: GiangSonDestinations(
        onNavigate: onNavigate,
        places: [
          for (final (id, label, description, anchor) in locations)
            GiangSonDestination(
              id: 'frontier-location-$id',
              label: label,
              description: description,
              route: frontierRoute(countryId, id),
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
