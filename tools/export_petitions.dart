import 'dart:convert';
import 'dart:io';

import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';

const conditions = <String, String>{
  'any': 'Không có điều kiện chỉ số riêng.',
  'weakLevee': 'Đê điều <50.',
  'hasConsort': 'Có ít nhất một người đã nhập hậu cung và còn hoạt động.',
  'factionSplit': 'Chênh lệch giữa thái độ phe cao nhất và thấp nhất >35.',
  'spring': 'Đang mùa Xuân.',
  'rain': 'Đang mùa Hạ.',
  'winter': 'Đang mùa Đông.',
  'flood': 'Đang mùa Hạ và đê điều <40.',
  'hungry': 'Lương thực <25.',
  'poor': 'Ngân khố <120.',
  'rich': 'Ngân khố >450.',
  'court': 'Ổn định triều đình <55.',
  'ill': 'Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60.',
  'peace': 'Không có chiến tranh: áp lực chiến tranh =0.',
  'war': 'Đang có chiến tranh: áp lực chiến tranh >0.',
  'debt': 'Nợ chi trả >0.',
  'harem': 'Có ít nhất hai người đã nhập hậu cung và còn hoạt động.',
  'stressed': 'Căng thẳng >45 hoặc mệt mỏi >45.',
  'weakArmy': 'Quân lực <50.',
  'tax': 'Mức thuế đã áp dụng ở kỳ thu gần nhất là thuế cao.',
  'plot': 'Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30.',
  'lowPeople': 'Lòng dân <30.',
  'weakAuthority': 'Uy quyền <35.',
  'recruitment': 'Từ mùa thứ 2 của lượt trị vì trở đi.',
};

const names = <String, String>{
  'treasury': 'Ngân khố',
  'grain': 'Lương thực',
  'people': 'Lòng dân',
  'authority': 'Uy quyền',
  'stability': 'Ổn định triều đình',
  'army': 'Quân lực',
  'health': 'Sức khỏe',
  'levee': 'Đê điều',
  'fatigue': 'Mệt mỏi',
  'stress': 'Căng thẳng',
  'illness': 'Bệnh',
  'war': 'Áp lực chiến tranh',
  'debt': 'Nợ chi trả',
  'revel': 'Số lần hưởng lạc trong mùa',
  'rest': 'Số lần nghỉ trong mùa',
  'work': 'Khối lượng công việc trong mùa',
};

String signed(int value) => value >= 0 ? '+$value' : '−${-value}';
String cell(String text) =>
    text.replaceAll('|', r'\|').replaceAll('\n', '<br>');

String relativeDue(int ticks) => switch (ticks) {
  1 => 'mùa chọn phương án',
  2 => 'mùa kế tiếp (sau 1 mùa)',
  3 => 'mùa sau nữa (sau 2 mùa)',
  5 => 'cùng mùa năm sau (sau 4 mùa)',
  _ => 'mùa thứ $ticks tính cả mùa chọn (sau ${ticks - 1} mùa)',
};

