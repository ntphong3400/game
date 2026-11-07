# Preview tỷ lệ thành công theo năng lực và mệt công vụ

Các ô là tỷ lệ thành công (%). Quan hệ, tính cách và phá việc có điều chỉnh ròng bằng 0.

```text
Phạt mệt = 4 × phần nguyên(mệt / 10)
Điểm hiệu dụng = năng lực − phạt mệt + các điều chỉnh khác
Tỷ lệ = 30 + làm tròn(0,6 × điểm hiệu dụng)
Giới hạn khi giao người: 35–90%. Không giao ai: 30%.
```

| Năng lực | Mệt 0 | Mệt 20 | Mệt 40 | Mệt 60 | Mệt 80 | Mệt 100 |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 35 | 35 | 35 | 35 | 35 | 35 |
| 10 | 36 | 35 | 35 | 35 | 35 | 35 |
| 20 | 42 | 37 | 35 | 35 | 35 | 35 |
| 30 | 48 | 43 | 38 | 35 | 35 | 35 |
| 40 | 54 | 49 | 44 | 40 | 35 | 35 |
| 41 | 55 | 50 | 45 | 40 | 35 | 35 |
| 50 | 60 | 55 | 50 | 46 | 41 | 36 |
| 60 | 66 | 61 | 56 | 52 | 47 | 42 |
| 70 | 72 | 67 | 62 | 58 | 53 | 48 |
| 80 | 78 | 73 | 68 | 64 | 59 | 54 |
| 90 | 84 | 79 | 74 | 70 | 65 | 60 |
| 100 | 90 | 85 | 80 | 76 | 71 | 66 |

- Nhận một công việc: +20 mệt, tối đa 100.
- Cuối mùa: giảm 10 nếu rảnh, giảm 5 nếu còn bận; tối thiểu 0.
- Tỷ lệ được chốt trước khi cộng mệt do nhận việc; công việc đang chờ giữ tỷ lệ và nhánh đã chốt.
- Đúng chuyên môn là điều kiện nhận việc, không cộng điểm cố định. Không còn điểm nền đánh giá +20.
- Hậu cung dùng thiện cảm làm đầu vào thay năng lực như cơ chế hiện tại.

Xuất lại bằng `dart run tools/preview_petition_chance.dart`. Dữ liệu được tính trực tiếp bằng `petitionChance()`, không đọc/sửa bản lưu.
