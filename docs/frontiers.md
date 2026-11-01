# Ba cửa ải và quân đồn trú

Triển khai bộ thông số đã được duyệt ngày 31/10/2026. Quân đội dùng chất lượng chung; mỗi nơi đóng quân có quân số và số quân đang đi riêng.

## Điều hướng và giao diện

Giang Sơn → Bắc Ải / Tây Ải / Nam Ải. Mỗi trang có đúng ba công trình tương tác: **Doanh Trại**, **Phủ Trấn Thủ**, **Cửa Ải**. HUD, về Giang Sơn, khóa mùa, làm thêm và kéo bản đồ trên màn hẹp dùng cùng cách tương tác với Kinh Thành. Dấu son báo nhiệm vụ mở, yêu cầu tiếp tế hoặc phòng thủ thiếu.

- Doanh Trại: quân thuộc đồn trú, quân xuất trận, quân rảnh, lực lượng bảo vệ; huấn luyện, quân khí, sĩ khí, hậu cần; điều quân và phân bổ bốn nơi.
- Phủ Trấn Thủ: quan hệ, ưu thế, chiến dịch, tướng, ngoại giao và quân báo riêng của mặt trận.
- Cửa Ải: quân địch chính xác, tăng viện gần nhất, so sánh sức phòng thủ/sức ép, nhận nhiệm vụ, chọn quân/tướng, xuất trận, tiếp tế và rút quân.

## Quân triều đình

Khởi đầu: Kinh Thành 20.000; Bắc/Tây/Nam mỗi nơi 10.000. Quân thuộc đồn trú bao gồm quân đi nhiệm vụ từ nơi đó. Quân rảnh tại nơi = quân thuộc đồn trú − quân đang đi từ nơi đó. Tổng quân các nơi luôn bằng tổng quân đội; quân đang đi không bị cộng thêm thành nguồn khác.

Điều chuyển 2.000/5.000/10.000, tốn một hành động, đến ngay, không thêm phí vàng hoặc lương. Xem trước quân trước/sau cả hai nơi, xác nhận rồi mới ghi lệnh. Thiếu quân rảnh thì khóa lựa chọn. Rút làm Kinh Thành còn dưới 10.000 quân rảnh hoặc cửa ải có tỷ lệ phòng thủ dưới 1 gây cảnh báo mềm. Có thể điều giữa ba ải và từ/về Kinh Thành.

Tân binh thường lệ và khẩn cấp tập kết Kinh Thành; huấn luyện bình quân, tuyển/giải ngũ, quân phí, khẩu phần và trang bị tiếp tục theo luật dân số. Quân sống sót trở về nơi xuất phát, thương vong trừ đúng nơi đó. Hao hụt dân số thường lệ được phân bổ trên quân rảnh tại các nơi; không tính lại rủi ro của đạo quân đang đi.

## Phòng thủ cuối mùa

```text
Q = 0,30 × huấn luyện + 0,25 × quân khí + 0,20 × sĩ khí + 0,25 × hậu cần
D = điểm chỉ huy chung hiện có
Sức phòng thủ = quân bảo vệ × Q/100 × (0,8 + 0,004 × D) × 1,35
Sức ép = quân địch mặt trận × chất lượng địch/100 × tình hình × quan hệ
R = sức phòng thủ / sức ép
```

Tình hình: hòa bình 0,80; căng thẳng 1,00; chiến tranh 1,15. Quan hệ ≥30: 0,90; −29…29: 1,00; ≤−30: 1,10. Quân rảnh cùng quân đang thực hiện nhiệm vụ giữ ải tại chính mặt trận đóng góp bảo vệ. Quân trinh sát, hộ tống, đánh ra ngoài hoặc đang rút về không đóng góp.

| R | Giảm ưu thế/mùa |
|---|---:|
| ≥1 | 0 |
| ≥0,90 và <1 | 1 |
| ≥0,75 và <0,90 | 2 |
| ≥0,60 và <0,75 | 3 |
| ≥0,40 và <0,60 | 4 |
| <0,40 | 6 |

