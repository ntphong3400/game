# Cửu phẩm, công trạng và bộ máy triều đình — 0.24.0

Hệ mới áp dụng khi bắt đầu ván theo mùa có dân số và đơn vị vàng. `courtSystemVersion = 1` được lưu riêng; đọc bản lưu cũ không tự tạo chức vụ hoặc đổi phẩm. Phẩm 1 cao nhất, phẩm 9 thấp nhất. `scoreRules` của ván cũ được giữ.

## Bộ máy đầu ván

46 vị trí: Văn ban 12, Võ ban 10, Hoàng thất 6, Nội đình 8, Địa phương 10. Danh sách chờ bổ nhiệm khởi đầu 12 người. 58 quan/ứng viên có diện mạo riêng trong bộ 60 chân dung hiện có. Vị trí có ID riêng, tách khỏi ID người giữ chức. Người ban đầu được phân bổ ngẫu nhiên theo seed trong nhóm và điều kiện thân phận; phẩm kế thừa đủ giữ vị trí, năng lực và thiện cảm có thể chưa đủ kích hoạt passive.

| Phẩm vị trí | Văn ban | Võ ban | Hoàng thất |
|---|---|---|---|
| Nhất | Tể tướng | Đại tướng | Thân vương |
| Nhị | Thái sư, Hộ bộ | Phó tướng, Đại tư mã | Quận vương |
| Tam | Lại bộ | Chinh tướng | Quốc công |
| Tứ | Ngự sử | Trấn thủ | Thái phó |
| Ngũ | Lễ bộ, Công bộ | Biên tướng | Tông chính |
| Lục | Hình bộ | Hiệu úy | Thiếu phó |
| Thất | Học sĩ, Giám sát ngự sử | Cấm vệ | — |
| Bát | Thương chính | Võ quan | — |
| Cửu | Thư lại | Đội trưởng | — |

Nội đình: Tổng quản Tam phẩm; một Ngự y Tứ phẩm và một Ngự y Thất phẩm; một Mật thám Tứ phẩm và một Mật thám Thất phẩm; Thượng thiện Ngũ phẩm; Thượng phục Lục phẩm; Ngự tiền Bát phẩm. Hai vị trí cùng chức có ID riêng. Chữa trị/điều tra thường trực ưu tiên người giữ vị trí cao hơn, không phụ thuộc thứ tự danh sách nhân vật; vị trí cao trống có thể dùng người ở vị trí thấp còn lại.

Địa phương giữ ba Tuần phủ Tứ phẩm, bốn Tri phủ Lục phẩm, ba Quan điền Cửu phẩm. Không có Đô đốc hoặc nhiệm vụ thủy chiến mới trong ván dùng hệ này. Bản lưu lịch sử giữ hợp đồng chiến tranh cũ.

Thân vương, Quận vương và Quốc công là tước vị trong nhóm Hoàng thất; chỉ nhân vật có điều kiện thân phận phù hợp được nhận. Phe Hoàng tộc không tự cấp quyền nhận tước. Các chức phục vụ hoàng gia được xét như chức quan thường.

## Thăng phẩm

Phí trong bảng là lượng vàng. Mỗi lần xác nhận tốn một hành động; không giới hạn khoảng cách giữa các lần. Chọn phẩm cao hơn bất kỳ, cộng tất cả các bậc đi qua. Năng lực và thành tích lớn xét theo phẩm đích. Không được sắc phong khi đang bận nhiệm vụ dài hạn.

| Phẩm đích | Công trạng từng bậc | Phí từng bậc | Năng lực | Thiện cảm | Bất mãn |
|---|---:|---:|---:|---:|---:|
| Bát | 2 | 800 | 45 | +2 | −4 |
| Thất | 3 | 1.000 | 50 | +3 | −6 |
| Lục | 4 | 1.200 | 55 | +4 | −8 |
| Ngũ | 6 | 1.600 | 60 | +5 | −10 |
| Tứ | 8 | 2.000 | 68 | +6 | −12 |
| Tam | 10 | 2.500 | 76 | +7 | −14 |
| Nhị | 13 | 3.200 | 84 | +8 | −16 |
| Nhất | 16 | 4.000 | 90 | +9 | −18 |

Tam/Nhị/Nhất cần 1/2/3 thành tích lớn đã ghi nhận. Thành tích lớn không bị tiêu hao. Mỗi bậc tăng 3 ảnh hưởng. Thiện cảm giới hạn 100 và giữ luật khóa vĩnh viễn tại 100; bất mãn tối thiểu 0. Popup báo mức thay đổi thực nhận.

