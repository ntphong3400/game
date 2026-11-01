import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_theme.dart';
import 'petition_art.dart';
import 'memorial_paper.dart';

/// A memorial is opened by selecting the paper, never approved from this list.
class PetitionDocument extends StatelessWidget {
  const PetitionDocument({
    super.key,
    required this.readKey,
    required this.title,
    required this.category,
    required this.deadline,
    required this.selected,
    required this.urgent,
    required this.onOpen,
  });
  final Key readKey;
  final String title, category, deadline;
  final bool selected, urgent;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Semantics(
      button: true,
      selected: selected,
      enabled: onOpen != null,
      onTap: onOpen,
      label: formatGameNumbers(
        'Bản tấu: $title. $category. $deadline. Chờ ngự phê.',
      ),
      child: MemorialPaper(
        readKey: readKey,
        onOpen: onOpen,
        child: ExcludeSemantics(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 12,
                  margin: const EdgeInsets.fromLTRB(9, 9, 0, 9),
                  decoration: BoxDecoration(
                    color: selected ? forest : Colors.transparent,
                    border:
                        selected
                            ? const Border.symmetric(
                              vertical: BorderSide(color: gold),
                            )
                            : null,
                    image:
                        selected
                            ? const DecorationImage(
                              image: AssetImage(
                                'assets/images/imperial/jade-texture.webp',
                              ),
                              fit: BoxFit.cover,
                              opacity: .3,
                            )
                            : null,
                  ),
                  child:
                      selected
                          ? const Center(
                            child: Icon(
                              Icons.filter_vintage_outlined,
                              size: 10,
                              color: Color(0xFFD9B873),
                            ),
                          )
                          : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 18, 15, 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 115,
                          child: PetitionPainting(
                            category: category,
                            thumbnail: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatGameNumbers(
                                  selected ? 'ĐANG NGỰ LÃM' : 'KÍNH TRÌNH',
                                ),
                                style: TextStyle(
                                  fontFamily: 'BeVietnam',
                                  fontSize: 9,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? forest : muted,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                formatGameNumbers(title),
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 16,
                                  height: 1.45,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formatGameNumbers(category),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    formatGameNumbers(deadline),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: urgent ? terracotta : muted,
                                    ),
                                  ),
                                  const PendingMemorialNote(),
                                ],
                              ),
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
        ),
      ),
    ),
  );
}
