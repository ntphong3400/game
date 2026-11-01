# Luật theo mùa — 0.17.0

Triều đại mới dùng Xuân → Hạ → Thu → Đông. Bốn lượt là một năm; vua từ 18 tới 100 tuổi cần 328 mùa. Tên lưu nội bộ `week`, `completedWeeks`, `*Week` vẫn là chỉ số lượt để giữ tương thích; `timeUnit: season|week` là nguồn xác định đơn vị, không tự diễn giải tuần lịch sử thành mùa.

## Hành động và thông tin

- 12 hành động/mùa. Khi hết hành động, được làm thêm một lần nhận 2 hành động, +10 mệt và +8 căng thẳng cùng hệ quả sức khỏe cuối mùa.
- Mỗi mùa chọn mục tiêu 4–6 tấu chương bằng RNG đã lưu và trình đầy đủ ngay đầu mùa. Không phát thêm đợt giữa mùa theo số hành động. Tổng mục tiêu và cờ đã trình đủ được lưu cùng transaction. Tấu chương còn hạn từ mùa trước vẫn được giữ; việc khẩn sinh theo tình hình vẫn áp dụng cơ chế hiện có.
- Mỗi ngự phê tốn ít nhất 1 hành động, kể cả lựa chọn không tốn tiền. Điều này phản ánh thời gian xem xét và ra quyết định.
- Khép mùa không phát thêm đợt tấu chương; các việc thường có hạn sang mùa sau, không bị bí mật bỏ qua. Việc khẩn sinh theo tình hình có thể cần xử lý ngay trong mùa, UI nêu hạn và hỏi trước khi bỏ quá hạn.
- Không tự giải quyết lựa chọn thay vua. Có thể bỏ lại tấu chương nhưng khi quá hạn vẫn chịu phương án mặc định như trước.

## Độ khó theo mùa

| Bắt đầu | Giai đoạn | Chi điều hành/mùa | Mức đại biến cố |
|---|---|---:|---:|
| Xuân năm 1 | Đăng cơ | 0 | 1 |
| Hạ năm 1 | Thử thách đầu triều | 8 | 2 |
| Xuân năm 2 | Tranh quyền | 16 | 3 |
| Xuân năm 6 | Sóng gió | 24 | 4 |
| Xuân năm 16 | Ngoại ưu nội hoạn | 32 | 5 |
| Xuân năm 31 | Giữ vững cơ nghiệp | 40 | 6 |

Có thông báo trước một mùa, thông báo chuyển giai đoạn và dự toán dùng chung công thức với engine. Mức độ được chốt khi đại biến cố mở; không tăng ngầm giữa lúc ứng phó. Từ giai đoạn Tranh quyền, chênh lệch phe phái tiếp tục gây áp lực. Hao mòn uy quyền tăng nhẹ theo giai đoạn.

## Chuỗi và lịch đại biến cố

Cơ chế hiện hành: [chuỗi tấu chương 0.17](story-petitions.md), gồm 10 chuỗi thường và 66 đại biến cố trong cùng luồng ngự phê. Mỗi đại biến cố có bốn bản tấu, nối qua bốn mùa, hạn cuối từng mùa mở; chi phí lớn và tổn thất áp dụng ngay theo phần chưa bảo vệ. Không còn bảng giao bốn mục tiêu song song cho hồ sơ theo mùa mới.

Đại biến cố đầu tiên vẫn sau 3–5 mùa chuẩn bị, từ Đông năm 1 tới Hạ năm 2. Sau tổng kết nghỉ trọn 3–5 mùa. Giữ điều kiện, ưu tiên mùa, lịch sử loại chưa gặp và giãn nhóm gần đây. Một đại biến cố và một chuỗi thường có thể cùng hoạt động; bản tấu tiếp nối được trình trước khi bốc việc thường cho đủ mục tiêu 4–6. Khi nâng bản, giữ phần đã hoàn thành và công việc đang làm, không thu lại phần kinh phí đã sử dụng.

## Kinh tế, công việc và sức khỏe

Nguồn thu phi thuế thường lệ: 80 tiền/mùa. Thuế chỉ thu một lần khi khép mùa Thu, sau thu hoạch, theo công thức `4 × (mức thuế ×45 + phần nguyên lòng dân/3)` với mức nhẹ/vừa/cao tương ứng 0/1/2. Cả phần thu theo lòng dân cũng nằm trong khoản thuế năm, không trả rải ở các mùa khác. Công thức giữ quy mô thuế năm tương đương trước cập nhật; sản lượng thóc ngẫu nhiên không trực tiếp nhân vào số thuế.

Mức vua chọn là chính sách cho kỳ thu tới: đổi trong Xuân/Hạ/Thu thì cuối Thu dùng lựa chọn mới nhất cho năm đó; đổi trong Đông dành cho Thu năm sau. Đổi tốn 1 hành động nhưng chưa trả tiền hoặc áp dụng tác động lòng dân. Khi chốt Thu, mức nhẹ +4 lòng dân, vừa 0, cao −8, chỉ một lần. Phản ứng nhân vật và điều kiện sự kiện dùng mức đã áp dụng gần nhất, không dùng lựa chọn chưa có hiệu lực. Dự toán chỉ tính thuế vào mùa Thu; kế hoạch thuế năm hiển thị riêng ở mùa khác và chưa cộng tiền vào ngân khố.

