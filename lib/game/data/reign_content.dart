import '../models/event_definition.dart';
import '../models/major_definition.dart';
import 'expanded_major_events.dart';
export '../models/major_definition.dart';
part 'chain_content.dart';
part 'settlement_chains.dart';

const coreMajorDefinitions = [
  MajorDefinition(
    'marriage',
    'Sứ đoàn láng giềng cầu thân',
    'Nước láng giềng đề nghị kết minh bằng hôn ước giữa hai hoàng tộc trưởng thành. '
        'Cần chuẩn bị lễ nghi, thỏa thuận và sự đồng thuận trong triều trước khi sứ đoàn hồi quốc.',
    [
      ObjectiveDefinition(
        'treaty',
        'Đàm phán cam kết tương trợ',
        'Ngoại giao',
        20,
        0,
        2,
        {'war': 1},
      ),
      ObjectiveDefinition('gifts', 'Chuẩn bị sính lễ', 'Cung đình', 35, 0, 1, {
        'treasury': -12,
      }),
      ObjectiveDefinition(
        'consensus',
        'Thuyết phục các phe trong triều',
        'Dân chính',
        15,
        0,
        2,
        {'stability': -3},
      ),
      ObjectiveDefinition(
        'ceremony',
        'Tổ chức lễ kết minh',
        'Ngoại giao',
        20,
        10,
        2,
        {'authority': -3},
      ),
    ],
    group: 'diplomacy',
    agreement: MajorAgreement(
      'Cam kết tương trợ sau cầu thân',
      3,
      6,
      goal: 'treaty',
    ),
  ),
  MajorDefinition(
    'invasion',
    'Ngoại bang xuất binh đánh biên cương',
    'Thám mã báo quân láng giềng đã vượt biên. Các cửa ải cần lực lượng, lương thảo '
        'và một phương án ngoại giao trước đợt tiến công chính.',
    [
      ObjectiveDefinition(
        'defense',
        'Củng cố phòng tuyến',
        'Công trình',
        25,
        0,
        2,
        {'war': 1},
      ),
      ObjectiveDefinition(
        'troops',
        'Tập kết quân tiếp viện',
        'Quân sự',
        25,
        0,
        2,
        {'army': -5},
      ),
      ObjectiveDefinition(
        'supply',
        'Vận lương ra biên giới',
        'Kinh tế',
        10,
        30,
        1,
        {'grain': -10},
      ),
      ObjectiveDefinition(
        'envoy',
        'Mở đường đàm phán',
        'Ngoại giao',
        20,
        0,
        2,
        {'authority': -3},
      ),
    ],
    group: 'military',
  ),
  MajorDefinition(
    'locusts',
    'Nạn châu chấu đe dọa mùa màng',
    'Đàn châu chấu xuất hiện tại các vùng trồng lúa. Cần bảo vệ đồng ruộng, '
        'chuẩn bị lương và giống trước khi thiệt hại lan rộng.',
    [
      ObjectiveDefinition(
        'fields',
        'Huy động bảo vệ đồng ruộng',
        'Dân chính',
        20,
        0,
        2,
        {'grain': -12},
      ),
      ObjectiveDefinition(
        'reserve',
        'Vận lương dự phòng tới vùng dịch',
        'Kinh tế',
        10,
        30,
        1,
        {'people': -4},
      ),
      ObjectiveDefinition(
        'seeds',
        'Chuẩn bị giống cho vụ sau',
        'Kinh tế',
        25,
        0,
        2,
        {'grain': -8},
      ),
      ObjectiveDefinition(
        'relief',
        'Tổ chức cứu đói địa phương',
        'Dân chính',
        15,
        15,
        2,
        {'stability': -3},
      ),
    ],
    group: 'disaster',
  ),
  MajorDefinition(
    'flood',
    'Mưa lớn đe dọa vỡ đê',
    'Mực nước dâng liên tục. Các đoạn đê xung yếu cần được gia cố, dân vùng trũng '
        'cần sơ tán và cứu trợ trước đỉnh lũ.',
    [
      ObjectiveDefinition(
        'levee',
        'Gia cố đoạn đê xung yếu',
        'Công trình',
        30,
        0,
        2,
        {'levee': -10},
      ),
      ObjectiveDefinition(
        'evacuate',
        'Sơ tán vùng nguy hiểm',
        'Dân chính',
        15,
        0,
        2,
        {'people': -5},
      ),
      ObjectiveDefinition('food', 'Vận lương cứu trợ', 'Kinh tế', 10, 30, 1, {
        'grain': -10,
      }),
      ObjectiveDefinition(
        'rescue',
        'Huy động lực lượng cứu hộ',
        'Quân sự',
        20,
        0,
        2,
        {'treasury': -15},
      ),
    ],
    group: 'disaster',
  ),
  MajorDefinition(
    'earthquake',
    'Động đất tàn phá thành trấn',
    'Mặt đất rung chuyển, nhà cửa sập và dân mắc kẹt. Thiệt hại ban đầu đã xảy ra; '
        'phải cứu hộ và tái thiết để ngăn hậu quả tiếp tục lan rộng.',
    [
      ObjectiveDefinition(
        'rescue',
        'Tìm kiếm và cứu người mắc kẹt',
        'Quân sự',
        20,
        0,
        1,
        {'people': -5},
      ),
      ObjectiveDefinition(
        'shelter',
        'Dựng nơi ở tạm cho dân',
        'Công trình',
        30,
        0,
        2,
        {'treasury': -15},
      ),
      ObjectiveDefinition(
        'food',
        'Cấp lương cho vùng bị nạn',
        'Kinh tế',
        10,
        30,
        1,
        {'grain': -10},
      ),
      ObjectiveDefinition(
        'medicine',
        'Tổ chức y tế và vệ sinh',
        'Y thuật',
        20,
        0,
        2,
        {'stability': -4},
      ),
    ],
    group: 'disaster',
  ),
  MajorDefinition(
    'rumor',
    'Lời đồn làm lung lay ngai vàng',
    'Lời đồn về đức hạnh nhà vua lan từ chợ đến triều đường. Cần xác minh nguồn tin, '
        'công khai chứng cứ và khôi phục lòng tin trước khi các phe lợi dụng.',
    [
      ObjectiveDefinition(
        'source',
        'Điều tra nguồn phát tán',
        'An ninh',
        20,
        0,
        2,
        {'authority': -5},
      ),
      ObjectiveDefinition(
        'evidence',
        'Đối chiếu và công khai chứng cứ',
        'Dân chính',
        15,
        0,
        2,
        {'people': -3},
      ),
      ObjectiveDefinition(
        'court',
        'Triệu tập các phe đối thoại',
        'Ngoại giao',
        15,
        0,
        1,
        {'stability': -4},
      ),
      ObjectiveDefinition(
        'remedy',
        'Thi hành biện pháp sửa sai',
        'Dân chính',
        25,
        0,
        2,
        {'authority': -3},
      ),
    ],
    group: 'politics',
  ),
];
const majorDefinitions = [...coreMajorDefinitions, ...expandedMajorDefinitions];

