# Kho Lương và sổ tài nguyên dùng chung

Kho Lương (`/locality/granary`) mở bằng **Sổ kho lương**: chọn mùa, số đầu mùa/hiện có/dự kiến cuối mùa, nhóm nhập–xuất và chi tiết theo thứ tự phát sinh. Các việc mua lương, cứu trợ, bán lương cùng tấu báo và công việc đang thực hiện vẫn nằm trong trang này. Ngân khố dùng cùng `ResourceLedgerPanel`, `ResourceLedgerRow` và `ResourceLedgerLine`; mỗi tài nguyên tự cung cấp dữ liệu và dự toán riêng.

## Ghi sổ

- `FoodWeek` lưu kỳ, tồn đầu/cuối, sức chứa, trạng thái chốt và danh sách `FoodEntry`. Giao dịch ghi lượng thực thay đổi kho, yêu cầu ban đầu, số dư sau giao dịch và thông tin khẩu phần.
- Đối chiếu: **tồn đầu + thực nhập − thực xuất = tồn cuối**. Mua lương, công trình, thu hoạch, tấu chương, kết quả đến hạn, chi quân sự, thiên tai và tiêu dùng cuối mùa đi qua cùng hàm nhập–xuất. Mất lương do lũ phát sinh đầu mùa mới thuộc sổ mùa mới.
- Kho đầy chỉ ghi phần nhận được vào tổng nhập. Phần không nhập được hiển thị riêng; không tạo một khoản chi giả. Thiếu lương chỉ ghi phần xuất được, kèm nhu cầu và lượng thiếu; tồn kho không âm.
- Lương cứu trợ/tiếp tế xuất kho như bình thường. Phần khẩu phần đã cấp trước được ghi riêng, không cộng vào thu. Khi khép mùa, phần này đối trừ nhu cầu toàn quốc; kho chỉ chịu phần nhu cầu còn lại. Khoản đối trừ chưa dùng kết thúc cùng mùa, không thành lương nhập và không chuyển sang mùa sau.
- Sổ được chốt sau toàn bộ xử lý cuối mùa, trước khi mở mùa kế tiếp. Kết thúc triều đại cũng chốt sổ hiện tại. Mở trang, đổi kỳ và mở chi tiết không phát sinh giao dịch hoặc thay đổi RNG.

## Dự toán và bản lưu cũ

Mùa hiện tại dự toán tiêu dùng còn phải cấp và thu hoạch nếu đang mùa Thu. Thu hoạch dùng thời tiết 100%, đê sau hao mòn mùa này và mẫu lao động mùa này; có khoảng dao động thời tiết 90–110%. Lương thu hoạch nhập trước tiêu dùng. Dự toán chưa gồm công việc, tấu chương, sự kiện đến hạn hoặc thay đổi dân cư sau đó, nên kết quả thực có thể khác. Sổ lịch sử chỉ hiển thị số đã phát sinh.

Trường `foodWeeks` là tùy chọn trong dữ liệu lưu. Bản lưu có dân số nhưng chưa có sổ bắt đầu ghi ở lệnh tiếp theo, lấy tồn kho và khẩu phần cấp trước lúc đó làm số đầu kỳ. Kỳ đang dở được đánh dấu lịch sử chưa đầy đủ; không dựng lại giao dịch trước đó. Dữ liệu bị chỉnh ngoài sổ có khoản đối chiếu riêng và đánh dấu thiếu lịch sử. Lượt lịch sử chưa có dân số giữ cơ chế thóc cũ. Không cần bắt đầu triều đại mới để có sổ.

## Kiểm tra

- `test/food_ledger_test.dart`: đối chiếu từng số dư, mua/bán, cứu trợ, khẩu phần cấp trước, thu hoạch đầy kho, thiếu lương, dự toán, chiến tranh nhiều mùa, kết quả đến hạn, lũ đầu mùa và bản lưu cũ.
- `test/food_ledger_ui_test.dart`: trang thật ở 1440×900, 844×390, 390×844, 320×568; đổi mùa chỉ đọc, hủy/xác nhận mua lương, cập nhật số trên sổ và giữ đúng nhóm hành động.
- `test/food_ledger_browser_test.dart`: IndexedDB, phát cùng lệnh từ hai cửa sổ, thử lại lệnh, chốt khẩu phần một lần và mở lại bản lưu.
- `test/finance_ui_test.dart` và các bộ ngân sách hiện có bảo vệ Ngân khố sau khi chuyển component.
- `flutter test tools/food_ledger_visual_test.dart` tạo ảnh giao diện thật tại `output/food-ledger/` để kiểm tra bố cục và font.
