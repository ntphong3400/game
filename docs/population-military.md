# Dân cư, quân số và sức mạnh quân lực

Từ bản 0.22, cơ chế điều quân và thương vong mới được mô tả tại [chiến tranh và hòa ước](warfare.md); khung thương vong cố định bên dưới chỉ còn áp dụng cho nhiệm vụ lịch sử đã chốt.

Mô hình gốc `mvp-0.21.1`, nội dung 19, schema 2. Chỉ lượt theo mùa **tạo mới** dùng mô hình này. Bản lưu cũ không tự đổi điểm quân lực thành quân số hoặc đổi thóc thành tạ; tiếp tục giữ dữ liệu, tiến trình và nhóm thành tích của lượt đó.

Đơn vị ngân khố: lượng vàng, quy đổi 1 tiền cũ = 100 lượng vàng. [Chi tiết quy đổi bản lưu](gold-currency.md).

## Trạng thái khởi đầu

| Thông số | Giá trị |
|---|---:|
| Ngân khố | 50.000 lượng vàng |
| Dân số lao động, bao gồm binh lính | 1.000.000 người |
| Quân số | 50.000 người |
| Lao động dân sự | 950.000 người |
| Huấn luyện | 60/100 |
| Quân khí | 30.000 bộ, đáp ứng 60% quân số |
| Sĩ khí | 65/100 |
| Hậu cần | 100/100 |
| Kho lương | 4.000.000 tạ |
| Sức chứa kho | 8.000.000 tạ |
| Sản lượng nông nghiệp cấp 1 | 4.500.000 tạ/năm trước lao động, đê và thời tiết |

`Dân số lao động = lao động dân sự + quân số`. Tuyển quân và giải ngũ chỉ chuyển người giữa hai nhóm. Tử trận hoặc mất khả năng lao động vĩnh viễn mới giảm tổng dân số. Lòng dân tiếp tục là chỉ số quan hệ 0–100, độc lập với số người.

## Tăng giảm dân số

Các tỷ lệ cùng tính trên dân số đầu mùa. Phần lẻ tăng trưởng, tuổi già và bệnh tật được giữ lại cho mùa sau.

| Khoản | Mỗi mùa |
|---|---:|
| Người mới tới tuổi lao động, bình thường | +0,70% |
| Rời lực lượng vì tuổi già | −0,25% |
| Bệnh thông thường | −0,10% |
| Tăng ròng ở tình trạng bình thường | +0,35% |

Nguồn người mới giảm còn 0,40% khi kho dưới 90 ngày, ổn định dưới 40 hoặc lòng dân dưới 30; còn 0,10% khi kho dưới 30 ngày hoặc ổn định dưới 20. Đủ dự trữ 180 ngày, lòng dân từ 70, ổn định từ 60 và hòa bình thì tăng 0,90%.

Mức dịch 0/1/2/3 có tỷ lệ giảm tương ứng 0,10%/0,40%/1,20%/2,50%, thay thế nhau. Phòng dịch dân chúng là lệnh riêng, không dùng mức bệnh của nhà vua. Thiếu khẩu phần gây tổn thất bổ sung; thiếu lương nghiêm trọng hoặc biên giới bị đẩy lùi có thể làm dân bỏ xứ. Chỉ người lưu tán còn sống mới nằm trong nguồn có thể gọi về.

Tổn thất chung phân bổ theo tỷ trọng quân đội/dân sự. Tử trận chỉ giảm quân đội; lưu tán chỉ giảm dân sự. Không vừa ghi chết vừa ghi lưu tán cho cùng một người.

## Hành động dân cư và quân sự

Các lệnh dưới đây ở Quốc sự, tốn 1 hành động khi xác nhận. Một mùa nhận kết quả nghĩa là nhận khi khép mùa đang ban lệnh; hai mùa nghĩa là khi khép mùa kế tiếp.

