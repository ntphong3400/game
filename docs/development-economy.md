# Phát triển kinh tế, nông nghiệp và đê điều

## Cân bằng hiện tại — lượt mới 0.28, balanceVersion 2

Các giá dưới đây là lượng vàng thực tế. Mọi lợi ích vẫn bắt đầu từ mùa sau khi hoàn thành; nâng cấp không cấp ngay tiền hoặc thóc, không tự sửa tình trạng đê.

| Cấp | Thưởng thuế nền/năm | Sản lượng nền/năm (tạ) | Sức chứa kho (tạ) | Giảm hao mòn đê | Giảm thiệt hại đê do thiên tai |
|---|---:|---:|---:|---:|---:|
| 1 | 0 | 4.100.000 | 8.000.000 | 0% | 0% |
| 2 | 4.000 | 4.400.000 | 10.000.000 | 15% | 10% |
| 3 | 9.500 | 4.700.000 | 12.000.000 | 30% | 20% |
| 4 | 17.000 | 5.000.000 | 14.000.000 | 45% | 30% |
| 5 | 27.000 | 5.300.000 | 16.000.000 | 60% | 40% |

Giá nâng kinh tế lên cấp 2–5 giữ 8.000/15.000/24.000/36.000 vàng; nông nghiệp giữ 7.000/13.000/21.000/32.000 vàng. Giá nâng đê giảm 35%, còn 6.500/11.700/18.200/26.000 vàng. Thưởng thuế là tổng của cấp hiện tại, chịu hệ số lao động cả vụ và điều chỉnh Hộ bộ. Sản lượng giữ hệ số lao động, đê và thời tiết cũ.

Mua lương cơ bản 200.000 tạ được nhân hiệu quả người phụ trách và tỷ lệ giao nhận; không còn bị chặn ở 999. Hạn mức 0–100 của chỉ số và sức chứa kho vẫn giữ riêng. Khi nhập kho vượt sức chứa, chỉ cộng phần còn chỗ và ghi nhật ký số tạ không nhập được. Kho mở rộng theo cấp đang có, dùng chung cho nhập kho, mua lương, giới hạn cuối lệnh và các màn hình; tải lại giữ nguyên tồn kho hợp lệ.

Ngân khố hiển thị sản lượng nền trước/sau nâng cấp, sức chứa, số mùa đủ ăn và dự báo vụ gặt. Dự báo dùng lao động cả vụ hiện tại, thời tiết 100%, tình trạng đê đã ghi và giả định tồn kho giữ nguyên đến vụ gặt; thực nhập và phần vượt kho tính trước khẩu phần mùa Thu.

Bảo vệ thiên tai chỉ giảm hiệu ứng âm trên **tình trạng đê** trong tấu chương Thiên tai, cảnh báo lũ và đại biến cố nhóm disaster. Không giảm mất dân/lương/vàng, hao mòn thường lệ, sửa chữa thất bại hoặc phá hoại. Thiệt hại còn lại làm tròn lên. Xem trước và thực thi dùng cùng bản hiệu ứng; kết quả chờ được chốt khi quyết định và không giảm lần thứ hai lúc nhận.

Bản lưu 0.27 có balanceVersion 1 giữ sản lượng 4,5/6/7,5/9/10,5 triệu tạ, giá tấu, tiếp tế và ngân sách cũ. Không đổi tồn kho, RNG, công trình, nghĩa vụ hoặc kết quả đã chốt. Lượt lịch sử chưa có dân số giữ thưởng kinh tế, giá nâng đê và sức chứa cũ. Chi tiết gián đoạn sản xuất, cứu trợ và hạch toán khẩu phần: [cân bằng 0.28](balance-food-028.md).

Kiểm tra hồi quy: `resource_development_test.dart`, `currency_ui_test.dart`, cùng các bộ development/population/currency hiện có.

## Thiết kế lịch sử 0.20.0 — lượt chưa có dân số

