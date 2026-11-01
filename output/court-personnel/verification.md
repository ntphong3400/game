# Kiểm tra hệ 9 phẩm — 0.23.0

- `flutter analyze --no-pub`: không có lỗi/cảnh báo.
- `flutter test --reporter expanded`: 935 bài kiểm tra đạt; bao gồm thăng vượt, công trạng, bổ nhiệm/đổi chỗ/bổ khuyết nguyên tử, passive, bản lưu và UI.
- `flutter build web --release --no-web-resources-cdn`: build thành công vào `build/web`.
- `flutter test test/court_ui_test.dart --dart-define=COURT_PREVIEWS=true`: 6 bài kiểm tra đạt; chụp giao diện thật ở 1440×900, 1024×768, 390×844, 320×568 và Hậu cung 1440×900.
- Chrome headless tải bản release tại `http://127.0.0.1:4173/`: Flutter hiển thị; không có exception JavaScript hoặc HTTP lỗi. Chi tiết: `web-checks.json`, ảnh `web-start.png`.

Ảnh `people-*.png` dùng bản lưu trong bộ nhớ riêng để thể hiện đồng thời passive hoạt động và chưa đủ điều kiện. Không thay đổi IndexedDB hoặc bản lưu của người chơi. Ảnh Hậu cung có một Phi tần mẫu để kiểm tra đóng góp đang hoạt động và các Tú nữ chưa nhập cung.

Ván mới: 46 quan đương nhiệm (12 Văn ban, 10 Võ ban, 6 Hoàng thất, 8 Nội đình, 10 Địa phương) và 12 người chờ bổ nhiệm. Hệ mới được bật bằng `courtSystemVersion`; bản lưu cũ giữ bộ máy cũ. Cần bắt đầu ván mới để sử dụng toàn bộ hệ 9 phẩm.
