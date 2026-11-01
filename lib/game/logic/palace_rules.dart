import 'population_rules.dart';
import 'currency_rules.dart';
import '../models/game_state.dart';
import 'personnel_rules.dart' show officerBusy;

class PalaceDuty {
  const PalaceDuty(
    this.id,
    this.title,
    this.group,
    this.description,
    this.cost,
    this.grain,
    this.duration,
    this.minAbility,
    this.xp,
    this.benefit, {
    this.risk = 'Thất bại mất kinh phí đã cấp, chỉ nhận ít kinh nghiệm.',
  });
  final String id, title, group, description, benefit, risk;
  final int cost, grain, duration, minAbility, xp;
}

const palaceDuties = <PalaceDuty>[
  PalaceDuty(
    'inventory',
    'Kiểm kê kho nội cung',
    'Chi tiêu',
    'Đối chiếu sổ sách, kiểm tra vật dụng và việc cấp phát.',
    15,
    0,
    2,
    40,
    10,
    'Giảm tối đa 8 tiền chi hậu cung/mùa trong 3 mùa tiếp theo.',
  ),
  PalaceDuty(
    'procurement',
    'Chấn chỉnh việc mua sắm',
    'Chi tiêu',
    'Kiểm tra giá cả, chất lượng và người cung ứng.',
    20,
    0,
    2,
    50,
    12,
    'Giảm 5 tiền cho 5 lần giao cung vụ tiếp theo, hiệu lực 4 mùa; không giảm học phí.',
  ),
  PalaceDuty(
    'wardrobe',
    'Quản lý y phục, vật dụng',
    'Chi tiêu',
    'Sửa chữa đồ cũ và điều phối may sắm theo mùa.',
    8,
    0,
    1,
    0,
    5,
    'Giảm tối đa 4 tiền chi hậu cung/mùa trong 3 mùa tiếp theo.',
  ),
  PalaceDuty(
    'kitchen',
    'Chỉnh đốn ngự thiện',
    'Long thể',
    'Kiểm tra bếp, nguồn thực phẩm và chế độ ăn của vua.',
    15,
    5,
    2,
    40,
    10,
    'Hỗ trợ +2 sức khỏe/mùa trong 3 mùa tiếp theo, tối đa 100.',
  ),
  PalaceDuty(
    'herbs',
    'Trông coi vườn dược liệu',
    'Long thể',
    'Phối hợp Ngự y chăm sóc và bảo quản dược liệu.',
    25,
    0,
    3,
    50,
    15,
    'Giảm 10 tiền cho 3 lần chữa bệnh tiếp theo, hiệu lực 6 mùa.',
  ),
  PalaceDuty(
    'quiet',
    'Thu xếp tĩnh dưỡng',
    'Long thể',
    'Sắp xếp nơi nghỉ và điều chỉnh sinh hoạt.',
    10,
    0,
    1,
    0,
    5,
    'Giảm 6 căng thẳng khi hoàn tất.',
  ),
  PalaceDuty(
    'ceremony',
    'Chủ trì nghi lễ',
    'Nội cung & gia tộc',
    'Chuẩn bị lễ tiết và kiểm tra nghi thức; nhận việc vào Thu hoặc Đông.',
    30,
    5,
    2,
    60,
    18,
    'Uy quyền +3 khi hoàn tất.',
    risk: 'Thất bại: uy quyền −1, mất kinh phí; vẫn nhận ít kinh nghiệm.',
  ),
  PalaceDuty(
    'kinship',
    'Tiếp đón gia quyến',
    'Nội cung & gia tộc',
    'Đón tiếp thân quyến một phe được chọn và trao đổi nguyện vọng.',
    20,
    0,
    1,
    50,
    10,
    'Thái độ phe được chọn +6; phe đối lập −3.',
    risk: 'Thất bại: thái độ phe được chọn −3, mất kinh phí.',
  ),
  PalaceDuty(
    'harmony',
    'Hòa giải hậu cung',
    'Nội cung & gia tộc',
    'Lắng nghe, giải quyết bất đồng khi hậu cung có người bất mãn.',
    10,
    0,
    2,
    50,
    12,
    'Ổn định triều đình +2; hai người thiện cảm thấp nhất được +5 thiện cảm, −5 bất mãn và −3 tiến độ âm mưu.',
  ),
  PalaceDuty(
    'staff',
    'Chấn chỉnh cung nhân',
    'Nội cung & gia tộc',
    'Chấn chỉnh người phục vụ khi nội cung thiếu ổn định hoặc có âm mưu.',
    15,
    0,
    2,
    55,
    14,
    'Ổn định triều đình +3; giảm 1 tiến độ âm mưu mỗi người trong hậu cung/mùa trong 2 mùa tiếp theo.',
  ),
  PalaceDuty(
    'charity',
    'Tổ chức phát chẩn',
    'Dân sinh',
    'Chuẩn bị vật phẩm và phối hợp phân phát cho dân khó khăn.',
    20,
    25,
    2,
    45,
    12,
    'Lòng dân +4 khi hoàn tất.',
  ),
  PalaceDuty(
    'school',
    'Bảo trợ học đường',
    'Dân sinh',
    'Cấp sách và vật dụng cho lớp học của trẻ em nghèo.',
    40,
    0,
    3,
    65,
    24,
    'Lòng dân +6 khi hoàn tất.',
  ),
];

PalaceDuty? palaceDuty(String id) =>
    palaceDuties.where((d) => d.id == id).firstOrNull;
String palaceWorkTitle(String kind) =>
    kind == 'study'
        ? 'Theo học trong cung'
        : palaceDuty(kind)?.title ?? 'Cung vụ';
PalaceWork? palaceWorkFor(GameState s, String id) =>
    s.palaceWorks.where((w) => w.personId == id).firstOrNull;
