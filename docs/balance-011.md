# Cân bằng 0.11.0 — 25/10/2026

Áp dụng cho nhịp mùa; luật `mvp-0.11.0`, nội dung 12, schema 2. Không thay quy mô thuế vụ Thu hoặc tự cộng/trừ ngân khố khi nâng bản.

## Thời gian và dòng tiền

| Nguồn | Khi nhận tiền |
|---|---|
| Đoàn thương mại | Cuối cùng mùa năm sau; Xuân năm 1 → cuối Xuân năm 2 |
| Đầu tư tấu chương có doanh thu | Cùng mốc W+4; cả nhánh thành công/thất bại cùng ngày hẹn |
| Truy thu tồn | Cuối mùa sau; cooldown 2 mùa, vẫn giảm nền mỗi lần thử |
| Bán lương dư | Khi khép mùa hiện tại; thóc trừ khi giao dịch, chưa có tiền để chi tiếp |
| Nguồn thu sau đại biến cố kinh tế | Lần đầu cùng mùa năm sau tổng kết; các kỳ tiếp theo giữ hữu hạn |

“Qua 3 mùa” được hiểu theo ví dụ cụ thể của yêu cầu: giao Xuân, qua Hạ–Thu–Đông, nhận cuối Xuân năm sau. Đây là W+4, cần 5 lần khép mùa nếu tính cả mùa giao. Dùng cùng công thức cho mọi mùa. Quan đi thương mại bận tới ngày về; chỉ một đoàn được hoạt động.

Khoản truy thu/bán lương được xét thành công, thất thoát và chốt số tiền khi thực hiện; phần chuyển kho lưu thành khoản chờ, không tạo tiền ngay. Thất bại vẫn chịu chi phí/hậu quả lúc thực hiện. Lưu/tải không bốc lại khoản tiền; nhận tiền chỉ ghi một lần trong ledger. Dự toán chi thường lệ chưa cộng khoản chờ; lịch công việc hiển thị riêng ngày nhận dự kiến.

## Các lựa chọn và nhân lực

- 8 hành động/mùa; tin giữa mùa sau hành động thứ 4. Làm thêm vẫn một lần +2.
- Lợi ích chỉ số tấu chương còn 65%, tiền 75%, làm tròn xuống tối thiểu 1. Không giảm các hình phạt. Phương án chỉ trả tiền/thóc mà không có đánh đổi chỉ số chịu tiền ×2 (tối thiểu 40), thóc ×1,5. Lợi ích miễn phí tương tự thêm 2 căng thẳng. Đầu tư rủi ro giữ vốn gốc; bảo trợ thương lộ tăng vốn 50%. Phần thưởng từ trường học, quân khí và kiểm toán cũng giảm.
- Đại biến cố đầu tiên có 3–5 mùa chuẩn bị, khoảng nghỉ sau tổng kết luôn 3–5 mùa, kể cả cuối game. Hạn ứng phó và hình phạt giữ nguyên.
- Nhiệm vụ mới: năng lực tối thiểu `min(75, 60 + 3 × (mức − 1))`; đúng hoặc liên quan chuyên môn, độ phù hợp ≥65. Giá tiền `ceil(gốc × (1,75 + 0,15 × (mức − 1)))`, thóc `ceil(gốc × 1,25)`. Giao lại tính theo phần còn thiếu. Thay người không đủ điều kiện làm gián đoạn; không thể dùng người giỏi nhận việc rồi chuyển cho người yếu để lách yêu cầu.
- Cấm vệ: chi 55, căng thẳng +3 kể cả thất bại; cơ bản giảm 7 tiến độ tùy người phụ trách; chờ 3 mùa giữa hai lần huy động, kể cả thất bại. Điều tra: chi 35, cuối mùa sau nhận kết quả, thành công chỉ giảm 6 tiến độ riêng nghi phạm. Xác suất giảm theo tiến độ và ảnh hưởng của nghi phạm; điều tra mạng lưới từ tấu chương cũng có thể chưa đủ chứng cứ, thành công chỉ giảm 6/người. Lựa chọn tấu chương giảm âm mưu còn 40%, tối đa 4/người.
- Âm mưu tăng nhanh hơn (`3 + (tham vọng − trung thành) ~/ 15` cộng các áp lực cũ), tự giảm 1/mùa. Sau hành động ở mốc 70 còn 35 tiến độ. Chặn âm mưu cho 1 uy quyền; cần cải thiện trung thành và thế cân bằng phe để xử lý nguyên nhân.

## Tiếp tục bản lưu

