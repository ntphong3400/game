import 'dart:io';

import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

/// Uses production rules with neutral relations and known traits.
void main(List<String> args) {
  final person =
      initialCourt().first
        ..specialty = 'Công trình'
        ..affection = 50
        ..discontent = 0
        ..investigated = false
        ..managementGrowthHalf = 0
        ..personalityContacts = 0;
  person.personalities
    ..clear()
    ..addAll([Personality.grateful, Personality.honest]);
  final s = GameState(
    runId: 'chance-preview',
    playerName: '',
    seed: 1,
    rng: 1,
    court: [person],
  )..seasonal = true;
  s.factions[person.faction] = 50;
  final e = eventForState(s, 'levee_warning');
  final c = e.choices.first;
  const fatigueLevels = [0, 20, 40, 60, 80, 100];
  final b =
      StringBuffer()
        ..writeln('# Preview tỷ lệ thành công theo năng lực và mệt công vụ')
        ..writeln()
        ..writeln(
          'Các ô là tỷ lệ thành công (%). Quan hệ, tính cách và phá việc có điều chỉnh ròng bằng 0.',
        )
        ..writeln()
        ..writeln('```text')
        ..writeln('Phạt mệt = 4 × phần nguyên(mệt / 10)')
        ..writeln('Điểm hiệu dụng = năng lực − phạt mệt + các điều chỉnh khác')
        ..writeln(
          'Tỷ lệ = $petitionUnassignedChance + làm tròn(0,6 × điểm hiệu dụng)',
        )
        ..writeln(
          'Giới hạn khi giao người: 35–$petitionMaxChance%. Không giao ai: $petitionUnassignedChance%.',
        )
        ..writeln('```')
        ..writeln()
        ..writeln(
          '| Năng lực | ${fatigueLevels.map((f) => 'Mệt $f').join(' | ')} |',
        )
        ..writeln('|---:|${fatigueLevels.map((_) => '---:|').join()}');
  for (final ability in [0, 10, 20, 30, 40, 41, 50, 60, 70, 80, 90, 100]) {
    person.ability = ability;
    final values = <int>[];
    for (final fatigue in fatigueLevels) {
      person.strain = fatigue;
      values.add(petitionChance(s, e, c, person));
    }
    b.writeln('| $ability | ${values.join(' | ')} |');
  }
  b
    ..writeln()
    ..writeln('- Nhận một công việc: +20 mệt, tối đa 100.')
    ..writeln('- Cuối mùa: giảm 10 nếu rảnh, giảm 5 nếu còn bận; tối thiểu 0.')
    ..writeln(
      '- Tỷ lệ được chốt trước khi cộng mệt do nhận việc; công việc đang chờ giữ tỷ lệ và nhánh đã chốt.',
    )
    ..writeln(
      '- Đúng chuyên môn là điều kiện nhận việc, không cộng điểm cố định. Không còn điểm nền đánh giá +20.',
    )
    ..writeln(
      '- Hậu cung dùng thiện cảm làm đầu vào thay năng lực như cơ chế hiện tại.',
    )
    ..writeln()
    ..writeln(
      'Xuất lại bằng `dart run tools/preview_petition_chance.dart`. Dữ liệu được tính trực tiếp bằng `petitionChance()`, không đọc/sửa bản lưu.',
    );
  final output = File(
    args.isEmpty ? 'output/preview-nang-luc-tau-chuong.md' : args.single,
  );
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(b.toString());
  stdout.writeln('Wrote ${output.path}');
}
