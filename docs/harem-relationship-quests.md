# Hậu cung và nhiệm vụ quan hệ

Hệ thống này thay học tập/cung vụ và điều kiện năng lực của nhân vật hậu cung.
Luật dùng cho lượt theo mùa; bản lưu lịch sử theo tuần không nhận nhiệm vụ mùa.

## Số người và đóng góp

- Tối đa 10 người đã nhập cung, gồm Hoàng hậu. Tú nữ không chiếm chỗ.
- Phong/phế hậu không thay số người. Phi tần xuống Tú nữ giải phóng một chỗ.
- Cả đường tuyển trực tiếp và nhập cung qua hiệu ứng sự kiện kiểm tra cùng giới hạn.
- Trần toàn hậu cung mỗi mùa: uy quyền +5, lòng dân +5, ổn định +5,
  ngân khố +5.000 vàng (50 tiền ở bản lưu dùng đơn vị cũ).
- Mỗi passive chỉ số +1, thiện cảm >95 cho +2; ngân khố +1.000 vàng.
- Mọi người đủ điều kiện có thể đóng góp; Hoàng hậu có thể có hai hiệu ứng.
  Giữ thứ tự ID ổn định khi chia trần. Một đóng góp có thể chỉ nhận một phần hoặc 0.

## Điều kiện

| Tuyến | Bắt đầu phân tuyến | Active passive |
|---|---|---|
| Cá nhân | Trưởng thành, đã nhập cung, thiện cảm ≥60 | Hoàn thành, thiện cảm >70 |
| Hoàng hậu | Đang giữ ngôi hậu, hoàn thành cá nhân, thiện cảm ≥85 | Hoàn thành tuyến riêng, thiện cảm ≥85 và còn ngôi hậu |

Thiện cảm giảm không xóa tiến độ. Mất ngôi hậu tạm dừng tuyến riêng; phong lại
tiếp tục tuyến cũ, không phát thưởng lần nữa. Passive cá nhân ổn định nhận bổ sung
uy quyền khi làm Hoàng hậu; các nhóm còn lại nhận bổ sung ổn định.

Nhân vật hậu cung không lưu chỉ số năng lực. Tấu chương được giao cho họ dùng
thiện cảm thay cho thành phần năng lực trong đánh giá công việc, giữ chuyên môn
và tính cách đã biết. Sắc phong Hoàng hậu cộng cố định 3 ổn định thay công thức
theo năng lực. Quan lại vẫn giữ nguyên hệ thống năng lực.

## Danh mục và chi phí

Nguồn dữ liệu: `lib/game/data/harem_quests.dart`, gồm PT01–PT22 và HH01–HH07:
29 tuyến, 87 chương. Mỗi chương có nội dung và lựa chọn riêng.

- PT01–PT16: bốn tuyến cho mỗi loại passive. Chi toàn tuyến A 4.800–7.200 vàng;
  B bằng một nửa, cộng mất 4–8 thái độ phe và 2 điểm quốc gia theo tuyến.
- HH01–HH04: A 7.200–9.600 vàng; B bằng một nửa, cộng mất 8–10 thái độ phe
  và 3 điểm quốc gia theo tuyến.
- Mỗi chương trả 1/3 tổng phí của hướng đã chọn và một hành động. B ở chương
  1/2 trừ mỗi lần nửa khoản thái độ phe; B ở chương 3 trừ chỉ số quốc gia.
- Có thể xen kẽ A/B. Không có RNG thành bại hoặc thưởng tiền/thiện cảm cuối tuyến.
- Tối đa một chương mỗi người/mùa, dùng chung giới hạn cho cá nhân và Hoàng hậu.
- Phí nhiệm vụ ghi riêng trong sổ ngân khố, không thay phí nhập cung/sắc phong/sinh hoạt.
- Tương tác hậu cung không thay việc xử lý quốc sự để tránh bỏ bê triều chính.

| Tuyến xung đột | Phí vàng | Yêu cầu |
|---|---:|---|
| PT17 | 2.400 | Đưa mục tiêu khỏi chức phẩm 5–7 |
| PT18 | 1.800 | Đưa Phi tần đang đóng góp khỏi hậu cung |
| PT19 | 3.000 | Đưa ứng viên gia tộc vào vị trí phẩm 5–7 |
| PT20 | 2.400 | Tước quyền mục tiêu tại vị trí tranh chấp phẩm 4–6 |
| PT21 | 3.000 | Chuyển vị trí phẩm 4–6 từ phe đối lập sang phe nàng |
| PT22 | 3.600 | Chuyển vị trí phẩm 4–5 từ phe đối lập sang phe nàng |
| HH05 | 3.600 | Đưa Phi tần đang đóng góp khỏi hậu cung |
| HH06 | 4.800 | Đưa ứng viên gia tộc vào vị trí phẩm 3–4 |
| HH07 | 4.800 | Chuyển vị trí phẩm 3–4 từ phe đối lập sang phe Hoàng hậu |

