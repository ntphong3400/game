import '../../models/number_format.dart';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../../logic/currency_rules.dart';
import '../../logic/population_rules.dart';
import '../../models/game_state.dart';
import 'imperial_assets.dart';
import 'hud_policy.dart';

const _jade = Color(0xFF16372F);
const _deep = Color(0xFF102922);
const _gold = Color(0xFFD9B873);
const _ivory = Color(0xFFFFF1CE);

/// Web HUD stays on one row; narrow windows scroll only the counters.
/// All counters are read from the save; opening a detail only navigates.
class WebGameHud extends StatelessWidget {
  const WebGameHud({
    super.key,
    required this.state,
    required this.onNavigate,
    required this.section,
    this.onBack,
    this.backLabel = 'Về Giang Sơn',
  });

  final GameState state;
  final ValueChanged<String> onNavigate;
  final String section, backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final compactBrand = bounds.maxWidth < 720;
      final textScaler = MediaQuery.textScalerOf(context);
      final counterHeight = math.max(
        48.0,
        (8 +
                math.max(24, textScaler.scale(17) * 1.2) +
                3 +
                textScaler.scale(10) * 1.2)
            .ceilToDouble(),
      );
      final population = state.population?.population;
      final militaryRoute = population == null ? 'kingdom' : 'military';
      final stats = <_HudStat>[
        _HudStat(
          'treasury',
          'Ngân khố',
          moneyNumber(state.treasury),
          moneyText(state, state.treasury),
          'treasury',
          'treasury',
        ),
        _HudStat(
          'population',
          'Số dân',
          population == null ? '—' : whole(population),
          population == null
              ? 'Bản lưu cũ chưa có dữ liệu dân số'
              : '${whole(population)} người',
          population == null ? 'kingdom' : 'population',
          'citizens',
        ),
        _HudStat(
          'food',
          'Lương thực',
          whole(state.grain),
          '${whole(state.grain)} ${foodUnit(state)}',
          'treasury',
          'grain',
          unit: foodUnit(state),
        ),
        _HudStat(
          'military',
          'Quân lực',
          whole(militaryStrength(state)),
          population == null
              ? '${state.army}/100'
              : '${whole(militaryStrength(state))} điểm sức mạnh quân sự',
          militaryRoute,
          'army',
        ),
        _HudStat(
          'people',
          'Lòng dân',
          '${state.people}',
          '${state.people}/100',
          'court',
          'citizens',
          warning: state.people <= 20,
        ),
        _HudStat(
          'authority',
          'Uy quyền',
          '${state.authority}',
          '${state.authority}/100',
          'court',
          'authority',
          warning: state.authority <= 20,
        ),
        _HudStat(
          'health',
          'Sức khỏe',
          '${state.health}',
          '${state.health}/100',
          'health',
          'health',
          warning: state.health <= 20,
        ),
        _HudStat(
          'stability',
          'Ổn định',
          '${state.stability}',
          '${state.stability}/100',
          'court',
          'stability',
          warning: state.stability <= 20,
        ),
      ];

      final visible =
          stats.where((s) => hudMetricsFor(section).contains(s.id)).toList();
      final resourceIds = allHudMetrics.take(4).toSet();
      final hasDivider =
          visible.any((s) => resourceIds.contains(s.id)) &&
          visible.any((s) => !resourceIds.contains(s.id));
      return Container(
        key: const ValueKey('web-game-hud'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_deep, _jade, _deep]),
          image: DecorationImage(
            image: AssetImage('assets/images/imperial/jade-texture.webp'),
            fit: BoxFit.cover,
            opacity: .22,
          ),
          border: Border(bottom: BorderSide(color: _gold)),
        ),
        child: Row(
          children: [
            SizedBox(
              width:
                  compactBrand
                      ? (onBack == null ? 0 : 48)
                      : (bounds.maxWidth < 900 ? 130 : 160),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      key: const ValueKey('section-back'),
                      tooltip: backLabel,
                      onPressed: onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                      icon: const Icon(Icons.arrow_back, color: _gold),
                    )
                  else if (!compactBrand) ...[
                    const ImperialIcon('authority', size: 32),
                    const SizedBox(width: 8),
                  ],
                  if (!compactBrand)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VẠN TUẾ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 16,
                              height: 1.2,
                              color: _ivory,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            formatGameNumbers(state.playerName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: _gold,
                            ),
                          ),
                          Text(
                            formatGameNumbers(
                              'Năm trị vì ${state.year} · ${state.age} tuổi',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.2,
                              color: _ivory,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (visible.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: counterHeight,
                  child: LayoutBuilder(
                    builder:
                        (context, strip) => ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: PointerDeviceKind.values.toSet(),
                          ),
                          child: SingleChildScrollView(
                            key: const ValueKey('web-hud-stat-scroll'),
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: math.max(
                                strip.maxWidth,
                                visible.length *
                                        (visible.length <= 3 ? 88 : 100) +
                                    (hasDivider ? 17 : 0),
                              ),
                              child: Row(
                                key: const ValueKey('web-hud-one-row'),
                                children: [
                                  for (var i = 0; i < visible.length; i++) ...[
                                    if (i > 0 &&
                                        resourceIds.contains(
                                          visible[i - 1].id,
                                        ) &&
                                        !resourceIds.contains(visible[i].id))
                                      Container(
                                        width: 1,
                                        height: 32,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        color: _gold.withValues(alpha: .35),
                                      ),
                                    Expanded(child: _counter(visible[i])),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(width: 12),
            SizedBox(
              width: compactBrand ? 90 : 130,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatGameNumbers(
                      state.seasonal
                          ? 'Mùa ${state.season}'
                          : 'Tuần ${state.week}',
                    ),
                    key: const ValueKey('room-calendar'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 15,
                      height: 1.2,
                      color: _ivory,
                    ),
                  ),
                  Text(
                    formatGameNumbers('Thiên Hòa · năm ${state.year}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      color: _gold,
                    ),
                  ),
                  if (section != 'journal')
                    Text(
                      formatGameNumbers(
                        section == 'citadel'
                            ? '${state.points} hành động còn lại'
                            : '${state.points} hành động',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      key:
                          section == 'citadel'
                              ? const ValueKey('citadel-actions')
                              : null,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        color: _ivory,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _counter(_HudStat stat) => Tooltip(
    message: formatGameNumbers(
      '${stat.id == 'stability' ? 'Ổn định triều đình' : stat.label}: ${stat.detail} · Nhấn để xem chi tiết',
    ),
    child: InkWell(
      key: ValueKey('web-hud-stat-${stat.id}'),
      onTap: () => onNavigate(stat.route),
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImperialIcon(stat.icon, size: 24),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatGameNumbers(stat.value),
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 17,
                        height: 1.2,
                        color: stat.warning ? const Color(0xFFFFAA90) : _ivory,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              formatGameNumbers(
                stat.unit == null ? stat.label : '${stat.label} (${stat.unit})',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, height: 1.2, color: _ivory),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HudStat {
  const _HudStat(
    this.id,
    this.label,
    this.value,
    this.detail,
    this.route,
    this.icon, {
    this.unit,
    this.warning = false,
  });
  final String id, label, value, detail, route, icon;
  final String? unit;
  final bool warning;
}
