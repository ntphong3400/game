import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart';

import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'web_game_hud.dart';

const _deepJade = Color(0xFF102922);
const giangSonJade = Color(0xFF16372F);
const giangSonGilt = Color(0xFFD9B873);
const giangSonIvory = Color(0xFFFFF1CE);
const _paper = Color(0xFFF5EBD5);
const _ink = Color(0xFF352C23);
const _son = Color(0xFF922F28);

/// Shared panorama layout for the Giang Sơn map and its destination hubs.
class GiangSonPage extends StatefulWidget {
  const GiangSonPage({
    super.key,
    required this.state,
    required this.busy,
    required this.section,
    required this.artwork,
    required this.aspectRatio,
    required this.destinations,
    required this.onNavigate,
    this.regionTabs,
    this.mapStatus,
    this.onEndTurn,
    this.onOvertime,
    this.artworkKey,
    this.focus = .5,
    this.verticalAlignment = -.5,
  });

  final GameState state;
  final bool busy;
  final String section, artwork;
  final double aspectRatio, focus, verticalAlignment;
  final Widget? regionTabs;
  final String? mapStatus;
  final Widget destinations;
  final Key? artworkKey;
  final ValueChanged<String> onNavigate;
  final VoidCallback? onEndTurn, onOvertime;

  String get _pageId => section.split('-').first;
  String get _mapId => section == 'citadel' ? 'giang-son-map' : '$_pageId-map';

  @override
  State<GiangSonPage> createState() => _GiangSonPageState();
}

