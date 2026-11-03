import '../models/game_state.dart';
import '../logic/development_rules.dart';
import '../logic/petition_rules.dart';
export '../logic/petition_rules.dart';
import '../models/event_definition.dart';
import 'expanded_events.dart';
import 'regional_officials.dart';
import 'population_content.dart';
import '../logic/population_rules.dart';
import '../logic/food_pressure_rules.dart';
import '../logic/currency_rules.dart';
import 'story_petitions.dart';
import 'court_personnel_petitions.dart';
import '../logic/court_personnel_rules.dart';
export '../models/event_definition.dart';

const factionOpponents = {
  'Văn thần': 'Võ tướng',
  'Võ tướng': 'Văn thần',
  'Hoàng tộc': 'Thế gia',
  'Thế gia': 'Hoàng tộc',
};
const officialCategories = [
  'Văn ban',
  'Võ ban',
  'Địa phương',
  'Hoàng thất',
  'Nội đình',
];

List<Courtier> initialCourt() => [
  Courtier(
    id: 'chancellor',
    name: 'Trần Văn Chính',
    role: 'Tể tướng',
    faction: 'Văn thần',
    trait: 'Thận trọng, coi trọng phép nước',
    age: 54,
    ability: 85,
    loyalty: 72,
    ambition: 48,
    integrity: 78,
    influence: 80,
  ),
  Courtier(
    id: 'general',
    name: 'Lê Trọng Uy',
    role: 'Đại tướng',
    faction: 'Võ tướng',
    trait: 'Quyết đoán, có uy trong quân',
    age: 42,
    ability: 88,
    loyalty: 59,
    ambition: 76,
    integrity: 62,
    influence: 84,
  ),
  Courtier(
    id: 'treasurer',
    name: 'Phạm Hữu Tín',
    role: 'Hộ bộ',
    faction: 'Thế gia',
    trait: 'Giỏi tính toán, nhiều quan hệ',
    age: 46,
    ability: 43,
    loyalty: 60,
    ambition: 63,
    integrity: 45,
    influence: 65,
  ),
  Courtier(
    id: 'spy',
    name: 'Đỗ Minh Kính',
    role: 'Mật thám',
    faction: 'Hoàng tộc',
    trait: 'Kín tiếng, quan sát sắc bén',
    age: 35,
    ability: 81,
    loyalty: 80,
    ambition: 35,
    integrity: 75,
    influence: 48,
  ),
  Courtier(
    id: 'doctor',
    name: 'Tôn Bách Thảo',
    role: 'Ngự y',
    faction: 'Văn thần',
    trait: 'Điềm đạm, tận tâm',
    age: 60,
    ability: 86,
    loyalty: 82,
    ambition: 20,
    integrity: 90,
    influence: 32,
  ),
  Courtier(
    id: 'governor',
    name: 'Nguyễn Đức An',
    role: 'Tri phủ',
    faction: 'Văn thần',
    trait: 'Gần dân, quen việc đê điều',
    age: 39,
    ability: 76,
    loyalty: 70,
    ambition: 42,
    integrity: 80,
    influence: 42,
  ),
  Courtier(
    id: 'prince',
    name: 'Hoàng Minh Viễn',
    role: 'Thân vương',
    faction: 'Hoàng tộc',
    trait: 'Lịch thiệp, có dòng dõi kế vị',
    age: 27,
    ability: 73,
    loyalty: 42,
    ambition: 88,
    integrity: 50,
    influence: 77,
  ),
  Courtier(
    id: 'scholar',
    name: 'Vũ Thanh Liêm',
    role: 'Ngự sử',
    faction: 'Văn thần',
    trait: 'Thẳng thắn, ghét tham nhũng',
    age: 33,
    ability: 78,
    loyalty: 78,
    ambition: 32,
    integrity: 94,
    influence: 45,
  ),
  Courtier(
    id: 'duke',
    name: 'Đặng Quốc Hưng',
    role: 'Quốc công',
    faction: 'Thế gia',
    trait: 'Trọng lợi ích gia tộc',
    age: 51,
    ability: 67,
    loyalty: 50,
    ambition: 78,
    integrity: 35,
    influence: 82,
  ),
  Courtier(
    id: 'consort_lan',
    name: 'Nguyễn Ngọc Lan',
    role: 'Tiểu thư',
    faction: 'Văn thần',
    trait: 'Ôn hòa, giỏi thu xếp',
    age: 21,
    ability: 84,
    loyalty: 72,
    ambition: 42,
    integrity: 85,
    influence: 38,
  ),
  Courtier(
    id: 'consort_mai',
    name: 'Đặng Thanh Mai',
    role: 'Tiểu thư',
    faction: 'Thế gia',
    trait: 'Sắc sảo, gia tộc quyền thế',
    age: 23,
    ability: 78,
    loyalty: 56,
    ambition: 80,
    integrity: 55,
    influence: 68,
  ),
  Courtier(
    id: 'consort_yen',
    name: 'Lê Hải Yến',
    role: 'Tiểu thư',
    faction: 'Võ tướng',
    trait: 'Cương trực, yêu thi ca',
    age: 20,
    ability: 70,
    loyalty: 78,
    ambition: 35,
    integrity: 82,
    influence: 45,
  ),
  ..._additionalOfficials(),
  ..._additionalCandidates(),
  ...regionalOfficialAdditions.map(
    (j) => Courtier.fromJson(Map<String, dynamic>.from(j)),
  ),
];

Courtier _official(
  String id,
  String name,
  String role,
  String faction,
  int age,
  int ability,
  int loyalty,
  int ambition,
  int integrity,
  int influence,
  String trait,
) => Courtier(
  id: id,
  name: name,
  role: role,
  faction: faction,
  age: age,
  ability: ability,
  loyalty: loyalty,
  ambition: ambition,
  integrity: integrity,
  influence: influence,
  trait: trait,
);

