# Chiến tranh, điều quân và hòa ước — 0.22.0

Ba nước dùng tên tạm **Hàn Kỳ** (Bắc), **Xích Lĩnh** (Tây), **Bích Trạch** (Nam). Tên nằm trong `WarfareState`; chưa có tên nào được người chơi chọn chính thức. **Ưu thế khởi đầu của cả ba nước đều là 0. Quan hệ ngoại giao: hai nước được chọn ngẫu nhiên có +10, nước còn lại có 0.** Lựa chọn theo seed ván chơi, lưu và tải lại không bốc lại. Không chiếm và sáp nhập quốc gia.

## Ngoại giao và chiến tranh

- Trạng thái: hòa bình, căng thẳng, chiến tranh, hòa ước.
- Chỉ một đối thủ đang chiến tranh; có thể có nhiều mặt trận/nhiệm vụ cùng lúc, tối đa bốn nhiệm vụ mở/đang đánh do hệ thống tự sinh. Nhiệm vụ riêng từ tấu chương có thể bổ sung.
- Tuyên chiến tốn một hành động, quan hệ −20. Giao hảo tốn 1.000 lượng vàng và một hành động, quan hệ +12.
- Các hiệu ứng chiến tranh cũ được gắn với một nước còn có thể giao chiến; hòa ước và bảo hộ hòa bình ngăn tự mở chiến tranh với nước đó.
- Ưu thế giới hạn −100…100. Nhiệm vụ thành công cộng, thất bại/trì hoãn quá hạn/bỏ mục tiêu trừ điểm. Quân địch dùng cùng nguồn lực mặt trận và tăng viện đầu năm; xem [luật ba cửa ải](frontiers.md).
- Các nhiệm vụ: trinh sát (+6), hộ tống lương (+8), giải vây (+12), tập kích quân nhu (+12), giữ ải (+15), hội chiến/công thành/thủy chiến (+20), bảo vệ kinh thành (+25). Thất bại trừ cùng mức.
- Trinh sát và tập kích thành công làm suy yếu hiệu quả đối phương; hộ tống lương tác động hậu cần.
- Ưu thế ≤−70 mở quân báo bảo vệ kinh thành, hạn nhận một mùa; có thể cầu hòa. Bỏ mặc, bỏ mục tiêu, rút bỏ phòng thủ hoặc thua trận kinh thành gây mất nước. Thua trận ngoài biên giới, hết quân dự bị hay mất toàn bộ một đạo quân không tự động làm mất nước. Nếu thắng phòng thủ cuối, ưu thế phục hồi ít nhất −40.

## Nhận và triển khai nhiệm vụ

Quân báo → chọn đối sách → chọn quân → chọn chủ/phó tướng → xem dự tính → xác nhận → triển khai → quân báo kết quả.

- Nhiệm vụ thường: **80%, 100%, 125%** quân địch.
- Công thành: **200%, 250%, 300%**; không nhận mức dưới 200%.
- Quân = `ceil(quân địch × tỷ lệ / 10) × 10`.
- Không đủ quân thì khóa mức lựa chọn; không tự đổi số lượng.
- Chủ tướng bắt buộc; phó tướng tùy chọn, khác chủ tướng. Người trưởng thành, còn hoạt động, không thuộc hậu cung và không đang bận mới được giao. Đô đốc có lợi thế chuyên môn khi thủy chiến.
- Quân rảnh toàn quốc = tổng quân − toàn bộ quân đang làm nhiệm vụ. Xuất trận dùng quân rảnh tại đúng cửa ải; bảo vệ kinh thành dùng quân tại Kinh Thành. Điều quân giữa các nơi tại Doanh Trại, xem [phân bổ và phòng thủ](frontiers.md). Cả hai chỉ huy đều bị giữ chỗ cho đến khi quân trở về. Quân ở nhà xuống dưới 20% được cảnh báo, nhưng vẫn có thể điều động hết.
- Nhiệm vụ nhỏ một mùa; hội chiến, công thành, giữ kinh thành hai mùa. Đếm cả mùa xuất quân: nhiệm vụ hai mùa xuất ở mùa 1 trở về cuối mùa 2.
- Các nhiệm vụ dài có yêu cầu tiếp tế giữa chừng: 1.000 lượng vàng, lương như một đợt xuất quân, một hành động. Tiếp tế hoặc rút quân; bỏ mặc làm nhiệm vụ thất bại.
- Các tấu chương quân sự trước đây điều một số quân cố định nay mở nhiệm vụ tại tab Quân sự; chưa trừ quân, vàng hoặc hành động cho tới khi xác nhận xuất quân. Mục tiêu đại biến cố chỉ được ghi nhận theo kết quả đạo quân, không tự hoàn thành lúc nhận quân báo.