bool palaceResident(Courtier c) =>
    c.available && c.isConsort && c.inHarem && c.age >= 18;
int palaceExperienceNeeded(int ability) =>
    ability < 60
        ? 10
        : ability < 80
        ? 20
        : ability < 90
        ? 40
        : 60;
int studyExperience(Courtier c) =>
    c.ability >= 100
        ? 0
        : c.ability < 80
        ? 20
        : 10;
int dutyExperience(PalaceDuty d, Courtier c) =>
    c.ability >= 100 || (c.ability >= 80 && d.minAbility < 60) ? 0 : d.xp;

String palaceProgress(GameState s, Courtier c) {
  final work = palaceWorkFor(s, c.id);
  return work == null
      ? 'Đang rảnh'
      : '${palaceWorkTitle(work.kind)} · ${work.progress}/${work.duration} mùa · hoàn tất cuối ${s.date(work.dueTurn)}';
}

String? palaceDutyUnavailable(GameState s, PalaceDuty d) {
  if (!s.seasonal) return 'Cung vụ dành cho lượt chơi theo mùa.';
  if (d.id == 'ceremony' && !['Thu', 'Đông'].contains(s.season)) {
    return 'Nhận việc vào mùa Thu hoặc Đông.';
  }
  final residents = s.court.where(palaceResident).toList();
  if (d.id == 'harmony' &&
      (residents.length < 2 || !residents.any((c) => c.affection < 70))) {
    return 'Cần ít nhất hai người trong cung và có người thiện cảm dưới 70.';
  }
  if (d.id == 'staff' &&
      s.stability >= 70 &&
      !residents.any((c) => c.plot >= 30)) {
    return 'Chỉ cần khi Ổn định triều đình dưới 70 hoặc hậu cung có dấu hiệu âm mưu.';
  }
  if (s.palaceWorks.where((w) => w.kind != 'study').length >= 2) {
    return 'Đã có hai cung vụ đang thực hiện.';
  }
  if (s.palaceWorks.any((w) => w.kind == d.id)) {
    return 'Cung vụ này đang có người phụ trách.';
  }
  return null;
}

String? palacePersonUnavailable(GameState s, Courtier c, {PalaceDuty? duty}) {
  if (!s.seasonal) return 'Học tập và cung vụ dành cho lượt chơi theo mùa.';
  if (!palaceResident(c)) return 'Cần là người trưởng thành đã nhập cung.';
  if (palaceWorkFor(s, c.id) != null) {
    return 'Đang học hoặc phụ trách cung vụ khác.';
  }
  if (officerBusy(s, c.id)) {
    return 'Đang phụ trách tấu chương hoặc công việc khác.';
  }
  if (duty == null && c.ability >= 100) return 'Năng lực đã đạt tối đa.';
  if (duty != null && c.ability < duty.minAbility) {
    return 'Cần năng lực từ ${duty.minAbility}.';
  }
  return null;
}

int palaceSuccessChance(
  GameState s,
  Courtier c,
  PalaceDuty d, {
  bool preview = false,
}) {
  var chance = 35 + c.ability * 0.55 + (c.affection - 50) * 0.12;
  final traits = preview ? c.knownPersonalities : c.personalities;
  for (final p in traits) {
    chance += switch (p) {
      Personality.dutiful || Personality.disciplined => 5,
      Personality.negligent => -12,
      Personality.cautious
          when [
            'inventory',
            'procurement',
            'herbs',
            'wardrobe',
          ].contains(d.id) =>
        6,
      Personality.diplomatic
          when ['kinship', 'harmony', 'ceremony'].contains(d.id) =>
        8,
      Personality.hotTempered when ['kinship', 'harmony'].contains(d.id) => -10,
      Personality.compassionate when ['charity', 'school'].contains(d.id) => 8,
      _ => 0,
    };
  }
  return chance.round().clamp(25, 95);
}

PalaceEffect? palaceEffect(GameState s, String kind) =>
    s.palaceEffects
        .where((e) => e.kind == kind && e.active(s.week))
        .firstOrNull;
int palaceDutyDiscount(GameState s) {
  final e = palaceEffect(s, 'procurement');
  return e != null && e.uses > 0 ? e.amount : 0;
}

int palaceDutyCost(GameState s, PalaceDuty d) =>
    money(s, (d.cost - palaceDutyDiscount(s)).clamp(0, d.cost));
int palaceTreatmentDiscount(GameState s) {
  final e = palaceEffect(s, 'herbs');
  return e != null && e.uses > 0 ? money(s, e.amount) : 0;
}

int palaceUpkeepSaving(GameState s) {
  final residents = s.court.where(palaceResident).length;
  final saving =
      (palaceEffect(s, 'inventory')?.amount ?? 0) +
      (palaceEffect(s, 'wardrobe')?.amount ?? 0);
  return saving.clamp(0, (residents * 6).clamp(0, 8));
}

String palaceEffectDescription(PalaceEffect e) => switch (e.kind) {
  'inventory' || 'wardrobe' =>
    'Giảm tối đa ${e.amount} tiền chi hậu cung/mùa (tổng trần 8 và không vượt chi hậu cung)',
  'procurement' => 'Giảm ${e.amount} tiền/lần giao cung vụ · còn ${e.uses} lần',
  'herbs' => 'Giảm ${e.amount} tiền/lần chữa bệnh · còn ${e.uses} lần',
  'kitchen' => 'Sức khỏe +${e.amount}/mùa',
  'staff' => 'Tiến độ âm mưu hậu cung −${e.amount}/người/mùa',
  _ => '',
};

int palaceDutyFood(GameState s, PalaceDuty d) =>
    s.population == null ? d.grain : authoredFood(d.grain, context: 'palace');
