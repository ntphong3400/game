# Điều tra kín, bằng chứng và xử lý triều thần — 0.26.0

## Giao nhiệm vụ

Điều tra kín trong ván cửu phẩm yêu cầu chọn một mật thám đang giữ chức, trưởng thành, còn hiện diện và rảnh công vụ. Không thể tự điều tra. Mỗi mục tiêu chỉ có một cuộc điều tra đang chạy; mật thám bận cho tới khi hoàn tất. Chọn người, kinh phí và hủy không tiêu tài nguyên.

Mỗi lần chi một hành động và tổng kinh phí 2.000/4.000/8.000 ngân lượng. Hoàn tất sau hai mùa. Cả tỷ lệ và kết quả được chốt khi xác nhận, lưu cùng nhiệm vụ; đổi phẩm, chức hoặc tải lại không xét lại kết quả.

```text
Thành công = 50 + 0,6 × (năng lực mật thám − 50)
             + thưởng phẩm mật thám − độ khó mục tiêu + hỗ trợ kinh phí
Giới hạn 10%–95%, làm tròn đến phần trăm nguyên.
```

| Phẩm | Thưởng mật thám | Độ khó mục tiêu | Tử vong nếu thất bại |
| --- | --- | --- | --- |
| Chưa có phẩm | 0 | 0 | 1% |
| Cửu – Bát | 0 | 5 | 2% |
| Thất – Lục | 3 | 10 | 4% |
| Ngũ – Tứ | 6 | 15 | 6% |
| Tam – Nhị | 9 | 20 | 9% |
| Nhất | 12 | 25 | 12% |

Kinh phí 2.000/4.000/8.000 cộng lần lượt 0/10/20 điểm phần trăm. Hậu cung có độ khó Tú nữ/Phi tần/Hoàng hậu là 5/15/25; tử vong nếu thất bại tương ứng **1%/4%/12%**. Chỉ dùng thông tin công khai để tính tỷ lệ; không tiết lộ âm mưu ẩn qua dự báo.

Popup hiển thị ba kết quả loại trừ nhau: thành công; thất bại sống sót; thất bại tử vong. Nguy cơ tử vong của cả nhiệm vụ bằng xác suất thất bại nhân nguy cơ tử vong khi thất bại. Mật thám 80 năng lực, Tứ phẩm điều tra Nhất phẩm có 49/59/69% thành công; nguy cơ tử vong toàn nhiệm vụ là 6,12/4,92/3,72%.

## Báo cáo và hạn bằng chứng

Chụp số liệu âm mưu/bất mãn khi giao nhiệm vụ nhưng chưa công bố. Chỉ thành công mới cập nhật hồ sơ và xác minh phẩm chất. Thành công giảm 6 tiến độ âm mưu thực tế và tăng 1 năng lực mật thám, không vượt 100. Thất bại không công bố thông tin mới, không hoàn phí và không gia hạn bằng chứng cũ. Tử nạn là vĩnh viễn, để trống chức Mật thám. Mục tiêu hoặc mật thám không còn hiện diện khiến nhiệm vụ gián đoạn, không xét tử vong do thất bại.

Bằng chứng có hiệu lực **bốn mùa kể từ mùa nhận báo cáo**, khác với ngày chụp số liệu. Ví dụ phái ở Xuân năm 1, hoàn tất cuối Hạ năm 1: dùng từ Thu năm 1 tới hết Hạ năm 2, hết hạn khi sang Thu năm 2. Khi hết hạn cần điều tra thành công lại. Báo cáo cũ vẫn được xem.

Dùng âm mưu ghi trong báo cáo đã xác minh làm căn cứ, không dùng chỉ số ẩn hiện tại. Báo cáo 80 vẫn cho phép xử tội khi âm mưu thực tế đã giảm còn 74, miễn còn hạn. Lần điều tra thành công sau thay báo cáo và bắt đầu thời hạn mới; thất bại giữ nguyên báo cáo/thời hạn trước đó.

## Giáng phẩm và kết tội

