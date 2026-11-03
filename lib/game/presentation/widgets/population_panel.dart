import '../../models/number_format.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../logic/population_rules.dart';
import '../../logic/frontier_rules.dart';
import 'imperial_theme.dart';
import '../../../app/game_controller.dart';
import 'warfare_panel.dart';

/// Read-only information panels. Commands remain in Quốc sự and Ngân khố.
class PopulationPanel extends StatelessWidget {
  const PopulationPanel({
    super.key,
    required this.state,
    this.military = false,
    this.controller,
    this.embedded = false,
  });
  final GameState state;
  final bool military;
  final bool embedded;
  final GameController? controller;

  @override
  Widget build(BuildContext context) {
    final s = state, p = s.population;
    if (p == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Lượt đang chơi giữ bộ luật cũ. Bắt đầu lượt mới để dùng dân số, quân số và lương thực tính bằng tạ.',
        ),
      );
    }
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Wrap(
        spacing: 12,
        runSpacing: 3,
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
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(
        formatGameNumbers(title),
        style: const TextStyle(fontSize: 18, fontFamily: 'Lora'),
      ),
    );
    final content = <Widget>[
      Text(
        formatGameNumbers(
          military ? 'Tổng quan quân đội' : 'Dân số và phân bổ lao động',
        ),
        style: const TextStyle(fontSize: 24, fontFamily: 'Lora'),
      ),
      const SizedBox(height: 8),
      const Text(
        'Thông tin từ trạng thái hiện tại. Ban lệnh tại Quốc sự; đổi ưu tiên sản xuất tại Ngân khố.',
        style: TextStyle(color: muted, fontSize: 12),
      ),
      if (!military) ...[
        row('Dân số lao động', '${whole(p.population)} người'),
        row('Lao động dân sự', '${whole(p.civilians)} người'),
        row('Quân số', '${whole(p.soldiers)} người'),
        row(
          'Tỷ lệ phục vụ quân đội',
          '${(p.soldiers * 100 / (p.population == 0 ? 1 : p.population)).toStringAsFixed(2)}%',
        ),
        row('Nguồn có thể tuyển', '${whole(p.recruitable)} người'),
        section('Phân bổ lao động dân sự'),
        row('Nông nghiệp — 60%', '${whole(p.civilians * .6)} người'),
        row('Sản xuất, thương mại — 30%', '${whole(p.civilians * .3)} người'),
        row('Hoạt động khác — 10%', '${whole(p.civilians * .1)} người'),
        row(
          'Lao động đã đóng góp mùa này',
          '${whole(p.productiveCivilians)} người',
        ),
        section('Tăng trưởng và nghĩa vụ'),
        row(
          'Người tới tuổi lao động dự kiến',
          '+${whole(p.openingPopulation * populationGrowthRate(s))} người (${(populationGrowthRate(s) * 100).toStringAsFixed(2)}%)',
        ),
        row(
          'Rời lực lượng vì tuổi già',
          '−${whole(p.openingPopulation * .0025)} người (0,25%)',
        ),
        row(
          'Bệnh tật dự kiến',
          '−${whole(p.openingPopulation * diseaseRate(s))} người',
        ),
        row('Mức dịch bệnh', '${p.diseaseLevel}/3'),
        row('Dân lưu tán chưa hồi hương', '${whole(p.displaced)} người'),
        row(
          'Lao động huy động sớm chưa đủ điều kiện tuyển quân',
          '${whole(p.earlyWorkers)} người',
        ),
        row('Nguồn người còn phải khấu trừ', '${whole(p.earlyDebt)} người'),
        if (p.earlyAvailable > s.week)
          row('Có thể hạ tuổi lao động lại', s.date(p.earlyAvailable)),
      ] else ...[
        row('Sức mạnh quân lực trên bộ', '${whole(militaryStrength(s))} điểm'),
        if (!s.hasCourtSystem)
          row(
            'Sức mạnh quân lực thủy chiến',
            '${whole(militaryStrength(s, naval: true))} điểm',
          ),
        row('Tổng quân số', '${whole(p.soldiers)} người'),
        row('Quân có thể điều động', '${whole(p.availableSoldiers)} người'),
        row('Quân đang làm nhiệm vụ', '${whole(p.busySoldiers)} người'),
        if (s.warfare != null) ...[
          section('Nơi đóng quân'),
          for (final id in garrisonNames.keys)
            row(
              garrisonNames[id]!,
              '${whole(p.stationed(id))} quân · rảnh ${whole(p.availableAt(id))}',
            ),
        ],
        if (s.warfare != null && controller != null)
          WarfarePanel(state: s, controller: controller!),
        section('Chất lượng và trang bị'),
        row('Huấn luyện', '${p.training.toStringAsFixed(1)}/100'),
        row('Quân khí', '${p.equipmentPercent.toStringAsFixed(1)}/100'),
        row('Kho quân khí', '${whole(p.equipment)} bộ trang bị quy đổi'),
        row('Sĩ khí', '${p.morale.toStringAsFixed(1)}/100'),
        row(
          'Tác động lòng dân lên sĩ khí',
          '${((s.people - 50) / 10).clamp(-3, 3).toStringAsFixed(1)} mỗi mùa',
        ),
        row('Hậu cần', '${p.logistics.toStringAsFixed(1)}/100'),
        row('Mức sẵn sàng tổng hợp', '${p.readiness.toStringAsFixed(1)}/100'),
        const Text(
          'Sẵn sàng = 30% huấn luyện + 25% quân khí + 20% sĩ khí + 25% hậu cần.',
        ),
        const Text(
          'Sức mạnh = quân số × sẵn sàng / 100 × hệ số chỉ huy. Chỉ số không giới hạn ở 100.',
        ),
        section('Bộ chỉ huy'),
        for (final role in [
          'Đại tướng',
          'Phó tướng',
          if (!s.hasCourtSystem) 'Đô đốc',
        ])
          row(
            role,
            '${s.court.where((c) => c.available && c.role == role).firstOrNull?.name ?? 'Chưa có người'} · hiệu quả ${commanderEffect(s, role).toStringAsFixed(1)}/100',
          ),
        row('Hệ số chỉ huy trên bộ', commandMultiplier(s).toStringAsFixed(3)),
        if (!s.hasCourtSystem)
          row(
            'Hệ số chỉ huy thủy chiến',
            commandMultiplier(s, naval: true).toStringAsFixed(3),
          ),
        section('Nhiệm vụ đang thực hiện'),
        if (p.deployments.isEmpty)
          const Text('Chưa có quân đang làm nhiệm vụ.'),
        for (final d in p.deployments)
          row(
            d.title,
            '${whole(d.troops)} quân · trả quân cuối ${s.date(d.due)}',
          ),
        const Text(
          'Tổn thất tính trên quân tham chiến, theo chỉ huy và chênh lệch quân số. Khi thắng giảm 50–75% thương vong cơ sở; tướng thiện cảm thấp có thể tự ý rút quân.',
        ),
      ],
      section('Sản xuất và kho lương'),
      row('Ưu tiên đang hiệu lực', populationPolicies[p.policy]!),
      row(
        'Kinh tế / quân khí',
        '${((1 - p.militaryAllocation) * 100).round()}% / ${(p.militaryAllocation * 100).round()}%',
      ),
      row('Chính sách mùa tới', populationPolicies[p.nextPolicy]!),
      row(
        'Quân khí sản xuất dự kiến',
        '${whole(manufacturedEquipment(s))} bộ/mùa trước hao mòn',
      ),
      row('Kho lương', '${whole(s.grain)} tạ / ${whole(foodCapacity(s))} tạ'),
      row(
        'Tiêu dùng đủ khẩu phần',
        '${whole(populationFoodConsumption(s))} tạ/mùa',
      ),
      row('Khẩu phần đã cấp trước', '${whole(p.foodCredit)} tạ'),
      row(
        'Còn phải cấp khi khép mùa',
        '${whole(remainingFoodConsumption(s))} tạ',
      ),
      row('Dự trữ tương đương', '${foodDays(s)} ngày'),
      const Text(
        '1 tạ = 100 cân quy đổi. Mỗi khoản thu/chi làm tròn lên một lần đến tạ nguyên.',
      ),
      section('Các đợt đang thực hiện'),
      if (p.orders.isEmpty) const Text('Chưa có đợt đang thực hiện.'),
      for (final o in p.orders)
        row(o.title, '${whole(o.count)} · cuối ${s.date(o.due)}'),
      section('Biến động mùa hiện tại'),
      if (p.changes.isEmpty) const Text('Chưa ghi nhận biến động.'),
      for (final e in p.changes.entries)
        row(e.key, '${e.value >= 0 ? '+' : ''}${whole(e.value)}'),
      if (p.reports.isNotEmpty) ...[
        section('Báo cáo mùa gần nhất'),
        Text(formatGameNumbers(s.date(p.reports.last['week'] as int))),
        for (final e
            in Map<String, dynamic>.from(
              p.reports.last['changes'] as Map,
            ).entries)
          row(
            e.key,
            '${(e.value as num) >= 0 ? '+' : ''}${whole(e.value as num)}',
          ),
      ],
    ];
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      );
    }
    return SingleChildScrollView(
      key: ValueKey(military ? 'military-panel' : 'population-panel'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      ),
    );
  }
}
