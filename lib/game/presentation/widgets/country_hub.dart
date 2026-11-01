import '../../models/number_format.dart';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/warfare_rules.dart';
import 'country_routes.dart';
import 'web_game_hud.dart';

const _jade = Color(0xFF16372F);
const _gold = Color(0xFFD9B873);
const _paper = Color(0xFFF5EBD5);

const countryBackgroundAssets = {
  'north': 'assets/images/country-north-watercolor.webp',
  'west': 'assets/images/country-west-watercolor.webp',
  'south': 'assets/images/country-south-watercolor.webp',
};

/// City destinations only navigate; they never issue a game command.
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
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      key: const ValueKey('country-page'),
      children: [
        WebGameHud(
          state: state,
          section: 'country-$countryId',
          onNavigate: onNavigate,
        ),
        if (MediaQuery.sizeOf(context).width < 720)
          Container(
            key: const ValueKey('country-compact-status'),
            width: double.infinity,
            color: _paper,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(
              formatGameNumbers(_countryStatus(state, countryId)),
              style: const TextStyle(fontSize: 11, color: _jade),
            ),
          ),
        if (busy)
          const LinearProgressIndicator(
            minHeight: 2,
            color: _gold,
            backgroundColor: _jade,
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, bounds) {
              final narrow = bounds.maxWidth < 720;
              return Stack(
                children: [
                  Positioned.fill(
                    child: _CountryMap(
                      state: state,
                      countryId: countryId,
                      onNavigate: onNavigate,
                    ),
                  ),
                  Positioned(
                    left: narrow ? 12 : 20,
                    top: 16,
                    child: _CountryLabel(
                      key: const ValueKey('country-back'),
                      label: 'Giang Sơn',
                      icon: Icons.arrow_back,
                      onPressed: () => onNavigate('citadel'),
                    ),
                  ),
                  Positioned(
                    right: narrow ? 12 : 20,
                    top: 16,
                    child: _CountryPlaque(
                      state: state,
                      countryId: countryId,
                      narrow: narrow,
                    ),
                  ),
                  if (state.points == 0 && state.overtime == 0)
                    Positioned(
                      left: 12,
                      bottom: 82,
                      child: _CountryLabel(
                        key: const ValueKey('country-overtime'),
                        label: 'Chong đèn làm thêm',
                        onPressed: busy ? null : onOvertime,
                      ),
                    ),
                  if (narrow || bounds.maxHeight < 760)
                    const Positioned(
                      left: 12,
                      bottom: 18,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: _paper),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Kéo để xem\nlân bang',
                              style: TextStyle(fontSize: 10, color: _jade),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 20,
                    bottom: 18,
                    width: narrow ? 168 : 205,
                    child: Tooltip(
                      message: formatGameNumbers(
                        '${state.points} hành động còn lại',
                      ),
                      child: _CountryLabel(
                        key: const ValueKey('country-end-turn'),
                        label: state.seasonal ? 'Khóa mùa' : 'Sang tuần',
                        icon: Icons.arrow_forward,
                        primary: true,
                        onPressed: busy ? null : onEndTurn,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

String _countryStatus(GameState state, String countryId) {
  final country =
      state.warfare?.neighbors.where((n) => n.id == countryId).firstOrNull;
  if (country == null) return 'Chưa có thông tin bang giao trong bản lưu này';
  String signed(int value) => value > 0 ? '+$value' : '$value';
  return '${country.direction} · ${neighborStatus(country)}\n'
      'Quan hệ ${signed(country.relation)} · Ưu thế của ta ${signed(country.advantage)}';
}

class _CountryPlaque extends StatelessWidget {
  const _CountryPlaque({
    required this.state,
    required this.countryId,
    required this.narrow,
  });
  final GameState state;
  final String countryId;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final name =
        state.warfare?.neighbors
            .where((n) => n.id == countryId)
            .firstOrNull
            ?.name ??
        countryNames[countryId]!;
    return IgnorePointer(
      child: Container(
        constraints: BoxConstraints(maxWidth: narrow ? 168 : 280),
        padding: EdgeInsets.symmetric(
          horizontal: narrow ? 12 : 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: _paper,
          image: const DecorationImage(
            image: AssetImage('assets/images/imperial/parchment.webp'),
            fit: BoxFit.cover,
            opacity: .55,
          ),
          border: Border.all(color: const Color(0xFF927A56)),
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [BoxShadow(color: Color(0x40352C23), blurRadius: 6)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatGameNumbers(name.toUpperCase()),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: narrow ? 17 : 24,
                fontWeight: FontWeight.w600,
                letterSpacing: narrow ? 1 : 2,
                color: const Color(0xFF352C23),
              ),
            ),
            if (!narrow) ...[
              const SizedBox(height: 10),
              Text(
                formatGameNumbers(_countryStatus(state, countryId)),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: _jade),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountryMap extends StatefulWidget {
  const _CountryMap({
    required this.state,
    required this.countryId,
    required this.onNavigate,
  });
  final GameState state;
  final String countryId;
  final ValueChanged<String> onNavigate;

  @override
  State<_CountryMap> createState() => _CountryMapState();
}

class _CountryMapState extends State<_CountryMap> {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      // Keep the painting's proportions and pan the city on narrow screens.
      final canvasHeight = math.max(760.0, bounds.maxHeight);
      final width = math.max(bounds.maxWidth, canvasHeight * 1.6);
      final imageHeight = math.max(canvasHeight, width / 1.6);
      final imageTop = (canvasHeight - imageHeight) / 2;
      _scroll ??= ScrollController(
        initialScrollOffset: (width - bounds.maxWidth) / 2,
      );
      // Roof anchors share the full-bleed painting coordinates, including the
      // scenery restored where the mockup HUD used to be.
      final locations = [
        (
          'palace',
          'Vương cung',
          'Bang giao · Giao hảo · Tuyên chiến',
          widget.countryId == 'south'
              ? const Offset(.49, .27)
              : widget.countryId == 'west'
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
          widget.countryId == 'south'
              ? const Offset(.81, .59)
              : widget.countryId == 'west'
              ? const Offset(.80, .51)
              : const Offset(.81, .55),
        ),
      ];
      final country =
          widget.state.warfare?.neighbors
              .where((n) => n.id == widget.countryId)
              .firstOrNull;
      final missions = widget.state.warfare?.missions.where(
        (m) => m.countryId == widget.countryId,
      );
      int alerts(String place) => switch (place) {
        'embassy' => (country?.treaty?.arrears ?? 0) > 0 ? 1 : 0,
        'border' =>
          missions?.where((m) => m.status == 'open' || m.intervention).length ??
              0,
        _ => 0,
      };
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            key: const ValueKey('country-map-scroll'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: bounds.maxHeight,
              child: SingleChildScrollView(
                key: const ValueKey('country-map-vertical-scroll'),
                primary: false,
                child: SizedBox(
                  height: canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: 0,
                        top: imageTop,
                        width: width,
                        height: imageHeight,
                        child: Image.asset(
                          countryBackgroundAssets[widget.countryId]!,
                          key: ValueKey(
                            'country-background-${widget.countryId}',
                          ),
                          fit: BoxFit.fill,
                          excludeFromSemantics: true,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      for (final location in locations)
                        Positioned(
                          // Coordinates locate the dot on the painted roof.
                          // Keep that anchor fixed when the viewport crops or
                          // scrolls the painting; do not clamp the nameplate.
                          left: width * location.$4.dx - 90,
                          top: imageTop + imageHeight * location.$4.dy - 69,
                          width: 180,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 48,
                                child: Tooltip(
                                  message: formatGameNumbers(location.$3),
                                  child: _CountryLabel(
                                    key: ValueKey(
                                      'country-location-${location.$1}',
                                    ),
                                    label: location.$2,
                                    count: alerts(location.$1),
                                    onPressed:
                                        () => widget.onNavigate(
                                          countryRoute(
                                            widget.countryId,
                                            location.$1,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 18, color: _gold),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _jade,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _gold),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _CountryLabel extends StatelessWidget {
  const _CountryLabel({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.count = 0,
    this.primary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final int count;
  final bool primary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0x55352C23),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _paper,
        backgroundColor: primary ? const Color(0xFF922F28) : _jade,
        disabledForegroundColor: _paper.withValues(alpha: .5),
        disabledBackgroundColor: _jade,
        side: const BorderSide(color: _gold),
        minimumSize: Size(0, primary ? 54 : 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(fontFamily: 'Lora', fontSize: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _gold),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(formatGameNumbers(label), textAlign: TextAlign.center),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color(0xFF922F28),
                shape: BoxShape.circle,
              ),
              child: Text(
                formatGameNumbers('$count'),
                style: const TextStyle(color: _paper, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
