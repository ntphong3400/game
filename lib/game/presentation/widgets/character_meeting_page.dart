import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import 'imperial_dialog.dart';
import 'court_grade_badge.dart';
import 'harem_rank_badge.dart';

/// Scene content is independent of roster type and gameplay actions.
class MeetingScene {
  const MeetingScene({
    required this.backgroundAsset,
    required this.characterAsset,
    required this.name,
    required this.role,
    required this.age,
    required this.affection,
    required this.ability,
    required this.location,
    required this.description,
    this.investigatedPlot,
    this.investigatedDiscontent,
    this.investigatedAt,
    this.contributions = const [],
    this.contributionCondition,
    this.contributionHint,
    this.grade,
    this.haremRank,
    this.contributionTitle = 'Đóng góp hậu cung',
  });

  final String backgroundAsset,
      characterAsset,
      name,
      role,
      location,
      description;
  final int age, affection;
  final num ability;
  final int? investigatedPlot, investigatedDiscontent;
  final String? investigatedAt;
  final List<MeetingContribution> contributions;
  final String? contributionCondition, contributionHint;
  final int? grade;
  final String? haremRank;
  final String contributionTitle;
}

class MeetingContribution {
  const MeetingContribution({
    required this.title,
    required this.effect,
    required this.summary,
    required this.status,
    this.condition,
    required this.active,
    this.enhancement,
  });

  final String title, effect, summary, status;
  final String? condition, enhancement;
  final bool active;
}

class MeetingAction {
  const MeetingAction({
    required this.id,
    required this.label,
    required this.description,
    required this.costLabel,
    this.benefit,
    this.consequence,
    this.disabledReason,
    this.choices = const [],
    this.requiresConfirmation = true,
    this.choiceLabel = 'Chọn mức ban thưởng',
    this.choiceKeyPrefix = 'reward-choice',
  });

  final String id, label, description, costLabel;
  final String? benefit, consequence;
  final String? disabledReason;
  final List<MeetingActionChoice> choices;
  final bool requiresConfirmation;
  final String choiceLabel, choiceKeyPrefix;
}

class MeetingActionChoice {
  const MeetingActionChoice({
    required this.id,
    required this.label,
    required this.summary,
    required this.benefit,
    required this.costLabel,
    this.disabledReason,
  });

  final String id, label, summary, benefit, costLabel;
  final String? disabledReason;
}

Future<String?> confirmMeetingAction(
  BuildContext context,
  MeetingAction action,
) {
  var selected =
      action.choices.where((c) => c.disabledReason == null).firstOrNull;
  return showDialog<String>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setDialogState) => ImperialAlertDialog(
                key: const ValueKey('meeting-action-confirmation'),
                width: 520,
                title: Text(formatGameNumbers(action.label)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatGameNumbers(action.description)),
                    if (action.choices.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        formatGameNumbers(action.choiceLabel),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      for (final choice in action.choices)
                        RadioListTile<String>(
                          key: ValueKey(
                            '${action.choiceKeyPrefix}-${choice.id}',
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(formatGameNumbers(choice.label)),
                          subtitle: Text(
                            formatGameNumbers(
                              '${choice.summary}${choice.disabledReason == null ? '' : ' · ${choice.disabledReason}'}',
                            ),
                          ),
                          value: choice.id,
                          groupValue: selected?.id,
                          onChanged:
                              choice.disabledReason != null
                                  ? null
                                  : (_) =>
                                      setDialogState(() => selected = choice),
                        ),
                    ],
                    if (selected?.benefit != null ||
                        action.benefit != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Lợi ích',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formatGameNumbers(selected?.benefit ?? action.benefit!),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Chi phí',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      formatGameNumbers(
                        selected?.costLabel ?? action.costLabel,
                      ),
                    ),
                    if (action.consequence != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Lưu ý',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(formatGameNumbers(action.consequence!)),
                    ],
                  ],
                ),
                actions: [
                  OutlinedButton(
                    key: const ValueKey('meeting-action-cancel'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Bỏ qua'),
                  ),
                  FilledButton(
                    key: const ValueKey('meeting-action-confirm'),
                    onPressed:
                        action.disabledReason != null ||
                                (action.choices.isNotEmpty && selected == null)
                            ? null
                            : () => Navigator.pop(
                              context,
                              selected?.id ?? action.id,
                            ),
                    child: const Text('Thực hiện'),
                  ),
                ],
              ),
        ),
  );
}

/// Full-body scene with separate scenery, character art and conversation data.
class CharacterMeetingPage extends StatefulWidget {
  const CharacterMeetingPage({
    super.key,
    required this.scene,
    required this.backLabel,
    this.actions = const [],
    this.onAction,
    this.onProfile,
    this.onBack,
    this.header,
    this.profileLabel = 'Hồ sơ nhân vật',
    this.profileDescription,
    this.profileButtonKey = const ValueKey('meeting-profile'),
    this.profileIcon = Icons.badge_outlined,
    this.busy = false,
  });

