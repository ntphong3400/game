import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../../app/game_controller.dart';
import '../../models/game_state.dart';
import '../../logic/frontier_rules.dart';
import '../../logic/population_rules.dart';
import '../../logic/warfare_rules.dart';
import 'country_routes.dart';
import 'frontier_routes.dart';
import 'imperial_theme.dart';
import 'warfare_panel.dart';

class CountryPanel extends StatelessWidget {
  const CountryPanel({
    super.key,
    required this.state,
    required this.controller,
    required this.countryId,
    required this.place,
    required this.onNavigate,
  });
  final GameState state;
  final GameController controller;
  final String countryId, place;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final country =
        state.warfare?.neighbors.where((n) => n.id == countryId).firstOrNull;
    if (country == null || state.population == null) {
      return ListView(
        children: [
          const Text(
            'Bản lưu này chưa có hệ thống bang giao và quân sự giữa các nước.',
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => onNavigate('kingdom'),
            child: const Text('Đến Quốc sự'),
          ),
        ],
      );
    }
    final missions =
        state.warfare!.missions
            .where((m) => m.countryId == countryId && liveMission(m))
            .toList();
    return ListView(
      key: ValueKey('country-panel-$countryId-$place'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
      children: [
        Text(
          formatGameNumbers('${country.name} · ${country.direction}'),
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        Text(
          formatGameNumbers(
            '${neighborStatus(country)} · Quan hệ ${country.relation} · Ưu thế của ta ${country.advantage}',
          ),
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 17,
            color: forest,
          ),
        ),
        if (place == 'palace') ...[
          const SizedBox(height: 12),
          const Text(
            'Giao thiệp với vương triều nước bạn. Mỗi quyết định có chi phí và ảnh hưởng đến quan hệ hai nước.',
          ),
          if (country.status == 'war' || country.status == 'treaty') ...[
            const SizedBox(height: 12),
            Text(
              formatGameNumbers(
                country.status == 'war'
                    ? 'Hai nước đang chiến tranh. Đến Sứ quán để thương lượng đình chiến hoặc cầu hòa.'
                    : 'Hai nước đang có hòa ước. Đến Sứ quán để xem điều khoản và nghĩa vụ triều cống.',
              ),
            ),
            OutlinedButton(
              onPressed: () => onNavigate(countryRoute(countryId, 'embassy')),
              child: const Text('Đến Sứ quán'),
            ),
          ],
          WarfarePanel(
            state: state,
            controller: controller,
            countryId: countryId,
            showTreaties: false,
            showMissions: false,
            showReports: false,
          ),
        ],
        if (place == 'embassy') ...[
          const SizedBox(height: 12),
          const Text(
            'Thương lượng hòa bình, theo dõi hòa ước và các kỳ triều cống giữa hai nước.',
          ),
          if (country.status != 'war' &&
              country.treaty == null &&
              country.oldPayable == 0 &&
              country.oldReceivable == 0)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Chưa có hòa ước hoặc nghĩa vụ triều cống với nước này.',
              ),
            ),
          WarfarePanel(
            state: state,
            controller: controller,
            countryId: countryId,
            showRelations: false,
            showMissions: false,
            showReports: false,
          ),
        ],
        if (place == 'border') ...[
          const SizedBox(height: 18),
          _metric('Quân đối phương', '${whole(country.enemyTroops)} quân'),
          _metric('Chất lượng quân đối phương', '${country.enemyQuality}/100'),
          _metric('Độ kiên cố thành trì', '${country.fortification}/100'),
          _metric(
            'Tăng viện gần nhất',
            country.lastReinforcementYear == 0
                ? 'Chưa có'
                : '+${whole(country.lastReinforcement)} quân · năm ${country.lastReinforcementYear}',
          ),
          const SizedBox(height: 16),
          const Text(
            'Chiến dịch liên quan',
            style: TextStyle(fontFamily: 'Lora', fontSize: 18, color: forest),
          ),
          if (missions.isEmpty)
            const Text('Chưa có chiến dịch đang mở với nước này.'),
          for (final m in missions)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatGameNumbers(m.title),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatGameNumbers(
                        m.status == 'open'
                            ? 'Chờ xuất quân · hạn cuối ${state.date(m.deadline)}'
                            : '${m.status == 'returning' ? 'Đang trở về' : 'Đang thực hiện'} · về cuối ${state.date(m.due)}',
                      ),
                    ),
                    if (m.intervention)
                      const Text(
                        'Đạo quân đang cần tiếp tế.',
                        style: TextStyle(color: terracotta),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Quân triều đình đóng tại cửa ải đối diện. Đến đó để điều quân, chọn tướng, xuất trận hoặc tiếp tế.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                key: const ValueKey('country-to-frontier'),
                onPressed: () => onNavigate(frontierRoute(countryId)),
                child: Text(
                  formatGameNumbers('Đến ${garrisonNames[countryId]}'),
                ),
              ),
              OutlinedButton(
                key: const ValueKey('country-to-gate'),
                onPressed: () => onNavigate(frontierRoute(countryId, 'gate')),
                child: const Text('Xử lý nhiệm vụ tại Cửa Ải'),
              ),
            ],
          ),
          WarfarePanel(
            state: state,
            controller: controller,
            countryId: countryId,
            showDiplomacy: false,
            showMissions: false,
          ),
        ],
      ],
    );
  }

  Widget _metric(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(
          formatGameNumbers('$label:'),
          style: const TextStyle(color: muted),
        ),
        Text(
          formatGameNumbers(value),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
