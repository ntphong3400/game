# Kết quả mô phỏng lương thực 0.28 — 03/11/2026

Đối chứng trước/sau đợt cân bằng lương thực này, đã bao gồm sửa trần 999 và các nâng cấp kinh tế/kho/đê của đợt trước. 30 seed 1–30 mỗi chính sách, tối đa 60 mùa/ván: **240 ván toàn game**. Cùng heuristic và seed cho hai hồ sơ; hồ sơ trước dùng `GameEngine(foodBalance: false)` và balanceVersion 1. Các chuyển trạng thái đi qua lệnh engine thật, không bơm tài nguyên hoặc chỉnh trạng thái giữa các mùa.

## Thiếu khẩu phần và biện pháp bổ sung

| Chính sách | Ván thiếu khẩu phần trước → sau | Tổng mùa thiếu trước → sau | Lần mua lương trước → sau | Lần khởi công nông nghiệp trước → sau |
|---|---:|---:|---:|---:|
| Thận trọng | 0/30 → 1/30 | 0 → 1 | 0 → 2 | 2 → 8 |
| Bỏ bảo dưỡng/nâng nông nghiệp | 26/30 → 28/30 | 73 → 80 | 129 → 238 | 0 → 0 |
| Bỏ tấu đại biến cố | 0/30 → 0/30 | 0 → 0 | 0 → 2 | 2 → 10 |
| Chủ động tham chiến | 0/30 → 3/30 | 0 → 3 | 0 → 20 | 0 → 4 |

Mua lương và khởi công được đếm cả lần thử không thành công; không đồng nghĩa toàn bộ lần mua/khởi công đều giao đủ thành quả. Thiếu khẩu phần được đếm từ báo cáo quyết toán thật, không chỉ từ việc số dư có lúc xuống thấp.

## Thời gian trị vì và dự trữ

| Chính sách | Trung vị mùa hoàn thành trước → sau | Trung vị dự trữ cuối ván trước → sau (tạ) | Lệnh bị từ chối trước → sau |
|---|---:|---:|---:|
| Thận trọng | 26 → 30 | 5,625,675 → 5,096,280 | 0 → 0 |
| Bỏ bảo dưỡng/nâng nông nghiệp | 24 → 24 | 62,132 → 96,000 | 0 → 0 |
| Bỏ tấu đại biến cố | 19 → 22 | 5,211,960 → 3,983,693 | 0 → 0 |
| Chủ động tham chiến | 16 → 16 | 4,854,247 → 1,332,415 | 0 → 0 |

Dự trữ cuối ván được quan sát ở thời điểm kết thúc khác nhau, với dân số/cấp nông nghiệp khác nhau; không coi đây là so sánh tại cùng năm. Ván còn sống ở mốc 60 mùa là dữ liệu bị giới hạn quan sát, không bị ép thua.

- Thận trọng: kết cục trước `{"coup": 12, "poisoning": 6, "illness": 7, "exhaustion": 4, "courtCollapse": 1}`, sau `{"coup": 15, "exhaustion": 3, "illness": 7, "poisoning": 3, "alive": 2}`.
- Bỏ bảo dưỡng/nâng nông nghiệp: kết cục trước `{"coup": 13, "exhaustion": 1, "rebellion": 11, "puppet": 2, "poisoning": 2, "courtCollapse": 1}`, sau `{"coup": 11, "puppet": 4, "rebellion": 12, "poisoning": 2, "illness": 1}`.
- Bỏ tấu đại biến cố: kết cục trước `{"exhaustion": 5, "coup": 8, "illness": 11, "courtCollapse": 2, "rebellion": 1, "puppet": 1, "poisoning": 2}`, sau `{"exhaustion": 5, "coup": 11, "illness": 11, "courtCollapse": 1, "rebellion": 1, "poisoning": 1}`.
- Chủ động tham chiến: kết cục trước `{"exhaustion": 4, "illness": 2, "invasion": 14, "coup": 8, "poisoning": 2}`, sau `{"invasion": 23, "poisoning": 1, "coup": 4, "illness": 1, "courtCollapse": 1}`.