R≥1,20 hiển thị “Dư sức phòng thủ”; không tự tăng ưu thế. Chất lượng đã nằm trong Q nên không phạt thêm theo từng chỉ số. Ba mặt trận chốt đồng thời theo dự báo hiện tại lúc khóa mùa, trước sản xuất, hồi quân hoặc nhận tân binh cuối mùa; quân về không bảo vệ ngược thời gian. Ưu thế do nhiệm vụ vẫn tính riêng. Hòa ước/bảo hộ miễn giảm ưu thế do quân đồn trú, có thêm một mùa chuẩn bị khi bảo hộ kết thúc. Hết hòa ước ghi thông báo; mùa chuẩn bị hiển thị thời điểm đánh giá lại. Ngưỡng −70 chỉ mở phòng thủ kinh thành khi đang chiến tranh.

## Địch và tăng viện

Mỗi nước khởi đầu 12.500 quân, chất lượng 65; không tự tăng chất lượng theo năm. Trinh sát/tập kích vẫn có hiệu ứng suy yếu chất lượng theo luật chiến tranh hiện hữu.

Một lần khi chuyển từ Đông sang Xuân, bắt đầu năm 2; ba nước bốc độc lập bằng RNG đã lưu. Với y là năm vừa kết thúc:

```text
Cận dưới = min(4.000, 1.000 + 200 × (y − 1))
Cận trên = min(5.000, 2.000 + 300 × (y − 1))
```

Bốc đồng xác suất bước 100. Cộng vào quân còn sống; trần 40.000 quân mỗi nước. Phần vượt trần không tích thành dự bị ẩn; quân báo nêu số bốc, số thực nhận và tổng quân mới. Bốc và quân báo chỉ xảy ra một lần/năm; tải lại hoặc gửi lại receipt không bốc lại.

| Nhiệm vụ | Tỷ lệ quân địch mặt trận |
|---|---:|
| Trinh sát | 10% |
| Hộ tống | 15% |
| Tập kích | 20% |
| Giải vây | 30% |
| Giữ ải | 40% |
| Hội chiến/thủy chiến/công thành | 50% |

Làm tròn lên bội số 100, giới hạn bởi quân địch chưa được giữ chỗ. Nhiệm vụ mở, đang đánh hoặc đang rút về giữ chỗ cùng một nguồn quân địch. Tối đa một nhiệm vụ thường nhóm lớn tại mỗi nước; phòng thủ kinh thành là tình huống khẩn cấp, dùng số quân địch còn chưa giữ chỗ. Nhiệm vụ riêng từ tấu chương có thể thay mục tiêu lớn thường lệ chưa nhận; không hủy đạo quân đã xuất trận hoặc mục tiêu đại biến cố.

Quân địch đang giao chiến vẫn thuộc tổng quân gây sức ép, không cộng lần hai. Khi quân báo kết thúc giao chiến: ta thắng → địch mất 25% đạo tham chiến; ta thua → địch mất 10%. Rút/hủy/gián đoạn hoặc không có giao chiến → 0. Trinh sát và hộ tống trong bản này không gây thương vong địch. Phần sống sót trả về nguồn địch; chỉ tổn thất bị trừ. Xác suất và thương vong quân ta giữ công thức chiến tranh hiện hữu.

## Bản lưu

Bản lưu dân số chưa có phân bổ: giữ nguyên tổng quân, quân/tướng bận, RNG và kết quả đã chốt; giữ chỗ các đạo hiện hữu rồi chia quân rảnh theo trọng số 2:1:1:1. Đạo lịch sử chưa lưu nơi xuất phát được gán theo quốc gia mục tiêu, không có quốc gia thì về Kinh Thành. Từ đó lưu nơi xuất phát rõ ràng. Địch khởi tạo tối thiểu 12.500 hoặc đủ số quân đang được giữ chỗ trong nhiệm vụ cũ; các đạo lịch sử vượt trần được bảo lưu và không nhận tăng viện vượt trần. Không bù các đợt tăng viện trước ngày nâng bản lưu. Bản lưu dùng bộ luật cũ không tự đổi đơn vị hay cách chơi.

