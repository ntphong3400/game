# Danh sách toàn bộ tấu chương — Vạn Tuế

- **Luật:** `mvp-0.19.0` · nội dung 18 · chế độ **theo mùa**.
- **Phạm vi:** 450 tấu chương, 1329 lựa chọn, 18 nhóm.
- **Nguồn:** catalog đang chạy trong `lib/game/data/content.dart`, `expanded_events.dart`, `event_stories.dart`; quy đổi bằng chính `eventForState()` / `seasonalPetitionChoice()` mà UI và engine đang dùng.
- **Xuất lại:** `dart run tools/export_petitions.dart`. Công cụ không đọc hay sửa bản lưu người chơi.

## Cách đọc

- Cân bằng 0.18.0: đầu tư nhận kết quả sau 2 mùa; kiểm toán/truy dấu sau 1 mùa. Thưởng kinh tế dùng mức riêng theo phương án; thất bại mất vốn/phí, không trừ thêm tiền, các phạt lòng dân/uy quyền/ổn định liên quan tối đa −1. Kiểm toán độc lập phí 20, thu hồi 60–90 nếu thành công. Hòa đàm có khoản thu phụ giữ quy tắc cũ; khoản vay giữ nguyên tiền và nợ. Phương án nhận tiền ngay còn lại tăng khoảng 35%, làm tròn bội 5. Kết quả đã chốt trong bản lưu giữ thời hạn và mức cũ.
- **Giao người xử lý (0.16.0):** 148 lựa chọn có rủi ro được chọn triều thần hoặc người trưởng thành đã nhập hậu cung và đang rảnh. Mặc định **không giao ai**: 143 lựa chọn có tỷ lệ nền 40–55% (giảm 25 điểm % so với tỷ lệ biên soạn); 5 công việc riêng có nền 35%. Chọn người cộng 5–35 điểm %, không tốn thêm hành động hoặc phí ngoài phương án. Tỷ lệ chính xác được hiển thị trước khi xác nhận; người được giao bận đến hạn, mệt công vụ +12 khi nhận việc.
- Người được giao, tỷ lệ và nhánh thành công/thất bại được lưu lúc xác nhận. Người đó rời chức, qua đời hoặc không còn đủ điều kiện trước hạn thì công việc gián đoạn và chịu hậu quả nhánh thất bại; kinh phí không hoàn lại. Bản lưu cũ đã có kết quả chờ giữ cách xử lý và tỷ lệ đã ghi.
- Chi phí, yêu cầu hành động và thưởng/phạt bên dưới là **giá trị thực tế theo mùa**, đã áp dụng quy đổi, làm tròn và phụ phí; không lấy các con số gốc theo tuần làm giá hiện hành.
- Catalog là toàn bộ nội dung có thể xuất hiện; mỗi mùa bốc mục tiêu 4–6 tấu chương mới, có điều kiện, cooldown và ưu tiên tránh lặp. Việc khẩn theo tình hình và tấu chương cũ còn hạn giữ cơ chế riêng.
- “Tác động ngay” bao gồm cả lợi ích và đánh đổi; dấu +/− là thay đổi chỉ số. Chi phí trả trước được ghi riêng, không cộng nó vào phần thưởng. Doanh thu chưa phải lợi nhuận.
- Mọi lựa chọn theo mùa tốn ít nhất 1 hành động. Engine kiểm tra ngân khố ≥ chi phí, lương thực ≥ lượng phải xuất và hành động còn lại ≥ yêu cầu. Khoản mất tiền trong hiệu ứng là tổn thất riêng: nếu kho không đủ, phần thiếu trở thành nợ; mất thóc trong hiệu ứng không phải điều kiện phải có đủ thóc để chọn.
- Lựa chọn cuối là phương án mặc định khi quá hạn: engine áp dụng hiệu ứng và kết quả chờ, không trừ phí/hành động của việc ngự phê. Bỏ quá hạn tấu chương nhóm Khủng hoảng/Âm mưu còn mất thêm 4 uy quyền và 3 ổn định mỗi việc, tối đa 2 việc/mùa, ngoài hậu quả riêng.
- Mùa đạt hạn vẫn được xử lý công việc chờ khi khép mùa. “Cuối mùa chọn” = chốt mùa hiện tại; “cuối mùa kế tiếp” = chốt lượt sau; “cùng mùa năm sau” = chốt sau 4 mùa.
- Tỷ lệ ở mỗi lựa chọn là mức khi không giao ai; người được giao giúp tăng tỷ lệ theo chuyên môn và đánh giá công vụ. Các kết quả chờ 100% không có nhánh thất bại vẫn giữ nguyên. Nhánh kết quả được bốc/lưu lúc xác nhận; tải lại không bốc lại.
- Các con số là thay đổi trước giới hạn: phần lớn chỉ số 0–100, lương thực 0–200; giá trị nhận thực tế có thể bị giới hạn. Kết quả dưới đây không bao gồm thu chi thường lệ, hao mòn, sức khỏe cuối mùa và sự kiện khác.
- Nội dung có `{candidate}` sẽ thay bằng ứng viên cụ thể khi tấu chương được trình. Những yêu cầu phụ thuộc nhân vật được ghi theo điều kiện, không tự gán một người giả định.
- Ngự phê tăng khối lượng làm việc bằng số hành động đã dùng; tấu chương ngoài nhóm Cung đình/Hậu cung/Sức khỏe được tính là xử lý việc nước. Các chỉ số sức khỏe, ổn định, uy quyền, lòng dân hoặc quân lực về 0 có thể kết thúc lượt ngay.

## Mục lục nhóm

