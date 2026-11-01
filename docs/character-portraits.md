# Chân dung nhân vật theo tuổi

## Bộ ảnh

| Nhóm | Diện mạo | Chân dung theo tuổi |
| --- | ---: | ---: |
| Hoàng đế | 1 | 3 |
| Triều thần | 60 | 180 |
| Hậu cung | 30 | 90 |
| Tổng | 91 | 273 |

`assets/images/portraits/` chứa 91 ảnh WebP. Mỗi ảnh là một bộ ba ô vuông theo thứ tự trái sang phải: trẻ, trung niên, lão niên. Mỗi tệp 1536 × 512 pixel, tương đương 512 × 512 pixel/tuổi. Giữ ba ô trong cùng tệp giúp tải một diện mạo và chuyển tuổi mà không cần tải ảnh khác.

- Trẻ: dưới 35 tuổi; mẫu minh họa 25 tuổi.
- Trung niên: 35–54 tuổi; mẫu minh họa 45 tuổi.
- Lão niên: từ 55 tuổi; mẫu minh họa 65 tuổi.

Phong cách bán hiện thực vẽ tay, bối cảnh cung điện/thư phòng/sân vườn có chiều sâu. Hoàng đế chính diện và uy nghiêm; các nhân vật khác có nhiều góc nghiêng. Mỗi nhân vật giữ cùng góc mặt, trang phục và đặc điểm khuôn mặt qua ba tuổi. Không có nốt ruồi. Ba bộ mẫu người dùng đã duyệt được giữ lại làm `emperor`, `official-001`, `harem-001`.

## Gán diện mạo

`lib/game/models/portraits.dart` định nghĩa danh mục, ngưỡng tuổi và ánh xạ 45 nhân vật có sẵn. Các nhóm trang phục triều thần gồm văn quan (001–016), võ ban (017–028), địa phương (029–042), hoàng thất (043–048), nội đình (049–054) và ứng viên dự phòng (055–060).

`Courtier.portraitId` được lưu cùng nhân vật. 35 triều thần và 10 tú nữ định sẵn có khuôn mặt riêng. 12 ứng viên đầu ván nhận 12 khuôn mặt khác, nên toàn bộ 57 người đầu ván không trùng diện mạo.

`GameState.ensurePortraits()` xử lý cả nhân vật mới và bản lưu cũ:

1. Giữ nguyên mọi diện mạo đã lưu hợp lệ.
2. Gán các diện mạo cố định cho nhân vật có sẵn trước khi xử lý người sinh thêm.
3. Với người mới, ưu tiên diện mạo chưa từng được gán; quần áo phù hợp nhóm/chuyên môn được xét trước.
4. Khi không còn diện mạo mới, tái sử dụng diện mạo không còn ai đang hoạt động sử dụng. Người bị bãi chức hoặc qua đời có `available = false`.
5. Nếu toàn bộ 60 diện mạo nam hoặc 30 diện mạo nữ đang được sử dụng, cho phép dùng chung diện mạo có ít người dùng nhất. Số lượng nhân vật không bị giới hạn bởi bộ ảnh.

Việc gán không dùng RNG của gameplay. Không thay đổi luật tuổi tác, xác suất tử vong, chi phí, lịch tiến cử hoặc trạng thái chơi. Bổ nhiệm, nhập cung, phong hậu và tuổi tác không đổi `portraitId`. Ảnh hoàng đế lấy tuổi thật của nhà vua ở màn Long thể. Mọi vị trí dùng `CharacterPortrait` lấy ảnh theo tuổi thật của người được hiển thị.

## Nguồn và rà soát

- Tạo bằng built-in `image_gen`; không dùng CLI/API thay thế.
- Bộ prompt đầy đủ: `output/avatar-generation/prompts.json`.
- Bản PNG gốc: `output/avatar-generation/source/`.
- Ảnh WebP trong game: `assets/images/portraits/`.
- Bảng rà soát: chạy `swift tools/portrait_review.swift`, kết quả trong `output/avatar-generation/review/`.
- Đóng gói và kiểm tra nguồn ảnh: `python3 tools/package_portraits.py` (cần `cwebp` trong PATH). Xuất `output/avatar-generation/manifest.json` với kích thước, dung lượng, SHA-256 từng tệp và trang lọc xem cả ba tuổi tại `output/avatar-generation/review.html`.
- Bộ 16 ô cũ vẫn được giữ trên đĩa để tham chiếu; không còn được đăng ký trong bundle hoặc sử dụng khi chơi.

Kiểm tra bằng `test/portraits_test.dart`: đủ danh mục và tài nguyên, ranh giới tuổi, gán không trùng, dùng hết bộ/tái sử dụng, bổ nhiệm, tiến cử, tăng tuổi hằng năm, nâng cấp bản lưu và hiển thị widget. Các kiểm tra gameplay và giao diện hiện có cũng phải tiếp tục qua.

Kết quả đóng gói: 91 atlas WebP, tổng 10,95 MiB; cả 91 atlas được tải từ Flutter asset bundle và giải mã thành công ở kích thước 1536 × 512. Toàn bộ 604 bài kiểm tra qua; bản Web release build thành công. Phân tích tĩnh không có lỗi/cảnh báo.

Đã kiểm tra bản Web release trên trình duyệt ở Triều thần, Hậu cung và Long thể. Ảnh hiển thị đúng nhóm/tuổi, không có lỗi hoặc cảnh báo console. Ảnh chụp nằm trong `output/avatar-generation/review/game-court.jpg`, `game-harem.jpg`, `game-emperor.jpg`; bản ghép `game-preview.png`.
