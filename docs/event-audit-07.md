**Kiểm kê sự kiện — bản 0.7, 25/10/2026.** Nguồn kiểm kê là catalog mà game dùng khi chạy, qua `dart run tools/audit_events.dart`.

| Hạng mục | Số lượng |
|---|---:|
| Sự kiện gốc | 45 |
| Sự kiện mới | 405 |
| Tổng sự kiện | **450 (10 lần)** |
| ID / tiêu đề / mô tả không trùng | 450 / 450 / 450 |
| Tổng lựa chọn | 1.330 |
| Nhóm nội dung mới | 15 × 27 tình huống |
| Mẫu đánh đổi mới | 45 (3 mỗi nhóm) |
| Lựa chọn có kết quả trì hoãn | 152 |
| Trong đó có nhánh thất bại | 143 |

15 nhóm gồm Dân sinh, Ngân khố, Thương mại, Nông nghiệp, Công trình, Quân sự, Ngoại giao, Pháp luật, Triều chính, Phe phái, An ninh, Hậu cung, Sức khỏe, Thiên tai và Văn hóa.

Mỗi tình huống có mô tả và ba nhãn quyết định được viết riêng trong [event_stories.dart](../lib/game/data/event_stories.dart). Các quy tắc thưởng/phạt dùng chung theo mẫu quyết định ở [expanded_events.dart](../lib/game/data/expanded_events.dart), nên 405 tình huống không đồng nghĩa 405 cơ chế hoàn toàn khác nhau. Ví dụ, bảo trợ xưởng giấy và thử giống cây đều là đầu tư có rủi ro, nhưng nguồn lợi, tổn hại và thời gian chờ khác theo nhóm. Tình huống không được tạo bằng cách thay tên trong một câu mẫu.

**Giảm lặp.** Giữ nhịp 0–2 sự kiện thường mới mỗi tuần. Lọc theo điều kiện và cooldown, ưu tiên số lần xuất hiện thấp nhất, rồi ưu tiên nhóm giãn ít nhất 3 tuần và thể loại khác hai thể loại vừa gặp. Giãn nhóm/thể loại là ưu tiên có thể nới nếu không còn phương án khác; điều kiện nội dung luôn bắt buộc. Lưu lịch sử theo lượt để tải lại không làm quên sự kiện đã gặp.

Khủng hoảng đói có 4 biến thể, dân biến 7, tranh ngôi/âm mưu/lũ mỗi loại 4. Mỗi nguyên nhân có cooldown chung và tối đa một tấu chương đang chờ. Khủng hoảng được phép quay lại khi tình trạng xấu chưa giải quyết; không dùng chống lặp để che cảnh báo nguy hiểm.

**Thưởng/phạt.** Có chi tiền hoặc xuất thóc để tăng lòng dân; tận thu lấy tiền nhưng mất lòng dân; nợ để giải quyết trước mắt; ưu ái một phe khiến phe khác giảm thái độ; huy động quân cứu dân làm giảm quân lực; tự xử công việc tốn hành động/mệt mỏi; nghỉ giảm áp lực nhưng mất cơ hội dùng hành động; thuốc thử hoặc đầu tư có thể thành công hay gây thiệt hại. Lựa chọn hiện đầy đủ hiệu ứng, chi phí, hạn và xác suất trước khi chọn. Kết quả chờ được bốc/lưu lúc xác nhận, chỉ công bố và áp dụng khi đến hạn.

**Kiểm tra tự động.** `test/event_catalog_test.dart` kiểm kê đúng 450 sự kiện, ID/tiêu đề/mô tả không trùng, điều kiện/khóa hiệu ứng hợp lệ, toàn bộ 1.330 lựa chọn chạy được qua engine và lưu/tải được; kiểm tra hết hạn ở cả 450 sự kiện. Ngoài ra có kiểm tra đủ tài nguyên, cả hai nhánh kết quả trì hoãn, chỉ áp dụng một lần, thâm hụt chuyển thành nợ, tác động phe/thành viên đang hoạt động, điều kiện nội dung, giãn nhóm và cooldown khủng hoảng.

Fixture phân phối kéo dài 180 tuần dùng trạng thái được ổn định lại mỗi tuần để tách việc kiểm tra scheduler khỏi sinh tồn. Trong fixture này có hơn 120 sự kiện thường khác nhau, không lặp lại sự kiện thường đã chọn. Đây là kiểm tra độ đa dạng của bộ chọn, không phải một chiến thuật chơi hoặc bằng chứng người chơi sống được 180 tuần.

Kiểm thử giao diện ở 1440×1000 và 390×844 xác nhận xem được rủi ro, chọn phương án, lưu kết quả chờ và xem tên/hạn trong Quốc sự. Kiểm tra gateway trên memory và hợp đồng IndexedDB xác nhận gửi lặp không bốc lại, không trừ tiền hay thêm kết quả chờ hai lần. Kiểm tra IndexedDB trình duyệt thật bao gồm giữ nguyên bản lưu 0.6 và thành tích khi bắt đầu lượt mới.

**Chạy lại kiểm kê hoặc xuất toàn bộ nội dung để biên tập:**

```sh
dart run tools/audit_events.dart
dart run tools/audit_events.dart --catalog
flutter analyze
flutter test --platform chrome --reporter expanded
dart run tools/simulate.dart
```

Luật hiện tại: `mvp-0.7.0`, nội dung 6, schema 2. Lượt và thành tích 0.2–0.6 được giữ nguyên trong local, thành tích xem riêng theo bộ luật. Bắt đầu triều đại mới để áp dụng catalog và lịch sử phân phối mới. Toàn bộ xử lý vẫn ở FE, không có backend mới.

**Kết quả lần kiểm tra này.** `flutter analyze`: không có vấn đề; 112 kiểm thử Chrome đều đạt. Mô phỏng qua chính engine với 100 seed (1–100), giới hạn 260 tuần: chỉ skip và chỉ nghỉ đều ghi 5 tuần rồi thua do đảo chính; chính sách chủ động đơn giản ghi trung vị 74 tuần, khoảng 33–132 tuần, p90 là 107. Cả 100 lượt chủ động đều kết thúc trong giới hạn, gồm ngoại xâm 20, dân biến 50, đảo chính 21, quân đội tan rã 6, triều đình tan rã 3. Bot vẫn dùng cách đánh giá lợi ích tức thời cũ nên chưa định giá tối ưu khoản đầu tư mới; đây là kiểm tra lỗi/pacing, không phải thước đo độ dài tối đa hoặc bảo đảm cân bằng cuối cùng.
