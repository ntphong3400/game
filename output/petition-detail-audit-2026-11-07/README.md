# Danh mục text dưới “Tác động khi ngự phê”

Ngày rà: 07/11/2026. Chỉ tạo báo cáo; không sửa mã nguồn hoặc save.

## Phạm vi

Đúng phần Text có key `petition-choice-detail-{index}` trong `lib/game/presentation/widgets/petition_decision.dart`. Nội dung được sinh từ `petitionChoiceHint()` rồi lọc qua `detailHint()`.

Trình rà đọc trực tiếp hàm lọc hiện tại và danh mục nhãn của các ô tác động, sau đó gọi cùng các hàm dựng sự kiện. Quét toàn bộ danh mục tấu thường; dựng mẫu các nhóm động (nhân sự theo chức vụ, chuỗi theo bước/nhánh và đại biến cố theo mục tiêu). Dữ liệu mẫu dùng seed 42, năm đầu, mức đại biến cố 3; không lấy từ phiên đang chơi. Kết quả chạy không có lỗi.

**Các số đếm là kết quả ở dữ liệu mẫu, không phải số text bất biến ở mọi save.** Tên người, tiền, lương, ngày, ngưỡng, tiến độ, lịch sử lựa chọn và điều kiện nhân vật thay đổi text. Xem mục mẫu text động để bao phủ các câu điều kiện không nhất thiết xảy ra trong mẫu.

## Danh sách để xem

| Nhóm | Kết quả trong mẫu hiện tại | File |
|---|---|---|
| Tấu thường | 510/1.343 lựa chọn còn mô tả, 71 chuỗi text khác nhau | [Danh sách đầy đủ theo text và lựa chọn](01-tau-thuong.md) |
| Nhân sự | Các nhánh bổ nhiệm, chọn người khác, hồi hương, thăng phẩm, đặc cách, bác đề nghị; 146 chuỗi text mẫu | [Danh sách theo chức vụ và lựa chọn](02-nhan-su.md) |
| Đại biến cố | 311/792 lựa chọn còn mô tả, 30 chuỗi text khác nhau | [Danh sách theo mục tiêu](03-dai-bien-co.md) |
| Cứu trợ tiếp diễn | Cả 3 lựa chọn | [Xem text](04-cuu-tro.md) |
| Save cũ | Theo mùa không dân số, theo tuần, chuỗi cũ và các nhánh cũ | [Xem text](05-save-cu.md) |
| Text biến thiên / UI liên quan | Mẫu câu với {biến}, các mã kỹ thuật và thành phần nằm riêng | [Xem mẫu](06-mau-text-dong.md) |

Trong trạng thái hiện tại có dân số, 144 lựa chọn chuỗi mẫu không còn detail sau các bước dựng lại hint và lọc. Trong chế độ không có dân số, mô tả quyết toán vẫn hiển thị. Do đó không gộp mô tả nguồn chưa chắc hiển thị vào danh sách hiện tại.

## Đọc kết quả

Mỗi file nhóm các chuỗi text giống nhau, sau đó liệt kê mọi tấu và lựa chọn trong lần rà có thể hiện chuỗi đó. Chỉ số lựa chọn bắt đầu từ 0. Mỗi tấu chỉ hiển thị mô tả của lựa chọn đang mở.

Các ô tác động chỉ có số liệu tức thời. Những đoạn về thời hạn, kết quả chờ, giới hạn dân hồi hương, yêu cầu bổ nhiệm và khẩu phần đối trừ có thông tin ngoài các ô này.

## Nguồn đã đọc

- lib/game/presentation/widgets/petition_decision.dart: detailHint(), choiceDetails().
- lib/game/presentation/widgets/petition_impacts.dart: nhãn của ô tác động.
- lib/game/logic/petition_assignment_rules.dart: petitionChoiceHint().
- lib/game/logic/petition_rules.dart: seasonalPetitionChoice(), petitionMoneyPreview().
- lib/game/data/court_personnel_petitions.dart.
- lib/game/data/population_content.dart; lib/game/logic/food_pressure_rules.dart.
- lib/game/data/story_petitions.dart; lib/game/data/reign_content.dart; lib/game/data/settlement_chains.dart.

## Dấu vết mã nguồn tại thời điểm rà

```
9cb31f8b68abe4374ed424729d49e9efab74c4d8e463cc75a9e262c6c8f4cbd1  lib/game/presentation/widgets/petition_decision.dart
6901f88f02d8b04882a0f1a71b8d7d0700817838e15eeef24bb7115b7b46d3d8  lib/game/data/court_personnel_petitions.dart
419fe1b0be932e9c802b371a5593eb071b02c99032346a81d8aba8e3410ed5d1  lib/game/data/population_content.dart
```