## Chi phí và hậu cần

Vàng xuất quân = `ceil((8 + quân/1000) × 100)` cho nhiệm vụ nhỏ, hoặc `ceil((15 + quân/1000) × 100)` cho nhiệm vụ dài.

Lương xuất quân = `ceil(quân × 30 × 2 / 100 × 1,1)` tạ. Phần khẩu phần thường lệ đã cấp = `ceil(quân × 30 × 1,5 / 100)` tạ, khấu trừ vào nhu cầu cuối mùa. Tiếp tế cũng ghi phần khẩu phần đã cấp trong mùa nhận tiếp tế. Quân vẫn nằm trong quân số phục vụ để tính quân phí; không trừ khẩu phần đã trả trước lần thứ hai.

Phí đã chi không hoàn khi thua, tự rút hoặc cầu hòa.

## Xác suất chiến đấu và thiện cảm

Dùng cùng dữ liệu công khai cho xem trước và thực thi. Không lấy trung thành/đặc tính chưa khám phá để âm thầm thay đổi xác suất đã hiển thị.

- Hiệu quả một chỉ huy = `clamp(năng lực × độ phù hợp − mệt/5, 0, 100)`. Phù hợp bằng 1 nếu chuyên Quân sự, hoặc đô đốc trong thủy chiến; còn lại 0,75.
- Chỉ huy và thiện cảm phối hợp dùng **70% chủ tướng + 30% phó tướng**. Nếu không có phó tướng thì dùng 100% người chỉ huy.
- Sẵn sàng dùng mô hình dân số hiện tại: 30% huấn luyện + 25% quân khí + 20% sĩ khí + 25% hậu cần.
- Sức ta = quân × sẵn sàng/100 × `(0,8 + 0,004 × chỉ huy)` × địa hình × đối sách.
- Sức địch = quân địch × chất lượng địch/100. Chất lượng ban đầu 65.
- Địa hình: giữ ải/kinh thành ×1,35; công thành chia `(1,5 + độ kiên cố/100)`; còn lại ×1. Kiên cố ban đầu 65.
- Đối sách: thận trọng sức chiến đấu ×0,95, thương vong cơ sở ×0,8; chủ động ×1,10 và ×1,2; theo kế hoạch ×1.
- Xác suất nếu giao chiến = `clamp(round(50 + 45 × (sức ta − sức địch)/(sức ta + sức địch)), 5, 95)`.

| Thiện cảm phối hợp | Nguy cơ tự ý bỏ nhiệm vụ |
|---|---:|
| 80–100 | 0% |
| 60–79 | 3% |
| 40–59 | 10% |
| 20–39 | 25% |
| Dưới 20 | 40% |

Xác suất cuối = `(1 − nguy cơ bỏ nhiệm vụ/100) × xác suất nếu giao chiến`. Bước đầu xét rút lui, bước sau xét giao chiến. Vì thế năng lực cao vẫn có thể thua do bất mãn.

## Thương vong

`R = quân tham chiến / quân địch`.

`B = clamp(50/R + (50 − chỉ huy) × 0,4, 1, 100)`; công thành nhân thêm 1,3 trước giới hạn. Áp dụng hệ số đối sách rồi giới hạn lại 1…100.

- **Thua khi giao chiến:** chịu B%.
- **Thắng:** giảm B ngẫu nhiên 50–75%, tức còn B × 25–50%.
- **Tướng tự ý rút:** chịu B × 10–25% ngẫu nhiên; nhiệm vụ vẫn thua.
- Số quân mất = làm tròn lên đến người nguyên, giới hạn bằng quân tham chiến.
- Trước khi trả quân, bỏ giữ chỗ đạo quân đó rồi trừ cùng số người khỏi tổng quân và dân số; quân của các nhiệm vụ khác không bị trừ theo. Tử vong dân số thường lệ vẫn có thể làm giảm quân tại nhà ngoài tổn thất trận đánh.
- Quân sống sót vẫn là quân nhân, không tự chuyển thành lao động dân sự.
- Tải lại, sao chép hoặc gửi lại receipt không bốc kết quả/thương vong lần nữa. Nguyên nhân gián đoạn do chỉ huy rời chức được báo riêng.

Ví dụ 10.000 đấu 10.000, chỉ huy 75: B=40%. Thua mất 4.000; thắng được giảm 60% thì mất 1.600. Thua có thể mất 100%; thắng vẫn có thương vong, tối đa 50% với mức giảm tối thiểu 50%.

## Hòa đàm và triều cống

