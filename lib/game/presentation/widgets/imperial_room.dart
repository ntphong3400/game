import '../../models/number_format.dart';
import 'web_game_hud.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';
import 'imperial_assets.dart';

/// A shared paper workspace keeps each tab inside one frame at the stage edges.
class RoomStage extends StatelessWidget {
  const RoomStage({
    super.key,
    required this.scene,
    required this.title,
    required this.child,
  });
  final String scene, title;
  final Widget child;

  String get label => switch (scene) {
    'court' => 'TRIỀU CHÍNH · NGỰ THƯ PHÒNG',
    'kingdom' => 'QUỐC SỰ',
    'treasury' => 'NGÂN KHỐ',
    'population' => 'DÂN CƯ & LAO ĐỘNG',
    'military' => 'QUÂN SỰ',
    'harem' => 'HẬU CUNG',
    'people' => 'TRIỀU THẦN',
    'health' => 'LONG THỂ',
    'journal' => 'SỬ KÝ',
    'scores' => 'BẢNG XẾP HẠNG',
    _ when scene.startsWith('frontier-') => 'BIÊN CƯƠNG',
    _ when scene.startsWith('country-') => 'LÂN BANG',
    _ when scene.startsWith('local-') => 'ĐỊA PHƯƠNG',
    _ => '',
  };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final compact = bounds.maxWidth < 760;
      final dense = bounds.maxHeight < 360;
      return ColoredBox(
        color: parchment,
        child: ImperialWorkspace(
          padding: 8,
          flushEdges: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                key: ValueKey('scene-header-$scene'),
                padding: EdgeInsets.only(bottom: dense ? 10 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!dense) ...[
                      Text(
                        formatGameNumbers(label),
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      formatGameNumbers(title),
                      style: TextStyle(
                        fontFamily: 'Lora',
                        color: forest,
                        fontSize: dense ? 17 : (compact ? 21 : 25),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: KeyedSubtree(key: ValueKey(scene), child: child)),
            ],
          ),
        ),
      );
    },
  );
}

class ImperialWorkspace extends StatelessWidget {
  const ImperialWorkspace({
    super.key,
    required this.child,
    this.padding = 16,
    this.flushEdges = false,
  });
  final Widget child;
  final double padding;
  final bool flushEdges;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0x99000000),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: ImperialSkin(
      edge: 46,
      flushEdges: flushEdges,
      child: Padding(padding: EdgeInsets.all(padding + 13), child: child),
    ),
  );
}

/// Independent scroll panes keep the shared HUD and end-turn controls visible.
class RoomPane extends StatelessWidget {
  const RoomPane({
    super.key,
    required this.child,
    this.controller,
    this.padding = 14,
  });
  final Widget child;
  final ScrollController? controller;
  final double padding;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, bounds) => SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.all(padding),
          child: child,
        ),
  );
}

class RoomPlaque extends StatelessWidget {
  const RoomPlaque({
    super.key,
    required this.label,
    this.value,
    this.warning = false,
  });
  final String label;
  final String? value;
  final bool warning;
  @override
  Widget build(BuildContext context) => ImperialSkin(
    asset: 'jade',
    edge: 24,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatGameNumbers(label),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lora',
              color: imperialIvory,
              fontSize: value == null ? 17 : 13,
              height: 1.2,
            ),
          ),
          if (value != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatGameNumbers(value!),
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 32,
                  height: 1.2,
                  color: warning ? const Color(0xFFFFA88D) : imperialIvory,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// A contextual header shared by interior screens on every viewport.
class RoomHud extends StatelessWidget {
  const RoomHud({
    super.key,
    required this.state,
    required this.section,
    required this.onNavigate,
    this.onBack,
    this.backLabel = 'Về Kinh Thành',
  });
  final GameState state;
  final String section, backLabel;
  final VoidCallback? onBack;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) => WebGameHud(
    state: state,
    section: section,
    onNavigate: onNavigate,
    onBack: onBack,
    backLabel: backLabel,
  );
}

class TreasuryObject extends StatelessWidget {
  const TreasuryObject({
    super.key,
    required this.index,
    this.width = 180,
    this.height = 120,
  });
  final int index;
  final double width, height;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: LayoutBuilder(
      builder: (context, bounds) {
        final side = math.min(bounds.maxWidth, bounds.maxHeight);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: ClipRect(
              key: ValueKey('treasury-sprite-$index'),
              child: Stack(
                children: [
                  Positioned(
                    left: -index * side,
                    top: 0,
                    width: side * 3,
                    height: side,
                    child: Image.asset(
                      'assets/images/treasury-objects.webp',
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

ThemeData roomTheme(BuildContext context) => Theme.of(context).copyWith(
  textTheme: Theme.of(
    context,
  ).textTheme.apply(bodyColor: ink, displayColor: ink),
  chipTheme: Theme.of(context).chipTheme.copyWith(
    backgroundColor: const Color(0xFFF7E7C9),
    selectedColor: const Color(0xFF214B3D),
    side: const BorderSide(color: Color(0xFFBD9754)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    labelStyle: const TextStyle(fontFamily: 'Lora', color: ink),
    secondaryLabelStyle: const TextStyle(
      fontFamily: 'Lora',
      color: imperialIvory,
    ),
    checkmarkColor: imperialIvory,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ink,
      backgroundColor: Colors.transparent,
      side: BorderSide.none,
      textStyle: const TextStyle(
        fontFamily: 'Lora',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
      backgroundBuilder:
          (context, states, child) =>
              imperialButtonLayer(context, states, child, asset: 'ivory'),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: imperialIvory,
      disabledBackgroundColor: Colors.transparent,
      side: BorderSide.none,
      textStyle: const TextStyle(
        fontFamily: 'Lora',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      backgroundBuilder:
          (context, states, child) =>
              imperialButtonLayer(context, states, child, asset: 'crimson'),
    ),
  ),
);
