**Kiểm tra lặp hành động ở luật mvp-0.4.0 — 25/10/2026.** Một lần chấn chỉnh hoặc tiếp kiến quan mỗi tuần đủ xóa chuỗi bỏ bê. Đây là hệ quả trực tiếp của điều kiện `affairsThisWeek > 0`, ngay cả khi mọi tấu chương đều bị bỏ qua. Những cách lặp này sống lâu hơn skip hoàn toàn; chưa có cách nào trong mẫu sống đến hết một năm.

Đây là số liệu lịch sử của luật 0.4. Engine từ bản 0.5 bổ sung các mốc kết thúc bắt buộc tại 0 cho Triều đình, Lòng dân và Quân lực, bên cạnh Sức khỏe đã có; chạy lại các lệnh dưới đây sẽ cho kết quả theo luật hiện tại.

Mỗi chính sách chạy seed 1–100, tối đa 260 tuần, qua cùng `GameEngine` mà game sử dụng. Không sửa trạng thái, đọc thông tin bí mật để chọn hành động, xử lý tấu chương, dùng làm thêm hoặc ghi scoreboard. Các lần tiếp kiến mặc định gặp Tể tướng Trần Văn Chính. “Luân phiên” đi lần lượt danh sách quan đang tại chức; “phe dè chừng” gặp người đầu tiên trong phe được hiển thị khi đăng cơ. An ninh chỉ thực hiện khi đủ ngân khố, thiếu tiền thì dùng hành động đó để nghỉ. Đây là các chính sách cố định để tìm cách lách, không phải bot tối ưu.

Số liệu đều là **tuần hoàn thành được tính thành tích**, không tính tuần xảy ra thất bại. P90 dùng phần tử thứ 90 và trung vị dùng phần tử thứ 50 sau khi sắp tăng dần 100 lượt. Mỗi dòng có 100/100 lượt kết thúc trước giới hạn, nên không có số liệu đang sống bị coi nhầm là kết cục.

| Chính sách mỗi tuần | Mã chạy riêng | Nhỏ nhất | Trung vị | P90 | Lớn nhất |
|---|---|---:|---:|---:|---:|
| Chấn chỉnh 1 lần, bỏ phần hành động còn lại | `govern-once` | 20 | 25 | 31 | 34 |
| Chấn chỉnh 3 lần | `govern-three` | 10 | 12 | 12 | 13 |
| Chấn chỉnh 1 lần + nghỉ 2 lần | `govern-rest` | 20 | 23 | 35 | 45 |
| Tiếp kiến Tể tướng 1 lần, bỏ phần còn lại | `audience-once` | 18 | 21 | 28 | 34 |
| Tiếp kiến Tể tướng 3 lần | `audience-three` | 13 | 16 | 18 | 19 |
| Tiếp kiến Tể tướng 1 lần + nghỉ 2 lần | `audience-rest` | 19 | 21 | 27 | 30 |
| Tiếp kiến Thân vương 1 lần + nghỉ 2 lần | `audience-prince-rest` | 19 | 21 | 30 | 35 |
| Tiếp kiến Đại tướng 1 lần + nghỉ 2 lần | `audience-general-rest` | 19 | 21 | 28 | 33 |
| Tiếp kiến phe dè chừng 1 lần + nghỉ 2 lần | `audience-hostile-rest` | 19 | 21 | 28 | 32 |
| Luân phiên tiếp kiến 1 quan + nghỉ 2 lần | `audience-rotate-rest` | 19 | 21 | 28 | 35 |
| Luân phiên tiếp kiến 3 quan | `audience-rotate-three` | 14 | 16 | 18 | 19 |
| Chấn chỉnh + tiếp kiến Tể tướng + nghỉ | `govern-audience-rest` | 20 | 25 | 37 | 41 |
| Chấn chỉnh + an ninh khi đủ tiền + nghỉ | `govern-security-rest` | 21 | 29 | 35 | 48 |

Đối chiếu với đợt mô phỏng `--compare` cùng luật 0.4 và cùng seed: skip hoàn toàn ghi 5–6 tuần, trung vị 5; chính sách chủ động ứng phó các chỉ số/tấu chương có trung vị 78, khoảng 43–119 tuần. Mẫu spam không đạt độ dài của chính sách chủ động, nhưng đã vô hiệu riêng hình phạt bỏ bê bằng một hành động chung chung mỗi tuần.

**Các giới hạn đang hoạt động.** Lặp ba việc mỗi tuần dẫn tới mệt mỏi, căng thẳng và giảm sức khỏe do quá độ. Tiếp kiến một người gây bất mãn phe đối lập; luân phiên người vẫn không giải quyết quân lực, lòng dân và thiên tai. Xen nghỉ bảo vệ long thể nhưng để quốc lực xuống thấp: seed 7 của `govern-rest` sống 45 tuần rồi mất nước, dù sức khỏe 100 và uy quyền 93; seed 19 của `govern-security-rest` sống 48 tuần rồi mất nước, khi uy quyền 96 nhưng lòng dân 8, quân lực 0 và ổn định 2. Tất cả mẫu tiếp kiến/chấn chỉnh còn lại cũng kết thúc do các cơ chế sẵn có.

**Điểm cần siết nếu muốn spam thua sớm hơn.** Theo dõi khủng hoảng cụ thể còn tồn đọng và thời gian không ứng phó, thay vì chỉ hỏi vua có làm một việc trong tuần hay không. Chấn chỉnh giúp uy quyền, tiếp kiến giúp quan hệ; hai hành động này không nên xóa áp lực của nạn đói, nguy cơ ngoại xâm hoặc âm mưu chưa được xử lý. Cảnh báo cần nêu vấn đề đang bị bỏ mặc và hành động nào có thể ứng phó. Việc nghỉ để giữ sức khỏe vẫn cần khả thi. Đây là đề xuất cho vòng cân bằng tiếp theo; đợt kiểm tra này bổ sung công cụ mô phỏng, không thay đổi luật 0.4.

Tái lập toàn bộ: `dart run tools/simulate.dart --spam`. Tái lập một chính sách: `dart run tools/simulate.dart --spam --policy=govern-rest`.
