# Kiểm toán thư viện 66 đại biến cố — 25/10/2026

Bản ứng dụng 0.8.1; luật `mvp-0.8.0`, nội dung 8, schema 2. Tiếp tục được lượt 0.8 nội dung 7.

| Nội dung | Kết quả |
|---|---:|
| Loại đại biến cố | 66 |
| Kịch bản bổ sung đã review | 60 |
| Mục tiêu | 264 |
| Nhóm | 6 |
| Kiểm thử Chrome | 242 đạt |
| Kịch bản mới 0/4 có nguy cơ kết thúc ở chỉ số 40 | 60/60 |
| Đối chiếu lời dẫn, 240 mục tiêu mới và hai đầu kết quả với bản review | Khớp |
| Phân tích tĩnh | Không có vấn đề |

**Phạm vi kiểm tra:** đầy đủ tập con mục tiêu của cả 66 loại để bảo đảm hoàn thành thêm không làm thiệt hại nặng hơn; thực hiện hợp lệ cả 66 loại trong hạn 6 tuần; các mức 0–4 mục tiêu, chết do hậu quả, trừ tiền vượt kho chuyển thành nợ, hoàn thành sớm và mục tiêu hoàn tất vào đúng hạn; quan bận, thay quan, gián đoạn, trạng thái người kế vị và xác nhận hồ sơ; ngân khố dự toán khớp nguồn thu định kỳ, hết kỳ dừng và biên nhận chống thực thi lại.

**Lịch 60 năm:** mô hình lịch 156 lượt chọn, có mùa, tuần, chiến tranh/thời bình và nợ thay đổi, xác nhận tiếp cận đủ 66 loại và tiếp tục sau khi hết vòng nội dung. Kiểm tra này đánh giá scheduler; không giả định một bot có thể sống qua 60 năm hoặc khẳng định mọi người chơi đều gặp đủ 66 loại nếu thiếu điều kiện.

**Lưu trữ thật:** đóng/mở lại IndexedDB giữ mục tiêu đang làm, random/revision, nội dung 7 → 8, thành tựu, người kế vị, nguồn thu và nghĩa vụ; gửi lại lệnh tổng kết không thêm thưởng hoặc nguồn thu lần hai.

**Nguồn thu hữu hạn:** DB-12 (5 tiền × 8 tuần), DB-18 (4 × 8), DB-38 (6 × 8), DB-60 (4 × 6). **Cam kết có phí:** cầu thân gốc (3 × 6), DB-08 (3 × 6), DB-13 (4 × 6); gắn với mục tiêu được nêu trước khi giao việc.

**Smoke test:** công cụ chơi cũ, vốn bỏ qua nhiệm vụ, đã chạy 5 seed qua engine thật và kết thúc đúng luật; không dùng mẫu này để công bố trung vị cân bằng. Số liệu trung vị của bản trước ở balance-audit-08.md là lịch sử, không đại diện cho thư viện và mức phạt hiện tại.

Tái lập:

```sh
flutter analyze
flutter test --platform chrome --reporter expanded
dart run tools/audit_majors.dart
dart run tools/audit_events.dart
flutter build web --release --no-web-resources-cdn
```
