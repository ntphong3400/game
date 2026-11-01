# Vạn Tuế 0.8 — Độ khó và nhiệm vụ đại biến cố

Luật `mvp-0.8.0`, nội dung hiện tại 8, schema IndexedDB 2. Bản 0.8.1 tiếp tục được lượt nội dung 7, giữ mục tiêu đang làm và lịch sử. Mọi xử lý ở `GameEngine`, dùng PRNG lưu trong lượt, cùng transaction gateway/ledger/biên nhận. UI chỉ gửi ý định. Thời gian trong tài liệu là tuần game.

## Phạm vi đã triển khai

1. **Khủng hoảng riêng:** đói (`grain < 25`), biên phòng (`war > 0 || army < 35`) và âm mưu (nhân vật tại chức có `plot >= 30`). Mỗi loại không được ứng phó chịu mất chỉ số tương ứng: `min(4, ceil(số tuần / 2))`. Mua lương/cứu tế thành công, hoàn tất khai khẩn và nhiệm vụ lương là ứng phó đói; luyện quân/tuyển quân khẩn/hòa đàm hoàn tất là ứng phó biên phòng; an ninh/điều tra thành công là ứng phó âm mưu. Điều tra thành công cũng giảm 8 tiến độ của người bị điều tra. Tiếp kiến và chấn chỉnh vẫn tính việc nước, nhưng không xóa các bộ đếm này. Thoát điều kiện khủng hoảng hoặc ứng phó đúng thì ngắt chuỗi riêng, không phục hồi chỉ số đã mất.
2. **Quan lại:** mỗi lần nhận việc tăng 12 mệt; xác suất giảm `strain ~/ 8` điểm phần trăm, hiệu quả giảm `strain ~/ 5` điểm phần trăm. Quan rảnh hồi 8 mỗi tuần, bận hồi 3. Thành công tăng một công trạng; mỗi 3 công trạng tăng 3 ảnh hưởng và mở một yêu sách 4 tiền × 4 tuần nếu chưa có yêu sách đang chạy của chính người đó. Trả thiếu làm phe của quan −1/tuần. Bãi quan ảnh hưởng ≥60 khiến phe cũ −1/tuần × 3 tuần, bên cạnh xáo trộn tức thời. Mục tiêu đại biến cố dùng thời gian xác định thay cho xác suất: thời gian cơ bản +1 khi trái chuyên môn hoàn toàn, +1 khi mệt ≥60, +1 khi năng lực <50.
3. **Nghĩa vụ cứu nguy:** truy thu giảm nền `max(15, 45 - 6 × số lần đã thử)` kể cả thất bại. Vay 120 trả tổng 150 trong 10 kỳ; tuyển quân +14, chi 15, dân −4, mất 2 thóc/tuần × 6 tuần; cầu hòa giảm chiến tranh 2, chi 20, uy quyền −3, cống 6/tuần × 8 tuần. Mỗi loại chỉ một nghĩa vụ hiệu lực. Khoản định kỳ bắt đầu tuần sau quyết định, được tính trong dự toán và thực thu/chi. Thiếu tiền ghi nợ và mất ổn định 1 (yêu sách thay bằng giảm thái độ phe). Hết kỳ không xóa nợ.
4. **Chuỗi có lịch sử:** tiền cứu trợ thất thoát, thương lộ biên giới và kho lương giáp hạt; mỗi chuỗi 3 giai đoạn × 3 lựa chọn. Quyết định trước thay đổi thưởng/phạt cuối và nghĩa vụ. Mỗi giai đoạn mở trong 3 tuần; giai đoạn sau mở sau quyết định 2 tuần. Quá hạn dùng phương án cuối. Hồ sơ ghi lựa chọn trước và nêu điều kiện thưởng/phạt. Một chuỗi hoạt động tại một thời điểm, có thể song hành đại biến cố; sau kết thúc chờ 6–12 tuần. Chạy đủ 3 loại mới lặp danh sách.
5. **Thế cục:** đăng cơ tuần 1–7; tranh quyền tuần 8–52 (+2 chi điều hành/tuần, mức biến cố 2); sóng gió từ tuần 53 (+4 chi/tuần, mức 3, chênh lệch thái độ phe >35 làm mất thêm 1 ổn định/tuần). Báo trước tại tuần 4 và 49, cùng chỉ báo từ đầu lượt. Không tăng yêu cầu của nhiệm vụ đã mở.