class _GiangSonPageState extends State<GiangSonPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _idleDelay = Duration(seconds: 5);
  static const _pixelsPerSecond = 7.0;
  final _scroll = ScrollController();
  final _pointers = <int>{};
  late final Ticker _tour = createTicker(_advance);
  Timer? _resumeTimer;
  Duration? _lastElapsed;
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
  void didUpdateWidget(GiangSonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focus != widget.focus) {
      // Wait for layout so the new viewport and scroll extents are available.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) unawaited(_centerCamera());
      });
    }
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
    // Preserve the painting and retain panning space on wide screens.
    final width = math.max(
      viewportWidth * 1.12,
      viewportHeight * widget.aspectRatio,
    );
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
        _scroll.jumpTo(_cameraOffset);
      } finally {
        _programmaticScroll = false;
      }
      _syncTour();
    });
  }

  double get _cameraOffset => (_canvasWidth * widget.focus - _viewportWidth / 2)
      .clamp(0.0, _scroll.position.maxScrollExtent);

  Future<void> _centerCamera() async {
    final version = ++_cameraVersion;
    _centering = true;
    _stopTour();
    _resumeTimer?.cancel();
    _resumeTimer = null;
    try {
      if (_motionAllowed) {
        await _scroll.animateTo(
          _cameraOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _scroll.jumpTo(_cameraOffset);
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
      child: Scaffold(
        backgroundColor: _deepJade,
        body: SafeArea(
          bottom: false,
          child: Column(
            key: ValueKey('${widget._pageId}-page'),
            children: [
              WebGameHud(
                state: widget.state,
                section: widget.section,
                onNavigate: widget.onNavigate,
              ),
              if (widget.busy)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: giangSonGilt,
                  backgroundColor: _deepJade,
                ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: _panorama()),
                    if (widget.mapStatus case final status?)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _MapStatus(status),
                          ),
                        ),
                      ),
                    _mapActions(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Keep transient messages above the destination buttons.
        bottomNavigationBar: SafeArea(
          top: false,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'BeVietnam',
              color: giangSonIvory,
              fontSize: 13,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.regionTabs case final tabs?) tabs,
                widget.destinations,
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _mapActions() {
    final overtime =
        widget.onOvertime != null &&
        widget.state.points == 0 &&
        widget.state.overtime == 0;
    final endTurn = widget.onEndTurn != null;
    if (!overtime && !endTurn) return const SizedBox.shrink();
    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (overtime)
            Flexible(
              child: _MapAction(
                key: ValueKey('${widget._pageId}-overtime'),
                label: 'Chong đèn làm thêm',
                onPressed: widget.busy ? null : widget.onOvertime,
              ),
            )
          else
            const SizedBox.shrink(),
          if (endTurn)
            Flexible(
              child: Tooltip(
                message: formatGameNumbers(
                  '${widget.state.points} hành động còn lại',
                ),
                child: _MapAction(
                  key: ValueKey('${widget._pageId}-end-turn'),
                  label: widget.state.seasonal ? 'Khóa mùa' : 'Sang tuần',
                  icon: Icons.arrow_forward,
                  onPressed: widget.busy ? null : widget.onEndTurn,
                ),
              ),
            ),
        ],
      ),
    );
  }

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
            key: ValueKey('${widget._mapId}-scroll'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              key: ValueKey(widget._mapId),
              width: _canvasWidth,
              height: bounds.maxHeight,
              child: RepaintBoundary(
                child: Image.asset(
                  widget.artwork,
                  key: widget.artworkKey,
                  fit: BoxFit.cover,
                  alignment: Alignment(0, widget.verticalAlignment),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class GiangSonDestination {
  const GiangSonDestination({
    required this.id,
    required this.label,
    required this.route,
    required this.artwork,
    this.artworkFocus,
    this.description,
    this.count = 0,
    this.countLabel = 'tấu sớ',
  });

  final String id, label, route, artwork, countLabel;
  final String? description;
  final Alignment? artworkFocus;
  final int count;
}

class GiangSonDestinations extends StatelessWidget {
  const GiangSonDestinations({
    super.key,
    required this.places,
    required this.onNavigate,
    this.featuredPlace,
  });

  final List<GiangSonDestination> places;
  final ValueChanged<String> onNavigate;
  final GiangSonDestination? featuredPlace;

  bool get _usesGrid => featuredPlace != null || places.length == 6;

  Widget _row(
    Iterable<GiangSonDestination> rowPlaces,
    double width,
    double gap, {
    bool compact = false,
    GiangSonDestination? featured,
  }) => IntrinsicHeight(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        for (final place in rowPlaces)
          SizedBox(
            width: width,
            child: _DestinationCard(
              destination: place,
              width: width,
              compact: compact,
              featured: place == featured,
              onPressed: () => onNavigate(place.route),
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border:
          _usesGrid ? const Border(top: BorderSide(color: giangSonGilt)) : null,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE6D6B4), Color(0xFFF1E6CE)],
      ),
    ),
    child: LayoutBuilder(
      builder: (context, bounds) {
        const gap = 8.0;
        const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
        final available = bounds.maxWidth - padding.horizontal;
        final gaps = (places.length - 1) * gap;
        if (_usesGrid) {
          final featured = featuredPlace;
          final textScale = math.max(
            1.0,
            MediaQuery.textScalerOf(context).scale(13) / 13,
          );
          final minCardWidth = 128.0 * textScale;
          final allPlaces = featured == null ? places : [featured, ...places];
          final fullRowGaps = (allPlaces.length - 1) * gap;
          const fullRowPadding = EdgeInsets.all(10);
          final fullRowWidth = bounds.maxWidth - fullRowPadding.horizontal;
          final fullRowCardWidth =
              (fullRowWidth - fullRowGaps) / allPlaces.length;
          if (fullRowCardWidth >= minCardWidth) {
            return Padding(
              padding: fullRowPadding,
              child: _row(
                allPlaces,
                fullRowCardWidth,
                gap,
                compact: true,
                featured: featured,
              ),
            );
          }
          final width = math.min(available, 1040.0 * textScale);
          final singleRowWidth = places.length * minCardWidth + gaps;
          final columns =
              width >= singleRowWidth ? math.max(1, places.length) : 3;
          final cardWidth = (width - (columns - 1) * gap) / columns;
          return Padding(
            padding: padding,
            child: Center(
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: gap,
                  children: [
                    if (featured != null)
                      _DestinationCard(
                        destination: featured,
                        width: width,
                        featured: true,
                        onPressed: () => onNavigate(featured.route),
                      ),
                    for (var start = 0; start < places.length; start += columns)
                      _row(
                        places.skip(start).take(columns),
                        cardWidth,
                        gap,
                        compact: true,
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        final minimum = places.length > 3 ? 136.0 : 0.0;
        final width = ((available - gaps) / places.length).clamp(
          minimum,
          250.0,
        );
        final row = _row(places, width, gap);
        if (width * places.length + gaps > available + .01) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
              scrollbars: false,
            ),
            child: Scrollbar(
              notificationPredicate:
                  (notification) =>
                      notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                primary: true,
                scrollDirection: Axis.horizontal,
                padding: padding,
                child: row,
              ),
            ),
          );
        }
        return SizedBox(
          width: double.infinity,
          child: Padding(padding: padding, child: Center(child: row)),
        );
      },
    ),
  );
}

class _MapStatus extends StatelessWidget {
  const _MapStatus(this.status);

  final String status;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 300),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: _deepJade.withValues(alpha: .94),
        border: Border.all(color: giangSonGilt),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          formatGameNumbers(status),
          style: const TextStyle(
            fontFamily: 'BeVietnam',
            fontSize: 11,
            color: giangSonIvory,
          ),
        ),
      ),
    ),
  );
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destination,
    required this.width,
    required this.onPressed,
    this.compact = false,
    this.featured = false,
  });

  final GiangSonDestination destination;
  final double width;
  final VoidCallback onPressed;
  final bool compact, featured;

  @override
  Widget build(BuildContext context) {
    final count = destination.count;
    final focus = destination.artworkFocus;
    final shape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(7)),
      side: BorderSide(
        color: featured ? const Color(0xFF907044) : const Color(0xFFAE9162),
      ),
    );
    const artCorners = BorderRadius.vertical(
      top: Radius.elliptical(23, 11),
      bottom: Radius.circular(4),
    );
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledWidth = width * 16 / math.max(16, textScaler.scale(16));
    final featuredBanner = featured && !compact;
    final stacked = !featuredBanner && scaledWidth < 125;
    final showFullCount = featuredBanner || scaledWidth >= 226;
    final cornerBadge = !featuredBanner && scaledWidth < 174;
    final compactStack = compact && stacked;
    final artSize = switch ((
      featuredBanner,
      compactStack,
      stacked,
      cornerBadge,
    )) {
      (true, _, _, _) => const Size(48, 36),
      (_, true, _, _) => const Size(34, 26),
      (_, _, true, _) => const Size(40, 34),
      (_, _, _, true) => const Size(35, 38),
      _ => Size(showFullCount ? 52 : 42, 46),
    };
    final illustration = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: artCorners,
        border: Border.all(color: const Color(0xFF907347)),
      ),
      child: ClipRRect(
        borderRadius: artCorners,
        child: SizedBox(
          width: artSize.width,
          height: artSize.height,
          child: Transform.scale(
            scale: focus == null ? 1 : 3,
            alignment: focus ?? Alignment.center,
            child: Image.asset(
              destination.artwork,
              fit: BoxFit.cover,
              alignment: focus ?? Alignment.center,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
    final title = Text(
      formatGameNumbers(destination.label),
      textAlign: stacked ? TextAlign.center : TextAlign.start,
      maxLines: compact || featured ? null : 2,
      overflow: compact || featured ? TextOverflow.clip : TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Lora',
        fontSize:
            compact
                ? (stacked ? 12 : 13)
                : (stacked ? 14 : (cornerBadge ? 15 : 16)),
      ),
    );
    final badgeText = formatGameNumbers('$count ${destination.countLabel}');
    final badge = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width / 3),
      child: Semantics(
        label: badgeText,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF7E6D4),
            border: Border.all(color: const Color(0xFFA95243)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: cornerBadge ? 4 : 5,
              vertical: cornerBadge ? 1 : 3,
            ),
            child: Text(
              showFullCount ? badgeText : formatWholeNumber(count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'BeVietnam',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _son,
              ),
            ),
          ),
        ),
      ),
    );

    return ConstrainedBox(
      key: ValueKey(destination.id),
      constraints: BoxConstraints(minHeight: featuredBanner ? 50 : 62),
      child: Material(
        color: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  featured
                      ? const [Color(0xFFFFF4DC), Color(0xFFF4E2B6)]
                      : const [Color(0xFFFDF4DF), Color(0xFFF4E6C7)],
            ),
          ),
          child: Tooltip(
            message: destination.description ?? '',
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: _ink,
                overlayColor: const Color(0x266F4A1A),
                alignment:
                    compactStack
                        ? Alignment.topCenter
                        : (stacked ? Alignment.center : Alignment.centerLeft),
                padding: EdgeInsets.symmetric(
                  horizontal: cornerBadge ? 6 : 8,
                  vertical: 6,
                ),
                shape: shape.copyWith(side: BorderSide.none),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top:
                          count > 0 && cornerBadge
                              ? math.max(0, textScaler.scale(11) - 11)
                              : 0,
                    ),
                    child:
                        stacked
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [illustration, title],
                            )
                            : Row(
                              spacing: cornerBadge ? 5 : 7,
                              children: [
                                illustration,
                                Expanded(child: title),
                                if (count > 0 && !cornerBadge) badge,
                              ],
                            ),
                  ),
                  if (count > 0 && cornerBadge)
                    PositionedDirectional(
                      top: -5,
                      start: stacked ? null : 0,
                      end: stacked ? 0 : null,
                      child: badge,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapAction extends StatelessWidget {
  const _MapAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: _paper,
      foregroundColor: _son,
      side: const BorderSide(color: _son),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      elevation: 3,
      shadowColor: const Color(0x40352C23),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            formatGameNumbers(label),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Lora', fontSize: 15),
          ),
        ),
      ],
    ),
  );
}
