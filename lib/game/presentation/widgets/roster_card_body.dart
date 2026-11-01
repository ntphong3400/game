import 'package:flutter/widgets.dart';

/// Natural height while measuring, with spare card height above the action.
/// Works with EqualHeightGrid's minimum height without an unbounded Spacer.
class RosterCardBody extends StatelessWidget {
  const RosterCardBody({
    super.key,
    required this.children,
    required this.action,
  });
  final List<Widget> children;
  final Widget action;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
      Padding(padding: const EdgeInsets.only(top: 8), child: action),
    ],
  );
}