Cửu → Thất: dùng 5 công trạng, 1.800 lượng, thiện cảm +5, bất mãn −10. Cửu → Lục: dùng 9 công trạng, 3.000 lượng, thiện cảm +9, bất mãn −18; đang có 10 công trạng thì còn 1. Tổng lịch sử công trạng = khả dụng + đã sử dụng; không giới hạn tổng ở 100.

## Công trạng

Hoàn thành quốc sự/nhiệm vụ thường: +1; công trình nâng cấp và công việc dài hạn thành công: +2; mục tiêu đại biến cố hoặc nhiệm vụ công thành/phòng thủ kinh thành thành công: +3 và một thành tích lớn. Chiến đấu thường/giải vây: +2. Chiến tranh có thể ghi công cho cả chủ tướng và phó tướng. Nhiệm vụ thất bại hoặc gián đoạn không có công. Các thao tác tức thời không còn tác dụng ở trần chỉ số không tạo công trạng.

Kết quả công trình, chiến tranh, đại biến cố và tấu chương có mã ghi công lưu theo nhân vật để không ghi lặp. Một tấu chương gồm nhiều kết quả chỉ ghi công sau kết quả cuối cùng. Ban thưởng, tiếp kiến, sắc phong và passive không tạo công. Mốc yêu sách mỗi ba điểm dựa trên tổng công trạng trước khi sử dụng, không bị đặt lại khi thăng phẩm.

## Bổ nhiệm

Người trưởng thành, còn hiện diện, đủ phẩm, không đang bận được chọn. Người đương nhiệm cũng phải rảnh. Chuyên môn giữ nguyên và được hiển thị để so sánh; chưa đủ năng lực/thiện cảm passive vẫn có thể nhận chức.

Bổ nhiệm/điều chuyển một người: một hành động và phí theo năng lực, ảnh hưởng, phẩm vị trí. Người bị thay chuyển về danh sách chờ, giữ danh tính, phẩm, công trạng, tính cách và quan hệ. Điều chuyển có thể để trống vị trí cũ, hoặc chọn ứng viên chờ bổ khuyết cùng một lần xác nhận; phương án bổ khuyết tốn hai hành động, hai khoản phí và được kiểm tra/ghi nhận nguyên tử. Đổi chỗ hai quan kiểm tra điều kiện cả hai chiều, tốn hai hành động và hai khoản phí, phản ứng chính trị tính cả hai lượt.

Chức có người qua đời được để trống để vua chọn người thay. Công việc dài hạn đang bận chặn bổ nhiệm; các nghĩa vụ tài chính đã cam kết không biến mất khi thay người.

### Sổ Bộ máy triều đình và hồi hương

Nút **Bộ máy triều đình** đặt cạnh tiêu đề Triều thần như nút Học tập & cung vụ ở Hậu cung. Sổ trình toàn bộ 46 vị trí, sắp theo phẩm chức vụ từ Nhất đến Cửu phẩm. Cùng phẩm xếp theo nhóm Văn ban, Võ ban, Hoàng thất, Nội đình, Địa phương, rồi tên chức và ID vị trí. Phẩm cá nhân cao hơn không đẩy một chức vụ thấp lên đầu danh sách. Các vị trí cùng tên như hai Ngự y, hai Mật thám và nhiều quan địa phương vẫn có dòng riêng. Hiển thị danh sách một vị trí mỗi dòng với năm cột: chức vụ, phẩm yêu cầu, người đang giữ chức, trạng thái passive và nút Bổ nhiệm/Cho hồi hương. Trên màn hình hẹp, các thông tin xuống hàng trong cùng dòng vị trí để không phải cuộn ngang. Bấm tên người giữ chức để mở trang chi tiết. Passive hiển thị trạng thái và mức cộng/trừ; bấm hoặc rê vào để xem điều kiện, lý do chưa kích hoạt và tác hại khi trống. Riêng tại sổ Bộ máy triều đình, nút Bổ nhiệm chỉ bật cho ghế trống; ghế đã có người giữ sẽ khóa nút và có chú giải. Sau khi hồi hương người cũ, nút được bật lại để chọn người mới.

**Cho hồi hương** là hành động riêng với thay người. Popup xác nhận báo phí một hành động, không chi vàng; phe người cũ −4 và phản ứng một mùa nếu ảnh hưởng ≥60. Người đó có trạng thái **Đã hồi hương**, giữ phẩm/công trạng/quan hệ và diện mạo trong danh sách chờ; khi được bổ nhiệm lại, trạng thái hồi hương được gỡ. Thân phận hoàng tộc vẫn giữ nguyên. Vị trí để trống đến khi vua bổ nhiệm. Quan đang bận chưa thể hồi hương.

