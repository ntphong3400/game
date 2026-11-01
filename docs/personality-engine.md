# Engine tính cách — 0.9.0

Luật `mvp-0.9.0`, nội dung 9, schema 2. Tính cách dùng enum có ID ổn định; chuỗi `trait` cũ chỉ giữ để tương thích bản lưu. Engine không phân tích lời mô tả khi thực hiện công việc.

## Khởi tạo và khám phá

- Nhân vật mới có 2–3 tính cách không mâu thuẫn. Áp dụng cả quan lại, người được tiến cử, hậu cung và người kế nhiệm.
- Ban đầu chỉ biết tính cách đầu tiên. Với mỗi nhân vật, `personalityContacts` tăng 1 sau một lệnh `audience` hợp lệ đã trả hành động; không tăng nếu lệnh thất bại hoặc gateway nhận lại cùng mã yêu cầu.
- Số tính cách đã biết = min(tổng số, 1 + số lần tiếp xúc ~/ 3). Lần 3 mở tính cách thứ hai, lần 6 mở thứ ba, lần 9 mở thứ tư nếu nhân vật có bốn tính cách trong dữ liệu.
- Ban thưởng, dạo vườn, phong hậu và điều tra không tăng tiến độ tìm hiểu. Điều tra vẫn xác minh trung thành, tham vọng và liêm chính như trước.
- Tính cách ẩn đã ảnh hưởng thực tế từ đầu. Khi khám phá, ghi một mục sử ký và cập nhật hồ sơ nhân vật. Không xóa tiến độ khi đổi tuần hoặc chức vụ; người kế nhiệm là một người khác, có tiến độ riêng.

## Hai loại đánh giá

`TaskAssessment` thực thi dùng đầy đủ phẩm chất. `TaskAssessment.preview` chỉ dùng tính cách đã khám phá; trung thành/liêm chính chưa điều tra được ước lượng trung tính 50. Thiện cảm cá nhân, phe, năng lực, chuyên môn, mệt mỏi là thông tin công khai.

Danh sách gợi ý công việc thường sắp xếp bằng dự báo công khai. Danh sách đại biến cố dùng thời gian và năng lực công khai. Không dùng số liệu ẩn để sắp xếp, tạo lời cảnh báo riêng hoặc hiển thị mô tả cũ tiết lộ thêm tính cách. Tấu chương tiến cử chỉ kể những tính cách đã biết. Dự báo ghi rõ là ước tính; khám phá và điều tra có thể làm dự báo thay đổi mà không thay đổi phẩm chất thật.

## Khả năng hoàn thành

Mức hợp tác = trung bình có trọng số của trung thành (0.4), thiện cảm cá nhân (0.35), thái độ phe (0.25). Công tâm giảm trọng số phe xuống 0.08; Trọng phe tăng lên 0.45; Thù dai tăng trọng số cá nhân lên 0.5. Chuẩn hóa lại theo tổng trọng số.

Điều chỉnh hợp tác = round((mức hợp tác − 50) × 0.4).

Xác suất = clamp(round(20 + năng lực × 0.6 + độ phù hợp × 0.25 − mệt ~/ 8 + điều chỉnh hợp tác + điều chỉnh tính cách − rủi ro chống đối), 5, 95).

Độ phù hợp giữ các mức 100/65/20. Nguy cơ chống đối chỉ bổ sung khi trung thành <30 và hợp tác <30, tối đa 15 điểm phần trăm; phe bất mãn đơn độc không tự biến người thanh liêm thành kẻ ăn chặn. Thất bại công việc thường giữ hệ thống thiệt hại cũ; Thận trọng tăng khoảng cách tới thất bại nặng, Liều lĩnh giảm khoảng cách này.

## Tác dụng của 20 tính cách

| ID | Tính cách | Luật đang thực thi |
|---|---|---|
| honest | Liêm khiết | Giảm 25 điểm % nguy cơ thất thoát; chỉ gán mới khi liêm chính ≥80. |
| greedy | Tham lợi | Nguy cơ thất thoát +18 điểm %, mức thất thoát +10 điểm %; thưởng tiền lần đầu trong tuần tăng thêm 3 thiện cảm; chỉ gán mới khi liêm chính ≤40. |
| dutiful | Tận tâm | Xác suất +4 điểm % và bù thêm mệt ~/20; hiệu quả +6 điểm %. |
| negligent | Tắc trách | Xác suất −12 điểm %, hiệu quả −15 điểm %. |
| cautious | Thận trọng | Xác suất +4 điểm %, hiệu quả −5 điểm %, khoảng tới thất bại nặng +12. |
| decisive | Quyết đoán | +7 điểm % cho luyện quân/an ninh/cứu tế/sửa đê, +2 cho việc khác. |
| reckless | Liều lĩnh | Xác suất −5 điểm %, hiệu quả +15 điểm %, khoảng tới thất bại nặng −10. |
| disciplined | Kỷ luật | Xác suất +4 điểm %. |
| flexible | Linh hoạt | Trái chuyên môn +10 điểm %; khi ngân khố <80 hoặc thóc <30, +4 điểm %. |
| conservative | Bảo thủ | Đúng chuyên môn +5 điểm %, các mức khác −8 điểm %. |
| upright | Cương trực | An ninh +7 điểm %; truy thu hoặc thuế cao −5 điểm %. |
| diplomatic | Khéo léo | Ngoại giao/hòa giải +10 điểm %. |
| hotTempered | Nóng nảy | Luyện quân +6 điểm %; ngoại giao/hòa giải −12; việc khác −2. |
| resentful | Thù dai | Tăng trọng số thiện cảm cá nhân; thiện cảm thấp chỉ hồi về nền mỗi 8 tuần thay vì 4. |
| grateful | Biết ơn | Ưu ái lần đầu trong tuần thêm 2 thiện cảm; thiện cảm cao chỉ giảm về nền mỗi 8 tuần thay vì 4. |
| compassionate | Gần dân | Cứu tế/nông nghiệp/mua thóc/sửa đê +7 điểm %; truy thu hoặc thuế cao −7; hiệu quả cứu tế/nông nghiệp +10 điểm %. |
| impartial | Công tâm | Ít chịu thái độ phe, nguy cơ thất thoát −8 điểm %. |
| familyFirst | Vị gia tộc | Phe ≥60: xác suất +4 điểm %, thấp hơn: −4; nguy cơ thất thoát +8 điểm %. |
| partisan | Trọng phe | Tăng trọng số thái độ phe lên 0.45. |
| fameSeeking | Háo danh | Công trình/nông nghiệp/thương mại/luyện quân/an ninh +5 điểm %; thưởng tiền lần đầu trong tuần thêm 2 thiện cảm. |

