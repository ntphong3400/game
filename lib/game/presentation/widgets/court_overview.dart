import 'package:flutter/material.dart';
import '../../logic/currency_rules.dart';
import '../../logic/population_rules.dart';
import '../../models/game_state.dart';
import '../../models/number_format.dart';
import 'equal_height_grid.dart';
import 'imperial_assets.dart';
import 'imperial_theme.dart';

/// Current game values belong to the court workspace, below the shared top bar.
class CourtOverview extends StatelessWidget {
  const CourtOverview({super.key, required this.state, this.dense = false});

  final GameState state;
  final bool dense;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, bounds) => EqualHeightGrid(
          key: const ValueKey('court-overview'),
          columns:
              bounds.maxWidth >= 1100 || (dense && bounds.maxWidth >= 700)
                  ? 8
                  : 4,
          spacing: 8,
          children: [
            _stat(
              dense || bounds.maxWidth < 600,
              'authority',
              'Uy quyền',
              '${state.authority}/100',
              'authority',
              warning: state.authority <= 20,
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'stability',
              'Ổn định',
              '${state.stability}/100',
              'stability',
              warning: state.stability <= 20,
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'treasury',
              'Ngân khố',
              moneyNumber(state.treasury),
              'treasury',
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'food',
              'Lương thực',
              whole(state.grain),
              'grain',
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'military',
              'Quân sự',
              state.population == null
                  ? '${state.army}/100'
                  : whole(militaryStrength(state)),
              'army',
              warning: armyCondition(state) <= 20,
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'population',
              'Dân số',
              state.population == null
                  ? '—'
                  : whole(state.population!.population),
              'citizens',
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'people',
              'Lòng dân',
              '${state.people}/100',
              'citizens',
              warning: state.people <= 20,
            ),
            _stat(
              dense || bounds.maxWidth < 600,
              'health',
              'Long thể',
              '${state.health}/100',
              'health',
              warning: state.health <= 20,
            ),
          ],
        ),
  );

  Widget _stat(
    bool compact,
    String id,
    String label,
    String value,
    String icon, {
    bool warning = false,
  }) => Container(
    key: ValueKey('court-stat-$id'),
    padding: EdgeInsets.all(compact ? 6 : 10),
    decoration: BoxDecoration(
      color: paper,
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: muted),
            ),
          )
        else
          Row(
            children: [
              ImperialIcon(icon, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
              ),
            ],
          ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatGameNumbers(value),
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: compact ? 16 : 20,
              height: 1.2,
              color: warning ? terracotta : forest,
            ),
          ),
        ),
      ],
    ),
  );
}
