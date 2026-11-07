import '../models/game_state.dart';
import '../models/event_definition.dart';
import '../logic/reign_rules.dart';
import '../logic/chain_settlement_rules.dart';
import 'reign_content.dart';
import 'expanded_events.dart' show eventEffectText;

bool isStoryEvent(String id) =>
    id.startsWith('chain:') || id.startsWith('major:');
String chainEventId(StoryArc arc) => 'chain:${arc.kind}:${arc.stage}';
String majorEventId(MajorMission m) => 'major:${m.kind}:${m.stage}';

String storyStageLabel(int stage, int count) {
  if (stage == count - 1) return 'Bản tấu cuối';
  return switch (stage) {
    0 => 'Bản tấu đầu',
    1 => 'Bản tấu thứ hai',
    2 => 'Bản tấu thứ ba',
    _ => 'Bản tấu thứ ${stage + 1}',
  };
}

String chainStageLabel(StoryArc arc) =>
    storyStageLabel(arc.stage, chainDefinitionFor(arc).stages.length);

String majorStageLabel(MajorMission m) =>
    storyStageLabel(m.stage, m.objectives.length);

String majorActionTitle(ObjectiveDefinition goal) {
  final title = goal.title.replaceFirst(
    RegExp(r'^hoàn tất ', caseSensitive: false),
    'Tổ chức ',
  );
  return '${title[0].toUpperCase()}${title.substring(1)}';
}

String majorDecisionRecap(MajorMission m) {
  if (m.decisions.isEmpty) return '';
  final full = m.decisions.where((i) => i == 0).length;
  final limited = m.decisions.where((i) => i == 1).length;
  if (full == m.decisions.length) {
    return 'Các phần việc trước đã được triều đình huy động đầy đủ.';
  }
  if (limited == m.decisions.length) {
    return 'Các phần việc trước mới được ứng phó bằng nguồn lực hạn chế.';
  }
  if (full + limited == 0) {
    return 'Những phần việc trước chưa được tổ chức ứng phó.';
  }
  if (full + limited < m.decisions.length) {
    return 'Triều đình đã ưu tiên một số phần việc, những việc còn lại chưa được tổ chức ứng phó.';
  }
  return 'Triều đình đã huy động đầy đủ ở một số phần việc, những việc còn lại mới được ứng phó có giới hạn.';
}

// Recall only choices already made, without costs, settlement ratios, or
// future steps. Full dated records remain available in the history disclosure.
String chainDecisionRecap(GameState s, StoryArc arc) {
  if (arc.decisions.isEmpty) return '';
  final stages = chainDefinitionFor(arc).stages;
  final actions =
      [
            for (var step = 0; step < arc.decisions.length; step++)
              chainParticipantText(
                s,
                arc,
                stages[step].choices[arc.decisions[step]].label,
              ),
          ]
          .map((label) => '${label[0].toLowerCase()}${label.substring(1)}')
          .toList();
  final recap =
      actions.length == 1
          ? actions.single
          : '${actions.take(actions.length - 1).join(', ')} và ${actions.last}';
  return 'Trước đó, bệ hạ đã $recap.';
}

String chainOutlook(StoryArc arc) => switch (arc.kind) {
  'embezzlement' => 'Lần theo tiền cứu trợ để thu hồi phần thất thoát.',
  'border' => 'Giữ vững biên cương, tìm đường hạ nhiệt xung đột.',
  'granary' => 'Củng cố nguồn lương để dân qua mùa giáp hạt.',
  'dyke' => 'Gia cố tuyến đê, bảo vệ dân trước mùa nước lớn.',
  'justice' => 'Làm rõ oan tình, giữ lòng tin vào phép nước.',
  'exams' => 'Tìm người có thực tài để giao trọng trách.',
  'merit' => 'Ghi công xứng đáng để giữ lòng quân.',
  'refugees' => 'Ổn định sinh kế, vun đắp nguồn lương và lòng dân.',
  'copper' => 'Khai thác nguồn đồng để gây dựng nguồn thu.',
  'palaceRumor' => 'Làm rõ lời đồn, khôi phục nền nếp nội cung.',
  'market' => 'Khơi thông buôn bán, gây dựng nguồn thu từ bến chợ.',
  'haremHarmony' => 'Thu xếp việc chung, giữ hòa khí trong Phượng điện.',
  _ => 'Theo đuổi phần việc đến khi có thể khép hồ sơ.',
};

