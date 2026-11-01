# Danh sách Triều thần và Hậu cung

- Avatar hình vuông 4:4 trong thẻ nhân vật của cả hai trang.
- Thanh trạng thái cách đáy avatar 8 px và nằm trên tên. Nút Triệu kiến/Gặp gỡ luôn cách đáy thẻ 16 px; khoảng trống bổ sung nằm trên nút, giữ tất cả nút cùng hàng thẳng nhau.
- Mọi thẻ trong cùng danh sách đang lọc có chiều cao bằng nội dung tự nhiên cao nhất trên toàn bộ các hàng.
- Tính lại chiều cao khi nội dung thay đổi hoặc thẻ cao nhất bị lọc bỏ; không giữ chiều cao cũ.
- Bỏ phân trang 12 người của Triều thần; kiểm tra đủ 46 quan xuất hiện, không có nút chuyển trang. Hậu cung tiếp tục hiển thị toàn bộ.
- Kiểm tra kích thước thật của avatar và thẻ ở các màn hình 1440, 1024, 844, 390, 320 px; mở trang gặp gỡ và bộ lọc hoạt động, không tràn nội dung.
- 17 kiểm tra liên quan đạt; toàn bộ 969 kiểm tra đạt.
- Flutter analyze không có lỗi/cảnh báo; build Web release thành công.
- Ảnh people-*.png và harem-1440x900.png trong thư mục này được tạo bằng bản lưu riêng trong test, không tác động dữ liệu người chơi.
