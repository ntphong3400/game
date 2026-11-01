import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../data/content.dart';
import '../../logic/currency_rules.dart';
import '../../logic/finance_rules.dart';
import '../../logic/personnel_rules.dart';
import '../../logic/population_rules.dart';
import '../../models/game_state.dart';
import 'imperial_widgets.dart';
import 'imperial_theme.dart';
import 'kingdom_style.dart';
import 'locality_routes.dart';
import 'memorial_paper.dart';
import 'population_panel.dart';
import '../../logic/management_rules.dart';
import 'management_panel.dart';

/// Local workspaces share the existing state, command validation and dialogs.
/// Phủ nha combines local personnel and the existing work ledger.
class LocalityPanel extends StatelessWidget {
  const LocalityPanel({
    super.key,
    required this.place,
    required this.state,
    required this.busy,
    required this.onNavigate,
    required this.onAction,
    required this.blockedReason,
    required this.actionDescription,
    required this.onPolicy,
    required this.onPetition,
    required this.onPerson,
    required this.onOutcomes,
    required this.send,
  });
  final LocalityPlace place;
  final GameState state;
  final bool busy;
  final ValueChanged<String> onNavigate;
  final Future<void> Function(ActionDefinition) onAction;
  final String? Function(ActionDefinition) blockedReason;
  final String Function(ActionDefinition) actionDescription;
  final Future<void> Function(String, String) onPolicy;
  final Future<void> Function(Petition) onPetition;
  final Future<void> Function(Courtier) onPerson;
  final VoidCallback onOutcomes;
  final Future<bool> Function(String, String, String) send;

  GameState get s => state;
  bool get policyLocked => busy || s.points < 1;