ChainStage chainStageFor(StoryArc arc) {
  final d = chainDefinitionFor(arc);
  if (usesChainSettlement(arc)) return d.stages[arc.stage];
  if (arc.decisions.isEmpty) return d.stages[arc.stage];
  return d.branches['${arc.stage}:${arc.decisions.join(',')}'] ??
      d.branches['${arc.stage}:${arc.decisions.last}'] ??
      d.stages[arc.stage];
}

bool chainEligible(GameState s, ChainDefinition d) => switch (d.condition) {
  'dyke' => s.season == 'Xuân' || s.season == 'Hạ' || s.levee < 50,
  'military' => s.court.any(
    (c) => c.available && !c.isConsort && c.specialty == 'Quân sự',
  ),
  'harem' => s.court.where((c) => c.available && c.inHarem).length >= 2,
  'differentConsortFactions' => harmonyPairs(s).isNotEmpty,
  _ => true,
};

Map<String, int> _merge(Map<String, int> a, Map<String, int> b) {
  final result = Map<String, int>.of(a);
  for (final e in b.entries) {
    result.update(e.key, (n) => n + e.value, ifAbsent: () => e.value);
  }
  result.removeWhere((k, v) => v == 0);
  return result;
}

Map<String, int> chainEndingEffects(GameState s, StoryArc arc, int index) {
  final d = chainDefinitionFor(arc);
  if (arc.stage != d.stages.length - 1) return {};
  final neglected = arc.decisions.where((i) => i == 2).length;
  final effects = <String, int>{};
  // The three original histories retain their authored endings.
  if (['embezzlement', 'border', 'granary'].contains(arc.kind)) {
    if (neglected > 0) {
      effects[arc.kind == 'border' ? 'army' : 'people'] = -3 * neglected;
    }
    if (arc.kind == 'embezzlement') {
      if (index == 0 && arc.decisions.every((i) => i == 0)) {
        effects.addAll({'treasury': 30, 'authority': 2});
      }
      if (arc.decisions.first == 1) effects['faction:Thế gia'] = -4;
    }
    if (arc.kind == 'border' &&
        index == 0 &&
        arc.decisions.every((i) => i == 0)) {
      effects['war'] = -1;
    }
    if (arc.kind == 'granary' && index == 0 && arc.decisions.first == 0) {
      effects['grain'] = 10;
    }
  } else if (arc.kind == 'dyke') {
    // Prevention and the actual national levee condition both matter.
    final protected = s.levee >= 75 || (s.levee >= 55 && arc.decisions[1] == 0);
    effects.addAll(protected ? {'people': 2} : {'grain': -15, 'people': -6});
  } else if (arc.kind == 'justice' && index == 0) {
    final verified = arc.decisions.length >= 2 && arc.decisions[1] == 0;
    effects.addAll(verified ? {'people': 5, 'authority': 2} : {'people': 1});
  } else if (arc.kind == 'merit' && index == 0) {
    effects.addAll(arc.decisions.contains(0) ? {'army': 3} : {'army': -2});
  } else if (arc.kind == 'refugees') {
    effects.addAll(
      arc.decisions[2] == 0
          ? {'grain': 25, 'people': 2}
          : {'grain': -8, 'people': -3},
    );
  } else if (arc.kind == 'copper' && index == 0 && arc.decisions[2] != 0) {
    effects.addAll({'people': -4, 'treasury': -15});
  } else if (arc.kind == 'palaceRumor' && index == 0 && arc.decisions[1] == 0) {
    effects['authority'] = 2;
  }
  return effects;
}

