// 405 individually written situations, 27 per pack. Columns:
// decision pattern[:condition[:urgent trigger]] | title | situation | three choices.
const eventStories = <String, String>{
  'community': '''
0|Giếng làng bị nhiễm bẩn|Dân hai xóm tranh nguồn nước sạch sau khi giếng chung đổi màu.|Cấp tiền đào giếng mới|Chia kho dùng tạm|Để làng tự thu xếp
1|Đò ngang thu phí lạ|Chủ đò tự tăng phí, người làm ruộng không qua sông được.|Đích thân xét đơn|Công nhận biểu phí mới|Chờ phủ báo cáo
2|Xóm chài mất chỗ neo|Bến cũ bị lấp, thuyền đánh cá phải ngủ ngoài dòng nước xiết.|Đầu tư bến chung|Cấp thóc dựng bè tạm|Chưa mở bến mới
0|Nhà cháy trong ngõ hẹp|Một đám cháy lan qua dãy nhà, nhiều gia đình không còn mái trú.|Cấp tiền dựng nhà|Chia vật liệu trong kho|Để họ hàng cưu mang
1|Sổ hộ khẩu bỏ sót|Người tản cư sống ở kinh thành nhiều năm vẫn bị từ chối nhận khẩu phần.|Mở buổi đối chiếu sổ|Giữ nguyên phép đăng hộ|Chuyển đơn xuống huyện
2|Lò bánh nuôi người nghèo|Một nhóm thợ muốn mở lò bánh giá rẻ nhưng thiếu vốn ban đầu.|Bảo trợ lò bánh|Cấp thóc cho mẻ đầu|Không bảo trợ việc bán bánh
0|Trẻ mồ côi ở trạm dịch|Trạm dịch nuôi thêm trẻ mất cha mẹ, kinh phí ăn ở sắp cạn.|Lập quỹ chăm sóc|Chia khẩu phần kho trạm|Giao các làng tiếp nhận
1|Hai làng chung nghĩa địa|Hai làng cùng nhận quyền trên mảnh đất chôn cất, đám tang bị chặn lại.|Nghe lời người làm chứng|Buộc theo ranh cũ|Hoãn xét tranh chấp
2|Nhà trọ cho dân phu|Người sửa đường ngủ ngoài trời, chủ quán xin mở nhà trọ giá thấp.|Ứng vốn dựng nhà trọ|Cấp lương dựng lán|Chưa giải quyết chỗ nghỉ
0|Chợ phiên mất mái che|Mái chợ đổ sau một đêm gió, người buôn nhỏ không có chỗ bán.|Cấp tiền sửa mái|Chia vật tư dự trữ|Chờ thương hộ tự góp
1|Tiếng chuông xin cứu|Dân một xã gõ chuông vì bị trưởng xã giữ giấy đi đường.|Mở phiên xét công khai|Trao thêm quyền trưởng xã|Chờ hết kỳ thu thuế
2|Người què xin nghề mới|Cựu dân phu mất sức lao động xin học nghề đan giỏ để nuôi nhà.|Mở lớp truyền nghề|Cấp thóc trong thời gian học|Chưa lập lớp riêng
0|Người già qua mùa lạnh|Hội lão trình danh sách người sống một mình, không đủ củi sưởi.|Mua củi phát tận nhà|Chia phần từ kho công|Để dòng họ tự giúp
1|Tấm biển cấm gánh hàng|Quan phố cấm hàng rong để giữ đường sạch, nhiều gia đình mất kế sinh nhai.|Xét lại phạm vi lệnh cấm|Giữ lệnh dẹp hàng rong|Không trả lời kiến nghị
2|Cầu nhỏ tới lớp học|Trẻ em phải lội qua mương để tới lớp, làng muốn dựng cầu tre.|Cấp vốn làm cầu bền|Cấp thóc đổi ngày công|Giữ đường đi hiện tại
0|Đám cưới không đủ lễ|Một vùng ép nhà nghèo nộp lễ cưới quá lớn, nhiều đôi phải bỏ lễ.|Cấp quỹ cưới giản dị|Dùng vật phẩm công chia sẻ|Để giữ lệ địa phương
1|Người kéo xe bị bắt oan|Một toán lính bắt người kéo xe vì nhầm dấu trên kiện hàng.|Mở phiên đối chất ngay|Giữ người để răn đe|Đợi người nhà chứng minh
2|Bếp chung ngoài thành|Người làm thuê muốn mở bếp chung, chủ bến hứa góp mặt bằng.|Góp vốn lập bếp|Xuất thóc vận hành trước|Không tham gia bếp chung
0|Đàn bò phá vườn chung|Gia súc của nhà giàu phá hoa màu, người trồng vườn chưa được bồi thường.|Cấp tiền khắc phục trước|Chia lương cứu vụ này|Đợi hai bên tự dàn xếp
1|Cánh cổng đóng quá sớm|Lính giữ thành đóng cổng trước giờ, người đi chợ bị kẹt ngoài đêm.|Kiểm tra sổ trực cổng|Chuẩn y giờ đóng mới|Đợi thêm lời khai
2|Quán nước bên đường quan|Một góa phụ xin dựng quán nước cho người đi đường, làng đề nghị cùng góp.|Cấp vốn quán cộng đồng|Cấp thóc giúp khởi sự|Không cấp phép hỗ trợ
0|Người gánh nước đình công|Giá nước tăng khiến các xóm nghèo xin triều đình lập điểm cấp nước.|Mua nước cấp miễn phí|Chia nguồn nước kho công|Để giá tự điều chỉnh
1|Tên người chết trong sổ thu|Một huyện vẫn thu sưu của người đã mất, gia đình phải bán đồ trả nợ.|Đối chiếu sổ ngay|Giữ định mức thu cũ|Gác đơn tới cuối vụ
2|Xưởng may áo mùa đông|Thợ may xin nhận việc cho dân nghèo nếu triều đình ứng vốn vải.|Ứng vốn cho xưởng|Xuất thóc trả công trước|Chưa lập đơn hàng mới
0:lowPeople:rebellion_warning|Tấm chiếu trước cổng phủ|Dân kéo tới ngồi kín cổng phủ, yêu cầu hỗ trợ những nhà mất mùa.|Cấp cứu trợ tận hộ|Chia phần dự trữ|Đóng cửa tiếp dân
1:lowPeople:rebellion_warning|Người khiêng cày tới điện|Nông dân đặt cày trước nha môn, đòi vua nghe chuyện lao dịch quá mức.|Mở buổi dân trình bày|Buộc họ trở về ruộng|Chuyển đơn qua nhiều phủ
2:lowPeople:rebellion_warning|Bếp nguội trong xóm thợ|Các xưởng ngừng việc, người thợ yêu cầu một đường sống trước khi rời kinh.|Đầu tư việc làm khẩn|Xuất thóc giữ bếp chung|Mặc các xưởng đóng cửa
''',
  'finance': '''
0|Khoản sưu trên ruộng cát|Sổ thuế tính ruộng cát ngang ruộng tốt, dân xin điều chỉnh khoản thiếu.|Bù phần thu quá mức|Giữ mức thu đang có|Chờ kỳ lập sổ sau
1|Dấu mực trên sổ kép|Ngự sử tìm thấy hai bản sổ chi khác nhau trong cùng một kho.|Cấp phí kiểm toán kín|Dàn xếp với chủ kho|Cất sổ chờ xét sau
2|Đề nghị góp vốn xưởng giấy|Một xưởng giấy muốn mở thêm lò để bán giấy cho các phủ.|Góp vốn thử nghiệm|Vay thế gia để mở rộng|Chưa mở khoản đầu tư
0|Thuế người chạy chợ|Phu gánh hàng bị thu thuế cả lúc vào lẫn lúc rời chợ.|Hoàn một phần tiền thu|Duy trì thu hai lượt|Để huyện tự xử
1|Bao bạc thiếu niêm phong|Bạc nộp về có bao bị thay dây, quan vận chuyển nói vì mưa.|Cho truy lại tuyến vận|Nhận tiền và bỏ qua dấu|Lưu kho không điều tra
2|Lò gốm xin đơn hàng|Thợ gốm đề nghị nhận đơn bình đựng nước nếu được ứng tiền lò.|Ứng vốn đặt lô thử|Vay tiền đặt lô lớn|Chưa ký đơn hàng
0|Nợ sưu của lính tử trận|Gia đình lính đã mất vẫn phải trả khoản sưu ghi trước ngày nhập ngũ.|Bù khoản nợ cho nhà|Thu đủ theo sổ cũ|Chuyển đơn sang quân phủ
1|Sáp niêm kho bị thay|Người giữ chìa phát hiện mẫu sáp lạ trên hòm thuế tháng trước.|Thuê thợ xác minh dấu|Thỏa thuận với người giữ kho|Không mở lại hòm cũ
2|Xưởng nhuộm muốn đổi kỹ thuật|Một nhóm thợ xin vốn thử cách nhuộm ít tốn củi nhưng chưa có tiền lệ.|Tài trợ một mẻ thử|Vay vốn dựng cả xưởng|Giữ cách nhuộm cũ
0|Thuế đàn ong trên đồi|Hộ nuôi ong bị tính thuế theo số tổ dù mùa hoa thất bát.|Giảm phần thu năm nay|Thu đủ để giữ ngân sách|Đợi mùa hoa mới
1|Tiền sửa đình chưa tới làng|Làng xuất trình giấy nhận tiền nhưng trưởng làng nói chưa từng nhận.|Sai ngự sử truy khoản chi|Thu khoản dàn xếp từ hào lý|Tạm tin giấy đã ký
2|Mỏ đá gửi bản tính lãi|Chủ mỏ hứa bán đá cho công trình công nếu được mua thêm dụng cụ.|Góp vốn khai thác thử|Vay thế gia mua dụng cụ|Chưa rót vốn vào mỏ
0|Phí qua cầu tăng đột ngột|Một trạm cầu thu thêm tiền mỗi gánh khiến dân phải đi đường vòng.|Bù phí và giảm mức thu|Cho trạm giữ mức tăng|Chưa đổi quy định
1|Phiếu lĩnh lương trùng tên|Hai người cùng lĩnh lương bằng một tên, thuộc hạ yêu cầu kiểm tra kín.|Kiểm lại sổ lĩnh lương|Thu tiền giải quyết nội bộ|Để kỳ lương sau xét
2|Kho chứa muối liên doanh|Thương nhân mời triều đình góp vốn kho muối để tránh hỏng hàng mùa ẩm.|Góp phần vốn nhỏ|Vay tiền giành phần lớn|Không tham gia kho muối
0|Lệ phí chôn cất mới|Một phủ đặt thêm phí chôn cất để bù khoản thiếu trong sổ thu.|Bù khoản thiếu và giảm phí|Cho phép duy trì lệ phí|Để phủ tự cân đối
1|Đồng cân hụt trong kho bạc|Thợ cân báo quả cân của kho nhẹ hơn chuẩn, chưa rõ ai đổi.|Lập tổ kiểm cân độc lập|Nhận khoản bù của chủ kho|Giữ nguyên bộ cân
2|Thợ đúc xin thử khuôn mới|Thợ đúc muốn làm khuôn bền hơn, đổi lại xin triều đình chia lợi nhuận.|Cấp vốn cho một lò|Vay vốn nhân nhiều lò|Không chấp nhận thử khuôn
0|Phí đổi giấy thông hành|Dân phải trả tiền đổi giấy dù mẫu giấy cũ mới ban hành.|Bù phí đổi cho dân|Tiếp tục thu theo mẫu mới|Không xét lại lệ phí
1|Khoản chi cho trạm ma|Bộ sổ ghi tiền nuôi một trạm dịch đã bị bỏ hoang từ lâu.|Cho kiểm kê tận nơi|Nhận tiền bồi hoàn kín|Gác khoản chi chưa rõ
2|Nghề làm nến thiếu sáp|Phường làm nến cần vốn mua sáp đầu mùa, hứa nộp phần lãi.|Ứng vốn một mùa|Vay thế gia mua sáp lớn|Không ứng trước tiền
0|Thuế thuyền nằm bờ|Thuyền hỏng vẫn phải nộp thuế hoạt động, chủ thuyền xin xét lại.|Bù thuế cho thuyền hỏng|Thu theo số đăng bạ|Chờ đợt kiểm thuyền sau
1|Bản kê quân trang bị sửa|Khoản chi áo giáp tăng sau khi đã đóng ấn, người chép sổ phủ nhận.|Kiểm toán khoản quân trang|Nhận tiền dàn xếp của nhà cung|Chưa truy bản kê
2|Đề nghị chung vốn ép dầu|Chủ xưởng dầu muốn mua guồng ép mới để cung cấp dầu đèn cho kinh.|Góp vốn thử guồng mới|Vay tiền mở rộng ngay|Giữ nguồn mua hiện tại
0:debt|Gia đình quan nhỏ thiếu lương|Lương chậm làm nhiều nhà quan nhỏ phải vay nặng lãi để ăn.|Chi hỗ trợ và trả bớt nợ|Thu thêm để vá thiếu hụt|Để họ chờ kỳ sau
1:poor|Hộp tiền trạm thuế bị tráo|Trạm thuế báo thiếu tiền giữa lúc ngân khố cạn, chứng từ có nhiều vết sửa.|Truy xét khoản thất thoát|Nhận khoản nộp kín của thế gia|Chưa mở vụ điều tra
2:debt|Lời mời mua lại công trái|Thế gia muốn đổi một khoản vay mới lấy quyền ưu tiên cung ứng cho triều đình.|Đầu tư nguồn thu độc lập|Nhận khoản vay có điều kiện|Tiếp tục thiếu nguồn chi
''',
  'commerce': '''
0|Bến vải tìm đường mới|Thương nhân muốn mở bến bán vải tới các huyện xa nhưng thiếu bảo trợ.|Góp phí mở tuyến vải|Thu phí qua bến mới|Không hỗ trợ tuyến mới
1|Con dấu độc quyền bán dầu|Một thế gia xin độc quyền bán dầu đèn, các quán nhỏ phản đối.|Giữ cạnh tranh công bằng|Bán quyền cung ứng độc quyền|Để tranh chấp kéo dài
2|Thuyền gạo tới cửa biển|Một đoàn thuyền có gạo muốn đổi hàng trước khi đổi gió.|Mua gạo vào kho|Bán thóc lấy tiền mặt|Không chốt việc trao đổi
0|Phiên chợ trên núi|Người vùng núi muốn nối phiên chợ với kinh, cần dựng vài điểm dừng.|Bảo trợ điểm dừng chân|Thu phí thương lộ núi|Giữ đường buôn hiện tại
1|Giá đèn tăng sau lệnh cấm|Phường đèn xin cấm thợ ngoài phường bán hàng, giá đã bắt đầu tăng.|Bảo vệ quyền bán tự do|Bán quyền kiểm soát thị trường|Không can dự việc phường
2|Khoai khô đổi gạo mới|Một vùng đề nghị mua lương khô từ kho công để đổi gạo ở vùng khác.|Mua phần gạo trao đổi|Xuất kho lấy tiền trước|Chưa trao đổi lương thực
0|Hàng gốm qua ba trạm|Thương nhân bỏ đường cũ vì ba trạm thu trùng phí, xin mở tuyến chung.|Góp vốn thống nhất tuyến|Giữ tuyến mới để thu phí|Không sửa đường thương mại
1|Chủ kho ép giá người bán|Chủ một kho lớn chỉ nhận hàng từ thân hữu, chợ nhỏ thiếu hàng.|Mở quyền gửi kho bình đẳng|Đổi đặc quyền lấy tiền nộp|Đợi người bán tự tìm nơi
2|Cá khô xin vào kho lương|Thuyền chài đề nghị bán cá khô để đa dạng khẩu phần quân dân.|Mua một lô dự phòng|Bán thóc để tăng tiền|Chưa đổi loại dự trữ
0|Thuyền hàng thiếu bản đồ luồng|Người lái thuyền xin bảo trợ khảo sát luồng cạn để đi an toàn hơn.|Góp phí khảo sát luồng|Thu lệ phí trên tuyến khảo sát|Chưa khảo sát tuyến nước
1|Đấu thầu sạp chợ có người chặn|Những người trả giá thấp bị chặn không cho vào phiên đấu sạp.|Mở lại phiên đấu công khai|Nhượng sạp cho nhóm hào phú|Không xét đơn khiếu nại
2|Hạt kê từ vùng cao|Một đoàn buôn mang kê xuống kinh trong lúc giá gạo đang dao động.|Mua kê bổ sung kho|Bán thóc lấy tiền dự phòng|Không tham gia mua bán
0|Xe muối muốn vượt đèo|Đoàn xe muối xin được lập điểm nghỉ để bớt hao hụt trên đèo.|Cùng mở điểm nghỉ|Thu phí đoàn xe qua đèo|Không cấp bảo trợ
1|Tem chợ giả tràn lan|Một phường xin quyền kiểm soát mọi tem chợ, người bán sợ bị ép.|Giữ tem theo chuẩn chung|Bán quyền phát hành tem|Để chợ tự phân biệt tem
2|Đậu dự trữ sắp hết vụ|Thương nhân đề nghị bán đậu khô trước lúc chuyển sang chở hàng khác.|Mua đậu bổ sung lương|Bán thóc đổi ngân khố|Để đoàn buôn đi tiếp
0|Đường buôn dọc bờ hồ|Các làng muốn nối những bến nhỏ thành một đường buôn chung.|Ứng vốn nối các bến|Đặt phí trên đường mới|Chưa mở đường buôn
1|Người giữ chợ thiên vị|Chủ chợ xếp mọi vị trí tốt cho người cùng họ, người buôn nhỏ bức xúc.|Cấp phí sắp lại chỗ bán|Đổi quyền sắp chỗ lấy tiền|Không đổi lệ xếp chợ
2|Thóc giống đổi hàng thủ công|Một vùng muốn đổi lương thực lấy hàng thủ công của kinh thành.|Mua phần lương thực mới|Xuất thóc lấy tiền ngay|Không duyệt cuộc trao đổi
0|Sợi tơ tìm khách phương xa|Thợ tơ có hàng tốt nhưng không thể tự thuê đoàn vận chuyển lớn.|Bảo trợ chuyến hàng thử|Thu phí gom hàng đi xa|Không góp vào chuyến hàng
1|Cân chợ cùng nghiêng một phía|Nhiều sạp dùng cân lệch giống nhau, người mua nghi có người bảo kê.|Sửa chuẩn cân và xử công bằng|Nhận tiền phạt để giữ lệ cũ|Chưa đo lại các cân
2|Lương khô của đoàn lữ hành|Đoàn lữ hành muốn bán phần lương dư rồi mua hàng thủ công mang về.|Mua lương dư còn tốt|Bán thêm thóc cho đoàn|Không giao dịch với đoàn
0|Mộc bản rao hàng liên phủ|Người buôn muốn in bản rao chung để các phủ biết nguồn hàng.|Góp vốn in bản rao|Thu phí đăng tên nhà buôn|Không lập bản rao chung
1|Đường chợ bị trạm tư chắn|Một thế gia dựng trạm trên lối vào chợ rồi đòi thu phí riêng.|Gỡ trạm và bảo vệ người bán|Bán quyền thu trạm cho thế gia|Để các bên tự thương lượng
2|Gạo đóng chum của thương hộ|Nhà buôn thử giữ gạo trong chum kín, muốn bán lô đầu cho triều đình.|Mua lô dự trữ mới|Xuất kho lấy tiền bù chi|Chưa đổi cách dự trữ
0:peace|Đoàn thương nhân qua biên giới|Hai bên biên giới muốn mở đường trao đổi nhỏ khi cửa ải còn yên.|Bảo trợ đường buôn thử|Thu phí qua cửa ải|Không mở tuyến trao đổi
1:rich|Quyền cung ứng cho hoàng thành|Các nhà buôn lớn tranh một hợp đồng độc quyền, hàng quán nhỏ xin được tham gia.|Cho đấu thầu ngang quyền|Nhận tiền mua quyền độc cung|Trì hoãn quyết định cung ứng
2:hungry|Những bao gạo giữ giá|Thương nhân giữ lô gạo để chờ giá tăng trong khi kho công đang thiếu.|Mua ngay phần gạo ấy|Bán thóc để kiếm ngân khố|Để thương nhân tiếp tục giữ
''',
  'agriculture': '''
0|Giống lúa chín sớm|Một làng muốn thử giống lúa thu hoạch trước mùa bão nhưng chưa ai dám góp vốn.|Cấp tiền ruộng thử|Trưng thêm ruộng gieo ngay|Không thử giống mới
1|Thóc ăn hay thóc giống|Những nhà nghèo đang ăn cả phần thóc để dành cho vụ sau.|Xuất thóc cứu bữa trước|Vay thóc giống từ thế gia|Để dân tự chia phần
2|Mương dẫn nước bỏ hoang|Một mương cũ bị bồi lấp, các thửa ruộng phía cuối không nhận được nước.|Thuê người khơi mương|Huy động dân vét mương|Chưa sửa tuyến dẫn
0|Đậu xanh trên đất bạc|Quan điền đề nghị đổi một phần ruộng bạc màu sang trồng đậu.|Tài trợ vụ trồng thử|Ép mở rộng diện tích ngay|Giữ cây trồng hiện tại
1|Người cày không còn trâu|Dân một huyện bán trâu trả nợ, nhiều thửa đất bị bỏ không.|Cấp thóc hỗ trợ hộ cày|Vay trâu kèm thóc thế gia|Để ruộng chờ người thuê
2|Đập gỗ giữa hai xã|Hai xã dùng chung một đập đã mục, bên đầu nguồn không muốn góp sửa.|Cấp tiền thay đập|Buộc hai xã góp công|Để đập qua thêm vụ
0|Ruộng trũng nuôi cá|Một vùng muốn chuyển ruộng ngập lâu thành ao cá nhưng thiếu vốn đào.|Ứng vốn đào ao thử|Trưng đất đào ao rộng|Chưa đổi cách canh tác
1|Kho giống mở sai lúc|Kho giống địa phương đã phát hết phần dự phòng cho một nhóm nhà giàu.|Cấp thóc giữ vụ gieo|Vay thóc đổi quyền thuê ruộng|Để làng tự kiếm giống
2|Cửa nước bị nhà giàu chặn|Một điền trang nâng bờ làm nước không tới ruộng của các hộ phía dưới.|Cấp tiền mở cửa nước|Ép điền trang góp dân phu|Chờ họ tự thương lượng
0|Vườn dâu thay bãi cỏ|Thợ tơ muốn trồng dâu trên bãi cỏ hoang, dân chăn trâu chưa đồng ý.|Tài trợ khoảnh dâu thử|Trưng bãi làm vườn rộng|Chưa đổi cách dùng bãi
1|Lúa non bị đem cầm|Nông dân cầm cả vụ lúa chưa gặt, tới ngày trả nợ không còn phần ăn.|Xuất thóc cứu các hộ|Vay thế gia để chuộc vụ|Giữ nguyên giấy cầm cố
2|Cọc đo nước thiếu dấu|Những cọc mực nước không được thay dấu khiến việc chia nước luôn gây cãi vã.|Cấp tiền đo lại dòng|Huy động dân đặt cọc mới|Giữ dấu cũ thêm mùa
0|Nghề ủ phân từ rơm|Một nhóm nông dân xin vốn thử ủ rơm thay vì đốt hết sau vụ gặt.|Cấp vốn ủ phân thử|Buộc các làng gom rơm|Không lập khu thử nghiệm
1|Người thuê ruộng mất phần|Chủ ruộng tăng phần tô đúng lúc các nhà thuê vừa gặp mất mùa.|Xuất kho hỗ trợ tá điền|Vay thóc có thế chấp|Để giữ hợp đồng tô
2|Nước mặn qua cửa cống|Dân vùng ven biển báo cửa cống cũ không ngăn được triều mặn.|Thuê thợ sửa cửa cống|Huy động dân đắp bờ tạm|Chờ hết đợt nước mặn
0|Ruộng bỏ theo người tản cư|Người tản cư muốn nhận lại ruộng bỏ nhưng cần tiền khai phục.|Cấp vốn phục hồi thử|Trưng nhân lực khai hết ruộng|Chưa cấp vốn khai phục
1|Thóc dành cho đàn giống|Các hộ chăn nuôi thiếu phần thóc giữ đàn giống qua mùa khan.|Cấp thóc giữ đàn giống|Vay thóc từ điền trang|Để các hộ bán bớt đàn
2|Guồng nước gãy trục|Guồng nước của một cánh đồng gãy trục ngay trước kỳ xuống giống.|Cấp tiền thay trục|Buộc các hộ góp công sửa|Chờ thợ đến vụ sau
0|Cây kê chịu hạn|Một người từ vùng khô mang hạt kê chịu hạn xin làm ruộng mẫu.|Bảo trợ ruộng mẫu kê|Trưng ruộng gieo diện rộng|Không nhận giống lạ
1|Lương thợ gặt bị giữ|Nhà thuê gặt giữ phần lương bằng thóc, nhiều người làm công sắp bỏ đi.|Xuất thóc trả trước|Vay thóc của chủ điền|Để họ tự đòi lương
2|Bờ ruộng bị tràn lối|Những bờ ruộng bị phá làm lối đi khiến nước tràn khỏi đồng thấp.|Cấp tiền sửa bờ chung|Huy động dân đắp lại|Để ruộng giữ bờ cũ
0:spring|Vụ gieo đầu xuân muộn|Mưa đến chậm, quan điền xin thử cách gieo ít nước trên một khoảnh nhỏ.|Tài trợ thử gieo khô|Ép gieo ngay diện rộng|Giữ lịch gieo cũ
1:winter|Hạt giống qua mùa rét|Các hộ nghèo thiếu thóc ăn, kho giống có nguy cơ bị dùng hết trước xuân.|Phát thóc ăn giữ giống|Vay thóc từ nhà nhiều ruộng|Chưa can thiệp vào kho giống
2:rain|Nước ruộng dâng qua bờ|Mưa liên tiếp khiến một vùng ruộng phải lựa chọn giữ nước hay tháo bỏ.|Cấp tiền củng cố đường thoát|Huy động dân đắp bờ dẫn|Để nước tự rút
1:hungry:hunger|Cháo loãng bên kho giống|Người dân xếp hàng xin cứu đói, nhiều nhà đã không còn gì để gieo.|Xuất thóc cứu đói|Vay thóc của thế gia|Siết phần ăn tiếp tục chờ
1:hungry:hunger|Người bán cày lấy gạo|Nhiều hộ đem cày ra chợ đổi lấy gạo, vụ sau đang bị đánh đổi.|Cấp thóc giữ lại nông cụ|Vay thóc cứu các hộ|Không can thiệp việc bán cày
1:hungry:hunger|Làng bỏ bữa liên tiếp|Quan huyện báo những bếp lửa không còn được nhóm, người dân bắt đầu rời làng.|Xuất kho chặn nạn đói|Vay gạo từ các điền trang|Cắt khẩu phần chờ mùa gặt
''',
  'engineering': '''
0|Kè đá trôi chân móng|Thợ phát hiện lớp đá móng kè bị nước cuốn, cần xử lý trước khi bờ sạt.|Ứng vốn làm lại móng|Huy động dân gia cố bờ|Để kè giữ như cũ
1|Cầu đường tới doanh trại|Một cầu gỗ yếu làm xe tiếp tế và người đi chợ phải cùng chờ.|Thuê thợ sửa lối chung|Thu phí nhượng quyền qua cầu|Chưa sửa tuyến đi
2|Gỗ công trình thiếu dấu|Kho gỗ công có nhiều cây mất dấu, người giao nhận đổ lỗi cho nhau.|Cấp phí truy dấu gỗ|Nhận tiền dàn xếp nhà thầu|Gác hồ sơ gỗ thiếu
0|Bờ thành nghiêng xuống hồ|Một đoạn bờ bảo vệ khu dân cư nghiêng dần, thợ xin sửa khi nước còn thấp.|Ứng tiền gia cố nền|Trưng dân phu chống bờ|Chờ tới mùa sửa lớn
1|Đường vận lương đầy ổ lún|Đội xe quân lương thường mắc kẹt ở con đường dân cũng dùng chở hàng.|Thuê người đắp nền đường|Đặt trạm thu tiền sửa đường|Để xe tự tìm lối tránh
2|Gạch nung vỡ hàng loạt|Lô gạch xây kho bị vỡ trước khi dùng, nhà thầu cho rằng vận chuyển có lỗi.|Kiểm định và truy nguồn|Nhận tiền giảm giá để bỏ qua|Giữ lô gạch chưa xét
0|Bậc xuống bến sông sụt|Người gánh nước trượt ngã vì bậc xuống bến bị sụt thành hố.|Cấp tiền làm bậc chắc|Huy động người dùng bến sửa|Chưa lập công trình sửa
1|Giếng trong trạm quân dịch|Giếng trạm không đủ cho người đi đường và đội lính thay phiên.|Thuê thợ mở giếng rộng|Bán quyền khai thác nước trạm|Giữ mức nước hiện tại
2|Dụng cụ khai mương bị kê cao|Người coi công trình phát hiện giá dụng cụ cao hơn giá bán ngoài chợ.|Kiểm toán giá dụng cụ|Thu khoản hoàn tiền nội bộ|Không xét giá đã ký
0|Cống ngầm đầy rễ cây|Rễ cây xuyên cống làm nước dâng ngược vào những ngõ thấp.|Ứng vốn sửa đường cống|Huy động dân thông cống|Đợi nước rút mới tính
1|Bến tập kết quân trang|Khoảng sân giao hàng quá nhỏ khiến quân trang và hàng dân cùng bị chậm.|Mở rộng sân tập kết chung|Cho thế gia giữ quyền vào bến|Giữ bến giao nhận cũ
2|Dây kéo đá bị tráo|Đội kéo đá nhận loại dây kém hơn hợp đồng, chưa tìm được người chịu trách nhiệm.|Truy xét lô dây kéo|Nhận tiền bảo lãnh nhà thầu|Cho dùng tiếp loại dây
0|Đê phụ chắn nước ngược|Một đê phụ giữ nước sai hướng khiến các vườn thấp luôn bị úng.|Ứng tiền đổi hướng đê|Huy động làng mở lối nước|Giữ tuyến đê phụ
1|Lối xuyên đồi sạt mép|Đường qua đồi vừa dùng cho dân vừa dùng đưa tin quân sự, mép đường đang nứt.|Thuê thợ gia cố lối đi|Đặt phí riêng cho người qua|Chưa đóng tuyến để sửa
2|Đá tốt biến thành đá vụn|Đá được báo là loại tốt nhưng tới công trường chỉ còn nhiều đá vụn.|Cho thẩm định hợp đồng đá|Nhận khoản bù của người cung|Không mở lại hợp đồng
0|Bờ hồ trong xóm lún|Nhiều cọc nhà ven hồ bị lộ chân, dân xin gia cố trước khi nhà nghiêng.|Ứng vốn giữ bờ hồ|Trưng ngày công cư dân|Để từng nhà tự chống
1|Trạm thay ngựa thiếu máng nước|Người chuyển công văn và xe dân thường phải tranh một máng nước nhỏ.|Làm thêm máng dùng chung|Nhượng quyền thu phí trạm|Giữ công suất trạm cũ
2|Số ngày công bị ghi khống|Sổ công trình ghi nhiều người làm mà dân trong làng chưa từng nghe tên.|Cấp phí đối chiếu nhân công|Nhận tiền hoàn kín từ chủ việc|Chưa xét lại sổ công
0|Đường thoát nước dưới chợ|Ngõ chợ bị ngập vì ống dẫn nước nhỏ hơn phần đã vẽ trong thiết kế.|Ứng tiền mở rộng tuyến thoát|Huy động thương hộ đào lại|Đợi phiên chợ thưa mới làm
1|Cầu tạm qua suối quân lương|Cầu tạm rung mạnh khi xe đi, người dân cũng phải qua cùng tuyến.|Thuê thợ gia cường cầu|Cho nhà thầu thu phí qua cầu|Chưa gia cường cầu tạm
2|Vật liệu dư không vào sổ|Kho cuối công trình có vật liệu dư nhưng không ai ghi việc nhập lại.|Kiểm kê vật liệu thừa|Cho người cung mua lại kín|Để kho tự xử lý
0:weakLevee|Mái đê bị khoét làm lối|Dân chăn trâu khoét mái đê làm lối xuống sông, đoạn yếu ngày càng rộng.|Ứng vốn phục hồi mái đê|Huy động dân lấp lối khoét|Chỉ cắm biển cảnh báo
1|Đường vào kho cháy đèn|Đường vào kho tối khiến cả lính gác và phu hàng thường xuyên vấp ngã.|Lắp đèn chung cho lối vào|Bán quyền thu phí giữ đèn|Giữ lối đi trong tối
2|Bản vẽ móng kho bị đổi|Bản vẽ trong tay thợ khác bản đã đóng dấu, kinh phí đã chi quá nửa.|Truy bản vẽ và khoản chi|Chấp nhận khoản bù của chủ thầu|Để công trình theo bản mới
0:rain|Khe đê rỉ nước đục|Người giữ đê thấy nước đục rỉ qua khe nhỏ khi mực sông đang lên.|Ứng tiền bịt khe từ gốc|Huy động dân gia cố tức thì|Chờ khe rỉ rộng hơn
1|Cầu cho xe cứu thương|Đội vận chuyển người bệnh xin sửa cầu chung với tuyến quân nhu.|Thuê thợ sửa cầu an toàn|Nhượng phí qua cầu cho hào phú|Giữ giới hạn tải cũ
2|Quỹ bảo trì biến mất|Quỹ dành sửa những công trình nhỏ đã được rút nhưng không có biên nhận rõ.|Cấp phí truy quỹ bảo trì|Nhận tiền dàn xếp của chủ quỹ|Để vụ quỹ chìm xuống
''',
  'military': '''
0|Tân binh thiếu giày|Doanh trại nhận lính mới nhưng nhiều người phải tập trên nền đá bằng chân trần.|Mua giày cho tân binh|Trưng vật tư và lương trong dân|Để quân tự xoay xở
1|Trận địa thử chưa dựng|Một tướng trẻ xin lập trận địa thử, hứa tìm cách giữ cửa ải ít tốn quân.|Cấp phí diễn tập thử|Giao tướng toàn quyền điều quân|Chưa thử cách bố trí mới
2|Đội tuần tra thiếu bữa|Lính tuần biên xin phần lương thực đủ cho chuyến đi dài.|Cấp khẩu phần hành quân|Trưng lương từ làng ven ải|Rút bớt phần ăn
0|Dây cung trong kho mục|Nhiều dây cung đứt lúc tập, người coi kho xin thay trước đợt luân chuyển quân.|Mua dây cung đạt chuẩn|Trưng vật tư địa phương|Dùng nốt số dây cũ
1|Đường áp sát cửa ải|Trinh sát đề xuất thử tuyến vòng để chặn đối phương nếu biên giới có biến.|Tài trợ cuộc khảo sát|Cho tướng tự điều quân thử|Không thử tuyến vòng
2|Kho gạo quân đóng xa|Đội lính ở trạm xa phải chia khẩu phần thấp hơn định mức.|Đưa thêm lương tới trạm|Trưng phần ăn từ làng gần|Giữ định mức đang cấp
0|Lính gác ngủ ngoài mái|Khu nhà trực bị hỏng mái làm lính thay phiên nghỉ không đủ giấc.|Cấp tiền sửa nơi nghỉ|Trưng gỗ và thóc địa phương|Để doanh tự sửa dần
1|Kỹ thuật báo hiệu mới|Một đội trưởng muốn thử cách báo hiệu nhanh hơn giữa các đồn.|Cấp tiền thử hệ thống|Cho quân tự đặt quy tắc riêng|Giữ cách báo hiệu cũ
2|Đàn ngựa thiếu thức ăn|Những con ngựa quân yếu dần vì phần thức ăn không theo kịp lịch tập.|Xuất lương giữ sức ngựa|Trưng thêm từ các làng|Giảm bữa và chờ tiếp tế
0|Quân y thiếu vải băng|Những vết thương lúc tập không được băng đúng cách vì thiếu vật tư.|Mua vải băng quân y|Trưng vật tư trong dân|Đợi kỳ cấp phát sau
1|Đội hình giữ cầu hẹp|Một tướng xin diễn tập đội hình mới để giữ những cầu trọng yếu.|Cấp tiền diễn tập có giám sát|Cho tướng tự chọn quân tập|Chưa đổi đội hình cũ
2|Lính vận lương mắc đường|Đội xe quân lương bị chậm, các trạm ở phía trước đang cắt phần ăn.|Xuất kho tiếp tế đường khác|Trưng lương từ huyện gần|Cho các trạm chịu thiếu
0|Mũ sắt sai kích cỡ|Lô mũ mới quá rộng với nhiều tân binh, việc luyện tập bị gián đoạn.|Mua và sửa mũ phù hợp|Trưng dụng vật tư địa phương|Buộc dùng tạm mũ cũ
1|Trinh sát vùng rừng rậm|Một đội xin thử cách luân phiên trinh sát để giảm chỗ mù quanh biên ải.|Cấp phí cho chuyến thử|Trao thêm quyền cho tướng|Giữ tuyến trinh sát cũ
2|Bếp quân dập lửa sớm|Bếp trong doanh không còn đủ lương thực để nấu đủ hai bữa.|Xuất thóc giữ bếp quân|Lấy lương từ làng quanh doanh|Cắt bớt bữa trong doanh
0|Lính mới bị giữ phụ cấp|Người phụ trách cấp phát chậm tiền, tân binh bắt đầu bỏ buổi tập.|Chi khoản hỗ trợ trực tiếp|Trưng nguồn lực từ địa phương|Đợi kiểm tra xong mới cấp
1|Bãi tập phòng thủ ven sông|Trấn thủ xin dựng bãi tập để luyện giữ bến trước quân đối phương.|Cấp phí diễn tập ven sông|Cho tướng tự điều phối lực lượng|Chưa dựng bãi tập
2|Kho đồn lẫn thóc mốc|Người giữ kho báo phần thóc ăn được không đủ cho kỳ trực mới.|Xuất lương thay thóc hỏng|Trưng thêm lương dân quanh đồn|Chia nhỏ phần thóc còn tốt
0|Xe kéo pháo hỏng trục|Những xe quân dụng không kéo được tải chuẩn, đội thợ xin tiền thay trục.|Mua trục và sửa xe|Trưng dụng xe vật tư của dân|Chưa sửa xe đồng loạt
1|Đội cứu viện đi đường đêm|Một chỉ huy đề nghị tập cách chuyển quân ban đêm để phản ứng sớm hơn.|Cấp phí tập có kiểm soát|Cho tướng tự điều quân ban đêm|Giữ cách chuyển quân cũ
2|Lương quân tới sai đơn vị|Một đồn nhận nhầm thóc của đồn khác, cả hai đều báo phần ăn thiếu.|Xuất lương vá hai đồn|Trưng lương tạm trong dân|Chờ sổ điều chuyển được sửa
0:weakArmy|Những hàng quân thưa dần|Tướng lĩnh báo lực lượng giảm, trang bị cũ khiến người còn lại càng khó giữ đồn.|Chi tiền bổ sung trang bị|Trưng thêm nguồn lực dân sự|Chưa bổ sung quân trang
1:war|Tin trinh sát trước trận lớn|Trinh sát xin mở chuyến dò đường có rủi ro trước khi đối phương tiến quân.|Cấp phí cho chuyến trinh sát|Trao tướng quyền tự triển khai|Không dò đường trước trận
2:war|Lương thực cho quân bị vây|Một đơn vị bị ép vào đồn hẹp, cần thêm lương để chờ đường viện mở.|Xuất kho tiếp tế đồn|Trưng lương dân sát chiến tuyến|Bỏ phần tiếp tế tuần này
0:peace|Quân dự bị xin tập lại|Lực lượng dự bị lâu không tập, người chỉ huy xin trang bị cho một đợt ôn luyện.|Cấp tiền cho đợt tập|Trưng dụng nguồn lực địa phương|Để quân dự bị chờ lệnh
1:war|Lối rút khỏi thung lũng|Một đội tiên phong muốn thử mở lối rút để tránh bị khóa trong thung lũng.|Cấp phí mở đường thử|Cho tướng quyết việc điều quân|Chưa mở lối dự phòng
2:weakArmy|Suất ăn của quân tái ngũ|Những người trở lại đội ngũ chưa nhận đủ phần ăn, tinh thần trong trại đang xuống.|Xuất lương đón quân trở lại|Trưng phần ăn của làng gần|Để đơn vị tự cân phần
''',
  'diplomacy': '''
0|Sứ đoàn bị giữ ở cửa ải|Nước láng giềng giữ đoàn sứ vì bất đồng giấy thông hành, đòi một lời giải thích.|Gửi đoàn thương lượng giải vây|Dọa đưa quân tới cửa ải|Chưa trả lời công hàm
1|Bến chung bên sông giới|Thương nhân hai nước muốn góp vốn lập bến chung nhưng chưa rõ quyền thu phí.|Thử bến chung có kiểm toán|Thu phí cao với thuyền ngoại|Đóng đề nghị mở bến
2|Mốc đá bị dời trong đêm|Dân biên báo một mốc đá đổi chỗ, lính hai phía đã đứng đối diện nhau.|Mời chứng nhân xác định mốc|Điều quân chiếm lại bãi đất|Để các đồn tự xử
0:war|Lời đề nghị ngừng bắn ngắn|Đối phương xin ngừng bắn để thu xác, tướng trong triều nghi đó là kế hoãn binh.|Cử sứ kiểm chứng thỏa thuận|Đáp bằng tối hậu thư|Không phản hồi đề nghị
1|Đường buôn qua cao nguyên|Một nước nhỏ cho mở đường qua núi nếu triều đình cùng gánh phí trạm.|Góp vốn thử tuyến đường|Đánh thuế hàng qua tuyến|Chưa mở đường buôn mới
2|Ngư dân vượt đường nước|Hai bên cùng bắt ngư dân của nhau ở khúc sông chưa phân định.|Bảo lãnh và lập vùng đánh cá|Tăng quân tuần sông|Để tranh chấp kéo dài
0|Quà ngoại giao bị hiểu lầm|Lễ vật mang hình thú bị một triều đình xem là lời mỉa mai, sứ giả xin chỉ dụ.|Cử người giải thích dụng ý|Khẳng định họ phải nhận quà|Bỏ qua thư phản đối
1|Xưởng nhuộm của khách ngoại|Thợ ngoại xin cùng mở xưởng và truyền nghề nếu được bảo vệ vốn ban đầu.|Góp vốn xưởng thử nghiệm|Thu phí đặc quyền nhập nghề|Không tiếp lời mời hợp tác
2|Đoàn hộ tống đi lạc|Lính hộ tống nước bạn đi qua làng biên giới khiến dân địa phương sợ hãi.|Thỏa thuận lối đi và bồi hoàn|Đặt quân chặn các lối mòn|Để làng tự thương lượng
0:war|Tin đổi tù binh|Đối phương gửi danh sách đổi tù nhưng nhiều tên chưa được xác nhận còn sống.|Chi phí xác minh và đàm phán|Đòi trao người ngay lập tức|Gác việc đổi tù binh
1|Hội chợ mùa lạnh|Nước bạn mời góp phần tổ chức hội chợ chung trước mùa đường núi đóng tuyết.|Góp vốn gian hàng và vận tải|Thu phụ phí hàng nhập hội chợ|Không dự hội chợ năm nay
2|Khách tị nạn bên cột mốc|Một nhóm dân xin qua biên, bên kia đòi trả người mà chưa nêu chứng cứ.|Bảo đảm an toàn và xét hồ sơ|Tăng quân ở trạm biên|Để họ chờ ngoài biên giới
0|Tranh thứ bậc trong quốc thư|Hai nước bất đồng cách xưng hô, chuyến sứ sắp bị hủy vì một hàng chữ.|Cử người tìm thể thức chung|Giữ lời lẽ cứng rắn|Chưa gửi lại quốc thư
1|Kho chuyển hàng đường biển|Một hải cảng ngoại đề nghị dành kho cho hàng của triều đình nếu cùng đầu tư.|Góp tiền thử kho chung|Đánh thuế cao hàng cảng ngoại|Bỏ đề nghị kho chuyển hàng
2|Kẻ truy đuổi qua biên|Lính láng giềng vượt ranh giới đuổi cướp và làm dân làng hoảng loạn.|Ký quy tắc truy bắt có bảo chứng|Tăng quân chặn biên|Chưa nêu ý kiến chính thức
0|Sứ thần mắc nợ nhà trọ|Đoàn sứ bị chủ trọ giữ hành lý, tin đồn tổn hại thể diện hai triều.|Cử người dàn xếp khoản nợ|Đòi thả hành lý bằng uy thế|Mặc đoàn sứ tự giải quyết
1|Giống vật nuôi trao đổi|Nước bên kia muốn đổi đàn giống lấy quyền phân phối sản vật tại một trạm.|Đầu tư thí điểm trao đổi giống|Thu phí ngay từ thương lái ngoại|Chưa tham gia trao đổi
2|Đền cổ nằm giữa hai nước|Khách hành hương hai phía tranh quyền vào đền khi lính địa phương thu phí.|Bảo chứng quyền đi lại chung|Tăng đồn kiểm soát quanh đền|Để xung đột tự lắng xuống
0:war|Đồng minh xin xác nhận lời hứa|Một nước từng hứa hỗ trợ nay yêu cầu đàm phán lại điều kiện xuất quân.|Gửi sứ thương lượng điều kiện|Dùng lời đe dọa ép thực hiện|Chưa trả lời đồng minh
1|Trạm đổi tiền cho khách ngoại|Thương khách muốn mở trạm đổi tiền có vốn triều đình để giảm giả mạo.|Góp vốn thử trạm đổi tiền|Đánh phụ thu tiền ngoại|Giữ cách đổi tiền tự phát
2|Công chúa nước bạn quá cảnh|Đoàn quý tộc xin quá cảnh đúng tuyến quân sự, hai bên nghi ngờ nhau.|Trả phí bảo đảm tuyến riêng|Tăng quân giữ toàn tuyến|Để đoàn chờ chỉ dụ khác
0|Đòi trả tấm bản đồ cũ|Một triều đình nói bản đồ trong thư viện là tài sản của họ và đòi trả lại.|Đàm phán quyền sao chép chung|Tuyên bố giữ bằng mọi giá|Không đáp thư đòi bản đồ
1|Hiệp hội thuyền buôn liên quốc|Các chủ thuyền muốn lập quỹ cứu nạn chung đổi lấy quyền cập bến thuận tiện.|Góp vốn thí điểm quỹ chung|Thu phí bảo hộ cao hơn|Không tham gia quỹ liên quốc
2|Lễ tế trên đỉnh núi giới|Hai bên cùng định tế lễ tại một đỉnh núi, đội hộ vệ có nguy cơ đụng độ.|Bảo chứng lịch lễ luân phiên|Đưa quân giữ đỉnh núi|Để mỗi bên tự lên núi
0:peace|Tin đồn nước bạn chuẩn bị chiến|Thương khách báo giá sắt tăng bên kia biên, quan ngoại giao xin thăm dò kín.|Gửi sứ kiểm chứng tin đồn|Công khai cảnh cáo nước bạn|Chưa điều tra tin đồn
1|Thợ đóng tàu muốn hợp tác|Một đoàn thợ ngoại mang bản vẽ mới nhưng cần vốn để đóng chiếc đầu tiên.|Cùng đầu tư tàu thử|Thu tiền quyền vào xưởng|Từ chối dự án hợp tác
2:war|Bảo đảm cho hành lang cứu trợ|Hai bên đều muốn chở lương qua chiến tuyến nhưng chưa tin lời hứa của nhau.|Chi tiền lập bảo chứng chung|Điều quân giữ hành lang riêng|Đình lại hành lang cứu trợ
''',
  'justice': '''
0|Con nhà quyền thế cán người|Gia đình nạn nhân xin xét xử công khai sau khi lính hầu tìm cách ém đơn.|Đích thân mở phiên xét xử|Phạt tiền gia đình quyền thế|Để đơn chờ ở nha môn
1|Người trộm bánh nuôi con|Một người mẹ lấy bánh lúc đói, dân và quan tranh luận giữa phép nước và lòng thương.|Chuộc lỗi bằng cứu trợ|Áp án nghiêm để răn đe|Không quyết án lần này
2|Nhân chứng đổi lời khai|Nhân chứng trong vụ mất đất bất ngờ rút lời sau khi nhận quà từ nhà giàu.|Chi tiền bảo vệ và điều tra|Hòa giải theo đề nghị các bên|Gác lại lời khai mâu thuẫn
0|Cọc ruộng bị nhổ|Một nhà thế gia bị tố dời cọc ruộng của cả xóm, quan huyện không dám xử.|Mở phiên đối chất trước dân|Nhận khoản phạt để khép vụ|Chuyển đơn về huyện cũ
1|Kẻ đào ngũ trở về chịu tội|Người lính nói đã bỏ trại để đưa cha tránh lũ, nay tự đến xin xét.|Cấp phí chuộc lỗi và giảm án|Xử nghiêm tội đào ngũ|Chưa công bố bản án
2|Ấn huyện trên giấy giả|Nhiều tờ thuế có dấu thật nhưng chữ khác nhau, dân không biết phải nộp cho ai.|Điều tra nguồn giấy và con dấu|Thỏa thuận mức nộp tạm|Để huyện tự thu tiếp
0|Đầy tớ kiện chủ đánh đập|Một gia nhân trốn vào kinh xin xử chủ nhà quyền quý vì đánh người đến tàn phế.|Mở án xét cả người quyền quý|Nhận bồi thường để khép án|Không thụ lý đơn vượt cấp
1|Đám đông đập kho đầu cơ|Dân phá cửa một kho giữ gạo, chủ kho đòi trị tội toàn bộ người tham gia.|Cứu trợ và khoan tội có điều kiện|Áp án nặng với đám đông|Để địa phương tự định tội
2|Hai người nhận cùng di chúc|Một gia đình trình hai di chúc trái ngược, mỗi bên đều có người làm chứng.|Cấp phí giám định hồ sơ|Hòa giải chia tài sản tạm|Chưa xác định người thừa kế
0|Quan trạm đánh người đưa thư|Một người đưa thư bị đánh vì giao đơn tố cáo nhà thế gia đúng ngày lễ.|Đích thân xét hành vi cản đơn|Nhận phạt tiền thay xét xử|Gác đơn sang kỳ sau
1|Thợ phá máy để giữ nghề|Thợ bị mất việc đập máy xay mới, chủ xưởng muốn dùng hình nặng làm gương.|Bồi hoàn và cho chuộc lỗi|Xử nghiêm hành vi phá xưởng|Chưa phân xử tranh chấp
2|Nhà tù báo thiếu một người|Sổ ghi đủ tù nhưng phòng giam thiếu người, lính canh đổ lỗi cho nhau.|Điều tra và kiểm tra lại sổ|Dàn xếp trách nhiệm giữa các đội|Chờ nhà tù tự báo lại
0|Đường làng bị dựng cổng riêng|Một dòng họ quyền quý dựng cổng thu tiền trên lối dân đi đã nhiều đời.|Xét quyền đi lại công khai|Phạt tiền để cho giữ cổng|Chưa động đến cổng thu phí
1|Người đánh chuông báo cháy sai|Một đứa trẻ gây hỗn loạn vì tưởng sương là khói, quan xin phạt để giữ lệnh.|Giúp gia đình và cho chuộc lỗi|Áp án nghiêm vì báo động sai|Không công bố cách xử
2|Chứng vật biến mất ở nha môn|Túi tiền làm bằng chứng thất lạc đúng lúc sắp xét vụ tham ô.|Chi tiền truy tìm chứng vật|Hòa giải để kết thúc vụ án|Xếp vụ án chờ chứng cứ
0|Phu trạm kiện bị giữ tiền công|Phu trạm nói quản sự nhà quyền thế giữ hết tiền vận chuyển do vua cấp.|Mở phiên đối chất tiền công|Nhận khoản phạt từ nhà quản sự|Để phu trạm chờ huyện xử
1|Tù nhân cứu người coi ngục|Một tù nhân phá khóa cứu lính canh khỏi cháy, nay xin xét lại hình phạt.|Giảm án và cấp phí tái hòa nhập|Giữ án để bảo vệ phép nước|Chưa trả lời đơn xin giảm
2|Lời tố cáo giữa hai làng|Mỗi làng cáo buộc làng kia đầu độc giếng, chưa có chứng cứ rõ ràng.|Cấp phí điều tra nguồn nước|Tổ chức hòa giải tạm|Để hai làng tự tìm chứng cứ
0|Bản án chỉ dành cho người nghèo|Hai người cùng phạm lỗi nhưng con nhà giàu được bỏ qua, dân kéo đến cửa triều.|Xét lại cả hai bản án|Phạt tiền nhà giàu cho xong|Không mở lại hồ sơ
1|Nông dân đốt sổ nợ|Một nhóm dân đốt giấy vay sau mùa mất trắng, chủ nợ yêu cầu xử thật nặng.|Cứu trợ và cho chuộc lỗi|Thi hành hình phạt nghiêm|Trì hoãn quyết định
2|Thầy thuốc bị tố dùng độc|Gia đình bệnh nhân tố thầy thuốc đầu độc nhưng người chữa bệnh nói là tai biến.|Mời người độc lập điều tra|Dàn xếp bồi thường đôi bên|Chưa xét vụ thầy thuốc
0|Đòi người làm để trừ nợ|Một nhà quyền quý giữ con của người mắc nợ, dân cho rằng trái phép triều đình.|Xét việc giữ người công khai|Nhận tiền phạt để khép hồ sơ|Để chủ nợ tự giải quyết
1|Kẻ trộm nộp lại đồ thất lạc|Người từng trộm đồ của triều đình tự mang trả và xin cơ hội làm lại.|Cho chuộc lỗi có hỗ trợ|Giữ hình phạt cũ để răn đe|Chưa xét lời tự thú
2|Lời khai dưới ép cung|Một viên lại thừa nhận đã ép người ký nhận tội, hồ sơ cũ có thể sai hàng loạt.|Chi tiền điều tra lại hồ sơ|Hòa giải và sửa vài bản án|Đóng việc xét lại hồ sơ
0:lowPeople:rebellion_warning|Dân đội đơn trước cửa thành|Đám đông đòi xét quan bao che nhà giàu và nói sẽ không rời cổng nếu bị bỏ qua.|Đích thân mở phiên xét xử|Phạt tiền nhà giàu để giải tán|Để đơn nằm ngoài cửa thành
1:lowPeople:rebellion_warning|Người bị bắt sau cuộc đòi gạo|Gia đình những người bị bắt tụ lại, xin phân biệt kẻ cướp với người đói.|Cứu trợ và khoan tội có điều kiện|Xử nghiêm cả nhóm gây rối|Chưa giải quyết người bị bắt
2:lowPeople:rebellion_warning|Quan địa phương giấu đơn dân|Một đoàn dân vượt cấp nói đơn đã bị giữ nhiều tháng, lòng tin sắp cạn.|Cấp phí điều tra việc giấu đơn|Cho các bên hòa giải tạm|Trả đoàn dân về chờ tiếp
''',
  'bureaucracy': '''
0|Hai bộ cùng giữ một hồ sơ|Công việc đứng lại vì hai bộ đều nói mình có quyền duyệt cuối cùng.|Tự phân quyền và sửa quy trình|Bán quyền phê duyệt cho nhà bảo trợ|Để hai bộ tiếp tục tranh quyền
1|Lịch trực quan chồng chéo|Hai nhóm quan được xếp trực cùng buổi, không ai chịu nhường vị trí.|Chi phí họp thống nhất lịch|Dùng mệnh lệnh ép một lịch|Để triều thần tự thu xếp
2|Sổ chi mua đèn tăng gấp bội|Lượng đèn không đổi nhưng tiền mua tăng, các phòng cùng đổ lỗi cho giá dầu.|Cấp phí kiểm toán khoản mua|Nhận khoản nộp để bỏ kiểm tra|Để sổ chi được duyệt tiếp
0|Chỉ dụ bị sao thành hai bản|Hai địa phương nhận hai bản chỉ dụ khác nhau khiến việc thu thuế bị đình lại.|Đích thân chuẩn hóa việc sao chỉ|Giao quyền sao cho nhà có tiền|Chưa sửa cách ban chỉ dụ
1|Ghế ngồi trong buổi chầu|Quan Văn và quan Võ tranh ghế đứng gần ngai, việc nghị chính bị kéo dài.|Chi phí nghị bàn phép chầu chung|Ép theo nghi thức quân lệnh|Mặc các phe tự sắp ghế
2|Kho giấy hao bất thường|Giấy mua cho triều đình nhanh hết nhưng văn bản phát đi không tăng.|Mở kiểm toán kho giấy|Nhận tiền bù từ nhà cung cấp|Tiếp tục mua giấy như cũ
0|Mệnh lệnh đến sau thời hạn|Các công văn thường đến nơi khi việc đã qua, người chuyển thư xin sửa khâu ký.|Tự cắt bớt vòng trình ký|Nhượng quyền chuyển thư lấy tiền|Giữ số vòng ký hiện tại
1|Đại thần bất đồng giờ chầu|Một nhóm muốn chầu sớm, nhóm khác nói quan xa không kịp đến kinh.|Họp thống nhất giờ chầu|Ép áp dụng giờ mới ngay|Để mỗi nhóm tới theo giờ riêng
2|Tiền sửa công đường mất dấu|Công đường vẫn dột dù đã nhận đủ tiền, hồ sơ thanh toán có nhiều dấu xóa.|Chi phí kiểm toán dự án|Nhận tiền trả bù để khép sổ|Chưa kiểm tra công đường
0|Con dấu đi theo người nghỉ|Một quan mang ấn về quê dưỡng bệnh khiến phòng không duyệt được việc.|Sửa quy tắc bàn giao ấn|Cho nhà bảo trợ giữ quyền duyệt|Đợi quan ấy quay lại
1|Bản tấu chen nhau trình vua|Các quan cùng xin ưu tiên tấu của mình, chuyện khẩn bị lẫn với việc thường.|Chi phí lập thứ tự nghị bàn|Ép ưu tiên theo quân lệnh|Để các quan tự tranh lượt
2|Tên người nhận bổng bị lặp|Một số tên xuất hiện trong hai sổ bổng, người coi sổ nói chỉ là trùng họ.|Cấp phí soát lại danh sách|Nhận tiền hoàn để thôi tra|Duyệt sổ bổng chưa đối chiếu
0|Mẫu biểu mỗi huyện một kiểu|Dữ liệu mùa vụ không ghép được vì mỗi huyện dùng đơn vị và mẫu khác nhau.|Tự chuẩn hóa mẫu và đơn vị|Giao việc thống kê cho nhà thầu|Để các huyện gửi mẫu cũ
1|Quan mới không được bàn việc|Người mới bị chặn phát biểu vì chưa theo lệ cũ, triều đình chia thành hai nhóm.|Tổ chức phiên thống nhất quy tắc|Ra lệnh buộc mọi người tuân theo|Để lệ cũ tự quyết tiếng nói
2|Ngựa trạm có tên nhưng không có thật|Sổ chi nuôi ngựa đủ đàn trong khi chuồng chỉ còn một nửa.|Cấp tiền kiểm tra thực địa|Thu khoản bù từ người bảo trợ|Duyệt tiếp khoản nuôi ngựa
0|Việc khẩn nằm dưới chồng tấu|Công văn khẩn bị xếp theo ngày đến, người thư lại không dám đổi thứ tự.|Đích thân sửa luồng xử lý khẩn|Nhượng quyền ưu tiên lấy phí|Giữ cách xếp công văn cũ
1|Quan xin nghỉ cùng một dịp|Nhiều đại thần cùng xin vắng, nhóm ở lại cho rằng mình bị đẩy hết việc.|Họp chia lịch và cấp hỗ trợ|Dùng mệnh lệnh buộc trực|Chưa phân lại lịch làm việc
2|Tiền công sứ bị khai trùng|Một chuyến công cán được kê ở nhiều bộ, các chữ ký đều đúng thẩm quyền.|Cấp phí đối chiếu chứng từ|Nhận tiền hoàn để kết thúc|Để các bộ tự quyết khoản chi
0|Chức trách bị bỏ trống giữa hai bộ|Một nhiệm vụ không ai nhận vì không ghi rõ trong lệ phân công cũ.|Tự xác định trách nhiệm mới|Giao quyền xử lý cho nhà tài trợ|Chờ các bộ tự nhận việc
1|Quan địa phương chống lệnh luân chuyển|Một nhóm quan xin giữ địa hạt, nhóm khác nói không đổi sẽ sinh cục bộ.|Chi phí nghị bàn cách luân chuyển|Ép luân chuyển bằng lệnh quân|Để các nhóm tự thương lượng
2|Vật tư nhập kho thiếu cân|Phiếu ghi đủ cân nhưng lính kho báo hàng nhận nhẹ hơn nhiều.|Cấp phí kiểm định vật tư|Nhận khoản bồi hoàn kín|Chưa soát lại nhà cung ứng
0|Quyền ký thay không rõ ràng|Một quyết định bị hủy vì người ký thay không có văn bản ủy quyền.|Tự lập quy tắc ký thay|Bán quyền đại diện cho nhà bảo trợ|Tiếp tục theo lệ truyền miệng
1|Tiếng nói của quan xa kinh|Quan địa phương nói chỉ được nghe quyết định sau khi các phe ở kinh đã chốt.|Chi phí tổ chức phiên nghị chung|Ép thực hiện quyết định hiện có|Để quan xa tự gửi phản đối
2|Khoản chi lễ nghi không có biên nhận|Bộ phận lễ nghi xin thanh toán một khoản lớn chỉ bằng lời chứng của quản sự.|Mở kiểm toán khoản chi lễ|Nhận khoản trả bù để thôi xét|Phê sổ chi thiếu biên nhận
0|Hồ sơ phải trình lại từ đầu|Một người dân phải nộp lại đơn vì đổi quan duyệt, khiến nhiều việc không bao giờ xong.|Tự sửa phép chuyển hồ sơ|Bán quyền xử nhanh cho nhà bảo trợ|Giữ phép trình lại hồ sơ
1|Quan chuyên môn bị gạt ngoài cuộc|Một nhóm quan không cho người hiểu việc tham dự vì người ấy thuộc nhóm khác.|Chi phí thống nhất cách mời nghị|Ép nghị theo mệnh lệnh|Để nhóm cũ tự chọn người dự
2|Tiền thuê người chép sổ tăng vọt|Tên người chép sổ dài hơn số bàn làm việc, quan coi phòng chưa giải thích rõ.|Cấp phí kiểm toán nhân công|Nhận khoản hoàn để khép sổ|Duyệt tiền thuê chưa đối chiếu
''',
  'factions': '''
0|Văn Võ tranh quyền coi trạm|Quan Văn muốn giữ sổ trạm, quan Võ muốn tự điều xe ngựa để khỏi chậm quân.|Chi phí lập quyền giám sát chung|Giao trạm cho phe Võ|Chưa phân xử quyền coi trạm
1|Họ vua và thế gia tranh đất lễ|Hai nhóm cùng nhận quyền quản một khu đất dùng cho lễ lớn.|Đích thân xét theo lệ chung|Cho thế gia nhận đất và nộp tiền|Để hai bên tự giữ đất
2|Gia phả cũ bị đem bàn tán|Một bản gia phả được truyền tay với lời nghi ngờ về chính thống của ngôi vua.|Công bố hồ sơ có kiểm chứng|Nhượng việc nội triều cho hoàng tộc|Không đáp lời bàn tán
0|Ai được giữ kho vũ khí|Quan Văn đòi kiểm kê, quan Võ nói kiểm kê giữa kỳ tập sẽ cản việc quân.|Lập tổ kiểm kê chung có kinh phí|Cho phe Võ toàn quyền giữ kho|Hoãn phân xử chuyện kho
1|Suất học cho con nhà danh giá|Hoàng tộc và thế gia đều muốn được ưu tiên số suất học có hạn.|Tự áp tiêu chuẩn chung|Cho thế gia mua quyền ưu tiên|Chưa định cách chia suất
2|Lời thề của người kế vị cũ|Một nhánh hoàng tộc nhắc lại lời hứa truyền ngôi trước đây để gây ảnh hưởng.|Làm rõ tính hợp lệ của chiếu cũ|Nhượng quyền nội triều cho hoàng tộc|Để lời thề tiếp tục lan
0|Tấu xin giám sát quân lương|Phe Văn muốn kiểm soát sổ lương, phe Võ lo việc cấp phát bị chậm.|Chi phí xây cơ chế giám sát chung|Trao toàn quyền cho tướng giữ lương|Để hai phe tự tranh sổ
1|Quyền mở đoàn săn mùa thu|Hoàng tộc nhận đó là truyền lệ, thế gia nói họ đã trả tiền chuẩn bị.|Tự xét quyền theo quy định chung|Nhận tiền và ưu tiên thế gia|Mặc hai nhóm giành đoàn săn
2|Bài ca ca ngợi một thân vương|Một bài ca lưu truyền tôn thân vương hơn nhà vua, các quan xin chỉ dụ.|Làm rõ chính thống bằng chứng cứ|Nhượng quyền sắp việc trong cung|Không phản ứng với bài ca
0|Tranh người phụ trách cứu hộ|Phe Văn đề nghị quan dân sự, phe Võ muốn giao tướng vì có quân sẵn.|Cấp phí phối hợp hai bên|Giao hẳn cho phe Võ|Để tranh người phụ trách kéo dài
1|Ghế chủ lễ của hai dòng họ|Hai dòng họ lớn tranh ghế chủ lễ và cùng mang người tới điện.|Đích thân áp phép lễ chung|Nhận tài trợ để ưu tiên thế gia|Không quyết ghế chủ lễ
2|Lời đồn ngai vàng được vay|Kẻ lạ nói việc lên ngôi nhờ một lời hứa bí mật mà vua chưa thực hiện.|Chi phí xác minh và công bố chiếu|Giao thêm quyền cho hoàng tộc|Bỏ qua lời đồn về ngai
0|Quan Văn phản đối đoàn duyệt binh|Quan Văn muốn giảm chi, quan Võ nói hủy duyệt binh là xem nhẹ quân đội.|Chi phí tìm phương án hai bên|Dùng uy quyền giữ kế hoạch phe Võ|Chưa quyết lịch duyệt binh
1|Người bảo trợ đòi đặt tên cầu|Hoàng tộc muốn tên tổ tiên, thế gia tài trợ muốn tên dòng họ mình.|Tự xét tên theo phép chung|Nhận tiền và thuận tên thế gia|Để hai bên tự treo biển
2|Một biểu chương xin vua nhường quyền|Một nhóm quan nói vua còn trẻ và muốn hoàng tộc thay xử việc một thời gian.|Củng cố chính thống bằng chiếu rõ|Giao thêm quyền điều phối cho hoàng tộc|Không trả lời biểu chương
0|Quyền bổ nhiệm người giữ biên|Hai phe đưa hai người khác nhau, ai cũng nói chỉ phe mình hiểu biên giới.|Chi phí lập cơ chế cùng giám sát|Theo đề xuất của phe Võ|Để chức trách tiếp tục tranh chấp
1|Hội đồng họ tộc xin miễn lệ|Hoàng tộc và thế gia cùng đòi đặc quyền nhưng không muốn bên kia được hưởng.|Tự tuyên bố áp lệ chung|Thu tiền và cho thế gia ưu tiên|Chưa trả lời đòi đặc quyền
2|Kỷ vật vua trước xuất hiện|Một kỷ vật bị dùng làm bằng chứng rằng có người khác từng được chọn nối ngôi.|Chi phí kiểm chứng kỷ vật|Nhượng quyền nội triều cho hoàng tộc|Để kỷ vật bị diễn giải tùy ý
0|Hai phe tranh cách đọc quân báo|Quan Văn muốn kiểm chứng tin, quan Võ đòi phản ứng ngay trước khi đối thủ biết.|Chi phí lập nhóm đọc báo chung|Theo đề nghị cứng rắn của phe Võ|Không chọn cách xử lý quân báo
1|Quyền dùng bến dành cho triều đình|Thế gia và hoàng tộc cùng đưa thuyền vào bến riêng rồi cáo nhau lấn quyền.|Tự xét theo quy tắc chung|Nhận phí và ưu tiên thuyền thế gia|Để hai bên tự tranh bến
2|Dấu hiệu trên thiên tượng|Một nhóm người giải thích sao lạ là điềm thay ngôi, hoàng tộc xin thêm quyền trấn an.|Chi phí công bố lời giải có chứng cứ|Giao thêm việc nội triều cho hoàng tộc|Không đáp chuyện thiên tượng
0:factionSplit|Hai phe cùng tẩy chay nghị chính|Phe Văn và phe Võ chỉ chịu dự chầu nếu bên kia nhượng quyền trước.|Chi phí lập thỏa thuận nghị chung|Dùng uy quyền thiên về phe Võ|Để buổi nghị tiếp tục đình lại
1:factionSplit|Lễ vật chia triều thành hai nhóm|Hai phe lớn tranh quyền nhận lễ vật và công khai chỉ trích nhau giữa điện.|Tự áp phép phân xử chung|Nhận tiền và thuận ý thế gia|Mặc các phe giữ lễ vật
2:factionSplit|Một phe muốn đứng giữa nhà vua|Một nhóm hoàng tộc đề nghị mọi chỉ dụ phải qua họ để tránh xung đột phe phái.|Củng cố quyền ban chỉ bằng chứng cứ|Cho hoàng tộc quyền điều phối|Chưa đáp đề nghị giữ chỉ dụ
2:weakAuthority:succession_rumor|Chiếu nhường quyền được viết sẵn|Một bản chiếu chưa có ấn vua đã xuất hiện trong các cuộc họp kín.|Chi phí xác minh và bác chiếu giả|Nhượng quyền nội triều để dàn xếp|Không đụng tới bản chiếu
2:weakAuthority:succession_rumor|Thân vương mở buổi nhận lời chúc|Một thân vương cho mở nghi lễ gần giống lễ đăng cơ, khiến quan lại xôn xao.|Công bố chiếu xác nhận chính thống|Nhường thêm quyền cho hoàng tộc|Để nghi lễ tiếp tục diễn ra
2:weakAuthority:succession_rumor|Danh sách người ủng hộ đổi ngôi|Một danh sách ký tên lan trong triều, chưa rõ ai bị giả tên và ai thật sự tham gia.|Cấp phí xác minh và khẳng định ngôi vua|Dàn xếp bằng quyền cho hoàng tộc|Không trả lời danh sách
''',
  'security': '''
0|Thư không ký tên trong bếp|Một thư nặc danh báo có người đổi gia vị trong bếp nhưng chưa nêu chứng cứ.|Cấp phí điều tra kín|Khám xét rộng các khu bếp|Bỏ qua thư nặc danh
1|Lính gác bị dụ rời cổng|Một lính gác nhận lời nhắn giả gọi đi, cổng phụ trống trong một đoạn canh.|Cấp phí bảo vệ và đổi quy trình|Thanh trừng người bị nghi|Giữ cách gác cổng cũ
2|Quản sự thu tiền qua cửa kín|Người có tiền được đi qua cửa phụ không ghi sổ, thị vệ xin vua xem xét.|Tự kiểm tra lối đi bí mật|Nhận tiền để giữ lệ cửa phụ|Chưa kiểm tra cửa kín
0|Chén bạc có dấu mài mới|Người rửa chén thấy đáy một chén bạc bị mài khác những chiếc còn lại.|Điều tra nguồn gốc chiếc chén|Khám xét những người phục vụ|Dùng chén như chưa có chuyện
1|Thợ khóa báo mất chìa mẫu|Chìa mẫu của một hành lang gần ngự phòng biến mất khỏi xưởng.|Cấp phí bảo vệ và thay cách giữ chìa|Bắt hàng loạt người bị nghi|Giữ các khóa đang dùng
2|Giấy thông hành được bán kín|Một người môi giới rao giấy vào cung có dấu thật nhưng không có tên người cấp.|Tự kiểm tra đường dây giấy phép|Nhận tiền và giữ đường cấp giấy|Chưa xét nguồn giấy thông hành
0|Người nếm thức ăn vắng mặt|Người phụ trách nếm món ăn bỗng mất tích trước buổi tiệc có nhiều khách.|Cấp phí điều tra kín|Khám xét toàn đội phục vụ|Tiếp tục tiệc theo lệ cũ
1|Dây neo thuyền ngự bị cắt|Thị vệ thấy một đoạn dây neo mỏng khác thường trước chuyến đi sông.|Cấp phí bảo vệ chuyến đi|Thanh trừng nhóm giữ thuyền|Không sửa quy trình bảo vệ
2|Khách lạ được dẫn qua vườn ngự|Một quản sự đưa khách không ghi tên qua đường vua thường đi dạo.|Tự kiểm tra việc dẫn khách|Nhận tiền để cho giữ lối riêng|Để quản sự tự định khách
0|Lưỡi dao trong kiện vải|Người nhận hàng phát hiện dao ngắn nằm trong kiện vải gửi vào cung.|Cấp phí lần theo nguồn kiện hàng|Khám xét rộng các kho hàng|Cho qua vì chưa ai bị hại
1|Lịch đi của vua bị lộ|Một người bán hàng ngoài thành biết chính xác giờ vua dự định ra ngoài.|Chi phí bảo vệ và đổi lịch|Thanh trừng người giữ lịch|Giữ nguyên lịch đi công khai
2|Lính canh bán ca trực|Một số ca gác gần điện được chuyển cho người lạ bằng tiền riêng.|Tự kiểm tra danh sách trực|Thu tiền để bỏ qua việc đổi ca|Để các đội tự đổi người
0|Ấm thuốc có mùi lạ|Thầy thuốc nói vị thuốc gửi đến có mùi khác, kho chưa biết ai đã chạm vào.|Cấp phí điều tra đường thuốc|Khám xét toàn bộ người trong kho|Dùng thuốc chưa kiểm chứng
1|Mái hiên trên lối vua đi bị lỏng|Người thợ báo chốt mái hiên bị rút trước giờ vua qua hành lang.|Cấp phí bảo vệ và gia cố lối đi|Thanh trừng nhóm coi hành lang|Giữ lối đi chưa kiểm tra
2|Người bán quyền gặp riêng|Một thân tín nhận tiền hứa cho khách gặp vua ngoài sổ triều kiến.|Tự kiểm tra các cuộc gặp kín|Nhận khoản nộp để giữ lệ gặp|Chưa xét người bán quyền gặp
0|Mật hiệu đổi nhưng đồn chưa biết|Một trạm gác nhận mật hiệu mới không có chữ ký người phụ trách.|Cấp phí điều tra người gửi|Khám xét người mang mật hiệu|Chấp nhận mật hiệu chưa xác nhận
1|Hộ vệ bị theo dõi ở chợ|Một hộ vệ nhận ra người lạ ghi thói quen đi lại của mình nhiều ngày.|Chi phí bảo vệ đội hộ vệ|Thanh trừng những người bị nghi|Để hộ vệ tự xử việc theo dõi
2|Xe chở hàng không qua kiểm cửa|Một thương nhân được miễn khám xe gần ngự điện nhờ quen quản sự.|Tự kiểm tra lệnh miễn khám|Nhận tiền để giữ lối miễn khám|Chưa động tới lối xe riêng
0|Đèn tín hiệu lạ trên tháp|Thị vệ thấy đèn nháy theo nhịp ở một tháp không có người trực được ghi tên.|Cấp phí theo dấu tín hiệu|Khám xét rộng khu quanh tháp|Bỏ qua vì chưa có chứng cứ
1|Thư đe dọa gia đình thị vệ|Một thị vệ xin đổi vị trí vì gia đình bị đe dọa nếu không mở cổng.|Cấp phí bảo vệ cả gia đình|Thanh trừng nhóm bị nghi liên quan|Để thị vệ tự lo gia đình
2|Bản vẽ ngự phòng bị rao bán|Một người buôn đồ cũ giữ bản vẽ chi tiết hành lang cạnh nơi vua ngủ.|Tự kiểm tra đường rò bản vẽ|Nhận tiền và ngừng truy xét|Chưa kiểm tra nguồn bản vẽ
0:plot|Tin mật về người thay đầu bếp|Có người trả tiền để đưa đầu bếp lạ vào ca phục vụ vua, chưa rõ kẻ đứng sau.|Cấp phí điều tra kín|Khám xét các nhóm phục vụ|Bỏ qua tin về đầu bếp
1:plot|Người xin mở cổng giữa đêm|Một lệnh miệng yêu cầu thị vệ mở cổng dù vua chưa ban chỉ.|Cấp phí bảo vệ và xác minh lệnh|Thanh trừng người bị nghi truyền lệnh|Cho đội gác tự xử
2:plot|Khoản tiền lạ vào nhà quản sự|Quản sự gần vua nhận khoản tiền lớn và không giải thích được nguồn.|Tự kiểm tra khoản tiền và quan hệ|Nhận khoản nộp để thôi tra|Chưa xét khoản tiền lạ
0:plot:plot_warning|Dấu hẹn trong thư chúc thọ|Một bức thư mừng có ký hiệu trùng với lời hẹn của nhóm người đáng nghi.|Chi tiền điều tra kín ký hiệu|Khám xét rộng người mang thư|Để thư chúc thọ vào kho
1:plot:plot_warning|Thuốc ngủ được giấu gần cổng|Thị vệ tìm thấy thuốc ngủ cạnh bình nước của đội trực đêm.|Cấp phí bảo vệ đội trực|Thanh trừng hàng loạt người bị nghi|Giữ cách trực đêm hiện tại
2:plot:plot_warning|Người giữ ấn nhận lời mời kín|Người giữ ấn bị thấy gặp một nhóm đang bàn chuyện đưa người khác lên ngôi.|Tự kiểm tra cuộc gặp và giữ ấn|Nhận tiền để dàn xếp kín|Không xét cuộc gặp người giữ ấn
''',
  'palace': '''
0|Kho vải nội cung thiếu sổ|Đồ dùng trong cung cấp không đều vì kho vải thiếu bản phân bổ rõ ràng.|Cấp tiền sửa phân bổ đồ dùng|Cắt chi và thu hồi vật dụng|Để kho tự chia tiếp
1:hasConsort|Tranh lượt dùng vườn ngự|Các phi tần cùng xin dùng vườn trong một buổi, gia đình họ bắt đầu can thiệp.|Tự áp lịch chung công bằng|Ưu tiên người có thế gia chống lưng|Để các bên tự tranh lượt
2|Một buổi nghe nhạc trong cung|Nội quan xin mở buổi nhạc nhỏ để vua bớt căng thẳng sau nhiều buổi chầu.|Chi cho buổi nhạc ngắn|Dành buổi ấy nghỉ yên|Giữ nhịp làm việc hiện tại
0|Nhà ở của người hầu dột mái|Nội quan nói người hầu thiếu chỗ ngủ khô nhưng khoản sửa chưa được duyệt.|Cấp tiền sửa khu ở trong cung|Cắt chi và gom người vào phòng chung|Chưa sửa khu ở người hầu
1:hasConsort|Quà biếu ngoài sổ cho phi tần|Một gia đình gửi quà riêng khiến các phi tần khác nghi ngờ có trao đổi quyền lợi.|Tự áp phép quà biếu chung|Thuận ý gia đình thế gia|Không xét chuyện quà ngoài sổ
2|Lời mời xem trò múa mới|Một đoàn diễn muốn biểu diễn riêng cho vua, nội quan xin quyết định quy mô.|Chi cho một buổi diễn ngắn|Từ chối để nghỉ tĩnh|Tiếp tục chịu áp lực công việc
0|Đèn trong nội điện tốn dầu|Người quản cung muốn đổi cách chiếu sáng nhưng cần chi phí ban đầu.|Cấp tiền sắp lại đèn trong điện|Thu hồi bớt dầu và đồ dùng|Để nội cung tự xoay dầu
1:hasConsort|Cung nữ bị hai viện cùng gọi|Hai viện cùng đòi một nhóm cung nữ, người trong cung sợ phe mạnh lấn phe yếu.|Tự đặt quy tắc phân người|Ưu tiên viện có thế gia bảo trợ|Để hai viện tự chia người
2|Dạo thuyền trong hồ ngự|Nội quan mời vua rời điện một buổi, nhưng cảnh báo vui quá sẽ khó nghỉ đúng giờ.|Chi cho chuyến dạo ngắn|Dành thời gian ngủ nghỉ|Không đổi lịch sinh hoạt
0|Khẩu phần trong cung bị cắt nhầm|Một số phòng bị thiếu phần ăn trong khi nơi khác nhận gấp đôi.|Cấp tiền sửa việc phân bổ|Cắt tổng chi và thu hồi phần dư|Chưa rà lại khẩu phần
1:hasConsort|Gia đình phi tần xin vào điện riêng|Một nhà muốn vào thăm ngoài giờ quy định khiến các viện khác phản đối.|Tự áp giờ thăm công bằng|Ưu tiên nhà thế gia ấy|Để lời xin đi qua cửa riêng
2|Cuộc thi làm thơ đêm|Nội quan đề nghị một đêm vui thơ để giải khuây, nhưng vua có thể mất giờ ngủ.|Chi cho cuộc vui có giới hạn|Rút lui nghỉ tĩnh một buổi|Giữ sức ép trong điện
0|Rèm ngự điện cần thay|Rèm cũ che gió kém, người quản cung xin thay nhưng nhiều khoản chi đang chờ.|Cấp tiền thay rèm hợp lý|Cắt đồ dùng để bù khoản thiếu|Để rèm cũ qua mùa
1:hasConsort|Chỗ ngồi trong yến nhỏ|Các phi tần tranh thứ tự chỗ ngồi và nhờ quan ngoài triều lên tiếng.|Tự áp nghi thức chung|Ưu tiên phía có thế gia mạnh|Để các bên tự xếp chỗ
2|Trò chơi cờ kéo dài|Một ván cờ trong cung được đề nghị làm dịp giải khuây sau buổi chầu.|Chi cho cuộc chơi ngắn|Dừng chơi để nghỉ tĩnh|Không giải tỏa căng thẳng
0|Người hầu xin áo mùa lạnh|Đồ mùa lạnh phát thiếu, hoàng tộc nói để người trong cung rét là mất thể diện.|Cấp tiền bổ sung áo|Thu hồi bớt đồ để tiết kiệm|Chưa cấp áo mùa lạnh
1:hasConsort|Tin đồn thiên vị người mới|Một phi tần mới được cấp đồ khác lệ khiến các viện còn lại bất bình.|Tự xét theo quy tắc công bằng|Ưu tiên phía thế gia hậu thuẫn|Bỏ qua lời bất bình
2|Buổi xem hoa sau cơn mưa|Nội quan mời vua ngắm hoa, nhắc rằng vui có chừng mực mới giúp hồi sức.|Chi cho buổi xem hoa ngắn|Dành buổi ấy để nghỉ|Tiếp tục lịch căng thẳng
0|Sổ vật dụng hồi môn lẫn lộn|Đồ riêng và đồ triều đình bị ghi chung khiến người quản cung khó phân bổ.|Cấp tiền rà và sắp kho|Cắt chi thu hồi đồ đang dùng|Giữ kho theo sổ lẫn lộn
1:hasConsort|Thư riêng nhờ can thiệp chức vụ|Gia đình một phi tần gửi thư nhờ ưu tiên người nhà, các viện đã nghe chuyện.|Tự áp phép không thiên vị|Thuận đề nghị của thế gia|Để thư riêng không có trả lời rõ
2|Rượu quý dành riêng cho vua|Một vò rượu mới được dâng, nội quan xin mở tiệc nhỏ ngay trong tuần.|Chi cho cuộc vui có giới hạn|Cất rượu để nghỉ yên|Giữ lịch làm việc căng
0|Nội điện thiếu người lo việc chung|Các phòng cùng thiếu vật dụng, quản sự xin một khoản để ổn định sinh hoạt.|Cấp tiền sắp lại việc nội điện|Cắt chi và gom đồ dùng|Để các phòng tự xoay xở
1:hasConsort|Tranh quyền chăm sóc lễ phục|Hai viện muốn đảm nhiệm lễ phục của vua và gọi người nhà ngoài triều trợ lực.|Tự phân xử bằng quy tắc chung|Trao ưu tiên cho thế gia|Để tranh chấp tiếp tục
2:hasConsort|Lời mời dự yến của phi tần|Một phi tần muốn tổ chức yến để vua giải sầu, trong khi lịch nghỉ đã thiếu.|Chi cho một buổi yến ngắn|Xin dành thời gian nghỉ tĩnh|Không đổi lịch căng thẳng
0|Kho hương trong cung phát thiếu|Các phòng nhận lượng hương rất khác nhau, người quản kho xin ổn định lại việc cấp.|Cấp tiền chỉnh kho và phân bổ|Cắt chi thu hồi đồ dùng|Để kho tiếp tục chia thiếu
1:hasConsort|Tranh quyền chọn người dạy lễ|Các phi tần muốn mời người quen vào dạy lễ, quan ngoài triều bắt đầu vận động.|Tự áp tiêu chuẩn công bằng|Ưu tiên người do thế gia giới thiệu|Để các viện tự tranh người dạy
2|Tiếng sáo bên hồ ngự|Một nghệ nhân xin tấu sáo cho vua giải khuây, nội quan nhắc nên giữ giờ nghỉ.|Chi cho một buổi nghe ngắn|Dành buổi ấy nghỉ tĩnh|Tiếp tục lịch căng thẳng
''',
  'health': '''
0:ill|Cơn ho lúc buổi chầu|Thái y nghe tiếng ho kéo dài và xin chữa sớm trước khi bệnh nặng hơn.|Chi tiền chữa theo toa|Dành một buổi nghỉ dưỡng|Cố làm việc dù còn ho
1:stressed|Đọc tấu đến mờ mắt|Nhiều buổi đọc tấu muộn khiến mắt vua khó tập trung, người hầu xin dừng việc.|Dành buổi nghỉ và giảm tải|Cố duyệt thêm tấu để giữ uy|Giữ nhịp làm việc cũ
2:ill|Bài thuốc mới từ phương xa|Một thầy thuốc đề nghị liệu trình mới có triển vọng nhưng chưa chắc đáp ứng.|Chi tiền thử liệu trình có rủi ro|Dùng thuốc thường ổn định|Không chữa bệnh tuần này
0:ill|Đau bụng sau bữa tối|Thái y nghi thức ăn không hợp và xin điều trị trước khi vua dự lễ dài.|Chi tiền điều trị theo toa|Dành buổi nghỉ dưỡng|Tiếp tục lịch dù còn đau
1:stressed|Bàn tay run khi ký chỉ|Vua đã ký quá nhiều văn bản, nét chữ run khiến người giữ ấn lo lắng.|Dành buổi nghỉ giảm tải|Cố ký hết để giữ uy quyền|Giữ lịch làm việc dày
2:ill|Chứng sốt tái diễn|Thuốc cũ chỉ đỡ tạm, thái y đề nghị một đợt chữa khác có xác suất thất bại.|Đầu tư liệu trình mới|Dùng phương thuốc thường|Để cơn sốt tự qua
0:ill|Khàn tiếng giữa cuộc nghị|Vua khó nói rõ sau nhiều buổi nghị kéo dài, thái y khuyên chữa và tĩnh dưỡng.|Chi tiền chữa khàn tiếng|Nghỉ một buổi dưỡng sức|Tiếp tục nghị dù còn khàn
1:stressed|Giấc ngủ đầy việc triều|Người hầu nói vua thức nhiều lần vì nghĩ tới công việc, sáng dậy càng mệt.|Dành buổi nghỉ giảm áp lực|Cố xử thêm việc để trấn an triều|Giữ cách làm việc hiện tại
2:ill|Thuốc bôi vết thương mới|Thái y có thuốc mới giúp vết thương lành nhanh nhưng cơ địa có thể không hợp.|Chi tiền thử đợt thuốc mới|Dùng thuốc thường đã quen|Không xử lý vết thương
0:ill|Cơn đau đầu dưới đèn|Thái y thấy vua đau đầu khi đọc chữ nhỏ, xin chữa trước khi thành bệnh kéo dài.|Chi tiền điều trị sớm|Dành buổi nghỉ dưỡng|Cố đọc tiếp dù đau
1:stressed|Không còn ngon miệng|Công việc dồn dập khiến bữa ăn của vua bị bỏ dở, thái y nói cần giảm tải.|Dành buổi nghỉ thật sự|Cố làm thêm để giữ uy|Tiếp tục nhịp làm việc cũ
2:ill|Liệu trình phục hồi sau bệnh|Thái y đề xuất phục hồi chuyên sâu nhưng cảnh báo có thể gây phản ứng ngược.|Chi tiền thử liệu trình phục hồi|Dùng chế độ chữa thông thường|Không dành thời gian chữa
0:ill|Đau lưng sau ngày thiết triều|Ngồi lâu trong điện khiến vua đau lưng, thầy thuốc xin chữa trước buổi nghị tới.|Chi tiền chữa theo toa|Nghỉ một buổi dưỡng sức|Chịu đau tiếp tục làm việc
1:stressed|Tấu khẩn tới trong giờ ngủ|Một chồng tấu không thật sự khẩn được đưa vào lúc vua vừa chợp mắt.|Giữ buổi nghỉ và giảm tải|Thức dậy xử thêm để giữ uy|Giữ lệ nhận tấu cả đêm
2:ill|Thuốc bổ gây tranh luận|Hai thái y bất đồng về một toa thuốc mới, vua phải chọn mức rủi ro chấp nhận.|Chi tiền thử toa mới|Dùng toa thông thường|Không theo toa nào
0:ill|Vết phồng rộp sau chuyến đi|Vết thương nhỏ bắt đầu viêm, thái y xin chữa trước khi lan rộng.|Chi tiền chữa vết viêm|Dành buổi nghỉ dưỡng|Tiếp tục lịch dù vết đau
1:stressed|Nhầm tên trong buổi chầu|Vua gọi nhầm người nhiều lần vì mệt, một nội quan xin giảm lịch ngay.|Dành buổi nghỉ hồi sức|Cố chầu tiếp để giữ uy|Không giảm việc đang có
2:ill|Thầy thuốc xin thử cách châm mới|Một phương pháp được đề nghị cho chứng đau kéo dài nhưng chưa chắc hiệu quả.|Chi tiền thử đợt chữa mới|Dùng cách chữa thông thường|Chưa chữa chứng đau
0:ill|Cảm lạnh sau buổi tế|Thái y thấy vua rét run sau lễ ngoài trời và xin chữa trước khi sốt.|Chi tiền điều trị cảm lạnh|Nghỉ một buổi dưỡng sức|Giữ lịch dù đang rét
1:stressed|Những bữa cơm bên bàn tấu|Nhiều ngày vua vừa ăn vừa xử việc, nội quan lo không còn khoảng nghỉ.|Dành buổi nghỉ tách khỏi công việc|Cố xử thêm để giữ uy quyền|Giữ thói quen làm việc liên tục
2:ill|Dược liệu khó hợp thể trạng|Một thuốc quý có thể giúp phục hồi nhanh nhưng thái y cảnh báo phản ứng phụ.|Chi tiền thử có theo dõi|Dùng thuốc thường ít biến động|Bỏ việc chữa trị kỳ này
0:ill|Cơn chóng mặt khi đứng dậy|Vua phải vịn bàn trong buổi chầu, thái y muốn điều trị ngay.|Chi tiền điều trị triệu chứng|Dành buổi nghỉ dưỡng|Cố tiếp tục lịch triều
1:stressed|Đêm trực đọc quân báo|Quân báo nối nhau làm vua thức tới sáng, thị vệ xin dành buổi sau để nghỉ.|Dành buổi nghỉ giảm tải|Cố xử tiếp để giữ uy|Không thay lịch nhận báo
2:ill|Đợt thuốc cần theo dõi dài ngày|Thái y đưa hai cách chữa, một cách có triển vọng cao hơn nhưng dễ phản ứng.|Đầu tư liệu trình có rủi ro|Dùng thuốc thường trước|Chưa dùng liệu trình nào
0:ill|Mỏi ngực sau ngày nghị dài|Thái y xin kiểm tra triệu chứng trước khi vua tiếp tục một buổi nghi lễ khác.|Chi tiền chữa theo toa|Dành buổi nghỉ dưỡng|Chịu mệt tiếp tục làm việc
1:stressed|Một ngày không còn khoảng trống|Lịch triều kiến lấp cả giờ nghỉ, người hầu xin vua dành lại một buổi cho mình.|Giữ một buổi nghỉ thật sự|Nhận thêm việc để giữ uy|Giữ nguyên lịch chật kín
2:ill|Đổi thuốc khi bệnh chưa dứt|Thái y đề nghị đổi liệu trình sau nhiều đợt bệnh, kết quả vẫn có thể xấu đi.|Chi tiền thử liệu trình khác|Tiếp tục thuốc thông thường|Dừng việc chữa bệnh
''',
  'disasters': '''
0:rain|Nước cuốn cầu gỗ|Một cầu tạm bị nước cuốn, dân mắc lại hai bên và xin cứu hộ.|Chi tiền cứu hộ và gia cố|Xuất lương nhờ quân ứng cứu|Chưa cứu hộ cầu gỗ
1|Làng mất kho sau gió lớn|Gió phá kho và bờ giữ nước, dân xin giúp dựng lại trước vụ tới.|Đầu tư tái thiết có kiểm tra|Xuất lương cứu trước và ghi nợ|Để làng tự dựng lại
2|Người chạy cháy thiếu chỗ ăn|Nhiều gia đình mất bếp sau đám cháy, họ cần phần ăn trước khi về dựng nhà.|Xuất lương cứu trợ|Điều quân chia sức cứu dân|Chưa cấp cứu trợ cháy
0:rain|Bờ kênh tràn lúc nửa đêm|Nước đang tràn qua bờ thấp, người giữ kênh xin vật liệu cứu gấp.|Chi tiền cứu và gia cố bờ|Xuất lương nhờ quân đắp bờ|Đợi nước tự rút
1|Nương đồi bị sạt mất bờ|Một vụ sạt nhỏ làm ruộng bậc thang hỏng, dân cần tái thiết có tính toán.|Đầu tư sửa lại bờ ruộng|Xuất lương cứu trước và vay nợ|Để dân tự sửa nương
2|Đàn châu chấu qua xóm|Một xóm mất phần lớn lương ăn sau khi châu chấu tràn qua ruộng.|Xuất lương cứu xóm|Điều quân hỗ trợ dân đói|Chưa cứu phần lương đã mất
0:rain|Cống nhỏ tắc giữa mưa|Cành cây chặn cống khiến nước dâng quanh khu dân, người dân cần giúp.|Chi tiền khai thông và gia cố|Xuất lương nhờ quân thông cống|Chờ mưa ngừng rồi tính
1|Giếng cạn sau mùa khô|Làng muốn đào giếng và khơi bờ dẫn nước mới nhưng không đủ sức tự làm.|Đầu tư công trình nước thử|Xuất lương cứu trước và ghi nợ|Để làng chờ mưa
2|Kho làng cháy vì đèn dầu|Một đám cháy thiêu lương dự trữ, người thoát nạn kéo nhau xin ăn.|Xuất lương giúp dân mất kho|Điều quân chia sức cứu trợ|Chưa bù lương bị cháy
0:rain|Bến đò sụt đất|Bến đò lở làm nhiều người kẹt trong mưa, dân xin đội cứu hộ triều đình.|Chi tiền cứu và gia cố bến|Xuất lương nhờ quân cứu hộ|Để chủ bến tự cứu người
1|Đất nứt quanh ao giữ nước|Nền ao nứt sau khô hạn, làng xin làm lại hệ giữ nước trước mùa mưa.|Đầu tư tái thiết có giám sát|Xuất lương trước và nhận thêm nợ|Chưa sửa ao giữ nước
2|Gió cuốn mái khu chợ|Nhiều người bán hàng mất nơi ở lẫn lương ăn sau một trận gió mạnh.|Xuất lương cho người mất mái|Điều quân hỗ trợ khu chợ|Chưa giúp khu chợ sau gió
0:rain|Trẻ nhỏ mắc trên gò nước|Nước lên nhanh khiến một nhóm trẻ và người già không rời được gò cao.|Chi tiền cứu và gia cố lối thoát|Xuất lương nhờ quân cứu người|Chờ nước xuống gò
1|Ruộng nhiễm mặn sau triều cường|Dân cần phục hồi bờ giữ nước và ruộng để không mất thêm vụ nữa.|Đầu tư phục hồi ruộng|Xuất lương trước và ghi thêm nợ|Để dân tự chờ nước ngọt
2|Dịch vật nuôi làm mất nguồn ăn|Nhiều hộ mất đàn vật nuôi cùng lúc, lương ăn trong làng nhanh chóng thiếu.|Xuất lương cứu các hộ|Điều quân hỗ trợ sinh hoạt|Chưa cứu hộ mất đàn
0:rain|Đường thoát nước bị vùi|Đất đổ xuống rãnh chính làm nước dồn về nhà dân, việc khai thông cần làm gấp.|Chi tiền cứu và khơi rãnh|Xuất lương nhờ quân khai thông|Chờ địa phương tự dọn
1|Lửa rừng phá bờ chắn|Lửa đi qua đồi làm bờ và vườn giữ đất hỏng, dân xin tái thiết trước mưa.|Đầu tư phục hồi khu đồi|Xuất lương cứu trước và vay nợ|Chưa phục hồi bờ chắn
2|Dân sơ tán ngủ ngoài đồng|Một nhóm dân tránh tai họa chưa có phần ăn trong điểm trú tạm.|Xuất lương tới nơi trú|Điều quân hỗ trợ người sơ tán|Chưa cứu nơi trú tạm
0:rain|Cột chống nhà chung bị trôi|Nước xiết làm nhà trú chung nghiêng, nhiều gia đình chưa tìm được chỗ an toàn.|Chi tiền cứu và gia cố nhà|Xuất lương nhờ quân chống đỡ|Đợi dân tự rời nhà chung
1|Mưa đá làm hỏng vườn giống|Vườn giống và bờ giữ nước hỏng, làng cần phục hồi để có vụ sau.|Đầu tư phục hồi vườn giống|Xuất lương trước và nhận nợ|Để làng tự tìm giống khác
2|Đàn thú phá kho dân|Thú đói tràn vào phá kho, người làng mất phần lương qua mùa.|Xuất lương giúp làng|Điều quân chia sức bảo vệ|Chưa giúp phần lương mất
0:weakLevee|Vết xói dưới chân bờ|Một vết xói mới xuất hiện dưới bờ yếu, dân xin cứu trước khi nước dâng.|Chi tiền cứu và gia cố|Xuất lương nhờ quân ứng cứu|Chưa vá vết xói
1|Hố sụt giữa vùng trồng trọt|Một hố sụt phá mương và ruộng, địa phương cần thử cách phục hồi nền đất.|Đầu tư tái thiết có theo dõi|Xuất lương cứu trước và ghi nợ|Bỏ việc phục hồi nền đất
2|Người dân mất lương trên đường tránh nạn|Đoàn dân sơ tán bị mất xe lương trên đường, xin giúp qua vài ngày đầu.|Xuất lương cứu đoàn dân|Điều quân hỗ trợ đoàn tránh nạn|Chưa cấp phần ăn cho đoàn
0:flood:flood|Nước tràn qua bãi dân cư|Đê yếu không giữ nổi dòng nước, dân đang dồn lên nền cao chờ cứu.|Chi tiền cứu và gia cố bờ|Xuất lương nhờ quân cứu người|Để dân tự chờ nước rút
1:flood:flood|Dòng lũ đổi lối qua ruộng|Nước tràn mở đường qua ruộng và mương, cần dựng lại trước khi mất thêm vụ.|Đầu tư khôi phục dòng nước|Xuất lương cứu trước và vay nợ|Chưa khôi phục ruộng sau lũ
2:flood:flood|Kho lương làng chìm trong lũ|Một kho lương bị ngập, dân mất cả phần ăn lẫn hạt giống trong khi nước chưa rút.|Xuất lương tới vùng ngập|Điều quân chia sức cứu dân|Chưa cứu kho lương làng
''',
  'culture': '''
0|Lớp học cho trẻ ở bến sông|Người dân xin mở lớp chữ nhưng thiếu tiền mua bảng và thuê người dạy.|Đầu tư lớp học chung|Dành việc học cho nhóm tinh hoa|Chưa mở lớp bến sông
1|Sân diễn chung của dân|Các phường muốn dựng sân diễn công cộng, một nhà giàu xin thu tiền độc quyền.|Cấp tiền cho sân chung|Bán quyền thu tiền sân diễn|Chưa quyết sân diễn
2|Thợ tìm cách nung gạch mới|Một nhóm thợ muốn thử lò ít hao củi nhưng cần vốn và có thể hỏng mẻ đầu.|Đầu tư thử lò mới|Tự cùng học và hướng dẫn thợ|Bỏ đề nghị nung gạch
0|Sách đọc cho làng xa|Thầy đồ xin đưa sách và mở lớp luân phiên cho những làng chưa có người dạy.|Đầu tư sách và lớp chung|Chỉ cấp học cho con nhà danh giá|Chưa đưa sách về làng
1|Ngày hội sau vụ gặt|Dân muốn có ngày hội chung, nhà buôn xin tài trợ nếu được quyền thu vé.|Cấp tiền cho hội mở|Bán quyền thu vé ngày hội|Chưa tổ chức ngày hội
2|Giấy từ thân cây lạ|Thợ giấy muốn thử nguyên liệu mới để giảm giá, nhưng mẻ đầu có thể thất bại.|Đầu tư thử cách làm giấy|Tự học cùng nhóm thợ|Không thử nguyên liệu mới
0|Người lớn xin học tính sổ|Các tiểu thương xin lớp tính để tránh bị gian cân và lừa giấy nợ.|Đầu tư lớp tính cho dân|Ưu tiên học cho nhóm tinh hoa|Chưa mở lớp tính sổ
1|Kho lưu nhạc của các phường|Nhiều bản nhạc sắp thất truyền, dân muốn nơi tập chung không thu phí cao.|Cấp tiền giữ nơi tập chung|Cho nhà giàu khai thác thu tiền|Chưa giữ kho nhạc
2|Bàn xoay mới của thợ gốm|Một thợ gốm mang mẫu bàn xoay có thể làm nhanh hơn nhưng cần thử lâu.|Đầu tư thử bàn xoay|Tự học và góp cách làm|Bỏ thử bàn xoay mới
0|Trẻ em vùng núi xin người dạy|Một đoàn dân miền núi xin lớp chung vì đi học ở kinh quá xa và tốn kém.|Đầu tư lớp vùng núi|Dành suất học cho nhóm tinh hoa|Chưa đưa người dạy lên núi
1|Nhà đọc sách ở khu chợ|Dân muốn nơi đọc chung, một nhà bảo trợ xin thu phí để đổi lấy tiền xây.|Cấp tiền nhà đọc công cộng|Bán quyền thu phí nhà đọc|Chưa mở nhà đọc sách
2|Dụng cụ đo ruộng cải tiến|Một nhóm thợ muốn thử thước đo mới để giảm tranh chấp, kết quả chưa được kiểm chứng.|Đầu tư thử dụng cụ đo|Tự nghiên cứu cùng thợ|Giữ dụng cụ đo cũ
0|Lớp chữ cho người giải ngũ|Người rời quân ngũ muốn học đọc để tìm nghề mới và hiểu giấy thuê đất.|Đầu tư lớp học chung|Ưu tiên học cho người có thế lực|Chưa mở lớp giải ngũ
1|Phường hát muốn diễn ở quảng trường|Phường hát xin hỗ trợ buổi diễn dân chúng, một thế gia muốn đứng ra bán chỗ.|Cấp tiền diễn cho dân|Bán quyền thu tiền chỗ xem|Chưa duyệt buổi diễn
2|Khung dệt mới tiết kiệm sợi|Thợ dệt muốn thử khung mới nhưng phải chấp nhận một số mẻ vải hỏng.|Đầu tư thử khung dệt|Tự học cùng nhóm thợ|Chưa thử khung mới
0|Sách thuốc dễ đọc cho dân|Thầy đồ xin làm sách hướng dẫn cơ bản để dân biết tìm người chữa đúng lúc.|Đầu tư phổ biến sách chung|Chỉ dạy nhóm tinh hoa|Chưa phổ biến sách thuốc
1|Lễ tưởng nhớ người giữ làng|Dân muốn tổ chức lễ chung, một dòng họ muốn biến thành dịp thu tiền riêng.|Cấp tiền cho lễ chung|Nhượng quyền thu tiền dịp lễ|Chưa quyết lễ tưởng nhớ
2|Kính đọc chữ do thợ thử làm|Một thợ mang mẫu kính nhưng cần vốn thử nhiều loại mặt kính để dùng được.|Đầu tư thử kính đọc|Tự nghiên cứu cùng thợ|Bỏ đề nghị chế kính
0|Lớp dạy cân đo cho phụ việc|Người làm thuê muốn học đơn vị đo để không bị thiệt khi lĩnh công.|Đầu tư lớp cân đo chung|Dành việc học cho nhóm tinh hoa|Chưa mở lớp phụ việc
1|Chỗ tập cho đoàn múa rối|Đoàn múa rối muốn nơi tập và diễn cho dân, một nhà buôn đề nghị thu vé độc quyền.|Cấp tiền nơi tập chung|Bán quyền thu vé múa rối|Chưa cấp nơi tập
2|Màu nhuộm từ cây ven núi|Thợ muốn thử màu mới nhưng chưa biết có bền qua nhiều lần giặt hay không.|Đầu tư thử màu nhuộm|Tự học và góp ý cùng thợ|Chưa thử màu mới
0|Người mù xin lớp học kể chuyện|Người khiếm thị muốn học nghề kể chuyện qua lớp chung do làng tổ chức.|Đầu tư lớp học tiếp cận được|Chỉ ưu tiên người có danh giá|Chưa cấp lớp học nghề
1|Ngày mở cửa kho bản đồ|Dân xin xem bản đồ địa phương, một nhà bảo trợ muốn giữ quyền thu tiền vào cửa.|Cấp tiền cho ngày mở chung|Bán quyền thu phí xem bản đồ|Chưa mở kho bản đồ
2|Hộp giữ hạt giống khô|Một thợ mộc đề nghị thử hộp mới chống ẩm, nhưng thử nghiệm có thể không đạt.|Đầu tư thử hộp giữ hạt|Tự nghiên cứu cùng thợ mộc|Giữ cách cất hạt cũ
0|Thư viện nhỏ ở trạm xa|Người coi trạm muốn lớp đọc và tủ sách cho con em dân quanh đường trạm.|Đầu tư tủ sách và lớp chung|Chỉ cấp học cho nhóm tinh hoa|Chưa mở thư viện trạm
1|Buổi kể sử ngoài thành|Các làng xin buổi kể sử chung, một nhà giàu muốn đổi hỗ trợ lấy quyền bán chỗ.|Cấp tiền cho buổi kể chung|Bán quyền thu tiền người nghe|Chưa duyệt buổi kể sử
2|Thợ trẻ chế bình nước đo canh giờ|Một thợ trẻ xin chế bình cho nước nhỏ giọt để đo canh giờ, nhưng kết quả có thể sai nếu vật liệu không đạt.|Đầu tư thử bình nước đo giờ|Tự học cùng nhóm thợ trẻ|Bỏ việc thử đo giờ mới
''',
};