Nhóm tham chiến có 324 → 331 lần xuất quân và 82 → 40 lần cấp tiếp tế mùa tiếp theo. Đây là bot chọn chiến dịch bằng thông tin công khai, không phải chiến thuật quân sự tối ưu.

## Thí nghiệm dự trữ tách riêng

2.400 mô phỏng dòng lương: 100 seed thời tiết × 3 cấp nông nghiệp × 4 tình huống × 2 hồ sơ, mỗi lần 120 mùa. Dân số cố định một triệu, quân số 50.000; không có tiền, chính trị, nhập cư, mua lương hoặc hạn mức hành động. Nhóm bảo dưỡng giả định luôn sửa đê về 100 trước mùa. Nhóm chiến tranh duy trì 10.000 quân làm nhiệm vụ và trả tiếp tế mỗi mùa. Nhóm chiến tranh/khủng hoảng đặt trước một ảnh hưởng 25% vào Hạ–Thu mỗi năm. Đây là kịch bản kiểm tra sức chịu đựng, không đại diện xác suất rút tấu thực.

| Cấp | Tình huống | Ván thiếu trước → sau /100 | Trung vị mùa thiếu đầu tiên sau, chỉ tính ván đã thiếu |
|---:|---|---:|---:|
| 1 | Bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 1 | Không bảo dưỡng | 100 → 100 | 14 |
| 1 | Chiến tranh, có bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 1 | Chiến tranh + khủng hoảng, có bảo dưỡng | 0 → 100 | 46 |
| 3 | Bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 3 | Không bảo dưỡng | 100 → 100 | 17 |
| 3 | Chiến tranh, có bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 3 | Chiến tranh + khủng hoảng, có bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 5 | Bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 5 | Không bảo dưỡng | 100 → 100 | 20 |
| 5 | Chiến tranh, có bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |
| 5 | Chiến tranh + khủng hoảng, có bảo dưỡng | 0 → 0 | Không thiếu trong thời gian quan sát |

## Đánh giá

- Áp lực lương tăng rõ nhất khi bỏ bảo dưỡng: nhiều mùa thiếu hơn và số lần phải mua lương tăng mạnh. Người quản lý tốt vẫn thường giữ được dự trữ; bảng mới không buộc mọi ván phải hết lương.
- Bỏ chi dân sinh giúp ngân khố dễ thở hơn, nên thời gian sống không nhất thiết giảm. Dùng thời gian trị vì đơn lẻ để kết luận độ khó lương thực sẽ sai; nhiều ván kết thúc bởi chính trị hoặc chiến tranh trước khi kho cạn.
- Nâng cấp và bảo dưỡng vẫn bảo vệ người chơi. Trong mô hình dân số cố định, cấp 3/5 có bảo dưỡng chịu được các tình huống kiểm tra kể cả chiến tranh/khủng hoảng; không được suy ra rằng người chơi thật sẽ không thiếu, vì tăng trưởng dân số và các khoản chi khác đã được loại khỏi mô hình này.
- Không tăng thêm thông số sau khi xem kết quả để ép tỷ lệ thiếu hoặc số năm sống. 30 seed/chính sách là mẫu khảo sát ban đầu; cần chơi thử người thật trước khi kết luận mọi chiến lược đã cân bằng.

## Kiểm chứng

- 1.111 kiểm tra VM/UI đạt; phân tích tĩnh sạch.
- 14 kiểm tra Chrome đạt, gồm lưu/tải áp lực và khẩu phần trả trước, replay hai tab, công trình và quyết toán chuỗi.
- Build Web release thành công ở thư mục tạm, giữ các file build/web đã có trong workspace.
- Tất cả 240 ván mô phỏng không có lệnh bị từ chối.

Số liệu: [trước](before.jsonl), [sau](after.jsonl), [mô hình dự trữ](reserve-scenarios.jsonl), [metadata và hash nguồn](metadata.json). Cách chạy: [tài liệu 0.28](../../docs/balance-food-028.md). Các lượt thử trước khi chốt đồng bộ nằm trong thư mục pilot, không dùng làm số liệu chính thức.