Nâng lượt mùa cũ trừ tối đa 2 hành động chưa dùng đúng một lần. Không đổi RNG, revision, tiền, ledger, ngày hẹn đã tạo hoặc thành tích cũ. Nhiệm vụ đã mở thiếu cờ `demanding` giữ giá và điều kiện cũ; nhiệm vụ mới lưu cờ này. Lịch đại biến cố đã công bố giữ nguyên; khoảng nghỉ sau lần tổng kết kế tiếp dùng luật mới. Thời hạn/thành quả đã chốt trong khoản chờ được giữ. Các kết quả followup cũ chưa chốt số tiền dùng cân bằng mới khi đến hạn. Nhịp tuần giữ cơ chế cân bằng trước cập nhật.

## Kết quả xác minh

- Phân tích tĩnh sạch.
- Toàn bộ 302 kiểm thử Chrome đạt, gồm giao diện desktop/mobile và IndexedDB thật. Sau chỉnh chi tiết ledger và bảo toàn hành vi tuần, chạy lại 33 ca kinh tế/âm mưu/bỏ bê: đều đạt.
- Kiểm thử mới bao gồm nhận thương mại đúng Xuân năm sau, cả bốn mùa đầu tư, nhánh thành công/thất bại tấu chương, nguồn thu định kỳ bắt đầu muộn, tiền chưa về không chi được, chống nhận hai lần, phí/hiệu ứng giống dự báo, năng lực/chuyên môn bắt buộc dù nhiều tiền, thay người không đủ điều kiện, lịch nghỉ, giới hạn cấm vệ và nâng bản đúng một lần.
- Kiểm toán giữ đủ 450 tấu chương/1.330 lựa chọn và 66 đại biến cố/264 mục tiêu; lời dẫn kịch bản đã duyệt còn khớp.
- Build Web release thành công; máy chủ local trả `version.json` phiên bản 0.11.0.

## Mô phỏng và giới hạn

Mô phỏng chính sách `prepared` qua 100 seed, tối đa 260 mùa, chỉ gửi lệnh hợp lệ vào cùng engine, không sửa trạng thái hoặc ghi scoreboard. Công cụ đã cập nhật để đọc giá/ngưỡng hành động mới và điều kiện nhân sự. Chính sách này ưu tiên nhiệm vụ, xử lý tấu chương rồi dùng phần hành động còn lại; không phải cách chơi tối ưu.

- Thời gian trị vì đã hoàn thành: nhỏ nhất 8, trung vị 11, P90 13, lớn nhất 15 mùa; không lượt nào chạm cap.
- 143 đại biến cố đã tổng kết: 73 lần 4/4, không lần nào 0/4; tổng 481 mục tiêu hoàn thành.
- Kết cục: 40 đảo chính, 27 ngoại xâm, 19 bộ máy tan rã, 12 dân biến, 2 quân đội tan rã.

Số liệu cho thấy người chuẩn bị vẫn có thể hoàn thành đủ mục tiêu, nhưng xử lý âm mưu và ưu tiên nguồn lực cần được chơi thử tiếp. Không có đối chứng cùng chính sách trên snapshot 0.10.1, nên không dùng số liệu này để khẳng định độ khó tăng theo một tỷ lệ cụ thể hoặc thời gian sống của người chơi.

```sh
flutter analyze
flutter test --platform chrome --reporter expanded
flutter build web --release --no-web-resources-cdn
dart run tools/audit_events.dart
dart run tools/audit_majors.dart
dart run tools/simulate.dart --compare --policy=prepared
```


## Điều chỉnh 0.11.1 — cấm vệ có khoảng chờ thực sự

Giới hạn một lần/mùa vẫn cho phép dùng ở mọi mùa nên đã thay bằng ngày mở lại `mùa dùng + 3`. Ví dụ dùng Xuân → Đông, dùng Hạ → Xuân năm sau; hai mùa ở giữa bị khóa hoàn toàn. Thất bại vẫn bắt đầu khoảng chờ; lệnh không đủ nguồn lực bị từ chối thì không bắt đầu. Ngày mở lại lưu trong cooldown, UI và engine dùng chung kiểm tra.

Luật `mvp-0.11.1`, nội dung vẫn 12. Bản 0.11.0 thiếu cooldown được đối chiếu lịch sử lệnh để lấy mùa huy động gần nhất, không bắt đầu lại thời gian chờ khi tải. Nếu chỉ còn bộ đếm mùa hiện tại thì dùng mùa đó làm mốc. Không trừ thêm hành động khi nâng từ 0.11.0.

Mô phỏng và kết quả 302 kiểm thử phía trên ghi nhận bản 0.11.0; số liệu mô phỏng không phải đối chứng cho khoảng chờ mới.

Xác minh 0.11.1: phân tích tĩnh sạch; 16/16 kiểm thử cân bằng đạt, gồm khóa Hạ/Thu sau lần dùng Xuân, mở đúng Đông, thất bại vẫn khóa, lệnh thiếu tiền không bắt đầu chờ và nâng bản không trừ thêm hành động. Các ca hồi quy ngoài bộ cân bằng cũng đạt. Build Web release thành công; máy chủ local trả phiên bản 0.11.1.
