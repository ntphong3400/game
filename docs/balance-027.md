# Cân bằng kinh tế và độ khó 0.27.0 — 01/11/2026

Áp dụng cho ván **mới** theo mùa, dùng dân số, vàng và cửu phẩm. Luật `mvp-0.27.0`, nội dung 24, schema 2. Ván hiện hữu giữ giá và phần thưởng cũ. Không đặt lại tài nguyên, RNG, công việc, nghĩa vụ hoặc nhóm thành tích của người chơi.

## Mục tiêu

Game rất khó nhưng có thể lý giải hậu quả: duy trì vốn lưu động, bảo dưỡng trước mùa vụ, dùng đúng người và cân bằng các phe phải có ích. Đánh đổi dân sinh/uy quyền để lấy tiền, bỏ phòng thủ hoặc trì hoãn đại biến cố nhiều lần có thể giúp vượt một mùa nhưng làm tăng nguy cơ ở những mùa sau. Không dùng mục tiêu thời gian sống cố định hoặc buộc thua theo năm.

## Thay đổi thông số

| Nội dung | Bộ cũ | Bộ mới |
|---|---|---|
| Chuỗi kinh tế hoàn thành 4/4 | Nhận tổng 250% vốn quy đổi | Nhận tổng 140%; lãi ròng tiền mặt 40% nếu trả hoàn toàn bằng tiền |
| Chuỗi kinh tế dừng ở 2/4, 3/4 | Nhận 50%, 100% vốn đã thực hiện | 40%, 75%; dừng sớm vẫn mất vốn |
| Chuỗi khác dừng ở 2/4, 3/4 | 20%, 40% quỹ thưởng | 15%, 35%; đủ 4/4 vẫn nhận 100% |
| Thưởng quân lực của chuỗi | 20 điểm cũ → 20 huấn luyện toàn quân | 12 huấn luyện; không biến thành quân mới |
| Vốn tối thiểu đầu tư/thu hồi trong tấu | Có khoản chỉ 1.000 vàng | Tối thiểu 2.500 vàng |
| Doanh thu đầu tư có rủi ro | 4.500–8.500 vàng theo kịch bản, đôi khi vốn rất nhỏ | Giữ mức biên soạn nhưng giới hạn không quá 170% vốn; thu hồi không quá 220% phí |
| Tiền nhận ngay trong tấu | Cộng thêm khoảng 35% sau quy đổi mùa | Bỏ phần cộng thêm; giữ các đánh đổi chỉ số |
| Phụ phí phương án chỉ chi tài nguyên để tăng chỉ số | Vàng ×2, tối thiểu 4.000 | ×1,5, tối thiểu 3.000; đầu tư, kiểm toán, thương lộ dùng luật riêng |
| Sàn phí mỗi phần đại biến cố | 5.500 vàng cho mọi phần | 3.000; phần đắt vẫn theo giá biên soạn và mức độ |
| Canh tác bổ sung | 5.500 vàng → nền 52.500 tạ sau 2 mùa | Nền 350.000 tạ; tiếp tục xét người, thất thoát và thất bại |

Ví dụ Bến chợ: vốn bốn bước 22.000 vàng, hoàn thành nhận 30.800, lãi 8.800. Trước đây nhận 55.000, lãi 33.000. Nếu trả bằng chỉ số, phần vốn quy đổi vẫn được ghi nhận; tổn thất chỉ số không được hoàn trả.

Các hiệu ứng/chi phí thóc biên soạn được cân theo quy mô tiêu thụ khoảng 922.500 tạ/mùa đầu ván: dân sinh/kho/sản xuất dùng hệ số 6.000 tạ mỗi đơn vị cũ, quân nhu theo ngữ cảnh `military`/`border` dùng 1.600. Canh tác bổ sung dùng 10.000. Định nghĩa đã dùng đơn vị tạ bản địa như tiếp nhận 10.000 người, phòng dịch hoặc lương chiến dịch giữ định mức riêng; không nhân lại. Ví dụ thưởng chuỗi kho lương 100 đơn vị cũ thành 600.000 tạ, thay cho 150.000.

Phần thưởng chuỗi được quy đổi ngay trong dự báo để giao diện dùng đúng đơn vị tạ/huấn luyện như engine. Báo cáo canh tác cũng ghi số tạ.

## Hệ quả dài hạn và những luật tiếp tục áp dụng

