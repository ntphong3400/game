import '../models/event_definition.dart';
import '../models/game_labels.dart';
import 'event_stories.dart';

class _Plan {
  const _Plan(
    this.effects, {
    this.cost = 0,
    this.grain = 0,
    this.points = 0,
    this.later = const {},
    this.fail = const {},
    this.delay = 0,
    this.chance = 100,
    this.economy,
  });
  final Map<String, int> effects, later, fail;
  final int cost, grain, points, delay, chance;
  final PetitionEconomy? economy;
}

// Each pack has three different decision patterns. Texts and choice labels are
// individually authored in event_stories.dart; there is no runtime text shuffle.
const _plans = <String, List<List<_Plan>>>{
  'community': [
    [
      _Plan({'people': 6}, cost: 35),
      _Plan({'people': 3, 'authority': -2, 'grain': -3}),
      _Plan({'people': -3}),
    ],
    [
      _Plan({'people': 4, 'authority': 2, 'fatigue': 3}, points: 1),
      _Plan({'authority': 4, 'people': -3}),
      _Plan({'people': -2, 'stability': -1}),
    ],
    [
      _Plan(
        {'people': 2},
        cost: 30,
        later: {'people': 6, 'authority': 2},
        fail: {'people': -3, 'treasury': -10},
        delay: 3,
        chance: 75,
      ),
      _Plan({'people': 4, 'stability': -2}, grain: 15),
      _Plan({'people': -4, 'authority': -1}),
    ],
  ],
  'finance': [
    [
      _Plan({'people': 4, 'debt': -10}, cost: 30),
      _Plan({'treasury': 25, 'people': -4}),
      _Plan({'authority': -2, 'people': -1}),
    ],
    [
      _Plan(
        {'authority': 1},
        cost: 20,
        later: {'treasury': 45, 'authority': 3},
        economy: PetitionEconomy.recovery(70),
        fail: {'stability': -2, 'treasury': -8},
        delay: 2,
        chance: 75,
      ),
      _Plan({'treasury': 20, 'faction:Thế gia': 3, 'authority': -3}),
      _Plan({'treasury': -12, 'authority': -1}),
    ],
    [
      _Plan(
        {'treasury': -10, 'people': 2},
        later: {'treasury': 40, 'people': 3},
        economy: PetitionEconomy.investment(45),
        fail: {'treasury': -20, 'people': -2},
        delay: 4,
        chance: 65,
      ),
      _Plan({'treasury': 30, 'debt': 40, 'faction:Thế gia': 2}),
      _Plan({'people': -3, 'stability': -1}),
    ],
  ],
  'commerce': [
    [
      _Plan(
        {'people': 2},
        cost: 30,
        later: {'treasury': 50, 'grain': 8},
        economy: PetitionEconomy.investment(85),
        fail: {'treasury': -10},
        delay: 4,
        chance: 75,
      ),
      _Plan({'treasury': 20, 'people': -2}),
      _Plan({'treasury': -5}),
    ],
    [
      _Plan({'authority': 3, 'people': 3}, cost: 25),
      _Plan({'treasury': 30, 'faction:Thế gia': 4, 'people': -4}),
      _Plan({'people': -3, 'authority': -1}),
    ],
    [
      _Plan({'grain': 22}, cost: 40),
      _Plan({'treasury': 35, 'grain': -18, 'people': -1}),
      _Plan({'grain': -5, 'people': -1}),
    ],
  ],
  'agriculture': [
    [
      _Plan(
        {'people': 2},
        cost: 35,
        later: {'grain': 35, 'people': 3},
        fail: {'grain': -6, 'treasury': -10},
        delay: 5,
        chance: 75,
      ),
      _Plan({'grain': 15, 'people': -4, 'fatigue': 2}),
      _Plan({'grain': -5, 'people': -2}),
    ],
    [
      _Plan({'people': 5, 'illness': -2}, grain: 18),
      _Plan({'grain': 20, 'authority': -4, 'faction:Thế gia': 3}),
      _Plan({'people': -5, 'army': -1}),
    ],
    [
      _Plan({'levee': 12, 'people': 2}, cost: 40),
      _Plan({'levee': 8, 'people': -4, 'stress': 2}),
      _Plan({'levee': -6, 'grain': -4}),
    ],
  ],
  'engineering': [
    [
      _Plan(
        {'people': 1},
        cost: 40,
        later: {'levee': 18, 'people': 4},
        fail: {'treasury': -15, 'authority': -2},
        delay: 4,
        chance: 80,
      ),
      _Plan({'levee': 10, 'people': -4}),
      _Plan({'levee': -5, 'people': -2}),
    ],
    [
      _Plan({'army': 4, 'people': 2}, cost: 35),
      _Plan({'treasury': 20, 'people': -3, 'stability': -1}),
      _Plan({'army': -2, 'people': -2}),
    ],
    [
      _Plan(
        {'authority': 2},
        cost: 20,
        later: {'treasury': 35, 'levee': 8},
        economy: PetitionEconomy.recovery(60),
        fail: {'authority': -3, 'treasury': -10},
        delay: 3,
        chance: 70,
      ),
      _Plan({'treasury': 15, 'faction:Thế gia': 3, 'authority': -3}),
      _Plan({'treasury': -10, 'levee': -3}),
    ],
  ],
  'military': [
    [
      _Plan({'army': 7, 'faction:Võ tướng': 2}, cost: 40),
      _Plan({'army': 5, 'people': -4, 'grain': -8}),
      _Plan({'army': -3, 'authority': -1}),
    ],
    [
      _Plan(
        {'army': 2},
        cost: 35,
        later: {'army': 10, 'war': -1},
        fail: {'army': -5, 'authority': -2},
        delay: 3,
        chance: 70,
      ),
      _Plan({'army': 4, 'stability': -3, 'faction:Võ tướng': 3}),
      _Plan({'army': -4, 'war': 1}),
    ],
    [
      _Plan({'army': 5, 'authority': 2}, grain: 20),
      _Plan({'army': 3, 'people': -5, 'faction:Văn thần': -2}),
      _Plan({'army': -4, 'stability': -2}),
    ],
  ],
  'diplomacy': [
    [
      _Plan(
        {'authority': 2},
        cost: 35,
        later: {'war': -2, 'treasury': 15},
        fail: {'war': 1, 'authority': -3},
        delay: 3,
        chance: 75,
      ),
      _Plan({'authority': 4, 'army': -3, 'war': 1}),
      _Plan({'authority': -2, 'war': 1}),
    ],
    [
      _Plan(
        {'people': 2},
        cost: 25,
        later: {'treasury': 45, 'faction:Thế gia': 2},
        economy: PetitionEconomy.investment(70),
        fail: {'treasury': -12, 'authority': -1},
        delay: 4,
        chance: 70,
      ),
      _Plan({'treasury': 25, 'war': 1, 'faction:Võ tướng': 2}),
      _Plan({'treasury': -8}),
    ],
    [
      _Plan({'war': -1, 'authority': 3}, cost: 40),
      _Plan({'army': 5, 'war': 1, 'faction:Võ tướng': 3}),
      _Plan({'war': 1, 'stability': -2}),
    ],
  ],
  'justice': [
    [
      _Plan({'authority': 4, 'people': 3, 'faction:Thế gia': -2}, points: 1),
      _Plan({'treasury': 20, 'people': -3, 'faction:Thế gia': 2}),
      _Plan({'people': -3, 'authority': -2}),
    ],
    [
      _Plan({'people': 4, 'authority': -2}, cost: 20),
      _Plan({'authority': 4, 'people': -4, 'stability': -1}),
      _Plan({'authority': -2, 'stability': -2}),
    ],
    [
      _Plan(
        {'authority': 1},
        cost: 20,
        later: {'authority': 5, 'people': 4},
        fail: {'authority': -3, 'people': -2},
        delay: 2,
        chance: 80,
      ),
      _Plan({'people': 2, 'stability': -2, 'faction:Văn thần': 2}),
      _Plan({'people': -4, 'stability': -2}),
    ],
  ],
  'bureaucracy': [
    [
      _Plan({'authority': 4, 'stability': 3, 'fatigue': 3}, points: 1),
      _Plan({'treasury': 20, 'authority': -3, 'faction:Thế gia': 2}),
      _Plan({'authority': -2, 'stability': -2}),
    ],
    [
      _Plan({'stability': 5, 'faction:Văn thần': 2}, cost: 30),
      _Plan({'authority': 4, 'stability': -3, 'faction:Võ tướng': 2}),
      _Plan({'stability': -3}),
    ],
    [
      _Plan(
        {'authority': 1},
        cost: 25,
        later: {'treasury': 40, 'stability': 3},
        economy: PetitionEconomy.recovery(75),
        fail: {'authority': -3, 'treasury': -10},
        delay: 3,
        chance: 75,
      ),
      _Plan({'treasury': 15, 'stability': -2, 'faction:Thế gia': 3}),
      _Plan({'treasury': -10, 'stability': -2}),
    ],
  ],
  'factions': [
    [
      _Plan({
        'stability': 5,
        'faction:Văn thần': 2,
        'faction:Võ tướng': 2,
      }, cost: 30),
      _Plan({'authority': 4, 'faction:Võ tướng': 5, 'faction:Văn thần': -5}),
      _Plan({'stability': -4, 'authority': -1}),
    ],
    [
      _Plan({
        'stability': 3,
        'authority': 2,
        'faction:Hoàng tộc': -2,
        'faction:Thế gia': -2,
      }, points: 1),
      _Plan({'treasury': 25, 'faction:Thế gia': 5, 'faction:Hoàng tộc': -5}),
      _Plan({'stability': -3, 'plotReduce': -3}),
    ],
    [
      _Plan({'authority': 5, 'plotReduce': 8}, cost: 35),
      _Plan({'stability': 4, 'authority': -3, 'faction:Hoàng tộc': 4}),
      _Plan({'authority': -4, 'plotReduce': -4}),
    ],
  ],
  'security': [
    [
      _Plan(
        {'authority': 2},
        cost: 25,
        later: {'plotReduce': 22, 'stability': 3},
        fail: {'plotReduce': -5, 'authority': -3},
        delay: 2,
        chance: 75,
      ),
      _Plan({'plotReduce': 10, 'people': -3, 'faction:Võ tướng': 2}),
      _Plan({'plotReduce': -5, 'authority': -2}),
    ],
    [
      _Plan({'plotReduce': 15, 'stability': 2}, cost: 30),
      _Plan({'authority': 4, 'stability': -4, 'faction:Văn thần': -3}),
      _Plan({'plotReduce': -5, 'stability': -2}),
    ],
    [
      _Plan({'authority': 3, 'plotReduce': 18, 'fatigue': 3}, points: 1),
      _Plan({'treasury': 20, 'plotReduce': -4, 'faction:Thế gia': 3}),
      _Plan({'authority': -3, 'plotReduce': -5}),
    ],
  ],
  'palace': [
    [
      _Plan({'stability': 4, 'stress': -3, 'faction:Hoàng tộc': 2}, cost: 25),
      _Plan({'treasury': 15, 'stability': -3, 'affection:Hoàng tộc': -2}),
      _Plan({'stability': -2, 'stress': 2}),
    ],
    [
      _Plan({
        'stability': 4,
        'authority': 2,
        'affection:Văn thần': 2,
      }, points: 1),
      _Plan({'faction:Thế gia': 5, 'faction:Văn thần': -4, 'stability': -2}),
      _Plan({'stability': -3, 'affection:Hoàng tộc': -2}),
    ],
    [
      _Plan({'stress': -5, 'revel': 1, 'stability': 2}, cost: 20),
      _Plan({'rest': 1, 'faction:Hoàng tộc': -2}, points: 1),
      _Plan({'stress': 3, 'stability': -1}),
    ],
  ],
  'health': [
    [
      _Plan({'illness': -8, 'health': 2, 'stress': -2}, cost: 25),
      _Plan({'rest': 1, 'fatigue': -5}, points: 1),
      _Plan({'illness': 3, 'fatigue': 3}),
    ],
    [
      _Plan({'fatigue': -8, 'stress': -5, 'rest': 1}, points: 1),
      _Plan({'authority': 2, 'fatigue': 8, 'stress': 4}),
      _Plan({'fatigue': 4, 'stress': 3}),
    ],
    [
      _Plan(
        {'illness': -2},
        cost: 30,
        later: {'health': 5, 'illness': -8},
        fail: {'illness': 5, 'health': -2},
        delay: 2,
        chance: 75,
      ),
      _Plan({'health': 2, 'stress': -2, 'treasury': -15}),
      _Plan({'illness': 3, 'health': -1}),
    ],
  ],
  'disasters': [
    [
      _Plan({'people': 5, 'levee': 5}, cost: 40),
      _Plan({'people': 4, 'army': -3}, grain: 12),
      _Plan({'people': -5, 'levee': -5}),
    ],
    [
      _Plan(
        {'people': 2},
        cost: 30,
        later: {'grain': 25, 'levee': 10},
        fail: {'grain': -8, 'people': -3},
        delay: 3,
        chance: 75,
      ),
      _Plan({'people': 2, 'grain': -8, 'debt': 15}),
      _Plan({'grain': -8, 'people': -4}),
    ],
    [
      _Plan({'people': 6, 'illness': -2}, grain: 20),
      _Plan({'people': 3, 'army': -4, 'authority': -2}),
      _Plan({'people': -6, 'grain': -6}),
    ],
  ],
  'culture': [
    [
      _Plan(
        {'people': 3},
        cost: 30,
        later: {'people': 6, 'authority': 3},
        delay: 4,
      ),
      _Plan({'authority': 3, 'faction:Văn thần': 3, 'people': -2}),
      _Plan({'people': -2, 'faction:Văn thần': -1}),
    ],
    [
      _Plan({'stability': 3, 'people': 3}, cost: 25),
      _Plan({'treasury': 20, 'people': -3, 'faction:Thế gia': 2}),
      _Plan({'stability': -2}),
    ],
    [
      _Plan(
        {'authority': 2},
        cost: 25,
        later: {'treasury': 30, 'people': 4},
        economy: PetitionEconomy.investment(70),
        fail: {'treasury': -10, 'authority': -2},
        delay: 5,
        chance: 75,
      ),
      _Plan({'people': 2, 'fatigue': 3, 'faction:Văn thần': 2}, points: 1),
      _Plan({'people': -2, 'authority': -1}),
    ],
  ],
};

