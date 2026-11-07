# Mẫu text động và phần nằm cùng khu vực

Các dấu {…} dưới đây là dữ liệu thay đổi trong game. Đây là danh mục nhánh nội dung trong code, không phải khẳng định mọi biến thể số liệu đều xuất hiện trong một save.

## Nhân sự

| Lựa chọn / trường hợp | Text hoặc đoạn text có thể xuất hiện |
|---|---|
| Cho {tên} thôi chức, hồi hương | Chi 1 hành động, không chi vàng. Cần uy quyền trên {ngưỡng} nếu chức từ Tứ phẩm trở lên. Mỗi mùa ghế trống: {tác động chức trống}. Người hồi hương giữ phẩm và công trạng; phe người cũ −4, phe dâng tấu +3; người ảnh hưởng cao còn phản ứng mùa sau. |
| Bác đề nghị — mọi tấu nhân sự | Giữ nguyên nhân sự; phe dâng tấu −1. Quá hạn cũng áp dụng phương án này. |
| Bổ nhiệm vào ghế trống; hoặc Chọn người khác để bổ nhiệm sau khi chọn ứng viên | {Tên} nhận chức {chức}. {Phẩm cũ} → {phẩm mới}. / Đã đủ phẩm; giữ phẩm hiện tại. Chi {tiền} và 1 hành động; dùng {công trạng} công trạng. Miễn yêu cầu năng lực và thiện cảm; vẫn cần công trạng, thành tích lớn và thân phận hợp lệ. Passive vẫn theo điều kiện thông thường. Chức {chức cũ} sẽ bỏ trống. |
| Chọn người khác — chưa chọn ứng viên, ghế trống | Chọn người được tiến cử để xem phí thăng phẩm. |
| Chọn người khác — chưa chọn ứng viên, đang thay người | Chọn ứng viên để xem đủ chi phí và điều kiện. |
| Bổ nhiệm thay người đang giữ chức | {Tên} nhận chức {chức}; {phẩm} trở lên. Triệu hồi người đã hồi hương. Phe người mới +5, phe đối lập −6; chuyển từ chức khác để lại ghế trống. Phí dùng luật bổ nhiệm thông thường. {Người cũ} về danh sách chờ; cùng phe nên không mất thêm thái độ vì thay người / phe {phe cũ} giảm thêm 4 thái độ. Phe người cũ còn phản ứng mùa sau. {Chức cũ} sẽ bỏ trống. Mỗi mùa bỏ trống: {tác động}. Passive cần đủ năng lực, thiện cảm và giữ chức trọn mùa. Nếu thôi giữ chức trước khi được đánh giá thì không ghi công tiến cử. |
| Nhánh bổ nhiệm vị trí quản lý | {Tên} quản lý {khu vực}; Lục phẩm trở lên / không yêu cầu phẩm vị. Chi 1.000 ngân lượng và 1 hành động; người mới +5 thiện cảm. {Người cũ} −10 thiện cảm, chờ bổ nhiệm và giữ nguyên phẩm. Chức {chức cũ} sẽ bỏ trống. {Tác dụng vị trí}; cần năng lực >{ngưỡng}, thiện cảm >{ngưỡng}. |
| Thăng lên {phẩm} | Dùng {số} công trạng; giữ nguyên yêu cầu thành tích lớn. Thiện cảm +{số}, bất mãn −{số}. Uy quyền +1, phe tiến cử +2. Không cộng công trạng cho việc thăng phẩm. |
| Đặc cách lên {phẩm} | Dùng {số} công trạng; giữ nguyên yêu cầu thành tích lớn. Thiện cảm +{số}, bất mãn −{số}. Miễn điều kiện năng lực; uy quyền −2, ổn định −1, phe tiến cử +5. Không kích hoạt passive nếu chưa đủ năng lực. |

Các câu về chức cũ, hồi hương và phản ứng phe phái chỉ được chèn khi thỏa điều kiện tương ứng.

## Tấu thường, kinh tế, kết quả chờ

- Chi {số} / Xuất {số} tạ / ngân khố ±{số} lượng vàng / nợ chi trả ±{số}: một số định dạng chưa bị bộ lọc hiện tại loại bỏ.
- Nhận kết quả cuối {mùa/tuần/năm}: {kết quả}.
- Nếu xác minh được: thu hồi {khoảng tiền}, uy quyền +2; có thể chưa đủ chứng cứ.
- Nếu xác minh được: mỗi âm mưu giảm tối đa 6; có thể chưa đủ chứng cứ.
- Kết quả tùy người phụ trách Ngoại giao; có thể thất bại.
- Doanh thu {khoảng tiền}, chưa trừ vốn đã chi.
- Kết quả chờ: {hiệu ứng}. Thất bại: {hiệu ứng}.
- Vốn/phí ứng {tiền}; Thành công: nhận {tiền}, lãi sau vốn {tiền}; Thất bại: mất {tiền} đã ứng, trừ thêm {tiền} / không phạt thêm {đơn vị}; Nhận kết quả cuối {ngày trong game}.
- Tiền nhận ngay {tiền}; sau phí {tiền}.
- Nhận {tiền} ngay; phát sinh {số} nợ.
- Nhận 8.000 bộ quân khí cuối kỳ.

## Mã kỹ thuật còn xuất hiện trong cấu hình hiện tại