Trang chi tiết triều thần có nút **Giáng chức**, chọn một hoặc hai phẩm, khóa mức chưa đủ điều kiện:

| Hành động | Điều kiện bằng chứng còn hạn | Hậu quả |
| --- | --- | --- |
| Giáng một phẩm | Âm mưu >50% | Phẩm tăng một bậc số, phe −2 |
| Giáng hai phẩm | Âm mưu >60% | Phẩm tăng hai bậc số, phe −2 |
| Kết tội | Âm mưu >75% | Bỏ tù, tước phẩm/chức, phe −5 |

Các ngưỡng dùng dấu `>`; đúng 50/60/75 chưa đủ mức tương ứng. Mỗi lần tốn một hành động, không chi tiền, không đổi uy quyền hoặc ổn định ngay khi thực hiện. Hai mức giáng phẩm đều chỉ trừ 2 thái độ phe. Không giáng quá Cửu phẩm, không hoàn công trạng đã dùng để thăng phẩm.

Giáng phẩm luôn bỏ chức, kể cả phẩm mới còn đủ cho chức cũ. Ví dụ Thân vương Nhất phẩm bị giáng một phẩm trở thành quan Nhị phẩm chờ bổ nhiệm, ghế Thân vương để trống. Giữ thân phận hoàng thân, công trạng và nhiệm vụ đang làm. Các vị trí quản lý cũng bị bỏ trống và chịu passive âm theo chu kỳ hiện có.

Kết tội áp dụng cả triều thần và hậu cung: nhân vật chuyển thành Đang bị giam, không được bổ nhiệm/nhận nhiệm vụ, giữ hồ sơ/lịch sử. Hoàng hậu/Phi tần rời hậu cung và ngừng đóng góp. Công vụ bị gián đoạn; dự án phát triển dừng chờ người mới; quân đang xuất trận được thu hồi về nguồn, không mất/nhân đôi quân. Không thể kết tội lặp người đã bị giam. Bản này chưa có hành động phóng thích.

## Tấu bổ khuyết

Chấp nhận tấu tiến cử/chiêu mộ vào chức trống đồng thời thăng phẩm cá nhân tới phẩm chức vụ nếu cần và bổ nhiệm. Chi **một hành động**, tiền và công trạng cộng dồn theo bảng thăng phẩm hiện có; không thu thêm phí bổ nhiệm. Người đã đủ phẩm giữ phẩm và có phí thăng bằng 0.

Miễn năng lực và thiện cảm khi nhận tấu bổ khuyết. Vẫn cần tuổi, phẩm hợp lệ, rảnh công vụ, công trạng, thành tích lớn, ngân khố, thân phận hoàng thân cho tước vị và Văn/Võ ban tương ứng cho quản lý. Nếu điều chuyển người tại chức thì vị trí cũ để trống. Bổ nhiệm trực tiếp và thay người ở chức đang có người giữ nguyên luật riêng.

Passive không được miễn điều kiện năng lực/thiện cảm hoặc thời gian giữ chức. Công trạng người tiến cử chỉ trao theo kết quả giữ chức và điều kiện hiện có, không cấp ngay khi nhận tấu.

## Tương thích và kiểm tra

Luật `mvp-0.26.0`, nội dung 23, schema 2. Bổ sung `evidenceTurn`, `imprisoned`, `dead` trên nhân vật và dữ liệu nhiệm vụ mật thám trên kết quả đang chờ. Bản cũ nhận mặc định an toàn; không tự tạo chứng nhận bằng chứng từ chỉ số hoặc báo cáo cũ. Cuộc điều tra cũ đang chờ giữ cơ chế hoàn tất lịch sử, không tự được cấp quyền xử tội. Ván chưa có hệ thống cửu phẩm giữ cơ chế cũ.

Luật và lưu/tải: `test/covert_discipline_test.dart`. Giao diện desktop/320px, hủy/xác nhận: `test/covert_discipline_ui_test.dart`. Xuất ảnh bằng `flutter test test/covert_discipline_ui_test.dart --dart-define=COVERT_PREVIEWS=true`; ảnh tại `output/covert-preview/`.