const _categories = {
  'community': 'Dân sinh',
  'finance': 'Ngân khố',
  'commerce': 'Thương mại',
  'agriculture': 'Nông nghiệp',
  'engineering': 'Công trình',
  'military': 'Quân sự',
  'diplomacy': 'Ngoại giao',
  'justice': 'Pháp luật',
  'bureaucracy': 'Triều chính',
  'factions': 'Phe phái',
  'security': 'An ninh',
  'palace': 'Hậu cung',
  'health': 'Sức khỏe',
  'disasters': 'Thiên tai',
  'culture': 'Văn hóa',
};
const _starts = {
  'military': 8,
  'diplomacy': 8,
  'palace': 4,
  'security': 3,
  'health': 3,
};
const _effectNames = {
  'treasury': 'ngân khố',
  'gold': 'ngân khố (lượng vàng)',
  'goldDebt': 'nợ (lượng vàng)',
  'people': 'lòng dân',
  'authority': 'uy quyền',
  'army': 'quân lực',
  'health': 'sức khỏe',
  'stability': stabilityLabel,
  'grain': 'lương thực',
  'food': 'lương thực (tạ)',
  'training': 'huấn luyện',
  'equipment': 'quân khí (bộ)',
  'morale': 'sĩ khí',
  'logistics': 'hậu cần',
  'population': 'dân số lao động',
  'settlers': 'lao động chờ tiếp nhận',
  'refugees': 'lao động tị nạn chờ tiếp nhận',
  'returnees': 'dân hồi hương',
  'troops': 'quân số',
  'displaced': 'dân lưu tán',
  'disease': 'mức dịch bệnh',
  'levee': 'đê điều',
  'stress': 'căng thẳng',
  'fatigue': 'mệt mỏi',
  'illness': 'bệnh',
  'war': 'áp lực chiến tranh',
  'debt': 'nợ chi trả',
  'revel': 'lần hưởng lạc',
  'rest': 'lần nghỉ',
  'plotReduce': 'âm mưu',
};