MajorDefinition majorDefinition(String id) =>
    majorDefinitions.firstWhere((d) => d.id == id);

class ChainStage {
  const ChainStage(this.title, this.body, this.choices, {this.delay = 1});
  final String title, body;
  final List<EventChoice> choices;
  final int delay;
}

class ChainDefinition {
  const ChainDefinition(
    this.id,
    this.title,
    this.stages, {
    this.condition = 'any',
    this.branches = const {},
    this.economic = false,
    this.rewards = const {},
    this.personRewards = const {},
  });
  final String id, title;
  final List<ChainStage> stages;
  final String condition;
  final Map<String, ChainStage> branches;
  final bool economic;
  final Map<String, int> rewards, personRewards;
}

const legacyChainDefinitions = [
  ChainDefinition('embezzlement', 'Dấu vết tiền cứu trợ', [
    ChainStage(
      'Tiền cứu trợ đi đâu?',
      'Dân địa phương chưa nhận đủ khoản cứu trợ đã cấp. Có nên mở hồ sơ?',
      [
        EventChoice(
          'Cử đoàn kiểm tra',
          'Chi 15 tiền, 1 hành động; hồ sơ tiếp tục sau 2 tuần.',
          {'authority': 1},
          cost: 15,
          points: 1,
        ),
        EventChoice(
          'Nhờ thế gia địa phương thu xếp',
          '1 hành động; thế gia +3, nhưng phải trả ân tình.',
          {'faction:Thế gia': 3},
          points: 1,
        ),
        EventChoice(
          'Gác hồ sơ',
          'Lòng dân −3; người dân sẽ tiếp tục khiếu kiện.',
          {'people': -3},
        ),
      ],
    ),
    ChainStage(
      'Chứng cứ chạm tới đại thần',
      'Sổ sách có dấu hiệu bao che của một gia tộc đang nắm quyền.',
      [
        EventChoice(
          'Điều tra công khai',
          'Chi 20, 1 hành động; uy quyền +3, thế gia −5.',
          {'authority': 3, 'faction:Thế gia': -5},
          cost: 20,
          points: 1,
        ),
        EventChoice(
          'Thỏa thuận hoàn trả',
          '1 hành động; thu hồi 20 tiền, uy quyền −2.',
          {'treasury': 20, 'authority': -2},
          points: 1,
        ),
        EventChoice(
          'Khép lại điều tra',
          'Ổn định triều đình −4, lòng dân −3.',
          {'stability': -4, 'people': -3},
        ),
      ],
    ),
    ChainStage(
      'Phán quyết trước triều',
      'Bản án sẽ quyết định người dân có tin vào phép nước hay không.',
      [
        EventChoice(
          'Xử theo chứng cứ',
          'Chi 10, 1 hành động; lòng dân +5, thế gia −4.',
          {'people': 5, 'faction:Thế gia': -4},
          cost: 10,
          points: 1,
        ),
        EventChoice(
          'Ân xá có điều kiện',
          '1 hành động; Ổn định triều đình +2, uy quyền −2.',
          {'stability': 2, 'authority': -2},
          points: 1,
        ),
        EventChoice('Để các phe tự dàn xếp', 'Uy quyền −5.', {'authority': -5}),
      ],
    ),
  ]),
  ChainDefinition('border', 'Lửa âm ỉ nơi biên ải', [
    ChainStage(
      'Thương lộ bị chặn',
      'Thương nhân báo trạm biên giới nước láng giềng giữ hàng và thu phí bất thường.',
      [
        EventChoice(
          'Cử sứ giả tìm hiểu',
          'Chi 15, 1 hành động; mở kênh đối thoại.',
          {'authority': 1},
          cost: 15,
          points: 1,
        ),
        EventChoice(
          'Hộ tống thương đoàn',
          'Chi 20, 1 hành động; quân lực −2.',
          {'army': -2},
          cost: 20,
          points: 1,
        ),
        EventChoice('Tạm đóng thương lộ', 'Ngân khố −15.', {'treasury': -15}),
      ],
    ),
    ChainStage(
      'Yêu sách từ nước láng giềng',
      'Đối phương đòi nhượng quyền thu phí để mở lại cửa khẩu.',
      [
        EventChoice(
          'Đàm phán bình đẳng',
          'Chi 20, 1 hành động; uy quyền +2.',
          {'authority': 2},
          cost: 20,
          points: 1,
        ),
        EventChoice(
          'Chấp nhận cống nạp',
          '1 hành động; hạ chiến tranh 1, trả 6 tiền mỗi tuần trong 6 tuần.',
          {'war': -1},
          points: 1,
        ),
        EventChoice('Bác bỏ yêu sách', 'Chiến tranh +1.', {'war': 1}),
      ],
    ),
    ChainStage(
      'Hiệp ước cửa khẩu',
      'Đã tới lúc quyết định quan hệ lâu dài ở biên giới.',
      [
        EventChoice(
          'Ký hiệp ước và giám sát',
          'Chi 20, 1 hành động; quân lực +4, uy quyền +2.',
          {'army': 4, 'authority': 2},
          cost: 20,
          points: 1,
        ),
        EventChoice(
          'Đổi thương quyền lấy yên ổn',
          '1 hành động; ngân khố +20, uy quyền −3.',
          {'treasury': 20, 'authority': -3},
          points: 1,
        ),
        EventChoice('Cắt đứt đàm phán', 'Chiến tranh +2.', {'war': 2}),
      ],
    ),
  ]),
  ChainDefinition('granary', 'Kho lương trước mùa giáp hạt', [
    ChainStage(
      'Giá thóc bắt đầu tăng',
      'Các địa phương báo thương lái gom hàng trước mùa giáp hạt.',
      [
        EventChoice(
          'Kiểm kê kho dự trữ',
          'Chi 10, 1 hành động; chuẩn bị phân phối lương.',
          {'authority': 1},
          cost: 10,
          points: 1,
        ),
        EventChoice(
          'Vay thóc của thế gia',
          '1 hành động; thóc +30, trả 7 tiền mỗi tuần trong 5 tuần.',
          {'grain': 30},
          points: 1,
        ),
        EventChoice('Chờ thị trường tự ổn định', 'Lòng dân −3.', {
          'people': -3,
        }),
      ],
    ),
    ChainStage(
      'Địa phương tranh phần cứu trợ',
      'Hai vùng cùng xin mở kho, lượng thóc có hạn.',
      [
        EventChoice(
          'Chia lương theo số hộ',
          'Chi 10, xuất 20 thóc, 1 hành động; lòng dân +4.',
          {'people': 4},
          cost: 10,
          grainCost: 20,
          points: 1,
        ),
        EventChoice(
          'Ưu tiên vùng trọng yếu',
          'Xuất 10 thóc, 1 hành động; Ổn định triều đình +2, lòng dân −2.',
          {'stability': 2, 'people': -2},
          grainCost: 10,
          points: 1,
        ),
        EventChoice('Đóng kho chờ chỉ thị', 'Lòng dân −5.', {'people': -5}),
      ],
    ),
    ChainStage(
      'Khôi phục vụ mùa',
      'Nông dân cần giống và công cụ để không phải xin cứu trợ lần nữa.',
      [
        EventChoice(
          'Cấp giống và công cụ',
          'Chi 25, 1 hành động; thóc +20, lòng dân +3.',
          {'grain': 20, 'people': 3},
          cost: 25,
          points: 1,
        ),
        EventChoice(
          'Cho vay giống',
          'Chi 10, 1 hành động; thóc +10.',
          {'grain': 10},
          cost: 10,
          points: 1,
        ),
        EventChoice('Dừng hỗ trợ', 'Lòng dân −3, Ổn định triều đình −2.', {
          'people': -3,
          'stability': -2,
        }),
      ],
    ),
  ]),
  ...additionalChains,
];
final chainDefinitions = List<ChainDefinition>.unmodifiable(settlementChains);
ChainDefinition chainDefinition(String id) =>
    chainDefinitions.firstWhere((d) => d.id == id);
ChainDefinition legacyChainDefinition(String id) =>
    legacyChainDefinitions.firstWhere((d) => d.id == id);