- Mỗi phần đại biến cố chưa bảo vệ đầy đủ làm phí phần sau tăng thêm 20%. Thiệt hại ghi ngay một lần; ứng phó yếu có dư âm sau tổng kết. Không cộng lại tổn thất đã ghi khi quyết toán.
- Tình trạng đê Xuân/Hạ/Thu có trọng số 20/50/30% trong thu hoạch. Sửa muộn không phục hồi sản lượng đã mất vì các mùa trước. Ở cùng cấp 1 và thời tiết, lịch sử hệ số 60/60/110 thay cho 110/110/110 làm mất 35% sản lượng nền, tức 1.575.000 tạ trước hệ số lao động/thời tiết — hơn một mùa khẩu phần ban đầu.
- Nợ, thiếu quân lương, phe phái và bất mãn vẫn tích lũy theo luật hiện có. Thuế cao là một lựa chọn chiến lược có thể hữu ích, không được mặc định là sai trong mọi hoàn cảnh.
- Chất lượng quân, điều quân, thương vong, nghĩa vụ cống và lịch tăng viện giữ hệ thống hiện hành. Chưa bổ sung các nhiệm vụ mới đã đề xuất trong lượt đánh giá trước.

## Bản lưu

Ván mới lưu `balanceVersion: 1`; thiếu trường này đọc là 0 và tiếp tục bộ cân bằng lịch sử, kể cả sau nhiều lần lưu/tải. Chuỗi mới của ván cân bằng dùng `settlementVersion: 2`; phiên bản 0/1 giữ công thức cũ. Các nhánh kết quả, kinh phí, ngày hẹn và nghĩa vụ đã chốt không bị tính lại. Thành tích ván mới thuộc nhóm luật 0.27; ván cũ giữ `scoreRules`.

Cần bắt đầu triều đại mới để chơi bộ cân bằng mới.

## Phép thử mô phỏng

`tools/balance_simulation.dart` dùng engine sản xuất, toàn bộ trạng thái chỉ đổi qua lệnh thật. Không bơm tài nguyên, không xóa tấu, không ổn định lại nhân vật giữa các mùa, không đọc RNG, âm mưu ẩn, trung thành ẩn hay kết quả chờ đã bốc. Dùng thông tin công khai để chọn phương án và người xử lý. Lỗi lệnh bị engine từ chối được đếm và xuất riêng, không bỏ qua âm thầm.

Các chính sách:

- `prudent`: chăm sức khỏe, hòa giải phe, bảo dưỡng đê, bổ sung lương, xử lý tấu/chuỗi/đại biến cố, phát triển nông nghiệp khi dự trữ thiếu, bán lương vượt nhu cầu tới vụ gặt để giữ vốn lưu động, tạo thu nhập; tìm đình chiến khi đang chiến tranh.
- `extractive`: cùng khung nhưng thuế cao và ưu tiên tiền nhận ngay hơn chỉ số.
- `no-maintenance`: cùng khung nhưng bỏ hành động bảo dưỡng và nâng nông nghiệp. Vẫn có thể nhận hiệu ứng đê từ tấu, vì thế đây không phải kịch bản không sửa đê bằng mọi cách.
- `neglect`: cùng khung nhưng bỏ qua tấu đại biến cố.
- `idle`: chỉ chuyển mùa.

Bot không tối ưu: chưa tự thay/bổ nhiệm nhân sự, phát triển hậu cung hoặc tổ chức chiến dịch quân sự. Không dùng kết quả này để khẳng định người thật chỉ sống được một số năm cố định, hay mọi chiến thuật thuế cao đều kém. Cặp so sánh dùng cùng seed 1–100, giới hạn 60 mùa, không có thời hạn thua nhân tạo. Cờ `--baseline` tạo ván dùng hệ số 0.26 để đối chứng cùng chính sách; không phải đọc một bản lưu thật.

Tái lập:

```sh
dart run tools/balance_simulation.dart --seeds=100 --cap=60 --policy=prudent --baseline
dart run tools/balance_simulation.dart --seeds=100 --cap=60
flutter analyze
flutter test --reporter expanded
flutter test --platform chrome test/challenging_economy_browser_test.dart test/challenging_economy_test.dart test/chain_settlement_browser_test.dart test/development_browser_test.dart
flutter build web --release --no-web-resources-cdn
```

Công cụ `tools/simulate.dart` là heuristic lịch sử; chưa hiểu đầy đủ tấu nhân sự/vàng hiện tại. Dùng công cụ mới cho đánh giá 0.27.

## Kiểm chứng chức năng