| Lệnh | Vàng (lượng) | Lương thực | Kết quả |
|---|---:|---:|---|
| Chiêu dân lập ấp | 4.000 | 7.000 tạ | 5.000 lao động sau 2 mùa |
| Tiếp nhận người tị nạn | 5.000 | 10.000 tạ | 10.000 lao động sau 1 mùa; cần đoàn người xin vào |
| Gọi dân lưu tán trở về | 3.000 | 4.000 tạ | Tối đa 10.000 người sau 1 mùa, không vượt nguồn còn lại |
| Tuyển quân thường lệ | 2.500 | 0 | Chuyển 5.000 dân sự thành tân binh sau 1 mùa, huấn luyện 20 |
| Giải ngũ | 0 | 0 | Chuyển 5.000 quân rảnh về dân sự, phải giữ lực lượng bảo vệ |
| Rèn thêm quân khí | 4.000 | 0 | 5.000 bộ sau 1 mùa |
| Thưởng quân | 2.500 | 0 | Sĩ khí +8, chia cho số lần sử dụng trong mùa |
| Tổ chức tiếp tế | 2.000 | 20.000 tạ | Cấp trước một phần khẩu phần mùa, không trừ lại |
| Tổ chức phòng dịch | 3.500 | 5.000 tạ | Mức dịch −1, lòng dân +1, một lần/mùa khi có dịch |

Không mở trùng một loại đợt đang thực hiện. Hồi hương giữ chỗ trong sổ dân lưu tán ngay khi xác nhận. Đợt tuyển thường lệ giữ chỗ nguồn lao động, không để tuyển khẩn cấp dùng lại nguồn đó. Người mới và người giải ngũ đóng góp sản xuất từ mùa sau; huy động người đi lính giảm ngay phần lao động có thể đóng góp của mùa.

Nguồn có thể tuyển giữ lại tối thiểu 70% dân số đủ tuổi cho dân sự, giới hạn quân thường lệ ở 12%, loại người huy động sớm chưa đủ điều kiện và các suất tuyển đang giữ chỗ. Nếu nguồn thực tế giảm trong lúc chờ, đợt tuyển chỉ nhận số còn hợp lệ.

### Hạ tuổi lao động

Bổ sung ngay 1% lao động dân sự, lòng dân −8, ổn định −5. Ghi nhận đây là người được huy động sớm; chưa được tuyển quân. Khấu trừ thành hai phần từ nguồn người mới của hai mùa tiếp theo. Nếu một mùa không đủ người mới để khấu trừ, phần thiếu chuyển tiếp; không làm nguồn tăng trưởng âm.

Khoảng cách tối thiểu **4 mùa**, tính `mùa sử dụng + 4`: dùng Xuân năm 1 thì sớm nhất Xuân năm 2. Cần hết nghĩa vụ trước khi dùng lại.

### Tuyển quân khẩn cấp

Bắt buộc chọn triều thần trưởng thành đang rảnh. Chi cố định 1.500 lượng vàng, 1.500 tạ và lòng dân −4; tạo nghĩa vụ 2 mùa trước đợt tiếp theo. Thóc phạt cũ do thiếu lao động được bỏ vì sản xuất nay đã giảm theo số người rút đi.

Tỷ lệ thành công `p` dùng cùng thông tin công khai với giao diện. Engine bốc một lần khi xác nhận:

```text
Thất bại: 1.000 quân
Thành công: ceil((10.000 × p / 100) / 10) × 10 quân
```

Ví dụ 60%: thành công nhận 6.000 quân, thất bại nhận 1.000. Giá trị 2.323,12 làm tròn lên 2.330 quân. Chi phí không thay đổi theo kết quả. Chỉ chuyển số thực nhận khỏi dân sự; không cộng tổng dân số. Tân binh khẩn cấp có huấn luyện 10.

## Phân bổ và chính sách sản xuất

Dân sự tự phân bổ 60% nông nghiệp, 30% sản xuất/thương mại, 10% hoạt động khác. Năng lực tiếp nhận ban đầu là 650.000 lao động nông nghiệp và 325.000 lao động sản xuất, tăng 25% mỗi cấp phát triển để có chỗ cho tăng trưởng dân số.

