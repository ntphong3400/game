# Thăng phẩm trực tiếp và badge trang chi tiết

- Trang Triệu kiến hệ 9 phẩm thay Hồ sơ & chức vụ bằng Thăng phẩm, mở trực tiếp popup.
- Popup liệt kê mọi phẩm cao hơn, hỗ trợ thăng vượt. Mỗi dòng hiện công trạng, vàng, hành động, năng lực, thành tích lớn; mức chưa đạt khóa RadioListTile và ghi rõ lý do.
- Mức được chọn có xem trước công trạng còn dư, thiện cảm tăng và bất mãn giảm. Hủy không đổi dữ liệu; chỉ xác nhận mới gửi lệnh promote.
- Nhất phẩm thông báo đã đạt phẩm cao nhất, không có thao tác thăng tiếp. Tài nguyên thay đổi khi đang mở làm mức đã mất điều kiện bị bỏ chọn, khóa xác nhận tới khi chọn lại mức hợp lệ.
- Badge ở danh sách, trang chi tiết và popup đều dùng CourtGradeBadge với cùng màu/biểu tượng/số 1–9; cập nhật ngay sau thăng phẩm.
- Kiểm tra Cửu lên Thất: 5 công trạng, 1.800 vàng, 1 hành động, thiện cảm +5, bất mãn −10; chức vụ đang giữ không đổi.
- Đã kiểm tra ở 1440×900, 390×844, 320×568; 24 kiểm tra giao diện liên quan và toàn bộ 981 kiểm tra đạt.
- Flutter analyze không có lỗi/cảnh báo; build Web release thành công, máy chủ local trả HTTP 200.

Ảnh promotion-*.png chụp từ bản lưu riêng của test. Ảnh trang chi tiết có badge mới và nút Thăng phẩm: ../court-rank-actions/retirement-1440.png. Không sửa IndexedDB của người chơi.