String effectsText(Map<String, int> effects) {
  if (effects.isEmpty) return 'Không có thay đổi chỉ số trực tiếp.';
  final parts = effects.entries
      .map((e) {
        final key = e.key, value = e.value;
        if (key.startsWith('faction:')) {
          return 'Thái độ phe ${key.substring(8)} ${signed(value)}';
        }
        if (key.startsWith('affection:')) {
          return 'Thiện cảm của người còn hoạt động thuộc phe ${key.substring(10)} ${signed(value)} (hậu cung chỉ tính người đã nhập cung)';
        }
        return switch (key) {
          'plotReduce' =>
            'Tiến độ âm mưu mỗi nhân vật ${signed(-value)} (tối thiểu 0)',
          'peace' =>
            'Chấm dứt chiến tranh và giải vây: áp lực chiến tranh =0, bao vây =0',
          'taxNormal' =>
            'Chọn thuế vừa cho kỳ thu hoạch Thu chưa chốt tiếp theo; không tính lại thuế đã thu',
          'repair' =>
            'Mở công việc sửa đê; người xử lý là tùy chọn, để trống không tự giao người; hoàn tất cuối mùa chọn. Khi thành công: đê điều tăng từ cơ bản 30, điều chỉnh theo người phụ trách nếu có và thất thoát. Xem phụ lục kết quả công trình',
          'revealCandidates' =>
            'Thêm $value ứng viên hậu cung trưởng thành vào danh sách tú nữ (chưa nhập cung)',
          'recruitConsort' =>
            'Nhận ứng viên làm tú nữ (chưa nhập cung); thái độ phe ứng viên +3, phe đối lập −5. Chưa phát sinh chi sinh hoạt hậu cung; cần tuyển riêng vào cung để trở thành phi tần',
          'rejectConsort' => 'Thái độ phe đối lập +3, phe ứng viên −5',
          _ =>
            '${names[key] ?? (throw StateError('Unknown effect: $key'))} ${signed(value)}',
        };
      })
      .join('; ');
  return '$parts.';
}

String followupText(String kind) => switch (kind) {
  'school' => 'Lòng dân +4; uy quyền +1. Không có nhánh thất bại riêng.',
  'trade' =>
    'Nhận doanh thu ngẫu nhiên 70–95 tiền vào ngân khố. Đây là doanh thu, chưa trừ chi phí đã bỏ ra; không có nhánh thất bại riêng.',
  'weapons' => 'Quân lực +8. Không có nhánh thất bại riêng.',
  'audit' =>
    'Không giao ai: 30% thành công. Có người: 35–90%, theo đánh giá người xử lý. Thành công: ngân khố +$petitionAuditMinimum đến +$petitionAuditMaximum; uy quyền +2. Thất bại: không có khoản thưởng này, không hoàn phí.',
  'security' =>
    'Không giao ai: 30% thành công. Có người: 35–90%, theo đánh giá người xử lý. Thành công: giảm tối đa 6 tiến độ âm mưu cho mỗi người còn hoạt động (hậu cung chỉ người đã nhập cung). Thất bại: không giảm âm mưu; không hoàn phí.',
  'envoy' =>
    'Không giao ai: 30% thành công, không tự chọn quan thay người chơi. Có người: 35–90%, theo đánh giá người xử lý. Thành công: giảm chiến tranh từ cơ bản 3, tăng uy quyền từ cơ bản 2, điều chỉnh theo người phụ trách nếu có và thất thoát; bao vây về 0. Thất bại thường: chiến tranh +1, uy quyền −2; thất bại nặng: chiến tranh +2, uy quyền −4, ngân khố −20. Người được giao không còn hợp lệ khi tới hạn: gián đoạn, uy quyền −2. Phí đã chi không hoàn lại.',
  _ => throw StateError('Unknown followup: $kind'),
};