String eventEffectText(Map<String, int> effects) =>
    effects.isEmpty
        ? 'không đổi chỉ số ngay'
        : effects.entries
            .map((e) {
              final key = e.key;
              if (key == 'warMission') {
                return 'Mở nhiệm vụ quân sự để chọn quân và tướng';
              }
              final value = key == 'plotReduce' ? -e.value : e.value;
              final label =
                  key.startsWith('faction:')
                      ? 'phe ${key.substring(8)}'
                      : key.startsWith('affection:')
                      ? 'thiện cảm phe ${key.substring(10)}'
                      : _effectNames[key] ?? key;
              return '$label ${value > 0 ? '+' : ''}$value';
            })
            .join(' · ');

EventChoice _choice(String label, _Plan p, {bool fallback = false}) {
  final effects = Map<String, int>.from(p.effects);
  var cost = p.cost;
  var grain = p.grain;
  if (!fallback) {
    if ((effects['treasury'] ?? 0) < 0) cost -= effects.remove('treasury')!;
    if ((effects['grain'] ?? 0) < 0) grain -= effects.remove('grain')!;
  }
  final immediate = [
    if (cost > 0) 'Chi $cost',
    if (grain > 0) 'xuất $grain lương thực',
    if (p.points > 0) '${p.points} hành động',
    eventEffectText(effects),
  ].join(' · ');
  final later =
      p.later.isEmpty
          ? ''
          : ' Sau ${p.delay} tuần: ${p.chance == 100 ? '' : '${p.chance}% thành công: '}${eventEffectText(p.later)}.${p.chance < 100 ? ' Nếu thất bại: ${eventEffectText(p.fail)}.' : ''}';
  return EventChoice(
    label,
    '$immediate.$later',
    effects,
    cost: cost,
    grainCost: grain,
    points: p.points,
    delay: p.delay,
    laterEffects: p.later,
    laterFailureEffects: p.fail,
    successChance: p.chance,
    economy: p.economy,
  );
}

