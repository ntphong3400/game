# Quốc sự — bàn điều hành

Quốc sự giữ đúng năm mục đã chốt. Giao diện dùng giấy ngà, mực xanh ngọc và vàng đồng; thu gọn phần cảnh điện nghị sự để dành thêm chỗ cho công việc.

1. **Ban hành công việc:** thẻ công văn theo từng lệnh, dùng cùng mép giấy nhiều lớp và góc đồng của Triều chính, có dải ngọc, tranh thủy mặc riêng, chuyên môn, mô tả ngắn và chi phí tiền/thóc/hành động riêng. Nút “Xem & giao việc” mở đầy đủ tác dụng, rủi ro và danh sách quan; chọn quan rồi xác nhận mới gửi lệnh. Lệnh chưa dùng được hiển thị lý do.
2. **Đang thực hiện:** số việc đang chạy, người phụ trách, tiến độ và ngày dự kiến hoàn tất. Công việc chờ hồi âm hoặc kết quả tiếp tục hiện trong cùng mục.
3. **Nghĩa vụ và ảnh hưởng đang hiệu lực:** mỗi nghĩa vụ có tên, thời điểm bắt đầu, số kỳ còn lại và khoản thu/chi hoặc ảnh hưởng. Khoản phải trả dùng màu đỏ đất, nguồn thu dùng xanh ngọc.
4. **Đối sách khẩn cấp:** hàng nút công văn với biểu tượng, tóm tắt chi phí/tác dụng và mũi tên. Hộp xác nhận giữ đầy đủ điều kiện và nghĩa vụ về sau; điều kiện chưa đạt hiện ngay dưới từng đối sách. Xem hoặc hủy không gửi lệnh.
5. **Kết quả đã nhận:** bộ chọn mùa/tuần và báo cáo kết quả hiện có. Khi chưa có dữ liệu, hiển thị lời giải thích ngắn.

Bốn mục phụ luôn có nút mở chi tiết ngay trong vùng nhìn thấy, không cần cuộn trang:

- Màn rộng đặt Nghĩa vụ, Đối sách khẩn cấp, Đang thực hiện và Kết quả đã nhận trong một khung cố định bên phải. Bốn công văn cùng chiều rộng xếp dọc; mỗi công văn có tranh riêng, mép giấy nhiều lớp, góc đồng, số lượng/trạng thái và nút “Mở sổ”; danh sách công việc bên trái cuộn riêng.
- Màn hẹp đặt bốn ô trước công việc, cố định phía trên vùng cuộn; dùng tranh thu nhỏ khi đủ chỗ để chữ vẫn đọc được. Khi chiều cao hạn chế, dùng ô tên ngắn hơn, vẫn mở được đủ nội dung. Thanh HUD và thanh khép mùa giữ vị trí.
- Sổ chi tiết có nút “Về Quốc sự”; nghĩa vụ và báo cáo dài chỉ cuộn trong sổ. Xem, mở/đóng hoặc chọn kỳ báo cáo không gửi lệnh chơi.
- Đối sách mở đủ điều kiện và chi phí trước khi xác nhận. Sau khi ban lệnh, dữ liệu sổ, trạng thái nút và số nghĩa vụ cập nhật từ trạng thái đã lưu; không cần đóng/mở lại.
- Các bản tóm tắt chỉ lấy tối đa hai nghĩa vụ và báo cáo gần nhất; dù lịch sử dài, bốn ô không bị đẩy khỏi màn hình.

Không hiển thị thế cục, đại biến cố, chuỗi tấu chương, lịch hoặc lịch sử đại biến cố. Ngự phê vẫn ở Triều chính. Không đổi engine, dữ liệu nội dung, chi phí, xác suất, luật hoặc schema bản lưu.

## Chất liệu theo mockup đã chốt

- [Mockup thẻ công việc đã duyệt](kingdom-watercolor-mockup.png).
- [Mockup bốn công văn cố định đã duyệt](kingdom-dossiers-mockup.png): sổ nghĩa vụ và tiền, chỉ dụ khẩn cấp, công việc đồng ruộng và người đọc báo cáo. Bốn công văn luôn hiện cùng lúc; màn thấp tự thu gọn phần xem trước.
- Bốn tranh công văn được tạo bằng imagegen tích hợp, đóng gói WebP quality 90 (tổng khoảng 573 KiB) trong `assets/images/kingdom/dossier-*.webp`. [Prompt và nguồn tranh](kingdom-dossiers-assets.json); atlas gốc ở `output/imagegen/kingdom-dossiers-atlas.png`.
- [Cận cảnh bốn công văn từ Flutter](kingdom-dossiers-panel.png); [desktop](kingdom-dossiers-desktop.png); [điện thoại](kingdom-dossiers-mobile.png).
- Bảy tranh riêng cho chấn chỉnh, cứu tế, hòa giải, luyện quân, khai khẩn, cấm vệ và hòa đàm nằm trong `assets/images/kingdom/`.
- Tranh được tạo bằng imagegen tích hợp, đóng gói WebP quality 90, tổng khoảng 560 KB. [Prompt, nguồn và vị trí từng tranh](kingdom-watercolor-assets.json). Atlas gốc được giữ ở `output/imagegen/kingdom-paintings-atlas.png`.
- Mép giấy và góc đồng tái sử dụng `MemorialPaper` của Triều chính; nhãn, chi phí, trạng thái, nút và tiến độ đều là Flutter. Không dùng ảnh mockup làm giao diện.
- [Cận cảnh thẻ thật](kingdom-watercolor-card.png); [toàn màn desktop 1672×1000](kingdom-focused-1672-active-orders.png).

## Xem giao diện

Ảnh được render từ widget, font và tài nguyên thật của Flutter. Trạng thái minh họa dùng bản lưu trong bộ nhớ, tách khỏi dữ liệu người chơi.

- [Desktop — giao việc và nghĩa vụ](kingdom-focused-1440-active-orders.png)
- [Desktop — tiến độ](kingdom-focused-1440-active-progress.png)
- [Desktop — kết quả](kingdom-focused-1440-active-results.png)
- [Điện thoại — giao việc](kingdom-focused-390-active-orders.png)
- [Điện thoại — nghĩa vụ](kingdom-focused-390-active-obligations.png)
- [Điện thoại — kết quả](kingdom-focused-390-active-results.png)

## Kiểm tra

- `test/kingdom_layout_ui_test.dart`: bốn nút luôn thấy và bấm được ngay, mở/đóng sổ trên 1440×900, 1280×720, 844×390, 760×600, 390×844, 320×568 và điện thoại với cỡ chữ 130%; không tràn và không thay đổi trạng thái/bản lưu khi xem; desktop xác nhận cả bốn công văn có cùng chiều rộng và xếp dọc. Kiểm tra thêm 30 nghĩa vụ/30 báo cáo và ban đối sách thật: lưu một lần, cập nhật sổ ngay và chặn dùng lặp khi nghĩa vụ còn hiệu lực.
- `tools/kingdom_visual_test.dart`: sáu kiểm tra render ở desktop/mobile (1672×1000, 1440×900, 390×844), gồm trạng thái trống và có công việc, nghĩa vụ, kết quả.
- Các kiểm tra giao quan, xem trước/hủy/xác nhận, đối sách khẩn cấp, lịch sử báo cáo và tải lại tiếp tục được giữ.

- `flutter test --reporter expanded`: 621 bài đạt; `flutter analyze`: không có vấn đề; `flutter build web --release`: thành công.