Áp dụng cho chế độ theo mùa. Ngân khố là tiền, lương thực là thóc riêng biệt;
thóc vẫn có sức chứa 200. Các con số dưới đây là cấu hình cân bằng ban đầu.

## Các cấp phát triển

Mọi nhánh bắt đầu cấp 1, nâng tuần tự đến cấp 5. Chi phí trả lúc khởi công,
tốn 1 hành động; quan phải đang rảnh, đúng chuyên môn và đạt năng lực tối thiểu.

| Cấp đích | Năng lực tối thiểu | Thời gian | Vốn kinh tế | Vốn nông nghiệp | Vốn đê |
|---|---:|---:|---:|---:|---:|
| 2 | 60 | 1 mùa | 80 | 70 | 100 |
| 3 | 70 | 2 mùa | 150 | 130 | 180 |
| 4 | 80 | 3 mùa | 240 | 210 | 280 |
| 5 | 90 | 4 mùa | 360 | 320 | 400 |

Kinh tế và nông nghiệp cần chuyên môn Kinh tế; nâng đê cần Công trình.
Mỗi nhánh chỉ có một dự án cùng lúc; các nhánh khác nhau cần người phụ trách riêng.

| Cấp | Thuế kinh tế tăng/năm | Sản lượng nông nghiệp nền/năm | Giảm hao mòn đê |
|---|---:|---:|---:|
| 1 | 0 | 60 | 0% |
| 2 | 20 | 80 | 15% |
| 3 | 45 | 100 | 30% |
| 4 | 75 | 120 | 45% |
| 5 | 110 | 140 | 60% |

Thưởng là tổng của cấp hiện tại, không cộng dồn các cấp trước. Thuế kinh tế được
cộng vào thuế vụ Thu: `4 × (mức thuế × 45 + lòng dân ~/ 3) + thưởng kinh tế`.
Không thay đổi mức thuế hoặc tác động lòng dân của mức thuế. Nông nghiệp tăng
thu hoạch, không tự cộng thêm tiền thuế ruộng. Các đoàn thương mại và canh tác
bổ sung hiện có vẫn trả thành quả từng lần, không tăng cấp.

## Thành công, thất bại và gián đoạn

Đủ năng lực chỉ là điều kiện nhận việc, không bảo đảm thành công. Xác suất nền
cho cấp đích 2/3/4/5 là 80/75/70/65%, sau đó cộng 0,8 điểm phần trăm cho mỗi
điểm năng lực vượt yêu cầu, trừ mệt/8, cộng nửa điều chỉnh tính cách/quan hệ,
trừ nguy cơ phá hoại và 0,2 lần nguy cơ tham nhũng. Giới hạn 10–95%.

Xác suất được chốt lúc giao việc, trước khi tăng mệt của quan. Giao diện chỉ
ước tính theo phẩm chất đã biết; phẩm chất ẩn có thể làm kết quả khác dự báo.
Random chỉ xét khi đủ thời gian thi công, dùng cùng bộ sinh số đã lưu của game.
Lưu/tải hoặc gửi lại cùng yêu cầu không trừ vốn hay xét kết quả thêm lần nữa.

Thành công tăng đúng một cấp. Thất bại giữ nguyên cấp, không hoàn vốn, không
thu thêm một khoản phạt nâng cấp. Quan được giải phóng khi dự án kết thúc.
Quan rời triều hoặc bị thay chức: dự án tạm dừng, giữ vốn và tiến độ; cần bổ nhiệm
người thay đạt cùng yêu cầu, tốn 1 hành động, không cấp lại vốn. Xác suất được
chốt lại theo người mới. Thay chức không tự chuyển dự án để vượt điều kiện.

Quyết toán mùa và thu hoạch diễn ra trước kết quả công trình dài hạn. Vì vậy,
cấp mới áp dụng từ mùa tiếp theo, không tăng ngược thuế/thu hoạch vừa quyết toán.
Tu bổ dài hạn hoàn thành sau quyết toán cũng bảo vệ từ mùa tiếp theo; bảo dưỡng
tức thì trước khi khép mùa sẽ có tác dụng trong mùa đó.

