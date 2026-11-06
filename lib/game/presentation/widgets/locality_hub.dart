import 'package:flutter/material.dart';

import '../../models/game_state.dart';
import 'giang_son_page.dart';
import 'locality_routes.dart';

class LocalityHub extends StatelessWidget {
  const LocalityHub({
    super.key,
    required this.state,
    required this.busy,
    required this.onNavigate,
    required this.onEndTurn,
    required this.onOvertime,
  });

  final GameState state;
  final bool busy;
  final ValueChanged<String> onNavigate;
  final VoidCallback onEndTurn, onOvertime;

  @override
  Widget build(BuildContext context) {
    const artwork = 'assets/images/dia-phuong-watercolor.webp';
    const locations = [
      (LocalityPlace.administration, Offset(.31, .28)),
      (LocalityPlace.agriculture, Offset(.22, .49)),
      (LocalityPlace.irrigation, Offset(.69, .34)),
      (LocalityPlace.granary, Offset(.87, .50)),
      (LocalityPlace.commerce, Offset(.55, .70)),
      (LocalityPlace.village, Offset(.23, .79)),
    ];
    return GiangSonPage(
      state: state,
      busy: busy,
      section: 'locality',
      artwork: artwork,
      aspectRatio: 1.5,
      onNavigate: onNavigate,
      onEndTurn: state.seasonal ? null : onEndTurn,
      onOvertime: onOvertime,
      destinations: GiangSonDestinations(
        onNavigate: onNavigate,
        places: [
          for (final (place, anchor) in locations)
            GiangSonDestination(
              id: 'locality-location-${place.name}',
              label: place.landmark,
              description: place.title,
              route: place.route,
              artwork: artwork,
              artworkFocus: Alignment(anchor.dx * 2 - 1, anchor.dy * 2 - 1),
              count: place.petitionsFor(state).length,
            ),
        ],
      ),
    );
  }
}
