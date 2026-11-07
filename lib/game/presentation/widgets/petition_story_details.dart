import 'package:flutter/material.dart';
import '../../data/content.dart';
import '../../data/story_petitions.dart';
import '../../data/expanded_events.dart' show eventEffectText;
import '../../logic/chain_settlement_rules.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'imperial_theme.dart';
import 'petition_art.dart';

String petitionExpiryWarning(GameState state, Petition petition) {
  if (petition.storyKind == 'major') {
    return 'Quá hạn sẽ không tổ chức ứng phó phần việc này.';
  }
  final arc = state.chains.where((a) => a.id == petition.storyId).firstOrNull;
  if (arc != null && usesChainSettlement(arc)) {
    return 'Quá hạn sẽ khép hồ sơ theo phần đã thực hiện.';
  }
  return 'Quá hạn: Áp dụng lựa chọn cuối cùng.';
}

class PetitionMetadata extends StatelessWidget {
  const PetitionMetadata({
    super.key,
    required this.state,
    required this.petition,
  });

  final GameState state;
  final Petition petition;

  @override
  Widget build(BuildContext context) {
    final category = eventForState(state, petition.definitionId).category;
    final arc = state.chains.where((a) => a.id == petition.storyId).firstOrNull;
    final major =
        petition.storyKind == 'major' && state.major?.id == petition.storyId
            ? state.major
            : null;
    final stageLabel =
        arc != null
            ? chainStageLabel(arc)
            : major != null
            ? majorStageLabel(major)
            : null;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        petitionCategoryIcon(category, color: forest),
        Text(
          formatGameNumbers(category.toUpperCase()),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1,
            color: forest,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (stageLabel != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('·', style: TextStyle(color: muted)),
              const SizedBox(width: 12),
              Text(
                stageLabel,
                key: ValueKey(
                  arc != null ? 'chain-stage-label' : 'major-stage-label',
                ),
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stageLabel != null) ...[
              const Text('·', style: TextStyle(color: muted)),
              const SizedBox(width: 12),
            ],
            Text(
              formatGameNumbers(
                petition.deadline <= state.week
                    ? 'Hạn: cuối ${state.periodName} này'
                    : 'Còn ${petition.deadline - state.week + 1} ${state.periodName}',
              ),
              key: const ValueKey('petition-deadline'),
              style: const TextStyle(color: terracotta, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class StoryPetitionHistory extends StatelessWidget {
  const StoryPetitionHistory({
    super.key,
    required this.state,
    required this.petition,
  });

  final GameState state;
  final Petition petition;

  @override
  Widget build(BuildContext context) {
    final arc = state.chains.where((a) => a.id == petition.storyId).firstOrNull;
    final major =
        petition.storyKind == 'major' && state.major?.id == petition.storyId
            ? state.major
            : null;
    final labels =
        arc != null && usesChainSettlement(arc)
            ? arc.decisionLabels
            : major?.decisionLabels ?? const <String>[];
    final damage = major?.damageTaken ?? const <String, int>{};
    if (labels.isEmpty && damage.isEmpty) {
      return const SizedBox.shrink();
    }
    final kind = major == null ? 'chain' : 'major';
    return ExpansionTile(
      key: ValueKey('$kind-history-${petition.id}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: const Text(
        'Xem chỉ dụ trước',
        style: TextStyle(fontSize: 13, color: forest),
      ),
      children: [
        for (var i = 0; i < labels.length; i++)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                formatGameNumbers(state.authoredText(labels[i])),
                key: ValueKey('$kind-history-entry-$i'),
                style: const TextStyle(fontSize: 12, height: 1.5, color: muted),
              ),
            ),
          ),
        if (damage.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              formatGameNumbers(
                state.authoredText(
                  'Tổn thất đã xảy ra: ${eventEffectText(damage)}.',
                ),
              ),
              key: const ValueKey('major-history-damage'),
              style: const TextStyle(fontSize: 12, height: 1.5, color: muted),
            ),
          ),
      ],
    );
  }
}
