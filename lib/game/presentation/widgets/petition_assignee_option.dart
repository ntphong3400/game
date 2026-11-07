import 'package:flutter/material.dart';

import '../../logic/petition_assignment_rules.dart';
import '../../models/event_definition.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'imperial_theme.dart';
import 'imperial_widgets.dart';

class PetitionAssigneeList extends StatelessWidget {
  const PetitionAssigneeList({
    super.key,
    required this.state,
    required this.event,
    required this.choice,
    required this.onSelected,
    required this.onSummon,
  });

  final GameState state;
  final EventDefinition event;
  final EventChoice choice;
  final ValueChanged<String> onSelected;
  final ValueChanged<Courtier> onSummon;

  @override
  Widget build(BuildContext context) {
    final candidates = petitionAssignees(state, event, choice);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final rateWidth = compact ? 64.0 : 108.0;
        final columnGap = compact ? 10.0 : 18.0;
        final inset = compact ? 8.0 : 16.0;
        final defaultChance = petitionBaseChance(choice);

        return Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1, color: line),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: inset, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: rateWidth,
                      child: const Text(
                        'Tỷ lệ thành công',
                        style: _columnStyle,
                      ),
                    ),
                    SizedBox(width: columnGap),
                    const Expanded(
                      child: Text('Người xử lý', style: _columnStyle),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: line),
              if (candidates.isEmpty)
                Padding(
                  padding: EdgeInsets.all(inset),
                  child: Text(
                    'Chưa có người chuyên môn ${petitionSpecialty(event, choice)} đủ điều kiện và đang rảnh.',
                  ),
                ),
              for (final person in candidates) ...[
                SimpleDialogOption(
                  key: ValueKey('petition-person-${person.id}'),
                  padding: EdgeInsets.symmetric(
                    horizontal: inset,
                    vertical: 12,
                  ),
                  onPressed: () => onSelected(person.id),
                  child: Row(
                    children: [
                      SizedBox(
                        width: rateWidth,
                        child: _ChanceScale(
                          personId: person.id,
                          chance: petitionChance(state, event, choice, person),
                          compact: compact,
                        ),
                      ),
                      SizedBox(width: columnGap),
                      Expanded(
                        child: _AssigneeDetails(
                          person: person,
                          state: state,
                          compact: compact,
                          onSummon: () => onSummon(person),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: line),
              ],
              Ink(
                color: const Color(0x66EADBC0),
                child: SimpleDialogOption(
                  key: const ValueKey('petition-unassigned'),
                  padding: EdgeInsets.symmetric(
                    horizontal: inset,
                    vertical: 12,
                  ),
                  onPressed: () => onSelected(''),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Không giao ai xử lý',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatGameNumbers('$defaultChance%'),
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

const _columnStyle = TextStyle(
  color: muted,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

class _AssigneeDetails extends StatelessWidget {
  const _AssigneeDetails({
    required this.person,
    required this.state,
    required this.compact,
    required this.onSummon,
  });

  final Courtier person;
  final GameState state;
  final bool compact;
  final VoidCallback onSummon;

  @override
  Widget build(BuildContext context) {
    final specialty = person.specialty
        .split(' ')
        .map((word) {
          return word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
    final aptitude =
        person.isConsort
            ? 'Thiện cảm: ${person.affection}'
            : 'Năng lực: ${person.abilityLabel}';
    final investigation = person.lastInvestigation;
    final discontent =
        investigation == null ? 'Chưa rõ' : '${investigation.discontent}/100';

    final summonButton = OutlinedButton(
      key: ValueKey('petition-person-summon-${person.id}'),
      onPressed: onSummon,
      style: OutlinedButton.styleFrom(
        foregroundColor: gold,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: gold),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: const TextStyle(
          fontFamily: 'BeVietnam',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        backgroundBuilder:
            (context, states, child) => child ?? const SizedBox.shrink(),
      ),
      child: const Text('Triệu kiến'),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CharacterPortrait(
              person: person,
              width: compact ? 30 : 38,
              height: compact ? 40 : 48,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: TextStyle(
                      color: ink,
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person.displayRole,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          formatGameNumbers(
            '$specialty · $aptitude · Mệt: ${person.strain} · Bất mãn: $discontent',
          ),
          key: ValueKey('petition-person-stats-${person.id}'),
          style: const TextStyle(color: muted, fontSize: 11, height: 1.55),
        ),
        if (investigation != null) ...[
          const SizedBox(height: 3),
          Text(
            formatGameNumbers(
              'Ghi nhận ${state.date(investigation.week)} · Chỉ cập nhật khi điều tra tiếp theo hoàn tất.',
            ),
            key: ValueKey('petition-person-investigation-${person.id}'),
            style: const TextStyle(color: muted, fontSize: 10, height: 1.5),
          ),
        ],
        if (compact) ...[const SizedBox(height: 8), summonButton],
      ],
    );
    return Row(
      children: [
        Expanded(child: details),
        if (!compact) ...[const SizedBox(width: 14), summonButton],
      ],
    );
  }
}

class _ChanceScale extends StatelessWidget {
  const _ChanceScale({
    required this.personId,
    required this.chance,
    required this.compact,
  });

  final String personId;
  final int chance;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Tỷ lệ thành công: $chance%',
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatGameNumbers('$chance%'),
          key: ValueKey('petition-person-chance-$personId'),
          style: TextStyle(
            fontFamily: 'Lora',
            color: forest,
            fontSize: compact ? 25 : 31,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: chance / 100,
          minHeight: 4,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: const Color(0xFFE3D4B7),
          color: const Color(0xFF5B806A),
        ),
      ],
    ),
  );
}