Hiệu quả = clamp(round(45 + năng lực ×0.6 + độ phù hợp ×0.3 − mệt ~/5 + điều chỉnh tính cách), 10, 180). Thưởng cơ bản dương được nhân hiệu quả rồi làm tròn. Đánh giá chụp lại phẩm chất/chỉ số lúc tạo để việc tăng mệt, lập công hoặc ban thưởng sau đó không sửa ngược dự báo cũ.

## Thất thoát và ngân sách

Sau khi vượt kiểm tra thành công, gieo nguy cơ thất thoát:

- Nguy cơ = clamp(round((70 − liêm chính) ×0.7 + điều chỉnh tính cách), 0, 70)%.
- Mức mất = clamp(15 + (100 − liêm chính) ~/3 + 10 nếu Tham lợi, 15, 60)%.
- Thành quả thực nhận = thành quả trước thất thoát × tỷ lệ còn lại, làm tròn cho việc thường. Không dùng thêm hệ số liêm chính 75–125% cũ.
- Áp dụng cho công việc tức thời, công trình/thương mại khi đến hạn, kết quả ngoại giao và nhiệm vụ đại biến cố. Công việc dài hạn xét người đang phụ trách tại lúc hoàn tất.
- Chỉ cộng tiền/thóc/chỉ số thực nhận; không trừ ngân khố lần thứ hai vì cùng một khoản thất thoát. Kinh phí ứng trước vẫn đã chi. Sổ thu/chi ghi số tiền thực nhận.
- Sử ký thông báo lượng kiểm đếm bị thiếu, không tự mở tính cách hoặc kết tội người chưa điều tra. Mất tiền không đồng nghĩa tự động chứng minh ai tham ô.

## Đại biến cố

Thời gian giữ theo chuyên môn, năng lực thấp và mệt như trước; không lộ tính cách qua ngày hẹn. Khi tới ngày nhận kết quả, kiểm tra thành công bằng bộ đánh giá chung, đúng chuyên môn mục tiêu (kể cả Y thuật/Cung đình).

Mỗi mục tiêu lưu `delivered` từ 0 đến 100. Thành công và không thất thoát hoàn thành toàn bộ phần còn thiếu. Nếu thất thoát, cộng phần thực nhận (làm tròn xuống), giữ mục tiêu chưa hoàn thành và giải phóng người phụ trách. Nếu thất bại, không cộng khối lượng; các phần đã nhận trước đó giữ nguyên.

Có thể giao lại trước hạn: chi phí tiền/thóc = ceil(chi phí ban đầu × phần trăm còn thiếu /100), vẫn tốn 1 hành động và thời gian xử lý. Không tự hoàn tiền hay tự gia hạn. Mục tiêu chỉ tính vào 0/4–4/4 khi đủ 100%; hết hạn vẫn chịu chế tài đại biến cố cũ. Đây không phải thêm một lượt trừ tiền hoặc thiệt hại việc thường khi nhiệm vụ thất bại.

## Bản lưu và random

Đọc được bản luật 0.8/nội dung 7–8. Nếu thiếu tính cách, gán theo dữ liệu mô tả cũ và hash ID ổn định, không tiêu thụ RNG gameplay; tiếp xúc khởi đầu 0. Lưu lại ID tính cách và số tiếp xúc. Các thuộc tính tài chính, RNG, revision, lịch sử, người phụ trách, tiến độ và ngày hẹn không bị đổi trong quá trình đọc.

Mọi lần gieo thành công/thất thoát khi thực hiện lệnh đều dùng RNG đã lưu và cùng transaction gateway. Tải lại không gieo lại; gửi lặp mã yêu cầu không cộng tiếp xúc, thu nhập hoặc khối lượng lần nữa. Lượt 0.2–0.7 vẫn được giữ trong kho lịch sử như trước.
