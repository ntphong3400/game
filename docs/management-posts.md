# Quản lý cửa ải và địa phương — 0.25.0

Đầu ván tự bố trí 12 người vào 12 vị trí. Mỗi người quản lý tối đa một vị trí nhưng vẫn nhận nhiệm vụ. Các vị trí dùng chung sổ chức vụ với Phủ Bá Quan; chức và người quản lý luôn đồng bộ.

## Ba cửa ải

Bắc Ải, Tây Ải, Nam Ải mỗi nơi có một quản lý Doanh trại và một Trấn thủ. Section quản lý đặt đầu Doanh trại/Phủ trấn thủ.

| Vị trí | Bổ nhiệm | Kích hoạt passive | Đóng góp | Tự rèn luyện |
| --- | --- | --- | --- | --- |
| Doanh trại | Võ ban, không yêu cầu phẩm | Năng lực >50 và thiện cảm >50 | +1 huấn luyện/2 mùa tại ải | +1 năng lực/mùa, tối đa 60 |
| Trấn thủ | Võ ban, lục phẩm trở lên | Năng lực >70 và thiện cảm >60 | +1 sĩ khí/mùa tại ải | +0,5 năng lực/mùa, tối đa 70 |

Trấn thủ là chức lục phẩm; ván mới có đúng ba người giữ chức này. Huấn luyện và sĩ khí của bốn nơi đóng quân được lưu riêng, kể cả Kinh Thành. Phòng thủ và xác suất chiến dịch dùng chất lượng của nơi xuất quân; quân khí và tiếp tế vẫn dùng chung.

Điều quân hòa chất lượng nơi đến theo số quân hiện có và số quân điều tới, bảo toàn mức trung bình toàn quân. Tân binh tập kết ở Kinh Thành và chỉ pha loãng huấn luyện tại đây. Thưởng quân, huấn luyện và các tác động toàn quân áp dụng lên từng nơi, giữ chênh lệch giữa các ải; kết quả chiến dịch thay đổi sĩ khí tại nơi xuất phát. Tổng quan quân đội hiển thị trung bình theo số quân đồn trú.

## Ba địa phương

Phủ nha có hai tab: **Quan lại địa phương** mở mặc định; **Điều hành địa phương** giữ các hoạt động điều hành hiện có. Mỗi địa phương có một Tri phủ và một Phò tá.

| Địa phương | Tri phủ | Phò tá |
| --- | --- | --- |
| Bắc Sơn | +200 dân số/mùa | +100 dân số/mùa |
| Đông Hải | +1 đê điều/2 mùa | +1 đê điều/4 mùa |
| Tây Lĩnh | +100 sản xuất quân khí/mùa | +50 sản xuất quân khí/mùa |

Tri phủ thuộc Văn ban, cần lục phẩm trở lên; passive cần năng lực >70 và thiện cảm >60. Tự tăng +0,5 năng lực/mùa đến 70. Ván mới có đúng ba Tri phủ. Phò tá thuộc Văn ban, không yêu cầu phẩm; passive cần năng lực >50 và thiện cảm >50. Tự tăng +1 năng lực/mùa đến 60.

Địa phương đóng góp vào các chỉ số dân số, đê điều và sản xuất quân khí hiện có của quốc gia; sản xuất quân khí được cộng cùng sản lượng công xưởng trước hao mòn.

## Thay người và khép mùa

- Thay người chi đúng **1.000 ngân lượng và 1 hành động**, người cũ −10 thiện cảm, người mới +5. Người cũ trở thành quan chờ bổ nhiệm, giữ phẩm vị, công trạng và nhiệm vụ đang thực hiện. Phí này không kèm thay đổi ổn định hoặc phe phái của cơ chế bổ nhiệm thông thường.
- Khoản −10 áp dụng cả khi người cũ có thiện cảm 100. Các tác động khác giữ quy tắc khóa thiện cảm 100 hiện có.
- Chọn người, xem xác nhận và hủy không thay đổi bản lưu. Không đổi chỗ hai quan hoặc bổ khuyết kèm theo đối với vị trí quản lý. Nếu điều chuyển người đang quản lý, vị trí cũ bị bỏ trống và chịu tác động âm tương ứng; không giữ đồng thời hai vị trí.
- Bỏ trống áp dụng tác động âm cùng mức và chu kỳ; có người chưa đủ điều kiện đóng góp 0. Điều kiện dùng dấu `>`; đúng 50/70 chưa đủ.
- Chu kỳ 2/4 mùa tích lũy số dư có dấu tại vị trí: đủ điều kiện +1 mùa, bỏ trống −1 mùa, chưa đủ điều kiện không đổi. Đủ chu kỳ mới thực hiện tác động nguyên; số dư được giữ khi thay người và lưu/tải.
- Tự rèn luyện không phụ thuộc điều kiện passive. Phần +0,5 được lưu qua các mùa; hai nửa cộng thành một điểm năng lực nguyên. Xét passive trước tăng năng lực, không áp dụng hồi tố. Năng lực đã vượt trần không bị hạ; nhiệm vụ vẫn có thể tăng thêm.

## Bản lưu và kiểm tra

Luật `mvp-0.25.0`, nội dung 22, schema 2. Bản lưu cửu phẩm theo mùa được nâng cấp đúng một lần, không tiêu RNG hoặc thay đổi kết quả nhiệm vụ đã chốt. Chất lượng chung cũ được dùng làm mức đầu cho từng nơi. Giữ phẩm cá nhân khi nâng cấp, đổi chức Trấn thủ thành lục phẩm. Tái sử dụng ba Tri phủ và một Trấn thủ hiện có; Tri phủ thứ tư chuyển sang một vị trí Phò tá. Bổ sung các người quản lý còn thiếu. Các tấu nhân sự và khóa ghi công được đổi sang ID vị trí tương ứng. Ván mới có 53 vị trí và 12 ứng viên chờ bổ nhiệm. Bản theo tuần hoặc chưa có bộ máy cửu phẩm giữ luật cũ.

Kiểm tra hành vi: `test/management_test.dart`; giao diện và xác nhận bổ nhiệm ở desktop/320px: `test/management_ui_test.dart`. Xuất ảnh bằng `flutter test test/management_ui_test.dart --dart-define=MANAGEMENT_PREVIEWS=true`, kết quả tại `output/management-preview/`.
