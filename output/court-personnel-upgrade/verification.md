# Hồi hương và tấu nhân sự — 0.24.0

- Toàn bộ 969 bài kiểm tra đạt; 23 kiểm tra luật/giao diện nhân sự mới đạt trên bản cuối.
- Flutter analyze không có lỗi/cảnh báo. Build Web release thành công trong build/web.
- Hồi hương mất 1 hành động, không chi vàng; ổn định theo phẩm chức vụ Nhất–Cửu: 8/7/6/5/4/3/2/1/1.
- Uy quyền yêu cầu nghiêm ngặt trên 80/70/60/50 cho Nhất/Nhị/Tam/Tứ; Ngũ–Cửu không có ngưỡng.
- Kiểm tra chống lách qua bổ nhiệm thay người, điều chuyển, đổi chỗ và bổ khuyết; mọi ghế bị thay đổi được kiểm tra trước chi tài nguyên, mỗi ghế tính xáo trộn một lần.
- Người hồi hương giữ danh tính/phẩm/công trạng/quan hệ, có trạng thái riêng và có thể triệu hồi.
- Sinh đủ sáu nhóm tấu theo seed; mục tiêu và ứng viên được lưu lại, không đổi khi xem trước/tải lại. Tối đa một tấu đang chờ, lịch 1–2 mùa; tối đa một ứng viên mới/năm.
- Thưởng tiến cử sau một mùa đầy đủ và đạt yêu cầu; rời ghế hủy theo dõi; mỗi cặp người/chức chỉ thưởng một lần.
- Đặc cách chỉ miễn năng lực; vẫn trừ công trạng/vàng, yêu cầu đại công theo phẩm và giữ nguyên điều kiện passive.
- Bồi dưỡng có thời hạn và đánh dấu bận. Tấu hết hạn/stale được khép lại, không tự hồi hương hoặc bổ nhiệm.
- Giao diện chọn ứng viên khác, xem phí, xác nhận, khóa theo uy quyền và hủy thao tác đã kiểm tra trên 1440×900, 390×844; sổ bộ máy còn kiểm tra ở 320×568.
- Nhận bản lưu 0.23.x; trường mới có mặc định an toàn, schema giữ 2. Ván có hệ 9 phẩm không phải bắt đầu lại.

Ảnh nominate-*.png, patronage-*.png, authority-*.png dùng bản lưu trong bộ nhớ riêng của test, không sửa IndexedDB người chơi. Các log cùng tiền tố court-personnel-upgrade nằm ở thư mục output.
