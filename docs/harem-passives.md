# Passive hậu cung — 0.13.0

Chỉ áp dụng cho lượt theo mùa, trả khi khép mùa. Tú nữ là người chưa nhập cung, có thể xem trước tiềm năng; chỉ người trưởng thành đang hiện diện, đã nhập cung mới đóng góp.

| Điều kiện | Đóng góp |
|---|---|
| Thiện cảm ≤70 hoặc năng lực ≤60 | Không có passive |
| Thiện cảm 71–95, năng lực 61–100 | +1 chỉ số/mùa |
| Thiện cảm 96–100, năng lực 61–100 | +2 chỉ số/mùa |
| Hoàng hậu năng lực 91–100, thiện cảm >70 | Thêm một passive chỉ số khác, cùng mức +1/+2 |
| Người có Gia sản, thuộc Thế gia/Hoàng tộc, đủ điều kiện | +10 ngân khố/mùa; không nhân đôi ở thiện cảm >95 |

Mỗi người có một passive chính. Tính cách đầu tiên luôn đã công khai: Gần dân/Liêm khiết/Công tâm/Cương trực cho Lòng dân; Quyết đoán/Kỷ luật/Nóng nảy/Háo danh/Liều lĩnh cho Uy quyền; các tính cách khác cho Ổn định. Một số người Thế gia/Hoàng tộc có Gia sản thay cho passive chỉ số: tính cách đầu là Vị gia tộc, hoặc mã nhân vật có `personalitySeed(id) % 3 == 0`. Quy tắc này cố định theo ID, không tiêu thụ RNG, không đọc hoặc làm lộ tính cách ẩn. Văn thần/Võ tướng không nhận Gia sản.

Passive bổ sung của Hoàng hậu là Ổn định; nếu chính đã là Ổn định thì thêm Uy quyền. Cần năng lực >90 và thiện cảm >70. Không cộng thêm bonus ổn định theo mùa cũ; hiệu ứng ổn định tức thì khi sắc phong vẫn giữ. Đổi ngôi hậu dừng passive bổ sung của người cũ, giữ passive chính nếu vẫn đủ điều kiện.

Giới hạn toàn hậu cung mỗi mùa: Uy quyền +3, Lòng dân +3, Ổn định +3, Ngân khố +20. Phân bổ theo ID nhân vật ổn định; khoản vượt giới hạn không trả, không để dành. Nhật ký ghi số đóng góp được nhận và phần bị giới hạn. Đây là mức cộng trước giới hạn chỉ số 0–100; thẻ nhân vật cho biết điều kiện cá nhân, tổng dự kiến cho biết số sau giới hạn toàn hậu cung.

Chốt điều kiện sau hậu quả tấu chương quá hạn/bỏ bê, khi bắt đầu tính kinh tế. Thuế, chi phí và biến động thiện cảm ở các bước sau không làm đổi ảnh chụp của lần chốt đó. Lợi ích tiền nằm trong `budgetIncome`, được cộng đúng một lần trước chi thường lệ; sổ tiền ghi riêng từng người, tổng chưa trừ chi sinh hoạt 6/người/mùa. Tải lại/gửi lặp không trả lần nữa. Bản lưu cũ không được truy lĩnh mùa đã qua, không đổi RNG hay số hành động khi nâng 0.12 lên 0.13.

Trò chuyện với một nhân vật: thái độ phe đối lập −3, thiện cảm mỗi nhân vật còn hiện diện thuộc phe đó −2, gồm cả tú nữ chưa nhập cung và phi tần. Người đã rời danh sách không bị ảnh hưởng. Cơ chế này đã tồn tại trong engine; UI và kiểm thử mới làm rõ phạm vi. Khi thiện cảm giảm qua ngưỡng, passive cập nhật ngay trong dự kiến, không truy thu đóng góp mùa trước.
