import '../../models/number_format.dart';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import 'web_game_hud.dart';
import 'locality_routes.dart';

const _jade = Color(0xFF16372F);
const _gold = Color(0xFFD9B873);
const _paper = Color(0xFFF5EBD5);

/// Countryside destinations only navigate; commands use the existing game shell.
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
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      key: const ValueKey('locality-page'),
      children: [
        WebGameHud(state: state, section: 'locality', onNavigate: onNavigate),
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
                    child: _LocalityMap(state: state, onNavigate: onNavigate),
                  ),
                  Positioned(
                    left: narrow ? 12 : 20,
                    top: 16,
                    child: _LocalityLabel(
                      key: const ValueKey('locality-back'),
                      label: 'Giang Sơn',
                      icon: Icons.arrow_back,
                      onPressed: () => onNavigate('citadel'),
                    ),
                  ),
                  Positioned(
                    right: narrow ? 12 : 20,
                    top: 16,
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: narrow ? 12 : 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _paper,
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/imperial/parchment.webp',
                            ),
                            fit: BoxFit.cover,
                            opacity: .55,
                          ),
                          border: Border.all(color: const Color(0xFF927A56)),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: const [
                            BoxShadow(color: Color(0x40352C23), blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          'ĐỊA PHƯƠNG',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: narrow ? 17 : 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: narrow ? 1 : 2,
                            color: const Color(0xFF352C23),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (state.points == 0 && state.overtime == 0)
                    Positioned(
                      left: 12,
                      bottom: 82,
                      child: _LocalityLabel(
                        key: const ValueKey('locality-overtime'),
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
                              'Kéo để xem\nđịa phương',
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
                      child: _LocalityLabel(
                        key: const ValueKey('locality-end-turn'),
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

class _LocalityMap extends StatefulWidget {
  const _LocalityMap({required this.state, required this.onNavigate});
  final GameState state;
  final ValueChanged<String> onNavigate;

  @override
  State<_LocalityMap> createState() => _LocalityMapState();
}

class _LocalityMapState extends State<_LocalityMap> {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      // Keep the painting's proportions and pan the countryside on narrow screens.
      final canvasHeight = math.max(760.0, bounds.maxHeight);
      final width = math.max(bounds.maxWidth, canvasHeight * 1.5);
      final imageHeight = math.max(canvasHeight, width / 1.5);
      final imageTop = (canvasHeight - imageHeight) / 2;
      _scroll ??= ScrollController(
        initialScrollOffset: (width - bounds.maxWidth) / 2,
      );
      final locations = [
        (LocalityPlace.administration, const Offset(.31, .28)),
        (LocalityPlace.agriculture, const Offset(.22, .49)),
        (LocalityPlace.irrigation, const Offset(.69, .34)),
        (LocalityPlace.granary, const Offset(.87, .50)),
        (LocalityPlace.commerce, const Offset(.55, .70)),
        (LocalityPlace.village, const Offset(.23, .79)),
      ];
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            key: const ValueKey('locality-map-scroll'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: bounds.maxHeight,
              child: SingleChildScrollView(
                key: const ValueKey('locality-map-vertical-scroll'),
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
                          'assets/images/dia-phuong-watercolor.webp',
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
                          left: width * location.$2.dx - 90,
                          top: imageTop + imageHeight * location.$2.dy - 69,
                          width: 180,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 48,
                                child: Tooltip(
                                  message: formatGameNumbers(location.$1.title),
                                  child: _LocalityLabel(
                                    key: ValueKey(
                                      'locality-location-${location.$1.name}',
                                    ),
                                    label: location.$1.landmark,
                                    count:
                                        location.$1
                                            .petitionsFor(widget.state)
                                            .length,
                                    onPressed:
                                        () => widget.onNavigate(
                                          location.$1.route,
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

class _LocalityLabel extends StatelessWidget {
  const _LocalityLabel({
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
            Text(
              formatGameNumbers('$count'),
              style: const TextStyle(color: _gold, fontSize: 12),
            ),
          ],
        ],
      ),
    ),
  );
}
