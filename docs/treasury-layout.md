# Ngân khố — sổ đối chiếu và công văn Hộ bộ

Triển khai theo mockup “Bảng đối chiếu gọn” đã được duyệt. Tái sử dụng khung phòng, giấy nhiều lớp/góc đồng của Triều chính và Quốc sự, tranh hiện có, font Lora/BeVietnam. Không thêm tranh hoặc thay tài nguyên của hai tab nguồn.

Màn rộng có sổ bên trái, bốn công văn cùng chiều rộng ở bên phải: Thuế & ngân sách, Việc tăng thu, Kho lương & đê điều, Đang thực hiện. Bấm công văn mở vùng đọc bên trái, có nút Về sổ ngân khố. Màn hẹp có bốn lối mở phía trên sổ; khi đọc công văn, dành vùng nội dung cho công văn và nút quay lại. Màn thấp thu gọn phần tiêu đề và công văn.

Sổ ngân khố có thanh cuộn riêng luôn hiển thị. Cuộn sổ hoặc mở thêm chi tiết không di chuyển HUD, công văn hay nút Khép mùa. Trở lại sổ giữ vị trí cuộn và kỳ đang chọn. Vùng đọc công văn có thanh cuộn độc lập.

## Số liệu trong sổ

- Ba số chính: đầu kỳ (hoặc lúc bắt đầu ghi với sổ một phần), hiện có/cuối kỳ, dự kiến cuối kỳ hiện tại.
- Đã ghi sổ lấy trực tiếp từ `FinanceWeek`/`FinanceEntry`. Nhóm thu gồm mọi khoản tiền dương; chi công việc/phát sinh gồm khoản âm ngoài `budget`/`debt`; chi thường lệ là khoản âm `budget`; trả nợ là khoản âm `debt`. Các nhóm không trùng nhau.
- Sắp tới dùng nguyên `BudgetProjection`: thu thường lệ, thực trả thường lệ (`paidExpense - repayment`) và trả nợ riêng. Không cộng dự toán vào tiền đã ghi, không tính trả nợ hai lần, không đưa công việc/sự kiện chưa nhận kết quả vào thu dự kiến.
- Mỗi nhóm có thể mở các khoản đã ghi và diễn giải dự toán. Chi tiết theo thứ tự phát sinh giữ toàn bộ khoản gốc, kể cả khoản chỉ đổi nợ hoặc không trả được tiền. Giữ số cần trả/đã chi/chưa trả, số dư tiền/nợ sau từng khoản.
- Kỳ lịch sử không hiện cột Sắp tới, dự toán hoặc thuế năm hiện tại. Kỳ mới chưa có sổ không dựng lại thu chi cũ; sổ một phần ghi rõ phạm vi. Lượt đã kết thúc không có dự toán tương lai.
- Nợ tăng/giảm và đối chiếu tiền/nợ hiển thị riêng. Thiếu chi thường lệ có cảnh báo. Thuế vụ Thu chỉ xuất hiện trong dự toán thường lệ khi luật hiện có xác định đến kỳ; ngoài kỳ, ghi rõ chưa tính trong dự toán mùa này.

## Giữ nguyên hành vi trò chơi

Chọn thuế/ưu tiên tiếp tục gửi chính xác lệnh `tax`/`priority` hiện có; chọn chính sách không trở thành lệnh kết hợp. Nút Xem & giao việc tiếp tục dùng quy trình xem trước/chọn quan/xác nhận và kiểm tra điều kiện hiện có của `GameShell`. Chỉ đọc sổ, đổi kỳ, mở/đóng công văn không gửi lệnh hoặc ghi bản lưu.

Không đổi luật, nội dung, mô hình, controller, bộ lưu hoặc cách tính tiền/nợ. SHA-256 của 44 tệp thuộc `lib/game/logic`, `lib/game/models`, `lib/game/data`, `lib/app` được đối chiếu với trước triển khai.

## Kiểm tra và ảnh thật

`flutter test --reporter expanded`: 631 bài đạt; ba bài render giao diện đạt. `flutter analyze`: không có vấn đề. `flutter build web --release`: thành công.

- `test/treasury_layout_ui_test.dart`: 1440×900, 1280×720, 844×390, 760×600, 390×844, 320×568, chữ 130%; mở cả bốn công văn, cuộn độc lập, giữ vị trí khi quay lại, không sửa trạng thái/bản lưu. Sổ 120 giao dịch kiểm tra cuộn tới khoản cuối trên desktop/mobile.
- `test/finance_ui_test.dart`: đối chiếu nhóm tiền, trả nợ không trùng, sổ lịch sử không lẫn dự toán, khoản chưa trả vẫn truy cập được. Các kiểm tra thuế vụ Thu và giao việc thật tiếp tục chạy theo cách điều hướng mới.
- `tools/treasury_visual_test.dart`: render widget/font/ảnh thật với bản lưu minh họa trong bộ nhớ tại 1440×900, 1280×720, 390×844; chụp sổ và bốn công văn. Số tiền minh họa trong ảnh vẫn tính bằng luật thật, không cố định theo mockup.

[Desktop — sổ](treasury-1440-ledger.png) · [chi tiết dự toán](treasury-1440-ledger-detail.png) · [thuế](treasury-1440-tax.png) · [tăng thu](treasury-1440-revenue.png) · [kho lương](treasury-1440-stock.png) · [tiến độ](treasury-1440-progress.png).

[Màn thấp](treasury-1280-ledger.png) · [Điện thoại — sổ](treasury-390-ledger.png) · [Điện thoại — công văn](treasury-390-revenue.png).
