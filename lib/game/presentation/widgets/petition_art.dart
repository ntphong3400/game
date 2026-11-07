import 'package:flutter/material.dart';
import 'imperial_assets.dart';
import 'imperial_theme.dart';

String petitionArtFor(String category) => switch (category) {
  'Nông nghiệp' || 'Thiên tai' || 'Sức khỏe' => 'agriculture',
  'Thương mại' || 'Ngân khố' => 'trade',
  'Dân sinh' || 'Công trình' || 'Quân sự' => 'river',
  _ => 'palace',
};

Widget petitionCategoryIcon(String category, {Color color = muted}) =>
    switch (category) {
      'Nông nghiệp' => const ImperialIcon('grain', size: 22),
      'Thương mại' || 'Ngân khố' => const ImperialIcon('treasury', size: 22),
      'Quân sự' => const ImperialIcon('army', size: 22),
      'Dân sinh' => const ImperialIcon('people', size: 22),
      'Sức khỏe' => const ImperialIcon('health', size: 22),
      'Triều chính' => const ImperialIcon('court', size: 22),
      'Hậu cung' => const ImperialIcon('harem', size: 22),
      'Công trình' || 'Thiên tai' => const ImperialIcon('levee', size: 22),
      _ => const ImperialIcon('decision', size: 22),
    };

class PetitionPainting extends StatelessWidget {
  const PetitionPainting({
    super.key,
    required this.category,
    this.thumbnail = false,
  });
  final String category;
  final bool thumbnail;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback:
        (rect) => LinearGradient(
          begin: thumbnail ? Alignment.centerLeft : Alignment.topCenter,
          end: thumbnail ? Alignment.centerRight : Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0, .08, .82, 1],
        ).createShader(rect),
    child: Image.asset(
      'assets/images/petitions/${petitionArtFor(category)}.webp',
      fit: BoxFit.cover,
      alignment: thumbnail ? const Alignment(-.65, 0) : Alignment.center,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.medium,
    ),
  );
}

class PetitionRule extends StatelessWidget {
  const PetitionRule({super.key});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Container(height: 1, color: line)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Icon(Icons.filter_vintage_outlined, size: 15, color: gold),
      ),
      Expanded(child: Container(height: 1, color: line)),
    ],
  );
}