Phí xung đột chia ba chương, cộng hành động/phí/hậu quả nhân sự thật theo luật
hiện hành. Không tự thực hiện bãi chức, không bỏ qua điều kiện nhân sự và không
phạt trùng. Không nhắm quan nhất/nhị phẩm hoặc dùng Phi tần để phế Hoàng hậu.
Ứng viên được câu chuyện xác định là người nhà ghi cố định trong hồ sơ nhiệm vụ;
cùng phe không tự tạo một quan hệ gia tộc toàn cục.

## Random và lưu trạng thái

Chọn nhóm trước rồi mới chọn tuyến. Chỉ đếm Thù dai/Vị gia tộc/Trọng phe đã biết:

| Số tính cách liên quan | Cá nhân: xung đột | Hoàng hậu: xung đột |
|---|---:|---:|
| 0 | 0% | 0% |
| 1 | 25% | 35% |
| 2 | 40% | 50% |
| 3 | 50% | 60% |

Không có mục tiêu/ứng viên hợp lệ thì phân tuyến thường ngay. Trong nhóm thường,
tuyến khớp tính cách có trọng số 2, tuyến nền 1; xung đột hợp lệ có trọng số bằng nhau.
Tuyến đã dùng giảm một nửa trọng số, không đổi xác suất chọn nhóm.

Phân tuyến trong giao dịch lưu game khi chạm điều kiện, không phân trong render.
Lưu cả tuyến, phe, mục tiêu, vị trí, ứng viên gia tộc, lựa chọn, chương và mùa.
Tải lại, mở giao diện hoặc khám phá thêm tính cách không được đổi tuyến.

## Cam kết xung đột

Sau chương 2, kết quả phải tồn tại hai mùa đầy đủ (cá nhân) hoặc ba (Hoàng hậu)
trước khi xác nhận chương cuối. Mùa thao tác nhân sự không được tính là mùa đầy đủ.
Mất điều kiện ở bất kỳ lệnh nào làm đặt lại thời gian kiểm chứng, kể cả trước khi
khép mùa. Tuyến hoàn thành vẫn yêu cầu giữ cam kết:

- Người bị đưa ra không nhập cung lại.
- Người mất vị trí không trở lại quyền hạn tranh chấp.
- Vị trí nâng đỡ tiếp tục thuộc ứng viên gia tộc hoặc phe đã cam kết.

Đảo ngược làm passive ngừng ngay. Khôi phục và kiểm chứng lại thì hoạt động tiếp,
không thu lại phí nhiệm vụ hoặc bắt đọc lại câu chuyện.

Trì hoãn không bị phạt nhiệm vụ. Từ chối yêu cầu cứng trừ 8 thiện cảm cá nhân,
12 với Hoàng hậu một lần; chờ hai mùa rồi tiếp tục cùng tuyến. Quy tắc thiện cảm
100 giữ nguyên. Không hoàn phí đã trả, không random lại tuyến khác.

## Giao diện và bản lưu cũ

`/harem/management` nay là Câu chuyện hậu cung, giữ URL cũ. Hồ sơ gặp gỡ có lối vào
Câu chuyện & passive; bỏ nút học tập/cung vụ và chỉ số năng lực hậu cung.
Hiện số người /10, tổng từng đóng góp/trần, tiến độ, mục tiêu, phí, hậu quả,
thời gian xác minh, đóng góp thực nhận và dự báo sau hoàn thành.

Nâng bản lưu một lần, giữ tiền và nhân vật, dừng công việc/các buff cung vụ cũ,
không thu phí mới hoặc tự tặng hoàn thành câu chuyện. Khoản cũ đã chi không hoàn lại.
Không dựng lại lịch sử giao dịch. Bản lưu đã có hơn 10 người được giữ nguyên để
không tự giáng/đuổi nhân vật: chặn tuyển thêm và chỉ tối đa 10 người đóng góp,
luôn dành chỗ cho Hoàng hậu. Giao diện báo rõ trạng thái vượt giới hạn.

Kiểm thử chính: `harem_quests_test.dart`, `harem_test.dart`, `palace_test.dart`,
`palace_ui_test.dart`, `harem_contribution_ui_test.dart` và bài IndexedDB trong
`browser_storage_test.dart`. Các tên palace trong kiểm thử còn dùng cho đường dẫn
và dữ liệu lịch sử, không còn là tính năng học tập.
