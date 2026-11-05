import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart';

import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'country_routes.dart';
import 'web_game_hud.dart';

const _deepJade = Color(0xFF102922);
const _jade = Color(0xFF16372F);
const _gilt = Color(0xFFD9B873);
const _ivory = Color(0xFFFFF1CE);
const _paper = Color(0xFFF5EBD5);
const _ink = Color(0xFF352C23);
const _son = Color(0xFF922F28);

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

class _CitadelHubState extends State<CitadelHub>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _idleDelay = Duration(seconds: 5);
  static const _pixelsPerSecond = 7.0;
  final _scroll = ScrollController();
  final _pointers = <int>{};
  late final Ticker _tour = createTicker(_advance);
  Timer? _resumeTimer;
  Duration? _lastElapsed;
  _Region _region = _Region.interior;
  bool _motionAllowed = false, _userScrolling = false;
  bool _programmaticScroll = false, _centering = false, _layoutPending = false;
  int _cameraVersion = 0;
  double _direction = 1, _viewportWidth = 0, _canvasWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionAllowed =
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.of(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (!_motionAllowed) {
      _resumeTimer?.cancel();
      _resumeTimer = null;
    }
    _syncTour();
  }

  @override
  void didUpdateWidget(CitadelHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTour();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _syncTour();

  bool get _canTour =>
      _motionAllowed &&
      !widget.busy &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);

  void _stopTour() {
    _tour.stop();
    _lastElapsed = null;
  }

  void _syncTour() {
    if (_canTour &&
        _pointers.isEmpty &&
        !_userScrolling &&
        !_centering &&
        _resumeTimer == null &&
        _scroll.hasClients &&
        _scroll.position.hasContentDimensions &&
        _scroll.position.maxScrollExtent > 0) {
      if (!_tour.isActive) _tour.start();
    } else {
      _stopTour();
    }
  }

  void _activity() {
    _stopTour();
    _resumeTimer?.cancel();
    _resumeTimer = null;
    if (!_canTour || _pointers.isNotEmpty || _userScrolling || _centering) {
      return;
    }
    _resumeTimer = Timer(_idleDelay, () {
      _resumeTimer = null;
      if (mounted) _syncTour();
    });
  }

  void _advance(Duration elapsed) {
    final previous = _lastElapsed;
    _lastElapsed = elapsed;
    if (previous == null || !_scroll.hasClients) return;
    final position = _scroll.position;
    // Cap delayed frames so a background tab cannot cause a camera jump.
    final dt = math.min((elapsed - previous).inMicroseconds / 1e6, .05);
    final ramp = (elapsed.inMicroseconds / 600000).clamp(0.0, 1.0);
    final next = _scroll.offset + _direction * _pixelsPerSecond * dt * ramp;
    if (next >= position.maxScrollExtent) _direction = -1;
    if (next <= position.minScrollExtent) _direction = 1;
    _programmaticScroll = true;
    try {
      _scroll.jumpTo(
        next.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    } finally {
      _programmaticScroll = false;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (_programmaticScroll || _centering) return false;
    if ((notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is UserScrollNotification &&
            notification.direction != ScrollDirection.idle)) {
      _userScrolling = true;
      _activity();
    } else if (_userScrolling && notification is ScrollEndNotification) {
      _userScrolling = false;
      _activity();
    }
    return false;
  }

  void _layoutCamera(double viewportWidth, double viewportHeight) {
    // Preserve the 1922:818 painting and retain panning space on wide screens.
    final width = math.max(viewportWidth * 1.12, viewportHeight * 1922 / 818);
    if (width == _canvasWidth && viewportWidth == _viewportWidth) return;
    _canvasWidth = width;
    _viewportWidth = viewportWidth;
    if (_layoutPending) return;
    _layoutPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layoutPending = false;
      if (!mounted || !_scroll.hasClients) return;
      _programmaticScroll = true;
      try {
        _scroll.jumpTo(_regionOffset);
      } finally {
        _programmaticScroll = false;
      }
      _syncTour();
    });
  }

  double get _regionOffset =>
      (_canvasWidth * _region.focus - _viewportWidth / 2).clamp(
        0.0,
        _scroll.position.maxScrollExtent,
      );

  Future<void> _selectRegion(_Region region) async {
    _activity();
    if (_region == region) return;
    setState(() => _region = region);
    if (!_scroll.hasClients) return;
    final version = ++_cameraVersion;
    _centering = true;
    _stopTour();
    _resumeTimer?.cancel();
    _resumeTimer = null;
    try {
      if (_motionAllowed) {
        await _scroll.animateTo(
          _regionOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _scroll.jumpTo(_regionOffset);
      }
    } finally {
      if (mounted && version == _cameraVersion) {
        _centering = false;
        _activity();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeTimer?.cancel();
    _tour.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    onKeyEvent: (_, _) {
      _activity();
      return KeyEventResult.ignored;
    },
    child: Listener(
      onPointerDown: (event) {
        _pointers.add(event.pointer);
        _activity();
      },
      onPointerUp: (event) {
        _pointers.remove(event.pointer);
        _activity();
      },
      onPointerCancel: (event) {
        _pointers.remove(event.pointer);
        _activity();
      },
      onPointerSignal: (_) => _activity(),
      onPointerPanZoomStart: (event) {
        _pointers.add(event.pointer);
        _activity();
      },
      onPointerPanZoomEnd: (event) {
        _pointers.remove(event.pointer);
        _activity();
      },
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'BeVietnam',
          color: _ivory,
          fontSize: 13,
        ),
        child: SafeArea(
          child: ColoredBox(
            color: _deepJade,
            child: Column(
              children: [
                WebGameHud(
                  state: widget.state,
                  section: 'citadel',
                  onNavigate: widget.onNavigate,
                ),
                if (widget.busy)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: _gilt,
                    backgroundColor: _deepJade,
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _panorama()),
                      Positioned(
                        right: 16,
                        bottom: 12,
                        child: Tooltip(
                          message: formatGameNumbers(
                            '${widget.state.points} hành động còn lại',
                          ),
                          child: _DestinationButton(
                            key: const ValueKey('citadel-end-turn'),
                            label:
                                widget.state.seasonal
                                    ? 'Khóa mùa'
                                    : 'Sang tuần',
                            icon: Icons.arrow_forward,
                            primary: true,
                            onPressed: widget.busy ? null : widget.onEndTurn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _regionTabs(),
                _destinations(),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _panorama() => LayoutBuilder(
    builder: (context, bounds) {
      _layoutCamera(bounds.maxWidth, bounds.maxHeight);
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: SingleChildScrollView(
            key: const ValueKey('giang-son-map-scroll'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              key: const ValueKey('giang-son-map'),
              width: _canvasWidth,
              height: bounds.maxHeight,
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/images/giang-son-map.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment(0, _region.verticalAlignment),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _regionTabs() => Material(
    key: const ValueKey('giang-son-regions'),
    color: _jade,
    child: Row(
      children: [
        for (final region in _Region.values)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _region == region ? _gilt : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Semantics(
                selected: _region == region,
                child: TextButton(
                  key: ValueKey('giang-son-region-${region.id}'),
                  style: TextButton.styleFrom(
                    foregroundColor: _region == region ? _ivory : _gilt,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: () => _selectRegion(region),
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
        ('palace', 'Kinh thành', 'capital'),
        ('farms', 'Địa phương', 'locality'),
      ],
      _Region.frontier => [
        for (final (id, name) in [
          ('north', 'Bắc ải'),
          ('west', 'Tây ải'),
          ('south', 'Nam ải'),
        ])
          ('$id-pass', name, state.warfare == null ? military : 'frontier-$id'),
      ],
      _Region.neighbors => [
        for (final id in countryNames.keys) (id, country(id), countryRoute(id)),
      ],
    };
    return ColoredBox(
      key: const ValueKey('giang-son-destinations'),
      color: _paper,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder:
              (context, bounds) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < places.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SizedBox(
                      width: math.min(
                        240.0,
                        (bounds.maxWidth - (places.length - 1) * 8) /
                            places.length,
                      ),
                      child: _DestinationButton(
                        key: ValueKey('giang-son-${places[i].$1}'),
                        label: places[i].$2,
                        count:
                            places[i].$1 == 'palace'
                                ? state.petitions.length
                                : 0,
                        onPressed: () => widget.onNavigate(places[i].$3),
                      ),
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.count = 0,
    this.primary = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final int count;
  final bool primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: _paper,
      foregroundColor: primary ? _son : _ink,
      side: BorderSide(color: primary ? _son : const Color(0xFFB6A27C)),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      elevation: primary ? 3 : 0,
      shadowColor: const Color(0x40352C23),
    ),
    onPressed: onPressed,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                formatGameNumbers(label),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Lora', fontSize: 15),
              ),
            ),
          ],
        ),
        if (count > 0) ...[
          const SizedBox(height: 4),
          Text(
            formatGameNumbers('$count tấu sớ'),
            style: const TextStyle(
              fontFamily: 'BeVietnam',
              color: _son,
              fontSize: 11,
            ),
          ),
        ],
      ],
    ),
  );
}
