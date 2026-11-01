part of 'reign_content.dart';

class _Chapter {
  const _Chapter(
    this.title,
    this.body,
    this.cost,
    this.sacrifice,
    this.alternative,
  );
  final String title, body, alternative;
  final int cost;
  final Map<String, int> sacrifice;
}

ChainDefinition _settlementChain(
  String id,
  String title,
  List<_Chapter> chapters, {
  String condition = 'any',
  bool economic = false,
  Map<String, int> rewards = const {},
  Map<String, int> personRewards = const {},
}) => ChainDefinition(
  id,
  title,
  [
    for (final c in chapters)
      ChainStage(c.title, c.body, [
        const EventChoice('Từ bỏ và quyết toán chuỗi', '', {}, points: 1),
        EventChoice(
          'Cấp ${c.cost} tiền để hoàn thành phần việc',
          '',
          {},
          cost: c.cost,
          points: 1,
        ),
        EventChoice(c.alternative, '', c.sacrifice, points: 1),
      ]),
  ],
  condition: condition,
  economic: economic,
  rewards: rewards,
  personRewards: personRewards,
);

final settlementChains = <ChainDefinition>[
  _settlementChain('embezzlement', 'Dấu vết tiền cứu trợ', const [
    _Chapter(
      'Tiền cứu trợ đi đâu?',
      'Dân chưa nhận được cứu trợ. Triều đình cần mở hồ sơ và giữ sổ gốc trước khi lần theo dòng tiền.',
      30,
      {'authority': -3},
      'Nhượng quyền đối chiếu cho các gia tộc, uy quyền −3',
    ),
    _Chapter(
      'Hai cuốn sổ ở phủ huyện',
      'Số cấp phát và số thực nhận không khớp. Cần lấy lời khai, niêm phong chứng từ và kiểm tra từng khoản.',
      40,
      {'people': -5},
      'Huy động dân cung cấp chứng cứ và chịu đình trệ, lòng dân −5',
    ),
    _Chapter(
      'Chứng cứ chạm tới đại thần',
      'Dấu vết dẫn tới người có thế lực. Phần việc tiếp theo là xác minh độc lập các khoản có thể thu hồi.',
      50,
      {'stability': -5},
      'Mở đối chất giữa các phe, ổn định triều đình −5',
    ),
    _Chapter(
      'Phán quyết và thu hồi',
      'Hồ sơ đã đủ để thi hành quyết định theo chứng cứ. Tiền chỉ được nhập kho khi khép hồ sơ và quyết toán.',
      60,
      {'authority': -6},
      'Chấp nhận thỏa thuận thi hành của các gia tộc, uy quyền −6',
    ),
  ], economic: true),
  _settlementChain(
    'border',
    'Lửa âm ỉ nơi biên ải',
    const [
      _Chapter(
        'Thương lộ bị chặn',
        'Trạm biên giới giữ hàng, thương nhân xin triều đình mở hồ sơ đối thoại và bảo vệ cửa ải.',
        30,
        {'authority': -3},
        'Nhượng quyền chủ trì cho quan biên giới, uy quyền −3',
      ),
      _Chapter(
        'Đường tiếp tế tới cửa khẩu',
        'Để có vị thế thương lượng, các trạm tiếp tế cần được sắp xếp lại.',
        40,
        {'people': -5},
        'Huy động dân phu phục vụ cửa ải, lòng dân −5',
      ),
      _Chapter(
        'Yêu sách trên bàn nghị hòa',
        'Các bên trình điều kiện khác nhau. Triều đình phải thống nhất phương án trước khi ký kết.',
        40,
        {'stability': -4},
        'Để các phe tranh luận công khai, ổn định triều đình −4',
      ),
      _Chapter(
        'Hiệp ước cửa khẩu',
        'Hoàn tất giám sát hiệp ước, bàn giao lực lượng và công bố kết quả toàn bộ hồ sơ.',
        50,
        {'authority': -5},
        'Nhượng quyền giám sát cho địa phương, uy quyền −5',
      ),
    ],
    rewards: {'army': 20, 'authority': 6, 'war': -1},
  ),
  _settlementChain(
    'granary',
    'Kho lương trước mùa giáp hạt',
    const [
      _Chapter(
        'Giá thóc bắt đầu tăng',
        'Các phủ báo thương lái gom thóc. Cần lập danh sách kho và hộ thiếu ăn để chuẩn bị phân phối.',
        20,
        {'authority': -2},
        'Giao địa phương tự kiểm kê theo lệ riêng, uy quyền −2',
      ),
      _Chapter(
        'Các phủ tranh phần dự trữ',
        'Sổ kê đã về, nhưng nơi nào cũng xin được ưu tiên. Cần thống nhất cách phân bổ.',
        30,
        {'stability': -3},
        'Để các phe tự thương lượng định mức, ổn định triều đình −3',
      ),
      _Chapter(
        'Đường vận lương',
        'Cần tổ chức tuyến vận chuyển và kiểm tra lượng thóc trước khi bàn giao.',
        30,
        {'authority': -3},
        'Nhượng quyền điều phối cho các phủ, uy quyền −3',
      ),
      _Chapter(
        'Khép sổ dự trữ',
        'Hoàn tất hợp đồng giống, kho và phân phối. Lương thực của chương trình được ghi nhận khi quyết toán.',
        40,
        {'people': -5},
        'Huy động lao dịch hoàn tất kho và vận chuyển, lòng dân −5',
      ),
    ],
    rewards: {'grain': 100, 'people': 8},
  ),
  _settlementChain(
    'dyke',
    'Con đê trước mùa nước lớn',
    const [
      _Chapter(
        'Vết nứt trên đê Đông Hà',
        'Quan phủ trình dấu nứt mới. Cần khảo sát độc lập trước khi tổ chức tu bổ.',
        20,
        {'authority': -2},
        'Giao hào trưởng tự tổ chức khảo sát, uy quyền −2',
      ),
      _Chapter(
        'Bản vẽ và phần đất cần giữ',
        'Kết quả khảo sát đã về. Các bên phải thống nhất tuyến đê và trách nhiệm thi công.',
        30,
        {'stability': -3},
        'Để các phe tự phân chia trách nhiệm, ổn định triều đình −3',
      ),
      _Chapter(
        'Kiểm tra nền đê',
        'Phần nền cần được nghiệm thu trước khi khép các đoạn yếu.',
        30,
        {'authority': -3},
        'Chấp nhận nghiệm thu do địa phương chủ trì, uy quyền −3',
      ),
      _Chapter(
        'Bàn giao tuyến đê',
        'Đoạn đê đã sẵn sàng bàn giao. Mức bảo vệ được cộng sau khi chốt nghiệm thu toàn chương trình.',
        40,
        {'people': -5},
        'Huy động dân hoàn thiện mặt đê, lòng dân −5',
      ),
    ],
    condition: 'dyke',
    rewards: {'levee': 35, 'people': 6},
  ),
  _settlementChain(
    'justice',
    'Lá đơn dưới cửa kinh thành',
    const [
      _Chapter(
        'Lá đơn kêu oan',
        'Một gia đình xin xét lại bản án. Nhà vua cần mở hồ sơ, giữ vật chứng và bảo đảm việc lấy lời khai.',
        20,
        {'authority': -2},
        'Nhượng quyền mở hồ sơ cho các quan sở tại, uy quyền −2',
      ),
      _Chapter(
        'Lời khai và vật chứng',
        'Cần đối chiếu độc lập thay vì chỉ nghe một phía. Kết quả xác minh sẽ được giữ trong hồ sơ.',
        20,
        {'authority': -2},
        'Cho địa phương chủ trì việc đối chiếu, uy quyền −2',
      ),
      _Chapter(
        'Sự thật trước công đường',
        'Hồ sơ đã có kết quả xác minh. Các bên được đối chất theo chứng cứ trước khi thi hành.',
        30,
        {'stability': -3},
        'Mở đối chất giữa các phe trong triều, ổn định triều đình −3',
      ),
      _Chapter(
        'Thi hành phán quyết',
        'Hoàn tất việc phục hồi quyền lợi hoặc thi hành bản án theo sự thật đã xác minh.',
        30,
        {'authority': -3},
        'Chấp nhận địa phương tự tổ chức thi hành, uy quyền −3',
      ),
    ],
    rewards: {'people': 12, 'authority': 8},
  ),
  _settlementChain(
    'exams',
    'Những cái tên trên bảng vàng',
    const [
      _Chapter(
        'Danh sách người dự tuyển',
        'Các địa phương gửi danh sách. Cần mở đợt tuyển chọn và thống nhất tiêu chuẩn.',
        20,
        {'stability': -2},
        'Cho các phe đề cử theo suất riêng, ổn định triều đình −2',
      ),
      _Chapter(
        'Dị nghị quanh bài thi',
        'Có lời bàn về việc ưu ái. Cần đối chiếu bài thi và giải trình trước khi thử việc.',
        20,
        {'authority': -2},
        'Nhượng quyền kiểm tra cho các gia tộc, uy quyền −2',
      ),
      _Chapter(
        'Thử việc tại phủ',
        'Người vượt vòng thi phải xử lý công việc thực tế. Ứng viên chỉ được bổ sung khi khép cả đợt đánh giá.',
        30,
        {'stability': -3},
        'Cho các phe tự tổ chức thử việc, ổn định triều đình −3',
      ),
      _Chapter(
        'Đánh giá trước triều',
        'Hoàn tất hồ sơ năng lực. Đủ bốn bước sẽ giới thiệu một ứng viên mới để vua tự bổ nhiệm.',
        30,
        {'authority': -3},
        'Chấp nhận hội đồng địa phương chốt đánh giá, uy quyền −3',
      ),
    ],
    rewards: {'authority': 5},
  ),
  _settlementChain(
    'merit',
    'Công lao sau trận giữ ải',
    const [
      _Chapter(
        'Báo công từ cửa ải',
        'Một võ quan xin ghi nhận công lao. Cần mở hồ sơ đối chiếu quân báo.',
        20,
        {'authority': -2},
        'Giao tướng lĩnh tự xác nhận bước đầu, uy quyền −2',
      ),
      _Chapter(
        'Hai danh sách công trạng',
        'Các đơn vị trình danh sách khác nhau. Cần kiểm tra người và việc thực tế.',
        20,
        {'stability': -2},
        'Để các phe quân sự tự phân định, ổn định triều đình −2',
      ),
      _Chapter(
        'Lời kể của người giữ thành',
        'Nhân chứng được tập hợp để xác nhận công trạng trước khi ban thưởng.',
        30,
        {'authority': -3},
        'Nhượng quyền xác nhận cho cấp chỉ huy, uy quyền −3',
      ),
      _Chapter(
        'Ghi công trước quân ngũ',
        'Hoàn tất ghi công và tổ chức lại lực lượng. Phần thưởng được trao khi khép hồ sơ.',
        30,
        {'stability': -3},
        'Thỏa thuận ghi công giữa các phe, ổn định triều đình −3',
      ),
    ],
    condition: 'military',
    rewards: {'army': 20},
    personRewards: {'loyalty': 12},
  ),
  _settlementChain(
    'refugees',
    'Dân đến từ bên kia núi',
    const [
      _Chapter(
        'Những đoàn người ngoài cửa phủ',
        'Các gia đình lưu tán xin định cư. Cần khảo sát nơi ở và lập danh sách nhu cầu.',
        30,
        {'authority': -3},
        'Giao các chủ điền tự tổ chức tiếp nhận, uy quyền −3',
      ),
      _Chapter(
        'Đất ở và đường nước',
        'Cần phân đất, mở đường và bảo đảm quyền sử dụng cho người mới đến.',
        40,
        {'people': -5},
        'Huy động dân sở tại mở đường và chỉnh đất, lòng dân −5',
      ),
      _Chapter(
        'Giống và công cụ',
        'Chương trình cần hoàn tất việc chuẩn bị sản xuất trước khi đánh giá vụ gặt.',
        40,
        {'stability': -4},
        'Cho các phe tự phân bổ giống và công cụ, ổn định triều đình −4',
      ),
      _Chapter(
        'Vụ gặt của người mới đến',
        'Hoàn tất kiểm đếm và xác nhận quyền định cư. Thành quả chương trình được trao khi quyết toán.',
        50,
        {'authority': -5},
        'Chấp nhận các chủ điền chốt việc phân chia, uy quyền −5',
      ),
    ],
    rewards: {'grain': 90, 'people': 10},
  ),
  _settlementChain('copper', 'Mạch đồng dưới chân núi', const [
    _Chapter(
      'Thợ săn nhặt được đá đồng',
      'Dấu quặng mới được báo về. Cần khảo sát trữ lượng trước khi mở mỏ.',
      40,
      {'people': -5},
      'Huy động dân địa phương khảo sát mỏ, lòng dân −5',
    ),
    _Chapter(
      'Mạch quặng và đất tổ',
      'Phải thống nhất quyền khai thác và lối vào trước khi đưa thợ xuống mỏ.',
      50,
      {'authority': -5},
      'Nhượng quyền tổ chức cho các gia tộc, uy quyền −5',
    ),
    _Chapter(
      'Chuyến đồng thử nghiệm',
      'Mẻ đồng đầu chỉ dùng đánh giá sản lượng và an toàn; chưa nhập khoản thu nào vào ngân khố.',
      60,
      {'stability': -6},
      'Để các phe tự thỏa thuận phần khai thác, ổn định triều đình −6',
    ),
    _Chapter(
      'Khép sổ khai thác',
      'Hoàn tất việc kiểm định, bán sản lượng và quyết toán vốn của toàn chuỗi.',
      70,
      {'people': -5, 'authority': -3},
      'Huy động dân và nhượng quyền thi hành, lòng dân −5, uy quyền −3',
    ),
  ], economic: true),
  _settlementChain(
    'palaceRumor',
    'Lời đồn sau rèm ngọc',
    const [
      _Chapter(
        'Một lời tố trong nội cung',
        'Có lời tố nhắm vào một người trong hậu cung. Cần giữ hồ sơ và xác minh trước khi kết luận.',
        20,
        {'authority': -2},
        'Giao các gia tộc tự trình chứng cứ, uy quyền −2',
      ),
      _Chapter(
        'Sổ chi và lời kể',
        'Các lời kể chưa khớp. Cần đối chiếu sổ chi và người thực hiện cung vụ.',
        20,
        {'stability': -2},
        'Mở đối chất giữa hai bên trong cung, ổn định triều đình −2',
      ),
      _Chapter(
        'Kết quả đối chiếu',
        'Sự thật đã được xác minh. Cần thống nhất cách xử lý và phục hồi nền nếp.',
        30,
        {'authority': -3},
        'Nhượng quyền thu xếp cho các gia tộc, uy quyền −3',
      ),
      _Chapter(
        'Khép lời đồn',
        'Hoàn tất việc xử lý theo chứng cứ và bảo đảm sinh hoạt cho người liên quan.',
        30,
        {'stability': -3},
        'Thỏa thuận khép hồ sơ giữa các phe, ổn định triều đình −3',
      ),
    ],
    condition: 'harem',
    rewards: {'stability': 10},
    personRewards: {'affection': 10, 'discontent': -15},
  ),
  _settlementChain('market', 'Bến chợ Đông Hà', const [
    _Chapter(
      'Khảo sát bến chợ cũ',
      'Thương nhân xin mở lại bến bỏ hoang. Cần khảo sát và xác định quyền sử dụng.',
      40,
      {'people': -5},
      'Huy động dân khảo sát và dọn bến, lòng dân −5',
    ),
    _Chapter(
      'Huy động xây dựng',
      'Bản khảo sát đã về. Cần hoàn thiện bến, đường hàng và nơi tập kết.',
      50,
      {'authority': -5},
      'Nhượng quyền huy động cho các gia tộc, uy quyền −5',
    ),
    _Chapter(
      'Tổ chức vận hành',
      'Phải thống nhất sổ hàng, lịch giao dịch và trách nhiệm trước khi khai thông.',
      60,
      {'stability': -6},
      'Để các phe tự phân chia quyền vận hành, ổn định triều đình −6',
    ),
    _Chapter(
      'Khai thông thương lộ',
      'Hoàn tất kiểm định và mở giao dịch. Toàn bộ khoản thu chỉ nhập kho khi khép chuỗi.',
      70,
      {'people': -5, 'authority': -3},
      'Huy động dân và nhượng quyền khai thông, lòng dân −5, uy quyền −3',
    ),
  ], economic: true),
  ChainDefinition(
    'haremHarmony',
    'Chung một mái Phượng điện',
    [
      for (var i = 0; i < 4; i++)
        ChainStage(
          const [
            'Hai lời thỉnh cầu trái ngược',
            'Cùng nhận một cung vụ',
            'Một sai sót trước ngày hành lễ',
            'Công trạng trước Phượng điện',
          ][i],
          const [
            '{A} và {B} cùng xin chủ trì việc nội cung. Hai người thuộc hai phe khác nhau; quyết định lần này sẽ định cách phối hợp.',
            'Hai phi tần cần cùng chuẩn bị nghi lễ. Việc phân chia quyền phụ trách khiến cả hai phe theo dõi.',
            'Một sai sót làm hai bên đùn đẩy trách nhiệm. Vua cần quyết định cách xử lý để phần việc được hoàn tất.',
            'Nghi lễ đã sẵn sàng. Việc ghi nhận công trạng sẽ khép hồ sơ phối hợp của hai phi tần.',
          ][i],
          [
            EventChoice('Ưu ái {A}', '', {
              'faction:A': const [3, 4, 5, 6][i],
              'faction:B': -(const [5, 7, 8, 10][i]),
            }, points: 1),
            EventChoice('Ưu ái {B}', '', {
              'faction:B': const [3, 4, 5, 6][i],
              'faction:A': -(const [5, 7, 8, 10][i]),
            }, points: 1),
            EventChoice(
              'Giải quyết công bằng, cấp kinh phí cho cả hai bên',
              '',
              {},
              cost: const [20, 30, 30, 40][i],
              points: 1,
            ),
          ],
        ),
    ],
    condition: 'differentConsortFactions',
    rewards: {'stability': 5},
    personRewards: {'ability': 5, 'affection': 10, 'discontent': -15},
  ),
];