| Phẩm chức vụ | Ổn định mất một lần | Uy quyền cần có |
|---|---:|---|
| Nhất | −8 | Trên 80 (từ 81) |
| Nhị | −7 | Trên 70 (từ 71) |
| Tam | −6 | Trên 60 (từ 61) |
| Tứ | −5 | Trên 50 (từ 51) |
| Ngũ | −4 | Không yêu cầu |
| Lục | −3 | Không yêu cầu |
| Thất | −2 | Không yêu cầu |
| Bát | −1 | Không yêu cầu |
| Cửu | −1 | Không yêu cầu |

Xét phẩm chức vụ để tính tổn thất ổn định. Uy quyền so sánh **lớn hơn**, không phải lớn hơn hoặc bằng. Điều kiện kiểm tra trong engine trước khi chi tài nguyên; giao diện khóa nút và ghi rõ lý do. Áp dụng cho hồi hương, thay người, điều chuyển và đổi chỗ: mọi chức đang có người bị rời ghế đều phải đủ uy quyền; mỗi ghế tính xáo trộn một lần. Điều chuyển có bổ khuyết không tính thêm một lần xáo trộn cho cùng ghế. Bổ nhiệm ứng viên chờ vào chức đang trống không yêu cầu uy quyền để loại người cũ. Các khoản xáo trộn tức thời và phạt passive mỗi mùa được trình bày riêng.

## Passive chức vụ

Nhất phẩm cần năng lực ≥90 và thiện cảm ≥80; Nhị phẩm cần năng lực ≥80 và thiện cảm ≥70. Người phải đủ phẩm, còn hiện diện và giữ đúng vị trí. Bổ nhiệm trong mùa bắt đầu được xét từ mùa sau; chuyển đi rồi về không khôi phục lượt đóng góp mùa đang diễn ra. Mỗi vị trí quyết toán một lần khi khép mùa, trước tính kinh tế và các bước kiểm tra kết cục tiếp theo.

| Vị trí | Passive |
|---|---|
| Tể tướng — Nhất | Ổn định +1/mùa; Uy quyền +1/mùa |
| Đại tướng — Nhất | Sĩ khí +1/mùa; Huấn luyện +1/mùa |
| Thân vương — Nhất | Uy quyền +1/mùa; thái độ Hoàng tộc +1/mùa |
| Thái sư — Nhị | Mệt mỏi của vua −1/mùa |
| Hộ bộ — Nhị | Tích lũy 0,75% thưởng thuế mỗi mùa đủ điều kiện, tối đa 3%/vụ |
| Phó tướng — Nhị | Huấn luyện +1/mùa |
| Đại tư mã — Nhị | Hậu cần +1/mùa |
| Quận vương — Nhị | Ổn định +1/mùa |

Người Nhất phẩm giữ chức Phó tướng chỉ nhận một passive của Phó tướng. Nội đình không có passive chức vụ, kể cả khi phẩm cá nhân cao hơn. Đóng góp từ các vị trí khác nhau cộng dồn và giữ trần chỉ số hiện có. Sử ký ghi nguồn và lượng thực nhận. Mùa Đông ghi nhận vào vụ thuế năm sau; điều chỉnh thuế tính một lần trên thực thu dương của vụ Thu, lấy phần nguyên của trị tuyệt đối rồi áp dụng dấu.

**Chức cao bỏ trống tại lúc khép mùa chịu tác động ngược từng passive:** Tể tướng ổn định −1 và uy quyền −1; Đại tướng sĩ khí −1 và huấn luyện −1; Phó tướng huấn luyện −1; Đại tư mã hậu cần −1; Quận vương ổn định −1; Thân vương uy quyền −1 và thái độ Hoàng tộc −1. Thái sư trống tăng mệt mỏi vua +1. Hộ bộ trống tích lũy −0,75% cho vụ thuế tương ứng, tối đa −3%; các mùa đủ điều kiện và bỏ trống bù trừ nhau. Không làm tiền thuế âm.

Có người giữ chức chưa đủ năng lực/thiện cảm hoặc vừa nhận chức trong mùa thì đóng góp 0, không chịu phạt bỏ trống. Bổ nhiệm chấm dứt phạt bỏ trống từ mùa đó, nhưng đóng góp dương vẫn đợi giữ chức trọn mùa. Ghi nhận phạt một lần mỗi mùa, không lặp khi tải lại/thử lại lệnh. Các tác động trái dấu cùng chỉ số được bù trừ trước khi áp dụng giới hạn 0–100, bảo đảm không phụ thuộc thứ tự chức vụ trong bản lưu.

## Tấu chương nhân sự

