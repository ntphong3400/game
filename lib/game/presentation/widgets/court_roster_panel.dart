import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../logic/court_rules.dart' show courtOfficeFor;
import '../../models/game_state.dart';
import '../../logic/personnel_rules.dart' show officerBusy;
import 'imperial_assets.dart';
import 'imperial_room.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';
import 'personnel_passives.dart';
import 'equal_height_grid.dart';
import 'roster_card_body.dart';
import 'court_grade_badge.dart';

class CourtRosterPanel extends StatefulWidget {
  const CourtRosterPanel({
    super.key,
    required this.state,
    required this.busy,
    required this.onPerson,
    required this.onOffice,
    required this.onGovernment,
  });
  final GameState state;
  final bool busy;
  final Future<void> Function(Courtier) onPerson;
  final Future<void> Function(CourtOffice) onOffice;
  final VoidCallback onGovernment;
  @override
  State<CourtRosterPanel> createState() => _CourtRosterPanelState();
}

class _CourtRosterPanelState extends State<CourtRosterPanel> {
  String category = 'Tất cả', faction = 'Tất cả', work = 'Tất cả';
  int grade = 0;
  static const groups = [
    'Tất cả',
    'Văn ban',
    'Võ ban',
    'Hoàng thất',
    'Nội đình',
    'Địa phương',
    'Chờ bổ nhiệm',
  ];
  @override
  Widget build(BuildContext context) {
    final s = widget.state, reserve = category == 'Chờ bổ nhiệm';
    final compact = MediaQuery.sizeOf(context).width < 760;
    Widget responsiveFilters(Widget fields) =>
        compact
            ? ExpansionTile(
              key: const ValueKey('court-filters-toggle'),
              tilePadding: EdgeInsets.zero,
              title: const Text('Bộ lọc', style: TextStyle(fontSize: 12)),
              children: [fields],
            )
            : fields;
    final all =
        (reserve
                ? [
                  ...s.officialsPool,
                  ...s.court.where(
                    (c) => !c.isConsort && courtOfficeFor(s, c.id) == null,
                  ),
                ]
                : s.court)
            .where((c) => c.available && !c.isConsort)
            .toList();
    final people =
        all
            .where(
              (c) =>
                  (reserve || category == 'Tất cả' || c.category == category) &&
                  (grade == 0 || c.grade == grade) &&
                  (faction == 'Tất cả' || c.faction == faction) &&
                  (work == 'Tất cả' ||
                      officerBusy(s, c.id) == (work == 'Đang bận')),
            )
            .toList()
          ..sort((a, b) {
            final g = a.grade.compareTo(b.grade);
            return g != 0 ? g : a.name.compareTo(b.name);
          });
    final vacancies =
        s.courtOffices
            .where(
              (o) =>
                  o.holderId.isEmpty &&
                  !reserve &&
                  (category == 'Tất cả' || o.group == category) &&
                  (grade == 0 || o.grade == grade) &&
                  faction == 'Tất cả' &&
                  work == 'Tất cả',
            )
            .toList();
    Widget dropdown<T>(
      String label,
      T value,
      List<DropdownMenuItem<T>> items,
      ValueChanged<T?> changed,
      String key,
    ) => SizedBox(
      width: compact ? (MediaQuery.sizeOf(context).width - 106) / 2 : 168,
      child: DropdownButtonFormField<T>(
        key: ValueKey(key),
        value: value,
        style: const TextStyle(
          fontFamily: 'BeVietnam',
          fontSize: 11,
          color: ink,
        ),
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          labelText: formatGameNumbers(label),
        ),
        items: items,
        onChanged: changed,
      ),
    );
    return RoomPane(
      key: const ValueKey('court-roster-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!compact)
                const Text(
                  'Triều thần',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 27,
                    color: ink,
                  ),
                ),
              OutlinedButton.icon(
                key: const ValueKey('open-court-government'),
                onPressed: widget.onGovernment,
                icon: const Icon(Icons.account_balance_outlined, size: 17),
                label: const Text('Bộ máy triều đình'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Surface(
            padding: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact)
                  DropdownButtonFormField<String>(
                    key: const ValueKey('court-group-picker'),
                    value: category,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Nhóm chức vụ',
                    ),
                    style: const TextStyle(
                      fontFamily: 'BeVietnam',
                      fontSize: 11,
                      color: ink,
                    ),
                    items: [
                      for (final group in groups)
                        DropdownMenuItem(
                          value: group,
                          child: Text(
                            formatGameNumbers(
                              '$group (${group == 'Chờ bổ nhiệm' ? [...s.officialsPool, ...s.court.where((c) => !c.isConsort && courtOfficeFor(s, c.id) == null)].where((c) => c.available).length : s.courtOffices.where((o) => group == 'Tất cả' || o.group == group).length})',
                            ),
                          ),
                        ),
                    ],
                    onChanged:
                        (group) => setState(() {
                          category = group ?? 'Tất cả';
                        }),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final group in groups)
                        ChoiceChip(
                          key: ValueKey('court-group-$group'),
                          label: Text(
                            formatGameNumbers(
                              '$group (${group == 'Chờ bổ nhiệm' ? [...s.officialsPool, ...s.court.where((c) => !c.isConsort && courtOfficeFor(s, c.id) == null)].where((c) => c.available).length : s.courtOffices.where((o) => group == 'Tất cả' || o.group == group).length})',
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: category == group,
                          onSelected:
                              (_) => setState(() {
                                category = group;
                              }),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                responsiveFilters(
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      dropdown<int>(
                        'Phẩm hàm',
                        grade,
                        [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Tất cả các phẩm'),
                          ),
                          for (var g = 1; g <= 9; g++)
                            DropdownMenuItem(
                              value: g,
                              child: Text(formatGameNumbers(courtGradeName(g))),
                            ),
                        ],
                        (g) => setState(() {
                          grade = g ?? 0;
                        }),
                        'court-grade-filter',
                      ),
                      dropdown<String>(
                        'Phe phái',
                        faction,
                        [
                          for (final f in ['Tất cả', ...s.factions.keys])
                            DropdownMenuItem(
                              value: f,
                              child: Text(formatGameNumbers(f)),
                            ),
                        ],
                        (f) => setState(() {
                          faction = f ?? 'Tất cả';
                        }),
                        'court-faction-filter',
                      ),
                      dropdown<String>(
                        'Công việc',
                        work,
                        [
                          for (final f in ['Tất cả', 'Đang rảnh', 'Đang bận'])
                            DropdownMenuItem(
                              value: f,
                              child: Text(formatGameNumbers(f)),
                            ),
                        ],
                        (f) => setState(() {
                          work = f ?? 'Tất cả';
                        }),
                        'court-work-filter',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatGameNumbers(
                    '${people.length} người phù hợp${vacancies.isNotEmpty ? ' · ${vacancies.length} chức đang trống' : ''}',
                  ),
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final columns = (box.maxWidth / 260).floor().clamp(1, 5);
              final width = (box.maxWidth - (columns - 1) * 14) / columns;
              return EqualHeightGrid(
                columns: columns,
                children: [
                  for (final c in people)
                    SizedBox(
                      width: width,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: ValueKey('select-person-${c.id}'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.busy ? null : () => widget.onPerson(c),
                          child: ImperialSkin(
                            key: ValueKey('court-card-${c.id}'),
                            edge: 24,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                16,
                              ),
                              child: RosterCardBody(
                                action: OutlinedButton(
                                  key: ValueKey('meet-person-${c.id}'),
                                  onPressed:
                                      widget.busy
                                          ? null
                                          : () => widget.onPerson(c),
                                  child: const Text(
                                    'Triệu kiến',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                                children: [
                                  CharacterPortrait(
                                    person: c,
                                    width: width - 24,
                                    height: width - 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Tag(
                                    key: ValueKey('roster-status-${c.id}'),
                                    officerBusy(s, c.id)
                                        ? 'ĐANG BẬN'
                                        : c.retired
                                        ? 'ĐÃ HỒI HƯƠNG'
                                        : reserve
                                        ? 'CHỜ BỔ NHIỆM'
                                        : 'ĐANG RẢNH',
                                    color: forest,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    formatGameNumbers(c.name),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Lora',
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Center(
                                    child: CourtGradeBadge(
                                      c.grade,
                                      key: ValueKey('court-grade-${c.id}'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatGameNumbers(
                                      '${c.displayRole} · ${c.age} tuổi',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: gold,
                                    ),
                                  ),
                                  Text(
                                    formatGameNumbers(
                                      '${c.faction} · ${c.specialty}',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        formatGameNumbers(
                                          'Năng lực ${c.abilityLabel}',
                                        ),
                                        key: ValueKey('court-ability-${c.id}'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: forest,
                                        ),
                                      ),
                                      Text(
                                        formatGameNumbers(
                                          'Thiện cảm ${c.affection}',
                                        ),
                                        key: ValueKey(
                                          'court-affection-${c.id}',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: forest,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatGameNumbers(
                                      'Công trạng ${c.merit} · Đại công ${c.majorMerits}',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 8),
                                  PersonnelPassives(person: c, state: s),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  for (final office in vacancies)
                    SizedBox(
                      width: width,
                      child: Surface(
                        child: Column(
                          children: [
                            Text(
                              formatGameNumbers(office.role),
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 18,
                              ),
                            ),
                            Tag(courtGradeName(office.grade)),
                            const Text('Chức vụ đang trống'),
                            OutlinedButton(
                              onPressed:
                                  widget.busy
                                      ? null
                                      : () => widget.onOffice(office),
                              child: const Text('Bổ nhiệm'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (people.isEmpty && vacancies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Không có quan phù hợp với bộ lọc.'),
            ),
        ],
      ),
    );
  }
}
