import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/court_rules.dart';
import '../../logic/management_rules.dart';
import 'imperial_room.dart';
import 'imperial_theme.dart';

class CourtGovernmentPanel extends StatelessWidget {
  const CourtGovernmentPanel({
    super.key,
    required this.state,
    required this.busy,
    required this.onBack,
    required this.onPerson,
    required this.onAppoint,
    required this.onDismiss,
  });
  final GameState state;
  final bool busy;
  final VoidCallback onBack;
  final Future<void> Function(Courtier) onPerson;
  final Future<void> Function(CourtOffice) onAppoint, onDismiss;

  @override
  Widget build(BuildContext context) {
    final offices =
        state.courtOffices.toList()..sort((a, b) {
          final grade = a.grade.compareTo(b.grade);
          if (grade != 0) return grade;
          const groups = [
            'Văn ban',
            'Võ ban',
            'Hoàng thất',
            'Nội đình',
            'Địa phương',
          ];
          final group = groups
              .indexOf(a.group)
              .compareTo(groups.indexOf(b.group));
          if (group != 0) return group;
          final role = a.role.compareTo(b.role);
          return role != 0 ? role : a.id.compareTo(b.id);
        });
    final vacant =
        offices.where((o) => courtOfficeHolder(state, o) == null).length;
    return RoomPane(
      key: const ValueKey('court-government'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('court-government-back'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 17),
            label: const Text('Về Triều thần'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatGameNumbers(
                    '${offices.length} vị trí quan chức · $vacant vị trí đang trống',
                  ),
                  key: const ValueKey('court-government-count'),
                  style: const TextStyle(fontSize: 12, color: forest),
                ),
              ),
              const Tooltip(
                key: ValueKey('government-list-help'),
                triggerMode: TooltipTriggerMode.tap,
                message:
                    'Sắp theo phẩm chức vụ từ Nhất đến Cửu phẩm. Chức có passive khi bỏ trống chịu tác động ngược lúc khép mùa; có người chưa đủ điều kiện thì đóng góp bằng 0. Bấm tên quan để xem chi tiết; bấm vào passive để xem điều kiện.',
                child: Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(Icons.info_outline, size: 18, color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 900;
              return Column(
                children: [
                  if (wide)
                    Container(
                      key: const ValueKey('government-list-header'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: forest.withValues(alpha: .08),
                        border: Border(bottom: BorderSide(color: line)),
                      ),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(
                          fontSize: 11,
                          color: forest,
                          fontWeight: FontWeight.w600,
                        ),
                        child: _columns(
                          role: const Text('Chức vụ'),
                          grade: const Text('Phẩm yêu cầu'),
                          holder: const Text('Người đang giữ chức'),
                          passive: const Text('Trạng thái passive'),
                          actions: const Text('Bổ nhiệm / hồi hương'),
                        ),
                      ),
                    ),
                  for (var i = 0; i < offices.length; i++)
                    _office(offices[i], wide: wide, alternate: i.isOdd),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _columns({
    required Widget role,
    required Widget grade,
    required Widget holder,
    required Widget passive,
    required Widget actions,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(flex: 3, child: role),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: grade),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: holder),
      const SizedBox(width: 12),
      Expanded(flex: 6, child: passive),
      const SizedBox(width: 12),
      SizedBox(width: 192, child: actions),
    ],
  );

  Widget _office(
    CourtOffice office, {
    required bool wide,
    required bool alternate,
  }) {
    final post = managementPost(office.id);
    final role = Text(
      formatGameNumbers(
        post == null ? office.role : '${office.role} · ${post.areaName}',
      ),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
    final grade = Text(
      formatGameNumbers(
        post != null && !post.senior
            ? 'Không yêu cầu phẩm'
            : courtGradeName(office.grade),
      ),
      style: const TextStyle(fontSize: 11, color: forest),
    );
    final holder = _holder(office);
    final passive = _passives(office);
    final actions = _actions(office, wide: wide);
    return Container(
      key: ValueKey('government-office-${office.id}'),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: wide ? 7 : 10),
      decoration: BoxDecoration(
        color: alternate ? forest.withValues(alpha: .025) : null,
        border: Border(bottom: BorderSide(color: line.withValues(alpha: .65))),
      ),
      child:
          wide
              ? _columns(
                role: role,
                grade: grade,
                holder: holder,
                passive: passive,
                actions: actions,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: role),
                      const SizedBox(width: 8),
                      grade,
                    ],
                  ),
                  const SizedBox(height: 3),
                  holder,
                  const SizedBox(height: 3),
                  passive,
                  const SizedBox(height: 3),
                  Align(alignment: Alignment.centerLeft, child: actions),
                ],
              ),
    );
  }

  Widget _holder(CourtOffice office) {
    final holder = courtOfficeHolder(state, office);
    if (holder == null) {
      return Text(
        'Đang bỏ trống',
        key: ValueKey('government-vacant-${office.id}'),
        style: const TextStyle(
          fontSize: 12,
          color: terracotta,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        key: ValueKey('government-meet-${office.id}'),
        onPressed: busy ? null : () => onPerson(holder),
        style: _buttonStyle(
          forest,
        ).copyWith(padding: const WidgetStatePropertyAll(EdgeInsets.zero)),
        child: Text(
          formatGameNumbers(holder.name),
          key: ValueKey('government-holder-${office.id}'),
          style: const TextStyle(fontSize: 12),
          softWrap: true,
        ),
      ),
    );
  }

  Widget _passives(CourtOffice office) {
    final post = managementPost(office.id);
    if (post != null) {
      final direction = managementDirection(state, post);
      return Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        message: formatGameNumbers(
          'Năng lực >${post.abilityThreshold}, thiện cảm >${post.affectionThreshold}. ${post.growthLabel}. Bỏ trống: ${post.effect(vacant: true)}.',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatGameNumbers(
                direction == 1
                    ? 'Đang hoạt động'
                    : direction < 0
                    ? 'Bỏ trống · Phạt theo chu kỳ'
                    : 'Chưa kích hoạt · Đóng góp 0',
              ),
              key: ValueKey('government-passive-status-${office.id}'),
              style: TextStyle(
                fontSize: 11,
                color:
                    direction < 0
                        ? terracotta
                        : direction == 1
                        ? forest
                        : muted,
              ),
            ),
            Text(
              formatGameNumbers(post.effect(vacant: direction < 0)),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
    }
    final benefits = courtPassives(office);
    if (benefits.isEmpty) {
      return const Text(
        'Không có passive chức vụ',
        style: TextStyle(fontSize: 11, color: muted),
      );
    }
    final direction = courtOfficeDirection(state, office);
    final reason = courtPassiveBlocked(state, office);
    final color =
        direction == -1
            ? terracotta
            : direction == 1
            ? forest
            : muted;
    final status =
        direction == -1
            ? 'Bỏ trống · Phạt mỗi mùa'
            : direction == 1
            ? 'Đang hoạt động'
            : 'Chưa kích hoạt · Đóng góp 0';
    final conditions =
        'Kích hoạt: năng lực ≥${office.grade == 1 ? 90 : 80}, thiện cảm ≥${office.grade == 1 ? 80 : 70}; đủ phẩm và giữ chức trọn mùa.';
    return Tooltip(
      message: formatGameNumbers(
        direction == -1
            ? 'Vị trí đang bỏ trống: ${courtVacancyEffects(office)}'
            : '${reason == null ? '' : '$reason\n'}$conditions\nNếu bỏ trống: ${courtVacancyEffects(office)}',
      ),
      triggerMode: TooltipTriggerMode.tap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatGameNumbers(status),
            key: ValueKey('government-passive-status-${office.id}'),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 2,
            children: [
              for (final benefit in benefits)
                Text(
                  formatGameNumbers(
                    '${benefit.label} ${direction == -1 ? benefit.vacancyEffect : benefit.effect}',
                  ),
                  key: ValueKey(
                    'government-effect-${office.id}-${benefit.name}',
                  ),
                  style: TextStyle(fontSize: 10, color: color),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, {bool wide = true}) =>
      TextButton.styleFrom(
        foregroundColor: color,
        textStyle: const TextStyle(
          fontFamily: 'BeVietnam',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size(0, wide ? 32 : 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundBuilder:
            (context, states, child) => child ?? const SizedBox.shrink(),
      );

  Widget _actions(CourtOffice office, {required bool wide}) {
    final holder = courtOfficeHolder(state, office);
    final dismissal = courtDismissalBlocked(state, office);
    final buttons = Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Tooltip(
          message: formatGameNumbers(
            holder == null
                ? 'Bổ nhiệm vào chức đang trống'
                : 'Chức vụ đã có người giữ. Cho quan hồi hương trước khi bổ nhiệm tại đây.',
          ),
          child: TextButton(
            key: ValueKey('government-appoint-${office.id}'),
            onPressed: busy || holder != null ? null : () => onAppoint(office),
            style: _buttonStyle(forest, wide: wide),
            child: const Text('Bổ nhiệm'),
          ),
        ),
        if (holder != null)
          Tooltip(
            message: formatGameNumbers(
              dismissal ?? 'Cho hồi hương, để trống vị trí này',
            ),
            child: TextButton(
              key: ValueKey('government-dismiss-${office.id}'),
              onPressed:
                  busy || dismissal != null ? null : () => onDismiss(office),
              style: _buttonStyle(terracotta, wide: wide),
              child: const Text('Cho hồi hương'),
            ),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buttons,
        if (holder != null && dismissal != null)
          Text(
            formatGameNumbers(dismissal.replaceFirst('${office.role}: ', '')),
            key: ValueKey('government-dismiss-blocked-${office.id}'),
            style: const TextStyle(fontSize: 9, color: muted),
          ),
      ],
    );
  }
}