| Text | Tấu → lựa chọn |
|---|---|
| revealCandidates +2 | Lời đề nghị kết thân → Cho tiến cử người mới |
| peace +1 | Một lá thư cầu hòa → Chi vàng đổi hòa bình |
| work +2 | Ngọn đèn chưa tắt → Xử lý nốt công việc |
| taxNormal +1 | Tấu xin giảm sưu → Giảm về mức vừa |
| recruitConsort +1 | Người mới trước cửa cung → Nhận làm tú nữ |
| rejectConsort +1 | Người mới trước cửa cung → Khước từ tiến cử |

repair +1 đã bị ẩn bởi thay đổi trước, không tính là text còn hiển thị.

## Thiên tai, lương thực, dân cư và quân sự

- Ứng phó một phần: năng suất giảm 12% trong mùa này.
- Bỏ mặc làm năng suất giảm 25% mùa này và mùa sau; mùa sau sẽ trình nhu cầu cứu trợ.
- Đã giảm {phần trăm}% thiệt hại đê do cấp công trình.
- Tối đa {số} tạ khẩu phần được đối trừ tiêu dùng toàn quốc khi khép mùa; hậu cần là chi phí bổ sung.
- Xuất {tổng} tạ, gồm {khẩu phần} tạ khẩu phần và {hậu cần} tạ hậu cần. Dừng tổn thất sản xuất từ mùa này; lòng dân +2; 1 hành động.
- Xuất {tổng} tạ; khẩu phần {số} tạ được đối trừ. Giảm một nửa tổn thất sản xuất còn lại; 1 hành động.
- Không xuất lương; giữ tổn thất sản xuất theo lịch, lòng dân −2; 1 hành động khi chủ động ngự phê.
- Chi {tiền}, {lương}; nhận {số} lao động khi khép mùa. {Phe và tác động}.
- Không nhận dân. Võ tướng +3, Văn thần −5.
- Không thay đổi dân số.
- Nhận lại tối đa {số} lao động, không vượt số người còn lưu tán.
- Chưa đón người về.
- Dân bỏ xứ {số} người, lòng dân −3.
- Dân lưu tán {số}, lòng dân −5, chiến tranh +1.
- Mở nhiệm vụ với {số} quân địch; chọn 80/100/125% quân, chủ tướng và phó tướng tại Quân sự. Thắng vẫn có thương vong.
- Với save chưa dùng nhiệm vụ chiến tranh mới: {số} quân làm nhiệm vụ; tổn thất 1–20% hoặc 20–50%; thất bại nặng 50–70%.

## Chuỗi sự kiện và đại biến cố — tùy chế độ/save

Trong cấu hình hiện tại có dân số, populationEvent() dựng lại hint, nên nhiều câu nguồn bên dưới không xuất hiện ở detailHint. Trong save không có dân số, chúng còn có thể hiển thị:

- Không chi ngân khố / Chi {tiền} ngay.
- 1 hành động. {hiệu ứng} ngay. Dừng ở {n}/4.
- Hoàn thành {n}/4; ghi nhận thêm {giá trị} chi phí quy đổi.
- Quyết toán: {phần thưởng}.
- Chưa nhận thưởng; bản tấu tiếp theo {ngày}. Nếu dừng sau bước này: {phần thưởng}.
- {tiền} tiền · {thóc} thóc · {số} hành động. {hiệu ứng}. Khép chuỗi sau quyết định này / Bản tấu tiếp theo dự kiến {ngày}.
- Từ mùa sau chi 18 tiền/mùa × 2 mùa.
- Mùa sau hoàn trả 35 tiền.
- Nguồn thu 12 tiền/mùa × 4 mùa, bắt đầu mùa sau.
- Bảo vệ đầy đủ phần việc này / Chỉ bảo vệ một phần.
- Bảo vệ {tỉ lệ}%; tổn thất ngay: {hiệu ứng}.
- Không bảo vệ phần việc này; tổn thất ngay: {hiệu ứng}.
- Khép đại biến cố; phần ứng phó yếu có thể để lại dư âm.
- Bản tấu tiếp theo vào {ngày}; quyết định này được giữ lại.
- Năng suất giảm {tỉ lệ}% trong mùa này / trong mùa này và mùa sau; mùa sau sẽ trình nhu cầu cứu trợ. Tổng ảnh hưởng đến nông nghiệp giới hạn 35%, không sửa ngược mùa đã chốt.
- Các lý do không đủ nguồn lực/nhân vật cho bước chuỗi có thể được nối cuối hint. Đây là lý do chặn thao tác, không phải chỉ số tác động.

## Các text cùng khu vực nhưng là thành phần UI riêng

Nếu chỉ bỏ Text có key petition-choice-detail-{index}, các phần này vẫn còn:

- CẢNH BÁO: phương án này làm ổn định về 0 và kết thúc lượt chơi.
- Người xử lý · yêu cầu chuyên môn {chuyên môn}.
- Không giao ai xử lý (mặc định) / tên người được giao.
- Tỷ lệ thành công: {tỉ lệ}%.
- Nút Chọn người để bổ nhiệm / tên ứng viên.
- Dòng Quá hạn: áp dụng lựa chọn cuối cùng. nằm ngoài khung tác động, không thuộc detailHint().