EventDefinition _chainEvent(GameState s, StoryArc arc) {
  if (usesChainSettlement(arc)) return _settlementChainEvent(s, arc);
  final d = chainDefinitionFor(arc), stage = chainStageFor(arc);
  var body = stage.body;
  // Original chains also report distinct consequences of the initial order.
  if (arc.stage == 1) {
    body = switch ((arc.kind, arc.decisions.first)) {
      ('embezzlement', 0) =>
        'Đoàn kiểm tra do bệ hạ cử đã giữ được sổ gốc. Chứng cứ chạm tới một gia tộc có thế lực. $body',
      ('embezzlement', 1) =>
        'Thế gia nhận thu xếp nay xin giải quyết kín; hồ sơ không còn được kiểm tra độc lập. $body',
      ('embezzlement', _) =>
        'Sau khi hồ sơ bị gác, dân lại khiếu kiện; việc xác minh nay tốn thêm kinh phí. $body',
      ('border', 0) =>
        'Sứ giả đã trở về, mang theo điều kiện mở cửa khẩu của đối phương. $body',
      ('border', 1) =>
        'Đoàn hộ tống đã va chạm tại trạm gác; đối phương nâng yêu sách. $body',
      ('border', _) =>
        'Thương lộ đóng kéo dài, thương nhân xin mở lại trước khi mất khách. $body',
      ('granary', 0) =>
        'Bản kiểm kê đã chỉ ra lượng thóc và số hộ cần cứu trợ. $body',
      ('granary', 1) =>
        'Thóc vay đã về, nhưng khoản hoàn trả sắp đến hạn. $body',
      ('granary', _) =>
        'Giá thóc chưa hạ sau thời gian chờ, các phủ thúc giục mở kho. $body',
      _ => body,
    };
  }
  if (arc.kind == 'justice' && arc.stage == 2) {
    body =
        arc.decisions[1] == 0
            ? '${arc.facts['innocent'] == 1 ? 'Đối chiếu độc lập xác nhận có ép cung, vật chứng ngoại phạm phù hợp.' : 'Đối chiếu độc lập xác nhận vật chứng buộc tội hợp lệ; lời tố ép cung không được chứng minh.'} $body'
            : 'Chưa có kết quả xác minh độc lập đủ để kết luận oan án. $body';
  }
  final subject =
      s.court.where((c) => c.id == arc.subjectId).firstOrNull ??
      s.officialsPool.where((c) => c.id == arc.subjectId).firstOrNull;
  if (subject != null) {
    body +=
        '\nNgười liên quan: ${subject.name} (${subject.role})${subject.available ? '' : ', đã rời vị trí'}.';
  }
  if (arc.kind == 'palaceRumor' && arc.stage == 2 && arc.decisions[1] == 0) {
    body +=
        arc.facts['guilty'] == 1
            ? '\nSổ chi đã xác nhận có can thiệp sai quy định. Chỉ xử lý theo phần đã xác minh.'
            : '\nĐối chiếu xác nhận lời tố sai; cần phục hồi danh dự người bị trách oan.';
  }
  final memory =
      arc.decisionLabels.isEmpty
          ? ''
          : '\nChỉ dụ trước: ${arc.decisionLabels.join(' → ')}.';
  final choices = <EventChoice>[];
  for (var i = 0; i < stage.choices.length; i++) {
    final c = stage.choices[i];
    final extra =
        arc.stage == 1 &&
                i == 0 &&
                arc.decisions.first == 2 &&
                ['embezzlement', 'border', 'granary'].contains(arc.kind)
            ? 10
            : arc.kind == 'border' &&
                arc.stage == 1 &&
                arc.decisions.first == 1 &&
                i == 0
            ? 8
            : 0;
    final effects = _merge(c.effects, chainEndingEffects(s, arc, i));
    final closes =
        arc.stage == d.stages.length - 1 ||
        (arc.kind == 'copper' && arc.stage == 0 && i == 2);
    final obligation = switch ((arc.kind, arc.stage, i)) {
      ('border', 1, 1) => 'Từ mùa sau chi 18 tiền/mùa × 2 mùa.',
      ('granary', 0, 1) => 'Mùa sau hoàn trả 35 tiền.',
      ('copper', 3, 0) when arc.decisions[1] == 0 && arc.decisions[2] == 0 =>
        'Nguồn thu 12 tiền/mùa × 4 mùa, bắt đầu mùa sau.',
      _ => '',
    };
    choices.add(
      EventChoice(
        c.label,
        '${c.cost + extra} tiền · ${c.grainCost} thóc · ${c.points == 0 ? 1 : c.points} hành động. '
        '${eventEffectText(effects)}. $obligation '
        '${closes ? 'Khép chuỗi sau quyết định này.' : 'Bản tấu tiếp theo dự kiến ${s.date(s.week + stage.delay)}.'}',
        effects,
        cost: c.cost + extra,
        grainCost: c.grainCost,
        points: c.points == 0 ? 1 : c.points,
      ),
    );
  }
  return EventDefinition(
    chainEventId(arc),
    stage.title,
    'Chuỗi: ${d.title} · Bản tấu ${arc.stage + 1}/${d.stages.length}.\n$body$memory',
    'Chuỗi sự kiện',
    choices,
    condition: 'storyOnly',
  );
}