void main(List<String> args) {
  final output = File(
    args.isEmpty ? 'docs/danh-sach-tau-chuong.md' : args.single,
  );
  final s = GameState(
    runId: 'catalog-only',
    playerName: '',
    seed: 1,
    rng: 1,
    court: [],
  )..seasonal = true;
  final before = jsonEncode(s.toJson());
  final categories = <String, List<EventDefinition>>{};
  for (final e in events) {
    if (!conditions.containsKey(e.condition)) {
      throw StateError('Unknown condition ${e.condition}');
    }
    categories.putIfAbsent(e.category, () => []).add(e);
  }
  final choices = events.expand((e) => e.choices).length;
  final ids = {for (var i = 0; i < events.length; i++) events[i].id: i + 1};
  if (ids.length != events.length) throw StateError('Duplicate event ID');
  final b = StringBuffer();
  void line([Object text = '']) => b.writeln(text);
  line('# Danh sách toàn bộ tấu chương — Vạn Tuế');
  line();
  line(
    '- **Luật:** `$rulesVersion` · nội dung $contentVersion · chế độ **theo mùa**.',
  );
  line(
    '- **Phạm vi:** ${events.length} tấu chương, $choices lựa chọn, ${categories.length} nhóm.',
  );
  line(
    '- **Nguồn:** catalog đang chạy trong `lib/game/data/content.dart`, `expanded_events.dart`, `event_stories.dart`; quy đổi bằng chính `eventForState()` / `seasonalPetitionChoice()` mà UI và engine đang dùng.',
  );
  line(
    '- **Xuất lại:** `dart run tools/export_petitions.dart`. Công cụ không đọc hay sửa bản lưu người chơi.',
  );
  line();
  line('## Cách đọc');
  line();
  line(
    '- Cân bằng 0.18.0: đầu tư nhận kết quả sau 2 mùa; kiểm toán/truy dấu sau 1 mùa. Thưởng kinh tế dùng mức riêng theo phương án; thất bại mất vốn/phí, không trừ thêm tiền, các phạt lòng dân/uy quyền/ổn định liên quan tối đa −1. Kiểm toán độc lập phí 20, thu hồi 60–90 nếu thành công. Hòa đàm có khoản thu phụ giữ quy tắc cũ; khoản vay giữ nguyên tiền và nợ. Phương án nhận tiền ngay còn lại tăng khoảng 35%, làm tròn bội 5. Kết quả đã chốt trong bản lưu giữ thời hạn và mức cũ.',
  );
  line(
    '- **Giao người xử lý (0.16.0):** 148 lựa chọn có rủi ro được chọn triều thần hoặc người trưởng thành đã nhập hậu cung, đang rảnh và đúng chuyên môn yêu cầu. Mặc định **không giao ai**: thống nhất 30%. Chọn người cộng 5–60 điểm %, trần chung 90%, không tốn thêm hành động hoặc phí ngoài phương án. Tỷ lệ chính xác được hiển thị trước khi xác nhận; người được giao bận đến hạn, mệt công vụ +20 khi nhận việc.',
  );
  line(
    '- Người được giao, tỷ lệ và nhánh thành công/thất bại được lưu lúc xác nhận. Người đó rời chức, qua đời hoặc không còn đủ điều kiện trước hạn thì công việc gián đoạn và chịu hậu quả nhánh thất bại; kinh phí không hoàn lại. Bản lưu cũ đã có kết quả chờ giữ cách xử lý và tỷ lệ đã ghi.',
  );
  line(
    '- Chi phí, yêu cầu hành động và thưởng/phạt bên dưới là **giá trị thực tế theo mùa**, đã áp dụng quy đổi, làm tròn và phụ phí; không lấy các con số gốc theo tuần làm giá hiện hành.',
  );
  line(
    '- Catalog là toàn bộ nội dung có thể xuất hiện; mỗi mùa bốc mục tiêu 4–6 tấu chương mới, có điều kiện, cooldown và ưu tiên tránh lặp. Việc khẩn theo tình hình và tấu chương cũ còn hạn giữ cơ chế riêng.',
  );
  line(
    '- “Tác động ngay” bao gồm cả lợi ích và đánh đổi; dấu +/− là thay đổi chỉ số. Chi phí trả trước được ghi riêng, không cộng nó vào phần thưởng. Doanh thu chưa phải lợi nhuận.',
  );
  line(
    '- Mọi lựa chọn theo mùa tốn ít nhất 1 hành động. Engine kiểm tra ngân khố ≥ chi phí, lương thực ≥ lượng phải xuất và hành động còn lại ≥ yêu cầu. Khoản mất tiền trong hiệu ứng là tổn thất riêng: nếu kho không đủ, phần thiếu trở thành nợ; mất thóc trong hiệu ứng không phải điều kiện phải có đủ thóc để chọn.',
  );
  line(
    '- Lựa chọn cuối là phương án mặc định khi quá hạn: engine áp dụng hiệu ứng và kết quả chờ, không trừ phí/hành động của việc ngự phê. Bỏ quá hạn tấu chương nhóm Khủng hoảng/Âm mưu còn mất thêm 4 uy quyền và 3 ổn định mỗi việc, tối đa 2 việc/mùa, ngoài hậu quả riêng.',
  );
  line(
    '- Mùa đạt hạn vẫn được xử lý công việc chờ khi khép mùa. “Cuối mùa chọn” = chốt mùa hiện tại; “cuối mùa kế tiếp” = chốt lượt sau; “cùng mùa năm sau” = chốt sau 4 mùa.',
  );
  line(
    '- Tỷ lệ ở mỗi lựa chọn là mức khi không giao ai; người được giao giúp tăng tỷ lệ theo chuyên môn và đánh giá công vụ. Các kết quả chờ 100% không có nhánh thất bại vẫn giữ nguyên. Nhánh kết quả được bốc/lưu lúc xác nhận; tải lại không bốc lại.',
  );
  line(
    '- Các con số là thay đổi trước giới hạn: phần lớn chỉ số 0–100, lương thực 0–200; giá trị nhận thực tế có thể bị giới hạn. Kết quả dưới đây không bao gồm thu chi thường lệ, hao mòn, sức khỏe cuối mùa và sự kiện khác.',
  );
  line(
    '- Nội dung có `{candidate}` sẽ thay bằng ứng viên cụ thể khi tấu chương được trình. Những yêu cầu phụ thuộc nhân vật được ghi theo điều kiện, không tự gán một người giả định.',
  );
  line(
    '- Ngự phê tăng khối lượng làm việc bằng số hành động đã dùng; tấu chương ngoài nhóm Cung đình/Hậu cung/Sức khỏe được tính là xử lý việc nước. Các chỉ số sức khỏe, ổn định, uy quyền, lòng dân hoặc quân lực về 0 có thể kết thúc lượt ngay.',
  );
  line();
  line('## Mục lục nhóm');
  line();
  line('| Nhóm | Tấu chương | Lựa chọn |');
  line('|---|---:|---:|');
  var group = 0;
  for (final item in categories.entries) {
    group++;
    line(
      '| [${cell(item.key)}](#group-$group) | ${item.value.length} | ${item.value.expand((e) => e.choices).length} |',
    );
  }
  line();
  line('## Chỉ mục tất cả tấu chương');
  line();
  line('| STT | Mã | Tên tấu chương | Nhóm | Lựa chọn |');
  line('|---:|---|---|---|---:|');
  for (final e in events) {
    line(
      '| ${ids[e.id]} | `${e.id}` | [${cell(e.title)}](#event-${e.id}) | ${cell(e.category)} | ${e.choices.length} |',
    );
  }

  var exportedChoices = 0;
  group = 0;
  for (final item in categories.entries) {
    group++;
    line();
    line('<a id="group-$group"></a>');
    line('## Nhóm $group — ${item.key}');
    for (final source in item.value) {
      final e = eventForState(s, source.id);
      final trigger = eventTrigger(e);
      final firstTurn =
          e.condition == 'recruitment'
              ? s.cooldownTurns(e.minWeek).clamp(2, 100000)
              : s.cooldownTurns(e.minWeek);
      line();
      line('<a id="event-${e.id}"></a>');
      line('### ${ids[e.id]}. ${e.title}');
      line();
      line('- **Mã:** `${e.id}` · **Nhóm:** ${e.category}.');
      line(
        '- **Điều kiện xuất hiện:** ${conditions[e.condition]} Mã điều kiện: `${e.condition}`.',
      );
      line(
        '- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ $firstTurn (${s.date(firstTurn)}); còn phải thỏa điều kiện xuất hiện trên.',
      );
      line(
        '- **Giãn lặp cùng mã:** ${s.cooldownTurns(e.cooldown)} mùa. Nhóm nội dung: `${eventFamily(e)}`.',
      );
      if (trigger.isNotEmpty) {
        line(
          '- **Việc khẩn:** nguyên nhân `$trigger`; cooldown chung ${s.cooldownTurns(eventById(trigger).cooldown)} mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.',
        );
      } else {
        line(
          '- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.',
        );
      }
      line(
        '- **Khi quá hạn:** chọn mặc định phương án ${e.choices.length} — “${e.choices.last.label}”.',
      );
      line();
      line('**Nội dung tấu chương:**');
      line();
      for (final paragraph in s.authoredText(e.body).split('\n')) {
        line('> $paragraph');
      }
      for (var i = 0; i < e.choices.length; i++) {
        final c = e.choices[i], raw = source.choices[i];
        exportedChoices++;
        final ticks = petitionDelay(s, raw);
        final requirements = <String>['${petitionPoints(s, c)} hành động'];
        if (c.cost > 0) {
          requirements.add('ngân khố ≥${c.cost} (chi ${c.cost} tiền)');
        }
        if (c.grainCost > 0) {
          requirements.add(
            'lương thực ≥${c.grainCost} (xuất ${c.grainCost} thóc)',
          );
        }
        if (c.cost == 0 && c.grainCost == 0) {
          requirements.add('không yêu cầu tiền/thóc trả trước');
        }
        if (c.effects.containsKey('repair')) {
          requirements.add(
            'chưa có công trình sửa đê đang chạy; người xử lý là tùy chọn',
          );
        }
        if (c.effects.containsKey('recruitConsort')) {
          requirements.add(
            'ứng viên gắn với tấu chương còn hoạt động, thuộc nhóm tú nữ, đủ 18 tuổi và chưa nhập cung',
          );
        }
        line();
        line(
          '#### Phương án ${i + 1} — ${c.label}${i == e.choices.length - 1 ? ' [mặc định khi quá hạn]' : ''}',
        );
        line();
        line(
          '- **Yêu cầu / chi phí khi chủ động chọn:** ${requirements.join('; ')}.',
        );
        line(
          '- **Tác động ngay — lợi ích và đánh đổi:** ${effectsText(c.effects)}',
        );
        final managed = petitionCanAssign(s, c);
        final chance = managed ? petitionBaseChance(c) : c.successChance;
        if (managed) {
          line(
            '- **Người xử lý tùy chọn:** chuyên môn ${petitionSpecialty(e, c)}. Không giao ai: $chance%; giao người đủ điều kiện: ${chance + 5}–$petitionMaxChance%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.',
          );
        }
        if (c.followup.isNotEmpty) {
          line(
            '- **Kết quả công việc riêng:** cuối ${relativeDue(ticks)}. ${followupText(c.followup)}',
          );
        }
        if (c.laterEffects.isNotEmpty) {
          line(
            '- **Kết quả chờ — thành công $chance%${managed ? ' khi không giao ai' : ''}:** cuối ${relativeDue(ticks)}: ${effectsText(c.laterEffects)}',
          );
          if (c.successChance < 100) {
            line(
              '- **Kết quả chờ — thất bại ${100 - chance}%${managed ? ' khi không giao ai' : ''}:** cùng thời điểm: ${effectsText(c.laterFailureEffects)} Chi phí đã trả không được hoàn lại.',
            );
          }
        }
        if (c.followup.isEmpty &&
            c.laterEffects.isEmpty &&
            !c.effects.containsKey('repair')) {
          line('- **Kết quả trì hoãn riêng:** không có.');
        }
        final due = s.date(s.week + ticks - 1);
        line(
          '- **Mô tả lựa chọn trên UI:** ${petitionChoiceHint(s, e, c).replaceAll(due, relativeDue(ticks))}',
        );
      }
    }
  }
  line();
  line('## Phụ lục — công trình sửa đê và kết quả phụ thuộc nhân vật');
  line();
  line(
    '- Sửa đê khởi tạo từ tấu chương hoàn tất cuối mùa chọn. Không giao ai dùng tỷ lệ nền 30%; nếu đã giao người thì người đó phải còn đủ điều kiện tới hạn. Thay quan không tự chuyển phân công tấu chương cho người mới; mất người phụ trách làm công việc gián đoạn. Phí ban đầu đã chi theo lựa chọn, không trừ lại khi hoàn tất.',
  );
  line(
    '- Điểm hiệu dụng = năng lực − 4×⌊mệt công vụ/10⌋ + điều chỉnh tính cách/quan hệ − nguy cơ phá việc. Không cộng điểm nền 20 hoặc điểm đúng chuyên môn 25. Điểm cộng tỷ lệ = làm tròn [0,6×điểm hiệu dụng], giới hạn 5–60 điểm %. Tỷ lệ thành công = 30% + điểm cộng, tối đa 90%. Nhận việc +20 mệt (tối đa 100); cuối mùa hồi 10 nếu rảnh, hồi 5 nếu còn bận (tối thiểu 0). Hậu cung dùng thiện cảm thay năng lực. Chỉ dùng tính cách đã biết; trung thành chưa xác minh được thay bằng giá trị trung tính 50, nên tỷ lệ hiển thị và tỷ lệ được chốt luôn thống nhất và không tiết lộ phẩm chất ẩn. Chỉ người đúng chuyên môn được nhận việc, độ phù hợp là 100.',
  );
  line(
    '- Hiệu quả thưởng = làm tròn [45 + 0,6×năng lực + 0,3×độ phù hợp − ⌊mệt công vụ/5⌋ + điều chỉnh tính cách], giới hạn 10–180%. Phần thưởng cơ bản được nhân tỷ lệ này, làm tròn, tối thiểu 1; sau đó có thể thất thoát do phẩm chất. Quan hệ và bất mãn ảnh hưởng hợp tác, còn liêm chính ảnh hưởng thất thoát.',
  );
  line(
    '- Sửa đê thành công: tăng đê điều từ cơ bản 30 theo hiệu quả và phần nhận được sau thất thoát. Thất bại thường: đê điều −4, lòng dân −2. Thất bại nặng: đê điều −8, lòng dân −4, uy quyền −3, ngân khố −15, ngoài phí đã cấp.',
  );
  line(
    '- Kiểm toán, mật thám, ngoại giao và sửa đê mới đều dùng tỷ lệ nền 30% nếu không giao ai; có người sẽ cộng theo đánh giá trên, tối đa 90%. Kết quả đã ngự phê trước lần cập nhật này giữ tỷ lệ và nhánh đã chốt.',
  );
  line();
  line('## Nguồn đối chiếu');
  line();
  for (final path in [
    'lib/game/data/content.dart',
    'lib/game/data/expanded_events.dart',
    'lib/game/data/event_stories.dart',
    'lib/game/logic/petition_rules.dart',
    'lib/game/logic/petition_assignment_rules.dart',
    'lib/game/logic/petition_engine.dart',
    'lib/game/logic/game_engine.dart',
    'lib/game/logic/personnel_rules.dart',
    'lib/game/logic/personality_rules.dart',
  ]) {
    line('- [`$path`](../$path)');
  }
  if (exportedChoices != choices || jsonEncode(s.toJson()) != before) {
    throw StateError('Export changed state or omitted choices');
  }
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(b.toString());
  stdout.writeln(
    jsonEncode({
      'file': output.absolute.path,
      'events': events.length,
      'choices': exportedChoices,
      'categories': categories.length,
      'bytes': output.lengthSync(),
      'rules': rulesVersion,
    }),
  );
}