  @override
  Widget build(BuildContext context) {
    final ledger = SingleChildScrollView(
      key: ValueKey(
        place == LocalityPlace.administration && s.managementVersion > 0
            ? 'locality-administration-ledger'
            : 'locality-panel-${place.name}',
      ),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (place == LocalityPlace.administration) ...[
            const Text(
              'Tiếp nhận tấu báo, giao việc và theo dõi thi hành tại địa phương.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _section('Giao việc địa phương', _destinations()),
            _section('Quan đang phụ trách', _assignedPeople()),
          ] else
            _section('Tình hình hiện tại', _overview()),
          if (place == LocalityPlace.commerce)
            _section('Chính sách thuế & sản xuất', _commercePolicies()),
          if (place == LocalityPlace.granary)
            _section('Ưu tiên chi trả', _reliefPolicy()),
          if (place != LocalityPlace.administration)
            _section(
              'Công việc có thể giao',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final action in place.actionsFor(s)) _action(action),
                ],
              ),
            ),
          _section('Tấu báo liên quan', _petitions()),
          _section('Đang thực hiện', _ongoing()),
          if (place == LocalityPlace.administration)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: const ValueKey('locality-outcomes'),
                onPressed: onOutcomes,
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Mở sổ kết quả triều đình'),
              ),
            ),
        ],
      ),
    );

    return place == LocalityPlace.administration && s.managementVersion > 0
        ? _LocalityManagementTabs(
          key: const ValueKey('locality-panel-administration'),
          state: s,
          busy: busy,
          send: send,
          ledger: ledger,
        )
        : ledger;
  }

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          formatGameNumbers(title),
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 19,
            color: forest,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(
          formatGameNumbers('$label:'),
          style: const TextStyle(color: muted),
        ),
        Text(formatGameNumbers(value), style: const TextStyle(color: forest)),
      ],
    ),
  );

  Widget _overview() => switch (place) {
    LocalityPlace.agriculture => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row('Lương thực', '${whole(s.grain)} ${foodUnit(s)}'),
        if (s.seasonal) ...[
          _row('Cấp nông nghiệp', '${s.agricultureLevel}/5'),
          Text(
            formatGameNumbers(harvestPlan(s)),
            key: const ValueKey('locality-harvest-plan'),
          ),
          if (s.lastHarvestYear > 0)
            _row(
              'Vụ Thu năm ${s.lastHarvestYear}',
              '+${whole(s.lastHarvestAmount)} ${foodUnit(s)}',
            ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Khai khẩn bổ sung lương thực một lần; phát triển nông nghiệp tăng sản lượng nền cho những vụ sau.',
        ),
      ],
    ),
    LocalityPlace.irrigation => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row('Tình trạng đê', '${s.levee}/100'),
        if (s.seasonal) ...[
          _row('Cấp công trình', '${s.leveeLevel}/5'),
          _row(
            'Hao mòn dự kiến cuối mùa ${s.season}',
            '−${leveeWearThisSeason(s)} điểm',
          ),
          Text(
            formatGameNumbers(
              'Cấp đê hiện tại giảm ${leveeWearReductions[s.leveeLevel]}% hao mòn thường lệ.',
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Bảo dưỡng và tu bổ phục hồi tình trạng đê. Nâng cấp tăng độ bền công trình, không tự phục hồi đê.',
        ),
      ],
    ),
    LocalityPlace.granary => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row('Lương thực dự trữ', '${whole(s.grain)} ${foodUnit(s)}'),
        if (s.population != null) ...[
          _row('Sức chứa', '${whole(foodCapacity)} tạ'),
          _row('Dự trữ tương đương', '${foodDays(s)} ngày'),
          _row(
            'Khẩu phần đã cấp trước',
            '${whole(s.population!.foodCredit)} tạ',
          ),
          _row(
            'Còn phải cấp cuối mùa',
            '${whole(remainingFoodConsumption(s))} tạ',
          ),
        ],
        _row('Lòng dân', '${s.people}/100'),
      ],
    ),
    LocalityPlace.commerce => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row('Ngân khố', moneyText(s, s.treasury)),
        _row('Mức thuế', taxLabels[s.tax]),
        if (s.seasonal) ...[
          _row('Cấp kinh tế', '${s.economyLevel}/5'),
          _row(
            'Thuế dự kiến vụ Thu',
            moneyText(s, annualTaxRevenue(s, year: s.nextTaxYear)),
          ),
          Text(formatGameNumbers(taxPolicyHint(s))),
        ],
      ],
    ),
    LocalityPlace.village => PopulationPanel(state: s, embedded: true),
    LocalityPlace.administration => const SizedBox.shrink(),
  };

  Widget _destinations() => LayoutBuilder(
    builder: (context, bounds) {
      final width =
          bounds.maxWidth >= 620 ? (bounds.maxWidth - 12) / 2 : bounds.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          for (final destination in LocalityPlace.values.where(
            (p) => p != place,
          ))
            SizedBox(
              width: width,
              child: OutlinedButton(
                key: ValueKey('locality-work-${destination.name}'),
                onPressed: () => onNavigate(destination.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatGameNumbers(destination.landmark),
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formatGameNumbers(destination.title),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _assignedPeople() {
    final ids = {
      for (final p in s.projects.where((p) => place.tasks.contains(p.kind)))
        p.officerId,
      for (final p in s.pending.where((p) => place.includesConsequence(s, p)))
        if (p.assignment != null) p.assignment!.assigneeId,
      for (final p in s.population?.orders ?? <PopulationOrder>[])
        if (place.tasks.contains(p.kind)) p.officerId,
    };
    final assigned = s.court.where(
      (c) => c.available && !c.isConsort && ids.contains(c.id),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (assigned.isEmpty)
          const Text(
            'Chưa có quan phụ trách công việc địa phương đang thực hiện.',
          ),
        for (final person in assigned)
          ListTile(
            key: ValueKey('locality-person-${person.id}'),
            contentPadding: EdgeInsets.zero,
            leading: CharacterPortrait(person: person, width: 40, height: 50),
            title: Text(formatGameNumbers(person.name)),
            subtitle: Text(
              formatGameNumbers('${person.displayRole} · ${person.specialty}'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: busy ? null : () => onPerson(person),
          ),
        const SizedBox(height: 8),
        const Text(
          'Bấm tên để xem hồ sơ quan. Tuyển dụng, bổ nhiệm và bãi nhiệm tại Phủ Bá Quan.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const ValueKey('locality-personnel'),
            onPressed: () => onNavigate('people'),
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Đến Phủ Bá Quan'),
          ),
        ),
      ],
    );
  }

  Widget _action(ActionDefinition action) {
    final reason = blockedReason(action);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MemorialPaper(
        readKey: ValueKey('locality-action-paper-${action.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formatGameNumbers(action.title),
                style: const TextStyle(fontFamily: 'Lora', fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                formatGameNumbers(actionDescription(action)),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  KingdomPill('${actionCost(s, action)} ${moneyUnit(s)}'),
                  if (actionGrainCost(s, action) > 0)
                    KingdomPill(
                      '${whole(actionGrainCost(s, action))} ${foodUnit(s)}',
                    ),
                  const KingdomPill('1 hành động'),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: ValueKey('action-${action.id}'),
                onPressed: reason == null ? () => onAction(action) : null,
                icon: const Icon(Icons.arrow_forward, size: 17),
                label: Text(
                  formatGameNumbers(
                    populationActionNames.containsKey(action.id)
                        ? 'Xem & ban lệnh'
                        : 'Xem & giao việc',
                  ),
                ),
              ),
              if (reason != null)
                Text(
                  formatGameNumbers(reason),
                  style: const TextStyle(fontSize: 11, color: terracotta),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commercePolicies() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var rate = 0; rate < taxLabels.length; rate++)
            ChoiceChip(
              key: ValueKey('locality-tax-$rate'),
              label: Text(formatGameNumbers('Thuế ${taxLabels[rate]}')),
              selected: s.tax == rate,
              onSelected: policyLocked ? null : (_) => onPolicy('tax', '$rate'),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        formatGameNumbers(
          s.seasonal
              ? 'Đổi mức thuế tốn 1 hành động; thu và áp dụng tác động lòng dân khi khép mùa Thu.'
              : 'Đổi mức thuế tốn 1 hành động; áp dụng khi khép tuần.',
        ),
      ),
      if (s.population != null) ...[
        const SizedBox(height: 16),
        const Text('Ưu tiên sản xuất mùa tới'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final policy in populationPolicies.entries)
              ChoiceChip(
                key: ValueKey('locality-production-${policy.key}'),
                label: Text(formatGameNumbers(policy.value)),
                selected: s.population!.nextPolicy == policy.key,
                onSelected:
                    policyLocked
                        ? null
                        : (_) => onPolicy('production', policy.key),
              ),
          ],
        ),
        Text(
          formatGameNumbers(
            'Đang hiệu lực: ${populationPolicies[s.population!.policy]}. Thay chính sách tốn 1 hành động.',
          ),
        ),
      ],
    ],
  );

  Widget _reliefPolicy() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option
              in const {
                'army': 'Ưu tiên quân đội',
                'people': 'Ưu tiên cứu tế',
              }.entries)
            ChoiceChip(
              key: ValueKey('locality-priority-${option.key}'),
              label: Text(formatGameNumbers(option.value)),
              selected: s.priority == option.key,
              onSelected:
                  policyLocked ? null : (_) => onPolicy('priority', option.key),
            ),
        ],
      ),
      const Text(
        'Khi thiếu tiền, khoản ưu tiên được thanh toán trước. Thay chính sách tốn 1 hành động.',
      ),
    ],
  );

  Widget _petitions() {
    final petitions = place.petitionsFor(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (petitions.isEmpty)
          const Text('Chưa có tấu báo liên quan đang chờ xử lý.'),
        for (final petition in petitions)
          ListTile(
            key: ValueKey('locality-petition-${petition.id}'),
            contentPadding: EdgeInsets.zero,
            title: Text(
              formatGameNumbers(eventForState(s, petition.definitionId).title),
            ),
            subtitle: Text(
              formatGameNumbers('Hạn xử lý: ${s.date(petition.deadline)}'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: busy ? null : () => onPetition(petition),
          ),
      ],
    );
  }

  Widget _ongoing() {
    final projects = s.projects.where((p) => place.tasks.contains(p.kind));
    final pending = s.pending.where((p) => place.includesConsequence(s, p));
    final orders = (s.population?.orders ?? <PopulationOrder>[]).where(
      (o) => place.tasks.contains(o.kind),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (projects.isEmpty && pending.isEmpty && orders.isEmpty)
          const Text('Chưa có công việc đang thực hiện.'),
        for (final p in projects) ...[
          _row(
            projectTitle(p.kind),
            '${p.progress}/${p.duration} ${s.periodName}',
          ),
          Text(
            formatGameNumbers(
              'Phụ trách: ${s.court.where((c) => c.id == p.officerId).firstOrNull?.name ?? 'Chưa có người'}',
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value:
                p.duration > 0 ? (p.progress / p.duration).clamp(0.0, 1.0) : 0,
            color: forest,
            backgroundColor: line,
          ),
          const SizedBox(height: 8),
          if (developmentTasks.contains(p.kind) &&
              developmentNeedsOfficer(s, p)) ...[
            const Text(
              'Tạm dừng, cần người thay.',
              style: TextStyle(color: terracotta),
            ),
            _action(actions.firstWhere((a) => a.id == p.kind)),
          ] else
            Text(
              formatGameNumbers(
                'Dự kiến cuối ${s.date(s.week + (p.duration - p.progress - 1).clamp(0, p.duration))}',
              ),
            ),
          const SizedBox(height: 18),
        ],
        for (final p in pending)
          _row(
            p.title.isNotEmpty ? p.title : 'Chờ kết quả',
            'Cuối ${s.date(p.dueWeek)}${p.assignment == null ? '' : ' · ${p.assignment!.personLabel}'}',
          ),
        for (final order in orders)
          _row(
            order.title,
            '${whole(order.count)} người · cuối ${s.date(order.due)}',
          ),
      ],
    );
  }
}

