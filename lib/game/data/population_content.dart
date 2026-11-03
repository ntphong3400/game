import '../models/event_definition.dart';
import '../models/game_state.dart';
import '../logic/population_rules.dart';
import '../logic/development_rules.dart';
import '../logic/food_pressure_rules.dart';
import 'expanded_events.dart' show eventEffectText;
import 'reign_content.dart';

const populationEvents = [
  EventDefinition(
    'population_refugees',
    'Lưu dân ngoài cửa ải',
    'Một đoàn có 10.000 người đủ sức lao động xin định cư. Văn thần muốn mở cửa cứu người; '
        'Võ tướng lo việc tiếp nhận gây khó giữ an ninh. Ngân sách và lương thực hỗ trợ được cấp trước; '
        'người mới chỉ đóng góp sản xuất sau khi ổn định.',
    'Dân cư',
    [
      EventChoice(
        'Tiếp nhận toàn bộ',
        'Chi 50 tiền, 10.000 tạ; nhận 10.000 lao động khi khép mùa. '
            'Văn thần +3, Võ tướng −5.',
        {'refugees': 10000, 'faction:Văn thần': 3, 'faction:Võ tướng': -5},
        cost: 50,
        grainCost: 10000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Tiếp nhận một nửa',
        'Chi 30 tiền, 5.000 tạ; nhận 5.000 lao động khi khép mùa. '
            'Văn thần +1, Võ tướng −2.',
        {'refugees': 5000, 'faction:Văn thần': 1, 'faction:Võ tướng': -2},
        cost: 30,
        grainCost: 5000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Khước từ tiếp nhận',
        'Không nhận dân. Võ tướng +3, Văn thần −5.',
        {'faction:Võ tướng': 3, 'faction:Văn thần': -5},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'population',
    cooldown: 52,
  ),
  EventDefinition(
    'population_settlers',
    'Đất lành đón người lập nghiệp',
    'Năm nghìn lao động muốn đến khai khẩn và lập nghiệp. Họ cần phí di chuyển, giống và '
        'lương thực trong thời gian ổn định; nguồn thu và sản lượng chỉ tăng khi có việc làm.',
    'Dân cư',
    [
      EventChoice(
        'Cấp vốn và lương lập nghiệp',
        'Chi 40 tiền, 7.000 tạ; nhận 5.000 lao động khi khép mùa.',
        {'settlers': 5000},
        cost: 40,
        grainCost: 7000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Chưa tiếp nhận',
        'Không thay đổi dân số.',
        {},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'population',
    cooldown: 52,
  ),
  EventDefinition(
    'population_return',
    'Người bỏ xứ xin hồi hương',
    'Dân từng lưu tán muốn quay về. Triều đình có thể hỗ trợ đường về và khôi phục sinh kế; '
        'chỉ nhận lại những người còn trong sổ lưu tán.',
    'Dân cư',
    [
      EventChoice(
        'Hỗ trợ hồi hương',
        'Chi 30 tiền, 4.000 tạ; nhận lại tối đa 10.000 lao động, '
            'không vượt số người còn lưu tán.',
        {'returnees': 10000},
        cost: 30,
        grainCost: 4000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Chờ an toàn hơn',
        'Chưa đón người về.',
        {},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'populationReturn',
    cooldown: 39,
  ),
  EventDefinition(
    'population_epidemic',
    'Dịch bệnh lan trong các phủ',
    'Các phủ báo dịch bệnh làm nhiều người mất khả năng lao động. Cần cấp thuốc và khẩu phần '
        'cứu trợ; bỏ mặc làm tăng tổn thất dân số mỗi mùa.',
    'Dân cư',
    [
      EventChoice(
        'Cấp thuốc và tổ chức phòng dịch',
        'Chi 35 tiền, 5.000 tạ; mức dịch −1, lòng dân +2.',
        {'disease': -1, 'people': 2},
        cost: 35,
        grainCost: 5000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Để địa phương tự lo',
        'Mức dịch +1, lòng dân −3.',
        {'disease': 1, 'people': -3},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'population',
    cooldown: 104,
    minWeek: 13,
  ),
  EventDefinition(
    'population_border_skirmish',
    'Toán địch quấy phá đường biên',
    'Một toán địch cắt đường vận tải. Cần cử 3.000 quân làm nhiệm vụ trong mùa; '
        'tổn thất chỉ tính trên toán quân này.',
    'Quân sự',
    [
      EventChoice(
        'Cử 3.000 quân bảo vệ đường biên',
        'Chi 35 tiền, 1.980 tạ. '
            'Giao tranh nhỏ: tổn thất 1–20%; thất bại nặng: 50–70%.',
        {},
        cost: 35,
        grainCost: 1980,
        points: 1,
        troops: 3000,
        combat: 'small',
        laterEffects: {'morale': 3, 'authority': 2},
        laterFailureEffects: {'authority': -2},
        nativeResources: true,
      ),
      EventChoice(
        'Không điều quân',
        'Dân bỏ xứ 1.000 người, lòng dân −3.',
        {'displaced': 1000, 'people': -3},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'population',
    cooldown: 52,
    minWeek: 8,
  ),
  EventDefinition(
    'population_major_battle',
    'Giữ tuyến phòng thủ phía Bắc',
    'Đối phương tập trung quân đánh cửa ải. Cần 10.000 quân cho nhiệm vụ này; '
        'phần quân còn lại vẫn bảo vệ các nơi khác.',
    'Quân sự',
    [
      EventChoice(
        'Cử 10.000 quân giữ ải',
        'Chi 60 tiền, 6.600 tạ. '
            'Giao tranh lớn: tổn thất 20–50%; thất bại nặng: 50–70%.',
        {},
        cost: 60,
        grainCost: 6600,
        points: 1,
        troops: 10000,
        combat: 'large',
        laterEffects: {'war': -1, 'authority': 3},
        laterFailureEffects: {'war': 1, 'authority': -3},
        nativeResources: true,
      ),
      EventChoice(
        'Rút dân khỏi khu vực',
        'Chi 20 tiền, 5.000 tạ; uy quyền −2.',
        {'authority': -2},
        cost: 20,
        grainCost: 5000,
        points: 1,
        nativeResources: true,
      ),
      EventChoice(
        'Chưa tổ chức phòng thủ',
        'Dân lưu tán 5.000, lòng dân −5, chiến tranh +1.',
        {'displaced': 5000, 'people': -5, 'war': 1},
        points: 1,
        nativeResources: true,
      ),
    ],
    condition: 'population',
    cooldown: 65,
    minWeek: 13,
  ),
];

EventDefinition populationEvent(GameState s, EventDefinition e) {
  if (s.population == null) return e;
  final disaster =
      e.category == 'Thiên tai' ||
      e.id == 'flood' ||
      e.trigger == 'flood' ||
      (e.id.startsWith('major:') &&
          majorDefinition(e.id.split(':')[1]).group == 'disaster');
  Map<String, int> convert(Map<String, int> effects, String context) =>
      populationEffects(
        disaster ? protectLeveeFromDisaster(s, effects) : effects,
        context: context,
        challenging: s.challengingEconomy,
      );
  final choices =
      e.choices.map((c) {
        if (c.nativeResources) return c;
        final context = '${e.id} ${e.title} ${c.label}'.toLowerCase();
        final effects = convert(c.effects, context);
        final later = convert(c.laterEffects, context);
        final failure = convert(c.laterFailureEffects, context);
        final battle =
            e.category == 'Quân sự' &&
            RegExp(
              'điều quân|dẹp cướp|tiến công|đánh đuổi|xuất quân',
            ).hasMatch(c.label.toLowerCase());
        final majorBattle =
            e.id.startsWith('major:') &&
            s.major != null &&
            majorDefinition(s.major!.kind).group == 'military' &&
            majorDefinition(
                  s.major!.kind,
                ).objectives[s.major!.stage].specialty ==
                'Quân sự';
        final troops =
            battle
                ? 3000
                : majorBattle && !c.label.contains('Chưa huy động')
                ? (c.points == 2 ? 10000 : 5000)
                : 0;
        final rations =
            troops == 0 ? 0 : foodAmount(troops * 30 * 2 / 100 * 1.1);
        final grain = mathMax(
          authoredFood(
            c.grainCost,
            context: context,
            challenging: s.challengingEconomy,
          ),
          rations,
        );
        final hints = <String>[
          if (c.cost > 0) 'Chi ${c.cost} tiền',
          if (grain > 0) 'Xuất ${whole(grain)} tạ',
          eventEffectText(effects),
          if (ordinaryDisasterHint(s, e, e.choices.indexOf(c)).isNotEmpty)
            ordinaryDisasterHint(s, e, e.choices.indexOf(c)),
          if (e.id.startsWith('major:') &&
              s.major != null &&
              crisisProductionHint(
                s,
                s.major!,
                e.choices.indexOf(c),
              ).isNotEmpty)
            crisisProductionHint(s, s.major!, e.choices.indexOf(c)),
          if (disaster && (c.effects['levee'] ?? 0) < 0 && s.leveeLevel > 1)
            'Đã giảm ${leveeDisasterReductions[s.leveeLevel]}% thiệt hại đê do cấp công trình',
          if (troops > 0)
            '${whole(troops)} quân làm nhiệm vụ; tổn thất '
                '${majorBattle ? '20–50%' : '1–20%'}; thất bại nặng 50–70%',
          if (later.isNotEmpty) 'Kết quả chờ: ${eventEffectText(later)}',
          if (failure.isNotEmpty) 'Thất bại: ${eventEffectText(failure)}',
          if (c.followup == 'weapons') 'Nhận 8.000 bộ quân khí cuối kỳ',
          if (c.followup.isNotEmpty && c.followup != 'weapons') c.hint,
        ];
        return EventChoice(
          c.label,
          hints.join(' · '),
          effects,
          cost: c.cost,
          grainCost: grain,
          points: c.points,
          followup: c.followup,
          delay: c.delay,
          laterEffects: later,
          laterFailureEffects: failure,
          successChance: c.successChance,
          economy: c.economy,
          troops: troops,
          combat: majorBattle ? 'large' : 'small',
          naval:
              !s.hasCourtSystem &&
              RegExp('sông|biển|thủy|hải|đô đốc').hasMatch(context),
          nativeResources: true,
        );
      }).toList();
  return EventDefinition(
    e.id,
    e.title,
    e.body,
    e.category,
    choices,
    condition: e.condition,
    cooldown: e.cooldown,
    minWeek: e.minWeek,
    family: e.family,
    trigger: e.trigger,
    foodCostsNative: e.foodCostsNative,
  );
}

int mathMax(int a, int b) => a > b ? a : b;

/// Military petitions now open a selectable campaign task. No fee or fixed
/// contingent is committed until the player confirms its own army and leaders.
EventDefinition warEvent(GameState s, EventDefinition e) {
  if (s.warfare == null || !e.choices.any((c) => c.troops > 0)) return e;
  return EventDefinition(
    e.id,
    e.title,
    'Quân báo yêu cầu ứng phó. Nhận nhiệm vụ để chọn đối sách, số quân và chỉ huy tại Quân sự. Chi phí chỉ thu khi xác nhận xuất quân.',
    e.category,
    [
      for (final c in e.choices)
        if (c.troops == 0)
          c
        else
          EventChoice(
            'Nhận nhiệm vụ: ${c.label}',
            'Mở nhiệm vụ với ${whole(c.troops)} quân địch; chọn 80/100/125% quân, chủ tướng và phó tướng tại Quân sự. Thắng vẫn có thương vong.',
            {'warMission': c.troops},
            points: 0,
            combat: c.combat,
            naval: !s.hasCourtSystem && c.naval,
            laterEffects: {
              for (final key in {...c.effects, ...c.laterEffects}.keys)
                key: (c.effects[key] ?? 0) + (c.laterEffects[key] ?? 0),
            },
            laterFailureEffects: c.laterFailureEffects,
            nativeResources: true,
          ),
    ],
    condition: e.condition,
    cooldown: e.cooldown,
    minWeek: e.minWeek,
    family: e.family,
    trigger: e.trigger,
    foodCostsNative: e.foodCostsNative,
  );
}
