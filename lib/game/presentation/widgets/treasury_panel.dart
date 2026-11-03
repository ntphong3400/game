import '../../models/number_format.dart';
import '../../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import '../../logic/population_rules.dart';
import '../../data/content.dart';
import '../../logic/finance_rules.dart';
import '../../logic/personnel_rules.dart';
import '../../models/game_state.dart';
import 'finance_panel.dart';
import 'imperial_assets.dart';
import 'imperial_theme.dart';
import 'kingdom_style.dart';
import 'memorial_paper.dart';
import 'petition_art.dart';

class TreasuryPanel extends StatefulWidget {
  const TreasuryPanel({
    super.key,
    required this.state,
    required this.section,
    required this.onSectionChanged,
    required this.busy,
    required this.onAction,
    required this.blockedReason,
    required this.onPolicy,
  });
  final GameState state;
  final int section;
  final ValueChanged<int> onSectionChanged;
  final bool busy;
  final Future<void> Function(ActionDefinition) onAction;
  final String? Function(ActionDefinition) blockedReason;
  final Future<void> Function(String type, String option) onPolicy;
  @override
  State<TreasuryPanel> createState() => _TreasuryPanelState();
}

class _TreasuryPanelState extends State<TreasuryPanel> {
  final ledgerScroll = ScrollController();
  final documentScroll = ScrollController();
  int get section => widget.section;
  GameState get s => widget.state;
  static const titles = [
    'Thuế & ngân sách',
    'Việc tăng thu',
    'Kho lương & đê điều',
    'Đang thực hiện',
  ];
  static const paintings = [
    'assets/images/kingdom/dossier-obligations.webp',
    'assets/images/petitions/trade.webp',
    'assets/images/petitions/river.webp',
    'assets/images/kingdom/dossier-progress.webp',
  ];

  @override
  void dispose() {
    ledgerScroll.dispose();
    documentScroll.dispose();
    super.dispose();
  }

