import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'imperial_assets.dart';
import 'imperial_room.dart';
import 'imperial_theme.dart';
import 'imperial_widgets.dart';

/// Dialog routes also open from contexts above the room's local Theme.
/// Apply the same painted controls explicitly inside every popup.
class _PopupTheme extends StatelessWidget {
  const _PopupTheme({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ImperialRoomScope(
    child: Theme(
      data: roomTheme(context).copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: roomTheme(context).filledButtonTheme.style?.copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.disabled) ? muted : imperialIvory,
            ),
            backgroundBuilder:
                (context, states, child) => ImperialSkin(
                  asset:
                      states.contains(WidgetState.disabled)
                          ? 'ivory'
                          : 'crimson',
                  edge: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: child,
                  ),
                ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: imperialIvory,
            textStyle: const TextStyle(fontFamily: 'Lora', fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundBuilder: imperialButtonLayer,
          ),
        ),
      ),
      child: child,
    ),
  );
}

class ImperialAlertDialog extends StatelessWidget {
  const ImperialAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [],
    this.insetPadding,
    this.icon = 'scroll',
    this.width = 660,
  });
  final Widget title;
  final Widget? content;
  final List<Widget> actions;
  final EdgeInsets? insetPadding;
  final String icon;
  final double width;

  @override
  Widget build(BuildContext context) => _PopupTheme(
    child: AlertDialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.none,
      insetPadding:
          insetPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      contentPadding: EdgeInsets.zero,
      content: _DialogSurface(
        title: title,
        body: _unwrapScroll(content ?? const SizedBox.shrink()),
        actions: actions,
        icon: icon,
        width: width,
      ),
    ),
  );
}

class ImperialSimpleDialog extends StatelessWidget {
  const ImperialSimpleDialog({
    super.key,
    required this.title,
    this.children = const [],
    this.insetPadding,
    this.icon = 'people',
    this.width = 720,
  });
  final Widget title;
  final List<Widget> children;
  final EdgeInsets? insetPadding;
  final String icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final hasClosingButton =
        children.isNotEmpty && children.last is ButtonStyleButton;
    return _PopupTheme(
      child: SimpleDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        insetPadding:
            insetPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        contentPadding: EdgeInsets.zero,
        children: [
          _DialogSurface(
            title: title,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  hasClosingButton
                      ? children.sublist(0, children.length - 1)
                      : children,
            ),
            actions:
                hasClosingButton
                    ? [children.last]
                    : [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
            icon: icon,
            width: width,
          ),
        ],
      ),
    );
  }
}

// Existing content sometimes already supplies a scroll view and fixed width.
// The shared body owns scrolling so its header and footer never scroll away.
Widget _unwrapScroll(Widget child) {
  if (child is SingleChildScrollView) return _unwrapScroll(child.child!);
  if (child is SizedBox && child.height == null && child.child != null) {
    return _unwrapScroll(child.child!);
  }
  return child;
}

class _DialogSurface extends StatefulWidget {
  const _DialogSurface({
    required this.title,
    required this.body,
    required this.actions,
    required this.icon,
    required this.width,
  });
  final Widget title, body;
  final List<Widget> actions;
  final String icon;
  final double width;

  @override
  State<_DialogSurface> createState() => _DialogSurfaceState();
}

class _DialogSurfaceState extends State<_DialogSurface> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compact = media.size.width < 600 || media.size.height < 500;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: math.max(
          120,
          media.size.height -
              media.viewInsets.bottom -
              media.padding.vertical -
              64,
        ),
      ),
      child: SizedBox(
        width: widget.width,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ImperialSkin(
            edge: compact ? 32 : 44,
            child: Padding(
              padding: EdgeInsets.all(compact ? 20 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    key: const ValueKey('imperial-dialog-header'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!compact && widget.title is! Row) ...[
                        ImperialIcon(widget.icon, size: 44),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Semantics(
                          namesRoute: true,
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: compact ? 20 : 24,
                              height: 1.3,
                              color: ink,
                            ),
                            child: widget.title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        key: const ValueKey('close-imperial-dialog'),
                        tooltip: 'Đóng hộp thoại',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.close, color: gold, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: gold),
                  Flexible(
                    child: Scrollbar(
                      controller: _scroll,
                      thumbVisibility: !compact,
                      child: SingleChildScrollView(
                        key: const ValueKey('imperial-dialog-scroll'),
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(0, 18, 8, 18),
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: ink,
                          ),
                          child: widget.body,
                        ),
                      ),
                    ),
                  ),
                  if (widget.actions.isNotEmpty) ...[
                    const Divider(height: 1, color: line),
                    const SizedBox(height: 12),
                    Wrap(
                      key: const ValueKey('imperial-dialog-actions'),
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 8,
                      children: widget.actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A readable, bounded choice card, including disabled and keyboard states.
class ImperialDialogOption extends StatelessWidget {
  const ImperialDialogOption({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Opacity(
      opacity: onPressed == null ? .62 : 1,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9E9), Color(0xFFF2E2C1)],
            ),
            border: Border.all(color: const Color(0xFFCAAA70)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1270481D),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SimpleDialogOption(
            padding: const EdgeInsets.all(14),
            onPressed: onPressed,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(child: child),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: gold, size: 18),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
