import 'package:flutter/material.dart';

import '../../models/game_state.dart';
import 'country_routes.dart';
import 'giang_son_page.dart';

enum _Region {
  interior('interior', 'Nội trị', .49, 0),
  frontier('frontier', 'Biên ải', .525, -.65),
  neighbors('neighbors', 'Lân bang', .26, 0);

  const _Region(this.id, this.label, this.focus, this.verticalAlignment);
  final String id, label;
  final double focus, verticalAlignment;
}

/// Giang Sơn overview. Navigation retains the existing routes and commands.
class CitadelHub extends StatefulWidget {
  const CitadelHub({
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
  State<CitadelHub> createState() => _CitadelHubState();
}

class _CitadelHubState extends State<CitadelHub> {
  _Region _region = _Region.interior;

  @override
  Widget build(BuildContext context) => GiangSonPage(
    state: widget.state,
    busy: widget.busy,
    section: 'citadel',
    artwork: 'assets/images/giang-son-map.webp',
    aspectRatio: 1922 / 818,
    focus: _region.focus,
    verticalAlignment: _region.verticalAlignment,
    onNavigate: widget.onNavigate,
    onEndTurn: widget.onEndTurn,
    regionTabs: _regionTabs(),
    destinations: _destinations(),
  );

  Widget _regionTabs() => Material(
    key: const ValueKey('giang-son-regions'),
    color: giangSonJade,
    child: Row(
      children: [
        for (final region in _Region.values)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        _region == region ? giangSonGilt : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Semantics(
                selected: _region == region,
                child: TextButton(
                  key: ValueKey('giang-son-region-${region.id}'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _region == region ? giangSonIvory : giangSonGilt,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: () => setState(() => _region = region),
                  child: Text(
                    region.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'BeVietnam',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _destinations() {
    final state = widget.state;
    final military = state.population == null ? 'kingdom' : 'military';
    String country(String id) =>
        state.warfare?.neighbors.where((n) => n.id == id).firstOrNull?.name ??
        countryNames[id]!;
    final places = switch (_region) {
      _Region.interior => [
        ('palace', 'Kinh thành', 'capital', 'palace'),
        ('farms', 'Địa phương', 'locality', 'village'),
      ],
      _Region.frontier => [
        for (final (id, name) in [
          ('north', 'Bắc ải'),
          ('west', 'Tây ải'),
          ('south', 'Nam ải'),
        ])
          (
            '$id-pass',
            name,
            state.warfare == null ? military : 'frontier-$id',
            'pass-$id',
          ),
      ],
      _Region.neighbors => [
        for (final id in countryNames.keys)
          (id, country(id), countryRoute(id), 'country-$id'),
      ],
    };
    return GiangSonDestinations(
      key: const ValueKey('giang-son-destinations'),
      onNavigate: widget.onNavigate,
      places: [
        for (final (id, label, route, artwork) in places)
          GiangSonDestination(
            id: 'giang-son-$id',
            label: label,
            route: route,
            artwork: 'assets/images/giang-son-$artwork.webp',
            count: id == 'palace' ? state.petitions.length : 0,
          ),
      ],
    );
  }
}