  void open(int value) {
    widget.onSectionChanged(value);
    if (value != 0 && documentScroll.hasClients) documentScroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final portrait =
          MediaQuery.orientationOf(context) == Orientation.portrait;
      final wide =
          !portrait && bounds.maxWidth >= 920 && bounds.maxHeight >= 360;
      final dense = bounds.maxHeight < 430;
      final primary = IndexedStack(
        index: section == 0 ? 0 : 1,
        children: [
          _scroll(
            ledgerScroll,
            'treasury-ledger-scroll',
            const PageStorageKey('treasury-ledger-position'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (portrait) ...[
                  _header(),
                  const SizedBox(height: 20),
                  for (var i = 1; i <= 4; i++) _portraitDossier(i),
                  const SizedBox(height: 12),
                ],
                FinancePanel(state: s, flat: true),
              ],
            ),
          ),
          section == 0
              ? const SizedBox.shrink()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _scroll(
                      documentScroll,
                      'treasury-document-scroll',
                      ValueKey('treasury-document-position-$section'),
                      _document(),
                    ),
                  ),
                ],
              ),
        ],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!dense && !portrait) ...[_header(), const SizedBox(height: 16)],
          Expanded(
            child:
                wide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: primary),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              for (var i = 1; i <= 4; i++) ...[
                                if (i > 1) const SizedBox(height: 5),
                                Expanded(child: _dossier(i)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (section == 0 && !portrait) ...[
                          _shortcuts(
                            dense: dense,
                            horizontal: dense && bounds.maxWidth >= 600,
                            terse: bounds.maxHeight < 260,
                          ),
                          const SizedBox(height: 10),
                        ],
                        Expanded(child: primary),
                      ],
                    ),
          ),
        ],
      );
    },
  );

  Widget _scroll(
    ScrollController controller,
    String key,
    Key positionKey,
    Widget child,
  ) => Scrollbar(
    controller: controller,
    thumbVisibility: true,
    child: SingleChildScrollView(
      key: ValueKey(key),
      controller: controller,
      primary: false,
      padding: const EdgeInsets.fromLTRB(4, 0, 14, 8),
      child: KeyedSubtree(key: positionKey, child: child),
    ),
  );

  Widget _header() => const Row(
    children: [
      ImperialIcon('treasury', size: 44),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngân khố',
              style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 1.2),
            ),
            SizedBox(height: 4),
            Text(
              'Xem sổ tiền, định thuế, giao việc tăng thu.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    ],
  );

  String _summary(int value) => switch (value) {
    1 =>
      'Thuế ${taxLabels[s.tax]}${s.foodPressureEnabled ? '' : ' · ưu tiên ${s.priority == 'army' ? 'quân đội' : 'cứu tế'}'}',
    2 => 'Truy thu · bán lương · thương mại',
    3 =>
      '${whole(s.grain)}${s.population == null ? '' : '/${whole(foodCapacity(s))}'} ${foodUnit(s)} · Đê điều ${s.levee}/100',
    _ =>
      s.projects.isNotEmpty
          ? '${projectTitle(s.projects.first.kind)} · ${s.projects.first.progress}/${s.projects.first.duration} kỳ'
          : s.pending.isNotEmpty
          ? s.pending.first.title.isEmpty
              ? 'Chờ kết quả'
              : s.pending.first.title
          : 'Chưa có công việc dài hạn',
  };

  String _preview(int value) => switch (value) {
    1 =>
      s.seasonal
          ? 'Vụ Thu: dự kiến thu ${annualTaxRevenue(s, year: s.nextTaxYear)} ${moneyUnit(s)}'
          : 'Thu chi theo chính sách hiện tại',
    2 =>
      s.seasonal
          ? 'Nâng cấp kinh tế · các việc tăng thu'
          : '3 cách tăng thu · chọn quan phụ trách',
    3 => 'Bổ sung dự trữ, tu bổ tuyến đê',
    _ => '${s.projects.length + s.pending.length} công việc đang theo dõi',
  };

  Widget _painting(int value, {bool thumbnail = false}) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback:
        (rect) => LinearGradient(
          begin: thumbnail ? Alignment.centerLeft : Alignment.topCenter,
          end: thumbnail ? Alignment.centerRight : Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0, .06, .82, 1],
        ).createShader(rect),
    child: Image.asset(
      paintings[value - 1],
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.medium,
    ),
  );

  Widget _dossier(int value) => LayoutBuilder(
    builder: (context, bounds) {
      // Include the paper margins and text padding in the compact breakpoint.
      final small =
          bounds.maxHeight < 128 ||
          MediaQuery.textScalerOf(context).scale(14) > 17;
      return MemorialPaper(
        readKey: ValueKey('treasury-paper-$value'),
        child: TextButton(
          key: ValueKey('treasury-open-$value'),
          onPressed: () => open(value),
          style: TextButton.styleFrom(
            foregroundColor: ink,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (section == value)
                Container(
                  width: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: forest,
                ),
              SizedBox(
                width: (bounds.maxWidth * .29).clamp(58.0, 125.0),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _painting(value, thumbnail: true),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, small ? 7 : 11, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        formatGameNumbers(titles[value - 1]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: small ? 13 : 15,
                          height: 1.3,
                        ),
                      ),
                      if (!small) ...[
                        const SizedBox(height: 6),
                        Text(
                          formatGameNumbers(_summary(value)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: forest),
                        ),
                        if (value == 4 && s.projects.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value:
                                s.projects.first.duration > 0
                                    ? (s.projects.first.progress /
                                            s.projects.first.duration)
                                        .clamp(0.0, 1.0)
                                    : 0,
                            minHeight: 4,
                            backgroundColor: line,
                            color: forest,
                          ),
                        ],
                      ],
                      const Spacer(),
                      if (!small)
                        Text(
                          formatGameNumbers(_preview(value)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: muted),
                        ),
                      const SizedBox(height: 5),
                      const Text(
                        'Mở sổ →',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          color: forest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _portraitDossier(int value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: MemorialPaper(
      readKey: ValueKey('treasury-paper-$value'),
      child: TextButton(
        key: ValueKey('treasury-open-$value'),
        onPressed: () => open(value),
        style: TextButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.all(12),
          minimumSize: Size.zero,
          textStyle: const TextStyle(fontFamily: 'BeVietnam'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 84,
                  height: 112,
                  child: _painting(value, thumbnail: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatGameNumbers(titles[value - 1]),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 17,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatGameNumbers(_summary(value)),
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: forest,
                        ),
                      ),
                      if (value == 4 && s.projects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value:
                              s.projects.first.duration > 0
                                  ? (s.projects.first.progress /
                                          s.projects.first.duration)
                                      .clamp(0.0, 1.0)
                                  : 0,
                          minHeight: 4,
                          backgroundColor: line,
                          color: forest,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              formatGameNumbers(_preview(value)),
              style: const TextStyle(fontSize: 12, height: 1.6, color: muted),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Mở sổ',
                  style: TextStyle(
                    fontSize: 11,
                    color: forest,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 15, color: forest),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _shortcuts({
    required bool dense,
    required bool horizontal,
    required bool terse,
  }) {
    final columns = horizontal ? 4 : 2;
    return Column(
      children: [
        for (var i = 1; i <= 4; i += columns) ...[
          if (i > 1) const SizedBox(height: 3),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) const SizedBox(width: 5),
                  Expanded(
                    child: MemorialPaper(
                      readKey: ValueKey('treasury-paper-${i + j}'),
                      child: TextButton(
                        key: ValueKey('treasury-open-${i + j}'),
                        onPressed: () => open(i + j),
                        style: TextButton.styleFrom(
                          foregroundColor: forest,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: dense ? 7 : 10,
                          ),
                          minimumSize: const Size(0, 44),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              formatGameNumbers(
                                terse
                                    ? const [
                                      'Thuế',
                                      'Tăng thu',
                                      'Kho & đê',
                                      'Tiến độ',
                                    ][i + j - 1]
                                    : titles[i + j - 1],
                              ),
                              semanticsLabel: formatGameNumbers(
                                titles[i + j - 1],
                              ),
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: dense ? 11 : 13,
                                height: 1.3,
                              ),
                            ),
                            if (!dense) ...[
                              const SizedBox(height: 5),
                              Text(
                                formatGameNumbers(_summary(i + j)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _document() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (section != 0) ...[
        SizedBox(height: 110, child: _painting(section)),
        Text(
          formatGameNumbers(
            'HỘ BỘ · ${section == 1
                ? 'CHÍNH SÁCH'
                : section == 4
                ? 'THEO DÕI'
                : 'GIAO VIỆC'}',
          ),
          style: const TextStyle(
            fontSize: 10,
            color: forest,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          formatGameNumbers(titles[section - 1]),
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 24,
            color: forest,
          ),
        ),
        const SizedBox(height: 14),
        const PetitionRule(),
        const SizedBox(height: 16),
        if (section == 1) _policies(),
        if (section == 2) ...[
          if (s.seasonal) ...[
            Text(
              formatGameNumbers(
                'Kinh tế cấp ${s.economyLevel}/5 · tăng thuế nền '
                '+${money(s, economyAnnualBonus(s))} ${moneyUnit(s)}/năm',
              ),
              key: const ValueKey('economy-development-summary'),
            ),
            const SizedBox(height: 12),
            _action(actions.firstWhere((a) => a.id == 'upgrade_economy')),
          ],
          for (final action in actions.where(
            (a) => revenueTasks.contains(a.id),
          ))
            _action(action),
        ],
        if (section == 3) ...[
          _stocks(),
          for (final action in actions.where(
            (a) => [
              'buy_grain',
              'repair',
              'maintain_levee',
              if (s.seasonal) ...['upgrade_farm', 'upgrade_levee'],
            ].contains(a.id),
          ))
            _action(action),
        ],
        if (section == 4) _ongoing(),
      ],
    ],
  );

  Widget _policies() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        formatGameNumbers(
          s.seasonal ? 'Mức thuế cho kỳ thu hoạch tới' : 'Mức thuế mỗi tuần',
        ),
        style: const TextStyle(fontFamily: 'Lora', fontSize: 17),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < 3; i++)
            ChoiceChip(
              label: Text(formatGameNumbers('Thuế ${taxLabels[i]}')),
              selected: s.tax == i,
              onSelected:
                  widget.busy || s.points == 0
                      ? null
                      : (_) => widget.onPolicy('tax', '$i'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        formatGameNumbers(
          s.seasonal
              ? '${taxPolicyHint(s)}\nĐổi mức thuế tốn 1 hành động. Chỉ thu tiền và áp dụng tác động lòng dân khi khép mùa Thu: nhẹ +4, vừa 0, cao −8.'
              : 'Thay chính sách tốn 1 hành động. Thuế cao tăng nguồn thu nhưng làm lòng dân giảm mỗi ${s.periodName}.',
        ),
        key: const ValueKey('tax-policy-timing'),
        style: const TextStyle(fontSize: 11, color: muted),
      ),
      if (s.seasonal) ...[
        const SizedBox(height: 12),
        Text(
          formatGameNumbers(
            'Tạm tính kỳ ${s.date(s.nextTaxTurn)}: +${annualTaxRevenue(s, year: s.nextTaxYear)} ${moneyUnit(s)}. ${s.autumnTaxDue ? 'Khoản này có trong dự toán cuối mùa Thu.' : 'Không có thuế trong dự toán mùa này; số dự kiến chưa được cộng vào ngân khố.'}',
          ),
          key: const ValueKey('treasury-tax-estimate'),
          style: const TextStyle(fontSize: 12, color: forest),
        ),
      ],
      if (s.population != null) ...[
        const SizedBox(height: 22),
        const Text(
          'Ưu tiên sản xuất',
          style: TextStyle(fontFamily: 'Lora', fontSize: 17),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final policy in populationPolicies.entries)
              ChoiceChip(
                key: ValueKey('production-${policy.key}'),
                label: Text(
                  formatGameNumbers(
                    '${policy.value} (${policy.key == 'economy'
                        ? '80/20'
                        : policy.key == 'army'
                        ? '20/80'
                        : '50/50'})',
                  ),
                ),
                selected: s.population!.nextPolicy == policy.key,
                onSelected:
                    widget.busy || s.points == 0
                        ? null
                        : (_) => widget.onPolicy('production', policy.key),
              ),
          ],
        ),
        Text(
          formatGameNumbers(
            'Kinh tế / quân khí, trong nhóm 30% sản xuất thương mại. Đang hiệu lực: ${populationPolicies[s.population!.policy]}. Chọn cho mùa tới, tốn 1 hành động.',
          ),
          style: const TextStyle(fontSize: 11, color: muted),
        ),
      ],
      if (!s.foodPressureEnabled) ...[
        const SizedBox(height: 22),
        const Text(
          'Ưu tiên khi thiếu tiền',
          style: TextStyle(fontFamily: 'Lora', fontSize: 17),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Ưu tiên quân đội'),
              selected: s.priority == 'army',
              onSelected:
                  widget.busy || s.points == 0
                      ? null
                      : (_) => widget.onPolicy('priority', 'army'),
            ),
            ChoiceChip(
              label: const Text('Ưu tiên cứu tế'),
              selected: s.priority == 'people',
              onSelected:
                  widget.busy || s.points == 0
                      ? null
                      : (_) => widget.onPolicy('priority', 'people'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Chọn chính sách để ban hành. Thay chính sách tốn 1 hành động. Khoản được ưu tiên sẽ thanh toán trước khi ngân khố không đủ trả tất cả.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    ],
  );

  Widget _stocks() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 26,
        runSpacing: 10,
        children: [
          _stockValue(
            'Lương thực dự trữ',
            '${whole(s.grain)} / ${whole(foodCapacity(s))} ${foodUnit(s)}',
          ),
          _stockValue('Tình trạng đê điều', '${s.levee}/100'),
          if (s.seasonal) ...[
            _stockValue('Cấp nông nghiệp', '${s.agricultureLevel}/5'),
            _stockValue('Cấp công trình đê', '${s.leveeLevel}/5'),
          ],
        ],
      ),
      const SizedBox(height: 14),
      if (s.seasonal) ...[
        Text(
          formatGameNumbers(harvestPlan(s)),
          key: const ValueKey('agriculture-harvest-plan'),
          style: const TextStyle(fontSize: 12, height: 1.7),
        ),
        const SizedBox(height: 8),
        Text(
          formatGameNumbers(
            'Đê cấp ${s.leveeLevel}: giảm ${leveeWearReductions[s.leveeLevel]}% hao mòn. '
            '${s.population == null ? '' : 'Giảm ${leveeDisasterReductions[s.leveeLevel]}% thiệt hại tình trạng đê do thiên tai. '}'
            'Cuối mùa ${s.season} dự kiến −${leveeWearThisSeason(s)} điểm. '
            'Mốc đê và sản lượng: 0: 30%, 30: 60%, 60: 100%, '
            '80: 110%, 95–100: 120%.',
          ),
          key: const ValueKey('levee-development-summary'),
          style: const TextStyle(fontSize: 11, height: 1.7, color: muted),
        ),
        if (s.lastHarvestYear > 0)
          Text(
            formatGameNumbers(
              'Vụ Thu năm ${s.lastHarvestYear}: +${whole(s.lastHarvestAmount)} ${foodUnit(s)}; '
              'đê cả vụ ${s.lastHarvestLeveePercent.toStringAsFixed(1)}%, '
              'thời tiết ${s.lastHarvestWeather}%.',
            ),
            style: const TextStyle(fontSize: 11, height: 1.7),
          ),
        const SizedBox(height: 14),
      ],
      Text(
        formatGameNumbers(
          s.war == 0
              ? 'Biên giới: tạm yên'
              : 'Chiến tranh: mức ${s.war} · áp sát kinh thành ${s.siege}/4',
        ),
        style: TextStyle(fontSize: 11, color: s.war > 0 ? terracotta : forest),
      ),
      const SizedBox(height: 16),
    ],
  );
  Widget _stockValue(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        formatGameNumbers(title),
        style: const TextStyle(fontSize: 11, color: muted),
      ),
      Text(
        formatGameNumbers(value),
        style: const TextStyle(fontFamily: 'Lora', fontSize: 25, color: forest),
      ),
    ],
  );

  Widget _action(ActionDefinition action) {
    final reason = widget.blockedReason(action);
    final summary = switch (action.id) {
      'collect_arrears' => 'Thu hồi tiền thuế còn thiếu.',
      'sell_surplus' => 'Đổi thóc dự trữ lấy tiền.',
      'commerce' => 'Ứng vốn trước, nhận doanh thu khi đoàn trở về.',
      'buy_grain' => 'Giao quan thu mua, bổ sung thóc dự trữ.',
      'upgrade_economy' => 'Đầu tư lâu dài, tăng nguồn thu vụ Thu.',
      'upgrade_farm' => 'Tăng sản lượng nền cho các vụ mùa sau.',
      'upgrade_levee' => 'Tăng độ bền công trình, giảm công bảo dưỡng.',
      'maintain_levee' => 'Phục hồi tình trạng đê, bảo vệ năng suất vụ mùa.',
      _ => 'Gia cố tuyến đê để phòng lũ.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MemorialPaper(
        readKey: ValueKey('treasury-action-paper-${action.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 15, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formatGameNumbers(taskSpecialties[action.id] ?? 'Kinh tế'),
                style: const TextStyle(
                  fontSize: 10,
                  color: forest,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatGameNumbers(action.title),
                style: const TextStyle(fontFamily: 'Lora', fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                formatGameNumbers(summary),
                style: const TextStyle(fontSize: 11, color: muted),
              ),
              if (developmentTasks.contains(action.id)) ...[
                const SizedBox(height: 8),
                Text(
                  formatGameNumbers(developmentDescription(s, action.id)),
                  style: const TextStyle(fontSize: 11, height: 1.6),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: [
                  KingdomPill(
                    '${actionCost(s, action)} ${moneyUnit(s)}',
                    icon: Icons.toll_outlined,
                    color: gold,
                  ),
                  if (actionGrainCost(s, action) > 0)
                    KingdomPill(
                      '${whole(actionGrainCost(s, action))} ${foodUnit(s)}',
                      icon: Icons.grass_outlined,
                      color: gold,
                    ),
                  const KingdomPill(
                    '1 hành động',
                    icon: Icons.directions_walk_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Tooltip(
                message: formatGameNumbers(action.title),
                child: OutlinedButton(
                  key: ValueKey('action-${action.id}'),
                  onPressed:
                      reason == null ? () => widget.onAction(action) : null,
                  style: OutlinedButton.styleFrom(
                    backgroundBuilder:
                        (context, states, child) => KingdomButtonFrame(
                          child: child ?? const SizedBox(),
                        ),
                    foregroundColor: forest,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: Text('Xem & giao việc')),
                      Icon(Icons.arrow_forward, size: 17),
                    ],
                  ),
                ),
              ),
              if (reason != null) ...[
                const SizedBox(height: 6),
                Text(
                  formatGameNumbers(reason),
                  style: const TextStyle(fontSize: 11, color: terracotta),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _ongoing() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (s.projects.isEmpty && s.pending.isEmpty)
        const Text(
          'Chưa có công việc dài hạn. Hãy chọn người và giao việc.',
          style: TextStyle(color: muted),
        ),
      for (final p in s.projects) ...[
        _work(
          '${projectTitle(p.kind)}${p.targetLevel > 0 ? ' · cấp ${p.targetLevel}' : ''} · ${s.court.where((c) => c.id == p.officerId).firstOrNull?.name ?? 'Người phụ trách'}',
          '${p.progress}/${p.duration} kỳ · ${developmentTasks.contains(p.kind) && developmentNeedsOfficer(s, p) ? 'Tạm dừng, cần bổ nhiệm người thay' : 'dự kiến cuối ${s.date(s.week + p.duration - p.progress - 1)}'}\n'
              '${p.targetLevel > 0 ? 'Ước tính ${p.estimatedChance}% thành công; thất bại giữ nguyên cấp, không hoàn vốn. Cấp mới có hiệu lực từ mùa sau khi hoàn thành.' : 'Khi hoàn tất sẽ xét chuyên môn và năng lực; có thể thất bại.'}',
          progress:
              p.duration > 0 ? (p.progress / p.duration).clamp(0.0, 1.0) : 0,
        ),
        if (developmentTasks.contains(p.kind) && developmentNeedsOfficer(s, p))
          _action(actions.firstWhere((a) => a.id == p.kind)),
      ],
      for (final p in s.pending)
        _work(
          p.title.isNotEmpty ? p.title : _pendingName(p.kind),
          'Dự kiến cuối ${s.date(p.dueWeek)}${p.assignment == null ? '' : '\n${p.assignment!.personLabel} · ${p.assignment!.chance}% thành công'}',
        ),
    ],
  );
  Widget _work(String title, String detail, {double? progress}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: MemorialPaper(
      readKey: ValueKey('treasury-work-$title'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              formatGameNumbers(title),
              style: const TextStyle(fontFamily: 'Lora', fontSize: 16),
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: line,
                color: forest,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              formatGameNumbers(detail),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    ),
  );
  String _pendingName(String key) => switch (key) {
    'envoy' => 'Sứ đoàn hòa đàm',
    'investigate' => 'Điều tra nhân vật',
    'audit' => 'Kiểm toán',
    'trade' => 'Thương lộ',
    'school' => 'Xây lớp học',
    'weapons' => 'Quân khí',
    'security' => 'Điều tra tin mật',
    _ => key,
  };
}
