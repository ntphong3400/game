import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Imperial icons stay decorative; labels and hit targets remain native.
class ImperialIcon extends StatelessWidget {
  const ImperialIcon(this.name, {super.key, this.size = 40});
  final String name;
  final double size;

  static const names = [
    'citadel',
    'court',
    'kingdom',
    'treasury',
    'people',
    'harem',
    'health',
    'journal',
    'scores',
    'citizens',
    'authority',
    'army',
    'stability',
    'grain',
    'scroll',
    'time',
  ];

  @override
  Widget build(BuildContext context) {
    if (name == 'action') {
      return ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: const CustomPaint(painter: _ActionIconPainter()),
        ),
      );
    }
    final index = names.indexOf(switch (name) {
      'population' => 'citizens',
      'military' => 'army',
      _ => name,
    });
    assert(index >= 0, 'Unknown imperial icon: $name');
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: -(index % 4) * size,
                top: -(index ~/ 4) * size,
                width: size * 4,
                height: size * 4,
                child: Image.asset(
                  'assets/images/imperial/icons.webp',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIconPainter extends CustomPainter {
  const _ActionIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.translate(12, 12);
    canvas.rotate(-0.18);
    canvas.translate(-12, -12);

    final tablet =
        Path()
          ..moveTo(9, 2)
          ..quadraticBezierTo(12, 0.7, 15, 2)
          ..quadraticBezierTo(15.5, 4.2, 18.5, 4.5)
          ..lineTo(18, 18.5)
          ..quadraticBezierTo(17.5, 21.3, 12, 22.2)
          ..quadraticBezierTo(6.5, 21.3, 6, 18.5)
          ..lineTo(5.5, 4.5)
          ..quadraticBezierTo(8.5, 4.2, 9, 2)
          ..close();
    final bounds = tablet.getBounds();
    canvas.drawPath(
      tablet,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFA54225), Color(0xFF54200D), Color(0xFF79301A)],
        ).createShader(bounds),
    );
    canvas.drawPath(
      tablet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF603510),
    );
    canvas.drawPath(
      tablet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFDF86), Color(0xFF9B5A1D), Color(0xFFECC15A)],
        ).createShader(bounds),
    );
    final engraving =
        Path()
          ..moveTo(8.3, 12.3)
          ..lineTo(12, 8.4)
          ..lineTo(15.7, 12.3)
          ..moveTo(11.4, 11.9)
          ..lineTo(12.8, 12.8)
          ..moveTo(9.6, 14.3)
          ..lineTo(14.5, 14.3)
          ..lineTo(12.6, 16.7)
          ..moveTo(11, 16.2)
          ..lineTo(13.1, 18.3);
    canvas.drawPath(
      engraving,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFFD77C),
    );
    canvas.drawCircle(
      const Offset(12, 4.9),
      0.9,
      Paint()..color = const Color(0xFFECC15A),
    );
  }

  @override
  bool shouldRepaint(covariant _ActionIconPainter oldDelegate) => false;
}

/// Nine-slice raster art preserves the carved corners at every panel size.
class ImperialSkin extends StatefulWidget {
  const ImperialSkin({
    super.key,
    this.asset = 'panel',
    this.edge = 34,
    this.child,
    this.flushEdges = false,
  });
  final String asset;
  final double edge;
  final Widget? child;
  final bool flushEdges;

  @override
  State<ImperialSkin> createState() => _ImperialSkinState();
}

class _ImperialSkinState extends State<ImperialSkin> {
  ImageStream? _stream;
  ImageInfo? _image;
  late final _listener = ImageStreamListener((image, _) {
    final previous = _image;
    setState(() => _image = image);
    previous?.dispose();
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(ImperialSkin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  void _resolve() {
    final next = AssetImage(
      'assets/images/imperial/${widget.asset}.webp',
    ).resolve(createLocalImageConfiguration(context));
    if (next.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = next..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter:
        _image == null
            ? null
            : _SkinPainter(_image!, widget.edge, widget.flushEdges),
    child: widget.child,
  );
}

class _SkinPainter extends CustomPainter {
  _SkinPainter(this.info, this.edge, this.flushEdges);
  final ImageInfo info;
  final double edge;
  final bool flushEdges;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final image = info.image;
    final plaque = image.width > image.height * 3;
    final sliceX = image.width * (plaque ? .24 : .22);
    final sliceY = image.height * (plaque ? .35 : .33);
    final scaleX =
        math.min(edge * (plaque ? 1.65 : 1), size.width / 2) / sliceX;
    final scaleY = math.min(edge, size.height / 2) / sliceY;
    final width = size.width / scaleX;
    final height = size.height / scaleY;
    // The panel's transparent outer margins are measured in source pixels.
    // Keep layout and content padding unchanged; trim only the painted frame.
    final insets =
        flushEdges
            ? EdgeInsets.fromLTRB(
              image.width * 35 / 1536,
              image.height * 44 / 1024,
              image.width * 34 / 1536,
              image.height * 49 / 1024,
            )
            : EdgeInsets.zero;
    canvas.save();
    canvas.scale(scaleX, scaleY);
    if (flushEdges) canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    canvas.drawImageNine(
      image,
      Rect.fromLTRB(
        sliceX,
        sliceY,
        image.width - sliceX,
        image.height - sliceY,
      ),
      Rect.fromLTRB(
        -insets.left,
        -insets.top,
        width + insets.right,
        height + insets.bottom,
      ),
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkinPainter old) =>
      old.info != info || old.edge != edge || old.flushEdges != flushEdges;
}

Widget imperialButtonLayer(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child, {
  String asset = 'jade',
}) => Opacity(
  opacity: states.contains(WidgetState.disabled) ? .45 : 1,
  child: ImperialSkin(
    asset: asset,
    edge: 16,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    ),
  ),
);