List<Courtier> _additionalOfficials() => [
  _official(
    'academician',
    'Phan Kính Văn',
    'Học sĩ',
    'Văn thần',
    37,
    82,
    76,
    38,
    86,
    46,
    'Uyên bác, thường can gián thẳng lời',
  ),
  _official(
    'rites',
    'Bùi Quang Lễ',
    'Lễ bộ',
    'Văn thần',
    48,
    46,
    68,
    51,
    73,
    58,
    'Coi trọng lễ chế và danh phận',
  ),
  _official(
    'works',
    'Đào Công Thành',
    'Công bộ',
    'Văn thần',
    41,
    83,
    71,
    44,
    79,
    51,
    'Thực tế, am hiểu công trình',
  ),
  _official(
    'deputy_general',
    'Lê Bá Kiên',
    'Phó tướng',
    'Võ tướng',
    36,
    80,
    73,
    52,
    70,
    62,
    'Trọng kỷ luật và lời hứa',
  ),
  _official(
    'admiral',
    'Trần Hải Nam',
    'Đô đốc',
    'Võ tướng',
    44,
    84,
    66,
    57,
    67,
    69,
    'Quen thủy chiến, dè chừng quan văn',
  ),
  _official(
    'guard',
    'Ngô Đình Vệ',
    'Cấm vệ',
    'Võ tướng',
    32,
    77,
    83,
    34,
    88,
    54,
    'Kín kẽ, đặt việc bảo vệ vua lên trước',
  ),
  _official(
    'border_general',
    'Hoàng Sơn Lâm',
    'Biên tướng',
    'Võ tướng',
    49,
    79,
    67,
    58,
    61,
    64,
    'Dày dạn trận mạc, khó chịu việc chậm lương',
  ),
  _official(
    'marshal',
    'Phạm Võ Dũng',
    'Võ quan',
    'Võ tướng',
    30,
    34,
    70,
    55,
    75,
    43,
    'Nóng tính nhưng coi trọng quân sĩ',
  ),
  _official(
    'garrison',
    'Vũ Thành Bắc',
    'Trấn thủ',
    'Võ tướng',
    46,
    74,
    64,
    59,
    68,
    58,
    'Thận trọng, quen giữ vùng xa',
  ),
  _official(
    'royal_cousin',
    'Hoàng Minh Khiêm',
    'Quận vương',
    'Hoàng tộc',
    31,
    39,
    65,
    55,
    71,
    63,
    'Giữ danh dự hoàng gia, ít bộc lộ ý riêng',
  ),
  _official(
    'royal_tutor',
    'Đinh Trọng Đạo',
    'Thái phó',
    'Hoàng tộc',
    58,
    87,
    84,
    25,
    89,
    60,
    'Từng dạy vua học, nghiêm khắc và tận tâm',
  ),
  _official(
    'royal_clan',
    'Hoàng Đức Cẩn',
    'Tông chính',
    'Hoàng tộc',
    52,
    72,
    66,
    54,
    74,
    66,
    'Ưu tiên quyền lợi của tông thất',
  ),
  _official(
    'steward',
    'Lưu Phúc Toàn',
    'Tổng quản',
    'Hoàng tộc',
    43,
    48,
    75,
    46,
    65,
    52,
    'Quen việc trong cung, nhiều tai mắt',
  ),
  _official(
    'chamberlain',
    'Nguyễn An Tường',
    'Ngự tiền',
    'Hoàng tộc',
    28,
    69,
    79,
    36,
    82,
    38,
    'Chăm chỉ, quan sát kỹ tâm trạng nhà vua',
  ),
  _official(
    'personnel',
    'Đặng Hữu Phúc',
    'Lại bộ',
    'Thế gia',
    47,
    80,
    64,
    58,
    56,
    70,
    'Giỏi chọn người, coi trọng quan hệ gia tộc',
  ),
  _official(
    'justice',
    'Tạ Công Luật',
    'Hình bộ',
    'Thế gia',
    50,
    82,
    69,
    47,
    78,
    59,
    'Rành luật lệ, ít nhượng bộ',
  ),
  _official(
    'trade_officer',
    'Phạm Kim Bảo',
    'Thương chính',
    'Thế gia',
    38,
    81,
    63,
    59,
    49,
    62,
    'Khéo thương lượng, luôn cân nhắc lợi ích',
  ),
  _official(
    'provincial',
    'Bùi Gia Thịnh',
    'Tuần phủ',
    'Thế gia',
    45,
    76,
    65,
    56,
    66,
    61,
    'Có thế lực địa phương và nhiều điền trang',
  ),
  _official(
    'land_officer',
    'Đỗ Điền Phong',
    'Quan điền',
    'Thế gia',
    34,
    44,
    70,
    45,
    77,
    45,
    'Quen mùa vụ, muốn mở mang ruộng đất',
  ),
];

List<Courtier> _additionalCandidates() => [
  _official(
    'consort_truc',
    'Phan Thanh Trúc',
    'Tiểu thư',
    'Văn thần',
    22,
    79,
    74,
    39,
    87,
    40,
    'Yêu sách vở, ứng xử điềm đạm',
  ),
  _official(
    'consort_dao',
    'Trần Bích Đào',
    'Tiểu thư',
    'Võ tướng',
    24,
    73,
    70,
    48,
    76,
    52,
    'Giỏi cưỡi ngựa, xuất thân nhà tướng',
  ),
  _official(
    'consort_khue',
    'Hoàng Tú Khuê',
    'Tiểu thư',
    'Hoàng tộc',
    20,
    81,
    72,
    51,
    80,
    57,
    'Cẩn trọng, hiểu lễ nghi hoàng gia',
  ),
  _official(
    'consort_nguyet',
    'Lưu Ánh Nguyệt',
    'Tiểu thư',
    'Hoàng tộc',
    25,
    76,
    69,
    55,
    72,
    49,
    'Giỏi thu xếp, thích giữ hòa khí',
  ),
  _official(
    'consort_lien',
    'Tạ Bạch Liên',
    'Tiểu thư',
    'Thế gia',
    23,
    82,
    65,
    59,
    69,
    60,
    'Sắc sảo, nhớ rõ ân tình và hiềm khích',
  ),
  _official(
    'consort_van',
    'Đào Nhã Vân',
    'Tiểu thư',
    'Văn thần',
    19,
    71,
    78,
    34,
    85,
    33,
    'Mộc mạc, quan tâm việc cứu tế',
  ),
  _official(
    'consort_chau',
    'Ngô Minh Châu',
    'Tiểu thư',
    'Võ tướng',
    26,
    75,
    74,
    43,
    81,
    46,
    'Thẳng thắn, coi trọng sự công bằng',
  ),
];

