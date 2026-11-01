import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../meeting_scenes.dart';
import 'imperial_theme.dart';

/// Same public, capped contribution preview on roster cards and meeting pages.
class PersonnelPassives extends StatelessWidget {
  const PersonnelPassives({
    super.key,
    required this.person,
    required this.state,
  });
  final Courtier person;
  final GameState state;
  @override
  Widget build(BuildContext context) {
    final entries = personMeetingContributions(person, state);
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      key: ValueKey('roster-passives-${person.id}'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: forest.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          entry.active
                              ? Icons.circle
                              : Icons.radio_button_unchecked,
                          size: 9,
                          color: entry.active ? forest : muted,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          formatGameNumbers(entry.summary),
                          style: TextStyle(
                            fontSize: 11,
                            color: entry.active ? forest : muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          for (final status
              in entries
                  .where((entry) => !entry.active)
                  .map((entry) => entry.status)
                  .toSet())
            Text(
              formatGameNumbers(status),
              style: const TextStyle(fontSize: 10, color: muted),
            ),
        ],
      ),
    );
  }
}
