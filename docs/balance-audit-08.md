# Kiểm tra cân bằng 0.8 — 25/10/2026

> Số liệu lịch sử với mốc tăng độ khó đầu tiên ở tuần 27. Sau yêu cầu đổi sang tuần 8, và tăng mạnh hình phạt đại biến cố, các số dưới đây không đại diện cho cân bằng hiện tại.

Mô phỏng dùng cùng `GameEngine`, seed 1–100, tối đa 260 tuần. Chỉ gửi lệnh hợp lệ, không sửa chỉ số hoặc ghi scoreboard. Số tuần là tuần hoàn thành, không cộng tuần thất bại.

Đối chứng 0.7.4 lấy từ snapshot source ngay trước thay đổi, chạy cùng mã chính sách `active`. Công cụ hiện tại giữ chính sách đó và thêm `prepared`, có đọc mục tiêu, giao việc, xử lý chuỗi, vay cứu nguy và dùng nguồn thu chủ động. `prepared` là một chính sách khác; không dùng chênh lệch giữa hai chính sách để suy ra mức tăng/giảm độ khó của cùng cách chơi.

| Luật / chính sách | Nhỏ nhất | Trung vị | P90 | Lớn nhất |
|---|---:|---:|---:|---:|
| 0.7.4 / active | 36 | 74 | 107 | 128 |
| 0.8 / active (cùng chính sách cũ) | 14 | 30 | 39 | 44 |
| 0.8 / prepared | 38 | 76 | 105 | 126 |
| 0.7.4 / chỉ sang tuần | 5 | 5 | 5 | 5 |
| 0.8 / chỉ sang tuần | 5 | 5 | 5 | 5 |
| 0.7.4 / chỉ nghỉ | 5 | 5 | 5 | 5 |
| 0.8 / chỉ nghỉ | 5 | 5 | 5 | 5 |

Tất cả lượt kết thúc trước cap, không có lượt còn sống bị coi nhầm là kết cục.

- `active` trên 0.8 gặp 124 đại biến cố đã tổng kết, bỏ toàn bộ mục tiêu (0/4), không có lần 4/4. Trung vị ngắn hơn đối chứng cho thấy bỏ qua nhiệm vụ và nghĩa vụ mới gây hậu quả rõ rệt.
- `prepared` trên 0.8 tổng kết 370 đại biến cố: 290 lần 4/4, chỉ 2 lần 0/4; tổng 1.341 mục tiêu hoàn tất trên 1.480 mục tiêu. Có thể ứng phó tốt và tiếp tục trị vì bằng chiến lược chủ động.
- Kết cục `prepared`: 43 dân biến, 36 bộ máy tan rã, 8 ngoại xâm, 4 quân đội tan rã, 9 đảo chính. Đây là điểm cần quan sát khi chơi thử tiếp: ưu tiên nhiệm vụ quá nhiều vẫn có thể bỏ sót lòng dân và cân bằng phe.

Các bot chưa tối ưu lựa chọn, không đại diện cho mọi người chơi; đây là kiểm tra tác động và khả năng phục hồi, không phải cam kết mỗi lượt sẽ sống 30 hoặc 76 tuần. Nhiệm vụ có lịch xác định để người chơi có thể lập kế hoạch, còn thiếu tiền, quan bận, thời hạn và công việc thường tạo sức ép lựa chọn.

Tái lập trên luật hiện tại:

```sh
dart run tools/simulate.dart --compare
dart run tools/simulate.dart --compare --policy=prepared
```

Đối chứng cần dùng source 0.7.4; chạy công cụ hiện tại không tự chuyển về luật cũ hoặc sửa lượt đã lưu.
