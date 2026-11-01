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
  if (arc.decisionLabels.isNotEmpty) {
    body += '\nChỉ dụ trước: ${arc.decisionLabels.join(' → ')}.';
  }
  final choices = <EventChoice>[];
  for (var i = 0; i < stage.choices.length; i++) {
    final c = stage.choices[i], quit = chainChoiceAbandons(arc, i);
    final projected = projectedChainChoice(arc, i);
    final effects = chainChoiceEffects(arc, c);
    final blocked = chainSettlementChoiceBlocked(s, arc, i);
    final closes = quit || projected.completedSteps == 4;
    final costText =
        c.cost > 0 ? 'Chi ${c.cost} tiền ngay' : 'Không chi ngân khố';
    choices.add(
      EventChoice(
        chainParticipantText(s, arc, c.label),
        '$costText · 1 hành động. ${effects.isEmpty ? '' : '${eventEffectText(effects)} ngay. '}'
        '${quit ? 'Dừng ở ${arc.completedSteps}/4.' : 'Hoàn thành ${projected.completedSteps}/4; ghi nhận thêm ${chainStepValue(arc)} chi phí quy đổi.'} '
        '${closes ? 'Quyết toán: ${chainSettlementRewardText(s, projected)}' : 'Chưa nhận thưởng; bản tấu tiếp theo ${s.date(s.week + stage.delay)}. Nếu dừng sau bước này: ${chainSettlementRewardText(s, projected)}'}'
        '${blocked == null ? '' : '\n$blocked'}',
        effects,
        cost: c.cost,
        points: 1,
      ),
    );
  }
  return EventDefinition(
    chainEventId(arc),
    stage.title,
    'Chuỗi: ${d.title} · Bản tấu ${arc.stage + 1}/4.\n$body\n\n${chainSettlementSummary(s, arc)}',
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
  final memory =
      m.decisionLabels.isEmpty
          ? 'Đây là bản tấu mở đầu.'
          : 'Chỉ dụ trước: ${m.decisionLabels.join(' → ')}. '
              '${previous > 0 ? 'Các phần chưa bảo vệ làm kinh phí ứng phó kỳ này tăng ${previous * 20}%.' : 'Các phần đã bảo vệ giúp giữ nguyên kinh phí kỳ này.'}';
  return EventDefinition(
    majorEventId(m),
    m.stage == 0 ? d.title : '${d.title} · ${goal.title}',
    'ĐẠI BIẾN CỐ ${d.code} · Bản tấu ${m.stage + 1}/${d.objectives.length} · mức ${m.severity}.\n'
        '${majorBody(s, m)}\n$memory\n'
        'Diễn biến cần ngự phê: ${goal.title}. '
        '${unavailable == null ? '' : '$unavailable Chỉ còn phương án dự phòng, không thể khôi phục người đã mất.'}\n'
        '${m.damageTaken.isEmpty ? '' : 'Tổn thất đã xảy ra: ${eventEffectText(m.damageTaken)}. Không thu hoặc trừ lại khi tổng kết.\n'}'
        'Hạn: cuối ${s.date(m.dueWeek)}. Bỏ quá hạn sẽ không tổ chức ứng phó phần việc này.',
    'Đại biến cố',
    [
      EventChoice(
        unavailable == null
            ? 'Huy động đầy đủ: ${goal.title}'
            : 'Huy động cho phương án dự phòng',
        '$cost tiền · $grain thóc · 2 hành động. '
        '${unavailable == null ? 'Bảo vệ đầy đủ phần việc này.' : 'Chỉ bảo vệ một phần.'} '
        '${eventEffectText(fullDamage)}. ${_majorNext(s, m)}',
        fullDamage,
        cost: cost,
        grainCost: grain,
        points: 2,
      ),
      EventChoice(
        'Ứng phó có giới hạn',
        '${(cost * .5).ceil()} tiền · ${(grain * .5).ceil()} thóc · 1 hành động. '
            'Bảo vệ $partialCoverage%; tổn thất ngay: ${eventEffectText(partialDamage)}. ${_majorNext(s, m)}',
        partialDamage,
        cost: (cost * .5).ceil(),
        grainCost: (grain * .5).ceil(),
        points: 1,
      ),
      EventChoice(
        'Chưa huy động, chấp nhận tổn thất',
        '0 tiền · 0 thóc · 1 hành động khi chủ động ngự phê. '
            'Không bảo vệ phần việc này; tổn thất ngay: ${eventEffectText(ignoredDamage)}. ${_majorNext(s, m)}',
        ignoredDamage,
        points: 1,
      ),
    ],
    condition: 'storyOnly',
  );
}

String _majorNext(GameState s, MajorMission m) =>
    m.stage == m.objectives.length - 1
        ? 'Khép đại biến cố; phần ứng phó yếu có thể để lại dư âm.'
        : 'Bản tấu tiếp theo vào ${s.date(s.week + 1)}; quyết định này được giữ lại.';

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