EventDefinition _settlementChainEvent(GameState s, StoryArc arc) {
  final d = chainDefinition(arc.kind), stage = d.stages[arc.stage];
  var body = chainParticipantText(s, arc, stage.body);
  if (arc.kind == 'justice' && arc.stage >= 2) {
    body +=
        arc.facts['innocent'] == 1
            ? '\nĐối chiếu xác nhận có oan sai; thi hành việc phục hồi quyền lợi theo chứng cứ.'
            : '\nĐối chiếu xác nhận bản án có căn cứ; thi hành theo chứng cứ đã kiểm tra.';
  }
  if (arc.kind == 'palaceRumor' && arc.stage >= 2) {
    body +=
        arc.facts['guilty'] == 1
            ? '\nSổ chi xác nhận sai phạm; xử lý và phục hồi nền nếp theo phần đã xác minh.'
            : '\nĐối chiếu xác nhận lời tố sai; cần phục hồi danh dự người liên quan.';
  }
  if (arc.subjectId.isNotEmpty) {
    final c = s.court.where((c) => c.id == arc.subjectId).firstOrNull;
    if (c != null) {
      body += '\nNgười liên quan: ${c.name} (${c.role}).';
    }
  }
  final recap = chainDecisionRecap(s, arc);
  if (recap.isNotEmpty) body += '\n$recap';
  final choices = <EventChoice>[];
  for (var i = 0; i < stage.choices.length; i++) {
    final c = stage.choices[i], quit = chainChoiceAbandons(arc, i);
    final effects = chainChoiceEffects(arc, c);
    final approach =
        quit
            ? 'Khép hồ sơ theo phần đã thực hiện. Chi phí đã trả không được hoàn lại.'
            : arc.kind == 'haremHarmony'
            ? i == 2
                ? 'Dùng ngân khố thu xếp việc chung, giữ cân bằng giữa hai bên.'
                : 'Trao ưu thế cho một bên, khiến phe còn lại bất bình.'
            : i == 1
            ? 'Dùng ngân khố để triều đình trực tiếp tổ chức phần việc này.'
            : [
              'Giảm gánh ngân khố.',
              if (effects.containsKey('authority'))
                'Triều đình phải nhượng bớt quyền định đoạt.',
              if (effects.containsKey('people'))
                'Dân phải gánh thêm phần việc, dễ sinh bất mãn.',
              if (effects.containsKey('stability'))
                'Việc thu xếp giữa các phe làm triều chính xáo trộn.',
            ].join(' ');
    choices.add(
      EventChoice(
        chainParticipantText(s, arc, c.label),
        approach,
        effects,
        cost: c.cost,
        points: 1,
      ),
    );
  }
  return EventDefinition(
    chainEventId(arc),
    stage.title,
    'Chuỗi: ${d.title}.\n$body\n\n'
        '${chainOutlook(arc)} Thành quả sẽ được ghi nhận khi hồ sơ khép lại.',
    'Chuỗi sự kiện',
    choices,
    condition: 'storyOnly',
  );
}

