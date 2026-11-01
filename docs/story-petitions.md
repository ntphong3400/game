# Mười hai chuỗi tấu chương — 0.19.0

Luật `mvp-0.19.0`, nội dung 18, schema 2. Chuỗi mở mới theo mùa dùng cơ chế quyết toán; hồ sơ cũ giữ luật đã mở đến khi kết thúc.

## Tiến độ và quyết toán

Mỗi chuỗi có 4 bản tấu, bản tiếp theo cách 1 mùa. Mỗi lần xác nhận tốn 1 hành động. Mười một chuỗi có lựa chọn 0 từ bỏ, 1 trả ngân khố, 2 trả chỉ số. Cả hai cách trả hoàn thành một bước và ghi nhận cùng giá trị vốn quy đổi của bước đó. Chi phí chỉ số được liệt kê rõ và phải trả đầy đủ; không được dùng chỉ số đã cạn, hoặc làm các chỉ số sống còn về 0, để nhận vốn quy đổi.

Chuỗi Phượng điện có ba cách hoàn thành: ưu ái A, ưu ái B, trả tiền giữ công bằng. Nút dừng riêng vẫn cần chọn rồi xác nhận. Đọc/đóng hộp thoại không thay đổi tiến độ hay tài nguyên.

| Hoàn thành | Chuỗi kinh tế: nhân vốn đã thực hiện | Chuỗi khác: phần quỹ thưởng tối đa |
|---|---:|---:|
| 0–1/4 | 0% | 0% |
| 2/4 | 50% | 20% |
| 3/4 | 100% | 40% |
| 4/4 | 250% | 100% |

Chi phí và tác động quan hệ phe có hiệu lực ngay. Phần thưởng chỉ trao khi hoàn thành, chủ động dừng hoặc quá hạn. Quá hạn quyết toán số bước đã làm, không trả phí và không hoàn thành bước đang chờ. Chỉ số đã đánh đổi không được phục hồi; tiền nhận tính cả vốn tương đương từ chỉ số. Mọi hệ số ngân khố là tổng tiền nhận về, chưa trừ vốn đã chi trước đó; không trừ vốn lại lúc quyết toán. Phần lẻ của phần thưởng chỉ số làm tròn xuống. Giới hạn chỉ số vẫn áp dụng; báo cáo ghi thay đổi thực nhận.

Ví dụ Bến chợ: các bước 40, 50, 60, 70 tiền quy đổi. Dừng 1/4 nhận 0; dừng 2/4 nhận 45; dừng 3/4 nhận 150; đủ 4/4 nhận 550. Nếu trả toàn bộ bằng tiền, chi 220 và lãi 330. Lòng dân −5 tương đương 40, uy quyền −5 tương đương 50, ổn định −6 tương đương 60; bước cuối có thể đổi lòng dân −5 và uy quyền −3 thay cho 70 tiền.

## Danh sách 12 chuỗi

| ID | Chủ đề | Tổng kinh phí nếu trả tiền | Phần thưởng 4/4 |
|---|---|---:|---|
| `embezzlement` | Dấu vết tiền cứu trợ | 180 | 250% vốn quy đổi, tối đa dự kiến 450 tiền |
| `border` | Lửa âm ỉ nơi biên ải | 160 | Quân lực +20, uy quyền +6, chiến tranh −1 |
| `granary` | Kho lương trước mùa giáp hạt | 120 | Lương thực +100, lòng dân +8 |
| `dyke` | Con đê trước mùa nước lớn | 120 | Đê điều +35, lòng dân +6 |
| `justice` | Lá đơn dưới cửa kinh thành | 100 | Lòng dân +12, uy quyền +8 |
| `exams` | Những cái tên trên bảng vàng | 100 | Uy quyền +5; thêm 1 ứng viên năng lực 80–90 để vua tự bổ nhiệm |
| `merit` | Công lao sau trận giữ ải | 100 | Quân lực +20, trung thành người liên quan +12 |
| `refugees` | Dân đến từ bên kia núi | 160 | Lương thực +90, lòng dân +10 |
| `copper` | Mạch đồng dưới chân núi | 220 | 250% vốn quy đổi, tối đa dự kiến 550 tiền |
| `palaceRumor` | Lời đồn sau rèm ngọc | 100 | Ổn định +10, thiện cảm người liên quan +10, bất mãn −15 |
| `market` | Bến chợ Đông Hà | 220 | 250% vốn quy đổi, tối đa dự kiến 550 tiền |
| `haremHarmony` | Chung một mái Phượng điện | 120 nếu luôn công bằng | Ổn định +5; hai phi tần mỗi người năng lực +5; thưởng quan hệ theo cách đối xử |

Ứng viên mới và giảm chiến tranh chỉ nhận khi đủ 4/4. Chưa đủ tiến độ, các phần thưởng số khác tính theo tỷ lệ. Việc xác minh của chuỗi oan án và lời đồn vẫn công bố sự thật đã chốt; không tự kết luận bên tố cáo luôn đúng.

## Chung một mái Phượng điện