const baseEvents = <EventDefinition>[
  EventDefinition(
    'levee_warning',
    'Vết nứt bên dòng Đại Hà',
    'Tri phủ dâng bản vẽ một đoạn đê đã yếu. Mùa mưa chưa tới, nhưng sửa sớm sẽ đỡ một nỗi lo.',
    'Dân sinh',
    [
      EventChoice('Cấp tiền tu bổ', 'Chi 80 · công trình kéo dài 4 tuần', {
        'repair': 1,
      }, cost: 80),
      EventChoice('Huy động dân phu', 'Đê +12 · lòng dân −6', {
        'levee': 12,
        'people': -6,
      }),
      EventChoice('Tạm gác lại', 'Đê −5 · rủi ro vẫn còn', {'levee': -5}),
    ],
    cooldown: 40,
  ),
  EventDefinition(
    'grain_merchants',
    'Những xe thóc ngoài cửa thành',
    'Thương nhân xin bán một đoàn thóc cho kho triều đình. Giá không rẻ, nhưng có thể dự phòng một mùa khó.',
    'Ngân khố',
    [
      EventChoice('Mua cho kho dự trữ', 'Chi 45 · lương thực +32', {
        'grain': 32,
      }, cost: 45),
      EventChoice('Để dân tự mua bán', 'Lòng dân +2', {'people': 2}),
    ],
  ),
  EventDefinition(
    'village_school',
    'Ngôi trường dưới mái đình',
    'Một huyện nghèo xin tiền mở lớp học. Quan địa phương hứa sẽ gửi báo cáo sau vài tuần.',
    'Dân sinh',
    [
      EventChoice(
        'Cấp tiền mở lớp',
        'Chi 35 · nhận kết quả sau 4 tuần',
        {},
        cost: 35,
        followup: 'school',
        delay: 4,
      ),
      EventChoice('Khuyến khích làng tự lo', 'Uy quyền −1', {'authority': -1}),
    ],
  ),
  EventDefinition(
    'tax_abuse',
    'Tiếng kêu oan ở cổng phủ',
    'Dân tố người thu thuế đòi thêm tiền ngoài sổ. Hộ bộ cho rằng đây chỉ là lời đồn.',
    'Triều chính',
    [
      EventChoice(
        'Sai ngự sử xác minh',
        'Chi 15 · kết quả sau 2 tuần',
        {},
        cost: 15,
        followup: 'audit',
        delay: 2,
      ),
      EventChoice('Hoàn lại tiền cho dân', 'Chi 30 · lòng dân +7', {
        'people': 7,
      }, cost: 30),
      EventChoice('Tin báo cáo Hộ bộ', 'Lòng dân −5 · Ổn định triều đình +2', {
        'people': -5,
        'stability': 2,
      }),
    ],
  ),
  EventDefinition(
    'border_riders',
    'Khói lửa ngoài biên ải',
    'Kỵ binh phương Bắc thăm dò cửa ải. Đại tướng xin chuẩn bị phòng thủ trước khi tình hình xấu hơn.',
    'Quân sự',
    [
      EventChoice(
        'Tăng viện cửa ải',
        'Chi 60 · quân lực +8 · áp lực chiến tranh +1',
        {'army': 8, 'war': 1},
        cost: 60,
      ),
      EventChoice(
        'Cử sứ thương lượng',
        'Chi 25 · có hồi âm sau 3 tuần',
        {},
        cost: 25,
        followup: 'envoy',
        delay: 3,
      ),
      EventChoice('Chờ xem động tĩnh', 'Áp lực chiến tranh +2', {'war': 2}),
    ],
    condition: 'peace',
    minWeek: 8,
    cooldown: 24,
  ),
  EventDefinition(
    'noble_feast',
    'Thiệp mời từ phủ Quốc công',
    'Một bữa tiệc hội đủ các thế gia. Có thể kết thân, nhưng tiếng đàn thường giữ khách tới khuya.',
    'Cung đình',
    [
      EventChoice(
        'Dự tiệc cùng các quan',
        'Chi 20 · Ổn định triều đình +5 · thêm 1 lần hưởng lạc',
        {'stability': 5, 'revel': 1},
        cost: 20,
      ),
      EventChoice('Gửi lời đáp lễ', 'Uy quyền +1', {'authority': 1}),
    ],
  ),
  EventDefinition(
    'rain_forecast',
    'Mưa dồn trên thượng nguồn',
    'Trạm dịch liên tiếp báo mưa lớn. Nếu đê yếu, các làng ven sông sẽ gặp nguy hiểm.',
    'Thiên tai',
    [
      EventChoice('Củng cố khẩn cấp', 'Chi 50 · đê +18', {
        'levee': 18,
      }, cost: 50),
      EventChoice(
        'Sơ tán các làng thấp',
        'Chi 20 · lòng dân +3 · lương thực −5',
        {'people': 3, 'grain': -5},
        cost: 20,
      ),
      EventChoice('Giao địa phương tự liệu', 'Đê −8 · lòng dân −3', {
        'levee': -8,
        'people': -3,
      }),
    ],
    condition: 'rain',
    cooldown: 13,
  ),
  EventDefinition(
    'flood',
    'Nước tràn qua bờ ruộng',
    'Đê yếu đã không giữ được nước. Làng mạc cần cứu tế ngay để tránh mất mùa lan rộng.',
    'Khủng hoảng',
    [
      EventChoice('Mở kho cứu dân', 'Lương thực −25 · lòng dân +5', {
        'people': 5,
      }, grainCost: 25),
      EventChoice('Mua gạo cứu tế', 'Chi 75 · lòng dân +5', {
        'people': 5,
      }, cost: 75),
      EventChoice(
        'Ưu tiên giữ kho triều đình',
        'Lòng dân −16 · lương thực −10',
        {'people': -16, 'grain': -10},
      ),
    ],
    condition: 'flood',
    cooldown: 8,
  ),
  EventDefinition(
    'hunger',
    'Nồi cháo trước sân đình',
    'Kho lương cạn dần. Người dân bắt đầu rời làng tìm nơi còn gạo; những lời oán thán lan nhanh.',
    'Khủng hoảng',
    [
      EventChoice(
        'Mua thóc khẩn cấp',
        'Chi 65 · lương thực +35 · lòng dân +5',
        {'grain': 35, 'people': 5},
        cost: 65,
      ),
      EventChoice('Vay thóc các thế gia', 'Lương thực +25 · uy quyền −7', {
        'grain': 25,
        'authority': -7,
      }),
      EventChoice('Siết khẩu phần', 'Lòng dân −12 · quân lực −4', {
        'people': -12,
        'army': -4,
      }),
    ],
    condition: 'hungry',
    cooldown: 5,
  ),
  EventDefinition(
    'court_rumor',
    'Lời đồn sau rèm châu',
    'Một đại thần bị tố kết bè. Chưa có bằng chứng, nhưng các phe đã bắt đầu nghi kỵ nhau.',
    'Triều chính',
    [
      EventChoice(
        'Điều tra kín',
        'Chi 20 · kết quả sau 2 tuần',
        {},
        cost: 20,
        followup: 'security',
        delay: 2,
      ),
      EventChoice(
        'Triệu các phe hòa giải',
        'Ổn định triều đình +5 · uy quyền −2',
        {'stability': 5, 'authority': -2},
      ),
      EventChoice('Không can dự', 'Ổn định triều đình −6', {'stability': -6}),
    ],
    condition: 'court',
  ),
  EventDefinition(
    'physician_warning',
    'Lời can của ngự y',
    'Ngự y nhận thấy sắc mặt bệ hạ kém đi. Việc nước và những đêm dài đang để lại dấu vết.',
    'Sức khỏe',
    [
      EventChoice('Dành thời gian dưỡng sức', '1 hành động · thêm 1 lần nghỉ', {
        'rest': 1,
      }, points: 1),
      EventChoice('Dùng thuốc theo đơn', 'Chi 25 · bệnh −8 · sức khỏe +3', {
        'illness': -8,
        'health': 3,
      }, cost: 25),
      EventChoice('Gác lời khuyên', 'Căng thẳng +4', {'stress': 4}),
    ],
    condition: 'ill',
    cooldown: 10,
  ),
  EventDefinition(
    'silk_route',
    'Đoàn buôn từ phương Nam',
    'Thương nhân xin phép mở tuyến giao thương. Họ cần bảo đảm an toàn và một khoản hỗ trợ ban đầu.',
    'Ngoại giao',
    [
      EventChoice(
        'Bảo trợ tuyến buôn',
        'Chi 40 · nhận doanh thu sau 5 tuần',
        {},
        cost: 40,
        followup: 'trade',
        delay: 5,
      ),
      EventChoice('Thu phí qua cửa', 'Ngân khố +20 · lòng dân −2', {
        'treasury': 20,
        'people': -2,
      }),
      EventChoice('Giữ nguyên quy định', 'Không thay đổi', {}),
    ],
  ),
  EventDefinition(
    'army_pay',
    'Lính gác chưa nhận lương',
    'Nghĩa vụ chi trả đang tồn đọng. Tướng lĩnh cảnh báo khó giữ quân nếu triều đình tiếp tục chậm trễ.',
    'Quân sự',
    [
      EventChoice('Chi khoản hỗ trợ', 'Chi 45 · quân lực +6 · nợ chi trả −45', {
        'army': 6,
        'debt': -45,
      }, cost: 45),
      EventChoice('Kêu gọi quân sĩ nhẫn nại', 'Quân lực −6 · uy quyền −3', {
        'army': -6,
        'authority': -3,
      }),
    ],
    condition: 'debt',
    cooldown: 8,
  ),
  EventDefinition(
    'palace_poetry',
    'Một đêm thơ ở Ngự uyển',
    'Các học sĩ đề nghị một buổi thưởng thơ giản dị. Giữa những tấu chương, cũng cần một khoảng thảnh thơi.',
    'Cung đình',
    [
      EventChoice('Cùng thưởng thơ', 'Chi 10 · thêm 1 lần hưởng lạc vừa phải', {
        'revel': 1,
      }, cost: 10),
      EventChoice('Dành buổi tối nghỉ ngơi', 'Thêm 1 lần nghỉ', {'rest': 1}),
    ],
    cooldown: 20,
  ),
  EventDefinition(
    'drought',
    'Đất nứt giữa mùa hạ',
    'Nắng dài khiến đồng ruộng thiếu nước. Địa phương xin hỗ trợ khơi kênh và giữ giống.',
    'Thiên tai',
    [
      EventChoice(
        'Cấp tiền khơi kênh',
        'Chi 45 · lương thực +8 · lòng dân +3',
        {'grain': 8, 'people': 3},
        cost: 45,
      ),
      EventChoice('Xuất thóc giống', 'Lương thực −10 · lòng dân +4', {
        'people': 4,
      }, grainCost: 10),
      EventChoice('Chờ mưa xuống', 'Lương thực −18 · lòng dân −4', {
        'grain': -18,
        'people': -4,
      }),
    ],
    condition: 'rain',
  ),
  EventDefinition(
    'winter_fuel',
    'Gió rét qua miền Bắc',
    'Mùa đông khắc nghiệt đẩy giá củi và gạo lên cao. Những hộ nghèo cần được hỗ trợ.',
    'Dân sinh',
    [
      EventChoice('Phát tiền cứu rét', 'Chi 35 · lòng dân +7', {
        'people': 7,
      }, cost: 35),
      EventChoice('Xuất kho hỗ trợ', 'Lương thực −12 · lòng dân +5', {
        'people': 5,
      }, grainCost: 12),
      EventChoice('Giữ ngân sách', 'Lòng dân −6', {'people': -6}),
    ],
    condition: 'winter',
  ),
  EventDefinition(
    'local_epidemic',
    'Dịch sốt ở bến sông',
    'Một khu chợ xuất hiện dịch sốt. Thầy thuốc địa phương xin dược liệu và người giúp.',
    'Dân sinh',
    [
      EventChoice('Cấp thuốc và cách ly', 'Chi 40 · lòng dân +6', {
        'people': 6,
      }, cost: 40),
      EventChoice('Đóng chợ tạm thời', 'Ngân khố −10 · lòng dân −2', {
        'treasury': -10,
        'people': -2,
      }),
      EventChoice('Để địa phương tự lo', 'Lòng dân −9 · quân lực −2', {
        'people': -9,
        'army': -2,
      }),
    ],
    minWeek: 10,
  ),
  EventDefinition(
    'examination',
    'Khoa thi mùa xuân',
    'Sĩ tử hội về kinh thành. Một khoa thi công bằng sẽ củng cố niềm tin vào triều đình.',
    'Triều chính',
    [
      EventChoice(
        'Mở khoa thi nghiêm túc',
        'Chi 35 · uy quyền +5 · Ổn định triều đình +4',
        {'authority': 5, 'stability': 4},
        cost: 35,
      ),
      EventChoice('Cho thế gia tiến cử', 'Ngân khố +15 · lòng dân −5', {
        'treasury': 15,
        'people': -5,
      }),
      EventChoice('Hoãn khoa thi', 'Uy quyền −3', {'authority': -3}),
    ],
    condition: 'spring',
    cooldown: 45,
  ),
  EventDefinition(
    'corrupt_gift',
    'Hộp ngọc không tên',
    'Một thương nhân mang lễ vật quý vào cung, mong triều đình ưu tiên việc làm ăn của mình.',
    'Ngân khố',
    [
      EventChoice(
        'Nhận vào ngân khố',
        'Ngân khố +55 · uy quyền −4 · lòng dân −4',
        {'treasury': 55, 'authority': -4, 'people': -4},
      ),
      EventChoice('Trả lại lễ vật', 'Uy quyền +3', {'authority': 3}),
    ],
  ),
  EventDefinition(
    'general_merit',
    'Chiến công nơi cửa ải',
    'Một toán cướp bị quân biên giới đánh lui. Các võ quan xin triều đình ghi nhận công lao.',
    'Quân sự',
    [
      EventChoice(
        'Ban thưởng quân sĩ',
        'Chi 30 · quân lực +5 · Ổn định triều đình +3',
        {'army': 5, 'stability': 3},
        cost: 30,
      ),
      EventChoice('Gửi chiếu khen', 'Uy quyền +2', {'authority': 2}),
    ],
    condition: 'peace',
  ),
  EventDefinition(
    'royal_wedding',
    'Lời đề nghị kết thân',
    'Một gia tộc muốn đưa người vào cung. Sự kết thân có thể đem lại ủng hộ, đồng thời làm các nhà khác dè chừng.',
    'Hậu cung',
    [
      EventChoice(
        'Cho tiến cử người mới',
        '1 hành động · chi 20 · gặp 2 ứng viên mới',
        {'revealCandidates': 2, 'stress': 2},
        cost: 20,
        points: 1,
      ),
      EventChoice('Chưa bàn chuyện kết thân', 'Không thay đổi', {}),
    ],
    cooldown: 26,
  ),
  EventDefinition(
    'harem_rivalry',
    'Hai chén trà lạnh',
    'Lời qua tiếng lại trong hậu cung đã tới tai các quan. Một cuộc tranh sủng đang biến thành chuyện gia tộc.',
    'Hậu cung',
    [
      EventChoice('Đích thân hòa giải', '1 hành động · Ổn định triều đình +6', {
        'stability': 6,
      }, points: 1),
      EventChoice('Ban quà xoa dịu', 'Chi 30 · Ổn định triều đình +3', {
        'stability': 3,
      }, cost: 30),
      EventChoice('Không can dự', 'Ổn định triều đình −8', {'stability': -8}),
    ],
    condition: 'harem',
  ),
  EventDefinition(
    'queen_charity',
    'Lời thỉnh cầu từ nội cung',
    'Nội cung muốn trích kinh phí may áo cho dân nghèo. Các gia tộc cũng đang chờ xem thái độ của vua.',
    'Hậu cung',
    [
      EventChoice('Chuẩn tấu', 'Chi 25 · lòng dân +5 · Ổn định triều đình +2', {
        'people': 5,
        'stability': 2,
      }, cost: 25),
      EventChoice('Đợi khi ngân khố khá hơn', 'Ổn định triều đình −2', {
        'stability': -2,
      }),
    ],
    condition: 'harem',
  ),
  EventDefinition(
    'foreign_tribute',
    'Lễ vật từ nước láng giềng',
    'Sứ thần mang lễ vật và lời mời hữu hảo. Tiếp đãi trọng thể có thể mở đường cho thương mại.',
    'Ngoại giao',
    [
      EventChoice(
        'Tiếp đãi và mở thương lộ',
        'Chi 20 · doanh thu sau 5 tuần',
        {},
        cost: 20,
        followup: 'trade',
        delay: 5,
      ),
      EventChoice('Nhận lễ theo nghi thức', 'Ngân khố +25', {'treasury': 25}),
    ],
    condition: 'peace',
    cooldown: 24,
  ),
  EventDefinition(
    'war_supplies',
    'Đoàn xe tiếp tế bị chặn',
    'Đường vận lương không còn an toàn. Quân ngoài biên ải cần tiếp tế trước khi tinh thần suy sụp.',
    'Quân sự',
    [
      EventChoice(
        'Mở đường hộ tống',
        'Chi 45 · quân lực +6 · áp lực chiến tranh −1',
        {'army': 6, 'war': -1},
        cost: 45,
      ),
      EventChoice(
        'Chuyển thóc theo đường vòng',
        'Lương thực −18 · quân lực +4',
        {'army': 4},
        grainCost: 18,
      ),
      EventChoice(
        'Giữ nguồn lực trong kinh',
        'Quân lực −10 · áp lực chiến tranh +1',
        {'army': -10, 'war': 1},
      ),
    ],
    condition: 'war',
    cooldown: 8,
  ),
  EventDefinition(
    'peace_offer',
    'Một lá thư cầu hòa',
    'Đối phương sẵn sàng dừng binh nếu triều đình nhượng bộ. Đại tướng cho rằng vẫn còn cơ hội chiến thắng.',
    'Ngoại giao',
    [
      EventChoice(
        'Chi tiền đổi hòa bình',
        'Chi 95 · chiến tranh kết thúc · uy quyền −4',
        {'peace': 1, 'authority': -4},
        cost: 95,
      ),
      EventChoice('Tiếp tục giữ biên giới', 'Quân lực +2 · căng thẳng +5', {
        'army': 2,
        'stress': 5,
      }),
    ],
    condition: 'war',
    cooldown: 12,
  ),
  EventDefinition(
    'treasury_review',
    'Những trang sổ không khớp',
    'Sổ thu của hai địa phương chênh lệch bất thường. Có thể là nhầm lẫn, cũng có thể có người giấu tiền.',
    'Ngân khố',
    [
      EventChoice(
        'Kiểm toán độc lập',
        'Chi 20 · kết quả sau 3 tuần',
        {},
        cost: 20,
        followup: 'audit',
        delay: 3,
      ),
      EventChoice(
        'Cho Hộ bộ tự đối chiếu',
        'Ổn định triều đình +2 · uy quyền −2',
        {'stability': 2, 'authority': -2},
      ),
    ],
  ),
  EventDefinition(
    'festival',
    'Đèn hoa trong kinh thành',
    'Dân chúng chuẩn bị lễ hội. Triều đình có thể góp vui hoặc giữ lại ngân sách cho những việc khác.',
    'Dân sinh',
    [
      EventChoice(
        'Tổ chức lễ hội tiết kiệm',
        'Chi 25 · lòng dân +5 · căng thẳng −5',
        {'people': 5, 'stress': -5},
        cost: 25,
      ),
      EventChoice('Để dân tự tổ chức', 'Lòng dân +1', {'people': 1}),
    ],
    condition: 'spring',
    cooldown: 30,
  ),
  EventDefinition(
    'bandits',
    'Đường núi không còn yên',
    'Thương lái bị cướp trên tuyến đường phía Tây. Dân địa phương xin triều đình bảo vệ.',
    'Quân sự',
    [
      EventChoice('Điều quân dẹp cướp', 'Chi 35 · lòng dân +5 · quân lực −2', {
        'people': 5,
        'army': -2,
      }, cost: 35),
      EventChoice(
        'Chiêu an có điều kiện',
        'Chi 15 · lòng dân +2 · uy quyền −2',
        {'people': 2, 'authority': -2},
        cost: 15,
      ),
      EventChoice('Bỏ mặc tuyến đường', 'Ngân khố −15 · lòng dân −6', {
        'treasury': -15,
        'people': -6,
      }),
    ],
    condition: 'weakArmy',
  ),
  EventDefinition(
    'land_dispute',
    'Một thửa ruộng, hai tờ khế',
    'Dân làng và một thế gia đều nhận quyền sở hữu ruộng. Bản án sẽ khiến ít nhất một bên không hài lòng.',
    'Triều chính',
    [
      EventChoice(
        'Xét theo chứng cứ của dân',
        'Lòng dân +7 · Ổn định triều đình −4',
        {'people': 7, 'stability': -4},
      ),
      EventChoice(
        'Giữ quyền cho thế gia',
        'Ổn định triều đình +4 · lòng dân −7',
        {'stability': 4, 'people': -7},
      ),
      EventChoice('Tạm đình chỉ tranh chấp', 'Uy quyền −3', {'authority': -3}),
    ],
  ),
  EventDefinition(
    'palace_repairs',
    'Mái điện qua một mùa mưa',
    'Một gian điện cần tu sửa. Thợ khuyên làm sớm, trong khi các quan đề nghị ưu tiên việc dân.',
    'Cung đình',
    [
      EventChoice('Sửa vừa đủ dùng', 'Chi 25 · Ổn định triều đình +3', {
        'stability': 3,
      }, cost: 25),
      EventChoice('Dành tiền cho dân', 'Lòng dân +3 · Ổn định triều đình −2', {
        'people': 3,
        'stability': -2,
      }),
    ],
  ),
  EventDefinition(
    'hunting_invite',
    'Cuộc săn đầu mùa',
    'Các võ tướng mời vua đi săn. Đây là dịp gần gũi quân thần, nhưng đường rừng không hoàn toàn an toàn.',
    'Cung đình',
    [
      EventChoice(
        'Đi săn có hộ vệ',
        'Chi 15 · quân lực +3 · thêm 1 lần hưởng lạc',
        {'army': 3, 'revel': 1},
        cost: 15,
      ),
      EventChoice('Ở cung nghỉ ngơi', 'Thêm 1 lần nghỉ', {'rest': 1}),
    ],
    condition: 'peace',
  ),
  EventDefinition(
    'wine_gift',
    'Bình rượu quý phương xa',
    'Rượu mới được tiến cung. Các cận thần mời vua thưởng thức sau một ngày nhiều công việc.',
    'Sức khỏe',
    [
      EventChoice(
        'Mở tiệc thưởng rượu',
        'Căng thẳng −5 · thêm 2 mức hưởng lạc',
        {'stress': -5, 'revel': 2},
      ),
      EventChoice('Cất vào kho', 'Không thay đổi', {}),
    ],
  ),
  EventDefinition(
    'sleepless',
    'Ngọn đèn chưa tắt',
    'Tấu chương còn chất trên bàn. Nhà vua có thể làm tiếp, nhưng ngự y đã đợi ngoài cửa điện.',
    'Sức khỏe',
    [
      EventChoice(
        'Xử lý nốt công việc',
        'Uy quyền +4 · thêm 2 mức công việc · mệt mỏi +6',
        {'authority': 4, 'work': 2, 'fatigue': 6},
      ),
      EventChoice('Gác bút dưỡng sức', 'Thêm 1 lần nghỉ', {'rest': 1}),
    ],
    condition: 'stressed',
  ),
  EventDefinition(
    'retired_adviser',
    'Lời khuyên của người cũ',
    'Một lão thần về kinh, xin nhắc lại những bài học từ triều trước. Nghe lời can gián có thể giúp việc trị nước.',
    'Triều chính',
    [
      EventChoice(
        'Mời vào điện đàm đạo',
        'Ổn định triều đình +4 · căng thẳng −3',
        {'stability': 4, 'stress': -3},
      ),
      EventChoice('Gửi quà thăm hỏi', 'Chi 10 · uy quyền +2', {
        'authority': 2,
      }, cost: 10),
      EventChoice('Không tiếp kiến', 'Ổn định triều đình −3', {
        'stability': -3,
      }),
    ],
    minWeek: 15,
  ),
  EventDefinition(
    'military_drill',
    'Tiếng trống thao trường',
    'Tướng lĩnh muốn mở cuộc diễn tập. Quân đội sẽ sẵn sàng hơn, đổi lại là chi phí và hao hụt lương thực.',
    'Quân sự',
    [
      EventChoice('Chuẩn y diễn tập', 'Chi 35 · quân lực +9 · lương thực −5', {
        'army': 9,
        'grain': -5,
      }, cost: 35),
      EventChoice('Hoãn diễn tập', 'Quân lực −2', {'army': -2}),
    ],
    condition: 'peace',
  ),
  EventDefinition(
    'refugees',
    'Những người tới cửa Nam',
    'Các gia đình từ vùng biên xin cư trú. Tiếp nhận họ cần lương thực và sự phối hợp của địa phương.',
    'Dân sinh',
    [
      EventChoice('Mở nơi tạm trú', 'Lương thực −12 · lòng dân +6', {
        'people': 6,
      }, grainCost: 12),
      EventChoice('Hỗ trợ tiền đi đường', 'Chi 20 · lòng dân +2', {
        'people': 2,
      }, cost: 20),
      EventChoice('Đóng cửa thành', 'Lòng dân −6', {'people': -6}),
    ],
    minWeek: 12,
  ),
  EventDefinition(
    'craftsmen',
    'Lò rèn mới của kinh thành',
    'Thợ rèn đề xuất cải tiến quân khí. Nếu được cấp vốn, vài tuần nữa triều đình sẽ nhận được thành phẩm.',
    'Quân sự',
    [
      EventChoice(
        'Đặt hàng quân khí',
        'Chi 45 · nhận quân lực sau 4 tuần',
        {},
        cost: 45,
        followup: 'weapons',
        delay: 4,
      ),
      EventChoice('Giữ trang bị hiện tại', 'Không thay đổi', {}),
    ],
  ),
  EventDefinition(
    'low_treasury',
    'Hộ bộ xin cắt chi',
    'Ngân khố không còn dư dả. Cắt khoản nào cũng sẽ có người chịu thiệt.',
    'Ngân khố',
    [
      EventChoice(
        'Giảm chi cung đình',
        'Ngân khố +25 · Ổn định triều đình −3',
        {'treasury': 25, 'stability': -3},
      ),
      EventChoice('Thu thêm từ thương nhân', 'Ngân khố +45 · lòng dân −7', {
        'treasury': 45,
        'people': -7,
      }),
      EventChoice('Giữ các khoản đã hứa', 'Uy quyền +2 · căng thẳng +4', {
        'authority': 2,
        'stress': 4,
      }),
    ],
    condition: 'poor',
    cooldown: 12,
  ),
  EventDefinition(
    'prosperity',
    'Một mùa chợ đông',
    'Các khu chợ buôn bán khởi sắc. Triều đình có thể tái đầu tư hoặc thu thêm một khoản.',
    'Ngân khố',
    [
      EventChoice(
        'Đầu tư kho và đường',
        'Chi 30 · lương thực +15 · lòng dân +4',
        {'grain': 15, 'people': 4},
        cost: 30,
      ),
      EventChoice('Thu phí một lần', 'Ngân khố +35 · lòng dân −2', {
        'treasury': 35,
        'people': -2,
      }),
      EventChoice('Để dân hưởng lợi', 'Lòng dân +5', {'people': 5}),
    ],
    condition: 'rich',
  ),
  EventDefinition(
    'petition_tax',
    'Tấu xin giảm sưu',
    'Thuế cao giúp ngân khố đầy hơn, nhưng các làng đã bắt đầu kiệt sức.',
    'Dân sinh',
    [
      EventChoice('Giảm về mức vừa', 'Đặt thuế vừa · lòng dân +5', {
        'taxNormal': 1,
        'people': 5,
      }),
      EventChoice('Giữ thuế hiện tại', 'Lòng dân −7 · uy quyền +2', {
        'people': -7,
        'authority': 2,
      }),
    ],
    condition: 'tax',
  ),
  EventDefinition(
    'plot_warning',
    'Dấu chân ngoài điện vắng',
    'Mật thám phát hiện những cuộc gặp kín và việc điều chuyển người bất thường. Một âm mưu đang tới gần.',
    'Âm mưu',
    [
      EventChoice(
        'Tăng bảo vệ, điều tra gấp',
        'Chi 60 · giảm mạnh tiến độ âm mưu',
        {'plotReduce': 45, 'authority': 2},
        cost: 60,
      ),
      EventChoice(
        'Triệu các phe đối thoại',
        'Giảm một phần âm mưu · uy quyền −5',
        {'plotReduce': 18, 'authority': -5},
      ),
      EventChoice('Chưa ra tay', 'Ổn định triều đình −5 · âm mưu tiếp tục', {
        'stability': -5,
      }),
    ],
    condition: 'plot',
    cooldown: 5,
  ),
  EventDefinition(
    'rebellion_warning',
    'Tiếng trống từ huyện xa',
    'Dân tụ tập phản đối, quan địa phương không còn kiểm soát được tình hình. Cần hành động trước khi bạo loạn lan rộng.',
    'Khủng hoảng',
    [
      EventChoice('Cứu tế và miễn khoản thu', 'Chi 65 · lòng dân +15', {
        'people': 15,
      }, cost: 65),
      EventChoice(
        'Điều quân giữ trật tự',
        'Quân lực −7 · lòng dân +6 · uy quyền +3',
        {'army': -7, 'people': 6, 'authority': 3},
      ),
      EventChoice('Không nhượng bộ', 'Lòng dân −9 · Ổn định triều đình −4', {
        'people': -9,
        'stability': -4,
      }),
    ],
    condition: 'lowPeople',
    cooldown: 6,
  ),
  EventDefinition(
    'succession_rumor',
    'Lời bàn về ngai vàng',
    'Những lời bàn về người có thể thay vua xuất hiện trong giới quyền quý. Uy tín của triều đình đang bị thử thách.',
    'Âm mưu',
    [
      EventChoice('Củng cố chính danh', 'Chi 35 · uy quyền +8 · giảm âm mưu', {
        'authority': 8,
        'plotReduce': 10,
      }, cost: 35),
      EventChoice(
        'Đối thoại với hoàng tộc',
        'Ổn định triều đình +4 · căng thẳng +4',
        {'stability': 4, 'stress': 4},
      ),
      EventChoice('Phớt lờ lời đồn', 'Uy quyền −6', {'authority': -6}),
    ],
    condition: 'weakAuthority',
    cooldown: 15,
  ),
  EventDefinition(
    'consort_recommendation',
    'Người mới trước cửa cung',
    'Các gia tộc tiến cử {candidate}. Bệ hạ có muốn nhận làm tú nữ (chưa nhập cung)? Sự ưu ái cũng sẽ khiến phe đối lập dè chừng.',
    'Hậu cung',
    [
      EventChoice(
        'Nhận làm tú nữ',
        'Chi 20 · nhận ứng viên làm tú nữ (chưa nhập cung) · cùng phe +3, phe đối lập −5 · 1 hành động',
        {'recruitConsort': 1},
        cost: 20,
        points: 1,
      ),
      EventChoice(
        'Khước từ tiến cử',
        'Phe đối lập +3, cùng phe −5 · 1 hành động',
        {'rejectConsort': 1},
        points: 1,
      ),
    ],
    minWeek: 4,
    cooldown: 13,
    condition: 'recruitment',
  ),
];

