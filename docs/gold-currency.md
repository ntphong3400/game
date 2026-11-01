# Ngân khố tính bằng lượng vàng

Luật `mvp-0.21.1`, nội dung 19. Lượt theo mùa mới bắt đầu với **50.000 lượng vàng**; dân số, quân số, lương thực và các chỉ số 0–100 giữ nguyên đơn vị.

## Quy đổi

Quy ước kinh tế trong game: **1 đơn vị tiền cũ = 100 lượng vàng**. Giá công việc, thuế, thu nhập, thưởng/phạt, tiền vay, nợ, cống nạp, phí nhân sự và ngưỡng kinh tế cùng dùng tỷ lệ này. Các khoản tiền lưu trong trạng thái và sổ thu chi là lượng vàng nguyên.

| Khoản | Lượng vàng |
|---|---:|
| Ngân khố khởi đầu lượt mới | 50.000 |
| Thu cơ bản ở lao động và ưu tiên kinh tế tham chiếu | 8.000/mùa |
| Duy trì 50.000 quân thời bình | 4.500/mùa |
| Dân sinh thường lệ | 2.000/mùa |
| Luyện quân | 3.500 |
| Tuyển quân thường lệ | 2.500 |
| Tuyển quân khẩn cấp, cả thành công và thất bại | 1.500 |
| Chiêu dân lập ấp | 4.000 |
| Tiếp nhận 10.000 lao động tị nạn | 5.000 |
| Mua cơ bản 200.000 tạ lương thực | 4.500 |
| Vay thế gia | Nhận 12.000; trả 5.000/mùa × 3 mùa |
| Cầu hòa | Chi 2.000; cống 1.600/mùa × 3 mùa |

Tỷ giá mua lương cơ bản tương đương **100 lượng vàng ≈ 4.445 tạ**, làm tròn lên từ 4.444,44 tạ. Hành động hiện tại vẫn mua theo đợt; thực nhận chịu hiệu quả và rủi ro của người phụ trách.

Các công thức biến thiên như thu nhập theo lao động và quân phí theo quân số nhân quy đổi trước rồi mới làm tròn lên. Không lấy số tiền cũ đã làm tròn rồi nhân 100, tránh làm mất độ chính xác của lượng vàng. Các kết quả đã chốt của bản lưu cũ giữ đúng giá trị quy đổi.

## Nội dung và sổ thu chi

Catalog có thể giữ con số gốc làm tham số biên soạn. `currency_rules.dart` chiếu giá và hiệu ứng sang đơn vị thực tại cùng ranh giới mà UI và engine dùng. Giá đã chiếu có dấu `currencyNative`; hiệu ứng vàng/nợ dùng khóa `gold`/`goldDebt`, không bị nhân tiếp khi áp dụng, xếp hàng hoặc nhận kết quả chờ.

Giá bổ nhiệm, chữa bệnh, học tập, cung vụ, phát triển, ngân sách và nghĩa vụ dùng chung hàm tính giá cho xem trước, kiểm tra đủ vàng và chi thực tế. Các ngưỡng nghèo/giàu, áp lực vì nợ, khoản trả nợ tối đa và số dư giữ lại cũng được quy đổi. Phần thưởng chuỗi kinh tế tính theo vốn đã đầu tư bằng vàng, không nhân 100 lần thứ hai.

Các hỗ trợ hậu cung vẫn giữ tham số biên soạn gốc; áp dụng quy đổi tại hàm tính phí/thu nhập. Không nhân lại năng lực, thiện cảm, tỷ lệ thuế, tiến độ, số mùa hoặc số lượt dùng hỗ trợ.

## Bản lưu và tương thích

- Bản lưu dân số 0.21.0 chưa có dấu đơn vị được nâng một lần: số dư, nợ, sổ thu chi, nghĩa vụ, vốn chuỗi, thuế đã thu/khấu trừ và thay đổi tiền trong báo cáo nhân 100.
- **Không đặt số dư bản lưu về 50.000**. Ví dụ đang có 520 tiền thì đổi thành 52.000 lượng vàng; 50.000 chỉ là mức khởi đầu mới.
- Kết quả chờ và nhánh thất bại đã chốt giữ người phụ trách, RNG, xác suất, thời hạn và số lần nhận. Hiệu ứng gốc được quy đổi đúng một lần khi thanh toán.
- Trường `goldStandard` phân biệt đơn vị. Sao chép, tải lại và gửi lại cùng receipt không tiếp tục nhân vàng hoặc thu phí lần nữa.
- Lượt trước mô hình dân số và fixture lịch sử có đơn vị cũ tiếp tục theo hợp đồng cũ. Thành tích gốc không bị đổi nhóm chỉ vì đổi đơn vị.

## Kiểm tra

`test/currency_test.dart` kiểm tra số dư 50.000, giá và ngưỡng, độ chính xác làm tròn, ngân sách/quân phí, vay và trả nợ, tấu chương, kết quả chờ, vốn/thưởng chuỗi, dược liệu, nâng bản lưu và receipt. `test/currency_ui_test.dart` kiểm tra giá mua lương hiển thị khớp khoản vàng thực trừ trên desktop và điện thoại. Bộ kiểm tra dân số, nhân sự, đại biến cố và bản lưu lịch sử tiếp tục được giữ.