| Nhóm | Tấu chương | Lựa chọn |
|---|---:|---:|
| [Dân sinh](#group-1) | 31 | 90 |
| [Ngân khố](#group-2) | 32 | 93 |
| [Triều chính](#group-3) | 32 | 96 |
| [Quân sự](#group-4) | 34 | 98 |
| [Cung đình](#group-5) | 4 | 8 |
| [Thiên tai](#group-6) | 26 | 78 |
| [Khủng hoảng](#group-7) | 15 | 45 |
| [Sức khỏe](#group-8) | 30 | 88 |
| [Ngoại giao](#group-9) | 30 | 88 |
| [Hậu cung](#group-10) | 31 | 90 |
| [Âm mưu](#group-11) | 8 | 24 |
| [Thương mại](#group-12) | 27 | 81 |
| [Nông nghiệp](#group-13) | 24 | 72 |
| [Công trình](#group-14) | 27 | 81 |
| [Pháp luật](#group-15) | 24 | 72 |
| [Phe phái](#group-16) | 24 | 72 |
| [An ninh](#group-17) | 24 | 72 |
| [Văn hóa](#group-18) | 27 | 81 |

## Chỉ mục tất cả tấu chương

| STT | Mã | Tên tấu chương | Nhóm | Lựa chọn |
|---:|---|---|---|---:|
| 1 | `levee_warning` | [Vết nứt bên dòng Đại Hà](#event-levee_warning) | Dân sinh | 3 |
| 2 | `grain_merchants` | [Những xe thóc ngoài cửa thành](#event-grain_merchants) | Ngân khố | 2 |
| 3 | `village_school` | [Ngôi trường dưới mái đình](#event-village_school) | Dân sinh | 2 |
| 4 | `tax_abuse` | [Tiếng kêu oan ở cổng phủ](#event-tax_abuse) | Triều chính | 3 |
| 5 | `border_riders` | [Khói lửa ngoài biên ải](#event-border_riders) | Quân sự | 3 |
| 6 | `noble_feast` | [Thiệp mời từ phủ Quốc công](#event-noble_feast) | Cung đình | 2 |
| 7 | `rain_forecast` | [Mưa dồn trên thượng nguồn](#event-rain_forecast) | Thiên tai | 3 |
| 8 | `flood` | [Nước tràn qua bờ ruộng](#event-flood) | Khủng hoảng | 3 |
| 9 | `hunger` | [Nồi cháo trước sân đình](#event-hunger) | Khủng hoảng | 3 |
| 10 | `court_rumor` | [Lời đồn sau rèm châu](#event-court_rumor) | Triều chính | 3 |
| 11 | `physician_warning` | [Lời can của ngự y](#event-physician_warning) | Sức khỏe | 3 |
| 12 | `silk_route` | [Đoàn buôn từ phương Nam](#event-silk_route) | Ngoại giao | 3 |
| 13 | `army_pay` | [Lính gác chưa nhận lương](#event-army_pay) | Quân sự | 2 |
| 14 | `palace_poetry` | [Một đêm thơ ở Ngự uyển](#event-palace_poetry) | Cung đình | 2 |
| 15 | `drought` | [Đất nứt giữa mùa hạ](#event-drought) | Thiên tai | 3 |
| 16 | `winter_fuel` | [Gió rét qua miền Bắc](#event-winter_fuel) | Dân sinh | 3 |
| 17 | `local_epidemic` | [Dịch sốt ở bến sông](#event-local_epidemic) | Dân sinh | 3 |
| 18 | `examination` | [Khoa thi mùa xuân](#event-examination) | Triều chính | 3 |
| 19 | `corrupt_gift` | [Hộp ngọc không tên](#event-corrupt_gift) | Ngân khố | 2 |
| 20 | `general_merit` | [Chiến công nơi cửa ải](#event-general_merit) | Quân sự | 2 |
| 21 | `royal_wedding` | [Lời đề nghị kết thân](#event-royal_wedding) | Hậu cung | 2 |
| 22 | `harem_rivalry` | [Hai chén trà lạnh](#event-harem_rivalry) | Hậu cung | 3 |
| 23 | `queen_charity` | [Lời thỉnh cầu từ nội cung](#event-queen_charity) | Hậu cung | 2 |
| 24 | `foreign_tribute` | [Lễ vật từ nước láng giềng](#event-foreign_tribute) | Ngoại giao | 2 |
| 25 | `war_supplies` | [Đoàn xe tiếp tế bị chặn](#event-war_supplies) | Quân sự | 3 |
| 26 | `peace_offer` | [Một lá thư cầu hòa](#event-peace_offer) | Ngoại giao | 2 |
| 27 | `treasury_review` | [Những trang sổ không khớp](#event-treasury_review) | Ngân khố | 2 |
| 28 | `festival` | [Đèn hoa trong kinh thành](#event-festival) | Dân sinh | 2 |
| 29 | `bandits` | [Đường núi không còn yên](#event-bandits) | Quân sự | 3 |
| 30 | `land_dispute` | [Một thửa ruộng, hai tờ khế](#event-land_dispute) | Triều chính | 3 |
| 31 | `palace_repairs` | [Mái điện qua một mùa mưa](#event-palace_repairs) | Cung đình | 2 |
| 32 | `hunting_invite` | [Cuộc săn đầu mùa](#event-hunting_invite) | Cung đình | 2 |
| 33 | `wine_gift` | [Bình rượu quý phương xa](#event-wine_gift) | Sức khỏe | 2 |
| 34 | `sleepless` | [Ngọn đèn chưa tắt](#event-sleepless) | Sức khỏe | 2 |
| 35 | `retired_adviser` | [Lời khuyên của người cũ](#event-retired_adviser) | Triều chính | 3 |
| 36 | `military_drill` | [Tiếng trống thao trường](#event-military_drill) | Quân sự | 2 |
| 37 | `refugees` | [Những người tới cửa Nam](#event-refugees) | Dân sinh | 3 |
| 38 | `craftsmen` | [Lò rèn mới của kinh thành](#event-craftsmen) | Quân sự | 2 |
| 39 | `low_treasury` | [Hộ bộ xin cắt chi](#event-low_treasury) | Ngân khố | 3 |
| 40 | `prosperity` | [Một mùa chợ đông](#event-prosperity) | Ngân khố | 3 |
| 41 | `petition_tax` | [Tấu xin giảm sưu](#event-petition_tax) | Dân sinh | 2 |
| 42 | `plot_warning` | [Dấu chân ngoài điện vắng](#event-plot_warning) | Âm mưu | 3 |
| 43 | `rebellion_warning` | [Tiếng trống từ huyện xa](#event-rebellion_warning) | Khủng hoảng | 3 |
| 44 | `succession_rumor` | [Lời bàn về ngai vàng](#event-succession_rumor) | Âm mưu | 3 |
| 45 | `consort_recommendation` | [Người mới trước cửa cung](#event-consort_recommendation) | Hậu cung | 2 |
| 46 | `community_01` | [Giếng làng bị nhiễm bẩn](#event-community_01) | Dân sinh | 3 |
| 47 | `community_02` | [Đò ngang thu phí lạ](#event-community_02) | Dân sinh | 3 |
| 48 | `community_03` | [Xóm chài mất chỗ neo](#event-community_03) | Dân sinh | 3 |
| 49 | `community_04` | [Nhà cháy trong ngõ hẹp](#event-community_04) | Dân sinh | 3 |
| 50 | `community_05` | [Sổ hộ khẩu bỏ sót](#event-community_05) | Dân sinh | 3 |
| 51 | `community_06` | [Lò bánh nuôi người nghèo](#event-community_06) | Dân sinh | 3 |
| 52 | `community_07` | [Trẻ mồ côi ở trạm dịch](#event-community_07) | Dân sinh | 3 |
| 53 | `community_08` | [Hai làng chung nghĩa địa](#event-community_08) | Dân sinh | 3 |
| 54 | `community_09` | [Nhà trọ cho dân phu](#event-community_09) | Dân sinh | 3 |
| 55 | `community_10` | [Chợ phiên mất mái che](#event-community_10) | Dân sinh | 3 |
| 56 | `community_11` | [Tiếng chuông xin cứu](#event-community_11) | Dân sinh | 3 |
| 57 | `community_12` | [Người què xin nghề mới](#event-community_12) | Dân sinh | 3 |
| 58 | `community_13` | [Người già qua mùa lạnh](#event-community_13) | Dân sinh | 3 |
| 59 | `community_14` | [Tấm biển cấm gánh hàng](#event-community_14) | Dân sinh | 3 |
| 60 | `community_15` | [Cầu nhỏ tới lớp học](#event-community_15) | Dân sinh | 3 |
| 61 | `community_16` | [Đám cưới không đủ lễ](#event-community_16) | Dân sinh | 3 |
| 62 | `community_17` | [Người kéo xe bị bắt oan](#event-community_17) | Dân sinh | 3 |
| 63 | `community_18` | [Bếp chung ngoài thành](#event-community_18) | Dân sinh | 3 |
| 64 | `community_19` | [Đàn bò phá vườn chung](#event-community_19) | Dân sinh | 3 |
| 65 | `community_20` | [Cánh cổng đóng quá sớm](#event-community_20) | Dân sinh | 3 |
| 66 | `community_21` | [Quán nước bên đường quan](#event-community_21) | Dân sinh | 3 |
| 67 | `community_22` | [Người gánh nước đình công](#event-community_22) | Dân sinh | 3 |
| 68 | `community_23` | [Tên người chết trong sổ thu](#event-community_23) | Dân sinh | 3 |
| 69 | `community_24` | [Xưởng may áo mùa đông](#event-community_24) | Dân sinh | 3 |
| 70 | `community_25` | [Tấm chiếu trước cổng phủ](#event-community_25) | Khủng hoảng | 3 |
| 71 | `community_26` | [Người khiêng cày tới điện](#event-community_26) | Khủng hoảng | 3 |
| 72 | `community_27` | [Bếp nguội trong xóm thợ](#event-community_27) | Khủng hoảng | 3 |
| 73 | `finance_01` | [Khoản sưu trên ruộng cát](#event-finance_01) | Ngân khố | 3 |
| 74 | `finance_02` | [Dấu mực trên sổ kép](#event-finance_02) | Ngân khố | 3 |
| 75 | `finance_03` | [Đề nghị góp vốn xưởng giấy](#event-finance_03) | Ngân khố | 3 |
| 76 | `finance_04` | [Thuế người chạy chợ](#event-finance_04) | Ngân khố | 3 |
| 77 | `finance_05` | [Bao bạc thiếu niêm phong](#event-finance_05) | Ngân khố | 3 |
| 78 | `finance_06` | [Lò gốm xin đơn hàng](#event-finance_06) | Ngân khố | 3 |
| 79 | `finance_07` | [Nợ sưu của lính tử trận](#event-finance_07) | Ngân khố | 3 |
| 80 | `finance_08` | [Sáp niêm kho bị thay](#event-finance_08) | Ngân khố | 3 |
| 81 | `finance_09` | [Xưởng nhuộm muốn đổi kỹ thuật](#event-finance_09) | Ngân khố | 3 |
| 82 | `finance_10` | [Thuế đàn ong trên đồi](#event-finance_10) | Ngân khố | 3 |
| 83 | `finance_11` | [Tiền sửa đình chưa tới làng](#event-finance_11) | Ngân khố | 3 |
| 84 | `finance_12` | [Mỏ đá gửi bản tính lãi](#event-finance_12) | Ngân khố | 3 |
| 85 | `finance_13` | [Phí qua cầu tăng đột ngột](#event-finance_13) | Ngân khố | 3 |
| 86 | `finance_14` | [Phiếu lĩnh lương trùng tên](#event-finance_14) | Ngân khố | 3 |
| 87 | `finance_15` | [Kho chứa muối liên doanh](#event-finance_15) | Ngân khố | 3 |
| 88 | `finance_16` | [Lệ phí chôn cất mới](#event-finance_16) | Ngân khố | 3 |
| 89 | `finance_17` | [Đồng cân hụt trong kho bạc](#event-finance_17) | Ngân khố | 3 |
| 90 | `finance_18` | [Thợ đúc xin thử khuôn mới](#event-finance_18) | Ngân khố | 3 |
| 91 | `finance_19` | [Phí đổi giấy thông hành](#event-finance_19) | Ngân khố | 3 |
| 92 | `finance_20` | [Khoản chi cho trạm ma](#event-finance_20) | Ngân khố | 3 |
| 93 | `finance_21` | [Nghề làm nến thiếu sáp](#event-finance_21) | Ngân khố | 3 |
| 94 | `finance_22` | [Thuế thuyền nằm bờ](#event-finance_22) | Ngân khố | 3 |
| 95 | `finance_23` | [Bản kê quân trang bị sửa](#event-finance_23) | Ngân khố | 3 |
| 96 | `finance_24` | [Đề nghị chung vốn ép dầu](#event-finance_24) | Ngân khố | 3 |
| 97 | `finance_25` | [Gia đình quan nhỏ thiếu lương](#event-finance_25) | Ngân khố | 3 |
| 98 | `finance_26` | [Hộp tiền trạm thuế bị tráo](#event-finance_26) | Ngân khố | 3 |
| 99 | `finance_27` | [Lời mời mua lại công trái](#event-finance_27) | Ngân khố | 3 |
| 100 | `commerce_01` | [Bến vải tìm đường mới](#event-commerce_01) | Thương mại | 3 |
| 101 | `commerce_02` | [Con dấu độc quyền bán dầu](#event-commerce_02) | Thương mại | 3 |
| 102 | `commerce_03` | [Thuyền gạo tới cửa biển](#event-commerce_03) | Thương mại | 3 |
| 103 | `commerce_04` | [Phiên chợ trên núi](#event-commerce_04) | Thương mại | 3 |
| 104 | `commerce_05` | [Giá đèn tăng sau lệnh cấm](#event-commerce_05) | Thương mại | 3 |
| 105 | `commerce_06` | [Khoai khô đổi gạo mới](#event-commerce_06) | Thương mại | 3 |
| 106 | `commerce_07` | [Hàng gốm qua ba trạm](#event-commerce_07) | Thương mại | 3 |
| 107 | `commerce_08` | [Chủ kho ép giá người bán](#event-commerce_08) | Thương mại | 3 |
| 108 | `commerce_09` | [Cá khô xin vào kho lương](#event-commerce_09) | Thương mại | 3 |
| 109 | `commerce_10` | [Thuyền hàng thiếu bản đồ luồng](#event-commerce_10) | Thương mại | 3 |
| 110 | `commerce_11` | [Đấu thầu sạp chợ có người chặn](#event-commerce_11) | Thương mại | 3 |
| 111 | `commerce_12` | [Hạt kê từ vùng cao](#event-commerce_12) | Thương mại | 3 |
| 112 | `commerce_13` | [Xe muối muốn vượt đèo](#event-commerce_13) | Thương mại | 3 |
| 113 | `commerce_14` | [Tem chợ giả tràn lan](#event-commerce_14) | Thương mại | 3 |
| 114 | `commerce_15` | [Đậu dự trữ sắp hết vụ](#event-commerce_15) | Thương mại | 3 |
| 115 | `commerce_16` | [Đường buôn dọc bờ hồ](#event-commerce_16) | Thương mại | 3 |
| 116 | `commerce_17` | [Người giữ chợ thiên vị](#event-commerce_17) | Thương mại | 3 |
| 117 | `commerce_18` | [Thóc giống đổi hàng thủ công](#event-commerce_18) | Thương mại | 3 |
| 118 | `commerce_19` | [Sợi tơ tìm khách phương xa](#event-commerce_19) | Thương mại | 3 |
| 119 | `commerce_20` | [Cân chợ cùng nghiêng một phía](#event-commerce_20) | Thương mại | 3 |
| 120 | `commerce_21` | [Lương khô của đoàn lữ hành](#event-commerce_21) | Thương mại | 3 |
| 121 | `commerce_22` | [Mộc bản rao hàng liên phủ](#event-commerce_22) | Thương mại | 3 |
| 122 | `commerce_23` | [Đường chợ bị trạm tư chắn](#event-commerce_23) | Thương mại | 3 |
| 123 | `commerce_24` | [Gạo đóng chum của thương hộ](#event-commerce_24) | Thương mại | 3 |
| 124 | `commerce_25` | [Đoàn thương nhân qua biên giới](#event-commerce_25) | Thương mại | 3 |
| 125 | `commerce_26` | [Quyền cung ứng cho hoàng thành](#event-commerce_26) | Thương mại | 3 |
| 126 | `commerce_27` | [Những bao gạo giữ giá](#event-commerce_27) | Thương mại | 3 |
| 127 | `agriculture_01` | [Giống lúa chín sớm](#event-agriculture_01) | Nông nghiệp | 3 |
| 128 | `agriculture_02` | [Thóc ăn hay thóc giống](#event-agriculture_02) | Nông nghiệp | 3 |
| 129 | `agriculture_03` | [Mương dẫn nước bỏ hoang](#event-agriculture_03) | Nông nghiệp | 3 |
| 130 | `agriculture_04` | [Đậu xanh trên đất bạc](#event-agriculture_04) | Nông nghiệp | 3 |
| 131 | `agriculture_05` | [Người cày không còn trâu](#event-agriculture_05) | Nông nghiệp | 3 |
| 132 | `agriculture_06` | [Đập gỗ giữa hai xã](#event-agriculture_06) | Nông nghiệp | 3 |
| 133 | `agriculture_07` | [Ruộng trũng nuôi cá](#event-agriculture_07) | Nông nghiệp | 3 |
| 134 | `agriculture_08` | [Kho giống mở sai lúc](#event-agriculture_08) | Nông nghiệp | 3 |
| 135 | `agriculture_09` | [Cửa nước bị nhà giàu chặn](#event-agriculture_09) | Nông nghiệp | 3 |
| 136 | `agriculture_10` | [Vườn dâu thay bãi cỏ](#event-agriculture_10) | Nông nghiệp | 3 |
| 137 | `agriculture_11` | [Lúa non bị đem cầm](#event-agriculture_11) | Nông nghiệp | 3 |
| 138 | `agriculture_12` | [Cọc đo nước thiếu dấu](#event-agriculture_12) | Nông nghiệp | 3 |
| 139 | `agriculture_13` | [Nghề ủ phân từ rơm](#event-agriculture_13) | Nông nghiệp | 3 |
| 140 | `agriculture_14` | [Người thuê ruộng mất phần](#event-agriculture_14) | Nông nghiệp | 3 |
| 141 | `agriculture_15` | [Nước mặn qua cửa cống](#event-agriculture_15) | Nông nghiệp | 3 |
| 142 | `agriculture_16` | [Ruộng bỏ theo người tản cư](#event-agriculture_16) | Nông nghiệp | 3 |
| 143 | `agriculture_17` | [Thóc dành cho đàn giống](#event-agriculture_17) | Nông nghiệp | 3 |
| 144 | `agriculture_18` | [Guồng nước gãy trục](#event-agriculture_18) | Nông nghiệp | 3 |
| 145 | `agriculture_19` | [Cây kê chịu hạn](#event-agriculture_19) | Nông nghiệp | 3 |
| 146 | `agriculture_20` | [Lương thợ gặt bị giữ](#event-agriculture_20) | Nông nghiệp | 3 |
| 147 | `agriculture_21` | [Bờ ruộng bị tràn lối](#event-agriculture_21) | Nông nghiệp | 3 |
| 148 | `agriculture_22` | [Vụ gieo đầu xuân muộn](#event-agriculture_22) | Nông nghiệp | 3 |
| 149 | `agriculture_23` | [Hạt giống qua mùa rét](#event-agriculture_23) | Nông nghiệp | 3 |
| 150 | `agriculture_24` | [Nước ruộng dâng qua bờ](#event-agriculture_24) | Nông nghiệp | 3 |
| 151 | `agriculture_25` | [Cháo loãng bên kho giống](#event-agriculture_25) | Khủng hoảng | 3 |
| 152 | `agriculture_26` | [Người bán cày lấy gạo](#event-agriculture_26) | Khủng hoảng | 3 |
| 153 | `agriculture_27` | [Làng bỏ bữa liên tiếp](#event-agriculture_27) | Khủng hoảng | 3 |
| 154 | `engineering_01` | [Kè đá trôi chân móng](#event-engineering_01) | Công trình | 3 |
| 155 | `engineering_02` | [Cầu đường tới doanh trại](#event-engineering_02) | Công trình | 3 |
| 156 | `engineering_03` | [Gỗ công trình thiếu dấu](#event-engineering_03) | Công trình | 3 |
| 157 | `engineering_04` | [Bờ thành nghiêng xuống hồ](#event-engineering_04) | Công trình | 3 |
| 158 | `engineering_05` | [Đường vận lương đầy ổ lún](#event-engineering_05) | Công trình | 3 |
| 159 | `engineering_06` | [Gạch nung vỡ hàng loạt](#event-engineering_06) | Công trình | 3 |
| 160 | `engineering_07` | [Bậc xuống bến sông sụt](#event-engineering_07) | Công trình | 3 |
| 161 | `engineering_08` | [Giếng trong trạm quân dịch](#event-engineering_08) | Công trình | 3 |
| 162 | `engineering_09` | [Dụng cụ khai mương bị kê cao](#event-engineering_09) | Công trình | 3 |
| 163 | `engineering_10` | [Cống ngầm đầy rễ cây](#event-engineering_10) | Công trình | 3 |
| 164 | `engineering_11` | [Bến tập kết quân trang](#event-engineering_11) | Công trình | 3 |
| 165 | `engineering_12` | [Dây kéo đá bị tráo](#event-engineering_12) | Công trình | 3 |
| 166 | `engineering_13` | [Đê phụ chắn nước ngược](#event-engineering_13) | Công trình | 3 |
| 167 | `engineering_14` | [Lối xuyên đồi sạt mép](#event-engineering_14) | Công trình | 3 |
| 168 | `engineering_15` | [Đá tốt biến thành đá vụn](#event-engineering_15) | Công trình | 3 |
| 169 | `engineering_16` | [Bờ hồ trong xóm lún](#event-engineering_16) | Công trình | 3 |
| 170 | `engineering_17` | [Trạm thay ngựa thiếu máng nước](#event-engineering_17) | Công trình | 3 |
| 171 | `engineering_18` | [Số ngày công bị ghi khống](#event-engineering_18) | Công trình | 3 |
| 172 | `engineering_19` | [Đường thoát nước dưới chợ](#event-engineering_19) | Công trình | 3 |
| 173 | `engineering_20` | [Cầu tạm qua suối quân lương](#event-engineering_20) | Công trình | 3 |
| 174 | `engineering_21` | [Vật liệu dư không vào sổ](#event-engineering_21) | Công trình | 3 |
| 175 | `engineering_22` | [Mái đê bị khoét làm lối](#event-engineering_22) | Công trình | 3 |
| 176 | `engineering_23` | [Đường vào kho cháy đèn](#event-engineering_23) | Công trình | 3 |
| 177 | `engineering_24` | [Bản vẽ móng kho bị đổi](#event-engineering_24) | Công trình | 3 |
| 178 | `engineering_25` | [Khe đê rỉ nước đục](#event-engineering_25) | Công trình | 3 |
| 179 | `engineering_26` | [Cầu cho xe cứu thương](#event-engineering_26) | Công trình | 3 |
| 180 | `engineering_27` | [Quỹ bảo trì biến mất](#event-engineering_27) | Công trình | 3 |
| 181 | `military_01` | [Tân binh thiếu giày](#event-military_01) | Quân sự | 3 |
| 182 | `military_02` | [Trận địa thử chưa dựng](#event-military_02) | Quân sự | 3 |
| 183 | `military_03` | [Đội tuần tra thiếu bữa](#event-military_03) | Quân sự | 3 |
| 184 | `military_04` | [Dây cung trong kho mục](#event-military_04) | Quân sự | 3 |
| 185 | `military_05` | [Đường áp sát cửa ải](#event-military_05) | Quân sự | 3 |
| 186 | `military_06` | [Kho gạo quân đóng xa](#event-military_06) | Quân sự | 3 |
| 187 | `military_07` | [Lính gác ngủ ngoài mái](#event-military_07) | Quân sự | 3 |
| 188 | `military_08` | [Kỹ thuật báo hiệu mới](#event-military_08) | Quân sự | 3 |
| 189 | `military_09` | [Đàn ngựa thiếu thức ăn](#event-military_09) | Quân sự | 3 |
| 190 | `military_10` | [Quân y thiếu vải băng](#event-military_10) | Quân sự | 3 |
| 191 | `military_11` | [Đội hình giữ cầu hẹp](#event-military_11) | Quân sự | 3 |
| 192 | `military_12` | [Lính vận lương mắc đường](#event-military_12) | Quân sự | 3 |
| 193 | `military_13` | [Mũ sắt sai kích cỡ](#event-military_13) | Quân sự | 3 |
| 194 | `military_14` | [Trinh sát vùng rừng rậm](#event-military_14) | Quân sự | 3 |
| 195 | `military_15` | [Bếp quân dập lửa sớm](#event-military_15) | Quân sự | 3 |
| 196 | `military_16` | [Lính mới bị giữ phụ cấp](#event-military_16) | Quân sự | 3 |
| 197 | `military_17` | [Bãi tập phòng thủ ven sông](#event-military_17) | Quân sự | 3 |
| 198 | `military_18` | [Kho đồn lẫn thóc mốc](#event-military_18) | Quân sự | 3 |
| 199 | `military_19` | [Xe kéo pháo hỏng trục](#event-military_19) | Quân sự | 3 |
| 200 | `military_20` | [Đội cứu viện đi đường đêm](#event-military_20) | Quân sự | 3 |
| 201 | `military_21` | [Lương quân tới sai đơn vị](#event-military_21) | Quân sự | 3 |
| 202 | `military_22` | [Những hàng quân thưa dần](#event-military_22) | Quân sự | 3 |
| 203 | `military_23` | [Tin trinh sát trước trận lớn](#event-military_23) | Quân sự | 3 |
| 204 | `military_24` | [Lương thực cho quân bị vây](#event-military_24) | Quân sự | 3 |
| 205 | `military_25` | [Quân dự bị xin tập lại](#event-military_25) | Quân sự | 3 |
| 206 | `military_26` | [Lối rút khỏi thung lũng](#event-military_26) | Quân sự | 3 |
| 207 | `military_27` | [Suất ăn của quân tái ngũ](#event-military_27) | Quân sự | 3 |
| 208 | `diplomacy_01` | [Sứ đoàn bị giữ ở cửa ải](#event-diplomacy_01) | Ngoại giao | 3 |
| 209 | `diplomacy_02` | [Bến chung bên sông giới](#event-diplomacy_02) | Ngoại giao | 3 |
| 210 | `diplomacy_03` | [Mốc đá bị dời trong đêm](#event-diplomacy_03) | Ngoại giao | 3 |
| 211 | `diplomacy_04` | [Lời đề nghị ngừng bắn ngắn](#event-diplomacy_04) | Ngoại giao | 3 |
| 212 | `diplomacy_05` | [Đường buôn qua cao nguyên](#event-diplomacy_05) | Ngoại giao | 3 |
| 213 | `diplomacy_06` | [Ngư dân vượt đường nước](#event-diplomacy_06) | Ngoại giao | 3 |
| 214 | `diplomacy_07` | [Quà ngoại giao bị hiểu lầm](#event-diplomacy_07) | Ngoại giao | 3 |
| 215 | `diplomacy_08` | [Xưởng nhuộm của khách ngoại](#event-diplomacy_08) | Ngoại giao | 3 |
| 216 | `diplomacy_09` | [Đoàn hộ tống đi lạc](#event-diplomacy_09) | Ngoại giao | 3 |
| 217 | `diplomacy_10` | [Tin đổi tù binh](#event-diplomacy_10) | Ngoại giao | 3 |
| 218 | `diplomacy_11` | [Hội chợ mùa lạnh](#event-diplomacy_11) | Ngoại giao | 3 |
| 219 | `diplomacy_12` | [Khách tị nạn bên cột mốc](#event-diplomacy_12) | Ngoại giao | 3 |
| 220 | `diplomacy_13` | [Tranh thứ bậc trong quốc thư](#event-diplomacy_13) | Ngoại giao | 3 |
| 221 | `diplomacy_14` | [Kho chuyển hàng đường biển](#event-diplomacy_14) | Ngoại giao | 3 |
| 222 | `diplomacy_15` | [Kẻ truy đuổi qua biên](#event-diplomacy_15) | Ngoại giao | 3 |
| 223 | `diplomacy_16` | [Sứ thần mắc nợ nhà trọ](#event-diplomacy_16) | Ngoại giao | 3 |
| 224 | `diplomacy_17` | [Giống vật nuôi trao đổi](#event-diplomacy_17) | Ngoại giao | 3 |
| 225 | `diplomacy_18` | [Đền cổ nằm giữa hai nước](#event-diplomacy_18) | Ngoại giao | 3 |
| 226 | `diplomacy_19` | [Đồng minh xin xác nhận lời hứa](#event-diplomacy_19) | Ngoại giao | 3 |
| 227 | `diplomacy_20` | [Trạm đổi tiền cho khách ngoại](#event-diplomacy_20) | Ngoại giao | 3 |
| 228 | `diplomacy_21` | [Công chúa nước bạn quá cảnh](#event-diplomacy_21) | Ngoại giao | 3 |
| 229 | `diplomacy_22` | [Đòi trả tấm bản đồ cũ](#event-diplomacy_22) | Ngoại giao | 3 |
| 230 | `diplomacy_23` | [Hiệp hội thuyền buôn liên quốc](#event-diplomacy_23) | Ngoại giao | 3 |
| 231 | `diplomacy_24` | [Lễ tế trên đỉnh núi giới](#event-diplomacy_24) | Ngoại giao | 3 |
| 232 | `diplomacy_25` | [Tin đồn nước bạn chuẩn bị chiến](#event-diplomacy_25) | Ngoại giao | 3 |
| 233 | `diplomacy_26` | [Thợ đóng tàu muốn hợp tác](#event-diplomacy_26) | Ngoại giao | 3 |
| 234 | `diplomacy_27` | [Bảo đảm cho hành lang cứu trợ](#event-diplomacy_27) | Ngoại giao | 3 |
| 235 | `justice_01` | [Con nhà quyền thế cán người](#event-justice_01) | Pháp luật | 3 |
| 236 | `justice_02` | [Người trộm bánh nuôi con](#event-justice_02) | Pháp luật | 3 |
| 237 | `justice_03` | [Nhân chứng đổi lời khai](#event-justice_03) | Pháp luật | 3 |
| 238 | `justice_04` | [Cọc ruộng bị nhổ](#event-justice_04) | Pháp luật | 3 |
| 239 | `justice_05` | [Kẻ đào ngũ trở về chịu tội](#event-justice_05) | Pháp luật | 3 |
| 240 | `justice_06` | [Ấn huyện trên giấy giả](#event-justice_06) | Pháp luật | 3 |
| 241 | `justice_07` | [Đầy tớ kiện chủ đánh đập](#event-justice_07) | Pháp luật | 3 |
| 242 | `justice_08` | [Đám đông đập kho đầu cơ](#event-justice_08) | Pháp luật | 3 |
| 243 | `justice_09` | [Hai người nhận cùng di chúc](#event-justice_09) | Pháp luật | 3 |
| 244 | `justice_10` | [Quan trạm đánh người đưa thư](#event-justice_10) | Pháp luật | 3 |
| 245 | `justice_11` | [Thợ phá máy để giữ nghề](#event-justice_11) | Pháp luật | 3 |
| 246 | `justice_12` | [Nhà tù báo thiếu một người](#event-justice_12) | Pháp luật | 3 |
| 247 | `justice_13` | [Đường làng bị dựng cổng riêng](#event-justice_13) | Pháp luật | 3 |
| 248 | `justice_14` | [Người đánh chuông báo cháy sai](#event-justice_14) | Pháp luật | 3 |
| 249 | `justice_15` | [Chứng vật biến mất ở nha môn](#event-justice_15) | Pháp luật | 3 |
| 250 | `justice_16` | [Phu trạm kiện bị giữ tiền công](#event-justice_16) | Pháp luật | 3 |
| 251 | `justice_17` | [Tù nhân cứu người coi ngục](#event-justice_17) | Pháp luật | 3 |
| 252 | `justice_18` | [Lời tố cáo giữa hai làng](#event-justice_18) | Pháp luật | 3 |
| 253 | `justice_19` | [Bản án chỉ dành cho người nghèo](#event-justice_19) | Pháp luật | 3 |
| 254 | `justice_20` | [Nông dân đốt sổ nợ](#event-justice_20) | Pháp luật | 3 |
| 255 | `justice_21` | [Thầy thuốc bị tố dùng độc](#event-justice_21) | Pháp luật | 3 |
| 256 | `justice_22` | [Đòi người làm để trừ nợ](#event-justice_22) | Pháp luật | 3 |
| 257 | `justice_23` | [Kẻ trộm nộp lại đồ thất lạc](#event-justice_23) | Pháp luật | 3 |
| 258 | `justice_24` | [Lời khai dưới ép cung](#event-justice_24) | Pháp luật | 3 |
| 259 | `justice_25` | [Dân đội đơn trước cửa thành](#event-justice_25) | Khủng hoảng | 3 |
| 260 | `justice_26` | [Người bị bắt sau cuộc đòi gạo](#event-justice_26) | Khủng hoảng | 3 |
| 261 | `justice_27` | [Quan địa phương giấu đơn dân](#event-justice_27) | Khủng hoảng | 3 |
| 262 | `bureaucracy_01` | [Hai bộ cùng giữ một hồ sơ](#event-bureaucracy_01) | Triều chính | 3 |
| 263 | `bureaucracy_02` | [Lịch trực quan chồng chéo](#event-bureaucracy_02) | Triều chính | 3 |
| 264 | `bureaucracy_03` | [Sổ chi mua đèn tăng gấp bội](#event-bureaucracy_03) | Triều chính | 3 |
| 265 | `bureaucracy_04` | [Chỉ dụ bị sao thành hai bản](#event-bureaucracy_04) | Triều chính | 3 |
| 266 | `bureaucracy_05` | [Ghế ngồi trong buổi chầu](#event-bureaucracy_05) | Triều chính | 3 |
| 267 | `bureaucracy_06` | [Kho giấy hao bất thường](#event-bureaucracy_06) | Triều chính | 3 |
| 268 | `bureaucracy_07` | [Mệnh lệnh đến sau thời hạn](#event-bureaucracy_07) | Triều chính | 3 |
| 269 | `bureaucracy_08` | [Đại thần bất đồng giờ chầu](#event-bureaucracy_08) | Triều chính | 3 |
| 270 | `bureaucracy_09` | [Tiền sửa công đường mất dấu](#event-bureaucracy_09) | Triều chính | 3 |
| 271 | `bureaucracy_10` | [Con dấu đi theo người nghỉ](#event-bureaucracy_10) | Triều chính | 3 |
| 272 | `bureaucracy_11` | [Bản tấu chen nhau trình vua](#event-bureaucracy_11) | Triều chính | 3 |
| 273 | `bureaucracy_12` | [Tên người nhận bổng bị lặp](#event-bureaucracy_12) | Triều chính | 3 |
| 274 | `bureaucracy_13` | [Mẫu biểu mỗi huyện một kiểu](#event-bureaucracy_13) | Triều chính | 3 |
| 275 | `bureaucracy_14` | [Quan mới không được bàn việc](#event-bureaucracy_14) | Triều chính | 3 |
| 276 | `bureaucracy_15` | [Ngựa trạm có tên nhưng không có thật](#event-bureaucracy_15) | Triều chính | 3 |
| 277 | `bureaucracy_16` | [Việc khẩn nằm dưới chồng tấu](#event-bureaucracy_16) | Triều chính | 3 |
| 278 | `bureaucracy_17` | [Quan xin nghỉ cùng một dịp](#event-bureaucracy_17) | Triều chính | 3 |
| 279 | `bureaucracy_18` | [Tiền công sứ bị khai trùng](#event-bureaucracy_18) | Triều chính | 3 |
| 280 | `bureaucracy_19` | [Chức trách bị bỏ trống giữa hai bộ](#event-bureaucracy_19) | Triều chính | 3 |
| 281 | `bureaucracy_20` | [Quan địa phương chống lệnh luân chuyển](#event-bureaucracy_20) | Triều chính | 3 |
| 282 | `bureaucracy_21` | [Vật tư nhập kho thiếu cân](#event-bureaucracy_21) | Triều chính | 3 |
| 283 | `bureaucracy_22` | [Quyền ký thay không rõ ràng](#event-bureaucracy_22) | Triều chính | 3 |
| 284 | `bureaucracy_23` | [Tiếng nói của quan xa kinh](#event-bureaucracy_23) | Triều chính | 3 |
| 285 | `bureaucracy_24` | [Khoản chi lễ nghi không có biên nhận](#event-bureaucracy_24) | Triều chính | 3 |
| 286 | `bureaucracy_25` | [Hồ sơ phải trình lại từ đầu](#event-bureaucracy_25) | Triều chính | 3 |
| 287 | `bureaucracy_26` | [Quan chuyên môn bị gạt ngoài cuộc](#event-bureaucracy_26) | Triều chính | 3 |
| 288 | `bureaucracy_27` | [Tiền thuê người chép sổ tăng vọt](#event-bureaucracy_27) | Triều chính | 3 |
| 289 | `factions_01` | [Văn Võ tranh quyền coi trạm](#event-factions_01) | Phe phái | 3 |
| 290 | `factions_02` | [Họ vua và thế gia tranh đất lễ](#event-factions_02) | Phe phái | 3 |
| 291 | `factions_03` | [Gia phả cũ bị đem bàn tán](#event-factions_03) | Phe phái | 3 |
| 292 | `factions_04` | [Ai được giữ kho vũ khí](#event-factions_04) | Phe phái | 3 |
| 293 | `factions_05` | [Suất học cho con nhà danh giá](#event-factions_05) | Phe phái | 3 |
| 294 | `factions_06` | [Lời thề của người kế vị cũ](#event-factions_06) | Phe phái | 3 |
| 295 | `factions_07` | [Tấu xin giám sát quân lương](#event-factions_07) | Phe phái | 3 |
| 296 | `factions_08` | [Quyền mở đoàn săn mùa thu](#event-factions_08) | Phe phái | 3 |
| 297 | `factions_09` | [Bài ca ca ngợi một thân vương](#event-factions_09) | Phe phái | 3 |
| 298 | `factions_10` | [Tranh người phụ trách cứu hộ](#event-factions_10) | Phe phái | 3 |
| 299 | `factions_11` | [Ghế chủ lễ của hai dòng họ](#event-factions_11) | Phe phái | 3 |
| 300 | `factions_12` | [Lời đồn ngai vàng được vay](#event-factions_12) | Phe phái | 3 |
| 301 | `factions_13` | [Quan Văn phản đối đoàn duyệt binh](#event-factions_13) | Phe phái | 3 |
| 302 | `factions_14` | [Người bảo trợ đòi đặt tên cầu](#event-factions_14) | Phe phái | 3 |
| 303 | `factions_15` | [Một biểu chương xin vua nhường quyền](#event-factions_15) | Phe phái | 3 |
| 304 | `factions_16` | [Quyền bổ nhiệm người giữ biên](#event-factions_16) | Phe phái | 3 |
| 305 | `factions_17` | [Hội đồng họ tộc xin miễn lệ](#event-factions_17) | Phe phái | 3 |
| 306 | `factions_18` | [Kỷ vật vua trước xuất hiện](#event-factions_18) | Phe phái | 3 |
| 307 | `factions_19` | [Hai phe tranh cách đọc quân báo](#event-factions_19) | Phe phái | 3 |
| 308 | `factions_20` | [Quyền dùng bến dành cho triều đình](#event-factions_20) | Phe phái | 3 |
| 309 | `factions_21` | [Dấu hiệu trên thiên tượng](#event-factions_21) | Phe phái | 3 |
| 310 | `factions_22` | [Hai phe cùng tẩy chay nghị chính](#event-factions_22) | Phe phái | 3 |
| 311 | `factions_23` | [Lễ vật chia triều thành hai nhóm](#event-factions_23) | Phe phái | 3 |
| 312 | `factions_24` | [Một phe muốn đứng giữa nhà vua](#event-factions_24) | Phe phái | 3 |
| 313 | `factions_25` | [Chiếu nhường quyền được viết sẵn](#event-factions_25) | Âm mưu | 3 |
| 314 | `factions_26` | [Thân vương mở buổi nhận lời chúc](#event-factions_26) | Âm mưu | 3 |
| 315 | `factions_27` | [Danh sách người ủng hộ đổi ngôi](#event-factions_27) | Âm mưu | 3 |
| 316 | `security_01` | [Thư không ký tên trong bếp](#event-security_01) | An ninh | 3 |
| 317 | `security_02` | [Lính gác bị dụ rời cổng](#event-security_02) | An ninh | 3 |
| 318 | `security_03` | [Quản sự thu tiền qua cửa kín](#event-security_03) | An ninh | 3 |
| 319 | `security_04` | [Chén bạc có dấu mài mới](#event-security_04) | An ninh | 3 |
| 320 | `security_05` | [Thợ khóa báo mất chìa mẫu](#event-security_05) | An ninh | 3 |
| 321 | `security_06` | [Giấy thông hành được bán kín](#event-security_06) | An ninh | 3 |
| 322 | `security_07` | [Người nếm thức ăn vắng mặt](#event-security_07) | An ninh | 3 |
| 323 | `security_08` | [Dây neo thuyền ngự bị cắt](#event-security_08) | An ninh | 3 |
| 324 | `security_09` | [Khách lạ được dẫn qua vườn ngự](#event-security_09) | An ninh | 3 |
| 325 | `security_10` | [Lưỡi dao trong kiện vải](#event-security_10) | An ninh | 3 |
| 326 | `security_11` | [Lịch đi của vua bị lộ](#event-security_11) | An ninh | 3 |
| 327 | `security_12` | [Lính canh bán ca trực](#event-security_12) | An ninh | 3 |
| 328 | `security_13` | [Ấm thuốc có mùi lạ](#event-security_13) | An ninh | 3 |
| 329 | `security_14` | [Mái hiên trên lối vua đi bị lỏng](#event-security_14) | An ninh | 3 |
| 330 | `security_15` | [Người bán quyền gặp riêng](#event-security_15) | An ninh | 3 |
| 331 | `security_16` | [Mật hiệu đổi nhưng đồn chưa biết](#event-security_16) | An ninh | 3 |
| 332 | `security_17` | [Hộ vệ bị theo dõi ở chợ](#event-security_17) | An ninh | 3 |
| 333 | `security_18` | [Xe chở hàng không qua kiểm cửa](#event-security_18) | An ninh | 3 |
| 334 | `security_19` | [Đèn tín hiệu lạ trên tháp](#event-security_19) | An ninh | 3 |
| 335 | `security_20` | [Thư đe dọa gia đình thị vệ](#event-security_20) | An ninh | 3 |
| 336 | `security_21` | [Bản vẽ ngự phòng bị rao bán](#event-security_21) | An ninh | 3 |
| 337 | `security_22` | [Tin mật về người thay đầu bếp](#event-security_22) | An ninh | 3 |
| 338 | `security_23` | [Người xin mở cổng giữa đêm](#event-security_23) | An ninh | 3 |
| 339 | `security_24` | [Khoản tiền lạ vào nhà quản sự](#event-security_24) | An ninh | 3 |
| 340 | `security_25` | [Dấu hẹn trong thư chúc thọ](#event-security_25) | Âm mưu | 3 |
| 341 | `security_26` | [Thuốc ngủ được giấu gần cổng](#event-security_26) | Âm mưu | 3 |
| 342 | `security_27` | [Người giữ ấn nhận lời mời kín](#event-security_27) | Âm mưu | 3 |
| 343 | `palace_01` | [Kho vải nội cung thiếu sổ](#event-palace_01) | Hậu cung | 3 |
| 344 | `palace_02` | [Tranh lượt dùng vườn ngự](#event-palace_02) | Hậu cung | 3 |
| 345 | `palace_03` | [Một buổi nghe nhạc trong cung](#event-palace_03) | Hậu cung | 3 |
| 346 | `palace_04` | [Nhà ở của người hầu dột mái](#event-palace_04) | Hậu cung | 3 |
| 347 | `palace_05` | [Quà biếu ngoài sổ cho phi tần](#event-palace_05) | Hậu cung | 3 |
| 348 | `palace_06` | [Lời mời xem trò múa mới](#event-palace_06) | Hậu cung | 3 |
| 349 | `palace_07` | [Đèn trong nội điện tốn dầu](#event-palace_07) | Hậu cung | 3 |
| 350 | `palace_08` | [Cung nữ bị hai viện cùng gọi](#event-palace_08) | Hậu cung | 3 |
| 351 | `palace_09` | [Dạo thuyền trong hồ ngự](#event-palace_09) | Hậu cung | 3 |
| 352 | `palace_10` | [Khẩu phần trong cung bị cắt nhầm](#event-palace_10) | Hậu cung | 3 |
| 353 | `palace_11` | [Gia đình phi tần xin vào điện riêng](#event-palace_11) | Hậu cung | 3 |
| 354 | `palace_12` | [Cuộc thi làm thơ đêm](#event-palace_12) | Hậu cung | 3 |
| 355 | `palace_13` | [Rèm ngự điện cần thay](#event-palace_13) | Hậu cung | 3 |
| 356 | `palace_14` | [Chỗ ngồi trong yến nhỏ](#event-palace_14) | Hậu cung | 3 |
| 357 | `palace_15` | [Trò chơi cờ kéo dài](#event-palace_15) | Hậu cung | 3 |
| 358 | `palace_16` | [Người hầu xin áo mùa lạnh](#event-palace_16) | Hậu cung | 3 |
| 359 | `palace_17` | [Tin đồn thiên vị người mới](#event-palace_17) | Hậu cung | 3 |
| 360 | `palace_18` | [Buổi xem hoa sau cơn mưa](#event-palace_18) | Hậu cung | 3 |
| 361 | `palace_19` | [Sổ vật dụng hồi môn lẫn lộn](#event-palace_19) | Hậu cung | 3 |
| 362 | `palace_20` | [Thư riêng nhờ can thiệp chức vụ](#event-palace_20) | Hậu cung | 3 |
| 363 | `palace_21` | [Rượu quý dành riêng cho vua](#event-palace_21) | Hậu cung | 3 |
| 364 | `palace_22` | [Nội điện thiếu người lo việc chung](#event-palace_22) | Hậu cung | 3 |
| 365 | `palace_23` | [Tranh quyền chăm sóc lễ phục](#event-palace_23) | Hậu cung | 3 |
| 366 | `palace_24` | [Lời mời dự yến của phi tần](#event-palace_24) | Hậu cung | 3 |
| 367 | `palace_25` | [Kho hương trong cung phát thiếu](#event-palace_25) | Hậu cung | 3 |
| 368 | `palace_26` | [Tranh quyền chọn người dạy lễ](#event-palace_26) | Hậu cung | 3 |
| 369 | `palace_27` | [Tiếng sáo bên hồ ngự](#event-palace_27) | Hậu cung | 3 |
| 370 | `health_01` | [Cơn ho lúc buổi chầu](#event-health_01) | Sức khỏe | 3 |
| 371 | `health_02` | [Đọc tấu đến mờ mắt](#event-health_02) | Sức khỏe | 3 |
| 372 | `health_03` | [Bài thuốc mới từ phương xa](#event-health_03) | Sức khỏe | 3 |
| 373 | `health_04` | [Đau bụng sau bữa tối](#event-health_04) | Sức khỏe | 3 |
| 374 | `health_05` | [Bàn tay run khi ký chỉ](#event-health_05) | Sức khỏe | 3 |
| 375 | `health_06` | [Chứng sốt tái diễn](#event-health_06) | Sức khỏe | 3 |
| 376 | `health_07` | [Khàn tiếng giữa cuộc nghị](#event-health_07) | Sức khỏe | 3 |
| 377 | `health_08` | [Giấc ngủ đầy việc triều](#event-health_08) | Sức khỏe | 3 |
| 378 | `health_09` | [Thuốc bôi vết thương mới](#event-health_09) | Sức khỏe | 3 |
| 379 | `health_10` | [Cơn đau đầu dưới đèn](#event-health_10) | Sức khỏe | 3 |
| 380 | `health_11` | [Không còn ngon miệng](#event-health_11) | Sức khỏe | 3 |
| 381 | `health_12` | [Liệu trình phục hồi sau bệnh](#event-health_12) | Sức khỏe | 3 |
| 382 | `health_13` | [Đau lưng sau ngày thiết triều](#event-health_13) | Sức khỏe | 3 |
| 383 | `health_14` | [Tấu khẩn tới trong giờ ngủ](#event-health_14) | Sức khỏe | 3 |
| 384 | `health_15` | [Thuốc bổ gây tranh luận](#event-health_15) | Sức khỏe | 3 |
| 385 | `health_16` | [Vết phồng rộp sau chuyến đi](#event-health_16) | Sức khỏe | 3 |
| 386 | `health_17` | [Nhầm tên trong buổi chầu](#event-health_17) | Sức khỏe | 3 |
| 387 | `health_18` | [Thầy thuốc xin thử cách châm mới](#event-health_18) | Sức khỏe | 3 |
| 388 | `health_19` | [Cảm lạnh sau buổi tế](#event-health_19) | Sức khỏe | 3 |
| 389 | `health_20` | [Những bữa cơm bên bàn tấu](#event-health_20) | Sức khỏe | 3 |
| 390 | `health_21` | [Dược liệu khó hợp thể trạng](#event-health_21) | Sức khỏe | 3 |
| 391 | `health_22` | [Cơn chóng mặt khi đứng dậy](#event-health_22) | Sức khỏe | 3 |
| 392 | `health_23` | [Đêm trực đọc quân báo](#event-health_23) | Sức khỏe | 3 |
| 393 | `health_24` | [Đợt thuốc cần theo dõi dài ngày](#event-health_24) | Sức khỏe | 3 |
| 394 | `health_25` | [Mỏi ngực sau ngày nghị dài](#event-health_25) | Sức khỏe | 3 |
| 395 | `health_26` | [Một ngày không còn khoảng trống](#event-health_26) | Sức khỏe | 3 |
| 396 | `health_27` | [Đổi thuốc khi bệnh chưa dứt](#event-health_27) | Sức khỏe | 3 |
| 397 | `disasters_01` | [Nước cuốn cầu gỗ](#event-disasters_01) | Thiên tai | 3 |
| 398 | `disasters_02` | [Làng mất kho sau gió lớn](#event-disasters_02) | Thiên tai | 3 |
| 399 | `disasters_03` | [Người chạy cháy thiếu chỗ ăn](#event-disasters_03) | Thiên tai | 3 |
| 400 | `disasters_04` | [Bờ kênh tràn lúc nửa đêm](#event-disasters_04) | Thiên tai | 3 |
| 401 | `disasters_05` | [Nương đồi bị sạt mất bờ](#event-disasters_05) | Thiên tai | 3 |
| 402 | `disasters_06` | [Đàn châu chấu qua xóm](#event-disasters_06) | Thiên tai | 3 |
| 403 | `disasters_07` | [Cống nhỏ tắc giữa mưa](#event-disasters_07) | Thiên tai | 3 |
| 404 | `disasters_08` | [Giếng cạn sau mùa khô](#event-disasters_08) | Thiên tai | 3 |
| 405 | `disasters_09` | [Kho làng cháy vì đèn dầu](#event-disasters_09) | Thiên tai | 3 |
| 406 | `disasters_10` | [Bến đò sụt đất](#event-disasters_10) | Thiên tai | 3 |
| 407 | `disasters_11` | [Đất nứt quanh ao giữ nước](#event-disasters_11) | Thiên tai | 3 |
| 408 | `disasters_12` | [Gió cuốn mái khu chợ](#event-disasters_12) | Thiên tai | 3 |
| 409 | `disasters_13` | [Trẻ nhỏ mắc trên gò nước](#event-disasters_13) | Thiên tai | 3 |
| 410 | `disasters_14` | [Ruộng nhiễm mặn sau triều cường](#event-disasters_14) | Thiên tai | 3 |
| 411 | `disasters_15` | [Dịch vật nuôi làm mất nguồn ăn](#event-disasters_15) | Thiên tai | 3 |
| 412 | `disasters_16` | [Đường thoát nước bị vùi](#event-disasters_16) | Thiên tai | 3 |
| 413 | `disasters_17` | [Lửa rừng phá bờ chắn](#event-disasters_17) | Thiên tai | 3 |
| 414 | `disasters_18` | [Dân sơ tán ngủ ngoài đồng](#event-disasters_18) | Thiên tai | 3 |
| 415 | `disasters_19` | [Cột chống nhà chung bị trôi](#event-disasters_19) | Thiên tai | 3 |
| 416 | `disasters_20` | [Mưa đá làm hỏng vườn giống](#event-disasters_20) | Thiên tai | 3 |
| 417 | `disasters_21` | [Đàn thú phá kho dân](#event-disasters_21) | Thiên tai | 3 |
| 418 | `disasters_22` | [Vết xói dưới chân bờ](#event-disasters_22) | Thiên tai | 3 |
| 419 | `disasters_23` | [Hố sụt giữa vùng trồng trọt](#event-disasters_23) | Thiên tai | 3 |
| 420 | `disasters_24` | [Người dân mất lương trên đường tránh nạn](#event-disasters_24) | Thiên tai | 3 |
| 421 | `disasters_25` | [Nước tràn qua bãi dân cư](#event-disasters_25) | Khủng hoảng | 3 |
| 422 | `disasters_26` | [Dòng lũ đổi lối qua ruộng](#event-disasters_26) | Khủng hoảng | 3 |
| 423 | `disasters_27` | [Kho lương làng chìm trong lũ](#event-disasters_27) | Khủng hoảng | 3 |
| 424 | `culture_01` | [Lớp học cho trẻ ở bến sông](#event-culture_01) | Văn hóa | 3 |
| 425 | `culture_02` | [Sân diễn chung của dân](#event-culture_02) | Văn hóa | 3 |
| 426 | `culture_03` | [Thợ tìm cách nung gạch mới](#event-culture_03) | Văn hóa | 3 |
| 427 | `culture_04` | [Sách đọc cho làng xa](#event-culture_04) | Văn hóa | 3 |
| 428 | `culture_05` | [Ngày hội sau vụ gặt](#event-culture_05) | Văn hóa | 3 |
| 429 | `culture_06` | [Giấy từ thân cây lạ](#event-culture_06) | Văn hóa | 3 |
| 430 | `culture_07` | [Người lớn xin học tính sổ](#event-culture_07) | Văn hóa | 3 |
| 431 | `culture_08` | [Kho lưu nhạc của các phường](#event-culture_08) | Văn hóa | 3 |
| 432 | `culture_09` | [Bàn xoay mới của thợ gốm](#event-culture_09) | Văn hóa | 3 |
| 433 | `culture_10` | [Trẻ em vùng núi xin người dạy](#event-culture_10) | Văn hóa | 3 |
| 434 | `culture_11` | [Nhà đọc sách ở khu chợ](#event-culture_11) | Văn hóa | 3 |
| 435 | `culture_12` | [Dụng cụ đo ruộng cải tiến](#event-culture_12) | Văn hóa | 3 |
| 436 | `culture_13` | [Lớp chữ cho người giải ngũ](#event-culture_13) | Văn hóa | 3 |
| 437 | `culture_14` | [Phường hát muốn diễn ở quảng trường](#event-culture_14) | Văn hóa | 3 |
| 438 | `culture_15` | [Khung dệt mới tiết kiệm sợi](#event-culture_15) | Văn hóa | 3 |
| 439 | `culture_16` | [Sách thuốc dễ đọc cho dân](#event-culture_16) | Văn hóa | 3 |
| 440 | `culture_17` | [Lễ tưởng nhớ người giữ làng](#event-culture_17) | Văn hóa | 3 |
| 441 | `culture_18` | [Kính đọc chữ do thợ thử làm](#event-culture_18) | Văn hóa | 3 |
| 442 | `culture_19` | [Lớp dạy cân đo cho phụ việc](#event-culture_19) | Văn hóa | 3 |
| 443 | `culture_20` | [Chỗ tập cho đoàn múa rối](#event-culture_20) | Văn hóa | 3 |
| 444 | `culture_21` | [Màu nhuộm từ cây ven núi](#event-culture_21) | Văn hóa | 3 |
| 445 | `culture_22` | [Người mù xin lớp học kể chuyện](#event-culture_22) | Văn hóa | 3 |
| 446 | `culture_23` | [Ngày mở cửa kho bản đồ](#event-culture_23) | Văn hóa | 3 |
| 447 | `culture_24` | [Hộp giữ hạt giống khô](#event-culture_24) | Văn hóa | 3 |
| 448 | `culture_25` | [Thư viện nhỏ ở trạm xa](#event-culture_25) | Văn hóa | 3 |
| 449 | `culture_26` | [Buổi kể sử ngoài thành](#event-culture_26) | Văn hóa | 3 |
| 450 | `culture_27` | [Thợ trẻ chế bình nước đo canh giờ](#event-culture_27) | Văn hóa | 3 |

<a id="group-1"></a>
## Nhóm 1 — Dân sinh

<a id="event-levee_warning"></a>
### 1. Vết nứt bên dòng Đại Hà

- **Mã:** `levee_warning` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tạm gác lại”.

**Nội dung tấu chương:**

> Tri phủ dâng bản vẽ một đoạn đê đã yếu. Mùa mưa chưa tới, nhưng sửa sớm sẽ đỡ một nỗi lo.

#### Phương án 1 — Cấp tiền tu bổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥160 (chi 160 tiền); chưa có công trình sửa đê đang chạy; người xử lý là tùy chọn.
- **Tác động ngay — lợi ích và đánh đổi:** Mở công việc sửa đê; người xử lý là tùy chọn, để trống không tự giao người; hoàn tất cuối mùa chọn. Khi thành công: đê điều tăng từ cơ bản 30, điều chỉnh theo người phụ trách nếu có và thất thoát. Xem phụ lục kết quả công trình.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 35%; giao người đủ điều kiện: 40–70%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Mô tả lựa chọn trên UI:** Chi 160 · Bắt đầu tu bổ đê; kết quả tùy người phụ trách · Không giao ai: 35% thành công

#### Phương án 2 — Huy động dân phu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +7 · lòng dân -6

#### Phương án 3 — Tạm gác lại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5

<a id="event-village_school"></a>
### 3. Ngôi trường dưới mái đình

- **Mã:** `village_school` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Khuyến khích làng tự lo”.

**Nội dung tấu chương:**

> Một huyện nghèo xin tiền mở lớp học. Quan địa phương hứa sẽ gửi báo cáo sau vài mùa.

#### Phương án 1 — Cấp tiền mở lớp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả công việc riêng:** cuối mùa chọn phương án. Lòng dân +4; uy quyền +1. Không có nhánh thất bại riêng.
- **Mô tả lựa chọn trên UI:** Chi 70 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa chọn phương án: Lòng dân +4, uy quyền +1

#### Phương án 2 — Khuyến khích làng tự lo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -1

<a id="event-winter_fuel"></a>
### 16. Gió rét qua miền Bắc

- **Mã:** `winter_fuel` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Đang mùa Đông. Mã điều kiện: `winter`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ ngân sách”.

**Nội dung tấu chương:**

> Mùa đông khắc nghiệt đẩy giá củi và gạo lên cao. Những hộ nghèo cần được hỗ trợ.

#### Phương án 1 — Phát tiền cứu rét

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +4

#### Phương án 2 — Xuất kho hỗ trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · lòng dân +3

#### Phương án 3 — Giữ ngân sách [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6

<a id="event-local_epidemic"></a>
### 17. Dịch sốt ở bến sông

- **Mã:** `local_epidemic` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để địa phương tự lo”.

**Nội dung tấu chương:**

> Một khu chợ xuất hiện dịch sốt. Thầy thuốc địa phương xin dược liệu và người giúp.

#### Phương án 1 — Cấp thuốc và cách ly

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3

#### Phương án 2 — Đóng chợ tạm thời

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · lòng dân -2

#### Phương án 3 — Để địa phương tự lo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −9; Quân lực −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -9 · quân lực -2

<a id="event-festival"></a>
### 28. Đèn hoa trong kinh thành

- **Mã:** `festival` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Đang mùa Xuân. Mã điều kiện: `spring`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Để dân tự tổ chức”.

**Nội dung tấu chương:**

> Dân chúng chuẩn bị lễ hội. Triều đình có thể góp vui hoặc giữ lại ngân sách cho những việc khác.

#### Phương án 1 — Tổ chức lễ hội tiết kiệm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Căng thẳng −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · lòng dân +3 · căng thẳng -3

#### Phương án 2 — Để dân tự tổ chức [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · căng thẳng +2

<a id="event-refugees"></a>
### 37. Những người tới cửa Nam

- **Mã:** `refugees` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đóng cửa thành”.

**Nội dung tấu chương:**

> Các gia đình từ vùng biên xin cư trú. Tiếp nhận họ cần lương thực và sự phối hợp của địa phương.

#### Phương án 1 — Mở nơi tạm trú

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · lòng dân +3

#### Phương án 2 — Hỗ trợ tiền đi đường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · lòng dân +1

#### Phương án 3 — Đóng cửa thành [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6

<a id="event-petition_tax"></a>
### 41. Tấu xin giảm sưu

- **Mã:** `petition_tax` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Mức thuế đã áp dụng ở kỳ thu gần nhất là thuế cao. Mã điều kiện: `tax`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Dân sinh`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Giữ thuế hiện tại”.

**Nội dung tấu chương:**

> Thuế cao giúp ngân khố đầy hơn, nhưng các làng đã bắt đầu kiệt sức.

#### Phương án 1 — Giảm về mức vừa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Chọn thuế vừa cho kỳ thu hoạch Thu chưa chốt tiếp theo; không tính lại thuế đã thu; Lòng dân +3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +3 · căng thẳng +2 · Chọn mức thuế vừa cho kỳ thu tới

#### Phương án 2 — Giữ thuế hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −7; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -7 · uy quyền +1

<a id="event-community_01"></a>
### 46. Giếng làng bị nhiễm bẩn

- **Mã:** `community_01` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng tự thu xếp”.

**Nội dung tấu chương:**

> Dân hai xóm tranh nguồn nước sạch sau khi giếng chung đổi màu.

#### Phương án 1 — Cấp tiền đào giếng mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia kho dùng tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Để làng tự thu xếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_02"></a>
### 47. Đò ngang thu phí lạ

- **Mã:** `community_02` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ phủ báo cáo”.

**Nội dung tấu chương:**

> Chủ đò tự tăng phí, người làm ruộng không qua sông được.

#### Phương án 1 — Đích thân xét đơn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Công nhận biểu phí mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Chờ phủ báo cáo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_03"></a>
### 48. Xóm chài mất chỗ neo

- **Mã:** `community_03` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở bến mới”.

**Nội dung tấu chương:**

> Bến cũ bị lấp, thuyền đánh cá phải ngủ ngoài dòng nước xiết.

#### Phương án 1 — Đầu tư bến chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp thóc dựng bè tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Chưa mở bến mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_04"></a>
### 49. Nhà cháy trong ngõ hẹp

- **Mã:** `community_04` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để họ hàng cưu mang”.

**Nội dung tấu chương:**

> Một đám cháy lan qua dãy nhà, nhiều gia đình không còn mái trú.

#### Phương án 1 — Cấp tiền dựng nhà

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia vật liệu trong kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Để họ hàng cưu mang [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_05"></a>
### 50. Sổ hộ khẩu bỏ sót

- **Mã:** `community_05` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chuyển đơn xuống huyện”.

**Nội dung tấu chương:**

> Người tản cư sống ở kinh thành nhiều năm vẫn bị từ chối nhận khẩu phần.

#### Phương án 1 — Mở buổi đối chiếu sổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Giữ nguyên phép đăng hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Chuyển đơn xuống huyện [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_06"></a>
### 51. Lò bánh nuôi người nghèo

- **Mã:** `community_06` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không bảo trợ việc bán bánh”.

**Nội dung tấu chương:**

> Một nhóm thợ muốn mở lò bánh giá rẻ nhưng thiếu vốn ban đầu.

#### Phương án 1 — Bảo trợ lò bánh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp thóc cho mẻ đầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Không bảo trợ việc bán bánh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_07"></a>
### 52. Trẻ mồ côi ở trạm dịch

- **Mã:** `community_07` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giao các làng tiếp nhận”.

**Nội dung tấu chương:**

> Trạm dịch nuôi thêm trẻ mất cha mẹ, kinh phí ăn ở sắp cạn.

#### Phương án 1 — Lập quỹ chăm sóc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia khẩu phần kho trạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Giao các làng tiếp nhận [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_08"></a>
### 53. Hai làng chung nghĩa địa

- **Mã:** `community_08` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Hoãn xét tranh chấp”.

**Nội dung tấu chương:**

> Hai làng cùng nhận quyền trên mảnh đất chôn cất, đám tang bị chặn lại.

#### Phương án 1 — Nghe lời người làm chứng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Buộc theo ranh cũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Hoãn xét tranh chấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_09"></a>
### 54. Nhà trọ cho dân phu

- **Mã:** `community_09` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa giải quyết chỗ nghỉ”.

**Nội dung tấu chương:**

> Người sửa đường ngủ ngoài trời, chủ quán xin mở nhà trọ giá thấp.

#### Phương án 1 — Ứng vốn dựng nhà trọ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp lương dựng lán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Chưa giải quyết chỗ nghỉ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_10"></a>
### 55. Chợ phiên mất mái che

- **Mã:** `community_10` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ thương hộ tự góp”.

**Nội dung tấu chương:**

> Mái chợ đổ sau một đêm gió, người buôn nhỏ không có chỗ bán.

#### Phương án 1 — Cấp tiền sửa mái

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia vật tư dự trữ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Chờ thương hộ tự góp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_11"></a>
### 56. Tiếng chuông xin cứu

- **Mã:** `community_11` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ hết kỳ thu thuế”.

**Nội dung tấu chương:**

> Dân một xã gõ chuông vì bị trưởng xã giữ giấy đi đường.

#### Phương án 1 — Mở phiên xét công khai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Trao thêm quyền trưởng xã

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Chờ hết kỳ thu thuế [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_12"></a>
### 57. Người què xin nghề mới

- **Mã:** `community_12` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa lập lớp riêng”.

**Nội dung tấu chương:**

> Cựu dân phu mất sức lao động xin học nghề đan giỏ để nuôi nhà.

#### Phương án 1 — Mở lớp truyền nghề

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp thóc trong thời gian học

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Chưa lập lớp riêng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_13"></a>
### 58. Người già qua mùa lạnh

- **Mã:** `community_13` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dòng họ tự giúp”.

**Nội dung tấu chương:**

> Hội lão trình danh sách người sống một mình, không đủ củi sưởi.

#### Phương án 1 — Mua củi phát tận nhà

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia phần từ kho công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Để dòng họ tự giúp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_14"></a>
### 59. Tấm biển cấm gánh hàng

- **Mã:** `community_14` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không trả lời kiến nghị”.

**Nội dung tấu chương:**

> Quan phố cấm hàng rong để giữ đường sạch, nhiều gia đình mất kế sinh nhai.

#### Phương án 1 — Xét lại phạm vi lệnh cấm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Giữ lệnh dẹp hàng rong

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Không trả lời kiến nghị [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_15"></a>
### 60. Cầu nhỏ tới lớp học

- **Mã:** `community_15` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ đường đi hiện tại”.

**Nội dung tấu chương:**

> Trẻ em phải lội qua mương để tới lớp, làng muốn dựng cầu tre.

#### Phương án 1 — Cấp vốn làm cầu bền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp thóc đổi ngày công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Giữ đường đi hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_16"></a>
### 61. Đám cưới không đủ lễ

- **Mã:** `community_16` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để giữ lệ địa phương”.

**Nội dung tấu chương:**

> Một vùng ép nhà nghèo nộp lễ cưới quá lớn, nhiều đôi phải bỏ lễ.

#### Phương án 1 — Cấp quỹ cưới giản dị

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Dùng vật phẩm công chia sẻ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Để giữ lệ địa phương [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_17"></a>
### 62. Người kéo xe bị bắt oan

- **Mã:** `community_17` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi người nhà chứng minh”.

**Nội dung tấu chương:**

> Một toán lính bắt người kéo xe vì nhầm dấu trên kiện hàng.

#### Phương án 1 — Mở phiên đối chất ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Giữ người để răn đe

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Đợi người nhà chứng minh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_18"></a>
### 63. Bếp chung ngoài thành

- **Mã:** `community_18` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tham gia bếp chung”.

**Nội dung tấu chương:**

> Người làm thuê muốn mở bếp chung, chủ bến hứa góp mặt bằng.

#### Phương án 1 — Góp vốn lập bếp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất thóc vận hành trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Không tham gia bếp chung [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_19"></a>
### 64. Đàn bò phá vườn chung

- **Mã:** `community_19` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi hai bên tự dàn xếp”.

**Nội dung tấu chương:**

> Gia súc của nhà giàu phá hoa màu, người trồng vườn chưa được bồi thường.

#### Phương án 1 — Cấp tiền khắc phục trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia lương cứu vụ này

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Đợi hai bên tự dàn xếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_20"></a>
### 65. Cánh cổng đóng quá sớm

- **Mã:** `community_20` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi thêm lời khai”.

**Nội dung tấu chương:**

> Lính giữ thành đóng cổng trước giờ, người đi chợ bị kẹt ngoài đêm.

#### Phương án 1 — Kiểm tra sổ trực cổng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Chuẩn y giờ đóng mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Đợi thêm lời khai [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_21"></a>
### 66. Quán nước bên đường quan

- **Mã:** `community_21` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không cấp phép hỗ trợ”.

**Nội dung tấu chương:**

> Một góa phụ xin dựng quán nước cho người đi đường, làng đề nghị cùng góp.

#### Phương án 1 — Cấp vốn quán cộng đồng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Cấp thóc giúp khởi sự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Không cấp phép hỗ trợ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-community_22"></a>
### 67. Người gánh nước đình công

- **Mã:** `community_22` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để giá tự điều chỉnh”.

**Nội dung tấu chương:**

> Giá nước tăng khiến các xóm nghèo xin triều đình lập điểm cấp nước.

#### Phương án 1 — Mua nước cấp miễn phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia nguồn nước kho công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Để giá tự điều chỉnh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_23"></a>
### 68. Tên người chết trong sổ thu

- **Mã:** `community_23` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác đơn tới cuối vụ”.

**Nội dung tấu chương:**

> Một huyện vẫn thu sưu của người đã mất, gia đình phải bán đồ trả nợ.

#### Phương án 1 — Đối chiếu sổ ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Giữ định mức thu cũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Gác đơn tới cuối vụ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_24"></a>
### 69. Xưởng may áo mùa đông

- **Mã:** `community_24` · **Nhóm:** Dân sinh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `community`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa lập đơn hàng mới”.

**Nội dung tấu chương:**

> Thợ may xin nhận việc cho dân nghèo nếu triều đình ứng vốn vải.

#### Phương án 1 — Ứng vốn cho xưởng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất thóc trả công trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Chưa lập đơn hàng mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="group-2"></a>
## Nhóm 2 — Ngân khố

<a id="event-grain_merchants"></a>
### 2. Những xe thóc ngoài cửa thành

- **Mã:** `grain_merchants` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngân khố`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Để dân tự mua bán”.

**Nội dung tấu chương:**

> Thương nhân xin bán một đoàn thóc cho kho triều đình. Giá không rẻ, nhưng có thể dự phòng một mùa khó.

#### Phương án 1 — Mua cho kho dự trữ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥90 (chi 90 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +20.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 90 · lương thực +20

#### Phương án 2 — Để dân tự mua bán [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · căng thẳng +2

<a id="event-corrupt_gift"></a>
### 19. Hộp ngọc không tên

- **Mã:** `corrupt_gift` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngân khố`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Trả lại lễ vật”.

**Nội dung tấu chương:**

> Một thương nhân mang lễ vật quý vào cung, mong triều đình ưu tiên việc làm ăn của mình.

#### Phương án 1 — Nhận vào ngân khố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +55; Uy quyền −4; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +55 · uy quyền -4 · lòng dân -4 · Tiền nhận ngay 55 · sau phí +55.

#### Phương án 2 — Trả lại lễ vật [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · căng thẳng +2

<a id="event-treasury_review"></a>
### 27. Những trang sổ không khớp

- **Mã:** `treasury_review` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngân khố`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Cho Hộ bộ tự đối chiếu”.

**Nội dung tấu chương:**

> Sổ thu của hai địa phương chênh lệch bất thường. Có thể là nhầm lẫn, cũng có thể có người giấu tiền.

#### Phương án 1 — Kiểm toán độc lập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 35%; giao người đủ điều kiện: 40–70%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả công việc riêng:** cuối mùa kế tiếp (sau 1 mùa). Không giao ai: 35% thành công. Có người: 40–70%, theo đánh giá người xử lý. Thành công: ngân khố +60 đến +90; uy quyền +2. Thất bại: không có khoản thưởng này, không hoàn phí.
- **Mô tả lựa chọn trên UI:** Chi 20 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa): Nếu xác minh được: thu hồi 60–90 tiền, uy quyền +2; có thể chưa đủ chứng cứ · Vốn/phí ứng 20 tiền · Thành công: nhận 60–90 tiền, lãi sau vốn 40–70 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 35% thành công

#### Phương án 2 — Cho Hộ bộ tự đối chiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền -2

<a id="event-low_treasury"></a>
### 39. Hộ bộ xin cắt chi

- **Mã:** `low_treasury` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Ngân khố <120. Mã điều kiện: `poor`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Ngân khố`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ các khoản đã hứa”.

**Nội dung tấu chương:**

> Ngân khố không còn dư dả. Cắt khoản nào cũng sẽ có người chịu thiệt.

#### Phương án 1 — Giảm chi cung đình

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · Ổn định triều đình -3 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 2 — Thu thêm từ thương nhân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +45; Lòng dân −7.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +45 · lòng dân -7 · Tiền nhận ngay 45 · sau phí +45.

#### Phương án 3 — Giữ các khoản đã hứa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · căng thẳng +4

<a id="event-prosperity"></a>
### 40. Một mùa chợ đông

- **Mã:** `prosperity` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Ngân khố >450. Mã điều kiện: `rich`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngân khố`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dân hưởng lợi”.

**Nội dung tấu chương:**

> Các khu chợ buôn bán khởi sắc. Triều đình có thể tái đầu tư hoặc thu thêm một khoản.

#### Phương án 1 — Đầu tư kho và đường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lương thực +9 · lòng dân +2

#### Phương án 2 — Thu phí một lần

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +35 · lòng dân -2 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Để dân hưởng lợi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +3 · căng thẳng +2

<a id="event-finance_01"></a>
### 73. Khoản sưu trên ruộng cát

- **Mã:** `finance_01` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ kỳ lập sổ sau”.

**Nội dung tấu chương:**

> Sổ thuế tính ruộng cát ngang ruộng tốt, dân xin điều chỉnh khoản thiếu.

#### Phương án 1 — Bù phần thu quá mức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Giữ mức thu đang có

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chờ kỳ lập sổ sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_02"></a>
### 74. Dấu mực trên sổ kép

- **Mã:** `finance_02` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cất sổ chờ xét sau”.

**Nội dung tấu chương:**

> Ngự sử tìm thấy hai bản sổ chi khác nhau trong cùng một kho.

#### Phương án 1 — Cấp phí kiểm toán kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Dàn xếp với chủ kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Cất sổ chờ xét sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_03"></a>
### 75. Đề nghị góp vốn xưởng giấy

- **Mã:** `finance_03` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở khoản đầu tư”.

**Nội dung tấu chương:**

> Một xưởng giấy muốn mở thêm lò để bán giấy cho các phủ.

#### Phương án 1 — Góp vốn thử nghiệm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay thế gia để mở rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Chưa mở khoản đầu tư [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_04"></a>
### 76. Thuế người chạy chợ

- **Mã:** `finance_04` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để huyện tự xử”.

**Nội dung tấu chương:**

> Phu gánh hàng bị thu thuế cả lúc vào lẫn lúc rời chợ.

#### Phương án 1 — Hoàn một phần tiền thu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Duy trì thu hai lượt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để huyện tự xử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_05"></a>
### 77. Bao bạc thiếu niêm phong

- **Mã:** `finance_05` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Lưu kho không điều tra”.

**Nội dung tấu chương:**

> Bạc nộp về có bao bị thay dây, quan vận chuyển nói vì mưa.

#### Phương án 1 — Cho truy lại tuyến vận

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền và bỏ qua dấu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Lưu kho không điều tra [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_06"></a>
### 78. Lò gốm xin đơn hàng

- **Mã:** `finance_06` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa ký đơn hàng”.

**Nội dung tấu chương:**

> Thợ gốm đề nghị nhận đơn bình đựng nước nếu được ứng tiền lò.

#### Phương án 1 — Ứng vốn đặt lô thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay tiền đặt lô lớn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Chưa ký đơn hàng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_07"></a>
### 79. Nợ sưu của lính tử trận

- **Mã:** `finance_07` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chuyển đơn sang quân phủ”.

**Nội dung tấu chương:**

> Gia đình lính đã mất vẫn phải trả khoản sưu ghi trước ngày nhập ngũ.

#### Phương án 1 — Bù khoản nợ cho nhà

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Thu đủ theo sổ cũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chuyển đơn sang quân phủ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_08"></a>
### 80. Sáp niêm kho bị thay

- **Mã:** `finance_08` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không mở lại hòm cũ”.

**Nội dung tấu chương:**

> Người giữ chìa phát hiện mẫu sáp lạ trên hòm thuế tháng trước.

#### Phương án 1 — Thuê thợ xác minh dấu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thỏa thuận với người giữ kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không mở lại hòm cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_09"></a>
### 81. Xưởng nhuộm muốn đổi kỹ thuật

- **Mã:** `finance_09` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách nhuộm cũ”.

**Nội dung tấu chương:**

> Một nhóm thợ xin vốn thử cách nhuộm ít tốn củi nhưng chưa có tiền lệ.

#### Phương án 1 — Tài trợ một mẻ thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay vốn dựng cả xưởng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Giữ cách nhuộm cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_10"></a>
### 82. Thuế đàn ong trên đồi

- **Mã:** `finance_10` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi mùa hoa mới”.

**Nội dung tấu chương:**

> Hộ nuôi ong bị tính thuế theo số tổ dù mùa hoa thất bát.

#### Phương án 1 — Giảm phần thu năm nay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Thu đủ để giữ ngân sách

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Đợi mùa hoa mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_11"></a>
### 83. Tiền sửa đình chưa tới làng

- **Mã:** `finance_11` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tạm tin giấy đã ký”.

**Nội dung tấu chương:**

> Làng xuất trình giấy nhận tiền nhưng trưởng làng nói chưa từng nhận.

#### Phương án 1 — Sai ngự sử truy khoản chi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu khoản dàn xếp từ hào lý

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Tạm tin giấy đã ký [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_12"></a>
### 84. Mỏ đá gửi bản tính lãi

- **Mã:** `finance_12` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa rót vốn vào mỏ”.

**Nội dung tấu chương:**

> Chủ mỏ hứa bán đá cho công trình công nếu được mua thêm dụng cụ.

#### Phương án 1 — Góp vốn khai thác thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay thế gia mua dụng cụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Chưa rót vốn vào mỏ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_13"></a>
### 85. Phí qua cầu tăng đột ngột

- **Mã:** `finance_13` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi quy định”.

**Nội dung tấu chương:**

> Một trạm cầu thu thêm tiền mỗi gánh khiến dân phải đi đường vòng.

#### Phương án 1 — Bù phí và giảm mức thu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Cho trạm giữ mức tăng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chưa đổi quy định [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_14"></a>
### 86. Phiếu lĩnh lương trùng tên

- **Mã:** `finance_14` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kỳ lương sau xét”.

**Nội dung tấu chương:**

> Hai người cùng lĩnh lương bằng một tên, thuộc hạ yêu cầu kiểm tra kín.

#### Phương án 1 — Kiểm lại sổ lĩnh lương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu tiền giải quyết nội bộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để kỳ lương sau xét [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_15"></a>
### 87. Kho chứa muối liên doanh

- **Mã:** `finance_15` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tham gia kho muối”.

**Nội dung tấu chương:**

> Thương nhân mời triều đình góp vốn kho muối để tránh hỏng hàng mùa ẩm.

#### Phương án 1 — Góp phần vốn nhỏ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay tiền giành phần lớn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Không tham gia kho muối [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_16"></a>
### 88. Lệ phí chôn cất mới

- **Mã:** `finance_16` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để phủ tự cân đối”.

**Nội dung tấu chương:**

> Một phủ đặt thêm phí chôn cất để bù khoản thiếu trong sổ thu.

#### Phương án 1 — Bù khoản thiếu và giảm phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Cho phép duy trì lệ phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để phủ tự cân đối [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_17"></a>
### 89. Đồng cân hụt trong kho bạc

- **Mã:** `finance_17` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguyên bộ cân”.

**Nội dung tấu chương:**

> Thợ cân báo quả cân của kho nhẹ hơn chuẩn, chưa rõ ai đổi.

#### Phương án 1 — Lập tổ kiểm cân độc lập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản bù của chủ kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ nguyên bộ cân [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_18"></a>
### 90. Thợ đúc xin thử khuôn mới

- **Mã:** `finance_18` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không chấp nhận thử khuôn”.

**Nội dung tấu chương:**

> Thợ đúc muốn làm khuôn bền hơn, đổi lại xin triều đình chia lợi nhuận.

#### Phương án 1 — Cấp vốn cho một lò

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay vốn nhân nhiều lò

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Không chấp nhận thử khuôn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_19"></a>
### 91. Phí đổi giấy thông hành

- **Mã:** `finance_19` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xét lại lệ phí”.

**Nội dung tấu chương:**

> Dân phải trả tiền đổi giấy dù mẫu giấy cũ mới ban hành.

#### Phương án 1 — Bù phí đổi cho dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Tiếp tục thu theo mẫu mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Không xét lại lệ phí [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_20"></a>
### 92. Khoản chi cho trạm ma

- **Mã:** `finance_20` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác khoản chi chưa rõ”.

**Nội dung tấu chương:**

> Bộ sổ ghi tiền nuôi một trạm dịch đã bị bỏ hoang từ lâu.

#### Phương án 1 — Cho kiểm kê tận nơi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền bồi hoàn kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Gác khoản chi chưa rõ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_21"></a>
### 93. Nghề làm nến thiếu sáp

- **Mã:** `finance_21` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không ứng trước tiền”.

**Nội dung tấu chương:**

> Phường làm nến cần vốn mua sáp đầu mùa, hứa nộp phần lãi.

#### Phương án 1 — Ứng vốn một mùa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay thế gia mua sáp lớn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Không ứng trước tiền [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_22"></a>
### 94. Thuế thuyền nằm bờ

- **Mã:** `finance_22` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ đợt kiểm thuyền sau”.

**Nội dung tấu chương:**

> Thuyền hỏng vẫn phải nộp thuế hoạt động, chủ thuyền xin xét lại.

#### Phương án 1 — Bù thuế cho thuyền hỏng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Thu theo số đăng bạ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chờ đợt kiểm thuyền sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_23"></a>
### 95. Bản kê quân trang bị sửa

- **Mã:** `finance_23` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa truy bản kê”.

**Nội dung tấu chương:**

> Khoản chi áo giáp tăng sau khi đã đóng ấn, người chép sổ phủ nhận.

#### Phương án 1 — Kiểm toán khoản quân trang

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền dàn xếp của nhà cung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa truy bản kê [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_24"></a>
### 96. Đề nghị chung vốn ép dầu

- **Mã:** `finance_24` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguồn mua hiện tại”.

**Nội dung tấu chương:**

> Chủ xưởng dầu muốn mua guồng ép mới để cung cấp dầu đèn cho kinh.

#### Phương án 1 — Góp vốn thử guồng mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Vay tiền mở rộng ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Giữ nguồn mua hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="event-finance_25"></a>
### 97. Gia đình quan nhỏ thiếu lương

- **Mã:** `finance_25` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Nợ chi trả >0. Mã điều kiện: `debt`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để họ chờ kỳ sau”.

**Nội dung tấu chương:**

> Lương chậm làm nhiều nhà quan nhỏ phải vay nặng lãi để ăn.

#### Phương án 1 — Chi hỗ trợ và trả bớt nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Nợ chi trả −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +2 · nợ chi trả -6

#### Phương án 2 — Thu thêm để vá thiếu hụt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · lòng dân -4 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để họ chờ kỳ sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · lòng dân -1

<a id="event-finance_26"></a>
### 98. Hộp tiền trạm thuế bị tráo

- **Mã:** `finance_26` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Ngân khố <120. Mã điều kiện: `poor`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở vụ điều tra”.

**Nội dung tấu chương:**

> Trạm thuế báo thiếu tiền giữa lúc ngân khố cạn, chứng từ có nhiều vết sửa.

#### Phương án 1 — Truy xét khoản thất thoát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +70; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Ổn định triều đình −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +70 · uy quyền +1. Thất bại: Ổn định triều đình -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 70 tiền, lãi sau vốn 50 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản nộp kín của thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa mở vụ điều tra [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −12; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -12 · uy quyền -1

<a id="event-finance_27"></a>
### 99. Lời mời mua lại công trái

- **Mã:** `finance_27` · **Nhóm:** Ngân khố.
- **Điều kiện xuất hiện:** Nợ chi trả >0. Mã điều kiện: `debt`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `finance`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục thiếu nguồn chi”.

**Nội dung tấu chương:**

> Thế gia muốn đổi một khoản vay mới lấy quyền ưu tiên cung ứng cho triều đình.

#### Phương án 1 — Đầu tư nguồn thu độc lập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 40%; giao người đủ điều kiện: 45–75%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 40% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +45; Lòng dân +1.
- **Kết quả chờ — thất bại 60% khi không giao ai:** cùng thời điểm: Lòng dân −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 10 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 40% thành công: ngân khố +45 · lòng dân +1. Thất bại: lòng dân -1. · Vốn/phí ứng 10 tiền · Thành công: nhận 45 tiền, lãi sau vốn 35 tiền · Thất bại: mất 10 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 40% thành công

#### Phương án 2 — Nhận khoản vay có điều kiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +22; Nợ chi trả +40; Thái độ phe Thế gia +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +22 · nợ chi trả +40 · phe Thế gia +1 · căng thẳng +2 · Nhận 22 tiền ngay · phát sinh 40 nợ.

#### Phương án 3 — Tiếp tục thiếu nguồn chi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · Ổn định triều đình -1

<a id="group-3"></a>
## Nhóm 3 — Triều chính

<a id="event-tax_abuse"></a>
### 4. Tiếng kêu oan ở cổng phủ

- **Mã:** `tax_abuse` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Triều chính`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tin báo cáo Hộ bộ”.

**Nội dung tấu chương:**

> Dân tố người thu thuế đòi thêm tiền ngoài sổ. Hộ bộ cho rằng đây chỉ là lời đồn.

#### Phương án 1 — Sai ngự sử xác minh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 35%; giao người đủ điều kiện: 40–70%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả công việc riêng:** cuối mùa kế tiếp (sau 1 mùa). Không giao ai: 35% thành công. Có người: 40–70%, theo đánh giá người xử lý. Thành công: ngân khố +60 đến +90; uy quyền +2. Thất bại: không có khoản thưởng này, không hoàn phí.
- **Mô tả lựa chọn trên UI:** Chi 20 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa): Nếu xác minh được: thu hồi 60–90 tiền, uy quyền +2; có thể chưa đủ chứng cứ · Vốn/phí ứng 20 tiền · Thành công: nhận 60–90 tiền, lãi sau vốn 40–70 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 35% thành công

#### Phương án 2 — Hoàn lại tiền cho dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +4

#### Phương án 3 — Tin báo cáo Hộ bộ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · Ổn định triều đình +1

<a id="event-court_rumor"></a>
### 10. Lời đồn sau rèm châu

- **Mã:** `court_rumor` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Ổn định triều đình <55. Mã điều kiện: `court`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Triều chính`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không can dự”.

**Nội dung tấu chương:**

> Một đại thần bị tố kết bè. Chưa có bằng chứng, nhưng các phe đã bắt đầu nghi kỵ nhau.

#### Phương án 1 — Điều tra kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 35%; giao người đủ điều kiện: 40–70%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả công việc riêng:** cuối mùa kế tiếp (sau 1 mùa). Không giao ai: 35% thành công. Có người: 40–70%, theo đánh giá người xử lý. Thành công: giảm tối đa 6 tiến độ âm mưu cho mỗi người còn hoạt động (hậu cung chỉ người đã nhập cung). Thất bại: không giảm âm mưu; không hoàn phí.
- **Mô tả lựa chọn trên UI:** Chi 40 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa): Nếu xác minh được: mỗi âm mưu giảm tối đa 6; có thể chưa đủ chứng cứ · Không giao ai: 35% thành công

#### Phương án 2 — Triệu các phe hòa giải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +3 · uy quyền -2

#### Phương án 3 — Không can dự [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -6

<a id="event-examination"></a>
### 18. Khoa thi mùa xuân

- **Mã:** `examination` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Đang mùa Xuân. Mã điều kiện: `spring`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `Triều chính`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Hoãn khoa thi”.

**Nội dung tấu chương:**

> Sĩ tử hội về kinh thành. Một khoa thi công bằng sẽ củng cố niềm tin vào triều đình.

#### Phương án 1 — Mở khoa thi nghiêm túc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Ổn định triều đình +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · Ổn định triều đình +2

#### Phương án 2 — Cho thế gia tiến cử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Lòng dân −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · lòng dân -5 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Hoãn khoa thi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3

<a id="event-land_dispute"></a>
### 30. Một thửa ruộng, hai tờ khế

- **Mã:** `land_dispute` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Triều chính`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tạm đình chỉ tranh chấp”.

**Nội dung tấu chương:**

> Dân làng và một thế gia đều nhận quyền sở hữu ruộng. Bản án sẽ khiến ít nhất một bên không hài lòng.

#### Phương án 1 — Xét theo chứng cứ của dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +4; Ổn định triều đình −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +4 · Ổn định triều đình -4

#### Phương án 2 — Giữ quyền cho thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Lòng dân −7.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · lòng dân -7

#### Phương án 3 — Tạm đình chỉ tranh chấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3

<a id="event-retired_adviser"></a>
### 35. Lời khuyên của người cũ

- **Mã:** `retired_adviser` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 2 (mùa Hạ · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Triều chính`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tiếp kiến”.

**Nội dung tấu chương:**

> Một lão thần về kinh, xin nhắc lại những bài học từ triều trước. Nghe lời can gián có thể giúp việc trị nước.

#### Phương án 1 — Mời vào điện đàm đạo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · căng thẳng +1

#### Phương án 2 — Gửi quà thăm hỏi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1

#### Phương án 3 — Không tiếp kiến [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_01"></a>
### 262. Hai bộ cùng giữ một hồ sơ

- **Mã:** `bureaucracy_01` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai bộ tiếp tục tranh quyền”.

**Nội dung tấu chương:**

> Công việc đứng lại vì hai bộ đều nói mình có quyền duyệt cuối cùng.

#### Phương án 1 — Tự phân quyền và sửa quy trình

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Bán quyền phê duyệt cho nhà bảo trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để hai bộ tiếp tục tranh quyền [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_02"></a>
### 263. Lịch trực quan chồng chéo

- **Mã:** `bureaucracy_02` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để triều thần tự thu xếp”.

**Nội dung tấu chương:**

> Hai nhóm quan được xếp trực cùng buổi, không ai chịu nhường vị trí.

#### Phương án 1 — Chi phí họp thống nhất lịch

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Dùng mệnh lệnh ép một lịch

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để triều thần tự thu xếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_03"></a>
### 264. Sổ chi mua đèn tăng gấp bội

- **Mã:** `bureaucracy_03` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để sổ chi được duyệt tiếp”.

**Nội dung tấu chương:**

> Lượng đèn không đổi nhưng tiền mua tăng, các phòng cùng đổ lỗi cho giá dầu.

#### Phương án 1 — Cấp phí kiểm toán khoản mua

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản nộp để bỏ kiểm tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để sổ chi được duyệt tiếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_04"></a>
### 265. Chỉ dụ bị sao thành hai bản

- **Mã:** `bureaucracy_04` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa cách ban chỉ dụ”.

**Nội dung tấu chương:**

> Hai địa phương nhận hai bản chỉ dụ khác nhau khiến việc thu thuế bị đình lại.

#### Phương án 1 — Đích thân chuẩn hóa việc sao chỉ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Giao quyền sao cho nhà có tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa sửa cách ban chỉ dụ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_05"></a>
### 266. Ghế ngồi trong buổi chầu

- **Mã:** `bureaucracy_05` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Mặc các phe tự sắp ghế”.

**Nội dung tấu chương:**

> Quan Văn và quan Võ tranh ghế đứng gần ngai, việc nghị chính bị kéo dài.

#### Phương án 1 — Chi phí nghị bàn phép chầu chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép theo nghi thức quân lệnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Mặc các phe tự sắp ghế [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_06"></a>
### 267. Kho giấy hao bất thường

- **Mã:** `bureaucracy_06` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục mua giấy như cũ”.

**Nội dung tấu chương:**

> Giấy mua cho triều đình nhanh hết nhưng văn bản phát đi không tăng.

#### Phương án 1 — Mở kiểm toán kho giấy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền bù từ nhà cung cấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Tiếp tục mua giấy như cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_07"></a>
### 268. Mệnh lệnh đến sau thời hạn

- **Mã:** `bureaucracy_07` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ số vòng ký hiện tại”.

**Nội dung tấu chương:**

> Các công văn thường đến nơi khi việc đã qua, người chuyển thư xin sửa khâu ký.

#### Phương án 1 — Tự cắt bớt vòng trình ký

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Nhượng quyền chuyển thư lấy tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ số vòng ký hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_08"></a>
### 269. Đại thần bất đồng giờ chầu

- **Mã:** `bureaucracy_08` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để mỗi nhóm tới theo giờ riêng”.

**Nội dung tấu chương:**

> Một nhóm muốn chầu sớm, nhóm khác nói quan xa không kịp đến kinh.

#### Phương án 1 — Họp thống nhất giờ chầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép áp dụng giờ mới ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để mỗi nhóm tới theo giờ riêng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_09"></a>
### 270. Tiền sửa công đường mất dấu

- **Mã:** `bureaucracy_09` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa kiểm tra công đường”.

**Nội dung tấu chương:**

> Công đường vẫn dột dù đã nhận đủ tiền, hồ sơ thanh toán có nhiều dấu xóa.

#### Phương án 1 — Chi phí kiểm toán dự án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền trả bù để khép sổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa kiểm tra công đường [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_10"></a>
### 271. Con dấu đi theo người nghỉ

- **Mã:** `bureaucracy_10` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi quan ấy quay lại”.

**Nội dung tấu chương:**

> Một quan mang ấn về quê dưỡng bệnh khiến phòng không duyệt được việc.

#### Phương án 1 — Sửa quy tắc bàn giao ấn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Cho nhà bảo trợ giữ quyền duyệt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Đợi quan ấy quay lại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_11"></a>
### 272. Bản tấu chen nhau trình vua

- **Mã:** `bureaucracy_11` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các quan tự tranh lượt”.

**Nội dung tấu chương:**

> Các quan cùng xin ưu tiên tấu của mình, chuyện khẩn bị lẫn với việc thường.

#### Phương án 1 — Chi phí lập thứ tự nghị bàn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép ưu tiên theo quân lệnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để các quan tự tranh lượt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_12"></a>
### 273. Tên người nhận bổng bị lặp

- **Mã:** `bureaucracy_12` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Duyệt sổ bổng chưa đối chiếu”.

**Nội dung tấu chương:**

> Một số tên xuất hiện trong hai sổ bổng, người coi sổ nói chỉ là trùng họ.

#### Phương án 1 — Cấp phí soát lại danh sách

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền hoàn để thôi tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Duyệt sổ bổng chưa đối chiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_13"></a>
### 274. Mẫu biểu mỗi huyện một kiểu

- **Mã:** `bureaucracy_13` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các huyện gửi mẫu cũ”.

**Nội dung tấu chương:**

> Dữ liệu mùa vụ không ghép được vì mỗi huyện dùng đơn vị và mẫu khác nhau.

#### Phương án 1 — Tự chuẩn hóa mẫu và đơn vị

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Giao việc thống kê cho nhà thầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để các huyện gửi mẫu cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_14"></a>
### 275. Quan mới không được bàn việc

- **Mã:** `bureaucracy_14` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để lệ cũ tự quyết tiếng nói”.

**Nội dung tấu chương:**

> Người mới bị chặn phát biểu vì chưa theo lệ cũ, triều đình chia thành hai nhóm.

#### Phương án 1 — Tổ chức phiên thống nhất quy tắc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ra lệnh buộc mọi người tuân theo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để lệ cũ tự quyết tiếng nói [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_15"></a>
### 276. Ngựa trạm có tên nhưng không có thật

- **Mã:** `bureaucracy_15` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Duyệt tiếp khoản nuôi ngựa”.

**Nội dung tấu chương:**

> Sổ chi nuôi ngựa đủ đàn trong khi chuồng chỉ còn một nửa.

#### Phương án 1 — Cấp tiền kiểm tra thực địa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu khoản bù từ người bảo trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Duyệt tiếp khoản nuôi ngựa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_16"></a>
### 277. Việc khẩn nằm dưới chồng tấu

- **Mã:** `bureaucracy_16` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách xếp công văn cũ”.

**Nội dung tấu chương:**

> Công văn khẩn bị xếp theo ngày đến, người thư lại không dám đổi thứ tự.

#### Phương án 1 — Đích thân sửa luồng xử lý khẩn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Nhượng quyền ưu tiên lấy phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ cách xếp công văn cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_17"></a>
### 278. Quan xin nghỉ cùng một dịp

- **Mã:** `bureaucracy_17` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa phân lại lịch làm việc”.

**Nội dung tấu chương:**

> Nhiều đại thần cùng xin vắng, nhóm ở lại cho rằng mình bị đẩy hết việc.

#### Phương án 1 — Họp chia lịch và cấp hỗ trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Dùng mệnh lệnh buộc trực

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Chưa phân lại lịch làm việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_18"></a>
### 279. Tiền công sứ bị khai trùng

- **Mã:** `bureaucracy_18` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các bộ tự quyết khoản chi”.

**Nội dung tấu chương:**

> Một chuyến công cán được kê ở nhiều bộ, các chữ ký đều đúng thẩm quyền.

#### Phương án 1 — Cấp phí đối chiếu chứng từ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận tiền hoàn để kết thúc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để các bộ tự quyết khoản chi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_19"></a>
### 280. Chức trách bị bỏ trống giữa hai bộ

- **Mã:** `bureaucracy_19` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ các bộ tự nhận việc”.

**Nội dung tấu chương:**

> Một nhiệm vụ không ai nhận vì không ghi rõ trong lệ phân công cũ.

#### Phương án 1 — Tự xác định trách nhiệm mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Giao quyền xử lý cho nhà tài trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chờ các bộ tự nhận việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_20"></a>
### 281. Quan địa phương chống lệnh luân chuyển

- **Mã:** `bureaucracy_20` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các nhóm tự thương lượng”.

**Nội dung tấu chương:**

> Một nhóm quan xin giữ địa hạt, nhóm khác nói không đổi sẽ sinh cục bộ.

#### Phương án 1 — Chi phí nghị bàn cách luân chuyển

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép luân chuyển bằng lệnh quân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để các nhóm tự thương lượng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_21"></a>
### 282. Vật tư nhập kho thiếu cân

- **Mã:** `bureaucracy_21` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa soát lại nhà cung ứng”.

**Nội dung tấu chương:**

> Phiếu ghi đủ cân nhưng lính kho báo hàng nhận nhẹ hơn nhiều.

#### Phương án 1 — Cấp phí kiểm định vật tư

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản bồi hoàn kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa soát lại nhà cung ứng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_22"></a>
### 283. Quyền ký thay không rõ ràng

- **Mã:** `bureaucracy_22` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục theo lệ truyền miệng”.

**Nội dung tấu chương:**

> Một quyết định bị hủy vì người ký thay không có văn bản ủy quyền.

#### Phương án 1 — Tự lập quy tắc ký thay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Bán quyền đại diện cho nhà bảo trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Tiếp tục theo lệ truyền miệng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_23"></a>
### 284. Tiếng nói của quan xa kinh

- **Mã:** `bureaucracy_23` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để quan xa tự gửi phản đối”.

**Nội dung tấu chương:**

> Quan địa phương nói chỉ được nghe quyết định sau khi các phe ở kinh đã chốt.

#### Phương án 1 — Chi phí tổ chức phiên nghị chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép thực hiện quyết định hiện có

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để quan xa tự gửi phản đối [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_24"></a>
### 285. Khoản chi lễ nghi không có biên nhận

- **Mã:** `bureaucracy_24` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Phê sổ chi thiếu biên nhận”.

**Nội dung tấu chương:**

> Bộ phận lễ nghi xin thanh toán một khoản lớn chỉ bằng lời chứng của quản sự.

#### Phương án 1 — Mở kiểm toán khoản chi lễ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản trả bù để thôi xét

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Phê sổ chi thiếu biên nhận [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="event-bureaucracy_25"></a>
### 286. Hồ sơ phải trình lại từ đầu

- **Mã:** `bureaucracy_25` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ phép trình lại hồ sơ”.

**Nội dung tấu chương:**

> Một người dân phải nộp lại đơn vì đổi quan duyệt, khiến nhiều việc không bao giờ xong.

#### Phương án 1 — Tự sửa phép chuyển hồ sơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình +1 · mệt mỏi +3

#### Phương án 2 — Bán quyền xử nhanh cho nhà bảo trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Uy quyền −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · uy quyền -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ phép trình lại hồ sơ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-bureaucracy_26"></a>
### 287. Quan chuyên môn bị gạt ngoài cuộc

- **Mã:** `bureaucracy_26` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để nhóm cũ tự chọn người dự”.

**Nội dung tấu chương:**

> Một nhóm quan không cho người hiểu việc tham dự vì người ấy thuộc nhóm khác.

#### Phương án 1 — Chi phí thống nhất cách mời nghị

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1

#### Phương án 2 — Ép nghị theo mệnh lệnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Để nhóm cũ tự chọn người dự [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3

<a id="event-bureaucracy_27"></a>
### 288. Tiền thuê người chép sổ tăng vọt

- **Mã:** `bureaucracy_27` · **Nhóm:** Triều chính.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `bureaucracy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Duyệt tiền thuê chưa đối chiếu”.

**Nội dung tấu chương:**

> Tên người chép sổ dài hơn số bàn làm việc, quan coi phòng chưa giải thích rõ.

#### Phương án 1 — Cấp phí kiểm toán nhân công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Dân chính. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +75; Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: ngân khố +75 · Ổn định triều đình +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 75 tiền, lãi sau vốn 50 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Nhận khoản hoàn để khép sổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −2; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -2 · phe Thế gia +1 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Duyệt tiền thuê chưa đối chiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · Ổn định triều đình -2

<a id="group-4"></a>
## Nhóm 4 — Quân sự

<a id="event-border_riders"></a>
### 5. Khói lửa ngoài biên ải

- **Mã:** `border_riders` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ xem động tĩnh”.

**Nội dung tấu chương:**

> Kỵ binh phương Bắc thăm dò cửa ải. Đại tướng xin chuẩn bị phòng thủ trước khi tình hình xấu hơn.

#### Phương án 1 — Tăng viện cửa ải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +5; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · quân lực +5 · áp lực chiến tranh +1

#### Phương án 2 — Cử sứ thương lượng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 35%; giao người đủ điều kiện: 40–70%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả công việc riêng:** cuối mùa chọn phương án. Không giao ai: 35% thành công, không tự chọn quan thay người chơi. Có người: 40–70%, theo đánh giá người xử lý. Thành công: giảm chiến tranh từ cơ bản 3, tăng uy quyền từ cơ bản 2, điều chỉnh theo người phụ trách nếu có và thất thoát; bao vây về 0. Thất bại thường: chiến tranh +1, uy quyền −2; thất bại nặng: chiến tranh +2, uy quyền −4, ngân khố −20. Người được giao không còn hợp lệ khi tới hạn: gián đoạn, uy quyền −2. Phí đã chi không hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa chọn phương án: Kết quả tùy người phụ trách Ngoại giao; có thể thất bại · Không giao ai: 35% thành công

#### Phương án 3 — Chờ xem động tĩnh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +2

<a id="event-army_pay"></a>
### 13. Lính gác chưa nhận lương

- **Mã:** `army_pay` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Nợ chi trả >0. Mã điều kiện: `debt`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Kêu gọi quân sĩ nhẫn nại”.

**Nội dung tấu chương:**

> Nghĩa vụ chi trả đang tồn đọng. Tướng lĩnh cảnh báo khó giữ quân nếu triều đình tiếp tục chậm trễ.

#### Phương án 1 — Chi khoản hỗ trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥90 (chi 90 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Nợ chi trả −29.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 90 · quân lực +3 · nợ chi trả -29

#### Phương án 2 — Kêu gọi quân sĩ nhẫn nại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −6; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -6 · uy quyền -3

<a id="event-general_merit"></a>
### 20. Chiến công nơi cửa ải

- **Mã:** `general_merit` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Gửi chiếu khen”.

**Nội dung tấu chương:**

> Một toán cướp bị quân biên giới đánh lui. Các võ quan xin triều đình ghi nhận công lao.

#### Phương án 1 — Ban thưởng quân sĩ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · quân lực +3 · Ổn định triều đình +1

#### Phương án 2 — Gửi chiếu khen [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · căng thẳng +2

<a id="event-war_supplies"></a>
### 25. Đoàn xe tiếp tế bị chặn

- **Mã:** `war_supplies` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguồn lực trong kinh”.

**Nội dung tấu chương:**

> Đường vận lương không còn an toàn. Quân ngoài biên ải cần tiếp tế trước khi tinh thần suy sụp.

#### Phương án 1 — Mở đường hộ tống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥90 (chi 90 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 90 · quân lực +3 · áp lực chiến tranh -1

#### Phương án 2 — Chuyển thóc theo đường vòng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · quân lực +2

#### Phương án 3 — Giữ nguồn lực trong kinh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −10; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -10 · áp lực chiến tranh +1

<a id="event-bandits"></a>
### 29. Đường núi không còn yên

- **Mã:** `bandits` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Quân lực <50. Mã điều kiện: `weakArmy`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ mặc tuyến đường”.

**Nội dung tấu chương:**

> Thương lái bị cướp trên tuyến đường phía Tây. Dân địa phương xin triều đình bảo vệ.

#### Phương án 1 — Điều quân dẹp cướp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Quân lực −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 35 · lòng dân +3 · quân lực -2

#### Phương án 2 — Chiêu an có điều kiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥15 (chi 15 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 15 · lòng dân +1 · uy quyền -2

#### Phương án 3 — Bỏ mặc tuyến đường [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −15; Lòng dân −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -15 · lòng dân -6

<a id="event-military_drill"></a>
### 36. Tiếng trống thao trường

- **Mã:** `military_drill` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Hoãn diễn tập”.

**Nội dung tấu chương:**

> Tướng lĩnh muốn mở cuộc diễn tập. Quân đội sẽ sẵn sàng hơn, đổi lại là chi phí và hao hụt lương thực.

#### Phương án 1 — Chuẩn y diễn tập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +5; Lương thực −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +5 · lương thực -5

#### Phương án 2 — Hoãn diễn tập [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2

<a id="event-craftsmen"></a>
### 38. Lò rèn mới của kinh thành

- **Mã:** `craftsmen` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Quân sự`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Giữ trang bị hiện tại”.

**Nội dung tấu chương:**

> Thợ rèn đề xuất cải tiến quân khí. Nếu được cấp vốn, vài mùa nữa triều đình sẽ nhận được thành phẩm.

#### Phương án 1 — Đặt hàng quân khí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥90 (chi 90 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả công việc riêng:** cuối mùa chọn phương án. Quân lực +8. Không có nhánh thất bại riêng.
- **Mô tả lựa chọn trên UI:** Chi 90 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa chọn phương án: Quân lực +8

#### Phương án 2 — Giữ trang bị hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Không đổi chỉ số ngay

<a id="event-military_01"></a>
### 181. Tân binh thiếu giày

- **Mã:** `military_01` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để quân tự xoay xở”.

**Nội dung tấu chương:**

> Doanh trại nhận lính mới nhưng nhiều người phải tập trên nền đá bằng chân trần.

#### Phương án 1 — Mua giày cho tân binh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng vật tư và lương trong dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Để quân tự xoay xở [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_02"></a>
### 182. Trận địa thử chưa dựng

- **Mã:** `military_02` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa thử cách bố trí mới”.

**Nội dung tấu chương:**

> Một tướng trẻ xin lập trận địa thử, hứa tìm cách giữ cửa ải ít tốn quân.

#### Phương án 1 — Cấp phí diễn tập thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Giao tướng toàn quyền điều quân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Chưa thử cách bố trí mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_03"></a>
### 183. Đội tuần tra thiếu bữa

- **Mã:** `military_03` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Rút bớt phần ăn”.

**Nội dung tấu chương:**

> Lính mùa biên xin phần lương thực đủ cho chuyến đi dài.

#### Phương án 1 — Cấp khẩu phần hành quân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng lương từ làng ven ải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Rút bớt phần ăn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_04"></a>
### 184. Dây cung trong kho mục

- **Mã:** `military_04` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Dùng nốt số dây cũ”.

**Nội dung tấu chương:**

> Nhiều dây cung đứt lúc tập, người coi kho xin thay trước đợt luân chuyển quân.

#### Phương án 1 — Mua dây cung đạt chuẩn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng vật tư địa phương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Dùng nốt số dây cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_05"></a>
### 185. Đường áp sát cửa ải

- **Mã:** `military_05` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không thử tuyến vòng”.

**Nội dung tấu chương:**

> Trinh sát đề xuất thử tuyến vòng để chặn đối phương nếu biên giới có biến.

#### Phương án 1 — Tài trợ cuộc khảo sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho tướng tự điều quân thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Không thử tuyến vòng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_06"></a>
### 186. Kho gạo quân đóng xa

- **Mã:** `military_06` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ định mức đang cấp”.

**Nội dung tấu chương:**

> Đội lính ở trạm xa phải chia khẩu phần thấp hơn định mức.

#### Phương án 1 — Đưa thêm lương tới trạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng phần ăn từ làng gần

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Giữ định mức đang cấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_07"></a>
### 187. Lính gác ngủ ngoài mái

- **Mã:** `military_07` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để doanh tự sửa dần”.

**Nội dung tấu chương:**

> Khu nhà trực bị hỏng mái làm lính thay phiên nghỉ không đủ giấc.

#### Phương án 1 — Cấp tiền sửa nơi nghỉ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng gỗ và thóc địa phương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Để doanh tự sửa dần [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_08"></a>
### 188. Kỹ thuật báo hiệu mới

- **Mã:** `military_08` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách báo hiệu cũ”.

**Nội dung tấu chương:**

> Một đội trưởng muốn thử cách báo hiệu nhanh hơn giữa các đồn.

#### Phương án 1 — Cấp tiền thử hệ thống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho quân tự đặt quy tắc riêng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Giữ cách báo hiệu cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_09"></a>
### 189. Đàn ngựa thiếu thức ăn

- **Mã:** `military_09` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giảm bữa và chờ tiếp tế”.

**Nội dung tấu chương:**

> Những con ngựa quân yếu dần vì phần thức ăn không theo kịp lịch tập.

#### Phương án 1 — Xuất lương giữ sức ngựa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng thêm từ các làng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Giảm bữa và chờ tiếp tế [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_10"></a>
### 190. Quân y thiếu vải băng

- **Mã:** `military_10` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi kỳ cấp phát sau”.

**Nội dung tấu chương:**

> Những vết thương lúc tập không được băng đúng cách vì thiếu vật tư.

#### Phương án 1 — Mua vải băng quân y

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng vật tư trong dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Đợi kỳ cấp phát sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_11"></a>
### 191. Đội hình giữ cầu hẹp

- **Mã:** `military_11` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi đội hình cũ”.

**Nội dung tấu chương:**

> Một tướng xin diễn tập đội hình mới để giữ những cầu trọng yếu.

#### Phương án 1 — Cấp tiền diễn tập có giám sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho tướng tự chọn quân tập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Chưa đổi đội hình cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_12"></a>
### 192. Lính vận lương mắc đường

- **Mã:** `military_12` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cho các trạm chịu thiếu”.

**Nội dung tấu chương:**

> Đội xe quân lương bị chậm, các trạm ở phía trước đang cắt phần ăn.

#### Phương án 1 — Xuất kho tiếp tế đường khác

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng lương từ huyện gần

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Cho các trạm chịu thiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_13"></a>
### 193. Mũ sắt sai kích cỡ

- **Mã:** `military_13` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Buộc dùng tạm mũ cũ”.

**Nội dung tấu chương:**

> Lô mũ mới quá rộng với nhiều tân binh, việc luyện tập bị gián đoạn.

#### Phương án 1 — Mua và sửa mũ phù hợp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng dụng vật tư địa phương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Buộc dùng tạm mũ cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_14"></a>
### 194. Trinh sát vùng rừng rậm

- **Mã:** `military_14` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ tuyến trinh sát cũ”.

**Nội dung tấu chương:**

> Một đội xin thử cách luân phiên trinh sát để giảm chỗ mù quanh biên ải.

#### Phương án 1 — Cấp phí cho chuyến thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Trao thêm quyền cho tướng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Giữ tuyến trinh sát cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_15"></a>
### 195. Bếp quân dập lửa sớm

- **Mã:** `military_15` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cắt bớt bữa trong doanh”.

**Nội dung tấu chương:**

> Bếp trong doanh không còn đủ lương thực để nấu đủ hai bữa.

#### Phương án 1 — Xuất thóc giữ bếp quân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Lấy lương từ làng quanh doanh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Cắt bớt bữa trong doanh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_16"></a>
### 196. Lính mới bị giữ phụ cấp

- **Mã:** `military_16` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi kiểm tra xong mới cấp”.

**Nội dung tấu chương:**

> Người phụ trách cấp phát chậm tiền, tân binh bắt đầu bỏ buổi tập.

#### Phương án 1 — Chi khoản hỗ trợ trực tiếp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng nguồn lực từ địa phương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Đợi kiểm tra xong mới cấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_17"></a>
### 197. Bãi tập phòng thủ ven sông

- **Mã:** `military_17` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa dựng bãi tập”.

**Nội dung tấu chương:**

> Đô đốc xin dựng bãi thử để luyện giữ bến khi thủy quân đối phương xuất hiện.

#### Phương án 1 — Cấp phí diễn tập ven sông

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho tướng tự điều phối lực lượng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Chưa dựng bãi tập [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_18"></a>
### 198. Kho đồn lẫn thóc mốc

- **Mã:** `military_18` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chia nhỏ phần thóc còn tốt”.

**Nội dung tấu chương:**

> Người giữ kho báo phần thóc ăn được không đủ cho kỳ trực mới.

#### Phương án 1 — Xuất lương thay thóc hỏng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng thêm lương dân quanh đồn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Chia nhỏ phần thóc còn tốt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_19"></a>
### 199. Xe kéo pháo hỏng trục

- **Mã:** `military_19` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa xe đồng loạt”.

**Nội dung tấu chương:**

> Những xe quân dụng không kéo được tải chuẩn, đội thợ xin tiền thay trục.

#### Phương án 1 — Mua trục và sửa xe

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng dụng xe vật tư của dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Chưa sửa xe đồng loạt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_20"></a>
### 200. Đội cứu viện đi đường đêm

- **Mã:** `military_20` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách chuyển quân cũ”.

**Nội dung tấu chương:**

> Một chỉ huy đề nghị tập cách chuyển quân ban đêm để phản ứng sớm hơn.

#### Phương án 1 — Cấp phí tập có kiểm soát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho tướng tự điều quân ban đêm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Giữ cách chuyển quân cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_21"></a>
### 201. Lương quân tới sai đơn vị

- **Mã:** `military_21` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ sổ điều chuyển được sửa”.

**Nội dung tấu chương:**

> Một đồn nhận nhầm thóc của đồn khác, cả hai đều báo phần ăn thiếu.

#### Phương án 1 — Xuất lương vá hai đồn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng lương tạm trong dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Chờ sổ điều chuyển được sửa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_22"></a>
### 202. Những hàng quân thưa dần

- **Mã:** `military_22` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Quân lực <50. Mã điều kiện: `weakArmy`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa bổ sung quân trang”.

**Nội dung tấu chương:**

> Tướng lĩnh báo lực lượng giảm, trang bị cũ khiến người còn lại càng khó giữ đồn.

#### Phương án 1 — Chi tiền bổ sung trang bị

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng thêm nguồn lực dân sự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Chưa bổ sung quân trang [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_23"></a>
### 203. Tin trinh sát trước trận lớn

- **Mã:** `military_23` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không dò đường trước trận”.

**Nội dung tấu chương:**

> Trinh sát xin mở chuyến dò đường có rủi ro trước khi đối phương tiến quân.

#### Phương án 1 — Cấp phí cho chuyến trinh sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Trao tướng quyền tự triển khai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Không dò đường trước trận [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_24"></a>
### 204. Lương thực cho quân bị vây

- **Mã:** `military_24` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ phần tiếp tế tuần này”.

**Nội dung tấu chương:**

> Một đơn vị bị ép vào đồn hẹp, cần thêm lương để chờ đường viện mở.

#### Phương án 1 — Xuất kho tiếp tế đồn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng lương dân sát chiến tuyến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Bỏ phần tiếp tế tuần này [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="event-military_25"></a>
### 205. Quân dự bị xin tập lại

- **Mã:** `military_25` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để quân dự bị chờ lệnh”.

**Nội dung tấu chương:**

> Lực lượng dự bị lâu không tập, người chỉ huy xin trang bị cho một đợt ôn luyện.

#### Phương án 1 — Cấp tiền cho đợt tập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +4; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · quân lực +4 · phe Võ tướng +1

#### Phương án 2 — Trưng dụng nguồn lực địa phương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥8 (xuất 8 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 8 lương thực · quân lực +3 · lòng dân -4

#### Phương án 3 — Để quân dự bị chờ lệnh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -3 · uy quyền -1

<a id="event-military_26"></a>
### 206. Lối rút khỏi thung lũng

- **Mã:** `military_26` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở lối dự phòng”.

**Nội dung tấu chương:**

> Một đội tiên phong muốn thử mở lối rút để tránh bị khóa trong thung lũng.

#### Phương án 1 — Cấp phí mở đường thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa chọn phương án: Quân lực +6; Áp lực chiến tranh −1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Quân lực −5; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +1 · Cuối mùa chọn phương án: 45% thành công: quân lực +6 · áp lực chiến tranh -1. Thất bại: quân lực -5 · uy quyền -2. · Không giao ai: 45% thành công

#### Phương án 2 — Cho tướng quyết việc điều quân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Ổn định triều đình −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +2 · Ổn định triều đình -3 · phe Võ tướng +1

#### Phương án 3 — Chưa mở lối dự phòng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · áp lực chiến tranh +1

<a id="event-military_27"></a>
### 207. Suất ăn của quân tái ngũ

- **Mã:** `military_27` · **Nhóm:** Quân sự.
- **Điều kiện xuất hiện:** Quân lực <50. Mã điều kiện: `weakArmy`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `military`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đơn vị tự cân phần”.

**Nội dung tấu chương:**

> Những người trở lại đội ngũ chưa nhận đủ phần ăn, tinh thần trong trại đang xuống.

#### Phương án 1 — Xuất lương đón quân trở lại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · quân lực +3 · uy quyền +1

#### Phương án 2 — Trưng phần ăn của làng gần

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Lòng dân −5; Thái độ phe Văn thần −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · lòng dân -5 · phe Văn thần -2

#### Phương án 3 — Để đơn vị tự cân phần [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -4 · Ổn định triều đình -2

<a id="group-5"></a>
## Nhóm 5 — Cung đình

<a id="event-noble_feast"></a>
### 6. Thiệp mời từ phủ Quốc công

- **Mã:** `noble_feast` · **Nhóm:** Cung đình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Cung đình`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Gửi lời đáp lễ”.

**Nội dung tấu chương:**

> Một bữa tiệc hội đủ các thế gia. Có thể kết thân, nhưng tiếng đàn thường giữ khách tới khuya.

#### Phương án 1 — Dự tiệc cùng các quan

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Số lần hưởng lạc trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · Ổn định triều đình +3 · lần hưởng lạc +1

#### Phương án 2 — Gửi lời đáp lễ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · căng thẳng +2

<a id="event-palace_poetry"></a>
### 14. Một đêm thơ ở Ngự uyển

- **Mã:** `palace_poetry` · **Nhóm:** Cung đình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Cung đình`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Dành buổi tối nghỉ ngơi”.

**Nội dung tấu chương:**

> Các học sĩ đề nghị một buổi thưởng thơ giản dị. Giữa những tấu chương, cũng cần một khoảng thảnh thơi.

#### Phương án 1 — Cùng thưởng thơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥10 (chi 10 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Số lần hưởng lạc trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 10 · lần hưởng lạc +1

#### Phương án 2 — Dành buổi tối nghỉ ngơi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1

<a id="event-palace_repairs"></a>
### 31. Mái điện qua một mùa mưa

- **Mã:** `palace_repairs` · **Nhóm:** Cung đình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Cung đình`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Dành tiền cho dân”.

**Nội dung tấu chương:**

> Một gian điện cần tu sửa. Thợ khuyên làm sớm, trong khi các quan đề nghị ưu tiên việc dân.

#### Phương án 1 — Sửa vừa đủ dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1

#### Phương án 2 — Dành tiền cho dân [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2

<a id="event-hunting_invite"></a>
### 32. Cuộc săn đầu mùa

- **Mã:** `hunting_invite` · **Nhóm:** Cung đình.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Cung đình`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Ở cung nghỉ ngơi”.

**Nội dung tấu chương:**

> Các võ tướng mời vua đi săn. Đây là dịp gần gũi quân thần, nhưng đường rừng không hoàn toàn an toàn.

#### Phương án 1 — Đi săn có hộ vệ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥15 (chi 15 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Số lần hưởng lạc trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 15 · quân lực +1 · lần hưởng lạc +1

#### Phương án 2 — Ở cung nghỉ ngơi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1

<a id="group-6"></a>
## Nhóm 6 — Thiên tai

<a id="event-rain_forecast"></a>
### 7. Mưa dồn trên thượng nguồn

- **Mã:** `rain_forecast` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Thiên tai`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giao địa phương tự liệu”.

**Nội dung tấu chương:**

> Trạm dịch liên tiếp báo mưa lớn. Nếu đê yếu, các làng ven sông sẽ gặp nguy hiểm.

#### Phương án 1 — Củng cố khẩn cấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥100 (chi 100 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +11.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 100 · đê điều +11

#### Phương án 2 — Sơ tán các làng thấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Lương thực −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · lòng dân +1 · lương thực -5

#### Phương án 3 — Giao địa phương tự liệu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −8; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -8 · lòng dân -3

<a id="event-drought"></a>
### 15. Đất nứt giữa mùa hạ

- **Mã:** `drought` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Thiên tai`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ mưa xuống”.

**Nội dung tấu chương:**

> Nắng dài khiến đồng ruộng thiếu nước. Địa phương xin hỗ trợ khơi kênh và giữ giống.

#### Phương án 1 — Cấp tiền khơi kênh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥90 (chi 90 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +5; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 90 · lương thực +5 · lòng dân +1

#### Phương án 2 — Xuất thóc giống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2

#### Phương án 3 — Chờ mưa xuống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −18; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -18 · lòng dân -4

<a id="event-disasters_01"></a>
### 397. Nước cuốn cầu gỗ

- **Mã:** `disasters_01` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cứu hộ cầu gỗ”.

**Nội dung tấu chương:**

> Một cầu tạm bị nước cuốn, dân mắc lại hai bên và xin cứu hộ.

#### Phương án 1 — Chi tiền cứu hộ và gia cố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân ứng cứu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Chưa cứu hộ cầu gỗ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_02"></a>
### 398. Làng mất kho sau gió lớn

- **Mã:** `disasters_02` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng tự dựng lại”.

**Nội dung tấu chương:**

> Gió phá kho và bờ giữ nước, dân xin giúp dựng lại trước vụ tới.

#### Phương án 1 — Đầu tư tái thiết có kiểm tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và ghi nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Để làng tự dựng lại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_03"></a>
### 399. Người chạy cháy thiếu chỗ ăn

- **Mã:** `disasters_03` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp cứu trợ cháy”.

**Nội dung tấu chương:**

> Nhiều gia đình mất bếp sau đám cháy, họ cần phần ăn trước khi về dựng nhà.

#### Phương án 1 — Xuất lương cứu trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân chia sức cứu dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cấp cứu trợ cháy [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_04"></a>
### 400. Bờ kênh tràn lúc nửa đêm

- **Mã:** `disasters_04` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi nước tự rút”.

**Nội dung tấu chương:**

> Nước đang tràn qua bờ thấp, người giữ kênh xin vật liệu cứu gấp.

#### Phương án 1 — Chi tiền cứu và gia cố bờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân đắp bờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Đợi nước tự rút [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_05"></a>
### 401. Nương đồi bị sạt mất bờ

- **Mã:** `disasters_05` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dân tự sửa nương”.

**Nội dung tấu chương:**

> Một vụ sạt nhỏ làm ruộng bậc thang hỏng, dân cần tái thiết có tính toán.

#### Phương án 1 — Đầu tư sửa lại bờ ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và vay nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Để dân tự sửa nương [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_06"></a>
### 402. Đàn châu chấu qua xóm

- **Mã:** `disasters_06` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cứu phần lương đã mất”.

**Nội dung tấu chương:**

> Một xóm mất phần lớn lương ăn sau khi châu chấu tràn qua ruộng.

#### Phương án 1 — Xuất lương cứu xóm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân hỗ trợ dân đói

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cứu phần lương đã mất [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_07"></a>
### 403. Cống nhỏ tắc giữa mưa

- **Mã:** `disasters_07` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ mưa ngừng rồi tính”.

**Nội dung tấu chương:**

> Cành cây chặn cống khiến nước dâng quanh khu dân, người dân cần giúp.

#### Phương án 1 — Chi tiền khai thông và gia cố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân thông cống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Chờ mưa ngừng rồi tính [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_08"></a>
### 404. Giếng cạn sau mùa khô

- **Mã:** `disasters_08` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng chờ mưa”.

**Nội dung tấu chương:**

> Làng muốn đào giếng và khơi bờ dẫn nước mới nhưng không đủ sức tự làm.

#### Phương án 1 — Đầu tư công trình nước thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và ghi nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Để làng chờ mưa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_09"></a>
### 405. Kho làng cháy vì đèn dầu

- **Mã:** `disasters_09` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa bù lương bị cháy”.

**Nội dung tấu chương:**

> Một đám cháy thiêu lương dự trữ, người thoát nạn kéo nhau xin ăn.

#### Phương án 1 — Xuất lương giúp dân mất kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân chia sức cứu trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa bù lương bị cháy [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_10"></a>
### 406. Bến đò sụt đất

- **Mã:** `disasters_10` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để chủ bến tự cứu người”.

**Nội dung tấu chương:**

> Bến đò lở làm nhiều người kẹt trong mưa, dân xin đội cứu hộ triều đình.

#### Phương án 1 — Chi tiền cứu và gia cố bến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân cứu hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Để chủ bến tự cứu người [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_11"></a>
### 407. Đất nứt quanh ao giữ nước

- **Mã:** `disasters_11` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa ao giữ nước”.

**Nội dung tấu chương:**

> Nền ao nứt sau khô hạn, làng xin làm lại hệ giữ nước trước mùa mưa.

#### Phương án 1 — Đầu tư tái thiết có giám sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương trước và nhận thêm nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Chưa sửa ao giữ nước [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_12"></a>
### 408. Gió cuốn mái khu chợ

- **Mã:** `disasters_12` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa giúp khu chợ sau gió”.

**Nội dung tấu chương:**

> Nhiều người bán hàng mất nơi ở lẫn lương ăn sau một trận gió mạnh.

#### Phương án 1 — Xuất lương cho người mất mái

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân hỗ trợ khu chợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa giúp khu chợ sau gió [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_13"></a>
### 409. Trẻ nhỏ mắc trên gò nước

- **Mã:** `disasters_13` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ nước xuống gò”.

**Nội dung tấu chương:**

> Nước lên nhanh khiến một nhóm trẻ và người già không rời được gò cao.

#### Phương án 1 — Chi tiền cứu và gia cố lối thoát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân cứu người

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Chờ nước xuống gò [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_14"></a>
### 410. Ruộng nhiễm mặn sau triều cường

- **Mã:** `disasters_14` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dân tự chờ nước ngọt”.

**Nội dung tấu chương:**

> Dân cần phục hồi bờ giữ nước và ruộng để không mất thêm vụ nữa.

#### Phương án 1 — Đầu tư phục hồi ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương trước và ghi thêm nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Để dân tự chờ nước ngọt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_15"></a>
### 411. Dịch vật nuôi làm mất nguồn ăn

- **Mã:** `disasters_15` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cứu hộ mất đàn”.

**Nội dung tấu chương:**

> Nhiều hộ mất đàn vật nuôi cùng lúc, lương ăn trong làng nhanh chóng thiếu.

#### Phương án 1 — Xuất lương cứu các hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân hỗ trợ sinh hoạt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cứu hộ mất đàn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_16"></a>
### 412. Đường thoát nước bị vùi

- **Mã:** `disasters_16` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ địa phương tự dọn”.

**Nội dung tấu chương:**

> Đất đổ xuống rãnh chính làm nước dồn về nhà dân, việc khai thông cần làm gấp.

#### Phương án 1 — Chi tiền cứu và khơi rãnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân khai thông

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Chờ địa phương tự dọn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_17"></a>
### 413. Lửa rừng phá bờ chắn

- **Mã:** `disasters_17` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa phục hồi bờ chắn”.

**Nội dung tấu chương:**

> Lửa đi qua đồi làm bờ và vườn giữ đất hỏng, dân xin tái thiết trước mưa.

#### Phương án 1 — Đầu tư phục hồi khu đồi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và vay nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Chưa phục hồi bờ chắn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_18"></a>
### 414. Dân sơ tán ngủ ngoài đồng

- **Mã:** `disasters_18` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cứu nơi trú tạm”.

**Nội dung tấu chương:**

> Một nhóm dân tránh tai họa chưa có phần ăn trong điểm trú tạm.

#### Phương án 1 — Xuất lương tới nơi trú

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân hỗ trợ người sơ tán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cứu nơi trú tạm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_19"></a>
### 415. Cột chống nhà chung bị trôi

- **Mã:** `disasters_19` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi dân tự rời nhà chung”.

**Nội dung tấu chương:**

> Nước xiết làm nhà trú chung nghiêng, nhiều gia đình chưa tìm được chỗ an toàn.

#### Phương án 1 — Chi tiền cứu và gia cố nhà

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân chống đỡ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Đợi dân tự rời nhà chung [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_20"></a>
### 416. Mưa đá làm hỏng vườn giống

- **Mã:** `disasters_20` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng tự tìm giống khác”.

**Nội dung tấu chương:**

> Vườn giống và bờ giữ nước hỏng, làng cần phục hồi để có vụ sau.

#### Phương án 1 — Đầu tư phục hồi vườn giống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương trước và nhận nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Để làng tự tìm giống khác [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_21"></a>
### 417. Đàn thú phá kho dân

- **Mã:** `disasters_21` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa giúp phần lương mất”.

**Nội dung tấu chương:**

> Thú đói tràn vào phá kho, người làng mất phần lương qua mùa.

#### Phương án 1 — Xuất lương giúp làng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân chia sức bảo vệ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa giúp phần lương mất [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="event-disasters_22"></a>
### 418. Vết xói dưới chân bờ

- **Mã:** `disasters_22` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Đê điều <50. Mã điều kiện: `weakLevee`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa vá vết xói”.

**Nội dung tấu chương:**

> Một vết xói mới xuất hiện dưới bờ yếu, dân xin cứu trước khi nước dâng.

#### Phương án 1 — Chi tiền cứu và gia cố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân ứng cứu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Chưa vá vết xói [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_23"></a>
### 419. Hố sụt giữa vùng trồng trọt

- **Mã:** `disasters_23` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ việc phục hồi nền đất”.

**Nội dung tấu chương:**

> Một hố sụt phá mương và ruộng, địa phương cần thử cách phục hồi nền đất.

#### Phương án 1 — Đầu tư tái thiết có theo dõi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và ghi nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Bỏ việc phục hồi nền đất [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_24"></a>
### 420. Người dân mất lương trên đường tránh nạn

- **Mã:** `disasters_24` · **Nhóm:** Thiên tai.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `disasters`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp phần ăn cho đoàn”.

**Nội dung tấu chương:**

> Đoàn dân sơ tán bị mất xe lương trên đường, xin giúp qua vài ngày đầu.

#### Phương án 1 — Xuất lương cứu đoàn dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân hỗ trợ đoàn tránh nạn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cấp phần ăn cho đoàn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="group-7"></a>
## Nhóm 7 — Khủng hoảng

<a id="event-flood"></a>
### 8. Nước tràn qua bờ ruộng

- **Mã:** `flood` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Đang mùa Hạ và đê điều <40. Mã điều kiện: `flood`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Khủng hoảng`.
- **Việc khẩn:** nguyên nhân `flood`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Ưu tiên giữ kho triều đình”.

**Nội dung tấu chương:**

> Đê yếu đã không giữ được nước. Làng mạc cần cứu tế ngay để tránh mất mùa lan rộng.

#### Phương án 1 — Mở kho cứu dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥38 (xuất 38 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 38 lương thực · lòng dân +3

#### Phương án 2 — Mua gạo cứu tế

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥150 (chi 150 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 150 · lòng dân +3

#### Phương án 3 — Ưu tiên giữ kho triều đình [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −16; Lương thực −10.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -16 · lương thực -10

<a id="event-hunger"></a>
### 9. Nồi cháo trước sân đình

- **Mã:** `hunger` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lương thực <25. Mã điều kiện: `hungry`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Khủng hoảng`.
- **Việc khẩn:** nguyên nhân `hunger`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Siết khẩu phần”.

**Nội dung tấu chương:**

> Kho lương cạn dần. Người dân bắt đầu rời làng tìm nơi còn gạo; những lời oán thán lan nhanh.

#### Phương án 1 — Mua thóc khẩn cấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥130 (chi 130 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +22; Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 130 · lương thực +22 · lòng dân +3

#### Phương án 2 — Vay thóc các thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +16; Uy quyền −7.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +16 · uy quyền -7

#### Phương án 3 — Siết khẩu phần [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −12; Quân lực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -12 · quân lực -4

<a id="event-rebellion_warning"></a>
### 43. Tiếng trống từ huyện xa

- **Mã:** `rebellion_warning` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Khủng hoảng`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không nhượng bộ”.

**Nội dung tấu chương:**

> Dân tụ tập phản đối, quan địa phương không còn kiểm soát được tình hình. Cần hành động trước khi bạo loạn lan rộng.

#### Phương án 1 — Cứu tế và miễn khoản thu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥130 (chi 130 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +9.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 130 · lòng dân +9

#### Phương án 2 — Điều quân giữ trật tự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −7; Lòng dân +3; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -7 · lòng dân +3 · uy quyền +1

#### Phương án 3 — Không nhượng bộ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −9; Ổn định triều đình −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -9 · Ổn định triều đình -4

<a id="event-community_25"></a>
### 70. Tấm chiếu trước cổng phủ

- **Mã:** `community_25` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đóng cửa tiếp dân”.

**Nội dung tấu chương:**

> Dân kéo tới ngồi kín cổng phủ, yêu cầu hỗ trợ những nhà mất mùa.

#### Phương án 1 — Cấp cứu trợ tận hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +3

#### Phương án 2 — Chia phần dự trữ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥3 (xuất 3 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 3 lương thực · lòng dân +1 · uy quyền -2

#### Phương án 3 — Đóng cửa tiếp dân [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3

<a id="event-community_26"></a>
### 71. Người khiêng cày tới điện

- **Mã:** `community_26` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chuyển đơn qua nhiều phủ”.

**Nội dung tấu chương:**

> Nông dân đặt cày trước nha môn, đòi vua nghe chuyện lao dịch quá mức.

#### Phương án 1 — Mở buổi dân trình bày

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền +1; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +2 · uy quyền +1 · mệt mỏi +3

#### Phương án 2 — Buộc họ trở về ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -3

#### Phương án 3 — Chuyển đơn qua nhiều phủ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · Ổn định triều đình -1

<a id="event-community_27"></a>
### 72. Bếp nguội trong xóm thợ

- **Mã:** `community_27` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Mặc các xưởng đóng cửa”.

**Nội dung tấu chương:**

> Các xưởng ngừng việc, người thợ yêu cầu một đường sống trước khi rời kinh.

#### Phương án 1 — Đầu tư việc làm khẩn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lòng dân −3; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lòng dân +3 · uy quyền +1. Thất bại: lòng dân -3 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất thóc giữ bếp chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥15 (xuất 15 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 15 lương thực · lòng dân +2 · Ổn định triều đình -2

#### Phương án 3 — Mặc các xưởng đóng cửa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · uy quyền -1

<a id="event-agriculture_25"></a>
### 151. Cháo loãng bên kho giống

- **Mã:** `agriculture_25` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lương thực <25. Mã điều kiện: `hungry`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:hunger`.
- **Việc khẩn:** nguyên nhân `hunger`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Siết phần ăn tiếp tục chờ”.

**Nội dung tấu chương:**

> Người dân xếp hàng xin cứu đói, nhiều nhà đã không còn gì để gieo.

#### Phương án 1 — Xuất thóc cứu đói

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc của thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Siết phần ăn tiếp tục chờ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_26"></a>
### 152. Người bán cày lấy gạo

- **Mã:** `agriculture_26` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lương thực <25. Mã điều kiện: `hungry`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:hunger`.
- **Việc khẩn:** nguyên nhân `hunger`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không can thiệp việc bán cày”.

**Nội dung tấu chương:**

> Nhiều hộ đem cày ra chợ đổi lấy gạo, vụ sau đang bị đánh đổi.

#### Phương án 1 — Cấp thóc giữ lại nông cụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc cứu các hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Không can thiệp việc bán cày [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_27"></a>
### 153. Làng bỏ bữa liên tiếp

- **Mã:** `agriculture_27` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lương thực <25. Mã điều kiện: `hungry`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:hunger`.
- **Việc khẩn:** nguyên nhân `hunger`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cắt khẩu phần chờ mùa gặt”.

**Nội dung tấu chương:**

> Quan huyện báo những bếp lửa không còn được nhóm, người dân bắt đầu rời làng.

#### Phương án 1 — Xuất kho chặn nạn đói

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay gạo từ các điền trang

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Cắt khẩu phần chờ mùa gặt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-justice_25"></a>
### 259. Dân đội đơn trước cửa thành

- **Mã:** `justice_25` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đơn nằm ngoài cửa thành”.

**Nội dung tấu chương:**

> Đám đông đòi xét quan bao che nhà giàu và nói sẽ không rời cổng nếu bị bỏ qua.

#### Phương án 1 — Đích thân mở phiên xét xử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Phạt tiền nhà giàu để giải tán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để đơn nằm ngoài cửa thành [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_26"></a>
### 260. Người bị bắt sau cuộc đòi gạo

- **Mã:** `justice_26` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa giải quyết người bị bắt”.

**Nội dung tấu chương:**

> Gia đình những người bị bắt tụ lại, xin phân biệt kẻ cướp với người đói.

#### Phương án 1 — Cứu trợ và khoan tội có điều kiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Xử nghiêm cả nhóm gây rối

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Chưa giải quyết người bị bắt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_27"></a>
### 261. Quan địa phương giấu đơn dân

- **Mã:** `justice_27` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Lòng dân <30. Mã điều kiện: `lowPeople`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:rebellion_warning`.
- **Việc khẩn:** nguyên nhân `rebellion_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Trả đoàn dân về chờ tiếp”.

**Nội dung tấu chương:**

> Một đoàn dân vượt cấp nói đơn đã bị giữ nhiều tháng, lòng tin sắp cạn.

#### Phương án 1 — Cấp phí điều tra việc giấu đơn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Quân sự. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Cho các bên hòa giải tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Trả đoàn dân về chờ tiếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-disasters_25"></a>
### 421. Nước tràn qua bãi dân cư

- **Mã:** `disasters_25` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Đang mùa Hạ và đê điều <40. Mã điều kiện: `flood`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:flood`.
- **Việc khẩn:** nguyên nhân `flood`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dân tự chờ nước rút”.

**Nội dung tấu chương:**

> Đê yếu không giữ nổi dòng nước, dân đang dồn lên nền cao chờ cứu.

#### Phương án 1 — Chi tiền cứu và gia cố bờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Đê điều +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +3 · đê điều +3

#### Phương án 2 — Xuất lương nhờ quân cứu người

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Quân lực −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +2 · quân lực -3

#### Phương án 3 — Để dân tự chờ nước rút [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Đê điều −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · đê điều -5

<a id="event-disasters_26"></a>
### 422. Dòng lũ đổi lối qua ruộng

- **Mã:** `disasters_26` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Đang mùa Hạ và đê điều <40. Mã điều kiện: `flood`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:flood`.
- **Việc khẩn:** nguyên nhân `flood`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa khôi phục ruộng sau lũ”.

**Nội dung tấu chương:**

> Nước tràn mở đường qua ruộng và mương, cần dựng lại trước khi mất thêm vụ.

#### Phương án 1 — Đầu tư khôi phục dòng nước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Lương thực +16; Đê điều +6.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −8; Lòng dân −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 50% thành công: lương thực +16 · đê điều +6. Thất bại: lương thực -8 · lòng dân -3. · Không giao ai: 50% thành công

#### Phương án 2 — Xuất lương cứu trước và vay nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥12 (xuất 12 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Nợ chi trả +15.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 12 lương thực · lòng dân +1 · nợ chi trả +15

#### Phương án 3 — Chưa khôi phục ruộng sau lũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −8; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -8 · lòng dân -4

<a id="event-disasters_27"></a>
### 423. Kho lương làng chìm trong lũ

- **Mã:** `disasters_27` · **Nhóm:** Khủng hoảng.
- **Điều kiện xuất hiện:** Đang mùa Hạ và đê điều <40. Mã điều kiện: `flood`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:flood`.
- **Việc khẩn:** nguyên nhân `flood`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cứu kho lương làng”.

**Nội dung tấu chương:**

> Một kho lương bị ngập, dân mất cả phần ăn lẫn hạt giống trong khi nước chưa rút.

#### Phương án 1 — Xuất lương tới vùng ngập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥30 (xuất 30 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 30 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Điều quân chia sức cứu dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Quân lực −4; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · quân lực -4 · uy quyền -2

#### Phương án 3 — Chưa cứu kho lương làng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −6; Lương thực −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -6 · lương thực -6

<a id="group-8"></a>
## Nhóm 8 — Sức khỏe

<a id="event-physician_warning"></a>
### 11. Lời can của ngự y

- **Mã:** `physician_warning` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Sức khỏe`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác lời khuyên”.

**Nội dung tấu chương:**

> Ngự y nhận thấy sắc mặt bệ hạ kém đi. Việc nước và những đêm dài đang để lại dấu vết.

#### Phương án 1 — Dành thời gian dưỡng sức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1

#### Phương án 2 — Dùng thuốc theo đơn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1

#### Phương án 3 — Gác lời khuyên [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +4

<a id="event-wine_gift"></a>
### 33. Bình rượu quý phương xa

- **Mã:** `wine_gift` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Sức khỏe`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Cất vào kho”.

**Nội dung tấu chương:**

> Rượu mới được tiến cung. Các cận thần mời vua thưởng thức sau một ngày nhiều công việc.

#### Phương án 1 — Mở tiệc thưởng rượu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng -3 · lần hưởng lạc +2

#### Phương án 2 — Cất vào kho [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Không đổi chỉ số ngay

<a id="event-sleepless"></a>
### 34. Ngọn đèn chưa tắt

- **Mã:** `sleepless` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Sức khỏe`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Gác bút dưỡng sức”.

**Nội dung tấu chương:**

> Tấu chương còn chất trên bàn. Nhà vua có thể làm tiếp, nhưng ngự y đã đợi ngoài cửa điện.

#### Phương án 1 — Xử lý nốt công việc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Khối lượng công việc trong mùa +2; Mệt mỏi +6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · work +2 · mệt mỏi +6

#### Phương án 2 — Gác bút dưỡng sức [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1

<a id="event-health_01"></a>
### 370. Cơn ho lúc buổi chầu

- **Mã:** `health_01` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cố làm việc dù còn ho”.

**Nội dung tấu chương:**

> Thái y nghe tiếng ho kéo dài và xin chữa sớm trước khi bệnh nặng hơn.

#### Phương án 1 — Chi tiền chữa theo toa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành một buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Cố làm việc dù còn ho [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_02"></a>
### 371. Đọc tấu đến mờ mắt

- **Mã:** `health_02` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nhịp làm việc cũ”.

**Nội dung tấu chương:**

> Nhiều buổi đọc tấu muộn khiến mắt vua khó tập trung, người hầu xin dừng việc.

#### Phương án 1 — Dành buổi nghỉ và giảm tải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố duyệt thêm tấu để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ nhịp làm việc cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_03"></a>
### 372. Bài thuốc mới từ phương xa

- **Mã:** `health_03` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không chữa bệnh tuần này”.

**Nội dung tấu chương:**

> Một thầy thuốc đề nghị liệu trình mới có triển vọng nhưng chưa chắc đáp ứng.

#### Phương án 1 — Chi tiền thử liệu trình có rủi ro

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng thuốc thường ổn định

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Không chữa bệnh tuần này [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_04"></a>
### 373. Đau bụng sau bữa tối

- **Mã:** `health_04` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục lịch dù còn đau”.

**Nội dung tấu chương:**

> Thái y nghi thức ăn không hợp và xin điều trị trước khi vua dự lễ dài.

#### Phương án 1 — Chi tiền điều trị theo toa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Tiếp tục lịch dù còn đau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_05"></a>
### 374. Bàn tay run khi ký chỉ

- **Mã:** `health_05` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lịch làm việc dày”.

**Nội dung tấu chương:**

> Vua đã ký quá nhiều văn bản, nét chữ run khiến người giữ ấn lo lắng.

#### Phương án 1 — Dành buổi nghỉ giảm tải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố ký hết để giữ uy quyền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ lịch làm việc dày [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_06"></a>
### 375. Chứng sốt tái diễn

- **Mã:** `health_06` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để cơn sốt tự qua”.

**Nội dung tấu chương:**

> Thuốc cũ chỉ đỡ tạm, thái y đề nghị một đợt chữa khác có xác suất thất bại.

#### Phương án 1 — Đầu tư liệu trình mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng phương thuốc thường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Để cơn sốt tự qua [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_07"></a>
### 376. Khàn tiếng giữa cuộc nghị

- **Mã:** `health_07` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục nghị dù còn khàn”.

**Nội dung tấu chương:**

> Vua khó nói rõ sau nhiều buổi nghị kéo dài, thái y khuyên chữa và tĩnh dưỡng.

#### Phương án 1 — Chi tiền chữa khàn tiếng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Nghỉ một buổi dưỡng sức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Tiếp tục nghị dù còn khàn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_08"></a>
### 377. Giấc ngủ đầy việc triều

- **Mã:** `health_08` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách làm việc hiện tại”.

**Nội dung tấu chương:**

> Người hầu nói vua thức nhiều lần vì nghĩ tới công việc, sáng dậy càng mệt.

#### Phương án 1 — Dành buổi nghỉ giảm áp lực

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố xử thêm việc để trấn an triều

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ cách làm việc hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_09"></a>
### 378. Thuốc bôi vết thương mới

- **Mã:** `health_09` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xử lý vết thương”.

**Nội dung tấu chương:**

> Thái y có thuốc mới giúp vết thương lành nhanh nhưng cơ địa có thể không hợp.

#### Phương án 1 — Chi tiền thử đợt thuốc mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng thuốc thường đã quen

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Không xử lý vết thương [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_10"></a>
### 379. Cơn đau đầu dưới đèn

- **Mã:** `health_10` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cố đọc tiếp dù đau”.

**Nội dung tấu chương:**

> Thái y thấy vua đau đầu khi đọc chữ nhỏ, xin chữa trước khi thành bệnh kéo dài.

#### Phương án 1 — Chi tiền điều trị sớm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Cố đọc tiếp dù đau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_11"></a>
### 380. Không còn ngon miệng

- **Mã:** `health_11` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục nhịp làm việc cũ”.

**Nội dung tấu chương:**

> Công việc dồn dập khiến bữa ăn của vua bị bỏ dở, thái y nói cần giảm tải.

#### Phương án 1 — Dành buổi nghỉ thật sự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố làm thêm để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Tiếp tục nhịp làm việc cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_12"></a>
### 381. Liệu trình phục hồi sau bệnh

- **Mã:** `health_12` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không dành thời gian chữa”.

**Nội dung tấu chương:**

> Thái y đề xuất phục hồi chuyên sâu nhưng cảnh báo có thể gây phản ứng ngược.

#### Phương án 1 — Chi tiền thử liệu trình phục hồi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng chế độ chữa thông thường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Không dành thời gian chữa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_13"></a>
### 382. Đau lưng sau ngày thiết triều

- **Mã:** `health_13` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chịu đau tiếp tục làm việc”.

**Nội dung tấu chương:**

> Ngồi lâu trong điện khiến vua đau lưng, thầy thuốc xin chữa trước buổi nghị tới.

#### Phương án 1 — Chi tiền chữa theo toa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Nghỉ một buổi dưỡng sức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Chịu đau tiếp tục làm việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_14"></a>
### 383. Tấu khẩn tới trong giờ ngủ

- **Mã:** `health_14` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lệ nhận tấu cả đêm”.

**Nội dung tấu chương:**

> Một chồng tấu không thật sự khẩn được đưa vào lúc vua vừa chợp mắt.

#### Phương án 1 — Giữ buổi nghỉ và giảm tải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Thức dậy xử thêm để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ lệ nhận tấu cả đêm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_15"></a>
### 384. Thuốc bổ gây tranh luận

- **Mã:** `health_15` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không theo toa nào”.

**Nội dung tấu chương:**

> Hai thái y bất đồng về một toa thuốc mới, vua phải chọn mức rủi ro chấp nhận.

#### Phương án 1 — Chi tiền thử toa mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng toa thông thường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Không theo toa nào [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_16"></a>
### 385. Vết phồng rộp sau chuyến đi

- **Mã:** `health_16` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục lịch dù vết đau”.

**Nội dung tấu chương:**

> Vết thương nhỏ bắt đầu viêm, thái y xin chữa trước khi lan rộng.

#### Phương án 1 — Chi tiền chữa vết viêm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Tiếp tục lịch dù vết đau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_17"></a>
### 386. Nhầm tên trong buổi chầu

- **Mã:** `health_17` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không giảm việc đang có”.

**Nội dung tấu chương:**

> Vua gọi nhầm người nhiều lần vì mệt, một nội quan xin giảm lịch ngay.

#### Phương án 1 — Dành buổi nghỉ hồi sức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố chầu tiếp để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Không giảm việc đang có [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_18"></a>
### 387. Thầy thuốc xin thử cách châm mới

- **Mã:** `health_18` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa chữa chứng đau”.

**Nội dung tấu chương:**

> Một phương pháp được đề nghị cho chứng đau kéo dài nhưng chưa chắc hiệu quả.

#### Phương án 1 — Chi tiền thử đợt chữa mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng cách chữa thông thường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Chưa chữa chứng đau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_19"></a>
### 388. Cảm lạnh sau buổi tế

- **Mã:** `health_19` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lịch dù đang rét”.

**Nội dung tấu chương:**

> Thái y thấy vua rét run sau lễ ngoài trời và xin chữa trước khi sốt.

#### Phương án 1 — Chi tiền điều trị cảm lạnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Nghỉ một buổi dưỡng sức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Giữ lịch dù đang rét [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_20"></a>
### 389. Những bữa cơm bên bàn tấu

- **Mã:** `health_20` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ thói quen làm việc liên tục”.

**Nội dung tấu chương:**

> Nhiều ngày vua vừa ăn vừa xử việc, nội quan lo không còn khoảng nghỉ.

#### Phương án 1 — Dành buổi nghỉ tách khỏi công việc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố xử thêm để giữ uy quyền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ thói quen làm việc liên tục [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_21"></a>
### 390. Dược liệu khó hợp thể trạng

- **Mã:** `health_21` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ việc chữa trị kỳ này”.

**Nội dung tấu chương:**

> Một thuốc quý có thể giúp phục hồi nhanh nhưng thái y cảnh báo phản ứng phụ.

#### Phương án 1 — Chi tiền thử có theo dõi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng thuốc thường ít biến động

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Bỏ việc chữa trị kỳ này [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_22"></a>
### 391. Cơn chóng mặt khi đứng dậy

- **Mã:** `health_22` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cố tiếp tục lịch triều”.

**Nội dung tấu chương:**

> Vua phải vịn bàn trong buổi chầu, thái y muốn điều trị ngay.

#### Phương án 1 — Chi tiền điều trị triệu chứng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Cố tiếp tục lịch triều [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_23"></a>
### 392. Đêm trực đọc quân báo

- **Mã:** `health_23` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không thay lịch nhận báo”.

**Nội dung tấu chương:**

> Quân báo nối nhau làm vua thức tới sáng, thị vệ xin dành buổi sau để nghỉ.

#### Phương án 1 — Dành buổi nghỉ giảm tải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Cố xử tiếp để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Không thay lịch nhận báo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_24"></a>
### 393. Đợt thuốc cần theo dõi dài ngày

- **Mã:** `health_24` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa dùng liệu trình nào”.

**Nội dung tấu chương:**

> Thái y đưa hai cách chữa, một cách có triển vọng cao hơn nhưng dễ phản ứng.

#### Phương án 1 — Đầu tư liệu trình có rủi ro

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Dùng thuốc thường trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Chưa dùng liệu trình nào [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="event-health_25"></a>
### 394. Mỏi ngực sau ngày nghị dài

- **Mã:** `health_25` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chịu mệt tiếp tục làm việc”.

**Nội dung tấu chương:**

> Thái y xin kiểm tra triệu chứng trước khi vua tiếp tục một buổi nghi lễ khác.

#### Phương án 1 — Chi tiền chữa theo toa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −5; Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · bệnh -5 · sức khỏe +1 · căng thẳng -1

#### Phương án 2 — Dành buổi nghỉ dưỡng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Mệt mỏi −3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · mệt mỏi -3 · căng thẳng +2

#### Phương án 3 — Chịu mệt tiếp tục làm việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · mệt mỏi +3

<a id="event-health_26"></a>
### 395. Một ngày không còn khoảng trống

- **Mã:** `health_26` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Căng thẳng >45 hoặc mệt mỏi >45. Mã điều kiện: `stressed`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguyên lịch chật kín”.

**Nội dung tấu chương:**

> Lịch triều kiến lấp cả giờ nghỉ, người hầu xin vua dành lại một buổi cho mình.

#### Phương án 1 — Giữ một buổi nghỉ thật sự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi −5; Căng thẳng −1; Số lần nghỉ trong mùa +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi -5 · căng thẳng -1 · lần nghỉ +1

#### Phương án 2 — Nhận thêm việc để giữ uy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Mệt mỏi +8; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · mệt mỏi +8 · căng thẳng +4

#### Phương án 3 — Giữ nguyên lịch chật kín [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Mệt mỏi +4; Căng thẳng +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** mệt mỏi +4 · căng thẳng +3

<a id="event-health_27"></a>
### 396. Đổi thuốc khi bệnh chưa dứt

- **Mã:** `health_27` · **Nhóm:** Sức khỏe.
- **Điều kiện xuất hiện:** Sức khỏe <65, hoặc bệnh >0, hoặc mệt mỏi >60. Mã điều kiện: `ill`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `health`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Dừng việc chữa bệnh”.

**Nội dung tấu chương:**

> Thái y đề nghị đổi liệu trình sau nhiều đợt bệnh, kết quả vẫn có thể xấu đi.

#### Phương án 1 — Chi tiền thử liệu trình khác

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh −1.
- **Người xử lý tùy chọn:** chuyên môn Y thuật. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Sức khỏe +3; Bệnh −5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Bệnh +5; Sức khỏe −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 60 · bệnh -1 · Cuối mùa chọn phương án: 50% thành công: sức khỏe +3 · bệnh -5. Thất bại: bệnh +5 · sức khỏe -2. · Không giao ai: 50% thành công

#### Phương án 2 — Tiếp tục thuốc thông thường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Sức khỏe +1; Căng thẳng −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 40 · sức khỏe +1 · căng thẳng -1

#### Phương án 3 — Dừng việc chữa bệnh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Bệnh +3; Sức khỏe −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** bệnh +3 · sức khỏe -1

<a id="group-9"></a>
## Nhóm 9 — Ngoại giao

<a id="event-silk_route"></a>
### 12. Đoàn buôn từ phương Nam

- **Mã:** `silk_route` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngoại giao`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguyên quy định”.

**Nội dung tấu chương:**

> Thương nhân xin phép mở tuyến giao thương. Họ cần bảo đảm an toàn và một khoản hỗ trợ ban đầu.

#### Phương án 1 — Bảo trợ tuyến buôn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả công việc riêng:** cuối mùa sau nữa (sau 2 mùa). Nhận doanh thu ngẫu nhiên 70–95 tiền vào ngân khố. Đây là doanh thu, chưa trừ chi phí đã bỏ ra; không có nhánh thất bại riêng.
- **Mô tả lựa chọn trên UI:** Chi 60 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa sau nữa (sau 2 mùa): Doanh thu 70–95 tiền, chưa trừ vốn đã chi · Vốn/phí ứng 60 tiền · nhận 70–95 tiền, lãi sau vốn 10–35 tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa)

#### Phương án 2 — Thu phí qua cửa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ nguyên quy định [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Không đổi chỉ số ngay

<a id="event-foreign_tribute"></a>
### 24. Lễ vật từ nước láng giềng

- **Mã:** `foreign_tribute` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Ngoại giao`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Nhận lễ theo nghi thức”.

**Nội dung tấu chương:**

> Sứ thần mang lễ vật và lời mời hữu hảo. Tiếp đãi trọng thể có thể mở đường cho thương mại.

#### Phương án 1 — Tiếp đãi và mở thương lộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả công việc riêng:** cuối mùa sau nữa (sau 2 mùa). Nhận doanh thu ngẫu nhiên 70–95 tiền vào ngân khố. Đây là doanh thu, chưa trừ chi phí đã bỏ ra; không có nhánh thất bại riêng.
- **Mô tả lựa chọn trên UI:** Chi 30 · Không đổi chỉ số ngay · Nhận kết quả cuối mùa sau nữa (sau 2 mùa): Doanh thu 70–95 tiền, chưa trừ vốn đã chi · Vốn/phí ứng 30 tiền · nhận 70–95 tiền, lãi sau vốn 40–65 tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa)

#### Phương án 2 — Nhận lễ theo nghi thức [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · căng thẳng +2 · Tiền nhận ngay 25 · sau phí +25.

<a id="event-peace_offer"></a>
### 26. Một lá thư cầu hòa

- **Mã:** `peace_offer` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Ngoại giao`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Tiếp tục giữ biên giới”.

**Nội dung tấu chương:**

> Đối phương sẵn sàng dừng binh nếu triều đình nhượng bộ. Đại tướng cho rằng vẫn còn cơ hội chiến thắng.

#### Phương án 1 — Chi tiền đổi hòa bình

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥95 (chi 95 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Chấm dứt chiến tranh và giải vây: áp lực chiến tranh =0, bao vây =0; Uy quyền −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 95 · uy quyền -4 · Chấm dứt chiến tranh và giải vây

#### Phương án 2 — Tiếp tục giữ biên giới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +1; Căng thẳng +5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +1 · căng thẳng +5

<a id="event-diplomacy_01"></a>
### 208. Sứ đoàn bị giữ ở cửa ải

- **Mã:** `diplomacy_01` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa trả lời công hàm”.

**Nội dung tấu chương:**

> Nước láng giềng giữ đoàn sứ vì bất đồng giấy thông hành, đòi một lời giải thích.

#### Phương án 1 — Gửi đoàn thương lượng giải vây

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Dọa đưa quân tới cửa ải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Chưa trả lời công hàm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_02"></a>
### 209. Bến chung bên sông giới

- **Mã:** `diplomacy_02` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đóng đề nghị mở bến”.

**Nội dung tấu chương:**

> Thương nhân hai nước muốn góp vốn lập bến chung nhưng chưa rõ quyền thu phí.

#### Phương án 1 — Thử bến chung có kiểm toán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu phí cao với thuyền ngoại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Đóng đề nghị mở bến [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_03"></a>
### 210. Mốc đá bị dời trong đêm

- **Mã:** `diplomacy_03` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các đồn tự xử”.

**Nội dung tấu chương:**

> Dân biên báo một mốc đá đổi chỗ, lính hai phía đã đứng đối diện nhau.

#### Phương án 1 — Mời chứng nhân xác định mốc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Điều quân chiếm lại bãi đất

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để các đồn tự xử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_04"></a>
### 211. Lời đề nghị ngừng bắn ngắn

- **Mã:** `diplomacy_04` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không phản hồi đề nghị”.

**Nội dung tấu chương:**

> Đối phương xin ngừng bắn để thu xác, tướng trong triều nghi đó là kế hoãn binh.

#### Phương án 1 — Cử sứ kiểm chứng thỏa thuận

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Đáp bằng tối hậu thư

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Không phản hồi đề nghị [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_05"></a>
### 212. Đường buôn qua cao nguyên

- **Mã:** `diplomacy_05` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở đường buôn mới”.

**Nội dung tấu chương:**

> Một nước nhỏ cho mở đường qua núi nếu triều đình cùng gánh phí trạm.

#### Phương án 1 — Góp vốn thử tuyến đường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Đánh thuế hàng qua tuyến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chưa mở đường buôn mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_06"></a>
### 213. Ngư dân vượt đường nước

- **Mã:** `diplomacy_06` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để tranh chấp kéo dài”.

**Nội dung tấu chương:**

> Hai bên cùng bắt ngư dân của nhau ở khúc sông chưa phân định.

#### Phương án 1 — Bảo lãnh và lập vùng đánh cá

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Tăng quân tuần sông

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để tranh chấp kéo dài [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_07"></a>
### 214. Quà ngoại giao bị hiểu lầm

- **Mã:** `diplomacy_07` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua thư phản đối”.

**Nội dung tấu chương:**

> Lễ vật mang hình thú bị một triều đình xem là lời mỉa mai, sứ giả xin chỉ dụ.

#### Phương án 1 — Cử người giải thích dụng ý

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Khẳng định họ phải nhận quà

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Bỏ qua thư phản đối [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_08"></a>
### 215. Xưởng nhuộm của khách ngoại

- **Mã:** `diplomacy_08` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tiếp lời mời hợp tác”.

**Nội dung tấu chương:**

> Thợ ngoại xin cùng mở xưởng và truyền nghề nếu được bảo vệ vốn ban đầu.

#### Phương án 1 — Góp vốn xưởng thử nghiệm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu phí đặc quyền nhập nghề

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Không tiếp lời mời hợp tác [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_09"></a>
### 216. Đoàn hộ tống đi lạc

- **Mã:** `diplomacy_09` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng tự thương lượng”.

**Nội dung tấu chương:**

> Lính hộ tống nước bạn đi qua làng biên giới khiến dân địa phương sợ hãi.

#### Phương án 1 — Thỏa thuận lối đi và bồi hoàn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Đặt quân chặn các lối mòn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để làng tự thương lượng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_10"></a>
### 217. Tin đổi tù binh

- **Mã:** `diplomacy_10` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác việc đổi tù binh”.

**Nội dung tấu chương:**

> Đối phương gửi danh sách đổi tù nhưng nhiều tên chưa được xác nhận còn sống.

#### Phương án 1 — Chi phí xác minh và đàm phán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Đòi trao người ngay lập tức

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Gác việc đổi tù binh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_11"></a>
### 218. Hội chợ mùa lạnh

- **Mã:** `diplomacy_11` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không dự hội chợ năm nay”.

**Nội dung tấu chương:**

> Nước bạn mời góp phần tổ chức hội chợ chung trước mùa đường núi đóng tuyết.

#### Phương án 1 — Góp vốn gian hàng và vận tải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu phụ phí hàng nhập hội chợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Không dự hội chợ năm nay [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_12"></a>
### 219. Khách tị nạn bên cột mốc

- **Mã:** `diplomacy_12` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để họ chờ ngoài biên giới”.

**Nội dung tấu chương:**

> Một nhóm dân xin qua biên, bên kia đòi trả người mà chưa nêu chứng cứ.

#### Phương án 1 — Bảo đảm an toàn và xét hồ sơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Tăng quân ở trạm biên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để họ chờ ngoài biên giới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_13"></a>
### 220. Tranh thứ bậc trong quốc thư

- **Mã:** `diplomacy_13` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa gửi lại quốc thư”.

**Nội dung tấu chương:**

> Hai nước bất đồng cách xưng hô, chuyến sứ sắp bị hủy vì một hàng chữ.

#### Phương án 1 — Cử người tìm thể thức chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Giữ lời lẽ cứng rắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Chưa gửi lại quốc thư [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_14"></a>
### 221. Kho chuyển hàng đường biển

- **Mã:** `diplomacy_14` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ đề nghị kho chuyển hàng”.

**Nội dung tấu chương:**

> Một hải cảng ngoại đề nghị dành kho cho hàng của triều đình nếu cùng đầu tư.

#### Phương án 1 — Góp tiền thử kho chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Đánh thuế cao hàng cảng ngoại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Bỏ đề nghị kho chuyển hàng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_15"></a>
### 222. Kẻ truy đuổi qua biên

- **Mã:** `diplomacy_15` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa nêu ý kiến chính thức”.

**Nội dung tấu chương:**

> Lính láng giềng vượt ranh giới đuổi cướp và làm dân làng hoảng loạn.

#### Phương án 1 — Ký quy tắc truy bắt có bảo chứng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Tăng quân chặn biên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Chưa nêu ý kiến chính thức [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_16"></a>
### 223. Sứ thần mắc nợ nhà trọ

- **Mã:** `diplomacy_16` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Mặc đoàn sứ tự giải quyết”.

**Nội dung tấu chương:**

> Đoàn sứ bị chủ trọ giữ hành lý, tin đồn tổn hại thể diện hai triều.

#### Phương án 1 — Cử người dàn xếp khoản nợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Đòi thả hành lý bằng uy thế

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Mặc đoàn sứ tự giải quyết [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_17"></a>
### 224. Giống vật nuôi trao đổi

- **Mã:** `diplomacy_17` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa tham gia trao đổi”.

**Nội dung tấu chương:**

> Nước bên kia muốn đổi đàn giống lấy quyền phân phối sản vật tại một trạm.

#### Phương án 1 — Đầu tư thí điểm trao đổi giống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu phí ngay từ thương lái ngoại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chưa tham gia trao đổi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_18"></a>
### 225. Đền cổ nằm giữa hai nước

- **Mã:** `diplomacy_18` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để xung đột tự lắng xuống”.

**Nội dung tấu chương:**

> Khách hành hương hai phía tranh quyền vào đền khi lính địa phương thu phí.

#### Phương án 1 — Bảo chứng quyền đi lại chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Tăng đồn kiểm soát quanh đền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để xung đột tự lắng xuống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_19"></a>
### 226. Đồng minh xin xác nhận lời hứa

- **Mã:** `diplomacy_19` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa trả lời đồng minh”.

**Nội dung tấu chương:**

> Một nước từng hứa hỗ trợ nay yêu cầu đàm phán lại điều kiện xuất quân.

#### Phương án 1 — Gửi sứ thương lượng điều kiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Dùng lời đe dọa ép thực hiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Chưa trả lời đồng minh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_20"></a>
### 227. Trạm đổi tiền cho khách ngoại

- **Mã:** `diplomacy_20` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách đổi tiền tự phát”.

**Nội dung tấu chương:**

> Thương khách muốn mở trạm đổi tiền có vốn triều đình để giảm giả mạo.

#### Phương án 1 — Góp vốn thử trạm đổi tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Đánh phụ thu tiền ngoại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Giữ cách đổi tiền tự phát [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_21"></a>
### 228. Công chúa nước bạn quá cảnh

- **Mã:** `diplomacy_21` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đoàn chờ chỉ dụ khác”.

**Nội dung tấu chương:**

> Đoàn quý tộc xin quá cảnh đúng tuyến quân sự, hai bên nghi ngờ nhau.

#### Phương án 1 — Trả phí bảo đảm tuyến riêng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Tăng quân giữ toàn tuyến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để đoàn chờ chỉ dụ khác [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_22"></a>
### 229. Đòi trả tấm bản đồ cũ

- **Mã:** `diplomacy_22` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đáp thư đòi bản đồ”.

**Nội dung tấu chương:**

> Một triều đình nói bản đồ trong thư viện là tài sản của họ và đòi trả lại.

#### Phương án 1 — Đàm phán quyền sao chép chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tuyên bố giữ bằng mọi giá

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Không đáp thư đòi bản đồ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_23"></a>
### 230. Hiệp hội thuyền buôn liên quốc

- **Mã:** `diplomacy_23` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tham gia quỹ liên quốc”.

**Nội dung tấu chương:**

> Các chủ thuyền muốn lập quỹ cứu nạn chung đổi lấy quyền cập bến thuận tiện.

#### Phương án 1 — Góp vốn thí điểm quỹ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu phí bảo hộ cao hơn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Không tham gia quỹ liên quốc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_24"></a>
### 231. Lễ tế trên đỉnh núi giới

- **Mã:** `diplomacy_24` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để mỗi bên tự lên núi”.

**Nội dung tấu chương:**

> Hai bên cùng định tế lễ tại một đỉnh núi, đội hộ vệ có nguy cơ đụng độ.

#### Phương án 1 — Bảo chứng lịch lễ luân phiên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Đưa quân giữ đỉnh núi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Để mỗi bên tự lên núi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="event-diplomacy_25"></a>
### 232. Tin đồn nước bạn chuẩn bị chiến

- **Mã:** `diplomacy_25` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa điều tra tin đồn”.

**Nội dung tấu chương:**

> Thương khách báo giá sắt tăng bên kia biên, quan ngoại giao xin thăm dò kín.

#### Phương án 1 — Gửi sứ kiểm chứng tin đồn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥35 (chi 35 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối cùng mùa năm sau (sau 4 mùa): Áp lực chiến tranh −1; Ngân khố +11.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Áp lực chiến tranh +1; Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 35 · uy quyền +1 · Cuối cùng mùa năm sau (sau 4 mùa): 50% thành công: áp lực chiến tranh -1 · ngân khố +11. Thất bại: áp lực chiến tranh +1 · uy quyền -3. · Vốn/phí ứng 35 tiền · Thành công: nhận 11 tiền, lãi sau vốn -24 tiền · Thất bại: mất 35 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối cùng mùa năm sau (sau 4 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Công khai cảnh cáo nước bạn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Quân lực −3; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · quân lực -3 · áp lực chiến tranh +1

#### Phương án 3 — Chưa điều tra tin đồn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Áp lực chiến tranh +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · áp lực chiến tranh +1

<a id="event-diplomacy_26"></a>
### 233. Thợ đóng tàu muốn hợp tác

- **Mã:** `diplomacy_26` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Từ chối dự án hợp tác”.

**Nội dung tấu chương:**

> Một đoàn thợ ngoại mang bản vẽ mới nhưng cần vốn để đóng chiếc đầu tiên.

#### Phương án 1 — Cùng đầu tư tàu thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Ngoại giao. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Thái độ phe Thế gia +1.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 45% thành công: ngân khố +70 · phe Thế gia +1. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu tiền quyền vào xưởng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · áp lực chiến tranh +1 · phe Võ tướng +1 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Từ chối dự án hợp tác [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -8

<a id="event-diplomacy_27"></a>
### 234. Bảo đảm cho hành lang cứu trợ

- **Mã:** `diplomacy_27` · **Nhóm:** Ngoại giao.
- **Điều kiện xuất hiện:** Đang có chiến tranh: áp lực chiến tranh >0. Mã điều kiện: `war`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `diplomacy`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đình lại hành lang cứu trợ”.

**Nội dung tấu chương:**

> Hai bên đều muốn chở lương qua chiến tuyến nhưng chưa tin lời hứa của nhau.

#### Phương án 1 — Chi tiền lập bảo chứng chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh −1; Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · áp lực chiến tranh -1 · uy quyền +1

#### Phương án 2 — Điều quân giữ hành lang riêng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +3; Áp lực chiến tranh +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực +3 · áp lực chiến tranh +1 · phe Võ tướng +1

#### Phương án 3 — Đình lại hành lang cứu trợ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Áp lực chiến tranh +1; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** áp lực chiến tranh +1 · Ổn định triều đình -2

<a id="group-10"></a>
## Nhóm 10 — Hậu cung

<a id="event-royal_wedding"></a>
### 21. Lời đề nghị kết thân

- **Mã:** `royal_wedding` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Hậu cung`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Chưa bàn chuyện kết thân”.

**Nội dung tấu chương:**

> Một gia tộc muốn đưa người vào cung. Sự kết thân có thể đem lại ủng hộ, đồng thời làm các nhà khác dè chừng.

#### Phương án 1 — Cho tiến cử người mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Thêm 2 ứng viên hậu cung trưởng thành vào danh sách tú nữ (chưa nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng +2 · Thêm ứng viên hậu cung vào danh sách tiến cử

#### Phương án 2 — Chưa bàn chuyện kết thân [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Không có thay đổi chỉ số trực tiếp.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Không đổi chỉ số ngay

<a id="event-harem_rivalry"></a>
### 22. Hai chén trà lạnh

- **Mã:** `harem_rivalry` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất hai người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `harem`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Hậu cung`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không can dự”.

**Nội dung tấu chương:**

> Lời qua tiếng lại trong hậu cung đã tới tai các quan. Một cuộc tranh sủng đang biến thành chuyện gia tộc.

#### Phương án 1 — Đích thân hòa giải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +3 · căng thẳng +2

#### Phương án 2 — Ban quà xoa dịu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +1

#### Phương án 3 — Không can dự [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −8.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -8

<a id="event-queen_charity"></a>
### 23. Lời thỉnh cầu từ nội cung

- **Mã:** `queen_charity` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất hai người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `harem`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Hậu cung`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Đợi khi ngân khố khá hơn”.

**Nội dung tấu chương:**

> Nội cung muốn trích kinh phí may áo cho dân nghèo. Các gia tộc cũng đang chờ xem thái độ của vua.

#### Phương án 1 — Chuẩn tấu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · lòng dân +3 · Ổn định triều đình +1

#### Phương án 2 — Đợi khi ngân khố khá hơn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-consort_recommendation"></a>
### 45. Người mới trước cửa cung

- **Mã:** `consort_recommendation` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Từ mùa thứ 2 của lượt trị vì trở đi. Mã điều kiện: `recruitment`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 2 (mùa Hạ · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Hậu cung`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 2 — “Khước từ tiến cử”.

**Nội dung tấu chương:**

> Các gia tộc tiến cử {candidate}. Bệ hạ có muốn nhận làm tú nữ (chưa nhập cung)? Sự ưu ái cũng sẽ khiến phe đối lập dè chừng.

#### Phương án 1 — Nhận làm tú nữ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền); ứng viên gắn với tấu chương còn hoạt động, thuộc nhóm tú nữ, đủ 18 tuổi và chưa nhập cung.
- **Tác động ngay — lợi ích và đánh đổi:** Nhận ứng viên làm tú nữ (chưa nhập cung); thái độ phe ứng viên +3, phe đối lập −5. Chưa phát sinh chi sinh hoạt hậu cung; cần tuyển riêng vào cung để trở thành phi tần.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · Nhận ứng viên làm tú nữ (chưa nhập cung) · cùng phe +3, phe đối lập −5

#### Phương án 2 — Khước từ tiến cử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe đối lập +3, phe ứng viên −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Phe đối lập +3, cùng phe −5

<a id="event-palace_01"></a>
### 343. Kho vải nội cung thiếu sổ

- **Mã:** `palace_01` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kho tự chia tiếp”.

**Nội dung tấu chương:**

> Đồ dùng trong cung cấp không đều vì kho vải thiếu bản phân bổ rõ ràng.

#### Phương án 1 — Cấp tiền sửa phân bổ đồ dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt chi và thu hồi vật dụng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để kho tự chia tiếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_02"></a>
### 344. Tranh lượt dùng vườn ngự

- **Mã:** `palace_02` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các bên tự tranh lượt”.

**Nội dung tấu chương:**

> Các phi tần cùng xin dùng vườn trong một buổi, gia đình họ bắt đầu can thiệp.

#### Phương án 1 — Tự áp lịch chung công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên người có thế gia chống lưng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để các bên tự tranh lượt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_03"></a>
### 345. Một buổi nghe nhạc trong cung

- **Mã:** `palace_03` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nhịp làm việc hiện tại”.

**Nội dung tấu chương:**

> Nội quan xin mở buổi nhạc nhỏ để vua bớt căng thẳng sau nhiều buổi chầu.

#### Phương án 1 — Chi cho buổi nhạc ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Dành buổi ấy nghỉ yên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Giữ nhịp làm việc hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_04"></a>
### 346. Nhà ở của người hầu dột mái

- **Mã:** `palace_04` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa khu ở người hầu”.

**Nội dung tấu chương:**

> Nội quan nói người hầu thiếu chỗ ngủ khô nhưng khoản sửa chưa được duyệt.

#### Phương án 1 — Cấp tiền sửa khu ở trong cung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt chi và gom người vào phòng chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa sửa khu ở người hầu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_05"></a>
### 347. Quà biếu ngoài sổ cho phi tần

- **Mã:** `palace_05` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xét chuyện quà ngoài sổ”.

**Nội dung tấu chương:**

> Một gia đình gửi quà riêng khiến các phi tần khác nghi ngờ có trao đổi quyền lợi.

#### Phương án 1 — Tự áp phép quà biếu chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Thuận ý gia đình thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Không xét chuyện quà ngoài sổ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_06"></a>
### 348. Lời mời xem trò múa mới

- **Mã:** `palace_06` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục chịu áp lực công việc”.

**Nội dung tấu chương:**

> Một đoàn diễn muốn biểu diễn riêng cho vua, nội quan xin quyết định quy mô.

#### Phương án 1 — Chi cho một buổi diễn ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Từ chối để nghỉ tĩnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Tiếp tục chịu áp lực công việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_07"></a>
### 349. Đèn trong nội điện tốn dầu

- **Mã:** `palace_07` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để nội cung tự xoay dầu”.

**Nội dung tấu chương:**

> Người quản cung muốn đổi cách chiếu sáng nhưng cần chi phí ban đầu.

#### Phương án 1 — Cấp tiền sắp lại đèn trong điện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Thu hồi bớt dầu và đồ dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để nội cung tự xoay dầu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_08"></a>
### 350. Cung nữ bị hai viện cùng gọi

- **Mã:** `palace_08` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai viện tự chia người”.

**Nội dung tấu chương:**

> Hai viện cùng đòi một nhóm cung nữ, người trong cung sợ phe mạnh lấn phe yếu.

#### Phương án 1 — Tự đặt quy tắc phân người

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên viện có thế gia bảo trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để hai viện tự chia người [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_09"></a>
### 351. Dạo thuyền trong hồ ngự

- **Mã:** `palace_09` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đổi lịch sinh hoạt”.

**Nội dung tấu chương:**

> Nội quan mời vua rời điện một buổi, nhưng cảnh báo vui quá sẽ khó nghỉ đúng giờ.

#### Phương án 1 — Chi cho chuyến dạo ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Dành thời gian ngủ nghỉ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Không đổi lịch sinh hoạt [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_10"></a>
### 352. Khẩu phần trong cung bị cắt nhầm

- **Mã:** `palace_10` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa rà lại khẩu phần”.

**Nội dung tấu chương:**

> Một số phòng bị thiếu phần ăn trong khi nơi khác nhận gấp đôi.

#### Phương án 1 — Cấp tiền sửa việc phân bổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt tổng chi và thu hồi phần dư

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa rà lại khẩu phần [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_11"></a>
### 353. Gia đình phi tần xin vào điện riêng

- **Mã:** `palace_11` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để lời xin đi qua cửa riêng”.

**Nội dung tấu chương:**

> Một nhà muốn vào thăm ngoài giờ quy định khiến các viện khác phản đối.

#### Phương án 1 — Tự áp giờ thăm công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên nhà thế gia ấy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để lời xin đi qua cửa riêng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_12"></a>
### 354. Cuộc thi làm thơ đêm

- **Mã:** `palace_12` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ sức ép trong điện”.

**Nội dung tấu chương:**

> Nội quan đề nghị một đêm vui thơ để giải khuây, nhưng vua có thể mất giờ ngủ.

#### Phương án 1 — Chi cho cuộc vui có giới hạn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Rút lui nghỉ tĩnh một buổi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Giữ sức ép trong điện [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_13"></a>
### 355. Rèm ngự điện cần thay

- **Mã:** `palace_13` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để rèm cũ qua mùa”.

**Nội dung tấu chương:**

> Rèm cũ che gió kém, người quản cung xin thay nhưng nhiều khoản chi đang chờ.

#### Phương án 1 — Cấp tiền thay rèm hợp lý

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt đồ dùng để bù khoản thiếu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để rèm cũ qua mùa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_14"></a>
### 356. Chỗ ngồi trong yến nhỏ

- **Mã:** `palace_14` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các bên tự xếp chỗ”.

**Nội dung tấu chương:**

> Các phi tần tranh thứ tự chỗ ngồi và nhờ quan ngoài triều lên tiếng.

#### Phương án 1 — Tự áp nghi thức chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên phía có thế gia mạnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để các bên tự xếp chỗ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_15"></a>
### 357. Trò chơi cờ kéo dài

- **Mã:** `palace_15` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không giải tỏa căng thẳng”.

**Nội dung tấu chương:**

> Một ván cờ trong cung được đề nghị làm dịp giải khuây sau buổi chầu.

#### Phương án 1 — Chi cho cuộc chơi ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Dừng chơi để nghỉ tĩnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Không giải tỏa căng thẳng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_16"></a>
### 358. Người hầu xin áo mùa lạnh

- **Mã:** `palace_16` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp áo mùa lạnh”.

**Nội dung tấu chương:**

> Đồ mùa lạnh phát thiếu, hoàng tộc nói để người trong cung rét là mất thể diện.

#### Phương án 1 — Cấp tiền bổ sung áo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Thu hồi bớt đồ để tiết kiệm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa cấp áo mùa lạnh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_17"></a>
### 359. Tin đồn thiên vị người mới

- **Mã:** `palace_17` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua lời bất bình”.

**Nội dung tấu chương:**

> Một phi tần mới được cấp đồ khác lệ khiến các viện còn lại bất bình.

#### Phương án 1 — Tự xét theo quy tắc công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên phía thế gia hậu thuẫn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Bỏ qua lời bất bình [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_18"></a>
### 360. Buổi xem hoa sau cơn mưa

- **Mã:** `palace_18` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục lịch căng thẳng”.

**Nội dung tấu chương:**

> Nội quan mời vua ngắm hoa, nhắc rằng vui có chừng mực mới giúp hồi sức.

#### Phương án 1 — Chi cho buổi xem hoa ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Dành buổi ấy để nghỉ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Tiếp tục lịch căng thẳng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_19"></a>
### 361. Sổ vật dụng hồi môn lẫn lộn

- **Mã:** `palace_19` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ kho theo sổ lẫn lộn”.

**Nội dung tấu chương:**

> Đồ riêng và đồ triều đình bị ghi chung khiến người quản cung khó phân bổ.

#### Phương án 1 — Cấp tiền rà và sắp kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt chi thu hồi đồ đang dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Giữ kho theo sổ lẫn lộn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_20"></a>
### 362. Thư riêng nhờ can thiệp chức vụ

- **Mã:** `palace_20` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để thư riêng không có trả lời rõ”.

**Nội dung tấu chương:**

> Gia đình một phi tần gửi thư nhờ ưu tiên người nhà, các viện đã nghe chuyện.

#### Phương án 1 — Tự áp phép không thiên vị

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Thuận đề nghị của thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để thư riêng không có trả lời rõ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_21"></a>
### 363. Rượu quý dành riêng cho vua

- **Mã:** `palace_21` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lịch làm việc căng”.

**Nội dung tấu chương:**

> Một vò rượu mới được dâng, nội quan xin mở tiệc nhỏ ngay trong mùa.

#### Phương án 1 — Chi cho cuộc vui có giới hạn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Cất rượu để nghỉ yên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Giữ lịch làm việc căng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_22"></a>
### 364. Nội điện thiếu người lo việc chung

- **Mã:** `palace_22` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các phòng tự xoay xở”.

**Nội dung tấu chương:**

> Các phòng cùng thiếu vật dụng, quản sự xin một khoản để ổn định sinh hoạt.

#### Phương án 1 — Cấp tiền sắp lại việc nội điện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt chi và gom đồ dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để các phòng tự xoay xở [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_23"></a>
### 365. Tranh quyền chăm sóc lễ phục

- **Mã:** `palace_23` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để tranh chấp tiếp tục”.

**Nội dung tấu chương:**

> Hai viện muốn đảm nhiệm lễ phục của vua và gọi người nhà ngoài triều trợ lực.

#### Phương án 1 — Tự phân xử bằng quy tắc chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Trao ưu tiên cho thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để tranh chấp tiếp tục [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_24"></a>
### 366. Lời mời dự yến của phi tần

- **Mã:** `palace_24` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đổi lịch căng thẳng”.

**Nội dung tấu chương:**

> Một phi tần muốn tổ chức yến để vua giải sầu, trong khi lịch nghỉ đã thiếu.

#### Phương án 1 — Chi cho một buổi yến ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Xin dành thời gian nghỉ tĩnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Không đổi lịch căng thẳng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="event-palace_25"></a>
### 367. Kho hương trong cung phát thiếu

- **Mã:** `palace_25` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kho tiếp tục chia thiếu”.

**Nội dung tấu chương:**

> Các phòng nhận lượng hương rất khác nhau, người quản kho xin ổn định lại việc cấp.

#### Phương án 1 — Cấp tiền chỉnh kho và phân bổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng −1; Thái độ phe Hoàng tộc +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +2 · căng thẳng -1 · phe Hoàng tộc +1

#### Phương án 2 — Cắt chi thu hồi đồ dùng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để kho tiếp tục chia thiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2 · căng thẳng +2

<a id="event-palace_26"></a>
### 368. Tranh quyền chọn người dạy lễ

- **Mã:** `palace_26` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Có ít nhất một người đã nhập hậu cung và còn hoạt động. Mã điều kiện: `hasConsort`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các viện tự tranh người dạy”.

**Nội dung tấu chương:**

> Các phi tần muốn mời người quen vào dạy lễ, quan ngoài triều bắt đầu vận động.

#### Phương án 1 — Tự áp tiêu chuẩn công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền +1; Thiện cảm của người còn hoạt động thuộc phe Văn thần +1 (hậu cung chỉ tính người đã nhập cung); Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền +1 · thiện cảm phe Văn thần +1 · căng thẳng +2

#### Phương án 2 — Ưu tiên người do thế gia giới thiệu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Thái độ phe Thế gia +3; Thái độ phe Văn thần −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** phe Thế gia +3 · phe Văn thần -4 · Ổn định triều đình -2

#### Phương án 3 — Để các viện tự tranh người dạy [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Thiện cảm của người còn hoạt động thuộc phe Hoàng tộc −2 (hậu cung chỉ tính người đã nhập cung).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · thiện cảm phe Hoàng tộc -2

<a id="event-palace_27"></a>
### 369. Tiếng sáo bên hồ ngự

- **Mã:** `palace_27` · **Nhóm:** Hậu cung.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `palace`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục lịch căng thẳng”.

**Nội dung tấu chương:**

> Một nghệ nhân xin tấu sáo cho vua giải khuây, nội quan nhắc nên giữ giờ nghỉ.

#### Phương án 1 — Chi cho một buổi nghe ngắn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng −3; Số lần hưởng lạc trong mùa +1; Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · căng thẳng -3 · lần hưởng lạc +1 · Ổn định triều đình +1

#### Phương án 2 — Dành buổi ấy nghỉ tĩnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Số lần nghỉ trong mùa +1; Thái độ phe Hoàng tộc −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lần nghỉ +1 · phe Hoàng tộc -2

#### Phương án 3 — Tiếp tục lịch căng thẳng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Căng thẳng +3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** căng thẳng +3 · Ổn định triều đình -1

<a id="group-11"></a>
## Nhóm 11 — Âm mưu

<a id="event-plot_warning"></a>
### 42. Dấu chân ngoài điện vắng

- **Mã:** `plot_warning` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 1 mùa. Nhóm nội dung: `Âm mưu`.
- **Việc khẩn:** nguyên nhân `plot_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa ra tay”.

**Nội dung tấu chương:**

> Mật thám phát hiện những cuộc gặp kín và việc điều chuyển người bất thường. Một âm mưu đang tới gần.

#### Phương án 1 — Tăng bảo vệ, điều tra gấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥120 (chi 120 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Uy quyền +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 120 · âm mưu -4 · uy quyền +1

#### Phương án 2 — Triệu các phe đối thoại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Uy quyền −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · uy quyền -5

#### Phương án 3 — Chưa ra tay [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -5

<a id="event-succession_rumor"></a>
### 44. Lời bàn về ngai vàng

- **Mã:** `succession_rumor` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Uy quyền <35. Mã điều kiện: `weakAuthority`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `Âm mưu`.
- **Việc khẩn:** nguyên nhân `succession_rumor`; cooldown chung 2 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Phớt lờ lời đồn”.

**Nội dung tấu chương:**

> Những lời bàn về người có thể thay vua xuất hiện trong giới quyền quý. Uy tín của triều đình đang bị thử thách.

#### Phương án 1 — Củng cố chính danh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +5; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +5 · âm mưu -4

#### Phương án 2 — Đối thoại với hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Căng thẳng +4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · căng thẳng +4

#### Phương án 3 — Phớt lờ lời đồn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −6.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -6

<a id="event-factions_25"></a>
### 313. Chiếu nhường quyền được viết sẵn

- **Mã:** `factions_25` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Uy quyền <35. Mã điều kiện: `weakAuthority`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:succession_rumor`.
- **Việc khẩn:** nguyên nhân `succession_rumor`; cooldown chung 2 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đụng tới bản chiếu”.

**Nội dung tấu chương:**

> Một bản chiếu chưa có ấn vua đã xuất hiện trong các cuộc họp kín.

#### Phương án 1 — Chi phí xác minh và bác chiếu giả

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhượng quyền nội triều để dàn xếp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không đụng tới bản chiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_26"></a>
### 314. Thân vương mở buổi nhận lời chúc

- **Mã:** `factions_26` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Uy quyền <35. Mã điều kiện: `weakAuthority`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:succession_rumor`.
- **Việc khẩn:** nguyên nhân `succession_rumor`; cooldown chung 2 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để nghi lễ tiếp tục diễn ra”.

**Nội dung tấu chương:**

> Một thân vương cho mở nghi lễ gần giống lễ đăng cơ, khiến quan lại xôn xao.

#### Phương án 1 — Công bố chiếu xác nhận chính thống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhường thêm quyền cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Để nghi lễ tiếp tục diễn ra [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_27"></a>
### 315. Danh sách người ủng hộ đổi ngôi

- **Mã:** `factions_27` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Uy quyền <35. Mã điều kiện: `weakAuthority`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:succession_rumor`.
- **Việc khẩn:** nguyên nhân `succession_rumor`; cooldown chung 2 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không trả lời danh sách”.

**Nội dung tấu chương:**

> Một danh sách ký tên lan trong triều, chưa rõ ai bị giả tên và ai thật sự tham gia.

#### Phương án 1 — Cấp phí xác minh và khẳng định ngôi vua

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Dàn xếp bằng quyền cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không trả lời danh sách [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-security_25"></a>
### 340. Dấu hẹn trong thư chúc thọ

- **Mã:** `security_25` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `urgent:plot_warning`.
- **Việc khẩn:** nguyên nhân `plot_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để thư chúc thọ vào kho”.

**Nội dung tấu chương:**

> Một bức thư mừng có ký hiệu trùng với lời hẹn của nhóm người đáng nghi.

#### Phương án 1 — Chi tiền điều tra kín ký hiệu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét rộng người mang thư

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Để thư chúc thọ vào kho [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_26"></a>
### 341. Thuốc ngủ được giấu gần cổng

- **Mã:** `security_26` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `urgent:plot_warning`.
- **Việc khẩn:** nguyên nhân `plot_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách trực đêm hiện tại”.

**Nội dung tấu chương:**

> Thị vệ tìm thấy thuốc ngủ cạnh bình nước của đội trực đêm.

#### Phương án 1 — Cấp phí bảo vệ đội trực

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng hàng loạt người bị nghi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Giữ cách trực đêm hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_27"></a>
### 342. Người giữ ấn nhận lời mời kín

- **Mã:** `security_27` · **Nhóm:** Âm mưu.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `urgent:plot_warning`.
- **Việc khẩn:** nguyên nhân `plot_warning`; cooldown chung 1 mùa, tối đa một tấu chương cùng nguyên nhân đang chờ; phải xử lý trước khi khép mùa xuất hiện.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xét cuộc gặp người giữ ấn”.

**Nội dung tấu chương:**

> Người giữ ấn bị thấy gặp một nhóm đang bàn chuyện đưa người khác lên ngôi.

#### Phương án 1 — Tự kiểm tra cuộc gặp và giữ ấn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền để dàn xếp kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không xét cuộc gặp người giữ ấn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="group-12"></a>
## Nhóm 12 — Thương mại

<a id="event-commerce_01"></a>
### 100. Bến vải tìm đường mới

- **Mã:** `commerce_01` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không hỗ trợ tuyến mới”.

**Nội dung tấu chương:**

> Thương nhân muốn mở bến bán vải tới các huyện xa nhưng thiếu bảo trợ.

#### Phương án 1 — Góp phí mở tuyến vải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí qua bến mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không hỗ trợ tuyến mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_02"></a>
### 101. Con dấu độc quyền bán dầu

- **Mã:** `commerce_02` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để tranh chấp kéo dài”.

**Nội dung tấu chương:**

> Một thế gia xin độc quyền bán dầu đèn, các quán nhỏ phản đối.

#### Phương án 1 — Giữ cạnh tranh công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Bán quyền cung ứng độc quyền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Để tranh chấp kéo dài [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_03"></a>
### 102. Thuyền gạo tới cửa biển

- **Mã:** `commerce_03` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không chốt việc trao đổi”.

**Nội dung tấu chương:**

> Một đoàn thuyền có gạo muốn đổi hàng trước khi đổi gió.

#### Phương án 1 — Mua gạo vào kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thóc lấy tiền mặt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Không chốt việc trao đổi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_04"></a>
### 103. Phiên chợ trên núi

- **Mã:** `commerce_04` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ đường buôn hiện tại”.

**Nội dung tấu chương:**

> Người vùng núi muốn nối phiên chợ với kinh, cần dựng vài điểm dừng.

#### Phương án 1 — Bảo trợ điểm dừng chân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí thương lộ núi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ đường buôn hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_05"></a>
### 104. Giá đèn tăng sau lệnh cấm

- **Mã:** `commerce_05` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không can dự việc phường”.

**Nội dung tấu chương:**

> Phường đèn xin cấm thợ ngoài phường bán hàng, giá đã bắt đầu tăng.

#### Phương án 1 — Bảo vệ quyền bán tự do

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Bán quyền kiểm soát thị trường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Không can dự việc phường [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_06"></a>
### 105. Khoai khô đổi gạo mới

- **Mã:** `commerce_06` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa trao đổi lương thực”.

**Nội dung tấu chương:**

> Một vùng đề nghị mua lương khô từ kho công để đổi gạo ở vùng khác.

#### Phương án 1 — Mua phần gạo trao đổi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Xuất kho lấy tiền trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Chưa trao đổi lương thực [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_07"></a>
### 106. Hàng gốm qua ba trạm

- **Mã:** `commerce_07` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không sửa đường thương mại”.

**Nội dung tấu chương:**

> Thương nhân bỏ đường cũ vì ba trạm thu trùng phí, xin mở tuyến chung.

#### Phương án 1 — Góp vốn thống nhất tuyến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Giữ tuyến mới để thu phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không sửa đường thương mại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_08"></a>
### 107. Chủ kho ép giá người bán

- **Mã:** `commerce_08` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi người bán tự tìm nơi”.

**Nội dung tấu chương:**

> Chủ một kho lớn chỉ nhận hàng từ thân hữu, chợ nhỏ thiếu hàng.

#### Phương án 1 — Mở quyền gửi kho bình đẳng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Đổi đặc quyền lấy tiền nộp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Đợi người bán tự tìm nơi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_09"></a>
### 108. Cá khô xin vào kho lương

- **Mã:** `commerce_09` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi loại dự trữ”.

**Nội dung tấu chương:**

> Thuyền chài đề nghị bán cá khô để đa dạng khẩu phần quân dân.

#### Phương án 1 — Mua một lô dự phòng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thóc để tăng tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Chưa đổi loại dự trữ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_10"></a>
### 109. Thuyền hàng thiếu bản đồ luồng

- **Mã:** `commerce_10` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa khảo sát tuyến nước”.

**Nội dung tấu chương:**

> Người lái thuyền xin bảo trợ khảo sát luồng cạn để đi an toàn hơn.

#### Phương án 1 — Góp phí khảo sát luồng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu lệ phí trên tuyến khảo sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa khảo sát tuyến nước [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_11"></a>
### 110. Đấu thầu sạp chợ có người chặn

- **Mã:** `commerce_11` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xét đơn khiếu nại”.

**Nội dung tấu chương:**

> Những người trả giá thấp bị chặn không cho vào phiên đấu sạp.

#### Phương án 1 — Mở lại phiên đấu công khai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Nhượng sạp cho nhóm hào phú

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Không xét đơn khiếu nại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_12"></a>
### 111. Hạt kê từ vùng cao

- **Mã:** `commerce_12` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không tham gia mua bán”.

**Nội dung tấu chương:**

> Một đoàn buôn mang kê xuống kinh trong lúc giá gạo đang dao động.

#### Phương án 1 — Mua kê bổ sung kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thóc lấy tiền dự phòng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Không tham gia mua bán [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_13"></a>
### 112. Xe muối muốn vượt đèo

- **Mã:** `commerce_13` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không cấp bảo trợ”.

**Nội dung tấu chương:**

> Đoàn xe muối xin được lập điểm nghỉ để bớt hao hụt trên đèo.

#### Phương án 1 — Cùng mở điểm nghỉ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí đoàn xe qua đèo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không cấp bảo trợ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_14"></a>
### 113. Tem chợ giả tràn lan

- **Mã:** `commerce_14` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để chợ tự phân biệt tem”.

**Nội dung tấu chương:**

> Một phường xin quyền kiểm soát mọi tem chợ, người bán sợ bị ép.

#### Phương án 1 — Giữ tem theo chuẩn chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Bán quyền phát hành tem

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Để chợ tự phân biệt tem [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_15"></a>
### 114. Đậu dự trữ sắp hết vụ

- **Mã:** `commerce_15` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đoàn buôn đi tiếp”.

**Nội dung tấu chương:**

> Thương nhân đề nghị bán đậu khô trước lúc chuyển sang chở hàng khác.

#### Phương án 1 — Mua đậu bổ sung lương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thóc đổi ngân khố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Để đoàn buôn đi tiếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_16"></a>
### 115. Đường buôn dọc bờ hồ

- **Mã:** `commerce_16` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở đường buôn”.

**Nội dung tấu chương:**

> Các làng muốn nối những bến nhỏ thành một đường buôn chung.

#### Phương án 1 — Ứng vốn nối các bến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Đặt phí trên đường mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa mở đường buôn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_17"></a>
### 116. Người giữ chợ thiên vị

- **Mã:** `commerce_17` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đổi lệ xếp chợ”.

**Nội dung tấu chương:**

> Chủ chợ xếp mọi vị trí tốt cho người cùng họ, người buôn nhỏ bức xúc.

#### Phương án 1 — Cấp phí sắp lại chỗ bán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Đổi quyền sắp chỗ lấy tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Không đổi lệ xếp chợ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_18"></a>
### 117. Thóc giống đổi hàng thủ công

- **Mã:** `commerce_18` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không duyệt cuộc trao đổi”.

**Nội dung tấu chương:**

> Một vùng muốn đổi lương thực lấy hàng thủ công của kinh thành.

#### Phương án 1 — Mua phần lương thực mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Xuất thóc lấy tiền ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Không duyệt cuộc trao đổi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_19"></a>
### 118. Sợi tơ tìm khách phương xa

- **Mã:** `commerce_19` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không góp vào chuyến hàng”.

**Nội dung tấu chương:**

> Thợ tơ có hàng tốt nhưng không thể tự thuê đoàn vận chuyển lớn.

#### Phương án 1 — Bảo trợ chuyến hàng thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí gom hàng đi xa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không góp vào chuyến hàng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_20"></a>
### 119. Cân chợ cùng nghiêng một phía

- **Mã:** `commerce_20` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đo lại các cân”.

**Nội dung tấu chương:**

> Nhiều sạp dùng cân lệch giống nhau, người mua nghi có người bảo kê.

#### Phương án 1 — Sửa chuẩn cân và xử công bằng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Nhận tiền phạt để giữ lệ cũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Chưa đo lại các cân [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_21"></a>
### 120. Lương khô của đoàn lữ hành

- **Mã:** `commerce_21` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không giao dịch với đoàn”.

**Nội dung tấu chương:**

> Đoàn lữ hành muốn bán phần lương dư rồi mua hàng thủ công mang về.

#### Phương án 1 — Mua lương dư còn tốt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thêm thóc cho đoàn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Không giao dịch với đoàn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_22"></a>
### 121. Mộc bản rao hàng liên phủ

- **Mã:** `commerce_22` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không lập bản rao chung”.

**Nội dung tấu chương:**

> Người buôn muốn in bản rao chung để các phủ biết nguồn hàng.

#### Phương án 1 — Góp vốn in bản rao

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí đăng tên nhà buôn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không lập bản rao chung [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_23"></a>
### 122. Đường chợ bị trạm tư chắn

- **Mã:** `commerce_23` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các bên tự thương lượng”.

**Nội dung tấu chương:**

> Một thế gia dựng trạm trên lối vào chợ rồi đòi thu phí riêng.

#### Phương án 1 — Gỡ trạm và bảo vệ người bán

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu trạm cho thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Để các bên tự thương lượng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_24"></a>
### 123. Gạo đóng chum của thương hộ

- **Mã:** `commerce_24` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi cách dự trữ”.

**Nội dung tấu chương:**

> Nhà buôn thử giữ gạo trong chum kín, muốn bán lô đầu cho triều đình.

#### Phương án 1 — Mua lô dự trữ mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Xuất kho lấy tiền bù chi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Chưa đổi cách dự trữ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="event-commerce_25"></a>
### 124. Đoàn thương nhân qua biên giới

- **Mã:** `commerce_25` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Không có chiến tranh: áp lực chiến tranh =0. Mã điều kiện: `peace`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không mở tuyến trao đổi”.

**Nội dung tấu chương:**

> Hai bên biên giới muốn mở đường trao đổi nhỏ khi cửa ải còn yên.

#### Phương án 1 — Bảo trợ đường buôn thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥30 (chi 30 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +85; Lương thực +5.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Không có thay đổi chỉ số trực tiếp. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 30 · lòng dân +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +85 · lương thực +5. Thất bại: Không đổi chỉ số ngay. · Vốn/phí ứng 30 tiền · Thành công: nhận 85 tiền, lãi sau vốn 55 tiền · Thất bại: mất 30 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Thu phí qua cửa ải

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -2 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không mở tuyến trao đổi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -5

<a id="event-commerce_26"></a>
### 125. Quyền cung ứng cho hoàng thành

- **Mã:** `commerce_26` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Ngân khố >450. Mã điều kiện: `rich`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Trì hoãn quyết định cung ứng”.

**Nội dung tấu chương:**

> Các nhà buôn lớn tranh một hợp đồng độc quyền, hàng quán nhỏ xin được tham gia.

#### Phương án 1 — Cho đấu thầu ngang quyền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · lòng dân +1

#### Phương án 2 — Nhận tiền mua quyền độc cung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +30; Thái độ phe Thế gia +2; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +30 · phe Thế gia +2 · lòng dân -4 · Tiền nhận ngay 30 · sau phí +30.

#### Phương án 3 — Trì hoãn quyết định cung ứng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -1

<a id="event-commerce_27"></a>
### 126. Những bao gạo giữ giá

- **Mã:** `commerce_27` · **Nhóm:** Thương mại.
- **Điều kiện xuất hiện:** Lương thực <25. Mã điều kiện: `hungry`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `commerce`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để thương nhân tiếp tục giữ”.

**Nội dung tấu chương:**

> Thương nhân giữ lô gạo để chờ giá tăng trong khi kho công đang thiếu.

#### Phương án 1 — Mua ngay phần gạo ấy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +14.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · lương thực +14

#### Phương án 2 — Bán thóc để kiếm ngân khố

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥18 (xuất 18 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +35; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 18 lương thực · ngân khố +35 · lòng dân -1 · Tiền nhận ngay 35 · sau phí +35.

#### Phương án 3 — Để thương nhân tiếp tục giữ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -1

<a id="group-13"></a>
## Nhóm 13 — Nông nghiệp

<a id="event-agriculture_01"></a>
### 127. Giống lúa chín sớm

- **Mã:** `agriculture_01` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không thử giống mới”.

**Nội dung tấu chương:**

> Một làng muốn thử giống lúa thu hoạch trước mùa bão nhưng chưa ai dám góp vốn.

#### Phương án 1 — Cấp tiền ruộng thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Trưng thêm ruộng gieo ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Không thử giống mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_02"></a>
### 128. Thóc ăn hay thóc giống

- **Mã:** `agriculture_02` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để dân tự chia phần”.

**Nội dung tấu chương:**

> Những nhà nghèo đang ăn cả phần thóc để dành cho vụ sau.

#### Phương án 1 — Xuất thóc cứu bữa trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc giống từ thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để dân tự chia phần [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_03"></a>
### 129. Mương dẫn nước bỏ hoang

- **Mã:** `agriculture_03` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa tuyến dẫn”.

**Nội dung tấu chương:**

> Một mương cũ bị bồi lấp, các thửa ruộng phía cuối không nhận được nước.

#### Phương án 1 — Thuê người khơi mương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Huy động dân vét mương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Chưa sửa tuyến dẫn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_04"></a>
### 130. Đậu xanh trên đất bạc

- **Mã:** `agriculture_04` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cây trồng hiện tại”.

**Nội dung tấu chương:**

> Quan điền đề nghị đổi một phần ruộng bạc màu sang trồng đậu.

#### Phương án 1 — Tài trợ vụ trồng thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Ép mở rộng diện tích ngay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Giữ cây trồng hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_05"></a>
### 131. Người cày không còn trâu

- **Mã:** `agriculture_05` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để ruộng chờ người thuê”.

**Nội dung tấu chương:**

> Dân một huyện bán trâu trả nợ, nhiều thửa đất bị bỏ không.

#### Phương án 1 — Cấp thóc hỗ trợ hộ cày

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay trâu kèm thóc thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để ruộng chờ người thuê [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_06"></a>
### 132. Đập gỗ giữa hai xã

- **Mã:** `agriculture_06` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đập qua thêm vụ”.

**Nội dung tấu chương:**

> Hai xã dùng chung một đập đã mục, bên đầu nguồn không muốn góp sửa.

#### Phương án 1 — Cấp tiền thay đập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Buộc hai xã góp công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Để đập qua thêm vụ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_07"></a>
### 133. Ruộng trũng nuôi cá

- **Mã:** `agriculture_07` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi cách canh tác”.

**Nội dung tấu chương:**

> Một vùng muốn chuyển ruộng ngập lâu thành ao cá nhưng thiếu vốn đào.

#### Phương án 1 — Ứng vốn đào ao thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Trưng đất đào ao rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Chưa đổi cách canh tác [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_08"></a>
### 134. Kho giống mở sai lúc

- **Mã:** `agriculture_08` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để làng tự kiếm giống”.

**Nội dung tấu chương:**

> Kho giống địa phương đã phát hết phần dự phòng cho một nhóm nhà giàu.

#### Phương án 1 — Cấp thóc giữ vụ gieo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc đổi quyền thuê ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để làng tự kiếm giống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_09"></a>
### 135. Cửa nước bị nhà giàu chặn

- **Mã:** `agriculture_09` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ họ tự thương lượng”.

**Nội dung tấu chương:**

> Một điền trang nâng bờ làm nước không tới ruộng của các hộ phía dưới.

#### Phương án 1 — Cấp tiền mở cửa nước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Ép điền trang góp dân phu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Chờ họ tự thương lượng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_10"></a>
### 136. Vườn dâu thay bãi cỏ

- **Mã:** `agriculture_10` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đổi cách dùng bãi”.

**Nội dung tấu chương:**

> Thợ tơ muốn trồng dâu trên bãi cỏ hoang, dân chăn trâu chưa đồng ý.

#### Phương án 1 — Tài trợ khoảnh dâu thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Trưng bãi làm vườn rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Chưa đổi cách dùng bãi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_11"></a>
### 137. Lúa non bị đem cầm

- **Mã:** `agriculture_11` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguyên giấy cầm cố”.

**Nội dung tấu chương:**

> Nông dân cầm cả vụ lúa chưa gặt, tới ngày trả nợ không còn phần ăn.

#### Phương án 1 — Xuất thóc cứu các hộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thế gia để chuộc vụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Giữ nguyên giấy cầm cố [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_12"></a>
### 138. Cọc đo nước thiếu dấu

- **Mã:** `agriculture_12` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ dấu cũ thêm mùa”.

**Nội dung tấu chương:**

> Những cọc mực nước không được thay dấu khiến việc chia nước luôn gây cãi vã.

#### Phương án 1 — Cấp tiền đo lại dòng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Huy động dân đặt cọc mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Giữ dấu cũ thêm mùa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_13"></a>
### 139. Nghề ủ phân từ rơm

- **Mã:** `agriculture_13` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không lập khu thử nghiệm”.

**Nội dung tấu chương:**

> Một nhóm nông dân xin vốn thử ủ rơm thay vì đốt hết sau vụ gặt.

#### Phương án 1 — Cấp vốn ủ phân thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Buộc các làng gom rơm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Không lập khu thử nghiệm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_14"></a>
### 140. Người thuê ruộng mất phần

- **Mã:** `agriculture_14` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để giữ hợp đồng tô”.

**Nội dung tấu chương:**

> Chủ ruộng tăng phần tô đúng lúc các nhà thuê vừa gặp mất mùa.

#### Phương án 1 — Xuất kho hỗ trợ tá điền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc có thế chấp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để giữ hợp đồng tô [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_15"></a>
### 141. Nước mặn qua cửa cống

- **Mã:** `agriculture_15` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ hết đợt nước mặn”.

**Nội dung tấu chương:**

> Dân vùng ven biển báo cửa cống cũ không ngăn được triều mặn.

#### Phương án 1 — Thuê thợ sửa cửa cống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Huy động dân đắp bờ tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Chờ hết đợt nước mặn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_16"></a>
### 142. Ruộng bỏ theo người tản cư

- **Mã:** `agriculture_16` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp vốn khai phục”.

**Nội dung tấu chương:**

> Người tản cư muốn nhận lại ruộng bỏ nhưng cần tiền khai phục.

#### Phương án 1 — Cấp vốn phục hồi thử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Trưng nhân lực khai hết ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Chưa cấp vốn khai phục [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_17"></a>
### 143. Thóc dành cho đàn giống

- **Mã:** `agriculture_17` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các hộ bán bớt đàn”.

**Nội dung tấu chương:**

> Các hộ chăn nuôi thiếu phần thóc giữ đàn giống qua mùa khan.

#### Phương án 1 — Cấp thóc giữ đàn giống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc từ điền trang

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để các hộ bán bớt đàn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_18"></a>
### 144. Guồng nước gãy trục

- **Mã:** `agriculture_18` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ thợ đến vụ sau”.

**Nội dung tấu chương:**

> Guồng nước của một cánh đồng gãy trục ngay trước kỳ xuống giống.

#### Phương án 1 — Cấp tiền thay trục

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Buộc các hộ góp công sửa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Chờ thợ đến vụ sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_19"></a>
### 145. Cây kê chịu hạn

- **Mã:** `agriculture_19` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không nhận giống lạ”.

**Nội dung tấu chương:**

> Một người từ vùng khô mang hạt kê chịu hạn xin làm ruộng mẫu.

#### Phương án 1 — Bảo trợ ruộng mẫu kê

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Trưng ruộng gieo diện rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Không nhận giống lạ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_20"></a>
### 146. Lương thợ gặt bị giữ

- **Mã:** `agriculture_20` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để họ tự đòi lương”.

**Nội dung tấu chương:**

> Nhà thuê gặt giữ phần lương bằng thóc, nhiều người làm công sắp bỏ đi.

#### Phương án 1 — Xuất thóc trả trước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc của chủ điền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Để họ tự đòi lương [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_21"></a>
### 147. Bờ ruộng bị tràn lối

- **Mã:** `agriculture_21` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để ruộng giữ bờ cũ”.

**Nội dung tấu chương:**

> Những bờ ruộng bị phá làm lối đi khiến nước tràn khỏi đồng thấp.

#### Phương án 1 — Cấp tiền sửa bờ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Huy động dân đắp lại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Để ruộng giữ bờ cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="event-agriculture_22"></a>
### 148. Vụ gieo đầu xuân muộn

- **Mã:** `agriculture_22` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Đang mùa Xuân. Mã điều kiện: `spring`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lịch gieo cũ”.

**Nội dung tấu chương:**

> Mưa đến chậm, quan điền xin thử cách gieo ít nước trên một khoảnh nhỏ.

#### Phương án 1 — Tài trợ thử gieo khô

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Kinh tế. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Lương thực +22; Lòng dân +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Lương thực −6; Ngân khố −10. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 70 · lòng dân +1 · Cuối mùa kế tiếp (sau 1 mùa): 50% thành công: lương thực +22 · lòng dân +1. Thất bại: lương thực -6 · ngân khố -10. · Không giao ai: 50% thành công

#### Phương án 2 — Ép gieo ngay diện rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +9; Lòng dân −4; Mệt mỏi +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +9 · lòng dân -4 · mệt mỏi +2

#### Phương án 3 — Giữ lịch gieo cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực -5 · lòng dân -2

<a id="event-agriculture_23"></a>
### 149. Hạt giống qua mùa rét

- **Mã:** `agriculture_23` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Đang mùa Đông. Mã điều kiện: `winter`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa can thiệp vào kho giống”.

**Nội dung tấu chương:**

> Các hộ nghèo thiếu thóc ăn, kho giống có nguy cơ bị dùng hết trước xuân.

#### Phương án 1 — Phát thóc ăn giữ giống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; lương thực ≥27 (xuất 27 thóc).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +3; Bệnh −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** xuất 27 lương thực · lòng dân +3 · bệnh -1

#### Phương án 2 — Vay thóc từ nhà nhiều ruộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lương thực +13; Uy quyền −4; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lương thực +13 · uy quyền -4 · phe Thế gia +1

#### Phương án 3 — Chưa can thiệp vào kho giống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −5; Quân lực −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -5 · quân lực -1

<a id="event-agriculture_24"></a>
### 150. Nước ruộng dâng qua bờ

- **Mã:** `agriculture_24` · **Nhóm:** Nông nghiệp.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `agriculture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để nước tự rút”.

**Nội dung tấu chương:**

> Mưa liên tiếp khiến một vùng ruộng phải lựa chọn giữ nước hay tháo bỏ.

#### Phương án 1 — Cấp tiền củng cố đường thoát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +7; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 80 · đê điều +7 · lòng dân +1

#### Phương án 2 — Huy động dân đắp bờ dẫn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +5; Lòng dân −4; Căng thẳng +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +5 · lòng dân -4 · căng thẳng +2

#### Phương án 3 — Để nước tự rút [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −6; Lương thực −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -6 · lương thực -4

<a id="group-14"></a>
## Nhóm 14 — Công trình

<a id="event-engineering_01"></a>
### 154. Kè đá trôi chân móng

- **Mã:** `engineering_01` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kè giữ như cũ”.

**Nội dung tấu chương:**

> Thợ phát hiện lớp đá móng kè bị nước cuốn, cần xử lý trước khi bờ sạt.

#### Phương án 1 — Ứng vốn làm lại móng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động dân gia cố bờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Để kè giữ như cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_02"></a>
### 155. Cầu đường tới doanh trại

- **Mã:** `engineering_02` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa sửa tuyến đi”.

**Nội dung tấu chương:**

> Một cầu gỗ yếu làm xe tiếp tế và người đi chợ phải cùng chờ.

#### Phương án 1 — Thuê thợ sửa lối chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Thu phí nhượng quyền qua cầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa sửa tuyến đi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_03"></a>
### 156. Gỗ công trình thiếu dấu

- **Mã:** `engineering_03` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác hồ sơ gỗ thiếu”.

**Nội dung tấu chương:**

> Kho gỗ công có nhiều cây mất dấu, người giao nhận đổ lỗi cho nhau.

#### Phương án 1 — Cấp phí truy dấu gỗ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận tiền dàn xếp nhà thầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Gác hồ sơ gỗ thiếu [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_04"></a>
### 157. Bờ thành nghiêng xuống hồ

- **Mã:** `engineering_04` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ tới mùa sửa lớn”.

**Nội dung tấu chương:**

> Một đoạn bờ bảo vệ khu dân cư nghiêng dần, thợ xin sửa khi nước còn thấp.

#### Phương án 1 — Ứng tiền gia cố nền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Trưng dân phu chống bờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Chờ tới mùa sửa lớn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_05"></a>
### 158. Đường vận lương đầy ổ lún

- **Mã:** `engineering_05` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để xe tự tìm lối tránh”.

**Nội dung tấu chương:**

> Đội xe quân lương thường mắc kẹt ở con đường dân cũng dùng chở hàng.

#### Phương án 1 — Thuê người đắp nền đường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Đặt trạm thu tiền sửa đường

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để xe tự tìm lối tránh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_06"></a>
### 159. Gạch nung vỡ hàng loạt

- **Mã:** `engineering_06` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lô gạch chưa xét”.

**Nội dung tấu chương:**

> Lô gạch xây kho bị vỡ trước khi dùng, nhà thầu cho rằng vận chuyển có lỗi.

#### Phương án 1 — Kiểm định và truy nguồn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận tiền giảm giá để bỏ qua

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Giữ lô gạch chưa xét [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_07"></a>
### 160. Bậc xuống bến sông sụt

- **Mã:** `engineering_07` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa lập công trình sửa”.

**Nội dung tấu chương:**

> Người gánh nước trượt ngã vì bậc xuống bến bị sụt thành hố.

#### Phương án 1 — Cấp tiền làm bậc chắc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động người dùng bến sửa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Chưa lập công trình sửa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_08"></a>
### 161. Giếng trong trạm quân dịch

- **Mã:** `engineering_08` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ mức nước hiện tại”.

**Nội dung tấu chương:**

> Giếng trạm không đủ cho người đi đường và đội lính thay phiên.

#### Phương án 1 — Thuê thợ mở giếng rộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Bán quyền khai thác nước trạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ mức nước hiện tại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_09"></a>
### 162. Dụng cụ khai mương bị kê cao

- **Mã:** `engineering_09` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không xét giá đã ký”.

**Nội dung tấu chương:**

> Người coi công trình phát hiện giá dụng cụ cao hơn giá bán ngoài chợ.

#### Phương án 1 — Kiểm toán giá dụng cụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Thu khoản hoàn tiền nội bộ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Không xét giá đã ký [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_10"></a>
### 163. Cống ngầm đầy rễ cây

- **Mã:** `engineering_10` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi nước rút mới tính”.

**Nội dung tấu chương:**

> Rễ cây xuyên cống làm nước dâng ngược vào những ngõ thấp.

#### Phương án 1 — Ứng vốn sửa đường cống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động dân thông cống

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Đợi nước rút mới tính [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_11"></a>
### 164. Bến tập kết quân trang

- **Mã:** `engineering_11` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ bến giao nhận cũ”.

**Nội dung tấu chương:**

> Khoảng sân giao hàng quá nhỏ khiến quân trang và hàng dân cùng bị chậm.

#### Phương án 1 — Mở rộng sân tập kết chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Cho thế gia giữ quyền vào bến

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ bến giao nhận cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_12"></a>
### 165. Dây kéo đá bị tráo

- **Mã:** `engineering_12` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cho dùng tiếp loại dây”.

**Nội dung tấu chương:**

> Đội kéo đá nhận loại dây kém hơn hợp đồng, chưa tìm được người chịu trách nhiệm.

#### Phương án 1 — Truy xét lô dây kéo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận tiền bảo lãnh nhà thầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Cho dùng tiếp loại dây [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_13"></a>
### 166. Đê phụ chắn nước ngược

- **Mã:** `engineering_13` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ tuyến đê phụ”.

**Nội dung tấu chương:**

> Một đê phụ giữ nước sai hướng khiến các vườn thấp luôn bị úng.

#### Phương án 1 — Ứng tiền đổi hướng đê

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động làng mở lối nước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Giữ tuyến đê phụ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_14"></a>
### 167. Lối xuyên đồi sạt mép

- **Mã:** `engineering_14` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đóng tuyến để sửa”.

**Nội dung tấu chương:**

> Đường qua đồi vừa dùng cho dân vừa dùng đưa tin quân sự, mép đường đang nứt.

#### Phương án 1 — Thuê thợ gia cố lối đi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Đặt phí riêng cho người qua

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa đóng tuyến để sửa [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_15"></a>
### 168. Đá tốt biến thành đá vụn

- **Mã:** `engineering_15` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không mở lại hợp đồng”.

**Nội dung tấu chương:**

> Đá được báo là loại tốt nhưng tới công trường chỉ còn nhiều đá vụn.

#### Phương án 1 — Cho thẩm định hợp đồng đá

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận khoản bù của người cung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Không mở lại hợp đồng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_16"></a>
### 169. Bờ hồ trong xóm lún

- **Mã:** `engineering_16` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để từng nhà tự chống”.

**Nội dung tấu chương:**

> Nhiều cọc nhà ven hồ bị lộ chân, dân xin gia cố trước khi nhà nghiêng.

#### Phương án 1 — Ứng vốn giữ bờ hồ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Trưng ngày công cư dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Để từng nhà tự chống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_17"></a>
### 170. Trạm thay ngựa thiếu máng nước

- **Mã:** `engineering_17` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ công suất trạm cũ”.

**Nội dung tấu chương:**

> Người chuyển công văn và xe dân thường phải tranh một máng nước nhỏ.

#### Phương án 1 — Làm thêm máng dùng chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Nhượng quyền thu phí trạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ công suất trạm cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_18"></a>
### 171. Số ngày công bị ghi khống

- **Mã:** `engineering_18` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét lại sổ công”.

**Nội dung tấu chương:**

> Sổ công trình ghi nhiều người làm mà dân trong làng chưa từng nghe tên.

#### Phương án 1 — Cấp phí đối chiếu nhân công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận tiền hoàn kín từ chủ việc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Chưa xét lại sổ công [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_19"></a>
### 172. Đường thoát nước dưới chợ

- **Mã:** `engineering_19` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đợi phiên chợ thưa mới làm”.

**Nội dung tấu chương:**

> Ngõ chợ bị ngập vì ống dẫn nước nhỏ hơn phần đã vẽ trong thiết kế.

#### Phương án 1 — Ứng tiền mở rộng tuyến thoát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động thương hộ đào lại

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Đợi phiên chợ thưa mới làm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_20"></a>
### 173. Cầu tạm qua suối quân lương

- **Mã:** `engineering_20` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa gia cường cầu tạm”.

**Nội dung tấu chương:**

> Cầu tạm rung mạnh khi xe đi, người dân cũng phải qua cùng tuyến.

#### Phương án 1 — Thuê thợ gia cường cầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Cho nhà thầu thu phí qua cầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa gia cường cầu tạm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_21"></a>
### 174. Vật liệu dư không vào sổ

- **Mã:** `engineering_21` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kho tự xử lý”.

**Nội dung tấu chương:**

> Kho cuối công trình có vật liệu dư nhưng không ai ghi việc nhập lại.

#### Phương án 1 — Kiểm kê vật liệu thừa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Cho người cung mua lại kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để kho tự xử lý [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_22"></a>
### 175. Mái đê bị khoét làm lối

- **Mã:** `engineering_22` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Đê điều <50. Mã điều kiện: `weakLevee`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chỉ cắm biển cảnh báo”.

**Nội dung tấu chương:**

> Dân chăn trâu khoét mái đê làm lối xuống sông, đoạn yếu ngày càng rộng.

#### Phương án 1 — Ứng vốn phục hồi mái đê

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động dân lấp lối khoét

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Chỉ cắm biển cảnh báo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_23"></a>
### 176. Đường vào kho cháy đèn

- **Mã:** `engineering_23` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lối đi trong tối”.

**Nội dung tấu chương:**

> Đường vào kho tối khiến cả lính gác và phu hàng thường xuyên vấp ngã.

#### Phương án 1 — Lắp đèn chung cho lối vào

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Bán quyền thu phí giữ đèn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ lối đi trong tối [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_24"></a>
### 177. Bản vẽ móng kho bị đổi

- **Mã:** `engineering_24` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để công trình theo bản mới”.

**Nội dung tấu chương:**

> Bản vẽ trong tay thợ khác bản đã đóng dấu, kinh phí đã chi quá nửa.

#### Phương án 1 — Truy bản vẽ và khoản chi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Chấp nhận khoản bù của chủ thầu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để công trình theo bản mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="event-engineering_25"></a>
### 178. Khe đê rỉ nước đục

- **Mã:** `engineering_25` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Đang mùa Hạ. Mã điều kiện: `rain`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ khe rỉ rộng hơn”.

**Nội dung tấu chương:**

> Người giữ đê thấy nước đục rỉ qua khe nhỏ khi mực sông đang lên.

#### Phương án 1 — Ứng tiền bịt khe từ gốc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥80 (chi 80 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Đê điều +11; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Ngân khố −15; Uy quyền −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 80 · lòng dân +1 · Cuối mùa chọn phương án: 55% thành công: đê điều +11 · lòng dân +2. Thất bại: ngân khố -15 · uy quyền -2. · Không giao ai: 55% thành công

#### Phương án 2 — Huy động dân gia cố tức thì

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều +6; Lòng dân −4.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều +6 · lòng dân -4

#### Phương án 3 — Chờ khe rỉ rộng hơn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Đê điều −5; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** đê điều -5 · lòng dân -2

<a id="event-engineering_26"></a>
### 179. Cầu cho xe cứu thương

- **Mã:** `engineering_26` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ giới hạn tải cũ”.

**Nội dung tấu chương:**

> Đội vận chuyển người bệnh xin sửa cầu chung với tuyến quân nhu.

#### Phương án 1 — Thuê thợ sửa cầu an toàn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực +2; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · quân lực +2 · lòng dân +1

#### Phương án 2 — Nhượng phí qua cầu cho hào phú

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · Ổn định triều đình -1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Giữ giới hạn tải cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Quân lực −2; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** quân lực -2 · lòng dân -2

<a id="event-engineering_27"></a>
### 180. Quỹ bảo trì biến mất

- **Mã:** `engineering_27` · **Nhóm:** Công trình.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `engineering`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để vụ quỹ chìm xuống”.

**Nội dung tấu chương:**

> Quỹ dành sửa những công trình nhỏ đã được rút nhưng không có biên nhận rõ.

#### Phương án 1 — Cấp phí truy quỹ bảo trì

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Công trình. Không giao ai: 45%; giao người đủ điều kiện: 50–80%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 45% khi không giao ai:** cuối mùa kế tiếp (sau 1 mùa): Ngân khố +60; Đê điều +5.
- **Kết quả chờ — thất bại 55% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 20 · uy quyền +1 · Cuối mùa kế tiếp (sau 1 mùa): 45% thành công: ngân khố +60 · đê điều +5. Thất bại: uy quyền -1. · Vốn/phí ứng 20 tiền · Thành công: nhận 60 tiền, lãi sau vốn 40 tiền · Thất bại: mất 20 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa kế tiếp (sau 1 mùa) · Không giao ai: 45% thành công

#### Phương án 2 — Nhận tiền dàn xếp của chủ quỹ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +15; Thái độ phe Thế gia +1; Uy quyền −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +15 · phe Thế gia +1 · uy quyền -3 · Tiền nhận ngay 15 · sau phí +15.

#### Phương án 3 — Để vụ quỹ chìm xuống [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố −10; Đê điều −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố -10 · đê điều -3

<a id="group-15"></a>
## Nhóm 15 — Pháp luật

<a id="event-justice_01"></a>
### 235. Con nhà quyền thế cán người

- **Mã:** `justice_01` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để đơn chờ ở nha môn”.

**Nội dung tấu chương:**

> Gia đình nạn nhân xin xét xử công khai sau khi lính hầu tìm cách ém đơn.

#### Phương án 1 — Đích thân mở phiên xét xử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Phạt tiền gia đình quyền thế

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để đơn chờ ở nha môn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_02"></a>
### 236. Người trộm bánh nuôi con

- **Mã:** `justice_02` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không quyết án lần này”.

**Nội dung tấu chương:**

> Một người mẹ lấy bánh lúc đói, dân và quan tranh luận giữa phép nước và lòng thương.

#### Phương án 1 — Chuộc lỗi bằng cứu trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Áp án nghiêm để răn đe

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Không quyết án lần này [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_03"></a>
### 237. Nhân chứng đổi lời khai

- **Mã:** `justice_03` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác lại lời khai mâu thuẫn”.

**Nội dung tấu chương:**

> Nhân chứng trong vụ mất đất bất ngờ rút lời sau khi nhận quà từ nhà giàu.

#### Phương án 1 — Chi tiền bảo vệ và điều tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Hòa giải theo đề nghị các bên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Gác lại lời khai mâu thuẫn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_04"></a>
### 238. Cọc ruộng bị nhổ

- **Mã:** `justice_04` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chuyển đơn về huyện cũ”.

**Nội dung tấu chương:**

> Một nhà thế gia bị tố dời cọc ruộng của cả xóm, quan huyện không dám xử.

#### Phương án 1 — Mở phiên đối chất trước dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Nhận khoản phạt để khép vụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chuyển đơn về huyện cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_05"></a>
### 239. Kẻ đào ngũ trở về chịu tội

- **Mã:** `justice_05` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa công bố bản án”.

**Nội dung tấu chương:**

> Người lính nói đã bỏ trại để đưa cha tránh lũ, nay tự đến xin xét.

#### Phương án 1 — Cấp phí chuộc lỗi và giảm án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Xử nghiêm tội đào ngũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Chưa công bố bản án [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_06"></a>
### 240. Ấn huyện trên giấy giả

- **Mã:** `justice_06` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để huyện tự thu tiếp”.

**Nội dung tấu chương:**

> Nhiều tờ thuế có dấu thật nhưng chữ khác nhau, dân không biết phải nộp cho ai.

#### Phương án 1 — Điều tra nguồn giấy và con dấu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Thỏa thuận mức nộp tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Để huyện tự thu tiếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_07"></a>
### 241. Đầy tớ kiện chủ đánh đập

- **Mã:** `justice_07` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không thụ lý đơn vượt cấp”.

**Nội dung tấu chương:**

> Một gia nhân trốn vào kinh xin xử chủ nhà quyền quý vì đánh người đến tàn phế.

#### Phương án 1 — Mở án xét cả người quyền quý

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Nhận bồi thường để khép án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không thụ lý đơn vượt cấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_08"></a>
### 242. Đám đông đập kho đầu cơ

- **Mã:** `justice_08` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để địa phương tự định tội”.

**Nội dung tấu chương:**

> Dân phá cửa một kho giữ gạo, chủ kho đòi trị tội toàn bộ người tham gia.

#### Phương án 1 — Cứu trợ và khoan tội có điều kiện

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Áp án nặng với đám đông

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Để địa phương tự định tội [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_09"></a>
### 243. Hai người nhận cùng di chúc

- **Mã:** `justice_09` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xác định người thừa kế”.

**Nội dung tấu chương:**

> Một gia đình trình hai di chúc trái ngược, mỗi bên đều có người làm chứng.

#### Phương án 1 — Cấp phí giám định hồ sơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Hòa giải chia tài sản tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Chưa xác định người thừa kế [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_10"></a>
### 244. Quan trạm đánh người đưa thư

- **Mã:** `justice_10` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Gác đơn sang kỳ sau”.

**Nội dung tấu chương:**

> Một người đưa thư bị đánh vì giao đơn tố cáo nhà thế gia đúng ngày lễ.

#### Phương án 1 — Đích thân xét hành vi cản đơn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Nhận phạt tiền thay xét xử

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Gác đơn sang kỳ sau [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_11"></a>
### 245. Thợ phá máy để giữ nghề

- **Mã:** `justice_11` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa phân xử tranh chấp”.

**Nội dung tấu chương:**

> Thợ bị mất việc đập máy xay mới, chủ xưởng muốn dùng hình nặng làm gương.

#### Phương án 1 — Bồi hoàn và cho chuộc lỗi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Xử nghiêm hành vi phá xưởng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Chưa phân xử tranh chấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_12"></a>
### 246. Nhà tù báo thiếu một người

- **Mã:** `justice_12` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chờ nhà tù tự báo lại”.

**Nội dung tấu chương:**

> Sổ ghi đủ tù nhưng phòng giam thiếu người, lính canh đổ lỗi cho nhau.

#### Phương án 1 — Điều tra và kiểm tra lại sổ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Dàn xếp trách nhiệm giữa các đội

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Chờ nhà tù tự báo lại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_13"></a>
### 247. Đường làng bị dựng cổng riêng

- **Mã:** `justice_13` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa động đến cổng thu phí”.

**Nội dung tấu chương:**

> Một dòng họ quyền quý dựng cổng thu tiền trên lối dân đi đã nhiều đời.

#### Phương án 1 — Xét quyền đi lại công khai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Phạt tiền để cho giữ cổng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa động đến cổng thu phí [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_14"></a>
### 248. Người đánh chuông báo cháy sai

- **Mã:** `justice_14` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không công bố cách xử”.

**Nội dung tấu chương:**

> Một đứa trẻ gây hỗn loạn vì tưởng sương là khói, quan xin phạt để giữ lệnh.

#### Phương án 1 — Giúp gia đình và cho chuộc lỗi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Áp án nghiêm vì báo động sai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Không công bố cách xử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_15"></a>
### 249. Chứng vật biến mất ở nha môn

- **Mã:** `justice_15` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Xếp vụ án chờ chứng cứ”.

**Nội dung tấu chương:**

> Túi tiền làm bằng chứng thất lạc đúng lúc sắp xét vụ tham ô.

#### Phương án 1 — Chi tiền truy tìm chứng vật

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Hòa giải để kết thúc vụ án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Xếp vụ án chờ chứng cứ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_16"></a>
### 250. Phu trạm kiện bị giữ tiền công

- **Mã:** `justice_16` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để phu trạm chờ huyện xử”.

**Nội dung tấu chương:**

> Phu trạm nói quản sự nhà quyền thế giữ hết tiền vận chuyển do vua cấp.

#### Phương án 1 — Mở phiên đối chất tiền công

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Nhận khoản phạt từ nhà quản sự

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để phu trạm chờ huyện xử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_17"></a>
### 251. Tù nhân cứu người coi ngục

- **Mã:** `justice_17` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa trả lời đơn xin giảm”.

**Nội dung tấu chương:**

> Một tù nhân phá khóa cứu lính canh khỏi cháy, nay xin xét lại hình phạt.

#### Phương án 1 — Giảm án và cấp phí tái hòa nhập

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Giữ án để bảo vệ phép nước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Chưa trả lời đơn xin giảm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_18"></a>
### 252. Lời tố cáo giữa hai làng

- **Mã:** `justice_18` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai làng tự tìm chứng cứ”.

**Nội dung tấu chương:**

> Mỗi làng cáo buộc làng kia đầu độc giếng, chưa có chứng cứ rõ ràng.

#### Phương án 1 — Cấp phí điều tra nguồn nước

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Tổ chức hòa giải tạm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Để hai làng tự tìm chứng cứ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_19"></a>
### 253. Bản án chỉ dành cho người nghèo

- **Mã:** `justice_19` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không mở lại hồ sơ”.

**Nội dung tấu chương:**

> Hai người cùng phạm lỗi nhưng con nhà giàu được bỏ qua, dân kéo đến cửa triều.

#### Phương án 1 — Xét lại cả hai bản án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Phạt tiền nhà giàu cho xong

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Không mở lại hồ sơ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_20"></a>
### 254. Nông dân đốt sổ nợ

- **Mã:** `justice_20` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Trì hoãn quyết định”.

**Nội dung tấu chương:**

> Một nhóm dân đốt giấy vay sau mùa mất trắng, chủ nợ yêu cầu xử thật nặng.

#### Phương án 1 — Cứu trợ và cho chuộc lỗi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Thi hành hình phạt nghiêm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Trì hoãn quyết định [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_21"></a>
### 255. Thầy thuốc bị tố dùng độc

- **Mã:** `justice_21` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét vụ thầy thuốc”.

**Nội dung tấu chương:**

> Gia đình bệnh nhân tố thầy thuốc đầu độc nhưng người chữa bệnh nói là tai biến.

#### Phương án 1 — Mời người độc lập điều tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Dàn xếp bồi thường đôi bên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Chưa xét vụ thầy thuốc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="event-justice_22"></a>
### 256. Đòi người làm để trừ nợ

- **Mã:** `justice_22` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để chủ nợ tự giải quyết”.

**Nội dung tấu chương:**

> Một nhà quyền quý giữ con của người mắc nợ, dân cho rằng trái phép triều đình.

#### Phương án 1 — Xét việc giữ người công khai

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân +1; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân +1 · phe Thế gia -2

#### Phương án 2 — Nhận tiền phạt để khép hồ sơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để chủ nợ tự giải quyết [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −3; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -3 · uy quyền -2

<a id="event-justice_23"></a>
### 257. Kẻ trộm nộp lại đồ thất lạc

- **Mã:** `justice_23` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét lời tự thú”.

**Nội dung tấu chương:**

> Người từng trộm đồ của triều đình tự mang trả và xin cơ hội làm lại.

#### Phương án 1 — Cho chuộc lỗi có hỗ trợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥20 (chi 20 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +2; Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 20 · lòng dân +2 · uy quyền -2

#### Phương án 2 — Giữ hình phạt cũ để răn đe

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Lòng dân −4; Ổn định triều đình −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · lòng dân -4 · Ổn định triều đình -1

#### Phương án 3 — Chưa xét lời tự thú [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −2; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -2 · Ổn định triều đình -2

<a id="event-justice_24"></a>
### 258. Lời khai dưới ép cung

- **Mã:** `justice_24` · **Nhóm:** Pháp luật.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `justice`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Đóng việc xét lại hồ sơ”.

**Nội dung tấu chương:**

> Một viên lại thừa nhận đã ép người ký nhận tội, hồ sơ cũ có thể sai hàng loạt.

#### Phương án 1 — Chi tiền điều tra lại hồ sơ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥40 (chi 40 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 55%; giao người đủ điều kiện: 60–90%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 55% khi không giao ai:** cuối mùa chọn phương án: Uy quyền +3; Lòng dân +2.
- **Kết quả chờ — thất bại 45% khi không giao ai:** cùng thời điểm: Uy quyền −3; Lòng dân −2. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 40 · uy quyền +1 · Cuối mùa chọn phương án: 55% thành công: uy quyền +3 · lòng dân +2. Thất bại: uy quyền -3 · lòng dân -2. · Không giao ai: 55% thành công

#### Phương án 2 — Hòa giải và sửa vài bản án

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Ổn định triều đình −2; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · Ổn định triều đình -2 · phe Văn thần +1

#### Phương án 3 — Đóng việc xét lại hồ sơ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −4; Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -4 · Ổn định triều đình -2

<a id="group-16"></a>
## Nhóm 16 — Phe phái

<a id="event-factions_01"></a>
### 289. Văn Võ tranh quyền coi trạm

- **Mã:** `factions_01` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa phân xử quyền coi trạm”.

**Nội dung tấu chương:**

> Quan Văn muốn giữ sổ trạm, quan Võ muốn tự điều xe ngựa để khỏi chậm quân.

#### Phương án 1 — Chi phí lập quyền giám sát chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Giao trạm cho phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Chưa phân xử quyền coi trạm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_02"></a>
### 290. Họ vua và thế gia tranh đất lễ

- **Mã:** `factions_02` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai bên tự giữ đất”.

**Nội dung tấu chương:**

> Hai nhóm cùng nhận quyền quản một khu đất dùng cho lễ lớn.

#### Phương án 1 — Đích thân xét theo lệ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Cho thế gia nhận đất và nộp tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để hai bên tự giữ đất [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_03"></a>
### 291. Gia phả cũ bị đem bàn tán

- **Mã:** `factions_03` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đáp lời bàn tán”.

**Nội dung tấu chương:**

> Một bản gia phả được truyền tay với lời nghi ngờ về chính thống của ngôi vua.

#### Phương án 1 — Công bố hồ sơ có kiểm chứng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhượng việc nội triều cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không đáp lời bàn tán [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_04"></a>
### 292. Ai được giữ kho vũ khí

- **Mã:** `factions_04` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Hoãn phân xử chuyện kho”.

**Nội dung tấu chương:**

> Quan Văn đòi kiểm kê, quan Võ nói kiểm kê giữa kỳ tập sẽ cản việc quân.

#### Phương án 1 — Lập tổ kiểm kê chung có kinh phí

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Cho phe Võ toàn quyền giữ kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Hoãn phân xử chuyện kho [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_05"></a>
### 293. Suất học cho con nhà danh giá

- **Mã:** `factions_05` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa định cách chia suất”.

**Nội dung tấu chương:**

> Hoàng tộc và thế gia đều muốn được ưu tiên số suất học có hạn.

#### Phương án 1 — Tự áp tiêu chuẩn chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Cho thế gia mua quyền ưu tiên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chưa định cách chia suất [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_06"></a>
### 294. Lời thề của người kế vị cũ

- **Mã:** `factions_06` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để lời thề tiếp tục lan”.

**Nội dung tấu chương:**

> Một nhánh hoàng tộc nhắc lại lời hứa truyền ngôi trước đây để gây ảnh hưởng.

#### Phương án 1 — Làm rõ tính hợp lệ của chiếu cũ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhượng quyền nội triều cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Để lời thề tiếp tục lan [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_07"></a>
### 295. Tấu xin giám sát quân lương

- **Mã:** `factions_07` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai phe tự tranh sổ”.

**Nội dung tấu chương:**

> Phe Văn muốn kiểm soát sổ lương, phe Võ lo việc cấp phát bị chậm.

#### Phương án 1 — Chi phí xây cơ chế giám sát chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Trao toàn quyền cho tướng giữ lương

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Để hai phe tự tranh sổ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_08"></a>
### 296. Quyền mở đoàn săn mùa thu

- **Mã:** `factions_08` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Mặc hai nhóm giành đoàn săn”.

**Nội dung tấu chương:**

> Hoàng tộc nhận đó là truyền lệ, thế gia nói họ đã trả tiền chuẩn bị.

#### Phương án 1 — Tự xét quyền theo quy định chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Nhận tiền và ưu tiên thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Mặc hai nhóm giành đoàn săn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_09"></a>
### 297. Bài ca ca ngợi một thân vương

- **Mã:** `factions_09` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không phản ứng với bài ca”.

**Nội dung tấu chương:**

> Một bài ca lưu truyền tôn thân vương hơn nhà vua, các quan xin chỉ dụ.

#### Phương án 1 — Làm rõ chính thống bằng chứng cứ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhượng quyền sắp việc trong cung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không phản ứng với bài ca [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_10"></a>
### 298. Tranh người phụ trách cứu hộ

- **Mã:** `factions_10` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để tranh người phụ trách kéo dài”.

**Nội dung tấu chương:**

> Phe Văn đề nghị quan dân sự, phe Võ muốn giao tướng vì có quân sẵn.

#### Phương án 1 — Cấp phí phối hợp hai bên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Giao hẳn cho phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Để tranh người phụ trách kéo dài [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_11"></a>
### 299. Ghế chủ lễ của hai dòng họ

- **Mã:** `factions_11` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không quyết ghế chủ lễ”.

**Nội dung tấu chương:**

> Hai dòng họ lớn tranh ghế chủ lễ và cùng mang người tới điện.

#### Phương án 1 — Đích thân áp phép lễ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Nhận tài trợ để ưu tiên thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Không quyết ghế chủ lễ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_12"></a>
### 300. Lời đồn ngai vàng được vay

- **Mã:** `factions_12` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua lời đồn về ngai”.

**Nội dung tấu chương:**

> Kẻ lạ nói việc lên ngôi nhờ một lời hứa bí mật mà vua chưa thực hiện.

#### Phương án 1 — Chi phí xác minh và công bố chiếu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Giao thêm quyền cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Bỏ qua lời đồn về ngai [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_13"></a>
### 301. Quan Văn phản đối đoàn duyệt binh

- **Mã:** `factions_13` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa quyết lịch duyệt binh”.

**Nội dung tấu chương:**

> Quan Văn muốn giảm chi, quan Võ nói hủy duyệt binh là xem nhẹ quân đội.

#### Phương án 1 — Chi phí tìm phương án hai bên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Dùng uy quyền giữ kế hoạch phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Chưa quyết lịch duyệt binh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_14"></a>
### 302. Người bảo trợ đòi đặt tên cầu

- **Mã:** `factions_14` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai bên tự treo biển”.

**Nội dung tấu chương:**

> Hoàng tộc muốn tên tổ tiên, thế gia tài trợ muốn tên dòng họ mình.

#### Phương án 1 — Tự xét tên theo phép chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Nhận tiền và thuận tên thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để hai bên tự treo biển [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_15"></a>
### 303. Một biểu chương xin vua nhường quyền

- **Mã:** `factions_15` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không trả lời biểu chương”.

**Nội dung tấu chương:**

> Một nhóm quan nói vua còn trẻ và muốn hoàng tộc thay xử việc một thời gian.

#### Phương án 1 — Củng cố chính thống bằng chiếu rõ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Giao thêm quyền điều phối cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không trả lời biểu chương [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_16"></a>
### 304. Quyền bổ nhiệm người giữ biên

- **Mã:** `factions_16` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để chức trách tiếp tục tranh chấp”.

**Nội dung tấu chương:**

> Hai phe đưa hai người khác nhau, ai cũng nói chỉ phe mình hiểu biên giới.

#### Phương án 1 — Chi phí lập cơ chế cùng giám sát

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Theo đề xuất của phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Để chức trách tiếp tục tranh chấp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_17"></a>
### 305. Hội đồng họ tộc xin miễn lệ

- **Mã:** `factions_17` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa trả lời đòi đặc quyền”.

**Nội dung tấu chương:**

> Hoàng tộc và thế gia cùng đòi đặc quyền nhưng không muốn bên kia được hưởng.

#### Phương án 1 — Tự tuyên bố áp lệ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Thu tiền và cho thế gia ưu tiên

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Chưa trả lời đòi đặc quyền [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_18"></a>
### 306. Kỷ vật vua trước xuất hiện

- **Mã:** `factions_18` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để kỷ vật bị diễn giải tùy ý”.

**Nội dung tấu chương:**

> Một kỷ vật bị dùng làm bằng chứng rằng có người khác từng được chọn nối ngôi.

#### Phương án 1 — Chi phí kiểm chứng kỷ vật

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Nhượng quyền nội triều cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Để kỷ vật bị diễn giải tùy ý [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_19"></a>
### 307. Hai phe tranh cách đọc quân báo

- **Mã:** `factions_19` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không chọn cách xử lý quân báo”.

**Nội dung tấu chương:**

> Quan Văn muốn kiểm chứng tin, quan Võ đòi phản ứng ngay trước khi đối thủ biết.

#### Phương án 1 — Chi phí lập nhóm đọc báo chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Theo đề nghị cứng rắn của phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Không chọn cách xử lý quân báo [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_20"></a>
### 308. Quyền dùng bến dành cho triều đình

- **Mã:** `factions_20` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hai bên tự tranh bến”.

**Nội dung tấu chương:**

> Thế gia và hoàng tộc cùng đưa thuyền vào bến riêng rồi cáo nhau lấn quyền.

#### Phương án 1 — Tự xét theo quy tắc chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Nhận phí và ưu tiên thuyền thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Để hai bên tự tranh bến [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_21"></a>
### 309. Dấu hiệu trên thiên tượng

- **Mã:** `factions_21` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không đáp chuyện thiên tượng”.

**Nội dung tấu chương:**

> Một nhóm người giải thích sao lạ là điềm thay ngôi, hoàng tộc xin thêm quyền trấn an.

#### Phương án 1 — Chi phí công bố lời giải có chứng cứ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Giao thêm việc nội triều cho hoàng tộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Không đáp chuyện thiên tượng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="event-factions_22"></a>
### 310. Hai phe cùng tẩy chay nghị chính

- **Mã:** `factions_22` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Chênh lệch giữa thái độ phe cao nhất và thấp nhất >35. Mã điều kiện: `factionSplit`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để buổi nghị tiếp tục đình lại”.

**Nội dung tấu chương:**

> Phe Văn và phe Võ chỉ chịu dự chầu nếu bên kia nhượng quyền trước.

#### Phương án 1 — Chi phí lập thỏa thuận nghị chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +3; Thái độ phe Văn thần +1; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · Ổn định triều đình +3 · phe Văn thần +1 · phe Võ tướng +1

#### Phương án 2 — Dùng uy quyền thiên về phe Võ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Thái độ phe Võ tướng +3; Thái độ phe Văn thần −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · phe Võ tướng +3 · phe Văn thần -5

#### Phương án 3 — Để buổi nghị tiếp tục đình lại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −4; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -4 · uy quyền -1

<a id="event-factions_23"></a>
### 311. Lễ vật chia triều thành hai nhóm

- **Mã:** `factions_23` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Chênh lệch giữa thái độ phe cao nhất và thấp nhất >35. Mã điều kiện: `factionSplit`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Mặc các phe giữ lễ vật”.

**Nội dung tấu chương:**

> Hai phe lớn tranh quyền nhận lễ vật và công khai chỉ trích nhau giữa điện.

#### Phương án 1 — Tự áp phép phân xử chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Uy quyền +1; Thái độ phe Hoàng tộc −2; Thái độ phe Thế gia −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +1 · uy quyền +1 · phe Hoàng tộc -2 · phe Thế gia -2

#### Phương án 2 — Nhận tiền và thuận ý thế gia

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +25; Thái độ phe Thế gia +3; Thái độ phe Hoàng tộc −5.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +25 · phe Thế gia +3 · phe Hoàng tộc -5 · Tiền nhận ngay 25 · sau phí +25.

#### Phương án 3 — Mặc các phe giữ lễ vật [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −3; Tiến độ âm mưu mỗi nhân vật +3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -3 · âm mưu +3

<a id="event-factions_24"></a>
### 312. Một phe muốn đứng giữa nhà vua

- **Mã:** `factions_24` · **Nhóm:** Phe phái.
- **Điều kiện xuất hiện:** Chênh lệch giữa thái độ phe cao nhất và thấp nhất >35. Mã điều kiện: `factionSplit`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `factions`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đáp đề nghị giữ chỉ dụ”.

**Nội dung tấu chương:**

> Một nhóm hoàng tộc đề nghị mọi chỉ dụ phải qua họ để tránh xung đột phe phái.

#### Phương án 1 — Củng cố quyền ban chỉ bằng chứng cứ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥70 (chi 70 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +3; Tiến độ âm mưu mỗi nhân vật −3 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 70 · uy quyền +3 · âm mưu -3

#### Phương án 2 — Cho hoàng tộc quyền điều phối

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +2; Uy quyền −3; Thái độ phe Hoàng tộc +2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình +2 · uy quyền -3 · phe Hoàng tộc +2

#### Phương án 3 — Chưa đáp đề nghị giữ chỉ dụ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −4; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -4 · âm mưu +4

<a id="group-17"></a>
## Nhóm 17 — An ninh

<a id="event-security_01"></a>
### 316. Thư không ký tên trong bếp

- **Mã:** `security_01` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua thư nặc danh”.

**Nội dung tấu chương:**

> Một thư nặc danh báo có người đổi gia vị trong bếp nhưng chưa nêu chứng cứ.

#### Phương án 1 — Cấp phí điều tra kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét rộng các khu bếp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Bỏ qua thư nặc danh [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_02"></a>
### 317. Lính gác bị dụ rời cổng

- **Mã:** `security_02` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách gác cổng cũ”.

**Nội dung tấu chương:**

> Một lính gác nhận lời nhắn giả gọi đi, cổng phụ trống trong một đoạn canh.

#### Phương án 1 — Cấp phí bảo vệ và đổi quy trình

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng người bị nghi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Giữ cách gác cổng cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_03"></a>
### 318. Quản sự thu tiền qua cửa kín

- **Mã:** `security_03` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa kiểm tra cửa kín”.

**Nội dung tấu chương:**

> Người có tiền được đi qua cửa phụ không ghi sổ, thị vệ xin vua xem xét.

#### Phương án 1 — Tự kiểm tra lối đi bí mật

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền để giữ lệ cửa phụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa kiểm tra cửa kín [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_04"></a>
### 319. Chén bạc có dấu mài mới

- **Mã:** `security_04` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Dùng chén như chưa có chuyện”.

**Nội dung tấu chương:**

> Người rửa chén thấy đáy một chén bạc bị mài khác những chiếc còn lại.

#### Phương án 1 — Điều tra nguồn gốc chiếc chén

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét những người phục vụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Dùng chén như chưa có chuyện [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_05"></a>
### 320. Thợ khóa báo mất chìa mẫu

- **Mã:** `security_05` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ các khóa đang dùng”.

**Nội dung tấu chương:**

> Chìa mẫu của một hành lang gần ngự phòng biến mất khỏi xưởng.

#### Phương án 1 — Cấp phí bảo vệ và thay cách giữ chìa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Bắt hàng loạt người bị nghi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Giữ các khóa đang dùng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_06"></a>
### 321. Giấy thông hành được bán kín

- **Mã:** `security_06` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét nguồn giấy thông hành”.

**Nội dung tấu chương:**

> Một người môi giới rao giấy vào cung có dấu thật nhưng không có tên người cấp.

#### Phương án 1 — Tự kiểm tra đường dây giấy phép

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền và giữ đường cấp giấy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa xét nguồn giấy thông hành [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_07"></a>
### 322. Người nếm thức ăn vắng mặt

- **Mã:** `security_07` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Tiếp tục tiệc theo lệ cũ”.

**Nội dung tấu chương:**

> Người phụ trách nếm món ăn bỗng mất tích trước buổi tiệc có nhiều khách.

#### Phương án 1 — Cấp phí điều tra kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét toàn đội phục vụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Tiếp tục tiệc theo lệ cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_08"></a>
### 323. Dây neo thuyền ngự bị cắt

- **Mã:** `security_08` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không sửa quy trình bảo vệ”.

**Nội dung tấu chương:**

> Thị vệ thấy một đoạn dây neo mỏng khác thường trước chuyến đi sông.

#### Phương án 1 — Cấp phí bảo vệ chuyến đi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng nhóm giữ thuyền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Không sửa quy trình bảo vệ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_09"></a>
### 324. Khách lạ được dẫn qua vườn ngự

- **Mã:** `security_09` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để quản sự tự định khách”.

**Nội dung tấu chương:**

> Một quản sự đưa khách không ghi tên qua đường vua thường đi dạo.

#### Phương án 1 — Tự kiểm tra việc dẫn khách

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền để cho giữ lối riêng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để quản sự tự định khách [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_10"></a>
### 325. Lưỡi dao trong kiện vải

- **Mã:** `security_10` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cho qua vì chưa ai bị hại”.

**Nội dung tấu chương:**

> Người nhận hàng phát hiện dao ngắn nằm trong kiện vải gửi vào cung.

#### Phương án 1 — Cấp phí lần theo nguồn kiện hàng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét rộng các kho hàng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Cho qua vì chưa ai bị hại [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_11"></a>
### 326. Lịch đi của vua bị lộ

- **Mã:** `security_11` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ nguyên lịch đi công khai”.

**Nội dung tấu chương:**

> Một người bán hàng ngoài thành biết chính xác giờ vua dự định ra ngoài.

#### Phương án 1 — Chi phí bảo vệ và đổi lịch

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng người giữ lịch

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Giữ nguyên lịch đi công khai [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_12"></a>
### 327. Lính canh bán ca trực

- **Mã:** `security_12` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để các đội tự đổi người”.

**Nội dung tấu chương:**

> Một số ca gác gần điện được chuyển cho người lạ bằng tiền riêng.

#### Phương án 1 — Tự kiểm tra danh sách trực

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Thu tiền để bỏ qua việc đổi ca

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Để các đội tự đổi người [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_13"></a>
### 328. Ấm thuốc có mùi lạ

- **Mã:** `security_13` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Dùng thuốc chưa kiểm chứng”.

**Nội dung tấu chương:**

> Thầy thuốc nói vị thuốc gửi đến có mùi khác, kho chưa biết ai đã chạm vào.

#### Phương án 1 — Cấp phí điều tra đường thuốc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét toàn bộ người trong kho

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Dùng thuốc chưa kiểm chứng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_14"></a>
### 329. Mái hiên trên lối vua đi bị lỏng

- **Mã:** `security_14` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ lối đi chưa kiểm tra”.

**Nội dung tấu chương:**

> Người thợ báo chốt mái hiên bị rút trước giờ vua qua hành lang.

#### Phương án 1 — Cấp phí bảo vệ và gia cố lối đi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng nhóm coi hành lang

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Giữ lối đi chưa kiểm tra [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_15"></a>
### 330. Người bán quyền gặp riêng

- **Mã:** `security_15` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét người bán quyền gặp”.

**Nội dung tấu chương:**

> Một thân tín nhận tiền hứa cho khách gặp vua ngoài sổ triều kiến.

#### Phương án 1 — Tự kiểm tra các cuộc gặp kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận khoản nộp để giữ lệ gặp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa xét người bán quyền gặp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_16"></a>
### 331. Mật hiệu đổi nhưng đồn chưa biết

- **Mã:** `security_16` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chấp nhận mật hiệu chưa xác nhận”.

**Nội dung tấu chương:**

> Một trạm gác nhận mật hiệu mới không có chữ ký người phụ trách.

#### Phương án 1 — Cấp phí điều tra người gửi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét người mang mật hiệu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Chấp nhận mật hiệu chưa xác nhận [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_17"></a>
### 332. Hộ vệ bị theo dõi ở chợ

- **Mã:** `security_17` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để hộ vệ tự xử việc theo dõi”.

**Nội dung tấu chương:**

> Một hộ vệ nhận ra người lạ ghi thói quen đi lại của mình nhiều ngày.

#### Phương án 1 — Chi phí bảo vệ đội hộ vệ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng những người bị nghi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Để hộ vệ tự xử việc theo dõi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_18"></a>
### 333. Xe chở hàng không qua kiểm cửa

- **Mã:** `security_18` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa động tới lối xe riêng”.

**Nội dung tấu chương:**

> Một thương nhân được miễn khám xe gần ngự điện nhờ quen quản sự.

#### Phương án 1 — Tự kiểm tra lệnh miễn khám

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền để giữ lối miễn khám

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa động tới lối xe riêng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_19"></a>
### 334. Đèn tín hiệu lạ trên tháp

- **Mã:** `security_19` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua vì chưa có chứng cứ”.

**Nội dung tấu chương:**

> Thị vệ thấy đèn nháy theo nhịp ở một tháp không có người trực được ghi tên.

#### Phương án 1 — Cấp phí theo dấu tín hiệu

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét rộng khu quanh tháp

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Bỏ qua vì chưa có chứng cứ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_20"></a>
### 335. Thư đe dọa gia đình thị vệ

- **Mã:** `security_20` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Để thị vệ tự lo gia đình”.

**Nội dung tấu chương:**

> Một thị vệ xin đổi vị trí vì gia đình bị đe dọa nếu không mở cổng.

#### Phương án 1 — Cấp phí bảo vệ cả gia đình

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng nhóm bị nghi liên quan

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Để thị vệ tự lo gia đình [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_21"></a>
### 336. Bản vẽ ngự phòng bị rao bán

- **Mã:** `security_21` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa kiểm tra nguồn bản vẽ”.

**Nội dung tấu chương:**

> Một người buôn đồ cũ giữ bản vẽ chi tiết hành lang cạnh nơi vua ngủ.

#### Phương án 1 — Tự kiểm tra đường rò bản vẽ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận tiền và ngừng truy xét

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa kiểm tra nguồn bản vẽ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="event-security_22"></a>
### 337. Tin mật về người thay đầu bếp

- **Mã:** `security_22` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ qua tin về đầu bếp”.

**Nội dung tấu chương:**

> Có người trả tiền để đưa đầu bếp lạ vào ca phục vụ vua, chưa rõ kẻ đứng sau.

#### Phương án 1 — Cấp phí điều tra kín

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn An ninh. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa chọn phương án: Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −3. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 50 · uy quyền +1 · Cuối mùa chọn phương án: 50% thành công: âm mưu -4 · Ổn định triều đình +1. Thất bại: âm mưu +5 · uy quyền -3. · Không giao ai: 50% thành công

#### Phương án 2 — Khám xét các nhóm phục vụ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Lòng dân −3; Thái độ phe Võ tướng +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu -4 · lòng dân -3 · phe Võ tướng +1

#### Phương án 3 — Bỏ qua tin về đầu bếp [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Uy quyền −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · uy quyền -2

<a id="event-security_23"></a>
### 338. Người xin mở cổng giữa đêm

- **Mã:** `security_23` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Cho đội gác tự xử”.

**Nội dung tấu chương:**

> Một lệnh miệng yêu cầu thị vệ mở cổng dù vua chưa ban chỉ.

#### Phương án 1 — Cấp phí bảo vệ và xác minh lệnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Ổn định triều đình +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 60 · âm mưu -4 · Ổn định triều đình +1

#### Phương án 2 — Thanh trừng người bị nghi truyền lệnh

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +2; Ổn định triều đình −4; Thái độ phe Văn thần −3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +2 · Ổn định triều đình -4 · phe Văn thần -3

#### Phương án 3 — Cho đội gác tự xử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0); Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** âm mưu +5 · Ổn định triều đình -2

<a id="event-security_24"></a>
### 339. Khoản tiền lạ vào nhà quản sự

- **Mã:** `security_24` · **Nhóm:** An ninh.
- **Điều kiện xuất hiện:** Có một nhân vật còn hoạt động có tiến độ âm mưu ≥30. Mã điều kiện: `plot`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `security`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa xét khoản tiền lạ”.

**Nội dung tấu chương:**

> Quản sự gần vua nhận khoản tiền lớn và không giải thích được nguồn.

#### Phương án 1 — Tự kiểm tra khoản tiền và quan hệ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Tiến độ âm mưu mỗi nhân vật −4 (tối thiểu 0); Mệt mỏi +3.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · âm mưu -4 · mệt mỏi +3

#### Phương án 2 — Nhận khoản nộp để thôi tra

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Tiến độ âm mưu mỗi nhân vật +4 (tối thiểu 0); Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · âm mưu +4 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa xét khoản tiền lạ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền −3; Tiến độ âm mưu mỗi nhân vật +5 (tối thiểu 0).
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền -3 · âm mưu +5

<a id="group-18"></a>
## Nhóm 18 — Văn hóa

<a id="event-culture_01"></a>
### 424. Lớp học cho trẻ ở bến sông

- **Mã:** `culture_01` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở lớp bến sông”.

**Nội dung tấu chương:**

> Người dân xin mở lớp chữ nhưng thiếu tiền mua bảng và thuê người dạy.

#### Phương án 1 — Đầu tư lớp học chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Dành việc học cho nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa mở lớp bến sông [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_02"></a>
### 425. Sân diễn chung của dân

- **Mã:** `culture_02` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa quyết sân diễn”.

**Nội dung tấu chương:**

> Các phường muốn dựng sân diễn công cộng, một nhà giàu xin thu tiền độc quyền.

#### Phương án 1 — Cấp tiền cho sân chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu tiền sân diễn

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa quyết sân diễn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_03"></a>
### 426. Thợ tìm cách nung gạch mới

- **Mã:** `culture_03` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ đề nghị nung gạch”.

**Nội dung tấu chương:**

> Một nhóm thợ muốn thử lò ít hao củi nhưng cần vốn và có thể hỏng mẻ đầu.

#### Phương án 1 — Đầu tư thử lò mới

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự cùng học và hướng dẫn thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Bỏ đề nghị nung gạch [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_04"></a>
### 427. Sách đọc cho làng xa

- **Mã:** `culture_04` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đưa sách về làng”.

**Nội dung tấu chương:**

> Thầy đồ xin đưa sách và mở lớp luân phiên cho những làng chưa có người dạy.

#### Phương án 1 — Đầu tư sách và lớp chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Chỉ cấp học cho con nhà danh giá

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa đưa sách về làng [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_05"></a>
### 428. Ngày hội sau vụ gặt

- **Mã:** `culture_05` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa tổ chức ngày hội”.

**Nội dung tấu chương:**

> Dân muốn có ngày hội chung, nhà buôn xin tài trợ nếu được quyền thu vé.

#### Phương án 1 — Cấp tiền cho hội mở

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu vé ngày hội

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa tổ chức ngày hội [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_06"></a>
### 429. Giấy từ thân cây lạ

- **Mã:** `culture_06` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Không thử nguyên liệu mới”.

**Nội dung tấu chương:**

> Thợ giấy muốn thử nguyên liệu mới để giảm giá, nhưng mẻ đầu có thể thất bại.

#### Phương án 1 — Đầu tư thử cách làm giấy

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự học cùng nhóm thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Không thử nguyên liệu mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_07"></a>
### 430. Người lớn xin học tính sổ

- **Mã:** `culture_07` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở lớp tính sổ”.

**Nội dung tấu chương:**

> Các tiểu thương xin lớp tính để tránh bị gian cân và lừa giấy nợ.

#### Phương án 1 — Đầu tư lớp tính cho dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Ưu tiên học cho nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa mở lớp tính sổ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_08"></a>
### 431. Kho lưu nhạc của các phường

- **Mã:** `culture_08` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa giữ kho nhạc”.

**Nội dung tấu chương:**

> Nhiều bản nhạc sắp thất truyền, dân muốn nơi tập chung không thu phí cao.

#### Phương án 1 — Cấp tiền giữ nơi tập chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Cho nhà giàu khai thác thu tiền

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa giữ kho nhạc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_09"></a>
### 432. Bàn xoay mới của thợ gốm

- **Mã:** `culture_09` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ thử bàn xoay mới”.

**Nội dung tấu chương:**

> Một thợ gốm mang mẫu bàn xoay có thể làm nhanh hơn nhưng cần thử lâu.

#### Phương án 1 — Đầu tư thử bàn xoay

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự học và góp cách làm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Bỏ thử bàn xoay mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_10"></a>
### 433. Trẻ em vùng núi xin người dạy

- **Mã:** `culture_10` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa đưa người dạy lên núi”.

**Nội dung tấu chương:**

> Một đoàn dân miền núi xin lớp chung vì đi học ở kinh quá xa và tốn kém.

#### Phương án 1 — Đầu tư lớp vùng núi

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Dành suất học cho nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa đưa người dạy lên núi [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_11"></a>
### 434. Nhà đọc sách ở khu chợ

- **Mã:** `culture_11` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở nhà đọc sách”.

**Nội dung tấu chương:**

> Dân muốn nơi đọc chung, một nhà bảo trợ xin thu phí để đổi lấy tiền xây.

#### Phương án 1 — Cấp tiền nhà đọc công cộng

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu phí nhà đọc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa mở nhà đọc sách [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_12"></a>
### 435. Dụng cụ đo ruộng cải tiến

- **Mã:** `culture_12` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ dụng cụ đo cũ”.

**Nội dung tấu chương:**

> Một nhóm thợ muốn thử thước đo mới để giảm tranh chấp, kết quả chưa được kiểm chứng.

#### Phương án 1 — Đầu tư thử dụng cụ đo

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự nghiên cứu cùng thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Giữ dụng cụ đo cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_13"></a>
### 436. Lớp chữ cho người giải ngũ

- **Mã:** `culture_13` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở lớp giải ngũ”.

**Nội dung tấu chương:**

> Người rời quân ngũ muốn học đọc để tìm nghề mới và hiểu giấy thuê đất.

#### Phương án 1 — Đầu tư lớp học chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Ưu tiên học cho người có thế lực

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa mở lớp giải ngũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_14"></a>
### 437. Phường hát muốn diễn ở quảng trường

- **Mã:** `culture_14` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa duyệt buổi diễn”.

**Nội dung tấu chương:**

> Phường hát xin hỗ trợ buổi diễn dân chúng, một thế gia muốn đứng ra bán chỗ.

#### Phương án 1 — Cấp tiền diễn cho dân

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu tiền chỗ xem

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa duyệt buổi diễn [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_15"></a>
### 438. Khung dệt mới tiết kiệm sợi

- **Mã:** `culture_15` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa thử khung mới”.

**Nội dung tấu chương:**

> Thợ dệt muốn thử khung mới nhưng phải chấp nhận một số mẻ vải hỏng.

#### Phương án 1 — Đầu tư thử khung dệt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự học cùng nhóm thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Chưa thử khung mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_16"></a>
### 439. Sách thuốc dễ đọc cho dân

- **Mã:** `culture_16` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa phổ biến sách thuốc”.

**Nội dung tấu chương:**

> Thầy đồ xin làm sách hướng dẫn cơ bản để dân biết tìm người chữa đúng lúc.

#### Phương án 1 — Đầu tư phổ biến sách chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Chỉ dạy nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa phổ biến sách thuốc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_17"></a>
### 440. Lễ tưởng nhớ người giữ làng

- **Mã:** `culture_17` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa quyết lễ tưởng nhớ”.

**Nội dung tấu chương:**

> Dân muốn tổ chức lễ chung, một dòng họ muốn biến thành dịp thu tiền riêng.

#### Phương án 1 — Cấp tiền cho lễ chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Nhượng quyền thu tiền dịp lễ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa quyết lễ tưởng nhớ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_18"></a>
### 441. Kính đọc chữ do thợ thử làm

- **Mã:** `culture_18` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ đề nghị chế kính”.

**Nội dung tấu chương:**

> Một thợ mang mẫu kính nhưng cần vốn thử nhiều loại mặt kính để dùng được.

#### Phương án 1 — Đầu tư thử kính đọc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự nghiên cứu cùng thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Bỏ đề nghị chế kính [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_19"></a>
### 442. Lớp dạy cân đo cho phụ việc

- **Mã:** `culture_19` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở lớp phụ việc”.

**Nội dung tấu chương:**

> Người làm thuê muốn học đơn vị đo để không bị thiệt khi lĩnh công.

#### Phương án 1 — Đầu tư lớp cân đo chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Dành việc học cho nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa mở lớp phụ việc [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_20"></a>
### 443. Chỗ tập cho đoàn múa rối

- **Mã:** `culture_20` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp nơi tập”.

**Nội dung tấu chương:**

> Đoàn múa rối muốn nơi tập và diễn cho dân, một nhà buôn đề nghị thu vé độc quyền.

#### Phương án 1 — Cấp tiền nơi tập chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu vé múa rối

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa cấp nơi tập [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_21"></a>
### 444. Màu nhuộm từ cây ven núi

- **Mã:** `culture_21` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa thử màu mới”.

**Nội dung tấu chương:**

> Thợ muốn thử màu mới nhưng chưa biết có bền qua nhiều lần giặt hay không.

#### Phương án 1 — Đầu tư thử màu nhuộm

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự học và góp ý cùng thợ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Chưa thử màu mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_22"></a>
### 445. Người mù xin lớp học kể chuyện

- **Mã:** `culture_22` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa cấp lớp học nghề”.

**Nội dung tấu chương:**

> Người khiếm thị muốn học nghề kể chuyện qua lớp chung do làng tổ chức.

#### Phương án 1 — Đầu tư lớp học tiếp cận được

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Chỉ ưu tiên người có danh giá

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa cấp lớp học nghề [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_23"></a>
### 446. Ngày mở cửa kho bản đồ

- **Mã:** `culture_23` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở kho bản đồ”.

**Nội dung tấu chương:**

> Dân xin xem bản đồ địa phương, một nhà bảo trợ muốn giữ quyền thu tiền vào cửa.

#### Phương án 1 — Cấp tiền cho ngày mở chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu phí xem bản đồ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa mở kho bản đồ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_24"></a>
### 447. Hộp giữ hạt giống khô

- **Mã:** `culture_24` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 5 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Giữ cách cất hạt cũ”.

**Nội dung tấu chương:**

> Một thợ mộc đề nghị thử hộp mới chống ẩm, nhưng thử nghiệm có thể không đạt.

#### Phương án 1 — Đầu tư thử hộp giữ hạt

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự nghiên cứu cùng thợ mộc

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Giữ cách cất hạt cũ [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

<a id="event-culture_25"></a>
### 448. Thư viện nhỏ ở trạm xa

- **Mã:** `culture_25` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 2 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa mở thư viện trạm”.

**Nội dung tấu chương:**

> Người coi trạm muốn lớp đọc và tủ sách cho con em dân quanh đường trạm.

#### Phương án 1 — Đầu tư tủ sách và lớp chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥60 (chi 60 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1.
- **Kết quả chờ — thành công 100%:** cuối mùa chọn phương án: Lòng dân +3; Uy quyền +1.
- **Mô tả lựa chọn trên UI:** Chi 60 · lòng dân +1 · Cuối mùa chọn phương án: 100% thành công: lòng dân +3 · uy quyền +1.

#### Phương án 2 — Chỉ cấp học cho nhóm tinh hoa

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1; Thái độ phe Văn thần +1; Lòng dân −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** uy quyền +1 · phe Văn thần +1 · lòng dân -2

#### Phương án 3 — Chưa mở thư viện trạm [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Thái độ phe Văn thần −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · phe Văn thần -1

<a id="event-culture_26"></a>
### 449. Buổi kể sử ngoài thành

- **Mã:** `culture_26` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 3 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Chưa duyệt buổi kể sử”.

**Nội dung tấu chương:**

> Các làng xin buổi kể sử chung, một nhà giàu muốn đổi hỗ trợ lấy quyền bán chỗ.

#### Phương án 1 — Cấp tiền cho buổi kể chung

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥50 (chi 50 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình +1; Lòng dân +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Chi 50 · Ổn định triều đình +1 · lòng dân +1

#### Phương án 2 — Bán quyền thu tiền người nghe

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ngân khố +20; Lòng dân −3; Thái độ phe Thế gia +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** ngân khố +20 · lòng dân -3 · phe Thế gia +1 · Tiền nhận ngay 20 · sau phí +20.

#### Phương án 3 — Chưa duyệt buổi kể sử [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Ổn định triều đình −2.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** Ổn định triều đình -2

<a id="event-culture_27"></a>
### 450. Thợ trẻ chế bình nước đo canh giờ

- **Mã:** `culture_27` · **Nhóm:** Văn hóa.
- **Điều kiện xuất hiện:** Không có điều kiện chỉ số riêng. Mã điều kiện: `any`.
- **Mốc mở tối thiểu theo cấu hình:** từ mùa thứ 1 (mùa Xuân · năm 1); còn phải thỏa điều kiện xuất hiện trên.
- **Giãn lặp cùng mã:** 4 mùa. Nhóm nội dung: `culture`.
- **Hạn:** được giữ sang mùa kế tiếp, phải xử lý trước khi khép mùa kế tiếp.
- **Khi quá hạn:** chọn mặc định phương án 3 — “Bỏ việc thử đo giờ mới”.

**Nội dung tấu chương:**

> Một thợ trẻ xin chế bình cho nước nhỏ giọt để đo canh giờ, nhưng kết quả có thể sai nếu vật liệu không đạt.

#### Phương án 1 — Đầu tư thử bình nước đo giờ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; ngân khố ≥25 (chi 25 tiền).
- **Tác động ngay — lợi ích và đánh đổi:** Uy quyền +1.
- **Người xử lý tùy chọn:** chuyên môn Cung đình. Không giao ai: 50%; giao người đủ điều kiện: 55–85%. Tỷ lệ cụ thể phụ thuộc nhân vật được chọn.
- **Kết quả chờ — thành công 50% khi không giao ai:** cuối mùa sau nữa (sau 2 mùa): Ngân khố +70; Lòng dân +2.
- **Kết quả chờ — thất bại 50% khi không giao ai:** cùng thời điểm: Uy quyền −1. Chi phí đã trả không được hoàn lại.
- **Mô tả lựa chọn trên UI:** Chi 25 · uy quyền +1 · Cuối mùa sau nữa (sau 2 mùa): 50% thành công: ngân khố +70 · lòng dân +2. Thất bại: uy quyền -1. · Vốn/phí ứng 25 tiền · Thành công: nhận 70 tiền, lãi sau vốn 45 tiền · Thất bại: mất 25 tiền đã ứng, không phạt thêm tiền · Nhận kết quả cuối mùa sau nữa (sau 2 mùa) · Không giao ai: 50% thành công

#### Phương án 2 — Tự học cùng nhóm thợ trẻ

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân +1; Mệt mỏi +3; Thái độ phe Văn thần +1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân +1 · mệt mỏi +3 · phe Văn thần +1

#### Phương án 3 — Bỏ việc thử đo giờ mới [mặc định khi quá hạn]

- **Yêu cầu / chi phí khi chủ động chọn:** 1 hành động; không yêu cầu tiền/thóc trả trước.
- **Tác động ngay — lợi ích và đánh đổi:** Lòng dân −2; Uy quyền −1.
- **Kết quả trì hoãn riêng:** không có.
- **Mô tả lựa chọn trên UI:** lòng dân -2 · uy quyền -1

## Phụ lục — công trình sửa đê và kết quả phụ thuộc nhân vật

- Sửa đê khởi tạo từ tấu chương hoàn tất cuối mùa chọn. Không giao ai dùng tỷ lệ nền 35%; nếu đã giao người thì người đó phải còn đủ điều kiện tới hạn. Thay quan không tự chuyển phân công tấu chương cho người mới; mất người phụ trách làm công việc gián đoạn. Phí ban đầu đã chi theo lựa chọn, không trừ lại khi hoàn tất.
- Điểm đánh giá người xử lý = làm tròn [20 + 0,6×năng lực + 0,25×độ phù hợp − ⌊mệt công vụ/8⌋ + điều chỉnh tính cách/quan hệ − nguy cơ phá việc], giới hạn 5–95. Điểm cộng tỷ lệ = làm tròn [điểm đánh giá ×0,4], giới hạn 5–35 điểm %. Tỷ lệ thành công = nền không giao ai + điểm cộng, tối đa 95%. Chỉ dùng tính cách đã biết; trung thành chưa xác minh được thay bằng giá trị trung tính 50, nên tỷ lệ hiển thị và tỷ lệ được chốt luôn thống nhất và không tiết lộ phẩm chất ẩn. Độ phù hợp chuyên môn là 100/65/20 cho đúng/liên quan/trái chuyên môn.
- Hiệu quả thưởng = làm tròn [45 + 0,6×năng lực + 0,3×độ phù hợp − ⌊mệt công vụ/5⌋ + điều chỉnh tính cách], giới hạn 10–180%. Phần thưởng cơ bản được nhân tỷ lệ này, làm tròn, tối thiểu 1; sau đó có thể thất thoát do phẩm chất. Quan hệ và bất mãn ảnh hưởng hợp tác, còn liêm chính ảnh hưởng thất thoát.
- Sửa đê thành công: tăng đê điều từ cơ bản 30 theo hiệu quả và phần nhận được sau thất thoát. Thất bại thường: đê điều −4, lòng dân −2. Thất bại nặng: đê điều −8, lòng dân −4, uy quyền −3, ngân khố −15, ngoài phí đã cấp.
- Kiểm toán, mật thám, ngoại giao và sửa đê mới đều dùng tỷ lệ nền 35% nếu không giao ai; có người sẽ cộng theo đánh giá trên. Chỉ các kết quả chờ được tạo trước 0.16.0 mới giữ cơ chế cũ.

## Nguồn đối chiếu

- [`lib/game/data/content.dart`](../lib/game/data/content.dart)
- [`lib/game/data/expanded_events.dart`](../lib/game/data/expanded_events.dart)
- [`lib/game/data/event_stories.dart`](../lib/game/data/event_stories.dart)
- [`lib/game/logic/petition_rules.dart`](../lib/game/logic/petition_rules.dart)
- [`lib/game/logic/petition_assignment_rules.dart`](../lib/game/logic/petition_assignment_rules.dart)
- [`lib/game/logic/petition_engine.dart`](../lib/game/logic/petition_engine.dart)
- [`lib/game/logic/game_engine.dart`](../lib/game/logic/game_engine.dart)
- [`lib/game/logic/personnel_rules.dart`](../lib/game/logic/personnel_rules.dart)
- [`lib/game/logic/personality_rules.dart`](../lib/game/logic/personality_rules.dart)