Trong nhóm 30% sản xuất/thương mại:

| Chính sách | Kinh tế | Quân khí |
|---|---:|---:|
| Ưu tiên kinh tế, mặc định | 80% | 20% |
| Ưu tiên quân đội | 20% | 80% |
| Cân bằng | 50% | 50% |

Chọn tại Ngân khố → Thuế & ngân sách, tốn 1 hành động, hiệu lực mùa sau. Chính sách này độc lập với thứ tự chi trả khi thiếu tiền.

Nguồn thu dân sự và thuế nhân theo lao động kinh tế hữu dụng, quy mô việc làm và phần dành cho kinh tế. Không nhân lại quà tặng, khoản vay, gia sản hoặc thưởng sự kiện. Ở cùng lao động/cấp phát triển, ba chính sách tạo 100%/25%/62,5% nguồn thu dân sự tham chiếu.

Quân khí sản xuất tham chiếu 2.000/8.000/5.000 bộ mỗi mùa, tăng theo lao động hữu dụng và cấp kinh tế. Kho hao mòn 1%/mùa thời bình, 3% khi chiến tranh. Quân khí tự sản xuất và mua sắm cùng nhập kho; giải ngũ giữ lại trang bị, tổn thất quân sự làm mất một phần trang bị.

## Lương thực tính bằng tạ

Quy ước game: 1 tạ = 100 cân quy đổi; một mùa tính 90 ngày khẩu phần. Dân sự dùng 1 cân/người/ngày; quân thường trực 1,5 cân; quân chiến dịch 2 cân.

```text
Thời bình khởi đầu:
(950.000 × 90 × 1 + 50.000 × 90 × 1,5) / 100
= 922.500 tạ/mùa

Lương nhiệm vụ = quân tham gia × số ngày × 2 / 100 + hao hụt vận chuyển
```

Mỗi khoản thu/chi dương dùng `ceil(tổng khoản)`, chỉ làm tròn một lần; 0 giữ nguyên 0. Chi phí xem trước là số thực trừ. Kho là số nguyên không âm, có trần 8 triệu tạ.

Nhiệm vụ trong phiên bản này cấp 30 ngày chiến dịch, hao hụt vận chuyển 10%: 10.000 quân cần 6.600 tạ. Ghi có 4.500 tạ khẩu phần thường trực đã nằm trong phần cấp trước để không tính hai lần. Tiếp tế chủ động cũng ghi phần cấp trước. Giải ngũ không xóa quân phí hoặc khẩu phần của thời gian đã phục vụ trong mùa.

Mua lương cơ bản chi 4.500 lượng vàng, nhận 200.000 tạ; bán xuất 100.000 tạ và giữ đủ khẩu phần một mùa; cứu tế xuất 100.000 tạ. Các tấu chương cũ được chuyển theo mục đích cứu trợ, quân nhu hoặc kho/sản xuất, không dùng một tỷ lệ chung cho mọi chi phí. Cung vụ cũng dùng số tạ đã chuyển đổi trên cả giao diện và engine.

Sản lượng nông nghiệp nền cấp 1–5 lần lượt tương ứng cấp cũ 60/80/100/120/140, với mức 60 quy thành 4.500.000 tạ. Thu hoạch vẫn ở Thu, có hệ số lao động cả vụ, đê và thời tiết. Cảnh báo thiếu lương dùng số ngày dự trữ thay ngưỡng 15/25 thóc cũ.

## Sức mạnh quân lực

```text
Quân khí E = min(100, bộ trang bị / quân số × 100)
Sẵn sàng Q = 0,30T + 0,25E + 0,20M + 0,25H
Hệ số chỉ huy K = 0,80 + 0,004D
Sức mạnh S = quân số × Q / 100 × K
```