Chi quân đội: 45 + chiến tranh ×12; dân sinh 20; triều đình 30 + số người trong hậu cung ×6; cộng chi điều hành và nghĩa vụ đến hạn. Dự toán, tiền thực chi, nợ và sổ tiền dùng chung các khoản này, không cộng lại tiền khi đọc dự báo.

Thóc dùng 8/mùa khi hòa bình, 16 khi chiến tranh. Đê hao 6 vào Hạ, 2 ở mùa khác. Quân lực hao 2 khi hòa bình, 6 khi chiến tranh. Thu hoạch một lần khi khép mùa Thu, 45–70 thóc. Không nhân nguyên xi mọi chi phí tuần với 13: nhịp hành động và số quyết định trong năm cũng đã giảm, nên kinh tế được cân bằng theo nhịp chơi mới.

Công việc thường được quy đổi thành 1–2 mùa, riêng thương mại mở vào một mùa nhận doanh thu khi khép cùng mùa năm sau (4 lượt sau lúc giao). Ví dụ giao Xuân năm 1, qua Hạ–Thu–Đông, nhận cuối Xuân năm 2; engine xử lý 5 lần khép mùa kể cả mùa giao. Quan bận suốt chuyến đi. Truy thu chuyển tiền cuối mùa sau, cooldown 2 mùa; bán lương chốt tiền cuối mùa hiện tại. Điều tra nhận kết quả cuối mùa sau, hòa đàm theo ngày hẹn. Đầu tư tấu chương có doanh thu chờ đến cùng mùa năm sau; nguồn thu sau đại biến cố kinh tế cũng bắt đầu cùng mùa năm sau tổng kết. Cooldown nội dung cũ quy đổi ceil(số tuần/13), ít nhất một mùa; hạn ngự phê thường đến mùa kế tiếp. Các mô tả thời lượng của nội dung cũ được chuyển sang đơn vị mới khi hiển thị.

Vay thế gia vẫn nhận 120, trả tổng 150 bằng 50/mùa trong 3 mùa sau; tuyển quân làm thiếu 6 thóc trong 2 mùa sau (tổng 12); cầu hòa cống 16/mùa trong 3 mùa sau (tổng 48). Yêu sách công thần là 8/mùa ×2. Cam kết sau biến cố gom thành 1–2 kỳ, chia lại tổng tiền theo kỳ và làm tròn lên tiền nguyên.

Sức khỏe xét lượng công việc theo mùa: từ 7 mức công việc bắt đầu tính làm quá độ, mức tăng mệt/căng thẳng mỗi công việc giảm so với tuần. Nghỉ ngơi vẫn cần thiết. Vua và quan tăng tuổi sau bốn mùa; nguy cơ qua đời tự nhiên của vua được quy đổi theo độ dài mùa, không cố định trần tuổi.

## Bản lưu và kiểm thử

Giữ schema 2, luật `mvp-0.12.1`, nội dung 13. Lượt từ 0.8–0.9 thiếu đơn vị được xác định là tuần và tiếp tục engine tuần, giữ nguyên tuổi, RNG, hành động, hạn công việc và lịch tiền. Không tự thay thế lượt đang chơi. Lượt mới qua gateway mặc định dùng mùa. Bản lưu ghi riêng nhóm luật dùng để chấm điểm của lượt cũ. Điểm theo mùa được quy đổi sang thời gian thực khi so thời gian trị vì (4 mùa =52 tuần), không so trực tiếp số lượt khác đơn vị.

Lượt theo mùa 0.10.0 tiếp tục được, giữ nguyên ngân khố, RNG, revision và lịch sử. Các khoản thuế/lòng dân đã thu trong năm được ghi thành khoản đối trừ cho kỳ Thu năm đó, cả tiền lẫn tác động lòng dân, để tránh áp dụng hai lần. Đang ở Đông thì đánh dấu năm đã thu và chờ kỳ Thu năm sau; không phát sinh khoản thu bù lúc tải lại. Bản lưu ghi riêng mức đang chọn, mức đã áp dụng, năm đã thu và tiền thực nhận; gửi lặp lệnh khép mùa không trả thuế lần nữa.

Các hồi quy tuần gọi rõ chế độ legacy để kiểm tra tính tương thích. Kiểm thử mùa dùng mặc định sản phẩm, bao gồm mốc tuổi 328 mùa, độ khó, tấu chương đầy đủ đầu mùa, phí ngự phê, thu chi, nghỉ đại biến cố, nhiệm vụ nhiều mùa, vay/trả nợ, lịch thu hoạch, lưu IndexedDB thật và giao diện desktop/mobile.

Kiểm thử thuế bao gồm đổi mức ở Xuân/Hạ/Thu/Đông, chốt sau mùa gặt, tác động lòng dân một lần, mức có hiệu lực với tính cách/sự kiện, đối trừ lượt cũ, lưu/tải lại và gửi lặp lệnh ở cả Memory/IndexedDB, dự toán và lựa chọn trên desktop/mobile.