final events = List<EventDefinition>.unmodifiable([
  ...baseEvents,
  ...expandedEvents,
]);
List<EventDefinition> eventsForState(GameState s) =>
    s.population == null ? events : [...events, ...populationEvents];
final _eventIndex = {
  for (final e in [...events, ...populationEvents]) e.id: e,
};
EventDefinition eventById(String id) =>
    _eventIndex[id] ??
    storyEventById(id) ??
    (throw StateError('Unknown event $id'));

/// Shared by commands, confirmation dialogs and expiry forecasts.
EventDefinition eventForState(GameState s, String id) {
  final recovery = foodRecoveryEvent(s, id);
  if (recovery != null) return recovery;
  final matter = courtMatterForEvent(s, id);
  if (matter != null) return courtPersonnelEvent(s, matter);
  final story = storyEventForState(s, id);
  if (story != null) {
    return foodCostEvent(
      s,
      currencyEvent(s, warEvent(s, populationEvent(s, story))),
    );
  }
  final e = eventById(id);
  if (!s.seasonal || e.condition.startsWith('population')) {
    return foodCostEvent(
      s,
      currencyEvent(s, warEvent(s, populationEvent(s, e))),
    );
  }
  final seasonal = EventDefinition(
    e.id,
    e.title,
    e.body,
    e.category,
    e.choices.map((c) => seasonalPetitionChoice(s, c)).toList(),
    condition: e.condition,
    cooldown: e.cooldown,
    minWeek: e.minWeek,
    family: e.family,
    trigger: e.trigger,
  );
  return foodCostEvent(
    s,
    currencyEvent(s, warEvent(s, populationEvent(s, seasonal))),
  );
}

