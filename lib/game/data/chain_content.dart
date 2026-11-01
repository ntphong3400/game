part of 'reign_content.dart';

// These are petitions, not a separate quest board. Branch keys are
// "stage:previous choice"; more specific full paths can override them.
const additionalChains = [
  ChainDefinition(
    'dyke',
    'Con đê trước mùa nước lớn',
    [
      ChainStage(
        'Vết nứt trên đê Đông Hà',
        'Đê Đông Hà rạn trước mùa nước lớn. Quan phủ xin quyết định trước khi huy động dân phu.',
        [
          EventChoice(
            'Cấp tiền tu bổ ngay',
            'Sửa sớm nhưng cần kiểm tra chất lượng.',
            {'levee': 8},
            cost: 30,
            points: 1,
          ),
          EventChoice(
            'Cử người khảo sát độc lập',
            'Chậm một bước để xác định đúng đoạn yếu.',
            {'authority': 1},
            cost: 12,
            points: 1,
          ),
          EventChoice(
            'Hoãn để giữ ngân khố',
            'Địa phương chưa được phép sửa.',
            {'people': -2},
          ),
        ],
      ),
      ChainStage(
        'Nước sông dâng sát mặt đê',
        'Đông Hà cần một phương án trước đợt mưa tới.',
        [
          EventChoice(
            'Gia cố đoạn xung yếu, sơ tán dân',
            'Bảo vệ cả công trình và người dân.',
            {'levee': 12, 'people': 2},
            cost: 35,
            grainCost: 10,
            points: 1,
          ),
          EventChoice(
            'Chỉ bảo vệ kho và khu dân cư',
            'Giảm tổn thất trước mắt, ruộng ngoài đê còn rủi ro.',
            {'levee': 4, 'people': -2},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Giao địa phương tự ứng phó',
            'Không cấp thêm nguồn lực.',
            {'people': -4},
          ),
        ],
      ),
      ChainStage(
        'Đông Hà qua trận nước lớn',
        'Đợt mưa đã qua. Triều đình cần chốt việc hỗ trợ và trách nhiệm công trình.',
        [
          EventChoice(
            'Cứu trợ và kiểm toán công trình',
            'Khôi phục đời sống và kiểm tra việc sử dụng tiền.',
            {'people': 4, 'authority': 2},
            cost: 20,
            grainCost: 12,
            points: 1,
          ),
          EventChoice(
            'Chỉ cấp lương cho hộ bị thiệt hại',
            'Ưu tiên cứu dân, chưa xét trách nhiệm.',
            {'people': 2},
            grainCost: 15,
            points: 1,
          ),
          EventChoice(
            'Khép hồ sơ, địa phương tự phục hồi',
            'Người bị thiệt hại không nhận hỗ trợ.',
            {'people': -4, 'stability': -2},
          ),
        ],
      ),
    ],
    condition: 'dyke',
    branches: {
      '1:0': ChainStage(
        'Đê đã sửa, dân vẫn bất an',
        'Quan phủ báo hoàn công, nhưng dân nói nền đê vẫn thấm nước. Khoản tu bổ trước cần được kiểm chứng.',
        [
          EventChoice(
            'Kiểm tra, sửa lại trước mùa mưa',
            'Bổ sung phần yếu thay vì tin riêng báo cáo.',
            {'levee': 12, 'authority': 2},
            cost: 22,
            points: 1,
          ),
          EventChoice(
            'Tin báo cáo, chỉ chuẩn bị sơ tán',
            'Có phương án cứu dân nhưng chưa xác nhận chất lượng đê.',
            {'people': 1},
            cost: 10,
            grainCost: 8,
            points: 1,
          ),
          EventChoice(
            'Chấp nhận nghiệm thu ngay',
            'Không kiểm chứng phản ánh của dân.',
            {'authority': -2},
          ),
        ],
      ),
      '1:1': ChainStage(
        'Đoạn đê yếu hơn lời báo',
        'Đoàn khảo sát đã xác định đúng đoạn sạt nền. Có thể tập trung vật liệu vào điểm này.',
        [
          EventChoice(
            'Sửa đúng đoạn đã khảo sát',
            'Thông tin sớm giúp giảm chi phí sửa.',
            {'levee': 16},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Sơ tán vùng thấp, sửa tạm',
            'Giữ người, chấp nhận rủi ro cho ruộng.',
            {'levee': 5, 'people': 1},
            cost: 12,
            grainCost: 10,
            points: 1,
          ),
          EventChoice(
            'Lưu báo cáo, chưa cấp tiền',
            'Đoạn yếu vẫn chưa được xử lý.',
            {'people': -3},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'justice',
    'Lá đơn dưới cửa kinh thành',
    [
      ChainStage(
        'Người đàn bà kêu oan',
        'Một người dân tố quan huyện ép chồng nhận tội cướp của. Hồ sơ chưa đủ để kết luận bên nào nói thật.',
        [
          EventChoice(
            'Đình chỉ thi hành án, bảo vệ nhân chứng',
            'Giữ cơ hội xét lại; chưa kết tội quan huyện.',
            {'authority': 1},
            cost: 18,
            points: 1,
          ),
          EventChoice(
            'Chuyển đơn về huyện xét lại',
            'Ít tốn tiền nhưng cơ quan bị tố tự kiểm tra.',
            {},
            cost: 5,
            points: 1,
          ),
          EventChoice(
            'Giữ nguyên án, không thụ lý',
            'Gia đình tiếp tục khiếu kiện.',
            {'people': -3},
          ),
        ],
      ),
      ChainStage(
        'Lá đơn thứ hai',
        'Gia đình tiếp tục xin xét lại. Hồ sơ cũ và lời khai cần được đối chiếu.',
        [
          EventChoice(
            'Mở cuộc xét hỏi độc lập',
            'Đối chiếu chứng cứ còn lại.',
            {'authority': 2},
            cost: 22,
            points: 1,
          ),
          EventChoice(
            'Cho hai bên đối chất tại huyện',
            'Khó bảo vệ người làm chứng hơn.',
            {},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Bác đơn tái thẩm',
            'Vụ án khép lại mà chưa được kiểm chứng độc lập.',
            {'people': -4},
          ),
        ],
      ),
      ChainStage(
        'Phán quyết trước công đường',
        'Triều đình phải phán quyết theo chứng cứ đã xác minh, không chỉ theo lời kêu oan.',
        [
          EventChoice(
            'Phán quyết theo chứng cứ đã xác minh',
            'Minh oan khi đủ chứng cứ; giữ án khi cáo buộc không đúng; thiếu chứng cứ thì bảo toàn tái thẩm.',
            {'authority': 3},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Ân giảm để khép tranh chấp',
            'Giảm căng thẳng nhưng trách nhiệm chưa rõ.',
            {'people': 1, 'authority': -2},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Giữ án cũ, không công bố kết quả',
            'Không giải đáp nghi vấn của dân.',
            {'people': -4, 'authority': -2},
          ),
        ],
      ),
    ],
    branches: {
      '1:0': ChainStage(
        'Lời khai không khớp',
        'Nhân chứng được bảo vệ còn có thể đối chiếu lời khai. Một chi tiết quan trọng trong hồ sơ cũ không khớp.',
        [
          EventChoice(
            'Xác minh vật chứng và lời khai',
            'Đủ cơ sở để phân biệt oan án với lời tố sai.',
            {'authority': 2},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Chỉ nghe đối chất hai bên',
            'Chưa kiểm chứng vật chứng độc lập.',
            {},
            cost: 6,
            points: 1,
          ),
          EventChoice('Dừng tái thẩm', 'Bỏ phí cơ hội làm rõ.', {'people': -4}),
        ],
      ),
      '1:1': ChainStage(
        'Người làm chứng xin được bảo vệ',
        'Huyện báo không có sai phạm, nhưng một người làm chứng nói đã bị gây sức ép sau khi nhận đơn chuyển về.',
        [
          EventChoice(
            'Đưa nhân chứng về kinh, xét hỏi độc lập',
            'Cứu cơ hội xác minh với kinh phí cao hơn.',
            {'authority': 1},
            cost: 28,
            points: 1,
          ),
          EventChoice(
            'Yêu cầu huyện cam kết bảo vệ',
            'Vẫn phụ thuộc bộ máy đang bị tố.',
            {'people': -1},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Chấp nhận kết luận của huyện',
            'Nghi vấn chưa được giải đáp.',
            {'people': -4},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'exams',
    'Những cái tên trên bảng vàng',
    [
      ChainStage(
        'Xin thêm suất tiến cử',
        'Các gia tộc xin dành chức vị cho người được bảo lãnh trong khoa tuyển quan sắp tới.',
        [
          EventChoice(
            'Giữ thi tuyển công khai',
            'Tốn kinh phí tổ chức, giảm sự can thiệp gia tộc.',
            {'authority': 2, 'faction:Thế gia': -2},
            cost: 20,
            points: 1,
          ),
          EventChoice(
            'Cho tiến cử nhưng phải khảo hạch',
            'Giữ cửa cho người được bảo lãnh, chưa bảo đảm chức vị.',
            {'faction:Thế gia': 1},
            cost: 12,
            points: 1,
          ),
          EventChoice(
            'Chấp thuận suất dành riêng',
            'Lấy sự ủng hộ trước mắt, giảm uy tín khoa tuyển.',
            {'faction:Thế gia': 4, 'authority': -3},
          ),
        ],
      ),
      ChainStage(
        'Bảng vàng có lời dị nghị',
        'Danh sách trúng tuyển gây tranh luận. Cần quyết định cách kiểm tra trước khi giao công vụ.',
        [
          EventChoice(
            'Khảo hạch lại theo bài làm thực tế',
            'Sàng lọc người không đạt trước khi bổ nhiệm.',
            {'authority': 2},
            cost: 18,
            points: 1,
          ),
          EventChoice(
            'Giữ danh sách, giao việc thử',
            'Kiểm chứng năng lực bằng công vụ.',
            {},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Bổ nhiệm theo người bảo lãnh',
            'Chấp nhận sức ép gia tộc.',
            {'authority': -3, 'faction:Thế gia': 2},
          ),
        ],
      ),
      ChainStage(
        'Tân quan nhận việc',
        'Một người trong danh sách đã được chọn để thử việc. Chưa ai được tự động thay quan đang tại chức.',
        [
          EventChoice(
            'Giao việc thử có giám sát',
            'Có căn cứ đánh giá trước khi đưa vào nguồn bổ nhiệm.',
            {'people': 1},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Giao địa phương nhận xét',
            'Ít giám sát hơn, tiết kiệm kinh phí.',
            {},
            cost: 5,
            points: 1,
          ),
          EventChoice(
            'Chỉ ghi danh, không thử việc',
            'Chưa kiểm chứng được năng lực.',
            {'authority': -2},
          ),
        ],
      ),
      ChainStage(
        'Bản tấu đầu tiên của tân quan',
        'Thời gian thử việc kết thúc. Triều đình có thể giữ người trong danh sách ứng viên hoặc loại khỏi đợt tuyển.',
        [
          EventChoice(
            'Giữ người đạt yêu cầu trong nguồn bổ nhiệm',
            'Ứng viên được lưu để vua tự xem và bổ nhiệm.',
            {'authority': 2},
            points: 1,
          ),
          EventChoice(
            'Gia hạn thử việc tại địa phương',
            'Ứng viên vẫn được lưu, chưa ưu tiên bổ nhiệm.',
            {},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Loại khỏi đợt tuyển này',
            'Không tự bổ nhiệm hoặc thay người đang tại chức.',
            {'faction:Văn thần': -2},
          ),
        ],
      ),
    ],
    branches: {
      '1:0': ChainStage(
        'Bài thi bị nghi sao chép',
        'Dù đã thi công khai, hai bài đứng đầu giống nhau bất thường. Cần xác minh thay vì phủ nhận mọi nghi vấn.',
        [
          EventChoice(
            'Thi đối chứng trước hội đồng độc lập',
            'Giữ tiêu chuẩn tuyển dụng công khai.',
            {'authority': 3},
            cost: 16,
            points: 1,
          ),
          EventChoice(
            'Cho cả hai thử việc',
            'Công vụ sẽ kiểm chứng thêm năng lực.',
            {},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Công bố bảng vàng ngay',
            'Chưa giải đáp được nghi vấn.',
            {'authority': -2},
          ),
        ],
      ),
      '1:1': ChainStage(
        'Người được tiến cử trái ý gia tộc',
        'Một ứng viên làm bài tốt nhưng không chịu cam kết phục vụ lợi ích người bảo lãnh.',
        [
          EventChoice(
            'Bảo vệ quyền dự tuyển độc lập',
            'Giữ người đạt chuẩn, làm phật ý gia tộc.',
            {'authority': 2, 'faction:Thế gia': -3},
            cost: 12,
            points: 1,
          ),
          EventChoice(
            'Mời gia tộc dự buổi khảo hạch',
            'Giữ cơ hội thỏa thuận.',
            {'faction:Thế gia': 1},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Đổi sang người gia tộc đề nghị',
            'Nhượng quyền lựa chọn cho người bảo lãnh.',
            {'authority': -3},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'merit',
    'Công lao sau trận giữ ải',
    [
      ChainStage(
        'Hai bản báo công',
        'Sau một đợt giữ ải, chủ tướng và phó tướng gửi báo cáo mâu thuẫn về người thực sự giữ được cửa thành.',
        [
          EventChoice(
            'Xác minh quân công trước khi thưởng',
            'Chậm ban thưởng để nghe nhiều phía.',
            {'authority': 1},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Chia thưởng để giữ hòa khí',
            'Xoa dịu trước mắt, chưa rõ công lao.',
            {'army': 2},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Thưởng theo lời chủ tướng',
            'Lời kể một phía trở thành quyết định của triều đình.',
            {'faction:Võ tướng': 2, 'authority': -2},
          ),
        ],
      ),
      ChainStage(
        'Quân sĩ bất phục',
        'Binh sĩ xin trình lại danh sách người chiến đấu. Hai bên đều muốn triều đình công nhận.',
        [
          EventChoice(
            'Nghe lời lính, đối chiếu quân báo',
            'Giữ cơ hội sửa việc chia công sai.',
            {'army': 3, 'authority': 1},
            cost: 18,
            points: 1,
          ),
          EventChoice(
            'Thưởng bổ sung cho binh sĩ',
            'Xoa dịu quân lính, chưa xét lại báo công.',
            {'army': 2},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Buộc quân sĩ phục tùng kết luận cũ',
            'Giữ thể diện chỉ huy, lòng quân giảm.',
            {'army': -4},
          ),
        ],
      ),
      ChainStage(
        'Ấn tướng và lòng quân',
        'Triều đình phải chốt danh sách công trạng và trách nhiệm báo công.',
        [
          EventChoice(
            'Công bố công trạng đã xác minh',
            'Ghi công đúng người; người liên quan nhớ cách được đối xử.',
            {'army': 4, 'authority': 2},
            cost: 20,
            points: 1,
          ),
          EventChoice(
            'Giữ chỉ huy, sửa danh sách thưởng',
            'Dung hòa với người đang cầm quân.',
            {'army': 2, 'authority': -1},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Khép tranh chấp theo cấp bậc',
            'Thứ bậc thay cho chứng cứ.',
            {'army': -4, 'authority': -2},
          ),
        ],
      ),
    ],
    condition: 'military',
    branches: {
      '1:0': ChainStage(
        'Danh sách người giữ cửa ải',
        'Việc xác minh sớm giữ được quân báo và lời khai. Một số người có công đã bị bỏ tên.',
        [
          EventChoice(
            'Đối chất dựa trên hồ sơ còn nguyên',
            'Có cơ sở chốt công trạng đúng người.',
            {'army': 3, 'authority': 2},
            cost: 10,
            points: 1,
          ),
          EventChoice(
            'Bổ sung thưởng, không quy trách nhiệm',
            'Sửa thiệt thòi nhưng không xét người báo sai.',
            {'army': 2},
            cost: 20,
            points: 1,
          ),
          EventChoice(
            'Lưu hồ sơ, chưa công bố',
            'Quân sĩ vẫn chờ được ghi nhận.',
            {'army': -3},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'refugees',
    'Dân đến từ bên kia núi',
    [
      ChainStage(
        'Ba trăm hộ xin nương nhờ',
        'Dân vùng mất mùa xin cư trú. Phủ sở tại còn đất hoang nhưng lương dự trữ có hạn.',
        [
          EventChoice(
            'Cấp lương, cho ở tạm',
            'Tiếp nhận trực tiếp rồi tìm sinh kế.',
            {'people': 3},
            cost: 15,
            grainCost: 20,
            points: 1,
          ),
          EventChoice(
            'Phân về các điền trang',
            'Giảm chi triều đình, phụ thuộc điều kiện của chủ đất.',
            {'faction:Thế gia': 3},
            grainCost: 8,
            points: 1,
          ),
          EventChoice('Từ chối tiếp nhận', 'Đoàn dân chưa có nơi định cư.', {
            'people': -3,
          }),
        ],
      ),
      ChainStage(
        'Trại dân ngoài cửa phủ',
        'Một phần dân lưu tán còn ở ngoài phủ. Địa phương xin quyết định về chỗ ở và việc làm.',
        [
          EventChoice(
            'Mở khu ở tạm, bảo đảm phần lương',
            'Cứu cơ hội ổn định trước khi tình hình xấu hơn.',
            {'people': 3},
            cost: 25,
            grainCost: 20,
            points: 1,
          ),
          EventChoice(
            'Cho làm thuê theo thỏa thuận công khai',
            'Có việc làm nhưng chưa có đất riêng.',
            {'people': 1},
            cost: 10,
            points: 1,
          ),
          EventChoice(
            'Để đoàn dân tự tìm nơi khác',
            'Địa phương không tổ chức hỗ trợ.',
            {'people': -4, 'stability': -2},
          ),
        ],
      ),
      ChainStage(
        'Ruộng mới cần nước',
        'Muốn hết cảnh cứu trợ, các hộ cần đất và đường nước. Dân sở tại cũng đòi bảo đảm quyền lợi.',
        [
          EventChoice(
            'Khai khẩn và hòa giải quyền dùng nước',
            'Đầu tư để các hộ tự nuôi sống.',
            {'people': 2},
            cost: 30,
            grainCost: 10,
            points: 1,
          ),
          EventChoice(
            'Chỉ cấp đất, giao dân tự làm kênh',
            'Ít tốn tiền, năng suất còn hạn chế.',
            {},
            cost: 12,
            points: 1,
          ),
          EventChoice(
            'Dừng kế hoạch định cư',
            'Người mới đến tiếp tục lệ thuộc.',
            {'people': -4},
          ),
        ],
        delay: 2,
      ),
      ChainStage(
        'Vụ gặt của người mới đến',
        'Sau thời gian khai khẩn, địa phương báo vụ gặt đầu tiên và phần hỗ trợ còn cần.',
        [
          EventChoice(
            'Cho ổn định sinh kế trước khi thu đủ thuế',
            'Giảm thu trước mắt để giữ cộng đồng mới.',
            {'people': 4},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Thu một phần để bù cứu trợ',
            'Có tiền ngay, lòng dân giảm nhẹ.',
            {'treasury': 20, 'people': -2},
            points: 1,
          ),
          EventChoice(
            'Thu đủ và chấm dứt hỗ trợ',
            'Áp lực lớn với các hộ chưa tự nuôi sống.',
            {'treasury': 30, 'people': -5},
          ),
        ],
      ),
    ],
    branches: {
      '1:0': ChainStage(
        'Làng cũ không muốn chia đất',
        'Sau khi được tiếp nhận, dân mới cần chỗ ở lâu dài. Dân sở tại lo mất đất và phần nước tưới.',
        [
          EventChoice(
            'Đo lại đất công, đền bù phần bị ảnh hưởng',
            'Bảo vệ quyền lợi cả hai phía.',
            {'people': 3, 'stability': 1},
            cost: 20,
            points: 1,
          ),
          EventChoice(
            'Chỉ dùng đất hoang xa làng',
            'Giảm tranh chấp, tốn thêm lương đi lại.',
            {'people': 1},
            grainCost: 12,
            points: 1,
          ),
          EventChoice(
            'Buộc làng cũ tự chia đất',
            'Chuyển gánh nặng cho dân sở tại.',
            {'people': -4},
          ),
        ],
      ),
      '1:1': ChainStage(
        'Người tá túc thành người mắc nợ',
        'Chủ điền đòi công lao động để trừ lương đã cấp. Các hộ nói không được biết điều kiện từ đầu.',
        [
          EventChoice(
            'Kiểm tra giao kèo, bảo đảm quyền rời đi',
            'Giới hạn sức ép của điền trang.',
            {'people': 3, 'faction:Thế gia': -4},
            cost: 18,
            points: 1,
          ),
          EventChoice(
            'Bù một phần khoản nợ cho các hộ',
            'Dùng ngân khố để giảm xung đột.',
            {'people': 1},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Công nhận mọi yêu cầu của chủ điền',
            'Dân lưu tán tiếp tục lệ thuộc.',
            {'people': -5, 'faction:Thế gia': 2},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'copper',
    'Mạch đồng dưới chân núi',
    [
      ChainStage(
        'Thợ săn nhặt được đá đồng',
        'Có dấu hiệu mạch quặng mới ở vùng xa. Trữ lượng và độ an toàn chưa được kiểm chứng.',
        [
          EventChoice(
            'Bỏ tiền khảo sát',
            'Giữ quyền quyết định, đầu tư trước khi có lợi.',
            {},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Cho thương nhân thăm dò có điều kiện',
            'Tiết kiệm vốn, phải thương lượng phần lợi.',
            {'faction:Thế gia': 2},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Gác việc thăm dò',
            'Khép hồ sơ sớm; không mặc định phát sinh tai họa.',
            {},
          ),
        ],
      ),
      ChainStage(
        'Mạch quặng và đất tổ',
        'Kết quả thăm dò cho thấy có thể khai thác, nhưng lối vào mỏ đi qua đất sinh hoạt của dân.',
        [
          EventChoice(
            'Thương lượng bồi hoàn và quy định an toàn',
            'Tăng vốn để có sự hợp tác của địa phương.',
            {'people': 2},
            cost: 30,
            points: 1,
          ),
          EventChoice(
            'Đổi đường vào mỏ, khai thác nhỏ',
            'Giữ đất dân nhưng giảm quy mô.',
            {},
            cost: 18,
            points: 1,
          ),
          EventChoice(
            'Trưng đất, khai thác gấp',
            'Có tiền sớm, dân bất mãn và an toàn chưa bảo đảm.',
            {'treasury': 20, 'people': -5},
          ),
        ],
      ),
      ChainStage(
        'Chuyến đồng đầu tiên',
        'Mỏ gửi chuyến hàng đầu. Muốn mở rộng phải quyết định giữa thu lợi và tái đầu tư.',
        [
          EventChoice(
            'Kiểm tra an toàn, tái đầu tư',
            'Hoãn thu để giữ vận hành ổn định.',
            {'authority': 1},
            cost: 25,
            points: 1,
          ),
          EventChoice(
            'Thu lợi, giữ quy mô hiện tại',
            'Có tiền ngay, chưa mở rộng bảo đảm an toàn.',
            {'treasury': 25},
            points: 1,
          ),
          EventChoice(
            'Ép tăng sản lượng ngay',
            'Thu nhiều trước mắt, tăng tổn thất và bất mãn.',
            {'treasury': 40, 'people': -5, 'stability': -2},
          ),
        ],
      ),
      ChainStage(
        'Ai được hưởng mạch đồng?',
        'Cần chốt phần lợi của triều đình, nhà đầu tư và dân địa phương trước đợt khai thác tiếp.',
        [
          EventChoice(
            'Chia lợi có giám sát, giữ quy định an toàn',
            'Có thể tạo nguồn thu dài hạn nếu chuẩn bị đủ.',
            {'people': 2, 'authority': 2},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Nhượng quyền để nhận khoản tiền ngay',
            'Thu một lần và kết thúc phần đầu tư của triều đình.',
            {'treasury': 45, 'authority': -2},
            points: 1,
          ),
          EventChoice(
            'Đóng mỏ, thanh lý phần còn lại',
            'Chấm dứt rủi ro khai thác và nguồn thu tương lai.',
            {'treasury': 10, 'people': -2},
          ),
        ],
      ),
    ],
    branches: {
      '1:1': ChainStage(
        'Nhà thăm dò xin độc quyền',
        'Thương nhân đã tìm thấy quặng, nay muốn đổi công thăm dò lấy quyền khai thác lâu dài.',
        [
          EventChoice(
            'Mua lại kết quả, bồi hoàn đất dân',
            'Lấy lại quyền quản lý bằng kinh phí lớn hơn.',
            {'people': 2, 'authority': 1},
            cost: 42,
            points: 1,
          ),
          EventChoice(
            'Cho khai thác nhỏ, giới hạn thời hạn',
            'Giữ nhà đầu tư nhưng hạn chế quyền.',
            {'faction:Thế gia': -1},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Chấp thuận độc quyền và trưng đất',
            'Nhận tiền trước, giảm quyền kiểm soát.',
            {'treasury': 25, 'people': -5, 'authority': -2},
          ),
        ],
      ),
    },
  ),
  ChainDefinition(
    'palaceRumor',
    'Lời đồn sau rèm ngọc',
    [
      ChainStage(
        'Lời tố trong nội đình',
        'Một người trong hậu cung bị tố dùng quan hệ gia tộc để giành phần cấp phát. Lời tố chưa được xác minh.',
        [
          EventChoice(
            'Kiểm tra sổ chi kín đáo',
            'Giữ chứng cứ, chưa quy tội người bị tố.',
            {},
            cost: 12,
            points: 1,
          ),
          EventChoice(
            'Giao nội đình hòa giải và đối chiếu',
            'Giảm căng thẳng nhưng ít kiểm chứng độc lập hơn.',
            {'stability': 1},
            cost: 5,
            points: 1,
          ),
          EventChoice(
            'Khiển trách ngay để răn đe',
            'Có thể trách oan khi chưa rõ sự việc.',
            {'authority': 1},
          ),
        ],
      ),
      ChainStage(
        'Sổ chi và lời người hầu',
        'Các lời khai cần được đối chiếu với sổ cấp phát trước khi kết luận.',
        [
          EventChoice(
            'Đối chiếu độc lập cả hai phía',
            'Làm rõ sai phạm, nhầm lẫn hay vu cáo.',
            {'authority': 1},
            cost: 15,
            points: 1,
          ),
          EventChoice(
            'Dàn xếp, sửa phần cấp phát',
            'Giảm tranh chấp, chưa xác minh được trách nhiệm.',
            {'stability': 1},
            cost: 10,
            points: 1,
          ),
          EventChoice(
            'Công nhận lời tố là thật',
            'Quy tội khi chứng cứ còn thiếu.',
            {'stability': -3},
          ),
        ],
      ),
      ChainStage(
        'Trả lại sự yên ổn trong cung',
        'Đã đến lúc công bố điều biết được và quyết định cách cấp phát về sau.',
        [
          EventChoice(
            'Công bố kết luận, phục hồi người bị trách oan',
            'Chỉ xử người có lỗi khi đã xác minh.',
            {'stability': 3},
            cost: 10,
            points: 1,
          ),
          EventChoice(
            'Xử lý kín, công khai quy tắc cấp phát',
            'Giảm xung đột, danh dự chưa được giải thích đầy đủ.',
            {'stability': 2},
            cost: 8,
            points: 1,
          ),
          EventChoice(
            'Cấm nhắc lại, giữ lời khiển trách cũ',
            'Lời đồn còn tác động tới quan hệ.',
            {'stability': -4},
          ),
        ],
      ),
    ],
    condition: 'harem',
    branches: {
      '1:2': ChainStage(
        'Gia tộc xin giải thích lời khiển trách',
        'Sau khi người bị tố bị trách ngay, gia tộc yêu cầu biết chứng cứ. Nội đình bắt đầu chia phe.',
        [
          EventChoice(
            'Mở lại việc xác minh, chưa kết tội',
            'Có cơ hội sửa việc xử lý vội.',
            {'authority': -1},
            cost: 20,
            points: 1,
          ),
          EventChoice(
            'Bù cấp phát để hòa giải',
            'Tốn tiền nhưng chưa làm rõ đúng sai.',
            {'stability': 1},
            cost: 25,
            points: 1,
          ),
          EventChoice('Bác yêu cầu giải thích', 'Mâu thuẫn với gia tộc tăng.', {
            'stability': -4,
          }),
        ],
      ),
    },
  ),
];
