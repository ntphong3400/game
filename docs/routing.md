# Điều hướng và URL

Ứng dụng dùng `MaterialApp.router`, `go_router` và `usePathUrlStrategy()`.
URL xác định màn hình đang xem; `GameController` và IndexedDB giữ trạng thái
ván chơi. Điều hướng, tải lại và Back/Forward không gửi lệnh game hoặc chi
hành động.

## Bản đồ đường dẫn

| Màn hình | Đường dẫn |
| --- | --- |
| Giới thiệu, bắt đầu hoặc tiếp tục | `/` |
| Giang Sơn | `/citadel` |
| Kinh thành | `/capital` |
| Địa phương | `/locality` |
| Phủ nha, Đồng ruộng, Đê điều, Kho lương, Chợ quê, Thôn làng | `/locality/administration`, `/locality/agriculture`, `/locality/irrigation`, `/locality/granary`, `/locality/commerce`, `/locality/village` |
| Triều chính, Quốc sự, Ngân khố | `/court`, `/kingdom`, `/treasury` |
| Dân cư, Quân sự | `/population`, `/military` |
| Triều thần, Bộ máy triều đình | `/people`, `/people/government` |
| Hậu cung, Học tập & cung vụ | `/harem`, `/harem/management` |
| Long thể, Sử ký, Bảng xếp hạng | `/health`, `/journal`, `/scores` |
| Biên ải | `/frontier/:country` |
| Doanh Trại, Phủ Trấn Thủ, Cửa Ải | `/frontier/:country/camp`, `/frontier/:country/command`, `/frontier/:country/gate` |
| Lân bang | `/country/:country` |
| Vương cung, Sứ quán, Biên thành | `/country/:country/palace`, `/country/:country/embassy`, `/country/:country/border` |
| Triệu kiến triều thần | `/people/meet/:publicId` |
| Gặp gỡ hậu cung | `/harem/meet/:publicId` |
| Nguyên nhân kết thúc, tổng kết thời gian trị vì | `/ending`, `/ending/summary` |

`:country` nhận `north`, `west`, `south`; `:publicId` là UUID v4 cố định của
cá thể nhân vật trong bản lưu. Ví dụ:
`/people/meet/550e8400-e29b-41d4-a716-446655440000`.
Mã này độc lập với chức vụ, phẩm vị và ID nội bộ như `war-minister` hoặc
`consort_lan`. Người thay cùng chức vụ và nhân vật ở ván mới có UUID riêng.
Link cũ như `/people/meet/war-minister`, `/harem/meet/consort_lan` và dạng
`/#/...` vẫn mở đúng nhân vật rồi chuyển về UUID, giữ `from` và không thêm
một bước trung gian vào lịch sử trình duyệt.
URL không tồn tại có màn thông báo và nút về giới thiệu.

Hộp xác nhận, ngự phê, chọn chức vụ, bộ lọc và các phần mở rộng trong một
bảng vẫn là trạng thái giao diện của trang đó. Chúng không tạo đường dẫn.
Đổi trang sẽ đóng hộp thoại của trang trước. Menu trái và drawer đã được
bỏ; dùng các điểm đến trên bản đồ, nút liên quan trong trang và nút quay
lại trang cha. Xem [HUD và điều hướng theo từng trang](context-hud.md).

## Mở trực tiếp và lịch sử

- `/` luôn là giới thiệu. Ván mới bắt đầu từ đây mở `/citadel`.
- Khi mở đường dẫn có sẵn ván chơi, router chờ `controller.load()` hoàn tất
  rồi mới kiểm tra nhân vật và tính khả dụng của trang.
- Nếu chưa có bản lưu, router về `/?continue=...`. Bắt đầu ván mới xong sẽ
  mở trang đã yêu cầu. Bảng xếp hạng mở được khi chưa có ván chơi.
- Nhân vật đã rời đi hoặc mã không tồn tại đưa về danh sách hoặc trang nguồn.
  Nếu mã đúng nhưng nhầm `/people` và `/harem`, router sửa về đúng nhóm.
- Trang cần hệ thống chưa có trong bản lưu cũ sẽ trở về trang phù hợp.
  Ván đã kết thúc mở `/ending`; trang giới thiệu và bảng xếp hạng vẫn mở được.
- Khi gặp nhân vật từ địa phương hoặc bộ máy triều đình, URL có thêm
  `?from=...` để nút quay lại giữ được trang nguồn sau khi tải lại. Đi từ địa
  phương sang danh sách triều thần cũng giữ thông tin này.
- Back/Forward của trình duyệt khôi phục URL và màn hình tương ứng. Nút quay
  lại trong giao diện đưa về trang cha hoặc trang nguồn; mỗi lần đổi trang
  vẫn được phản ánh trong lịch sử trình duyệt.

URL không chứa dữ liệu ván chơi. Mở cùng link trên trình duyệt hoặc origin
khác dùng bản lưu ở nơi đó, hoặc đưa về giới thiệu nếu chưa có bản lưu.

## Định danh nhân vật và bản lưu cũ

`Courtier.publicId` được ghi cùng nhân vật trong JSON. `LocalGameGateway`
cấp mã trong giao dịch lưu khi bắt đầu ván hoặc khi một lệnh sinh thêm nhân
vật. `load()` phát hiện bản lưu cũ còn thiếu mã và bổ sung trong một giao
dịch; cả ván theo tuần, theo mùa và ván đã kết thúc đều được xử lý. Các lần
tải tiếp theo dùng lại mã đã lưu, không tạo UUID mới.