## Cân bằng quyết định và âm mưu 0.11

Lợi ích tấu chương thông thường còn 65%, tiền còn 75%, lấy phần nguyên tối thiểu 1. Hình phạt giữ nguyên. Phương án không đánh đổi chỉ số chịu tiền ×2 (tối thiểu 40), thóc ×1,5; nếu không tốn tài nguyên thì thêm 2 căng thẳng. Đầu tư rủi ro giữ chi phí gốc, chịu doanh thu thấp hơn và chờ lâu hơn; bảo trợ thương lộ tăng vốn 50%. Mọi giá, kết quả và ngày hẹn hiển thị dùng cùng quy tắc với engine; lựa chọn quá hạn dùng cùng tác động đã cân bằng.

Cấm vệ chờ 3 mùa giữa hai lần huy động, kể cả thất bại, chi 55, căng thẳng +3, giảm cơ bản 7 tiến độ (tùy người phụ trách). Điều tra chi 35, kết quả cuối mùa sau; xác suất là năng lực Mật thám theo chuyên môn trừ `plot ~/ 4 + influence ~/ 10`, giới hạn 10–90%. Thành công giảm 6 tiến độ riêng người bị điều tra. Điều tra mạng lưới từ tấu chương dùng cùng độ khó theo nghi phạm có tiến độ cao nhất; thành công giảm mỗi âm mưu 6. Tấu chương giảm âm mưu chỉ còn 40% hiệu lực cũ, tối đa 4 mỗi người.

Âm mưu đủ điều kiện tăng `3 + (tham vọng − trung thành) ~/ 15` mỗi mùa, cộng áp lực bất ổn/uy quyền thấp/bỏ bê như trước; tự giảm chỉ 1 mỗi mùa khi hết điều kiện. Sau hành động ở mốc 70 còn lại 35 tiến độ, thay vì 15. Cấm vệ chặn thành công chỉ cho 1 uy quyền. Cần chăm quan hệ, trung thành và thế cân bằng phe để xử lý nguyên nhân lâu dài.

Lượt 0.10.0/0.10.1 theo mùa trừ tối đa 2 hành động chưa dùng đúng một lần khi đọc bản cũ. Ngày hẹn công việc, khoản tiền đã chốt và RNG giữ nguyên. Đại biến cố cũ thiếu cờ `demanding` giữ chi phí/điều kiện cũ; biến cố mới lưu cờ để dùng yêu cầu mới. Lịch đại biến cố đã báo giữ nguyên, các khoảng nghỉ sau đó dùng 3–5 mùa. Chi tiết kiểm chứng ở [balance-011.md](balance-011.md).

Từ 0.11.1, cấm vệ huy động vào Xuân chỉ mở lại từ Đông. Khoảng chờ được tính từ lần huy động thực tế trong lịch sử lệnh của bản cũ, giữ khi đổi người/tải lại. Nâng từ 0.11.0 không trừ lại 2 hành động.


## Tab Ngân khố và cập nhật 0.12

Ngân khố có tab riêng gồm Tăng ngân khố, Thu thuế/ưu tiên ngân sách, tình hình kho lương và đê điều, mua thóc/cứu tế/tu bổ đê, công việc đang chạy và Sổ thu chi. Quốc sự giữ các lệnh điều hành, công việc đang thực hiện, nghĩa vụ và ảnh hưởng đang hiệu lực, đối sách khẩn cấp và báo cáo kết quả; ngự phê đại biến cố và chuỗi tấu chương tại Triều chính. UI theo mùa ghi tên mùa cụ thể cho tấu chương, lịch sử tiền và báo cáo kết quả; bản tuần lịch sử giữ đơn vị tuần.

Bản lưu mùa 0.11 đang chơi nhận thêm 4 hành động đúng một lần, giữ nguyên hành động đã dùng, tấu chương đã bốc, RNG và lịch công việc. Mục tiêu 7–10 áp dụng từ mùa mới để không bốc lại hoặc nhân đôi tấu chương hiện tại. Bản lưu mùa 0.10 cộng ròng 2 hành động so với ngân sách 10 cũ. Lượt đã kết thúc và lượt tuần không đổi hành động; nhóm luật thành tích gốc được giữ.


Từ 0.12.1, khi tải lượt theo cơ chế chia đợt mà chưa trình phần giữa mùa, gateway bổ sung đúng nửa còn thiếu trong transaction và tăng revision. Việc đã ngự phê không được dựng lại; không trừ hành động. Tải lại, mở hai tab hay gửi lặp không bổ sung lần hai. Lượt đã nhận đủ, lượt tuần và lượt kết thúc không bị đổi.


Từ 0.15.2, mục tiêu đầu mùa giảm còn 4–6. Bản lưu đang chơi giữ mục tiêu và các tấu chương đã bốc; áp dụng khoảng mới từ mùa tiếp theo. Tải lại không cắt bớt hay bốc lại mùa hiện tại. Luật `mvp-0.15.2`, nội dung 15, schema 2; bản tuần lịch sử giữ cơ chế cũ.