- Toàn bộ 1.047 kiểm thử VM (gồm sáu ca cân bằng mới) đạt; thêm kiểm tra Chrome riêng cho bản lưu cân bằng mới và replay hai tab.
- Chrome: sáu ca cân bằng mới, một ca IndexedDB mới, ba ca quyết toán chuỗi lịch sử và một ca công trình/lịch sử vụ mùa đều đạt.
- Phân tích tĩnh sạch; build Web release thành công.
- Kiểm tra bản lưu 0.26 thiếu cờ cân bằng, giữ RNG/số dư/kết quả chờ 7.000 vàng và chuỗi lịch sử 250%; kiểm tra không quyết toán thưởng lần hai khi retry, mở lại trình duyệt hoặc gửi đồng thời hai tab.

## Hiệu chỉnh phép thử

Lượt thử đầu với 100 seed cho bot đầu tư nông nghiệp ngay khi có trên 18.000 vàng, dù kho còn dư, và chưa dùng bán lương dư. Kết quả: thận trọng trung vị 22 mùa, bỏ bảo dưỡng/nâng nông nghiệp 24 mùa. Không dùng kết quả này để kết luận bảo dưỡng có hại; nó cho thấy heuristic đã chi quá sớm, làm tăng nợ và áp lực chính trị. Số liệu cùng mã chính sách lúc đó được giữ ở `output/balance-027/pilot/`.

Lượt chính thức sửa chính sách cho **cả** đối chứng 0.26 và 0.27: chỉ nâng nông nghiệp khi dự trữ dưới 210 ngày và ngân khố trên 22.000; bán phần lương dư sau khi giữ nhu cầu tới vụ gặt cùng dự phòng; đánh giá tấu có xét vốn lưu động cho ba mùa. Không thay thêm hệ số game để ép một lối chơi thắng lối khác. Các giới hạn khác của bot vẫn giữ nguyên.

## Kết quả chính thức — 600 ván

100 seed 1–100 cho mỗi dòng, cap 60 mùa (15 năm). Trung vị dùng mốc thứ 50, P90 mốc thứ 90 trong 100 kết quả đã sắp xếp.

| Bộ luật và chính sách | Trung vị (mùa) | P90 | Khoảng quan sát | Đạt 40 mùa | Còn sống ở cap 60 |
|---|---:|---:|---|---:|---:|
| 0.26: thận trọng, thuế vừa | 33 | 50 | 13–60 | 31/100 | 5/100 |
| 0.27: thận trọng, thuế vừa | 28 | 44 | 16–57 | 20/100 | 0/100 |
| 0.27: thuế cao, ưu tiên tiền | 38 | 60 | 13–60 | 47/100 | 16/100 |
| 0.27: bỏ bảo dưỡng/nâng nông nghiệp | 24 | 33 | 13–42 | 2/100 | 0/100 |
| 0.27: bỏ mặc đại biến cố | 21 | 28 | 14–33 | 0/100 | 0/100 |
| 0.27: chỉ chuyển mùa | 4 | 4 | 3–4 | 0/100 | 0/100 |

Tất cả 600 ván không có lệnh bị từ chối. Các ván còn sống ở cap là dữ liệu bị giới hạn quan sát, không được coi là đã thua ở mùa 60. Số liệu thô và metadata/hash mã nguồn: `output/balance-027/`.

Ở cùng chính sách thuế vừa, trung vị giảm 33 → 28 mùa sau cân bằng; đuôi dài vẫn đạt 57 mùa. Bỏ bảo dưỡng/nâng nông nghiệp giảm xuống 24; bỏ đại biến cố còn 21; không xử lý việc nước còn 4. Phép thử cụ thể về mùa gặt xác nhận sửa muộn không hoàn lại thiệt hại sản lượng của Xuân/Hạ.

Thuế cao + ưu tiên dòng tiền là chiến thuật mạnh hơn trong heuristic này: trung vị 38 mùa và 16/100 ván vẫn sống ở cap. Đây là lợi thế chiến lược cần công bố, không giấu đi để gọi chính sách thuế vừa là tối ưu. Bot vẫn dùng cứu tế, chăm sóc và đối sách để bù tổn thất; chính sách này không phải chỉ bấm thuế cao rồi bỏ mặc. Cần chơi thử người thật và thêm chiến lược nhân sự/quân sự trước khi khẳng định mọi lựa chọn đã cân tuyệt đối.

Các hệ số game không bị chỉnh thêm sau khi thấy bảng kết quả chính thức. Không tăng xác suất thua bí mật, không có mốc năm buộc kết thúc; độ khó đến từ vốn, tổn thất chỉ số, sức khỏe, quan hệ phe, áp lực quân sự và chi phí trì hoãn.