`lib/game/data/character_identity.dart` dùng nguồn random riêng cho UUID;
engine mô phỏng vẫn xác định hoàn toàn bằng seed và RNG gameplay. Migration
định danh không chi hành động, không tăng revision và không sửa nhiệm vụ,
sổ thu chi hoặc quan hệ đang tham chiếu ID nội bộ. Trường `publicId` là phần
bổ sung tương thích của schema hiện tại. Các bản sao của cùng một ID nội
bộ trong triều đình và danh sách ứng viên dùng chung UUID; giá trị thiếu,
sai định dạng hoặc bị trùng giữa hai người khác nhau được sửa khi tải.

Chuyển chức, thăng phẩm, nhập cung, phong hậu, chuyển danh sách và sao chép
trạng thái giữ nguyên `publicId`. Tất cả lệnh và liên kết nghiệp vụ vẫn dùng
`Courtier.id`. Router tìm UUID trước, nhận ID cũ làm alias và chỉ tạo link
mới bằng UUID.

## Cấu trúc và cách thêm trang

`lib/game/presentation/game_routes.dart` là nơi định nghĩa `sectionPaths`,
chuyển đổi URL và quy tắc chuyển hướng. Các section key cũ vẫn được dùng
bên trong giao diện, ví dụ `local-granary` tương ứng `/locality/granary`.

`GameApp` tạo một router cho toàn bộ vòng đời ứng dụng. `ShellRoute` giữ
`GameShell` và các trạng thái bộ lọc, cuộn, callback. Các trang chính dùng
cùng danh tính page để cập nhật nội dung trong shell; trang nhân vật là page
con khai báo của `/people` hoặc `/harem`, có thể dựng trực tiếp từ URL.

Để thêm một trang:

1. Thêm section key và đường dẫn vào `GameLocation.sectionPaths`.
2. Thêm nội dung hiển thị trong `GameShell` và gọi `navigate(sectionKey)` từ
   điểm vào. Router tự đăng ký các đường dẫn trong bản đồ.
3. Thêm điều kiện trong `GameLocation.redirect` nếu trang cần dữ liệu hoặc
   hệ thống đặc biệt. Luôn đợi tải bản lưu trước khi chuyển hướng.
4. Kiểm tra mở trực tiếp, tải lại, Back/Forward và dữ liệu game không thay đổi.

`GameApp.initialRoute` dành cho kiểm thử và các bản preview. Khi không truyền,
router đọc URL thật của trình duyệt.

## Máy chủ

`flutter run -d chrome` đã hỗ trợ fallback cho các path. Với bản release,
dùng `node tools/serve.mjs`: đường dẫn trang trả `build/web/index.html`, còn
tài nguyên thiếu vẫn trả 404. Máy chủ chỉ phục vụ file, không xử lý luật game.

Hosting khác cần cấu hình SPA rewrite, ví dụ Nginx khi phục vụ ở domain root:

```nginx
location /assets/ { try_files $uri =404; }
location /canvaskit/ { try_files $uri =404; }
location / { try_files $uri $uri/ /index.html; }
```

Nếu đặt ứng dụng dưới một thư mục, build với `--base-href=/thu-muc/` và cấu
hình rewrite tương ứng. Đường dẫn trong bảng tính từ base đó. Tải lại một
path cần máy chủ hoặc service worker hỗ trợ navigation fallback.
`web/game_service_worker.js` bổ sung fallback navigation vào bộ cache tài
nguyên do Flutter tạo, để tải lại path đã dùng khi mất mạng vẫn mở được
ứng dụng. Cần tải tài nguyên của màn hình đó ít nhất một lần khi có mạng;
cơ chế này không làm trang chưa từng tải tự có đủ ảnh hoặc font offline.

## Kiểm tra

```sh
flutter analyze
flutter test test/game_routing_test.dart test/character_public_id_test.dart
flutter test --platform chrome test/character_identity_browser_test.dart
node --test tools/static_server_test.mjs
```

Kiểm tra Chrome thật với một bản lưu: mở `/`, tiếp tục vào Giang Sơn, mở
Kinh thành, Hậu cung, một nhân vật, rồi Back/Forward và tải lại. Lặp lại với
đường dẫn địa phương, biên ải, lân bang và trang con của triều thần/hậu cung.
Thử thêm một cửa sổ chưa có bản lưu để kiểm tra `continue`.

Kiểm tra tự động trên Chrome thật đã lưu ở
`output/routing-browser-test.mjs`, kết quả trong
`output/routing-browser-results.json`. Script dùng browser context riêng,
tạo ván thử riêng và so sánh nguyên bản dữ liệu IndexedDB trước/sau. Chạy
máy chủ release trước, rồi chạy (Playwright chỉ cài ở thư mục tạm):

```sh
npm install --prefix /tmp/king-routing-qa playwright
PLAYWRIGHT_MODULE=file:///tmp/king-routing-qa/node_modules/playwright/index.mjs \
  ROUTING_BASE=http://127.0.0.1:4173 node output/routing-browser-test.mjs
```

Kiểm tra riêng chuyển đổi UUID, migration bản lưu cũ, link alias không thêm
lịch sử và link của ván trước không trỏ nhầm ván mới:

```sh
PLAYWRIGHT_MODULE=file:///tmp/king-routing-qa/node_modules/playwright/index.mjs \
  ROUTING_BASE=http://127.0.0.1:4173 node output/public-id-browser-test.mjs
```

Kết quả lưu ở `output/public-id-browser-results.json`.

Tài liệu nền tảng: [Flutter navigation](https://docs.flutter.dev/ui/navigation),
[URL strategy và cấu hình hosting](https://docs.flutter.dev/ui/navigation/url-strategies).