Điều kiện: ít nhất hai phi tần trưởng thành đã nhập cung, còn hoạt động và không giữ ngôi Hoàng hậu; hai người khác phe, không bắt buộc thuộc hai phe đối địch. Chọn một cặp hợp lệ khi mở và lưu ID/phe. Người rời vị trí hoặc đổi phe thì chặn hoàn thành bước tiếp, cho phép dừng hoặc chờ quá hạn; không tự thay người.

| Bản tấu | Ưu ái A | Ưu ái B | Công bằng |
|---|---|---|---:|
| Hai lời thỉnh cầu trái ngược | Phe A +3, B −5 | Phe B +3, A −5 | 20 tiền |
| Cùng nhận một cung vụ | Phe A +4, B −7 | Phe B +4, A −7 | 30 tiền |
| Một sai sót trước ngày hành lễ | Phe A +5, B −8 | Phe B +5, A −8 | 30 tiền |
| Công trạng trước Phượng điện | Phe A +6, B −10 | Phe B +6, A −10 | 40 tiền |

Quan hệ hai phe đổi ngay, không lan thêm tác động đến phe đối địch tự động. Công bằng giữ nguyên quan hệ phe. Nếu ưu ái cùng một người ít nhất 3 lần: phần thưởng quan hệ tối đa của người được ưu ái là thiện cảm +12, bất mãn −15; người kia +3 và −5. Các cách kết hợp khác cho cả hai thiện cảm +10, bất mãn −15. Năng lực +5 mỗi người và ổn định +5 là quỹ thưởng cơ bản; tất cả thưởng này chỉ trao khi quyết toán và nhân tỷ lệ tiến độ.

## Đại biến cố

Giữ 66 chủ đề, mã DB, điều kiện, ưu tiên mùa, chống lặp, mức độ, chuẩn bị, cam kết và dư âm. Bốn phần nội dung của mỗi chủ đề trở thành bốn bản tấu qua bốn mùa, có hạn cuối mùa mở. Không nhận lệnh `mission` cho hồ sơ mới.

- Huy động đầy đủ: 2 hành động, phí tiền cơ sở ít nhất 55 và thóc theo nội dung; bảo vệ toàn phần.
- Ứng phó giới hạn: 1 hành động, nửa tiền/thóc làm tròn lên; bảo vệ một nửa phần còn thiếu, tổn thất còn lại áp dụng ngay.
- Chưa huy động: không cấp tiền/thóc; ngự phê tốn một hành động, quá hạn không tốn hành động. Tổn thất phần chưa bảo vệ áp dụng ngay.

Mỗi bản trước chưa bảo vệ đầy đủ tăng 20% kinh phí bản sau. Phí cơ sở xét mức độ; khối lượng cũ đã làm được trừ khỏi phần phải cấp lại.

Tổn thất = thiệt hại biên soạn × `(3 + mức × 0,6)` × `(1 − chuẩn bị × 0,1)` × tỷ lệ chưa bảo vệ, làm tròn. Dự báo và thực thi dùng cùng hàm. Tổn thất đi qua sổ thu chi ngay, không trừ lại lúc tổng kết; chỉ số cạn khiến lượt kết thúc ngay.

Đủ bốn phần nhận thưởng/cam kết đủ điều kiện. Mức ứng phó tương đương = tổng phần trăm bảo vệ chia 100, lấy phần nguyên. Mức 0/1 có dư âm 2/1 mùa; bốn phần bảo vệ một nửa được tính là ứng phó hai phần. Sau tổng kết nghỉ trọn 3–5 mùa. Người kế vị đã mất không được hồi sinh, chỉ còn phương án dự phòng.

## Lưu và kiểm thử

`StoryArc` lưu `settlementVersion`, `completedSteps`, `investedValue`, `cashSpent`, `resourceCosts`, `participantIds`, `participantFactions`, quyết định, ngày hẹn và dữ kiện. ID hồ sơ và revision được gateway dùng để chống gửi lặp; quyết toán xóa hồ sơ và chỉ ghi một lần vào sổ/báo cáo. Tải lại không tính lại vốn, chọn lại người hay cấp thêm ứng viên.

Hồ sơ không có `settlementVersion` được đọc là phiên bản 0: giữ toàn bộ định nghĩa cũ (3–4 bước), nhánh, tiền/thóc đã nhận và nghĩa vụ đang tồn tại. Lượt theo tuần cũng dùng định nghĩa cũ. Chuỗi mới theo mùa lưu phiên bản 1 và dùng bộ 12 chuỗi. Giữ RNG, revision, nhóm thành tích và mọi kết quả đã chốt khi nâng bản. 66 đại biến cố giữ cách xử lý hiện có.

Kiểm thử `chain_settlement_test.dart`, `chain_settlement_ui_test.dart` và `chain_settlement_browser_test.dart` bao phủ 12 chuỗi, mốc 0–4/4, tiền/chỉ số/hỗn hợp, thưởng đặc thù, thiếu nguồn lực, người và phe cố định, thiên vị, dừng, quá hạn, bản lưu cũ và chống cấp lặp; UI kiểm tra 1440 và 390 px. Các bài kiểm thử hồ sơ cũ tiếp tục chạy bằng phiên bản 0.