  final MeetingScene scene;
  final Widget? header;
  final String backLabel, profileLabel;
  final String? profileDescription;
  final Key profileButtonKey;
  final IconData profileIcon;
  final List<MeetingAction> actions;
  final Future<String?> Function(String actionId)? onAction;
  final Future<void> Function()? onProfile;
  final VoidCallback? onBack;
  final bool busy;

  @override
  State<CharacterMeetingPage> createState() => _CharacterMeetingPageState();
}

class _CharacterMeetingPageState extends State<CharacterMeetingPage> {
  static const _jade = Color(0xFF123D34);
  static const _gold = Color(0xFFE1C38B);
  static const _ivory = Color(0xFFFFF6E4);
  bool _performingAction = false;
  bool _contributionsExpanded = false;
  String? _feedback;

  Future<void> _performAction(MeetingAction action) async {
    if (_performingAction ||
        widget.busy ||
        action.disabledReason != null ||
        widget.onAction == null) {
      return;
    }
    setState(() => _performingAction = true);
    try {
      final character = widget.scene;
      final confirmed =
          action.requiresConfirmation
              ? await confirmMeetingAction(context, action)
              : action.id;
      if (!mounted ||
          confirmed == null ||
          widget.busy ||
          widget.onAction == null) {
        return;
      }
      // The roster or available resources may have changed while confirming.
      final currentAction =
          widget.actions.where((a) => a.id == action.id).firstOrNull;
      if (currentAction == null ||
          currentAction.disabledReason != null ||
          character.name != widget.scene.name ||
          character.role != widget.scene.role ||
          character.characterAsset != widget.scene.characterAsset) {
        return;
      }
      if (currentAction.choices.isNotEmpty &&
          !currentAction.choices.any(
            (choice) => choice.id == confirmed && choice.disabledReason == null,
          )) {
        return;
      }
      final feedback = await widget.onAction!(confirmed);
      if (mounted) setState(() => _feedback = feedback);
    } finally {
      if (mounted) setState(() => _performingAction = false);
    }
  }

  Future<void> _openProfile() async {
    if (_performingAction || widget.busy || widget.onProfile == null) return;
    setState(() => _performingAction = true);
    try {
      await widget.onProfile!();
    } finally {
      if (mounted) setState(() => _performingAction = false);
    }
  }

