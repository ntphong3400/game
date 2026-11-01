import '../../models/number_format.dart';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import 'web_game_hud.dart';
import 'country_routes.dart';

const _deepJade = Color(0xFF102922);
const _gilt = Color(0xFFD9B873);
const _ivory = Color(0xFFFFF1CE);
const _son = Color(0xFF922F28);

/// Giang Sơn overview. The internal citadel route stays compatible with saves.
/// All actions are delegated to the existing game shell.
class CitadelHub extends StatelessWidget {
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
  Widget build(BuildContext context) => DefaultTextStyle(
    style: const TextStyle(
      fontFamily: 'BeVietnam',
      color: _ivory,
      fontSize: 13,
    ),
    child: SafeArea(
      child: ColoredBox(
        color: _deepJade,
        child: LayoutBuilder(
          builder:
              (context, bounds) => Column(
                children: [
                  _header(bounds.maxWidth >= 720, bounds.maxHeight < 520),
                  if (busy)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: _gilt,
                      backgroundColor: _deepJade,
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _NationalMap(
                            state: state,
                            onPalace: () => onNavigate('capital'),
                            onNavigate: onNavigate,
                          ),
                        ),
                        if (bounds.maxWidth >= 720)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _deepJade.withValues(alpha: .9),
                                  border: Border.all(color: _gilt),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'GIANG SƠN',
                                      style: TextStyle(
                                        fontFamily: 'Lora',
                                        fontSize: 20,
                                        letterSpacing: 2,
                                        color: _ivory,
                                      ),
                                    ),
                                    Text(
                                      'Lãnh thổ của bệ hạ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _gilt,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (bounds.maxWidth < 720)
                          const Positioned(
                            left: 12,
                            bottom: 20,
                            child: IgnorePointer(
                              child: Text(
                                'Kéo ngang để xem bản đồ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _ivory,
                                  shadows: [
                                    Shadow(color: _deepJade, blurRadius: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 20,
                          bottom: 18,
                          width: bounds.maxWidth < 600 ? 168 : 205,
                          child: Tooltip(
                            message: formatGameNumbers(
                              '${state.points} hành động còn lại',
                            ),
                            child: _MapLabel(
                              key: const ValueKey('citadel-end-turn'),
                              onPressed: busy ? null : onEndTurn,
                              label: state.seasonal ? 'Khóa mùa' : 'Sang tuần',
                              icon: Icons.arrow_forward,
                              primary: true,
                              compact: bounds.maxHeight < 520,
                            ),
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
  );

  Widget _header(bool wide, bool short) =>
      WebGameHud(state: state, section: 'citadel', onNavigate: onNavigate);
}

class _NationalMap extends StatefulWidget {
  const _NationalMap({
    required this.state,
    required this.onPalace,
    required this.onNavigate,
  });
  final GameState state;
  final VoidCallback onPalace;
  final ValueChanged<String> onNavigate;
  @override
  State<_NationalMap> createState() => _NationalMapState();
}

class _NationalMapState extends State<_NationalMap> {
  ScrollController? _scroll;
  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      // This matches the aspect ratio of the shipped background plate.
      final width =
          bounds.maxWidth >= 720
              ? bounds.maxWidth
              : math.max(bounds.maxWidth, bounds.maxHeight * (1922 / 818));
      _scroll ??= ScrollController(
        initialScrollOffset: (width - bounds.maxWidth) * .48,
      );
      final military = widget.state.population == null ? 'kingdom' : 'military';
      final neighbors = widget.state.warfare?.neighbors;
      String country(String id, String fallback) =>
          neighbors?.where((n) => n.id == id).firstOrNull?.name ?? fallback;
      final landmarks = <(String, String, Offset, VoidCallback)>[
        ('palace', 'Kinh thành', const Offset(.49, .36), widget.onPalace),
        (
          'farms',
          'Địa phương',
          const Offset(.76, .67),
          () => widget.onNavigate('locality'),
        ),
        (
          'north-pass',
          'Bắc ải',
          const Offset(.525, .15),
          () => widget.onNavigate(
            widget.state.warfare == null ? military : 'frontier-north',
          ),
        ),
        (
          'west-pass',
          'Tây ải',
          const Offset(.27, .46),
          () => widget.onNavigate(
            widget.state.warfare == null ? military : 'frontier-west',
          ),
        ),
        (
          'south-pass',
          'Nam ải',
          const Offset(.595, .81),
          () => widget.onNavigate(
            widget.state.warfare == null ? military : 'frontier-south',
          ),
        ),
        (
          'north',
          country('north', 'Hàn Kỳ'),
          const Offset(.26, .19),
          () => widget.onNavigate(countryRoute('north')),
        ),
        (
          'west',
          country('west', 'Xích Lĩnh'),
          const Offset(.10, .57),
          () => widget.onNavigate(countryRoute('west')),
        ),
        (
          'south',
          country('south', 'Bích Trạch'),
          const Offset(.29, .90),
          () => widget.onNavigate(countryRoute('south')),
        ),
      ];
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            key: const ValueKey('giang-son-map-scroll'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: bounds.maxHeight,
              child: Stack(
                key: const ValueKey('giang-son-map'),
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/giang-son-map.webp',
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                  for (final landmark in landmarks)
                    Positioned(
                      left: (width * landmark.$3.dx -
                              (bounds.maxWidth >= 720 && bounds.maxHeight < 360
                                  ? 58
                                  : 75))
                          .clamp(4.0, width - 154),
                      top: (bounds.maxHeight * landmark.$3.dy - 42).clamp(
                        4.0,
                        math.max(4.0, bounds.maxHeight - 52),
                      ),
                      width:
                          bounds.maxWidth >= 720 && bounds.maxHeight < 360
                              ? 116
                              : 150,
                      child: _MapLabel(
                        key: ValueKey('giang-son-${landmark.$1}'),
                        label: landmark.$2,
                        onPressed: landmark.$4,
                        compact: bounds.maxHeight < 360,
                        count:
                            landmark.$1 == 'palace'
                                ? widget.state.petitions.length
                                : 0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    super.key,
    required this.label,
    required this.onPressed,
    this.count = 0,
    this.compact = false,
    this.icon,
    this.primary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final int count;
  final bool compact;
  final IconData? icon;
  final bool primary;

  static const _paper = Color(0xFFF5EBD5);
  static const _ink = Color(0xFF352C23);
  static const _border = Color(0xFF927A56);

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? .45 : 1,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40352C23),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: _paper,
        borderRadius: BorderRadius.circular(3),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/imperial/parchment.webp'),
              fit: BoxFit.cover,
              opacity: .65,
            ),
            border: Border.all(color: primary ? _son : _border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: InkWell(
            onTap: onPressed,
            mouseCursor:
                onPressed == null
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
            hoverColor: const Color(0x187A5C38),
            focusColor: const Color(0x33922F28),
            highlightColor: const Color(0x267A5C38),
            splashColor: const Color(0x337A5C38),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: primary ? 54 : 44),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (primary ? _son : _border).withValues(alpha: .35),
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: _son, size: compact ? 16 : 18),
                          const SizedBox(width: 7),
                        ],
                        Flexible(
                          child: Text(
                            formatGameNumbers(label),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: compact ? 12 : 15,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _son,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              formatGameNumbers('$count'),
                              style: const TextStyle(
                                fontFamily: 'BeVietnam',
                                fontSize: 10,
                                color: _paper,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
