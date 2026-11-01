import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_theme.dart';
import 'memorial_paper.dart';

String kingdomDossierAsset(int section) =>
    'assets/images/kingdom/dossier-${switch (section) {
      1 => 'progress',
      2 => 'obligations',
      3 => 'emergency',
      _ => 'reports',
    }}.webp';

class KingdomDossierPainting extends StatelessWidget {
  const KingdomDossierPainting({super.key, required this.section});
  final int section;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback:
        (rect) => const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0, .06, .8, 1],
        ).createShader(rect),
    child: Image.asset(
      kingdomDossierAsset(section),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    ),
  );
}

/// A live document row, rather than a screenshot: all data and hit targets
/// remain native. The art is decorative and excluded from accessibility.
class KingdomDossier extends StatelessWidget {
  const KingdomDossier({
    super.key,
    required this.section,
    required this.title,
    required this.badge,
    required this.summary,
    required this.preview,
    required this.onOpen,
  });
  final int section;
  final String title, badge, summary;
  final Widget preview;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final short = bounds.maxHeight < 110;
      final small = bounds.maxHeight < 96;
      final enlargedText = MediaQuery.textScalerOf(context).scale(14) > 17;
      final showPreview = !short && !enlargedText;
      final accent = section == 3 ? terracotta : forest;
      return MemorialPaper(
        readKey: ValueKey('kingdom-dossier-paper-$section'),
        child: TextButton(
          key: ValueKey('kingdom-open-$section'),
          onPressed: onOpen,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: ink,
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(fontFamily: 'BeVietnam'),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: (bounds.maxWidth * .3).clamp(64.0, 145.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                  child: KingdomDossierPainting(section: section),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    5,
                    small ? 7 : 11,
                    12,
                    small ? 7 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              formatGameNumbers(title),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: small ? 12 : 15,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (!small)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                formatGameNumbers(badge),
                                key: ValueKey('kingdom-count-$section'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: muted,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 16, color: accent),
                        ],
                      ),
                      if (showPreview) ...[
                        const SizedBox(height: 7),
                        Expanded(child: preview),
                      ] else if (!small) ...[
                        const SizedBox(height: 5),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              formatGameNumbers(summary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mở sổ',
                              style: TextStyle(
                                fontSize: 11,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 15, color: accent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
