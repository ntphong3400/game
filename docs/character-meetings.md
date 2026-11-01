# Trang chi tiết nhân vật toàn thân

Trang **Gặp gỡ** ở Hậu cung và **Triệu kiến** ở Triều thần đều mở cảnh toàn màn hình theo mẫu Ngọc Lan và Thanh Mai đã duyệt. Các lối mở từ Phủ nha cũng dùng trang này và quay về đúng Địa phương.

## Bộ ảnh

- 90 diện mạo: 30 hậu cung và 60 triều thần, gồm cả khuôn mặt dùng cho ứng viên tuyển mới.
- Giữ nguyên ảnh Ngọc Lan và mẫu Thanh Mai được duyệt. Các ảnh mới là từng nhân vật riêng trên canvas dọc, thấy đủ đầu, tay, thân người và giày; tỷ lệ cơ thể theo mẫu được duyệt.
- Nhân vật nữ dùng chung `assets/images/harem-interior.webp`; triều thần dùng `assets/images/people-interior.webp`.
- Ảnh toàn thân theo `resolvedPortraitId`, không dựa vào chức vụ hiện tại. Nhân vật giữ diện mạo khi bổ nhiệm, nhập cung và tải lại bản lưu.
- Mỗi diện mạo hiện có một ảnh toàn thân. Bộ chân dung ba độ tuổi trong danh sách vẫn giữ cơ chế đổi ở tuổi 35/55; ảnh toàn thân không phải bộ ba tuổi.
- PNG gốc và prompt/biên nhận ở `output/meeting-generation/`. Tệp chạy game ở `assets/images/meetings/`; ảnh mới mã hóa WebP có alpha, giữ nguyên kích thước và tỷ lệ, không chỉnh hình thể bằng mã.

Xem toàn bộ tại [gallery](../output/meeting-generation/review.html), [30 diện mạo hậu cung](../output/meeting-generation/review-harem.png), [triều thần 001–030](../output/meeting-generation/review-officials-1.png), [triều thần 031–060](../output/meeting-generation/review-officials-2.png). [Prompt](../output/meeting-generation/prompts.json) ghi cách tạo từng ảnh bằng built-in `image_gen`; [manifest](../output/meeting-generation/manifest.json) ghi kích thước bộ ảnh và hash chống trùng tệp.

## Thao tác

Trang chi tiết cập nhật tên, vai trò, tuổi, thiện cảm và năng lực từ cùng trạng thái game. Âm mưu/bất mãn chỉ hiện số liệu cuộc điều tra đã hoàn tất; không dùng giá trị ẩn đang chạy.

Trò chuyện, ban thưởng và điều tra kín dùng cùng luồng xác nhận. Hậu cung có các nút trực tiếp: tuyển vào cung, trục xuất, giáng chức; Phi tần có Sắc phong Hoàng hậu, người đã nhập cung có Cùng dạo Ngự uyển và học tập/cung vụ theo điều kiện của lượt theo mùa. Bỏ nút Hồ sơ & cung vụ, các thao tác chỉ xuất hiện một lần. Sắc phong/dạo vườn có xác nhận với chi phí và tác động; Theo học và Giao cung vụ mở thẳng hộp chọn/xác nhận chuyên biệt, không hỏi xác nhận trùng. Ba badge Hoàng hậu/Phi tần/Tú nữ có màu và biểu tượng riêng, nằm dưới tên ở cả danh sách và trang Gặp gỡ; đổi ngay khi tuyển, sắc phong hoặc giáng chức. Trạng thái bận vẫn nằm dưới avatar ở danh sách, nút Gặp gỡ neo đáy thẻ. Sau khi trục xuất nhân vật, trang chi tiết đóng để quay về danh sách.

Triều thần hệ 9 phẩm có Thăng phẩm mở danh sách phẩm cao hơn, khóa mức chưa đạt; Cho hồi hương nằm trong nhóm hành động. Badge cá nhân dùng chung bộ màu/biểu tượng/số 1–9 ở danh sách, trang chi tiết và popup thăng phẩm.

Mở/đóng trang không tốn tài nguyên và không thay đổi RNG hoặc bản lưu. Đóng thông báo cũ khi vào cảnh gặp gỡ để thông báo từ trang trước không che nút trên điện thoại.

## Tái tạo và kiểm tra

```sh
dart run tools/export_meeting_cast.dart
python3 tools/package_meeting_gallery.py --require-complete
swift tools/meeting_art_review.swift
flutter test test/meeting_scenes_test.dart test/official_meeting_ui_test.dart test/character_meeting_ui_test.dart test/harem_ui_test.dart test/meeting_actions_ui_test.dart test/character_reward_ui_test.dart test/game_ui_test.dart test/personality_ui_test.dart test/locality_hub_test.dart
flutter test tools/all_meetings_visual_test.dart
flutter build web --release --no-web-resources-cdn
```

`package_meeting_art.py` chỉ sao chép ảnh `image_gen` và mã hóa WebP; không gọi API tạo ảnh. Gallery và bản đồ asset được tạo từ manifest prompt, kiểm tra đủ 90 đường dẫn và không trùng hash. Ảnh thực tế desktop/mobile nằm trong `output/meeting-generation/screenshots/`.

Kiểm tra thao tác Hậu cung trực tiếp: `test/harem_rank_actions_ui_test.dart`, ảnh bằng `flutter test test/harem_rank_actions_ui_test.dart --dart-define=HAREM_RANK_ACTION_PREVIEWS=true` tại `output/harem-rank-actions/`.