EventDefinition _majorEvent(GameState s, MajorMission m) {
  final d = majorDefinition(m.kind), goal = d.objectives[m.stage];
  final delivered = m.objectives[m.stage].delivered;
  final previous = m.decisions.where((i) => i != 0).length;
  final cost =
      ((missionCost(m, goal).clamp(s.challengingEconomy ? 30 : 55, 999)) *
              (1 + previous * .2) *
              (100 - delivered) /
              100)
          .ceil();
  final grain = (missionGrain(m, goal) * (100 - delivered) / 100).ceil();
  final unavailable = majorGoalUnavailable(s, m, goal);
  final partialCoverage = delivered + ((100 - delivered) / 2).floor();
  final fullCoverage = unavailable == null ? 100 : partialCoverage;
  final fullDamage = majorPetitionDamage(m, goal, fullCoverage);
  final partialDamage = majorPetitionDamage(m, goal, partialCoverage);
  final ignoredDamage = majorPetitionDamage(m, goal, delivered);
  final action = majorActionTitle(goal);
  final lowerAction = '${action[0].toLowerCase()}${action.substring(1)}';
  final memory = majorDecisionRecap(m);
  final body = [
    majorBody(s, m),
    if (m.stage == 0 && unavailable == null)
      'Trước mắt, triều đình cần $lowerAction.',
    if (unavailable != null) '$unavailable Chỉ còn phương án dự phòng.',
    if (memory.isNotEmpty) '\n$memory',
    if (m.damageTaken.values.any((value) => value != 0))
      'Những phần chưa được bảo vệ đã để lại tổn thất.',
  ].join('\n');
  return EventDefinition(
    majorEventId(m),
    m.stage == 0 ? d.title : '${d.title} · $action',
    body,
    'Đại biến cố',
    [
      EventChoice(
        unavailable == null ? action : 'Huy động cho phương án dự phòng',
        '',
        fullDamage,
        cost: cost,
        grainCost: grain,
        points: 2,
      ),
      EventChoice(
        unavailable == null
            ? '$action với nguồn lực hạn chế'
            : 'Huy động hạn chế cho phương án dự phòng',
        '',
        partialDamage,
        cost: (cost * .5).ceil(),
        grainCost: (grain * .5).ceil(),
        points: 1,
      ),
      EventChoice(
        unavailable == null ? 'Tạm hoãn $lowerAction' : 'Chưa tổ chức ứng phó',
        '',
        ignoredDamage,
        points: 1,
      ),
    ],
    condition: 'storyOnly',
  );
}

/// Static lookup also works for old journal/export callers. These definitions
/// are deliberately excluded from the ordinary random petition pool.
EventDefinition? storyEventById(String id) {
  if (!isStoryEvent(id)) return null;
  final parts = id.split(':');
  if (parts.length != 3) throw StateError('Invalid story event $id');
  final stage = int.parse(parts[2]);
  if (parts[0] == 'chain') {
    final d = chainDefinition(parts[1]), st = d.stages[stage];
    return EventDefinition(
      id,
      st.title,
      st.body,
      'Chuỗi sự kiện',
      st.choices,
      condition: 'storyOnly',
    );
  }
  final d = majorDefinition(parts[1]), goal = d.objectives[stage];
  return EventDefinition(
    id,
    d.title,
    '${d.body}\n${goal.title}',
    'Đại biến cố',
    const [],
    condition: 'storyOnly',
  );
}

EventDefinition? storyEventForState(GameState s, String id) {
  if (!isStoryEvent(id)) return null;
  for (final arc in s.chains) {
    if (chainEventId(arc) == id) return _chainEvent(s, arc);
  }
  final m = s.major;
  if (m != null && m.stage < m.objectives.length && majorEventId(m) == id) {
    return _majorEvent(s, m);
  }
  return storyEventById(id);
}