  @override
  void didUpdateWidget(CharacterMeetingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.characterAsset != widget.scene.characterAsset ||
        oldWidget.scene.name != widget.scene.name) {
      _feedback = null;
      _contributionsExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('character-meeting-page'),
    backgroundColor: _jade,
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          widget.scene.backgroundAsset,
          key: const ValueKey('meeting-background'),
          fit: BoxFit.cover,
          alignment: const Alignment(-.35, 0),
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xA607211C), Color(0x0807211C), Color(0xA607211C)],
              stops: [0, .35, 1],
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, bounds) {
              final compact = bounds.maxWidth < 760;
              final portrait =
                  MediaQuery.orientationOf(context) == Orientation.portrait;
              return Column(
                children: [
                  widget.header ?? _header(compact),
                  Expanded(
                    child:
                        portrait
                            ? LayoutBuilder(
                              builder:
                                  (context, area) => Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _character(fullHeight: true),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: area.maxHeight * .57,
                                          ),
                                          child: _conversation(compact: true),
                                        ),
                                      ),
                                    ],
                                  ),
                            )
                            : compact
                            ? LayoutBuilder(
                              builder:
                                  (context, area) => Column(
                                    children: [
                                      Expanded(child: _character()),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: area.maxHeight * .57,
                                        ),
                                        child: _conversation(compact: true),
                                      ),
                                    ],
                                  ),
                            )
                            : Row(
                              children: [
                                Expanded(flex: 6, child: _character()),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      16,
                                      36,
                                      28,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 510,
                                        ),
                                        child: _conversation(
                                          compact: bounds.maxHeight < 600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _header(bool compact) => Padding(
    padding: EdgeInsets.fromLTRB(compact ? 12 : 28, 12, compact ? 16 : 36, 8),
    child: Row(
      children: [
        TextButton.icon(
          key: const ValueKey('meeting-back'),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: _ivory,
            backgroundColor: _jade.withValues(alpha: .88),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(color: _gold.withValues(alpha: .6)),
          ),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(
            formatGameNumbers(widget.backLabel),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            formatGameNumbers(widget.scene.location),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: compact ? 12 : 16,
              color: _ivory,
              shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _character({bool fullHeight = false}) => Padding(
    padding:
        fullHeight
            ? const EdgeInsets.fromLTRB(12, 20, 12, 20)
            : const EdgeInsets.fromLTRB(12, 8, 12, 10),
    child: Image.asset(
      widget.scene.characterAsset,
      key: const ValueKey('meeting-fullbody'),
      fit: fullHeight ? BoxFit.fitHeight : BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: '${widget.scene.name} toàn thân',
    ),
  );

  Widget _conversation({required bool compact}) => Container(
    margin:
        compact ? const EdgeInsets.fromLTRB(12, 0, 12, 12) : EdgeInsets.zero,
    decoration: BoxDecoration(
      color: _jade.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withValues(alpha: .75)),
      boxShadow: const [BoxShadow(color: Color(0x45000000), blurRadius: 24)],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SingleChildScrollView(
        key: const ValueKey('meeting-conversation'),
        padding: EdgeInsets.all(compact ? 18 : 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatGameNumbers(widget.scene.name),
              key: const ValueKey('meeting-name'),
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: compact ? 23 : 36,
                color: _ivory,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            if (widget.scene.grade != null) ...[
              CourtGradeBadge(
                widget.scene.grade!,
                key: const ValueKey('meeting-grade'),
              ),
              const SizedBox(height: 6),
            ],
            if (widget.scene.haremRank != null) ...[
              HaremRankBadge(
                widget.scene.haremRank!,
                key: const ValueKey('meeting-harem-rank'),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              formatGameNumbers(
                widget.scene.haremRank == null
                    ? '${widget.scene.role} · ${widget.scene.age} tuổi'
                    : '${widget.scene.age} tuổi',
              ),
              style: const TextStyle(fontSize: 12, color: _gold),
            ),
            SizedBox(height: compact ? 14 : 24),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    'Thiện cảm',
                    widget.scene.affection,
                    'affection',
                  ),
                ),
                if (widget.scene.haremRank == null) ...[
                  const SizedBox(width: 22),
                  Expanded(
                    child: _stat('Năng lực', widget.scene.ability, 'ability'),
                  ),
                ],
              ],
            ),
            SizedBox(height: compact ? 14 : 20),
            Row(
              children: [
                Expanded(
                  child: _stat('Âm mưu', widget.scene.investigatedPlot, 'plot'),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: _stat(
                    'Bất mãn',
                    widget.scene.investigatedDiscontent,
                    'discontent',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatGameNumbers(
                widget.scene.investigatedPlot == null
                    ? 'Chưa điều tra · Điều tra kín để biết âm mưu và bất mãn.'
                    : 'Ghi nhận${widget.scene.investigatedAt == null ? '' : ' ${widget.scene.investigatedAt}'} · Chỉ cập nhật khi điều tra tiếp theo hoàn tất.',
              ),
              key: const ValueKey('meeting-investigation-date'),
              style: TextStyle(
                color: _ivory.withValues(alpha: .7),
                fontSize: 10,
                height: 1.5,
              ),
            ),
            if (widget.scene.contributions.isNotEmpty) ...[
              SizedBox(height: compact ? 16 : 20),
              _contributions(compact),
            ],
            SizedBox(height: compact ? 16 : 28),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 14 : 20),
              decoration: BoxDecoration(
                color: _ivory,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatGameNumbers(widget.scene.description),
                key: const ValueKey('meeting-description'),
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: compact ? 14 : 17,
                  height: 1.7,
                  color: _jade,
                ),
              ),
            ),
            if (widget.actions.isNotEmpty || widget.onProfile != null) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, bounds) {
                  final width =
                      bounds.maxWidth < 280
                          ? bounds.maxWidth
                          : (bounds.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final action in widget.actions)
                        SizedBox(
                          width: width,
                          child: _actionButton(
                            key: ValueKey('meeting-action-${action.id}'),
                            label: action.label,
                            detail: action.disabledReason ?? action.costLabel,
                            description: [
                              action.description,
                              if (action.disabledReason != null)
                                action.disabledReason!,
                            ].join('\n'),
                            onPressed:
                                widget.busy ||
                                        _performingAction ||
                                        widget.onAction == null ||
                                        action.disabledReason != null
                                    ? null
                                    : () => _performAction(action),
                          ),
                        ),
                      if (widget.onProfile != null)
                        SizedBox(
                          width: width,
                          child: _actionButton(
                            key: widget.profileButtonKey,
                            label: widget.profileLabel,
                            detail:
                                widget.profileDescription ??
                                widget.profileLabel,
                            description:
                                widget.profileDescription ??
                                widget.profileLabel,
                            onPressed:
                                widget.busy || _performingAction
                                    ? null
                                    : _openProfile,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  formatGameNumbers(_feedback!),
                  key: const ValueKey('meeting-action-feedback'),
                  style: const TextStyle(color: _ivory, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _actionButton({
    required Key key,
    required String label,
    required String detail,
    required String description,
    required VoidCallback? onPressed,
  }) => Tooltip(
    message: formatGameNumbers(description),
    child: OutlinedButton(
      key: key,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ivory,
        disabledForegroundColor: _ivory.withValues(alpha: .45),
        side: BorderSide(
          color: _gold.withValues(alpha: onPressed == null ? .25 : .75),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: const Size(0, 70),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatGameNumbers(label),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (detail != label) ...[
            const SizedBox(height: 4),
            Text(
              formatGameNumbers(detail),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _contributions(bool compact) => Semantics(
    button: true,
    expanded: _contributionsExpanded,
    child: Material(
      key: const ValueKey('meeting-contributions'),
      color: _gold.withValues(alpha: .06),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _gold.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('meeting-contributions-toggle'),
        onTap:
            () => setState(
              () => _contributionsExpanded = !_contributionsExpanded,
            ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatGameNumbers(widget.scene.contributionTitle),
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 15,
                        color: _gold,
                      ),
                    ),
                  ),
                  Icon(
                    _contributionsExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: _gold,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder:
                    (context, bounds) => Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final (index, contribution)
                            in widget.scene.contributions.indexed)
                          Tooltip(
                            message: formatGameNumbers(contribution.status),
                            child: Semantics(
                              label: formatGameNumbers(
                                '${contribution.summary}. ${contribution.status}',
                              ),
                              excludeSemantics: true,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: bounds.maxWidth,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _ivory.withValues(alpha: .05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      key: ValueKey(
                                        'meeting-contribution-dot-$index',
                                      ),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            contribution.active
                                                ? const Color(0xFFAFE2BC)
                                                : const Color(0xFF89928F),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        formatGameNumbers(contribution.summary),
                                        key: ValueKey(
                                          'meeting-contribution-summary-$index',
                                        ),
                                        style: TextStyle(
                                          color:
                                              contribution.active
                                                  ? _ivory
                                                  : _ivory.withValues(
                                                    alpha: .65,
                                                  ),
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
              ),
              if (widget.scene.contributionHint != null) ...[
                const SizedBox(height: 6),
                Text(
                  formatGameNumbers(widget.scene.contributionHint!),
                  style: TextStyle(
                    color: _ivory.withValues(alpha: .65),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
              if (_contributionsExpanded)
                Column(
                  key: const ValueKey('meeting-contributions-details'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 20, color: _gold.withValues(alpha: .25)),
                    if (widget.scene.contributionCondition != null)
                      Text(
                        formatGameNumbers(widget.scene.contributionCondition!),
                        style: TextStyle(
                          color: _ivory.withValues(alpha: .75),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    for (final (index, contribution)
                        in widget.scene.contributions.indexed) ...[
                      const SizedBox(height: 10),
                      if (index > 0)
                        Text(
                          formatGameNumbers(contribution.title),
                          style: const TextStyle(color: _gold, fontSize: 12),
                        ),
                      Text(
                        formatGameNumbers(contribution.effect),
                        key: ValueKey('meeting-contribution-effect-$index'),
                        style: const TextStyle(
                          color: _ivory,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatGameNumbers(contribution.status),
                        key: ValueKey('meeting-contribution-status-$index'),
                        style: TextStyle(
                          color:
                              contribution.active
                                  ? const Color(0xFFAFE2BC)
                                  : _gold,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                      if (contribution.condition != null)
                        Text(
                          formatGameNumbers(contribution.condition!),
                          style: TextStyle(
                            color: _ivory.withValues(alpha: .75),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                    ],
                    for (final enhancement
                        in widget.scene.contributions
                            .map((c) => c.enhancement)
                            .whereType<String>()
                            .toSet()) ...[
                      const SizedBox(height: 6),
                      Text(
                        formatGameNumbers(enhancement),
                        style: TextStyle(
                          color: _ivory.withValues(alpha: .75),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _stat(String label, num? value, String id) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            formatGameNumbers(label),
            style: const TextStyle(color: _ivory, fontSize: 11),
          ),
          Text(
            formatGameNumbers(
              value == null
                  ? 'Chưa rõ'
                  : ['affection', 'ability'].contains(id)
                  ? '$value'
                  : '$value/100',
            ),
            key: ValueKey('meeting-$id'),
            style: const TextStyle(color: _gold, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: (value ?? 0).clamp(0, 100) / 100,
          minHeight: 4,
          backgroundColor: _ivory.withValues(alpha: .15),
          color: _gold,
          semanticsLabel: label,
          semanticsValue:
              value == null
                  ? 'Chưa rõ'
                  : ['affection', 'ability'].contains(id)
                  ? '$value'
                  : '$value/100',
        ),
      ),
    ],
  );
}