Từ mùa thứ hai, mỗi lần mở tấu nhân sự đặt lịch lần sau cách 1–2 mùa; chỉ có một tấu nhân sự đang chờ. Tấu gắn ID người/chức và được lưu cùng ván chơi. Ưu tiên chức trống; không tạo lại người hoặc ứng viên khi xem trước/tải lại.

| Loại | Lựa chọn |
|---|---|
| Tiến cử người tài | Bổ nhiệm người được tiến cử / chọn ứng viên khác / bác |
| Chiêu mộ hiền tài | Bổ nhiệm ứng viên mới / khảo hạch, rồi có thể chọn người khác / bác |
| Đề nghị hồi hương quan đối lập | Cho hồi hương / đối chiếu công việc / bác |
| Xin thăng phẩm theo công | Sắc phong / xét dịp khác / bác |
| Xin thăng phẩm đặc cách | Sắc phong đặc cách / yêu cầu lập công và rèn năng lực / bác |
| Kiện toàn trọng chức | Bổ nhiệm người tiến cử / chọn người khác / bồi dưỡng đương nhiệm / bác |

Người dâng tấu, phe và người được đề nghị đều hiển thị cụ thể. Tấu hồi hương do phe đối lập của quan mục tiêu dâng. Phương án nhận chức dùng nguyên phí, phẩm, thân phận và uy quyền của luật bổ nhiệm. Chọn ứng viên khác cập nhật chi phí trước khi xác nhận ngự phê. Tấu không tự miễn điều kiện hoặc bổ nhiệm khi khảo hạch.

Khảo hạch ứng viên tốn 500 lượng vàng và một hành động; đối chiếu đề nghị hồi hương tốn một hành động. Cả hai giữ tấu đến cuối mùa sau, không lặp khảo hạch để đổi người hoặc kết quả. Chỉ đối chiếu thông tin năng lực/chuyên môn công khai, không công bố phẩm chất ẩn hay tự kết luận sai phạm. Ứng viên mới tối đa một người/năm, vào danh sách chờ với phẩm ban đầu phù hợp một chức Ngũ–Cửu phẩm không dành riêng cho hoàng thân; không cấp miễn phí phẩm hoặc công trạng cho người hiện hữu.

Thăng phẩm thường cần đủ năng lực, công trạng, thành tích lớn và vàng. **Đặc cách chỉ miễn năng lực**, giữ nguyên ba điều kiện còn lại và tác động thiện cảm/bất mãn của sắc phong. Đặc cách làm uy quyền −2, ổn định −1, phe tiến cử +5. Sắc phong theo công làm uy quyền +1, phe tiến cử +2. Thăng phẩm không cấp thêm công trạng, không tự tăng năng lực hoặc kích hoạt passive.

Tiến cử chỉ được đánh giá sau một mùa đầy đủ trong cùng vị trí: đủ phẩm, năng lực phù hợp cấp chức, độ phù hợp chuyên môn ≥80; chức có passive còn cần đủ thiện cảm. Thành công ghi +2 công trạng cho người tiến cử và uy quyền +1; một cặp người/chức chỉ được thưởng một lần trong ván. Rời chức rồi quay lại trước đánh giá hủy kết quả chờ. Không tự tiến cử bản thân để nhận công trạng. Người chưa đạt yêu cầu không đem lại thưởng tiến cử.

Bồi dưỡng đương nhiệm tốn 1.200 lượng vàng và một hành động; người đó bận tới khi giữ nguyên chức trọn một mùa đầy đủ. Kết quả: năng lực +2, thiện cảm +2, giữ trần 100 và luật biến động thiện cảm mỗi mùa. Chưa chắc đạt ngưỡng passive. Nếu rời vị trí trước kết quả thì khóa học khép lại không trao tăng chỉ số.

Bác đề nghị hoặc hết hạn làm phe dâng tấu −1. Hết hạn không tự hành động nhân sự, không thu phí hoặc hành động. Nếu người liên quan qua đời, chức đã đổi người hoặc người đó đã đạt phẩm đích, tấu khép lại trung lập. Kết quả được ghi Sử ký; phí và thao tác dùng cơ chế lưu lệnh hiện có để chống thực hiện trùng.

## Giao diện và kiểm tra

Danh sách nhân vật Triều thần và Hậu cung dùng avatar vuông tỷ lệ 4:4. Mọi thẻ trong danh sách đang lọc lấy chiều cao của thẻ có nội dung cao nhất, áp dụng cho tất cả các hàng. Chiều cao được tính lại khi đổi bộ lọc, nội dung hoặc chiều rộng màn hình; không cắt tên hay passive để ép chiều cao. Danh sách cuộn liên tục, không phân trang và không giới hạn 12 người. Thanh trạng thái nằm ngay dưới avatar; nút Triệu kiến/Gặp gỡ luôn nằm ở đáy thẻ, cách mép dưới 16 px, kể cả khi các nhân vật có lượng nội dung khác nhau.

