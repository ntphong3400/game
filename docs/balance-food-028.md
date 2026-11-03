# Cân bằng lương thực 0.28 — 03/11/2026

Lượt mới dùng `balanceVersion: 2`, luật `mvp-0.28.0`, nội dung 25, schema 2. Lượt đang chơi giữ phiên bản 0/1, RNG, tài nguyên, nhóm thành tích và các kết quả đã chốt. Bắt đầu triều đại mới để dùng luật này. Các nâng cấp kinh tế, sức chứa kho và bảo vệ đê của đợt sửa trước được giữ.

## Thông số

- Giữ tiêu dùng toàn quốc: `ceil((dân số × 90 + quân đã phục vụ × 45)/100)` tạ mỗi mùa, trước đối trừ khẩu phần đã cấp. Khởi đầu 922.500 tạ/mùa.
- Bỏ dòng ngân sách Dân sinh thường lệ 2.000 vàng/mùa và phạt lòng dân do không trả dòng này. Bỏ lựa chọn ưu tiên cứu tế khi thiếu tiền trong UI/lệnh của lượt mới. Hành động cứu trợ vẫn do người chơi quyết định và vẫn có phí của nó.
- Sản lượng nền cấp 1–5: 4.100.000 / 4.400.000 / 4.700.000 / 5.000.000 / 5.300.000 tạ/năm. Giữ hệ số lao động, đê, thời tiết 90–110% và thu hoạch cuối Thu. Sức chứa 8/10/12/14/16 triệu tạ.
- Mỗi khoản chi lương tự nguyện trong tấu tăng 25% trên số tạ đã quy đổi, làm tròn lên một lần ở bước tăng phí. Gồm `grainCost` và hiệu ứng âm `food` của phương án chủ động có chi phí/ứng phó. Phương án cuối không cấp nguồn lực giữ nguyên thiệt hại; thưởng và thiệt hại thất bại/kết quả chờ không tăng. Ví dụ tiếp nhận tị nạn 10.000 → 12.500 tạ, sơ tán khi mưa 30.000 → 37.500, mở kho trong tấu lũ 228.000 → 285.000. Các nhiệm vụ quân sự mở từ tấu được báo giá ở màn hình xuất quân, không thu hai lần hoặc nhân thêm 25% lên báo giá chiến dịch.
- Bảng số và mô tả dùng chung bản chiếu với engine; có dấu đã tăng phí để không nhân lặp khi chiếu lại. Phương án dùng vàng thay lương giữ giá vàng hiện tại ở vòng cân bằng này.
- Các hành động phòng dịch, lập ấp, tiếp nhận tị nạn và hồi hương dùng cùng mức phí lương tăng 25% với tấu tương ứng, tránh đổi đường thao tác để trả phí cũ. Luyện quân và cấp trước khẩu phần quân đội giữ định mức riêng.

## Khủng hoảng và quyết định cứu trợ

Thiên tai thường (nhóm Thiên tai hoặc cảnh báo lũ) và đại biến cố nhóm disaster/economy để lại ảnh hưởng khi ứng phó yếu:

| Quyết định | Giảm năng suất | Thời hạn |
|---|---:|---|
| Đầy đủ | Không tạo tổn thất mới | Ảnh hưởng đã có vẫn theo lịch phục hồi |
| Một phần | 12%, hoặc 15% ở đại biến cố mức 4–6 | Mùa đang quyết định |
| Bỏ mặc/quá hạn | 25%, hoặc 30% ở đại biến cố mức 4–6 | Mùa đang quyết định và mùa sau |

Ảnh hưởng cùng nguồn không cộng lặp qua các phần của cùng hồ sơ: giữ mức mạnh hơn khi còn hiệu lực và kéo dài đến hạn mới. Các nguồn độc lập nhân phần năng suất còn lại; tổng giảm do gián đoạn và huy động dân phu bị chặn ở 35% so với lao động dân sự hiện hữu. Mất dân/lao động thực tế và tình trạng đê vẫn có hậu quả riêng.

Đầu mùa sau, nếu ảnh hưởng còn hiệu lực, một tấu tiếp tục cứu trợ được trình cho mỗi hồ sơ. Không có khoản tự động xuất lương cứu trợ. Tấu cho chọn:

- Đầy đủ: khẩu phần tham chiếu `ceil(dân số × 0,9 × tỷ lệ ảnh hưởng)`, cộng 25% hậu cần; dừng ảnh hưởng từ mùa hiện tại, lòng dân +2.
- Một phần: nửa đợt cấp lương, giảm một nửa tỷ lệ ảnh hưởng còn lại, làm tròn lên.
- Chưa cấp/quá hạn: không xuất lương; giữ tổn thất đến hạn, lòng dân −2. Quá hạn không tốn hành động.

Tấu và quyết định được lưu cùng transaction; một hồ sơ không trình lại sau khi đã quyết định trong mùa. Khẩu phần cứu trợ đã cấp được đối trừ đúng mùa, không vượt nhu cầu tiêu dùng còn lại; phí hậu cần vẫn là chi phí bổ sung. Áp dụng cho tấu tiếp tục cứu trợ, mở kho trong tấu lũ/thiếu lương, và hành động cứu tế thành công. Giống, vật tư và các chương trình khác không được mặc định là khẩu phần để đối trừ.