| Gói | Vàng/năm | Số năm/kỳ | Ưu thế để đòi cống |
|---|---:|---:|---:|
| Nhẹ | 5.000 | 2 | ≥30 |
| Vừa | 10.000 | 3 | ≥70 |
| Nặng | 17.000 | 3 | ≥90 |

Đòi cống: phí sứ đoàn 1.000 vàng và một hành động; cơ hội `clamp(60 + 2 × (ưu thế − ngưỡng), 5, 95)%`. Chưa đạt ngưỡng không được yêu cầu. Từ chối không hoàn phí.

Cầu hòa: phí 2.000 vàng và một hành động; chấp nhận nghĩa vụ tối thiểu Nhẹ nếu ưu thế >−30, Vừa nếu −70<ưu thế≤−30, Nặng nếu ưu thế≤−70. Đình chiến không cống kéo dài bốn mùa, xác suất chấp nhận 95% khi hai bên trong khoảng −29…29, còn lại 70%.

- Kỳ đầu **sau bốn mùa kể từ ký**, rồi mỗi bốn mùa; không nhận ngay khi ký. Không biến thành thu/chi mỗi mùa.
- Thu/chi xuất hiện trong dự toán đúng kỳ và sổ ngân khố khi thanh toán. Khoản phải trả được xử lý sau chi thường lệ.
- Khi thiếu, thanh toán được bao nhiêu ghi bấy nhiêu; phần còn lại vào **nợ cống riêng**, không đồng thời cộng vào nợ thường lệ.
- Hạn trả bù một mùa, có thể gia hạn một lần. Người nộp có thể trả bù hoặc khước từ. Quá hạn/khước từ phá hòa ước, quan hệ −25, có tối hậu thư trước nguy cơ tái chiến từ mùa sau. Một cuộc chiến khác đang diễn ra vẫn ngăn mở thêm cuộc chiến.
- Đối phương có thể chậm cống nếu quan hệ <−50 (20% tại kỳ đến hạn). Có thể miễn, gia hạn hoặc gây sức ép (phí 500 vàng, một hành động, 70% thu khoản thiếu).
- Hết số kỳ thì hòa ước hết hiệu lực, không phát sinh kỳ mới; khoản còn thiếu vẫn giữ lại. Bảo hộ hòa bình thêm bốn mùa. Hết bảo hộ không tự động tuyên chiến.
- Ký hòa ước mới vẫn bảo lưu nợ cống cũ thành khoản có thể trả/đòi riêng; không xóa nợ vì thay điều khoản.
- Quân đang đánh khi ký hòa ước rút về theo lịch, không nhận thêm thương vong giao chiến sau hòa ước, không trả quân hai lần. Phí đã ứng không hoàn.

## Bản lưu và giao diện

Ván mới và bản lưu dùng dân số/vàng được gắn mô hình quốc gia; bản lưu vàng chưa có trường chiến tranh được bổ sung một lần. Giữ số dư, quân số, các đạo quân và kết quả lịch sử đã chốt. Bản lưu trước mô hình dân số hoặc fixture giữ đơn vị cũ tiếp tục cơ chế cũ. Thành tích giữ `scoreRules` cũ.

Thiết lập cũ nhầm +10 ưu thế ở Bắc/Tây được sửa một lần bằng `initialSetupVersion: 2`: bỏ phần ưu thế ban đầu đó, cộng quan hệ ban đầu 10/10/0 theo seed, bảo lưu các thay đổi ngoại giao và chiến đấu tiếp theo. Không đặt lại quân đang đi nhiệm vụ, RNG hay kết quả trận đánh đã chốt.

Tab **Quân sự** chứa tổng quân/đang bận/rảnh, ba nước, hòa đàm, hòa ước, nhiệm vụ, yêu cầu tiếp tế và quân báo. Hộp xuất quân hiển thị tỷ lệ quân, hai chỉ huy, thiện cảm, xác suất cuối, thương vong theo từng nhánh, vàng/lương và quân còn ở nhà. Không cần tab mới.

Các hệ số cân bằng và tên quốc gia ở trên là giá trị mặc định được dùng để triển khai các phần trước đó mới có đề xuất.

## Kiểm tra

`test/warfare_test.dart`: mô hình, nâng bản lưu, nhiều nhiệm vụ, giữ quân/tướng, công thành, xác suất/thiện cảm, thương vong, hồi quân, đại biến cố, mất nước, kỳ cống, nợ, hết hạn, receipt. `test/warfare_ui_test.dart`: chọn quân và tướng, giá khớp thực chi, hủy không ghi dữ liệu, công thành và cầu hòa trên desktop/điện thoại nhỏ.
