# Hàn Kỳ, Xích Lĩnh và Bích Trạch

Từ Giang Sơn, bấm tên nước để mở toàn cảnh riêng. Mỗi nước có đúng ba điểm đến: **Vương cung**, **Sứ quán**, **Biên thành**. Trang giữ HUD của người chơi, nút về Giang Sơn, khóa mùa/sang tuần và chong đèn làm thêm. Tên nước, quan hệ, tình trạng và ưu thế của ta lấy từ bản lưu, không dùng số liệu minh họa trong mockup.

## Công trình

- **Vương cung:** tình hình bang giao, giao hảo, tuyên chiến. Khi đang chiến tranh hoặc có hòa ước, có lối sang Sứ quán. Dùng cùng chi phí, điều kiện và bước xác nhận như Quân sự.
- **Sứ quán:** đình chiến, cầu hòa, yêu cầu triều cống; hòa ước, kỳ thanh toán, nợ cống, trả bù, gia hạn và bảo hộ. Chỉ hiển thị nước đã chọn.
- **Biên thành:** quân số đối phương, chất lượng, độ kiên cố, tăng viện gần nhất; chiến dịch và quân báo của nước này. Nút đến cửa ải đối diện hoặc Cửa Ải để chọn quân/tướng, xuất trận, tiếp tế và rút quân. Quân triều đình tiếp tục quản lý tại ba ải.

Không thêm hệ thống quốc vương, kinh tế nước ngoài hay luật chiến tranh. Mở trang và chuyển điểm đến không ghi lệnh hoặc tiêu hành động. Mọi hành động ngoại giao vẫn đi qua GameController và bước xác nhận hiện có.

## Tranh và màn hình hẹp

Ba nền sạch được ImageGen dựng từ mockup đã duyệt, xóa toàn bộ chữ và giao diện trước khi xuất WebP. Hàn Kỳ có núi tuyết và rừng thông; Xích Lĩnh có núi đất đỏ và thương lộ; Bích Trạch có hồ, sông và bến thuyền. Các nút thật neo vào mái công trình, cùng cuộn với tranh. Tỷ lệ tranh 8:5; màn hẹp kéo ngang và dọc để xem đủ ba điểm. Bảng quan hệ chuyển thành dải nhỏ dưới HUD trên màn hình hẹp để giữ chỗ cho tranh và nhãn.

Assets: `assets/images/country-{north,west,south}-watercolor.webp`. Prompt thực tế: `output/country-implementation/background-prompts.txt`; mockup gốc: `output/neighbor-country-mockups/`.

## Điều hướng và tương thích

- Tổng quan: `country-north`, `country-west`, `country-south`.
- Chi tiết: thêm `-palace`, `-embassy` hoặc `-border`.
- Cửa ải giữ các route `frontier-*` hiện có. Quân sự vẫn có thể mở từ HUD/danh mục và giữ nguyên nội dung tổng quan.
- Bản lưu cũ chưa có mô hình bang giao vẫn mở được tranh và ba điểm; phần chi tiết giải thích chưa có dữ liệu và dẫn về Quốc sự. Không tự tạo thông tin nước ngoài hoặc thay đổi bộ luật của bản lưu.

## Kiểm tra và xem trước

- `flutter analyze`
- `flutter test --dart-define=COUNTRY_PREVIEWS=true test/country_ui_test.dart` kiểm tra cả ba nước, ba điểm đến, quay lại, dữ liệu không bị ghi khi duyệt, xác nhận/hủy giao hảo, hòa đàm/nợ cống, lọc quân báo, dẫn đúng cửa ải và bản lưu cũ. Ảnh thực tế ghi vào `output/country-implementation/` ở 1440×900, 1024×768, 390×844, 320×568 và 844×390.
- Chạy lại kiểm tra Giang Sơn, biên ải và chiến tranh vì dùng chung điều hướng và WarfarePanel.
- `flutter build web --release` dựng bản chính.
- Bản xem trước riêng: `flutter build web --release --target tools/country_preview.dart --output build/country-preview`. Phục vụ thư mục này bằng web server. Tham số: `country=north|west|south`, `place=palace|embassy|border`, `scenario=war`. Dùng MemoryGameStore, không đọc/ghi bản lưu của người chơi.