Ví dụ cứu trợ tiếp diễn cho ảnh hưởng 25% ở một triệu dân: xuất 281.250 tạ, trong đó tối đa 225.000 tạ đối trừ tiêu dùng; 56.250 tạ hậu cần là chi bổ sung. Tăng số xuất kho không đồng nghĩa tăng cùng tỷ lệ tiêu hao thực sau đối trừ. Độ khó được đo trên dự trữ cuối mùa và thiếu khẩu phần.

Ảnh hưởng được ghi vào mẫu lao động/năng suất cuối từng mùa. Không sửa ngược các mẫu đã chốt; cứu trợ vào Thu chỉ phục hồi phần Thu. Lịch Xuân/Hạ/Thu của đê vẫn giữ riêng, và mẫu lao động mùa Đông tiếp tục tham gia chu kỳ sản xuất theo cơ chế hiện có.

## Chiến tranh

- Tiếp tế cho 90 ngày/mùa: `ceil(quân × 90 × 2 /100 × (1 + phụ phí))` tạ. Phụ phí 20% cho nhiệm vụ một mùa, 40% cho hội chiến/công thành/bảo vệ kinh thành kéo dài hai mùa.
- Đối trừ khẩu phần thường lệ đã cấp: `ceil(quân × 90 × 1,5 /100)` tạ mỗi lần cấp cho một mùa. Ví dụ 10.000 quân: xuất 21.600 hoặc 25.200 tạ, đối trừ 13.500. Nhiệm vụ hai mùa cấp lúc xuất quân và trả tiếp tế mùa tiếp theo; không cho xác nhận cùng yêu cầu hai lần.
- Mỗi quân làm nhiệm vụ huy động một dân phu. Số người phục vụ trong mùa được giữ đến hết mùa kể cả rút quân sớm, tác động lao động nông nghiệp, kinh tế và quân khí. Quân/dân phu được giải phóng cho mùa sau khi nhiệm vụ thực sự kết thúc.
- Giao tranh giảm 10% năng suất nông nghiệp; sau hai mùa chiến tranh hoặc khi ưu thế ≤−30, giảm 20%. Kết hợp với khủng hoảng theo phần năng suất còn lại, giới hạn giảm 35% cùng huy động dân phu. Hòa bình ngăn ảnh hưởng tiếp theo; lịch sử mùa đã chốt không bị xóa.

## Kiểm chứng và mô phỏng

Kiểm tra: `test/food_pressure_test.dart`, `test/food_pressure_ui_test.dart`, `test/food_pressure_browser_test.dart`, cùng toàn bộ kiểm tra hiện hữu. Kiểm chứng giá tạ, đối trừ, hết hạn, mẫu vụ Thu, lưu/tải, hai tab, cấp tiếp tế và UI desktop/điện thoại.

Mô phỏng toàn game: `tools/balance_simulation.dart`, các lệnh thật qua engine, cùng seed cho trước/sau. `--previous-food` tạo hồ sơ cân bằng 1 qua tùy chọn engine để đối chứng, không sửa trạng thái giữa các mùa. Chính sách thận trọng, bỏ bảo dưỡng, bỏ mặc đại biến cố và tham chiến; ghi dự trữ, thiếu khẩu phần, mua lương, nâng cấp, nguyên nhân kết thúc và lệnh bị từ chối. Bot tham chiến chủ động nhận nhiệm vụ, chọn quân theo lực lượng khả dụng và cấp tiếp tế, không đọc kết quả ngẫu nhiên đã chốt.

Mô hình dự trữ tách riêng: `tools/food_reserve_simulation.dart`, 100 seed thời tiết, 120 mùa, cấp 1/3/5; dùng các hàm sản xuất/hao mòn/khẩu phần/tiếp tế thực. Cố định một triệu dân, 50.000 quân; không mô phỏng tiền, hành động, chính trị, nhập cư hoặc mua lương. Các cấu hình bảo dưỡng giả định luôn có khả năng sửa đê trước mùa. Đây là thí nghiệm dòng lương, không phải số năm sống của người chơi thật. Các mẫu khủng hoảng là kịch bản kiểm tra sức chịu đựng được đặt trước, không phải tần suất rút tấu trong game.

Số liệu tái lập và dấu vết từng seed: `output/balance-food/`. Báo cáo tổng hợp: [kết quả mô phỏng](../output/balance-food/report.md).

```sh
dart compile exe tools/balance_simulation.dart -o /tmp/game-food-simulation
/tmp/game-food-simulation --seeds=30 --cap=60 --policy=prudent --policy=no-maintenance --policy=neglect --policy=campaign --previous-food --runs > output/balance-food/before.jsonl
/tmp/game-food-simulation --seeds=30 --cap=60 --policy=prudent --policy=no-maintenance --policy=neglect --policy=campaign --runs > output/balance-food/after.jsonl
dart run tools/food_reserve_simulation.dart > output/balance-food/reserve-scenarios.jsonl
```
