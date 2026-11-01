import '../../models/number_format.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/game_state.dart';

const imperialJade = Color(0xFF16372F);
const imperialDeep = Color(0xFF102922);
const imperialGold = Color(0xFFD9B873);
const imperialIvory = Color(0xFFFFF1CE);

class PalaceSceneHeader extends StatelessWidget {
  const PalaceSceneHeader({
    super.key,
    required this.scene,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    this.trailing,
  });
  final String scene, title, subtitle, eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('scene-header-$scene'),
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 22),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFAC8549)),
      color: imperialJade,
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/$scene-interior.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(.3, -.1),
            excludeFromSemantics: true,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xF0102922),
                  Color(0xB0102922),
                  Color(0x10102922),
                ],
                stops: [0, .45, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: LayoutBuilder(
            builder:
                (context, bounds) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatGameNumbers(eyebrow.toUpperCase()),
                      style: const TextStyle(
                        color: imperialGold,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      formatGameNumbers(title),
                      style: TextStyle(
                        color: imperialIvory,
                        fontFamily: 'Lora',
                        fontSize: bounds.maxWidth < 500 ? 26 : 34,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        formatGameNumbers(subtitle),
                        style: const TextStyle(
                          color: imperialIvory,
                          fontSize: 12,
                          height: 1.8,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 16),
                      trailing!,
                    ],
                  ],
                ),
          ),
        ),
      ],
    ),
  );
}

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    this.person,
    this.emperor = false,
    this.emperorAge = 18,
    this.width = 88,
    this.height = 108,
  });
  final Courtier? person;
  final bool emperor;
  final int emperorAge;
  final double width, height;

  String get portraitId =>
      emperor ? emperorPortraitId : person!.resolvedPortraitId;
  PortraitAge get portraitAge =>
      portraitAgeFor(emperor ? emperorAge : person!.age);

  @override
  Widget build(BuildContext context) {
    final stage = portraitAge;
    return Semantics(
      image: true,
      label: formatGameNumbers(
        emperor
            ? 'Chân dung hoàng đế · ${stage.label}'
            : 'Chân dung ${person!.name} · ${stage.label}',
      ),
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE7D8BA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFB89559)),
        ),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final side = math.max(bounds.maxWidth, bounds.maxHeight);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: bounds.maxWidth / 2 - (stage.index + .5) * side,
                  top: (bounds.maxHeight - side) / 2,
                  width: side * 3,
                  height: side,
                  child: Image.asset(
                    portraitAsset(portraitId),
                    key: ValueKey('$portraitId-${stage.name}'),
                    fit: BoxFit.fill,
                    cacheWidth: 1152,
                    excludeFromSemantics: true,
                    gaplessPlayback: true,
                    errorBuilder:
                        (_, _, _) => Row(
                          children: List.generate(
                            3,
                            (_) => const Expanded(
                              child: ColoredBox(
                                color: Color(0xFFE7D8BA),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: imperialJade,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ImperialResource extends StatelessWidget {
  const ImperialResource({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.warning = false,
  });
  final String label, value, detail;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E8),
      border: Border.all(color: const Color(0xFFD7BF91)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF0E2C4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 27, color: const Color(0xFF9F783B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(label),
                style: const TextStyle(fontSize: 12, color: Color(0xFF796747)),
              ),
              Text(
                formatGameNumbers(value),
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 30,
                  color: warning ? const Color(0xFF9B362E) : imperialJade,
                ),
              ),
              Text(
                formatGameNumbers(detail),
                style: const TextStyle(fontSize: 11, color: Color(0xFF796747)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ImperialSplit extends StatelessWidget {
  const ImperialSplit({
    super.key,
    required this.main,
    required this.aside,
    this.breakpoint = 900,
    this.asideWidth = 300,
  });
  final Widget main, aside;
  final double breakpoint, asideWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, bounds) =>
            bounds.maxWidth < breakpoint
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [main, const SizedBox(height: 22), aside],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: main),
                    const SizedBox(width: 22),
                    SizedBox(width: asideWidth, child: aside),
                  ],
                ),
  );
}