## Xem trước và kiểm tra

- Bản thử riêng: `flutter build web --release --target tools/frontier_preview.dart --output build/frontier-preview`, rồi `node tools/serve_frontier.mjs`.
- Mở http://127.0.0.1:4180/; tham số `front=north|west|south`, `place=camp|command|gate`, `scenario=war|weak`.
- Bản thử dùng MemoryGameStore, không đọc/ghi bản lưu của người chơi. Tải lại bắt đầu lại bản thử.
- Bản chính: `flutter build web --release`; `node tools/serve.mjs`.
- Logic: `test/frontier_test.dart`, chiến tranh/dân số/receipt và nâng bản lưu; có kịch bản 80 mùa với nguồn lực được giữ đủ để kiểm tra bảo toàn quân, trần tăng viện và bản ghi. Kịch bản này không chứng nhận độ khó kinh tế hay cân bằng một ván chơi hoàn chỉnh.
- Giao diện: `test/frontier_ui_test.dart`, ba cửa ải, ba công trình, điều quân, hủy/xác nhận, xuất trận theo quân tại nơi; viewport 1440×900, 390×844, 320×568, 844×390.
- Xuất ảnh thực tế: `flutter test --dart-define=FRONTIER_PREVIEWS=true test/frontier_ui_test.dart`; ảnh ở `output/frontier-preview/`.

## Tranh nền

Ba ải dùng tranh riêng cùng phong cách màu nước và nét mực trên giấy ngà. Bắc Ải là thành đá xám, rừng thông, núi lạnh phủ tuyết ở xa; Tây Ải là thành đất đá vàng nâu, khe núi khô, doanh trại kỵ binh và thương lộ; Nam Ải giữ cảnh núi rừng xanh, tre và suối. Các điểm tương tác giữ vị trí gần nhau để người chơi quen thao tác, nhưng địa hình, kiến trúc và đường đi khác nhau. `frontierBackgroundAssets` trong `frontier_hub.dart` chọn asset theo quốc gia.

| Cửa ải | Asset trong dự án |
|---|---|
| Bắc | `assets/images/frontier-north-watercolor.webp` |
| Tây | `assets/images/frontier-west-watercolor.webp` |
| Nam | `assets/images/frontier-watercolor.webp` |

Ảnh được tạo bằng công cụ ImageGen tích hợp. Hai tranh Bắc/Tây dùng tranh Nam làm tham chiếu phong cách và bố cục ba điểm; PNG gốc được giữ trong generated_images, bản WebP đưa vào dự án. Không dùng bộ lọc đổi màu để tạo khác biệt. Kiểm tra giao diện xác nhận ba tuyến chọn ba asset riêng và mở được các điểm tương tác.

### Prompt Bắc Ải

> Use case: historical-scene. Asset type: production watercolor background for the NORTH frontier page (Bắc Ải) in an ancient Vietnamese strategy game. Create a new distinct painting using the reference only for the fine ink / watercolor on ivory paper art style and three-destination layout. Landscape 1536x1024, full bleed, no frame, no writing or UI.
> Scene: a cold, windswept northern highland fortress at the edge of a vast conifer forest. Slate blue-grey mountains, pale mist, distant snow on high peaks, dark green pines, scattered late autumn ochre trees and frost in shaded ground. A broad rocky mountain valley and winding road beyond the gate, NOT the lush karst rainforest and waterfalls of the reference. Cooler light, restrained blue, grey, pine green with warm terracotta architectural accents.
> Keep the approximate interaction anchors: main fortified gate roof at x50%, y27%; army camp drilling yard at x24%, y62%; military governor command mansion at x77%, y59%. Keep only these three major destination buildings. The central fortress is a rugged dark grey single-arched stone gateway with a low broad traditional Vietnamese tiled watch pavilion and sturdy walls following a rocky ridge; silhouette visibly different from the southern gate. Left foreground: orderly rectangular barracks with dark tiled roofs, a few wind-braced tents, soldiers training and stacked firewood. Right foreground: compact traditional Vietnamese governor's manor with charcoal roofs, stone-walled courtyard, military banners, a small pine grove. Supporting scenery: grain carts, horses, merchants wrapped for cold weather, small watchtower. A thin icy creek is acceptable but no large waterfall or ornamental waterwheel. Rich detail with tiny figures, bird's-eye oblique view, hand-painted pigments and delicate ink linework. Do not recolor or copy the southern painting; make the terrain, fort architecture, paths and vegetation genuinely different. No modern objects, no text, no watermark.

