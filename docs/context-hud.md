# Chỉ số và điều hướng theo từng trang

Giang Sơn là nơi xem toàn cảnh. Chỉ màn này hiển thị đủ tám chỉ số:
Ngân khố, Số dân, Lương thực, Quân lực, Lòng dân, Uy quyền, Sức khỏe và
Ổn định triều đình. Màn hình hẹp cuộn ngang dãy chỉ số; lịch và số hành
động giữ ở bên phải. Web và các kích thước mobile dùng cùng thành phần,
không còn biến thể native chỉ có sáu chỉ số. Chiều cao tăng theo cỡ chữ
truy cập để chữ không bị tràn.

Các trang khác hiển thị các nhóm sau. Giá trị, đơn vị, tooltip và lối vào
chi tiết vẫn đọc trực tiếp từ bản lưu.

| Trang | Chỉ số trong header |
| --- | --- |
| Kinh thành | Ngân khố, Uy quyền, Ổn định |
| Triều chính | Ngân khố, Lòng dân, Uy quyền, Ổn định |
| Quốc sự | Ngân khố, Lương thực, Lòng dân, Ổn định |
| Ngân khố | Ngân khố, Lương thực |
| Dân cư & Lao động | Số dân, Lương thực, Lòng dân |
| Quân sự, các bản đồ và trang chi tiết biên ải | Ngân khố, Lương thực, Quân lực |
| Triều thần, Bộ máy triều đình | Ngân khố, Uy quyền, Ổn định |
| Hậu cung, Học tập & cung vụ | Ngân khố, Lương thực, Ổn định |
| Long thể | Ngân khố, Sức khỏe |
| Bản đồ Địa phương, Phủ nha | Ngân khố, Số dân, Lương thực, Lòng dân |
| Đồng ruộng | Ngân khố, Lương thực |
| Đê điều, Kho lương | Ngân khố, Lương thực, Lòng dân |
| Chợ quê | Ngân khố, Số dân, Lòng dân |
| Thôn làng | Số dân, Lương thực, Lòng dân |
| Các bản đồ và trang chi tiết lân bang | Ngân khố, Quân lực, Uy quyền |
| Sử ký, Bảng xếp hạng | Không có dải chỉ số |
| Chi tiết/gặp gỡ nhân vật | Không có HUD toàn quốc; giữ thông tin nhân vật, hành động và chi phí của hành động |
| Giới thiệu, kết thúc | Không có HUD toàn quốc |

## Điều hướng

Thanh menu trái và drawer đã được gỡ ở mọi kích thước. Không còn nút mở
danh mục. Nội dung của trang như danh sách tấu chương hoặc bộ lọc hồ sơ
vẫn là phần làm việc của trang.

- Các phòng trong Kinh thành có nút **Về Kinh Thành** khi chưa có nút quay
  lại trong nội dung. Triều thần hiện hành, Bộ máy triều đình, Hậu cung và
  Cung vụ giữ nút sẵn có, không thêm nút back thứ hai vào header.
- Quốc sự có nút **Về Triều chính**; Dân cư và Quân sự về **Giang Sơn**.
- Triều chính có lối vào **Quốc sự** thường trực, ngoài các cảnh báo và nút
  đã có. Bỏ menu không làm mất đường truy cập khi không còn cảnh báo.
- Kinh thành, Địa phương, Biên ải và Lân bang giữ các nút về Giang Sơn trên
  bản đồ; trang chi tiết giữ nút về khu vực tương ứng.
- Bảng xếp hạng có back về Kinh thành khi đang chơi, hoặc về giới thiệu
  khi chưa có ván/đã kết thúc.
- Chi tiết nhân vật giữ đường quay lại danh sách/trang nguồn của routing,
  kể cả khi mở từ địa phương rồi tải lại.

Các nút này dẫn về trang cha đã ghi rõ trên nhãn, nên vẫn dùng được khi
mở URL trực tiếp. Back/Forward của trình duyệt tiếp tục theo lịch sử URL.
Điều hướng và chọn chỉ số không gửi lệnh game, không chi hành động hoặc
ghi lại bản lưu.

## Mã nguồn và kiểm tra

`lib/game/presentation/widgets/hud_policy.dart` định nghĩa nhóm chỉ số theo
section. `WebGameHud` chỉ dựng các counter được chọn; `RoomHud` dùng chung
thành phần này trên mọi kích thước. Các scene bản đồ truyền section riêng.
Các trang nhân vật là page riêng, không được bọc bằng HUD.

`GameShell` giữ nút về trang cha cho các phòng chưa có nút back; không còn
code sidebar, drawer hay `RoomRail`. Khi thêm trang, chọn nhóm chỉ số trong
`hud_policy.dart`, kiểm tra nút về trang cha và các lối vào liên quan.

```sh
flutter analyze
flutter test test/context_hud_ui_test.dart test/web_hud_test.dart
flutter test test/citadel_hub_test.dart test/kingdom_layout_ui_test.dart test/treasury_layout_ui_test.dart
```

Kiểm thử giao diện bao gồm desktop, 390 px và 320 px; các kiểm tra layout
Ngân khố/Quốc sự còn thử cỡ chữ 1,3. Các kiểm thử nghiệp vụ mở section bằng
URL thay cho menu đã bỏ; các kiểm thử bản đồ, back và HUD kiểm tra đường
đi thật trong giao diện.

Chrome thật được kiểm tra bằng `output/context-hud-browser-test.mjs` với
browser context riêng. Script đối chiếu chỉ số của 16 trang trên desktop
và mobile, thử nút back/Quốc sự, kiểm tra chi tiết nhân vật không có HUD,
so sánh dữ liệu IndexedDB trước/sau và ghi lỗi console. Kết quả:
[results.json](../output/context-hud/results.json).

Ảnh đã kiểm tra:

- [Giang Sơn desktop](../output/context-hud/desktop-citadel.png), [mobile](../output/context-hud/mobile-citadel.png).
- [Ngân khố desktop](../output/context-hud/desktop-treasury.png), [mobile](../output/context-hud/mobile-treasury.png).
- [Triều chính desktop](../output/context-hud/desktop-court.png), [mobile](../output/context-hud/mobile-court.png).
- [Chi tiết nhân vật desktop](../output/context-hud/desktop-character.png), [mobile](../output/context-hud/mobile-character.png).