const urgentEventIds = [
  'hunger',
  'rebellion_warning',
  'succession_rumor',
  'plot_warning',
  'flood',
];
String eventTrigger(EventDefinition e) =>
    e.trigger.isNotEmpty
        ? e.trigger
        : urgentEventIds.contains(e.id)
        ? e.id
        : '';
String eventFamily(EventDefinition e) =>
    e.family.isEmpty ? e.category : e.family;

int petitionPoints(GameState s, EventChoice c) =>
    c.effects.containsKey('warMission')
        ? 0
        : s.seasonal && c.points == 0
        ? 1
        : c.points;

String petitionText(Petition petition, GameState state) {
  final candidate =
      state.court.where((c) => c.id == petition.targetId).firstOrNull;
  return eventForState(state, petition.definitionId).body.replaceAll(
    '{candidate}',
    candidate == null
        ? 'một ứng viên chưa được xác minh'
        : '${candidate.name}, ${candidate.age} tuổi, thuộc phe ${candidate.faction} (đã biết: ${candidate.knownPersonalityText}; các tính cách khác chưa rõ)',
  );
}

class ActionDefinition {
  const ActionDefinition(
    this.id,
    this.title,
    this.description,
    this.cost,
    this.icon, {
    this.grainCost = 0,
  });
  final String id, title, description, icon;
  final int cost, grainCost;
}