Chỉ huy trên bộ: Đại tướng 70%, Phó tướng 30%. Thủy chiến: Đại tướng 20%, Phó tướng 20%, Đô đốc 60%. Hiệu quả mỗi người theo năng lực, độ phù hợp Quân sự và mệt công vụ; vị trí trống đóng góp 0.

Huấn luyện quân mới tính trung bình có trọng số. Luyện quân có hiệu quả cơ bản 10 cho 50.000 quân, điều chỉnh theo người phụ trách và giảm khi quy mô lớn hơn. Sĩ khí chịu tác động `clamp((lòng dân − 50)/10, −3, +3)` mỗi mùa, cộng quân lương và kết quả tác chiến. Hậu cần gồm 60% mức đáp ứng khẩu phần, 40% quân lương.

Sức mạnh là điểm không có trần 100. Biên giới xét sức mạnh quân đang có thể điều động so với đối phương; các cảnh báo chất lượng dùng mức sẵn sàng. Quân số về 0 vẫn kết thúc lượt, không dùng trường điểm quân lực cũ để kết thúc lượt mới.

## Nhiệm vụ quân sự và tấu chương

Mỗi nhiệm vụ xác định số quân, chi phí tiếp tế và chỉ huy. Quân đang đi vẫn nằm trong tổng quân số nhưng bị giữ chỗ, không giao thêm nhiệm vụ. Tỷ lệ hoàn thành dùng cùng công thức trên giao diện/engine, có ảnh hưởng sức mạnh và bộ chỉ huy. Kết quả và tổn thất được bốc/lưu khi xác nhận, chỉ công bố khi quân báo về.

| Giao tranh | Tổn thất trên số quân được cử |
|---|---:|
| Nhỏ | 1–20% |
| Lớn | 20–50% |
| Thất bại nặng | 50–70% |

Tổn thất nhiệm vụ là tổn thất vĩnh viễn; giảm tổng dân số và quân số đúng một lần. Đại biến cố có phần điều quân chờ quân báo trước khi quyết toán thưởng; không trao thưởng toàn diện khi nhiệm vụ quân sự chưa có kết quả.

Tấu chương dân cư mới gồm lưu dân, lập nghiệp, hồi hương và dịch bệnh; thêm giao tranh biên giới nhỏ/lớn. Ví dụ nhận toàn bộ đoàn 10.000 người: chi 5.000 lượng vàng, 10.000 tạ, Văn thần +3, Võ tướng −5. Tác động là thái độ phe, không tự trừ thêm thiện cảm từng người. Mỗi năm ưu tiên một bản tấu dân cư trong ngân sách 4–6 bản đầu mùa khi có nội dung đủ điều kiện.

## Giao diện và kiểm tra

Hai tab Dân cư & Lao động và Quân sự chỉ hiển thị dữ liệu, có vùng cuộn riêng; không tự gửi lệnh hoặc ghi bản lưu khi xem. Lệnh ở Quốc sự, đối sách trong sổ khẩn cấp, chính sách ở Ngân khố. HUD quân lực của lượt mới mở Quân sự và hiển thị điểm sức mạnh thực.

Kiểm tra mới: `test/population_test.dart`, `test/population_ui_test.dart`. Bộ kiểm tra lịch sử dùng fixture `test/support/legacy_engine.dart` và `legacy_gateway.dart` để tiếp tục kiểm chứng hợp đồng bản lưu cũ; kiểm tra mới dùng mặc định production.

Các ca chính: tăng trưởng/rời lực lượng, hạ tuổi và khấu trừ/cooldown, nhập cư/hồi hương, tuyển quân bảo toàn dân số, hai nhánh tuyển khẩn cấp, kho/quân khí, chi phí không trả lại, quân không bị giao trùng, khẩu phần không bị trừ hai lần, replay/receipt, và toàn bộ 66 đại biến cố. Giao diện kiểm tra desktop, điện thoại nhỏ và landscape; ảnh thực tế nằm cạnh tài liệu với tiền tố `population-`.