final expandedEvents = <EventDefinition>[
  for (final pack in eventStories.entries) ..._buildPack(pack.key, pack.value),
];

List<EventDefinition> _buildPack(String pack, String source) {
  final rows = source.trim().split('\n');
  return [for (var i = 0; i < rows.length; i++) _buildEvent(pack, i, rows[i])];
}

EventDefinition _buildEvent(String pack, int index, String row) {
  final fields = row.split('|');
  if (fields.length != 6) throw StateError('Invalid event story $pack/$index');
  final settings = fields[0].split(':');
  final profile = int.parse(settings[0]);
  final trigger = settings.length > 2 ? settings[2] : '';
  return EventDefinition(
    '${pack}_${(index + 1).toString().padLeft(2, '0')}',
    fields[1],
    fields[2],
    trigger.isEmpty
        ? _categories[pack]!
        : ['plot_warning', 'succession_rumor'].contains(trigger)
        ? 'Âm mưu'
        : 'Khủng hoảng',
    [
      for (var j = 0; j < 3; j++)
        _choice(fields[j + 3], _plans[pack]![profile][j], fallback: j == 2),
    ],
    condition: settings.length > 1 ? settings[1] : 'any',
    minWeek: _starts[pack] ?? 2,
    cooldown: 26 + index % 4 * 13,
    family: trigger.isEmpty ? pack : 'urgent:$trigger',
    trigger: trigger,
  );
}
