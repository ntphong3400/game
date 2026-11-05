import 'package:flutter/material.dart';
import '../../models/number_format.dart';
import '../../models/game_state.dart';
import 'hud_policy.dart';
import '../music/music_scope.dart';

const _jade = Color(0xFF16372F);
const _deep = Color(0xFF102922);
const _gold = Color(0xFFD9B873);
const _ivory = Color(0xFFFFF1CE);

/// Navigation, calendar and remaining actions shared by every game page.
class WebGameHud extends StatelessWidget {
  const WebGameHud({
    super.key,
    required this.state,
    required this.onNavigate,
    required this.section,
    this.title,
    this.onBack,
    this.backLabel,
    this.backKey = const ValueKey('section-back'),
  });

  final GameState state;
  final ValueChanged<String> onNavigate;
  final String section;
  final String? title, backLabel;
  final VoidCallback? onBack;
  final Key backKey;

  @override
  Widget build(BuildContext context) {
    final parent = hudParentFor(section);
    return GameTopBar(
      key: const ValueKey('web-game-hud'),
      title: title ?? hudTitleFor(state, section),
      titleAtStart: section == 'citadel',
      backLabel:
          backLabel ?? (parent == null ? null : hudTitleFor(state, parent)),
      onBack: onBack ?? (parent == null ? null : () => onNavigate(parent)),
      backKey: backKey,
      calendar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _fitText(
            state.seasonal ? 'Mùa ${state.season}' : 'Tuần ${state.week}',
            key: const ValueKey('room-calendar'),
            size: 15,
            color: _ivory,
          ),
          const SizedBox(height: 3),
          _fitText('Thiên Hòa · năm ${state.year}', size: 10, color: _gold),
          const SizedBox(height: 3),
          _fitText(
            section == 'citadel'
                ? 'Còn ${state.points} hành động'
                : '${state.points} hành động còn lại',
            key: const ValueKey('hud-actions-remaining'),
            size: section == 'citadel' ? 12 : 10,
            color: _ivory,
          ),
        ],
      ),
    );
  }
}

/// Child pages center their title; the Giang Sơn overview uses a leading title.
class GameTopBar extends StatelessWidget {
  const GameTopBar({
    super.key,
    required this.title,
    this.backLabel,
    this.onBack,
    this.calendar,
    this.backKey = const ValueKey('section-back'),
    this.titleAtStart = false,
  });

  final String title;
  final String? backLabel;
  final VoidCallback? onBack;
  final Widget? calendar;
  final Key backKey;
  final bool titleAtStart;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 60),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [_deep, _jade, _deep]),
      image: DecorationImage(
        image: AssetImage('assets/images/imperial/jade-texture.webp'),
        fit: BoxFit.cover,
        opacity: .22,
      ),
      border: Border(bottom: BorderSide(color: _gold)),
    ),
    child: Row(
      children: [
        if (titleAtStart) ...[
          Expanded(
            child: _fitText(
              title,
              key: const ValueKey('hud-page-title'),
              size: 23,
              color: _ivory,
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(width: 12),
        ] else ...[
          Expanded(
            flex: 3,
            child:
                onBack == null
                    ? const SizedBox.shrink()
                    : Tooltip(
                      message: backLabel ?? '',
                      child: TextButton(
                        key: backKey,
                        onPressed: onBack,
                        style: TextButton.styleFrom(
                          foregroundColor: _gold,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 48),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back, size: 18),
                            const SizedBox(width: 5),
                            Flexible(
                              child: _fitText(
                                backLabel ?? '',
                                size: 13,
                                color: _gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _fitText(
                title,
                key: const ValueKey('hud-page-title'),
                size: 18,
                color: _ivory,
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
        Expanded(
          flex: titleAtStart ? 1 : 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: calendar ?? const SizedBox.shrink()),
              const MusicToggle(),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _fitText(
  String value, {
  Key? key,
  required double size,
  required Color color,
  Alignment alignment = Alignment.centerRight,
}) => FittedBox(
  fit: BoxFit.scaleDown,
  alignment: alignment,
  child: Text(
    formatGameNumbers(value),
    key: key,
    maxLines: 1,
    style: TextStyle(
      fontFamily: 'Lora',
      fontSize: size,
      height: 1.2,
      color: color,
    ),
  ),
);