## Đê điều và thu hoạch

Cấp công trình khác tình trạng 0–100: nâng cấp giảm hao mòn, không tự hồi tình trạng.
Hao mòn nền Xuân/Hạ/Thu/Đông là 3/8/4/3, tổng 18 điểm/năm ở cấp 1.
Hao mòn thực bằng nền nhân `(1 − tỷ lệ giảm theo cấp)`; phần lẻ được tích lũy qua
mùa và lưu lại, tránh cấp cao được miễn hao mòn vì làm tròn. Thiên tai vẫn có
thể gây hư hại riêng, không được miễn nhờ cấp đê.

| Tình trạng | Hệ số sản lượng |
|---|---:|
| 0 | 30% |
| 30 | 60% |
| 60 | 100% |
| 80 | 110% |
| 95–100 | 120% |

Nội suy tuyến tính giữa các mốc. Cuối mỗi mùa ghi tình trạng sau hao mòn thường
lệ và các hành động tức thì đã thực hiện. Xuân và Hạ được lưu theo năm.

`Hệ số cả vụ = 20% × hệ số Xuân + 50% × hệ số Hạ + 30% × hệ số Thu`.

`Thu hoạch = làm tròn(sản lượng nền × hệ số cả vụ × thời tiết)`.

Thời tiết dao động 90–110%, chỉ xét khi thu hoạch tự động cuối Thu, tối đa một
lần mỗi năm. Ví dụ đê Xuân/Hạ/Thu 30/60/80 cho hệ số cả vụ 95%. Sửa vào Thu
không xóa phần năng suất đã mất ở đầu vụ. Mùa Đông không tính lại vụ đã gặt;
tình trạng đê được giữ sang Xuân năm sau.

Lương thực tiêu hao 12/mùa thời bình và 20/mùa khi có chiến tranh, bao gồm mùa
Thu. Dưới 15 thóc sau tiêu hao vẫn làm mất 3 lòng dân theo luật cũ.

Bảo dưỡng đê: 20 tiền, 1 hành động, cơ bản hồi 12 ngay; phụ thuộc quan Công trình,
chỉ thử một lần mỗi mùa. Thất bại mất vốn và 2 tình trạng đê. Đại tu hiện có:
80 tiền, cơ bản hồi 30 sau công trình dài hạn, vẫn có rủi ro theo luật giao việc.

## Giao diện và bản lưu

- Ngân khố → Việc tăng thu: cấp kinh tế, thưởng thuế và nâng cấp.
- Ngân khố → Kho lương & đê điều: cấp nông nghiệp/công trình, tình trạng đê,
  hao mòn dự kiến, công thức thu hoạch, kết quả vụ gần nhất và các việc nâng cấp/bảo dưỡng.
- Ngân khố → Đang thực hiện: cấp đích, tiến độ, dự báo thành công, gián đoạn và bổ nhiệm thay.
- Hộp giao việc lọc quan đủ điều kiện, hiển thị xác suất ước tính; xác nhận mới chi vốn.
- Bản lưu cũ mặc định cấp 1; giữ tiền, thóc, RNG và công việc cũ. Nếu thiếu lịch sử
  đê đầu vụ, dùng tình trạng lúc chuyển bản làm mốc cho mùa chưa có dữ liệu;
  không sinh ngược thu hoạch hay sửa số tiền đã thu.
- Chế độ tuần giữ thuế, thu hoạch và hao mòn cũ; các nâng cấp chỉ mở trong chế độ mùa.

Kiểm tra: `development_test.dart`, `development_ui_test.dart`,
`development_browser_test.dart`, cùng các kiểm thử thuế, ngân sách, giao việc và
toàn bộ bộ kiểm thử hiện có.