## Đại biến cố

Có 66 loại: 6 loại ban đầu trong bảng dưới và 60 loại DB-01…DB-60 tại [danh sách đã triển khai](major-scenarios-review-60.md), mỗi loại 4 mục tiêu được định nghĩa riêng:

| Loại | Các phần cần bảo vệ |
|---|---|
| Cầu thân | Cam kết tương trợ, sính lễ, đồng thuận trong triều, lễ kết minh |
| Ngoại xâm | Phòng tuyến, tiếp viện, vận lương, đàm phán |
| Châu chấu | Đồng ruộng, lương dự phòng, hạt giống, cứu đói |
| Mưa lớn/vỡ đê | Gia cố đê, sơ tán, lương cứu trợ, cứu hộ |
| Động đất | Cứu người, nhà tạm, cấp lương, y tế |
| Lời đồn về vua | Nguồn tin, chứng cứ, đối thoại các phe, sửa sai |

Chỉ một đại biến cố hoạt động. Sự kiện thường và chuỗi vẫn tiếp tục. Loại vừa gặp không lặp ngay; đê yếu vào mùa Hạ, quân yếu, uy quyền thấp hoặc thiếu lương tăng trọng số của biến cố tương ứng.

Mở tuần W, hạn cuối tuần W+5 (6 tuần gồm tuần nhận). Mỗi mục tiêu cần 1 hành động, kinh phí/thóc được ghi riêng, chọn quan rảnh. Quan bận cho tới khi xong, dùng cùng kiểm tra bận với công trình và sứ đoàn. Nếu lịch hoàn thành vượt hạn thì không nhận lệnh. Đây là công việc có lịch xác định: đủ nguồn lực và còn người phụ trách tại chức thì hoàn thành, không có lần bốc thất bại bí mật. Bổ nhiệm chuyển nhiệm vụ cho người mới, giữ thời hạn đã cam kết; qua đời làm gián đoạn, cần giao lại và không hoàn kinh phí.

Mục tiêu chỉ tính khi công việc hoàn tất. Xử lý công việc đến hạn trước khi tổng kết, nên việc hoàn tất đúng cuối tuần hạn chót vẫn được tính. Đủ 4 mục tiêu thì tổng kết ngay cuối tuần hoàn tất, không phải đợi hết hạn. Nếu chưa đủ thì tổng kết vào hạn. Lượt kết thúc vì nguyên nhân khác trước đó thì không được hồi sinh bằng phần thưởng nhiệm vụ.

### Kết quả và công thức

- 4/4: lòng dân +4, uy quyền +5, ổn định +3.
- 3/4: thiệt hại đáng kể ở phần chưa bảo vệ, hệ số 2.
- 2/4: thiệt hại nặng, hệ số 4.
- 1/4: thiệt hại rất nặng, hệ số 7, dư âm 2 tuần.
- 0/4: thảm họa, hệ số 10, dư âm 4 tuần.

**Có thể thua ngay khi tổng kết.** Không giữ chỉ số tối thiểu ở 1 để cứu lượt chơi. Chỉ số sức khỏe/triều đình/lòng dân/quân lực chạm 0 dùng luật kết thúc hiện có; uy quyền cạn khi triều đình bất ổn cũng có thể mất ngôi. Phần thưởng 4/4 giữ nguyên; không trừ ngược số tuần thành tích.

Ví dụ bỏ mục tiêu sơ tán trong biến cố vỡ đê, mức 1 và chưa có chuẩn bị: đạt 3/4 mất 10 lòng dân; 2/4 mất 20; 1/4 mất 35; 0/4 mất 50. Các phần chưa bảo vệ khác có thiệt hại riêng. Lòng dân 40 mà thất bại 0/4 sẽ về 0 và kết thúc lượt. Có đủ hai mức chuẩn bị vẫn mất 40 ở mức biến cố 1, hoặc 48 ở mức 2. Làm mục tiêu sơ tán sẽ loại bỏ hoàn toàn khoản mất lòng dân tương ứng, nên ưu tiên đúng vẫn có thể cứu triều đại.