class _LocalityManagementTabs extends StatefulWidget {
  const _LocalityManagementTabs({
    super.key,
    required this.state,
    required this.busy,
    required this.send,
    required this.ledger,
  });
  final GameState state;
  final bool busy;
  final Future<bool> Function(String, String, String) send;
  final Widget ledger;
  @override
  State<_LocalityManagementTabs> createState() =>
      _LocalityManagementTabsState();
}

class _LocalityManagementTabsState extends State<_LocalityManagementTabs> {
  int selected = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                child: OutlinedButton(
                  key: ValueKey('locality-tab-$i'),
                  onPressed: () => setState(() => selected = i),
                  style:
                      selected == i
                          ? OutlinedButton.styleFrom(
                            backgroundColor: forest.withValues(alpha: .12),
                          )
                          : null,
                  child: Text(
                    formatGameNumbers(
                      i == 0 ? 'Quan lại địa phương' : 'Điều hành địa phương',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      Expanded(
        child:
            selected == 1
                ? widget.ledger
                : LayoutBuilder(
                  builder: (context, bounds) {
                    final columns =
                        bounds.maxWidth >= 1100
                            ? 3
                            : bounds.maxWidth >= 700
                            ? 2
                            : 1;
                    final width =
                        (bounds.maxWidth - (columns - 1) * 12) / columns;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final area in [
                            'bac-son',
                            'dong-hai',
                            'tay-linh',
                          ])
                            SizedBox(
                              width: width,
                              child: Column(
                                children: [
                                  for (final kind in ['prefect', 'assistant'])
                                    ManagementCard(
                                      state: widget.state,
                                      post: ManagementPost(kind, area),
                                      busy: widget.busy,
                                      send: widget.send,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    ],
  );
}
