import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A finite roster whose cards all use the tallest natural card height.
/// Measure at the actual column width so wrapped text and text scaling count.
class EqualHeightGrid extends MultiChildRenderObjectWidget {
  const EqualHeightGrid({
    super.key,
    required this.columns,
    this.spacing = 14,
    required super.children,
  }) : assert(columns > 0),
       assert(spacing >= 0);

  final int columns;
  final double spacing;

  @override
  RenderBox createRenderObject(BuildContext context) => _RenderEqualHeightGrid(
    columns: columns,
    spacing: spacing,
    direction: Directionality.of(context),
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBox renderObject,
  ) {
    final grid = renderObject as _RenderEqualHeightGrid;
    grid
      ..columns = columns
      ..spacing = spacing
      ..direction = Directionality.of(context);
  }
}

class _EqualHeightGridParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightGridParentData> {
  _RenderEqualHeightGrid({
    required int columns,
    required double spacing,
    required TextDirection direction,
  }) : _columns = columns,
       _spacing = spacing,
       _direction = direction;

  int _columns;
  double _spacing;
  TextDirection _direction;

  set columns(int value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  set direction(TextDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightGridParentData) {
      child.parentData = _EqualHeightGridParentData();
    }
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth, 'Roster grids need a finite width.');
    final width = constraints.maxWidth;
    final cardWidth = math.max(
      0.0,
      (width - (_columns - 1) * _spacing) / _columns,
    );
    var tallest = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: cardWidth),
        parentUsesSize: true,
      );
      tallest = math.max(tallest, child.size.height);
      child = childAfter(child);
    }
    final rows = (childCount / _columns).ceil();
    size = constraints.constrain(
      Size(width, rows == 0 ? 0 : rows * tallest + (rows - 1) * _spacing),
    );
    // Leave height unbounded above so content changes still invalidate this
    // parent's measurements instead of stopping at a tight relayout boundary.
    final cardConstraints = BoxConstraints.tightFor(
      width: cardWidth,
    ).copyWith(minHeight: tallest);
    var index = 0;
    child = firstChild;
    while (child != null) {
      child.layout(cardConstraints, parentUsesSize: true);
      final column = index % _columns;
      final left = column * (cardWidth + _spacing);
      (child.parentData! as _EqualHeightGridParentData).offset = Offset(
        _direction == TextDirection.rtl ? width - cardWidth - left : left,
        (index ~/ _columns) * (tallest + _spacing),
      );
      index++;
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
