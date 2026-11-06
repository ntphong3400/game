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
  const CourtOverview({
    super.key,
    required this.state,
    this.dense = false,
    this.inPetitionOverlay = false,
  });

  final GameState state;
  final bool dense, inPetitionOverlay;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final compact = dense || bounds.maxWidth < 600;

      Widget stat(
        String id,
        String label,
        String value,
        String icon, {
        String? overlayIcon,
        bool warning = false,
      }) =>
          inPetitionOverlay
              ? _stripStat(
                id,
                label,
                overlayIcon ?? icon,
                value,
                warning: warning,
              )
              : _stat(compact, id, label, value, icon, warning: warning);

      final authority = stat(
        'authority',
        'Uy quyền',
        _score(state.authority),
        'authority',
        warning: state.authority <= 20,
      );
      final stability = stat(
        'stability',
        'Ổn định',
        _score(state.stability),
        'stability',
        warning: state.stability <= 20,
      );
      final treasury = stat(
        'treasury',
        'Ngân khố',
        inPetitionOverlay
            ? _thousands(state.treasury)
            : moneyNumber(state.treasury),
        'treasury',
      );
      final food = stat(
        'food',
        'Lương thực',
        inPetitionOverlay ? _thousands(state.grain) : whole(state.grain),
        'grain',
      );
      final military = stat(
        'military',
        'Quân sự',
        state.population == null
            ? _score(state.army)
            : whole(militaryStrength(state)),
        'army',
        warning: armyCondition(state) <= 20,
      );
      final population = stat(
        'population',
        'Dân số',
        state.population == null
            ? '—'
            : _population(state.population!.population),
        'citizens',
      );
      final people = stat(
        'people',
        'Lòng dân',
        _score(state.people),
        'citizens',
        overlayIcon: 'people',
        warning: state.people <= 20,
      );
      final health = stat(
        'health',
        'Long thể',
        _score(state.health),
        'health',
        warning: state.health <= 20,
      );

      if (inPetitionOverlay) {
        final minRowWidth =
            330 * MediaQuery.textScalerOf(context).scale(10) / 10;
        return _petitionStrip([
          authority,
          stability,
          people,
          health,
          treasury,
          food,
          military,
          population,
        ], singleRow: bounds.maxWidth >= minRowWidth + 12);
      }
      return EqualHeightGrid(
        key: const ValueKey('court-overview'),
        columns:
            bounds.maxWidth >= 1100 || (dense && bounds.maxWidth >= 700)
                ? 8
                : 4,
        spacing: 8,
        children: [
          authority,
          stability,
          treasury,
          food,
          military,
          population,
          people,
          health,
        ],
      );
    },
  );

  String _score(int value) => inPetitionOverlay ? '$value' : '$value/100';

  String _thousands(int value) =>
      value.abs() < 1000 ? whole(value) : '${whole(value ~/ 1000)}K';

  String _population(int value) {
    if (!inPetitionOverlay) return whole(value);
    if (value < 1000000) return _thousands(value);
    final millions = (value / 1000000)
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
    return '${millions}M';
  }

  Widget _petitionStrip(List<Widget> stats, {required bool singleRow}) =>
      DecoratedBox(
        key: const ValueKey('petition-overview'),
        decoration: BoxDecoration(
          color: paper,
          border: Border.all(color: gold),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child:
              singleRow
                  ? _stripRow(stats)
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stripRow(stats.sublist(0, 4)),
                      const Divider(height: 1, color: line),
                      _stripRow(stats.sublist(4)),
                    ],
                  ),
        ),
      );

  Widget _stripRow(List<Widget> stats) => Row(
    children: [
      for (var index = 0; index < stats.length; index++) ...[
        if (index > 0)
          Container(
            width: 1,
            height: index == 4 ? 30 : 20,
            color: index == 4 ? gold : line,
          ),
        Expanded(child: stats[index]),
      ],
    ],
  );

  Widget _stripStat(
    String id,
    String label,
    String icon,
    String value, {
    bool warning = false,
  }) => Tooltip(
    key: ValueKey('petition-stat-$id'),
    message: label,
    triggerMode: TooltipTriggerMode.tap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImperialIcon(icon, size: 22),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'BeVietnam',
              fontSize: 10,
              height: 1.2,
              color: warning ? terracotta : forest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
