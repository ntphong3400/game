import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_assets.dart';

const parchment = Color(0xFFF2E9D8);
const paper = Color(0xFFFFF9ED);
const ink = Color(0xFF352F25);
const muted = Color(0xFF786D58);
const forest = Color(0xFF214B3D);
const gold = Color(0xFFA77F40);
const line = Color(0xFFE0CFAD);
const terracotta = Color(0xFFA23E32);

class ImperialRoomScope extends InheritedWidget {
  const ImperialRoomScope({super.key, required super.child});
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ImperialRoomScope>() != null;
  @override
  bool updateShouldNotify(ImperialRoomScope oldWidget) => false;
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = 22,
    this.selected = false,
  });
  final Widget child;
  final double padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final room = ImperialRoomScope.of(context);
    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(room && padding > 16 ? 16 : padding),
      decoration: BoxDecoration(
        color: room ? const Color(0x66FFFAE9) : paper,
        image:
            room
                ? const DecorationImage(
                  image: AssetImage('assets/images/imperial/parchment.webp'),
                  fit: BoxFit.cover,
                  opacity: .45,
                )
                : null,
        border: Border.all(
          color:
              selected
                  ? gold
                  : room
                  ? const Color(0x55B58C48)
                  : line,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(room ? 12 : 7),
        boxShadow:
            room
                ? const [
                  BoxShadow(
                    color: Color(0x14704719),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
                : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
      ),
      child: child,
    );
    return room && selected
        ? ImperialSkin(asset: 'ivory', edge: 16, child: content)
        : content;
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = gold});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      formatGameNumbers(text),
      style: TextStyle(
        fontSize: 9,
        letterSpacing: .7,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