Triều thần dùng thẻ chân dung, mở Triệu kiến thành trang riêng. Badge phẩm dưới tên, mỗi phẩm có màu nền, biểu tượng và số 1–9 riêng; Nhất phẩm đỏ son viền vàng, Nhị phẩm xanh chàm viền vàng, Tam phẩm tím, Tứ phẩm xanh ngọc, Ngũ phẩm xanh cổ vịt, Lục phẩm xanh lam, Thất phẩm đồng, Bát phẩm vàng cát và Cửu phẩm xám. Hiện năng lực, thiện cảm bằng số hiện tại, công trạng khả dụng, đại công và đóng góp chức vụ. Bộ lọc nhóm/phẩm/phe/công việc, không tìm tên hoặc lọc passive. Danh sách chờ và chức trống có lối bổ nhiệm. Trên trang Triệu kiến của hệ 9 phẩm, nút Thăng phẩm thay cho Hồ sơ & chức vụ, dùng biểu tượng nâng phẩm. Bấm mở popup liệt kê mọi phẩm cao hơn từ gần nhất đến Nhất phẩm, hỗ trợ thăng vượt. Mỗi lựa chọn hiện công trạng/phí vàng/hành động/năng lực/thành tích lớn; lựa chọn chưa đạt bị khóa và ghi rõ lý do. Phẩm được chọn hiện trước mức thiện cảm tăng, bất mãn giảm và công trạng còn dư; chỉ xác nhận mới chi tài nguyên. Popup cập nhật theo bản lưu mới khi đang mở và bỏ lựa chọn đã mất điều kiện. Nhất phẩm hiển thị thông báo đã đạt phẩm cao nhất. Badge của trang chi tiết và popup dùng cùng bộ 9 phẩm với danh sách, cập nhật ngay sau khi sắc phong. Trang Triệu kiến có nút Cho hồi hương ngay trong nhóm hành động: mở xác nhận với 1 hành động, tổn thất ổn định, phản ứng phe và phạt passive khi ghế trống. Nút khóa theo uy quyền, công vụ đang bận hoặc trạng thái đã hồi hương; hủy xác nhận không đổi dữ liệu.

Hậu cung giữ luật đóng góp hiện có, bổ sung tóm tắt trạng thái/mức đóng góp trên thẻ, dùng chung dự báo đã xét trần với trang Gặp gỡ. Năng lực và thiện cảm không thêm `/100`; điều kiện kích hoạt và các chỉ số điều tra khác vẫn hiện theo đúng ngữ cảnh.

Kiểm tra: `flutter analyze`, `flutter test`; riêng `test/court_system_test.dart` kiểm tra luật/bản lưu và `test/court_ui_test.dart` kiểm tra bố cục/lọc/trang riêng. Tạo ảnh thật của giao diện bằng `flutter test test/court_ui_test.dart --dart-define=COURT_PREVIEWS=true`; ảnh nằm trong `output/court-personnel/`.

Kiểm tra hồi hương/tấu nhân sự: `test/court_personnel_missions_test.dart` (luật, ngưỡng, chống lách, sinh đủ sáu nhóm tấu, giới hạn chiêu mộ, lưu/tải) và `test/court_personnel_ui_test.dart` (chọn ứng viên, chi phí, đặc cách, khóa nút trên desktop/mobile). Ảnh: `flutter test test/court_personnel_ui_test.dart --dart-define=COURT_PERSONNEL_PREVIEWS=true`, lưu trong `output/court-personnel-upgrade/`. Bản 0.24.0 dùng content 21/schema 2, nhận bản lưu 0.23.0/0.23.1 và bổ sung các trường nhân sự với giá trị mặc định an toàn; bộ máy cũ chưa có hệ 9 phẩm giữ luật cũ.

Kiểm tra popup thăng phẩm: `test/court_promotion_popup_ui_test.dart` kiểm tra mở trực tiếp, mọi phẩm đích, khóa lựa chọn, hủy/xác nhận, cập nhật dữ liệu trong lúc mở, Nhất phẩm và đổi badge tại 1440×900, 390×844, 320×568. Tạo ảnh: `flutter test test/court_promotion_popup_ui_test.dart --dart-define=COURT_PROMOTION_PREVIEWS=true`; ảnh lưu trong `output/court-promotion-popup/`.
