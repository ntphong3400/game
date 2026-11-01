# Bộ máy triều đình — 0.23.1

- Phân tích mã: không có lỗi/cảnh báo.
- Toàn bộ 945 bài kiểm tra đạt.
- 3 bài kiểm tra giao diện ở 1440×900, 390×844, 320×568 đạt và đã chụp ảnh thật.
- Build Web release thành công vào `build/web`.

Sổ hiển thị dạng danh sách đủ 46 vị trí, sắp theo phẩm chức vụ Nhất → Cửu. Màn hình rộng có năm cột: chức vụ, phẩm yêu cầu, người đang giữ chức, trạng thái passive, bổ nhiệm/cắt chức. Mỗi chức chiếm một dòng riêng; dòng Tể tướng dưới 86 px ở 1440×900. Màn hình hẹp xếp thông tin trong cùng mục, không tràn ngang. Bỏ chân dung và phần thông tin dài; tên quan mở chi tiết, tooltip passive/biểu tượng thông tin cung cấp điều kiện và giải thích. Đã xem lại ảnh chụp cả ba kích thước. Kiểm tra bao gồm một quan Nhất phẩm giữ chức Thư lại để bảo đảm phẩm cá nhân không làm thay đổi thứ tự chức vụ. Hai Ngự y, hai Mật thám và các chức địa phương cùng tên vẫn có vị trí riêng. Chức không có passive không hiển thị điều kiện kích hoạt giả hoặc phạt passive.

Đã kiểm tra mở sổ không thay đổi bản lưu; hủy xác nhận cắt chức không tiêu tài nguyên; xác nhận tốn một hành động, giữ ngân khố/phẩm/công trạng; vị trí trống được lưu lại, không tự bổ nhiệm; có thể bổ nhiệm lại từ danh sách chờ. Các kiểm tra luật xác minh tác động ngược passive, điều chỉnh thuế âm, người chưa đủ điều kiện đóng góp 0, chặn cắt chức người bận, không phạt lặp khi tải lại và bù trừ tác động trái dấu trước giới hạn 0–100.

Ảnh dùng bộ nhớ riêng của test, không thay đổi IndexedDB của người chơi. Ván đã dùng hệ 9 phẩm áp dụng cập nhật sau khi tải lại trang, không cần bắt đầu lại.