UI hiển thị dự báo chính xác theo tiến độ hiện tại, cảnh báo riêng khi khoản mất dự kiến làm chỉ số chạm 0; dự báo chưa tính các diễn biến khác cuối tuần.

Mỗi mục tiêu có nhóm thiệt hại riêng; hoàn thành mục tiêu nào thì bỏ hoàn toàn nhóm thiệt hại đó. Phần còn lại nhân với hệ số theo số mục tiêu, hệ số mức biến cố `1 + (mức - 1) × 0,2` và hệ số chuẩn bị `1 - chuẩn bị × 0,1`, làm tròn từng khoản. Chuẩn bị 0–2 được chốt lúc nhận: đê/quân/uy quyền/ổn định/kho lương/ngân khố phù hợp loại biến cố. UI hiển thị mức chuẩn bị và dự báo chính xác theo các mục tiêu đã hoàn tất.

Dư âm gắn với phần bị bỏ mặc: thiếu lương → mất thóc; thiếu cứu hộ/sơ tán/y tế → giảm lòng dân; thiếu xử lý lời đồn/đồng thuận → giảm uy quyền; thiếu phòng thủ/cam kết → giảm quân lực. Bắt đầu tuần sau tổng kết. Động đất mất 2 lòng dân và 10 tiền ban đầu, có thông báo và dòng sổ riêng; nhiệm vụ ngăn hậu quả tiếp theo. Cầu thân hoàn tất mục tiêu ký cam kết sẽ có nghĩa vụ tương trợ 3 tiền/tuần × 6 tuần từ sau tổng kết, đã công khai trước khi giao.

Chi phí nhận nhiệm vụ chỉ trừ một lần lúc giao; tổng kết chỉ áp thưởng/phạt. Khoản mất vượt ngân khố chuyển phần thiếu thành nợ. Báo cáo kết quả có phần tăng/giảm riêng, vào popup cuối tuần, lịch sử Quốc sự và Sử ký; đóng/xem lại không thực thi lại kết quả.

### Khoảng nghỉ

Lúc tổng kết bốc `gap = 4 + next(21)` một lần, lưu `nextMajorWeek = resolvedWeek + gap + 1`. Có **4–24 tuần trọn vẹn** không mở đại biến cố mới. Ví dụ tổng kết cuối tuần 8, gap 4 → nghỉ tuần 9–12 → mở biến cố tuần 13. Lưu/tải hoặc mở giao diện không bốc lại lịch. Biến cố đầu tiên cũng có 4–24 tuần chuẩn bị tính từ đầu lượt, lịch được báo khi đăng cơ.

## Lưu trữ và thành tích

Giữ nguyên toàn bộ snapshot các lượt 0.2–0.7 trong `archivedRuns`, không áp cân bằng 0.8 ngầm và không xóa khi bắt đầu lượt mới. Bảng thành tích lọc theo luật, vẫn chỉ tính số tuần trị vì; không cộng điểm phụ của nhiệm vụ. Phiên bản schema/luật/nội dung lạ bị từ chối, giữ dữ liệu. Các trạng thái mục tiêu, tiến độ, người phụ trách, lịch nghỉ, chuỗi, lựa chọn, nghĩa vụ, mệt/công trạng, kết quả và random đều lưu cùng trạng thái game.

## Kiểm tra

- Phân tích tĩnh, toàn bộ kiểm thử Chrome, build Web release đóng gói CanvasKit.
- Các test mới kiểm tra đủ 6 loại có thể hoàn thành bằng lệnh hợp lệ trong hạn, mọi tập con mục tiêu đều có hậu quả không nặng hơn khi hoàn thành thêm, 0–4 mục tiêu, hạn chót, hoàn thành sớm, nghỉ đủ 4–24 tuần, chuyển quan/gián đoạn, phản ứng đúng khủng hoảng, nghĩa vụ hữu hạn và sổ tiền.
- Kiểm tra IndexedDB thật đóng/mở lại và lệnh gửi lặp; kiểm tra xác nhận/hủy giao việc và nghĩa vụ ở desktop/mobile.
- Mô phỏng dùng cùng engine qua seed 1–100, cap 260 tuần; `active` là chính sách cũ, `prepared` đọc nhiệm vụ và làm việc phù hợp. Các chính sách chỉ là mẫu tìm lỗi/cân bằng, không phải bot tối ưu hoặc bảo đảm thời gian sống của người chơi.