int actionGrainCost(GameState s, ActionDefinition a) =>
    s.population == null
        ? a.grainCost
        : populationActionNames.containsKey(a.id)
        ? populationActionFood(a.id, s)
        : switch (a.id) {
          'relief' => 100000,
          'sell_surplus' => 100000,
          _ => authoredFood(a.grainCost, context: a.id),
        };

int actionCost(GameState s, ActionDefinition a) =>
    developmentTasks.contains(a.id)
        ? developmentCost(s, a.id)
        : s.seasonal && a.id == 'security'
        ? money(s, 55)
        : money(s, a.cost);

const actions = [
  ActionDefinition(
    'public_health',
    'Tổ chức phòng dịch',
    'Chi 35 tiền, 5.000 tạ; mức dịch −1, lòng dân +1; một lần/mùa.',
    35,
    'population',
  ),
  ActionDefinition(
    'settle',
    'Chiêu dân lập ấp',
    'Chi 40 tiền, 7.000 tạ; sau 2 mùa nhận 5.000 lao động.',
    40,
    'population',
  ),
  ActionDefinition(
    'refugees',
    'Tiếp nhận người tị nạn',
    'Chi 50 tiền, 10.000 tạ; cần đoàn người xin vào, nhận 10.000 lao động cuối mùa.',
    50,
    'population',
  ),
  ActionDefinition(
    'return',
    'Kêu gọi dân lưu tán trở về',
    'Chi 30 tiền, 4.000 tạ; cuối mùa nhận tối đa 10.000 lao động còn lưu tán.',
    30,
    'population',
  ),
  ActionDefinition(
    'recruit',
    'Tuyển quân thường lệ',
    'Chi 25 tiền; cuối mùa chuyển 5.000 lao động dân sự thành tân binh.',
    25,
    'population',
  ),
  ActionDefinition(
    'demobilize',
    'Giải ngũ 5.000 quân',
    'Chuyển 5.000 quân rảnh về dân sự; không tăng tổng dân số.',
    0,
    'population',
  ),
  ActionDefinition(
    'equipment',
    'Rèn thêm quân khí',
    'Chi 40 tiền; cuối mùa nhận 5.000 bộ quân khí.',
    40,
    'population',
  ),
  ActionDefinition(
    'reward_army',
    'Thưởng quân',
    'Chi 25 tiền; sĩ khí +8, lặp trong mùa giảm hiệu quả.',
    25,
    'population',
  ),
  ActionDefinition(
    'supply_army',
    'Tổ chức tiếp tế',
    'Chi 20 tiền; chuyển trước 20.000 tạ vào khẩu phần mùa này.',
    20,
    'population',
  ),
  ActionDefinition(
    'upgrade_economy',
    'Phát triển kinh tế',
    'Nâng cấp kinh tế để tăng thuế nền hằng năm.',
    80,
    'treasury',
  ),
  ActionDefinition(
    'upgrade_farm',
    'Phát triển nông nghiệp',
    'Nâng cấp nông nghiệp để tăng sản lượng thu hoạch hằng năm.',
    70,
    'grain',
  ),
  ActionDefinition(
    'upgrade_levee',
    'Nâng cấp đê điều',
    'Nâng cấp công trình để giảm hao mòn; không tự phục hồi tình trạng đê.',
    100,
    'levee',
  ),
  ActionDefinition(
    'maintain_levee',
    'Bảo dưỡng đê điều',
    'Chi 20 · cơ bản đê +12 ngay; 1 lần mỗi kỳ, có thể thất bại.',
    20,
    'levee',
  ),
  ActionDefinition(
    'collect_arrears',
    'Truy thu thuế tồn',
    'Không ứng tiền · nền +45 lần đầu, mỗi lần thử giảm 6, tối thiểu 15 · lòng dân −2 · mệt +4 · căng thẳng +3; 4 tuần/lần kể cả thất bại',
    0,
    'treasury',
  ),
  ActionDefinition(
    'sell_surplus',
    'Bán lương dư',
    'Xuất 40 thóc · giữ lại ít nhất 25 · cơ bản ngân khố +28 ngay · mệt +2; 1 lần/tuần, có rủi ro mất hàng',
    0,
    'treasury',
    grainCost: 40,
  ),
  ActionDefinition(
    'commerce',
    'Mở đoàn thương mại',
    'Chi 40 vốn · 4 tuần · cơ bản doanh thu +110, chưa trừ vốn; tùy năng lực/liêm chính, có thể mất cả vốn lẫn tiền thêm',
    40,
    'treasury',
  ),
  ActionDefinition(
    'govern',
    'Chấn chỉnh triều chính',
    'Cơ bản: uy quyền +3 · Ổn định triều đình +1; hiệu quả tùy người · mệt +6 · căng thẳng +4',
    0,
    'court',
  ),
  ActionDefinition(
    'relief',
    'Mở kho cứu tế',
    'Chi 20 · thóc −25 · cơ bản lòng dân +5; tùy năng lực, chuyên môn và số lần lặp',
    20,
    'people',
    grainCost: 25,
  ),
  ActionDefinition(
    'buy_grain',
    'Bổ sung kho lương',
    'Chi 45 · cơ bản lương thực +30; có rủi ro thất bại',
    45,
    'grain',
  ),
  ActionDefinition(
    'mediate',
    'Hòa giải các phe',
    'Chi 25 · cơ bản các phe +2, bất mãn mỗi người −2, Ổn định triều đình +2 · uy quyền −2 · mệt +4 · căng thẳng +4; 1 lần/tuần',
    25,
    'court',
  ),
  ActionDefinition(
    'train',
    'Luyện quân',
    'Chi 35 · cơ bản quân lực +10; tùy năng lực/chuyên môn',
    35,
    'army',
  ),
  ActionDefinition(
    'repair',
    'Tu bổ đê điều',
    'Chi 80 · 4 tuần · cơ bản đê +30; có thể thất bại',
    80,
    'levee',
  ),
  ActionDefinition(
    'farm',
    'Khai khẩn ruộng đất',
    'Chi 55 · 5 tuần · cơ bản thóc +35; có thể thất bại',
    55,
    'grain',
  ),
  ActionDefinition(
    'rest',
    'Dưỡng sức',
    'Giảm mệt mỏi · hỗ trợ hồi phục',
    0,
    'health',
  ),
  ActionDefinition(
    'revel',
    'Thưởng nhạc, yến tiệc',
    'Chi 18 · thư giãn; lạm dụng gây hại',
    18,
    'revel',
  ),
  ActionDefinition(
    'treat',
    'Mời ngự y chữa trị',
    'Chi 25 · giảm bệnh tùy ngự y · sức khỏe +2 · mệt mỏi −12 · hiệu quả áp dụng ngay',
    25,
    'health',
  ),
  ActionDefinition(
    'security',
    'Củng cố cấm vệ',
    'Chi 35 · cơ bản giảm 18 tiến độ âm mưu; chọn người giỏi An ninh',
    35,
    'security',
  ),
  ActionDefinition(
    'diplomacy',
    'Cử sứ hòa đàm',
    'Chi 45 · hồi âm sau 3 tuần; chọn người giỏi Ngoại giao',
    45,
    'diplomacy',
  ),
];