### Prompt Tây Ải

> Use case: historical-scene. Asset type: production watercolor background for the WEST frontier page (Tây Ải) in an ancient Vietnamese strategy game. New painting, landscape 1536x1024, full bleed, no border. Reference is for fine ink and watercolor on warm ivory paper style plus the three functional building layout ONLY. Do not reproduce or merely recolor that scene.
> Scene: a sun-warmed western frontier mountain pass through ochre sandstone ridges and a rugged dry river gorge. Terraced russet cliffs, tawny grassland, sparse wind-shaped trees, small dusty trading road with packhorses, timber bridges over a shallow seasonal stream. Distinct earth palette: burnt sienna, sandstone gold, muted copper, dusty sage and hazy mauve distant mountains, warm late afternoon light. No tropical jungle, no waterfalls, no snow or pine forest. It is ancient Vietnam's dry western highlands, not an Arabian desert and not a Chinese imperial city.
> Keep approximate UI anchors: main gate roof at x50%, y27%; army camp training yard at x24%, y62%; military governor command manor at x77%, y59%. Central upper gateway: broad sandstone and rammed-earth frontier fort with paired square stone bastions, one traditional Vietnamese timber tiled pavilion above a dark passage, wall continuing along the ochre ridge. Make the gate silhouette visibly different from the reference. Left foreground: cavalry encampment with earth-toned tents, a broad training paddock, barracks, horses, soldiers drilling. Right foreground: low traditional Vietnamese governor mansion complex, terracotta tiles, shaded veranda, walled courtyard and sparse old tree. Supporting scenery: a small grain store, wooden watchtower, transport carts and a small packhorse caravan approaching the gate along a visibly winding western trade route. Only these three major destination buildings; supporting structures subordinate. Rich small-scale detail, delicate ink hatching and washed pigments on paper, coherent bird's-eye oblique perspective. No writing, no letters, no UI, no labels, no watermark, no modern objects.

### Prompt Nam Ải

> Use case: historical-scene. Asset type: production background illustration for Vạn Tuế ancient Vietnamese strategy game, landscape 1536x1024. Create a richly detailed panoramic fortified mountain border pass in fine ink and watercolor on warm ivory paper, matching the illustrative density, ochre tiled roofs, jade vegetation and hand-painted style of the reference image. Reference image is style reference only, do not reproduce the capital city. Composition fixed for interactive hotspots: one monumental stone gate with traditional Vietnamese watch pavilion at upper center (roof centered x50% y28%), flanking stone walls climb into wooded mountains; large army encampment in foreground LEFT (x24% y64%) including barracks, rows of canvas tents, soldiers drilling in a courtyard; military governor's administrative mansion foreground RIGHT (x77% y64%), an elegant enclosed ochre-roofed command courtyard. Only these THREE major destinations, clearly separated. Winding stream, bamboo, lush mountain forest, road leading through gate into mist beyond; supply carts, grain store, small observation tower and merchants are small supporting scenery. Bird's-eye oblique landscape, no closeup figures. Balanced detailed composition reaching all edges, no border, no UI, no labels, no writing, no letters, no watermark. Soft warm daylight, restrained pigment, delicate ink linework, watercolor paper texture.