```sh
flutter analyze
flutter test --platform chrome --reporter expanded
flutter build web --release --no-web-resources-cdn
dart run tools/audit_events.dart
dart run tools/simulate.dart --compare
dart run tools/simulate.dart --spam
```

Kết quả mô phỏng và giới hạn diễn giải: [balance-audit-08.md](balance-audit-08.md).

Kết quả xác minh 0.8.0 (lịch sử): `flutter analyze` không có lỗi/cảnh báo; 215 kiểm thử Chrome đạt; build Web release thành công. Kiểm toán 450 sự kiện thường và 1.330 lựa chọn vẫn đạt.

Cập nhật theo yêu cầu: mốc tăng độ khó đầu tiên chuyển từ tuần 27 xuống tuần 8, áp dụng cả lượt 0.8 đang chơi; nhiệm vụ đã mở giữ nguyên mức độ và thời hạn. Mốc tiếp theo vẫn là tuần 53. Bộ số liệu trong balance-audit-08.md được giữ làm lịch sử ở mốc tuần 27, không phải kết quả cân bằng của mốc tuần 8.

Cập nhật hình phạt theo yêu cầu: thất bại đại biến cố đủ sức kết thúc lượt ở chỉ số thấp–trung bình. Các số liệu mô phỏng lịch sử không đại diện cho khung phạt nặng mới.

Xác minh khung phạt nặng trước mở rộng thư viện (lịch sử): phân tích tĩnh sạch, 222 kiểm thử Chrome đạt, gồm trường hợp chỉ số 15 và 40 bị phạt dẫn tới dân biến/mất nước/bộ máy tan rã; kiểm tra bảo vệ mục tiêu, lưu/tải và không áp phạt lại sau kết thúc.

## Mở rộng 0.8.1

Đã đưa đủ 60 kịch bản review vào thư viện, tổng 66 loại/264 mục tiêu. Lọc tuần, mùa, chiến tranh, nợ và điều kiện kế vị; ưu tiên số lần gặp ít nhất rồi giãn nhóm, trọng số bối cảnh không lấn ưu tiên loại chưa gặp. Lịch sử nhiệm vụ là nguồn đếm nên không mất thông tin khi nâng nội dung hoặc tải lại.

Nguồn thu định kỳ sau các cơ hội thành công được tính qua cùng `budgetIncome` ở dự toán và ledger, chỉ trả từ tuần sau và dừng đúng kỳ. Cam kết viện trợ dùng nghĩa vụ có phí theo mục tiêu đã hoàn tất; chưa đạt mục tiêu kinh tế thì không nhận nguồn thu. Các thành tựu tiếp quản/hiệp ước lưu trong `realmMilestones`; sự kiện kế vị gắn một hoàng thân trưởng thành còn sống, lưu `heirId`, tình trạng chăm sóc và `successionCertified`. Không có bản đồ lãnh thổ riêng; không hồi sinh nhân vật đã qua đời.

Bản lưu `mvp-0.8.0` nội dung 7 được đọc có kiểm soát và ghi lại nội dung 8 ở lần lưu tiếp theo; không reset revision/random, không đổi công việc/hạn/mức độ đã nhận, không buộc chơi lại. Dữ liệu/phiên bản chưa biết vẫn bị từ chối.

Xác minh bản 0.8.1 / 66 biến cố: phân tích tĩnh không có vấn đề; 242 kiểm thử Chrome đạt. Kiểm toán lời dẫn/mục tiêu/kết quả DB-01…60 khớp bản review; 66 loại/264 mục tiêu, mọi tập con mục tiêu được kiểm tra, 60 biến cố mới có thể kết thúc lượt ở chỉ số trung bình 40 khi 0/4. IndexedDB xác nhận nâng bản nội dung 7, lưu/tải trạng thái kế vị, nguồn thu hữu hạn và chống cấp thưởng hai lần. Kiểm toán 450 sự kiện nhỏ vẫn đạt.
