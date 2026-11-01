**Bản thiết kế game v0.8.1 — cập nhật ngày 25/10/2026.** Phần 1–20 giữ nền thiết kế v0.2, có cập nhật luồng giải thích kết cục. Mục 21 mở rộng nhân vật/phe phái; mục 22 bổ sung hậu quả bỏ bê; mục 23 quy định các mốc kết thúc tại 0; mục 24 bổ sung chuyên môn, giao việc và chọn người thay thế có chi phí. Mục 25 mở rộng lên 450 sự kiện và quy định chống lặp, kết quả trì hoãn; mục 26 bổ sung nguồn thu chủ động; mục 27 giảm phí bổ nhiệm và tính theo chức vụ, địa vị; mục 28 nâng nhóm quan địa phương lên 10 người; mục 29 thêm sổ thu/chi và dự toán có giải thích; mục 30 thêm thông báo và lịch sử kết quả đến hạn. Các thông số mới thay thế đề xuất tương ứng ở các mục trước.

**Cập nhật giao diện 0.7.5.** Tấu chương dùng hai bước: chọn phương án rồi bấm “Xác nhận ngự phê”. Lựa chọn được đánh dấu rõ, có thể đổi trước khi xác nhận. Chưa chọn thì nút xác nhận bị khóa; lựa chọn thiếu tài nguyên không thể chọn hoặc xác nhận. “Đọc sau” hoặc đóng hộp thoại không ghi quyết định, không tiêu tài nguyên hay bốc random. Mỗi lần mở lại bắt đầu chưa chọn. Áp dụng cho cả sự kiện tuyển hậu cung; cơ chế quá hạn giữ nguyên. Luật chơi và nhóm scoreboard vẫn là 0.7.4, không yêu cầu bắt đầu lại.

**1. Ý tưởng và mục tiêu.** Người chơi trở thành vua của một vương quốc hư cấu khi vừa tròn 18 tuổi. Người chơi điều hành triều chính, quản lý dân sinh, quân sự, ngoại giao và hậu cung; đồng thời bảo vệ bản thân trước bệnh tật, âm mưu và những lựa chọn có hại cho sức khỏe.

Mục tiêu duy nhất là giữ ngai vàng càng lâu càng tốt. Không có điểm danh vọng, danh hiệu cuối đời hoặc điểm đánh giá minh quân. Quyết định có thể đem lại lợi ích trước mắt nhưng gây hậu quả nhiều tuần hoặc nhiều năm sau.

**2. Các quyết định đã chốt và phần cần cân bằng.** Những luật dưới đây là nền tảng của bản thiết kế:

| Nội dung | Quyết định |
|---|---|
| Tuổi lên ngôi | 18 tuổi |
| Nhịp chơi | Mỗi lượt là 1 tuần |
| Thành tích | Thời gian giữ ngai vàng |
| Kết thúc | Giải thích nguyên nhân trước, sau đó hiển thị số năm và tuần trị vì cùng các nút điều hướng |
| Scoreboard | Xếp hạng bằng tổng số tuần hoàn thành |
| Sức khỏe | Làm quá sức và hưởng lạc quá mức đều gây hại; hưởng lạc vừa phải có thể giúp hồi phục |
| Sự kiện | Kết hợp lịch, điều kiện, random có điều kiện và hậu quả đã lên lịch |
| MVP | Tất cả tính toán ở FE; lưu tiến trình và scoreboard local |
| Giai đoạn server | Bắt buộc có mạng; server xử lý luật chơi, random và thành tích chính thức |

Quy ước 52 tuần/năm, số điểm hành động, thang chỉ số, số sự kiện mỗi tuần, ngưỡng sức khỏe và quy mô nội dung bên dưới là thông số đề xuất. Chúng cần được cân bằng qua chơi thử, chưa phải các con số cố định.

**3. Thời gian và cách tính thành tích.** Đề xuất dùng lịch 52 tuần/năm, chia bốn mùa, mỗi mùa 13 tuần. Thời gian chỉ trôi khi người chơi xác nhận chuyển tuần; đóng game hoặc để game chạy không làm thời gian tự tăng.

- Lượt mới bắt đầu ở tuổi 18, tuần đang chơi là tuần 1, số tuần đã hoàn thành là 0.
- Một tuần chỉ được cộng sau khi xử lý hết diễn biến cuối tuần và nhà vua vẫn sống, vẫn giữ ngai.
- Nếu chết hoặc mất ngai trong tuần đang xử lý, tuần đó không được cộng.
- Nếu một hành động gây kết thúc ngay giữa tuần, lượt chơi đóng ngay và không cho thực hiện thêm hành động.
- Sau 52 tuần hoàn thành, thành tích là 1 năm 0 tuần và tuổi nhà vua tăng một năm.
- Không tiếp tục điều khiển người kế vị trong cùng lượt chơi.

Công thức hiển thị: `năm = floor(completedWeeks / 52)`; `tuần lẻ = completedWeeks % 52`. Không dùng đồng hồ thiết bị để tính điểm.

**4. Vòng chơi mỗi tuần.** Người chơi bắt đầu bằng báo cáo tình hình, xử lý công việc và lựa chọn cách sử dụng thời gian trước khi sang tuần.

| Bước | Nội dung |
|---|---|
| Nhận tình hình | Xem chỉ số, thu chi, tiến độ, sức khỏe, cảnh báo và các sự kiện đang chờ |
| Ra quyết định | Xử lý tấu chương, tiếp kiến, điều hành, nghỉ ngơi hoặc hưởng lạc |
| Xác nhận sang tuần | Xem việc còn bỏ ngỏ, hạn chót và hậu quả của việc không xử lý |
| Xử lý cuối tuần | Áp dụng kinh tế, tiến độ, sức khỏe, phản ứng nhân vật, sự kiện và âm mưu |
| Chuyển tiếp | Cộng tuần nếu còn giữ ngai; chuẩn bị báo cáo và tình huống cho tuần tiếp theo |

Đề xuất mỗi tuần có 3 điểm hành động. Ban lệnh, bổ nhiệm, tiếp kiến, điều tra, nghỉ ngơi hoặc tổ chức một hoạt động thường dùng 1 điểm; chi phí cụ thể phải hiện trước khi xác nhận. Xem báo cáo và kiểm tra dữ liệu không tốn điểm. Quyết định trong sự kiện chỉ tốn điểm nếu lựa chọn ghi rõ.

Không bắt buộc dùng hết điểm; điểm dư không cộng dồn. Bỏ qua hành động không tự động được tính là một buổi nghỉ ngơi có thưởng hồi phục. Sinh hoạt cơ bản được tính trong diễn biến tuần; muốn hồi phục chủ động phải chọn hoạt động tương ứng.

Đề xuất có lựa chọn làm việc quá giờ để xử lý thêm một việc khi đã hết điểm. Mỗi lần làm thêm tạo gánh nặng sức khỏe rõ ràng và có giới hạn, tránh chuỗi hành động vô hạn.

Sự kiện bắt buộc phải được xử lý hoặc có lựa chọn bỏ qua với hậu quả rõ ràng. Tuần yên ổn có thể chuyển nhanh; không cần tuần nào cũng có biến cố lớn.

**5. Các chỉ số chính.** Sáu chỉ số xuất hiện ở màn hình chính; mỗi chỉ số hiển thị giá trị, chiều hướng thay đổi và nguyên nhân quan trọng.

| Chỉ số | Đề xuất biểu diễn | Vai trò |
|---|---|---|
| Ngân khố | Số tiền, tối thiểu 0 | Chi cho quân đội, quan lại, công trình, cứu tế và cung đình |
| Lòng dân | 0–100 | Ảnh hưởng hợp tác, nguồn thu và nguy cơ nổi dậy |
| Uy quyền | 0–100 | Khả năng thi hành mệnh lệnh và duy trì quyền lực của vua |
| Quân lực | 0–100 | Sức mạnh tổng hợp của quân đội |
| Sức khỏe | 0–100 | Khả năng sống sót trước tuổi tác, bệnh, thương tích và lối sống |
| Ổn định triều đình | 0–100 | Mức hợp tác hoặc đấu đá giữa các phe |

Uy quyền khác ổn định: vua có thể mạnh nhưng triều đình chia rẽ, hoặc triều đình liên kết chặt nhưng nhà vua bị lấn át. Quân lực cao cũng không bảo đảm an toàn nếu người chỉ huy không trung thành.

Ngoại trừ sức khỏe về 0 gây chết, không áp dụng luật mọi chỉ số về 0 đều thua ngay. Chỉ số xấu làm phát sinh hoặc tăng mức nguy hiểm của các tình huống cụ thể. Ví dụ, ngân khố cạn dẫn tới thiếu chi trả; lòng dân thấp tạo điều kiện nổi loạn.

Thông tin hỗ trợ gồm dự trữ lương thực, đê điều, thuế, nợ chi trả, căng thẳng, mệt mỏi và thói quen sinh hoạt. Chúng nằm trong màn hình liên quan và xuất hiện nổi bật khi có cảnh báo.

**6. Sức khỏe, làm việc và hưởng lạc.** Sức khỏe chịu ảnh hưởng của mệt mỏi, căng thẳng, mức hưởng lạc, tình trạng bệnh, thương tích và tuổi tác. Các yếu tố có trí nhớ qua nhiều tuần, không đặt lại về bình thường khi sang tuần mới.

| Hoạt động | Lợi ích trước mắt | Tác động khi kéo dài hoặc quá mức |
|---|---|---|
| Làm việc triều chính | Giải quyết việc nước | Tích lũy mệt mỏi, căng thẳng; thiếu phục hồi lâu ngày làm giảm sức khỏe |
| Làm việc quá giờ | Xử lý thêm việc cấp bách | Tăng mạnh mệt mỏi, có thể giảm sức khỏe ngay và tăng nguy cơ kiệt sức |
| Nghỉ ngơi, ngủ đủ | Giảm mệt mỏi, hỗ trợ hồi phục | Mất thời gian có thể dành cho việc khác; không bảo đảm chữa khỏi bệnh |
| Giải trí hoặc tửu sắc vừa phải | Giảm căng thẳng, có thể hồi phục một phần sức khỏe | Hiệu quả giảm khi lặp lại thường xuyên |
| Tiệc tùng, uống rượu hoặc tửu sắc quá mức | Có thể vẫn giảm căng thẳng tạm thời | Không còn hồi phục, trực tiếp gây hại sức khỏe và tăng nguy cơ bệnh |

Mức hưởng lạc được đánh giá theo cường độ trong tuần và lịch sử gần đây:

- **Vừa phải:** giảm căng thẳng, có thể giúp hồi phục trong giới hạn phù hợp.
- **Thường xuyên:** hiệu quả hồi phục giảm dần, bắt đầu tạo mệt mỏi.
- **Lạm dụng:** tác động sức khỏe chuyển sang âm, tăng nguy cơ hình thành thói quen xấu và bệnh.

Tác động phải xét tổng thể của tuần. Chia một mức hưởng lạc quá nhiều thành nhiều hành động nhỏ không được nhận nhiều lần hồi phục. Làm việc và hưởng lạc cùng tích lũy mệt mỏi: làm việc cả ngày rồi tiệc tùng liên tục vẫn có thể xuống sức dù căng thẳng tạm giảm.

Tác hại của thói quen kéo dài không biến mất chỉ sau một tuần nghỉ. Tuổi cao làm khả năng hồi phục giảm và nguy cơ bệnh tăng; không đặt một tuổi kết thúc cố định, nhưng cũng không bảo đảm bất tử bằng một vòng hành động hồi phục.

Cuối tuần, hệ thống đánh giá lượng việc, nghỉ ngơi, hưởng lạc và các tác động đang tồn tại; sau đó tính một kết quả sức khỏe có giải thích. Mỗi tác động chỉ áp dụng một lần. Chữa trị hoặc bị đầu độc có thể có hiệu lực tức thời nếu sự kiện quy định.

Ví dụ minh họa, chưa phải số cân bằng: “Sức khỏe giảm 4: làm việc quá độ −3, tửu sắc quá mức −2, nghỉ ngơi +1.” Cảnh báo kèm theo: “Nhà vua đã thiếu nghỉ ngơi trong 3 tuần liên tiếp.”

**7. Kinh tế và công việc dài hạn.** Ngân khố cuối tuần bằng ngân khố đầu tuần cộng khoản thu, trừ khoản chi thực trả. Nguồn thu gồm thuế, thương mại và khoản thu theo sự kiện. Khoản chi gồm lương, nuôi quân, cứu tế, cung đình, công trình và chiến tranh.

Khi thiếu tiền, người chơi chọn ưu tiên thanh toán; nghĩa vụ chưa trả được theo dõi riêng. Nợ lương lính gây bất mãn và đào ngũ; thiếu cứu tế làm dân sinh xấu đi; thiếu kinh phí làm công trình chậm tiến độ. Không cho ngân khố âm mà không có cơ chế vay nợ được thiết kế rõ.

Công việc dài hạn có người phụ trách, mục tiêu, kinh phí, tiến độ, thời gian dự kiến và rủi ro. Năng lực, liêm chính và nguồn lực ảnh hưởng kết quả. Chi tiền sửa đê không đồng nghĩa đê đã sửa xong; báo cáo hoàn thành cũng có thể sai nếu người phụ trách che giấu thất thoát.

**8. Nhân vật và phe phái.** Nhân vật có tên, tuổi, vai trò, gia tộc hoặc phe, tính cách và lịch sử tương tác. Các thuộc tính chính gồm năng lực chuyên môn, trung thành, tham vọng, liêm chính, ảnh hưởng và thiện cảm với vua.

Thiện cảm không đồng nghĩa trung thành. Người không thích vua vẫn có thể tận trung; người thường nịnh nọt vẫn có thể phản bội. Một số thuộc tính chỉ được ước lượng qua thành tích, hành vi và điều tra; giao diện phải phân biệt điều đã xác minh với lời đồn.

Các vai trò gồm đại thần, quan ngân khố, tướng lĩnh, quan địa phương, người đứng đầu tình báo, ngự y, hoàng tộc, hoàng hậu và phi tần. Nhân vật có thể già, mắc bệnh, chết hoặc rời chức; có người thay thế để duy trì các lượt chơi dài.

Người chơi có thể bổ nhiệm, thăng chức, thưởng, khiển trách, điều tra, bãi chức và trừng phạt. Quyết định ảnh hưởng cả người liên quan và phe của họ. Giao việc giảm tải cho vua nhưng tạo sự phụ thuộc vào người được giao.

Phe phái có ảnh hưởng, lợi ích, mong muốn và thái độ với nhà vua. Một phe được hưởng lợi quá nhiều có thể giúp vua trước mắt nhưng tích lũy quyền lực để gây sức ép về sau.

**9. Hậu cung.** Chọn phi tần và phong hoàng hậu tác động lên tình cảm, chi tiêu, quan hệ gia tộc và cân bằng phe phái. Các nhân vật có thể kết đôi đều là người trưởng thành.

Hoàng hậu có thể hỗ trợ quản lý hậu cung tùy năng lực. Thiên vị, tranh sủng hoặc bất mãn có thể dẫn tới tung tin, chia phe và âm mưu. Có nhiều phi tần không tự động tạo lợi thế; người chơi không bắt buộc mở rộng hậu cung để tồn tại lâu.

Hoạt động hưởng lạc áp dụng cơ chế sức khỏe ở mục 6. Không mặc định mọi tương tác tình cảm đều có hại hoặc đều là một lần hồi phục sức khỏe.

**10. Random và cách xuất hiện sự kiện.** Random không chọn tùy ý từ toàn bộ nội dung. Hệ thống trước hết kiểm tra tình hình, lịch và quyết định trước đó, rồi mới chọn trong các sự kiện phù hợp.

| Loại sự kiện | Cơ chế | Ví dụ |
|---|---|---|
| Theo lịch | Đến mốc đã định thì kích hoạt theo điều kiện liên quan | Mùa thu hoạch, sứ đoàn đến theo hẹn |
| Theo điều kiện | Kích hoạt khi điều kiện bắt buộc được thỏa mãn | Thiếu lương thực bắt đầu gây đói; không tự động đồng nghĩa nổi loạn ngay |
| Random có điều kiện | Đủ điều kiện mới có xác suất xuất hiện | Đê yếu trong mùa mưa có nguy cơ vỡ |
| Hậu quả đã lên lịch | Xuất phát từ quyết định hoặc chuỗi trước đó | Kết quả điều tra, viện quân đến, thời hạn yêu sách |

Khi tạo tình huống cho tuần tiếp theo, hệ thống thực hiện theo thứ tự:

1. Giải quyết các hạn chót, diễn biến đến hạn và khủng hoảng đang tiếp tục.
2. Kiểm tra các điều kiện bắt buộc phát sinh từ trạng thái mới.
3. Tạo danh sách sự kiện random đủ điều kiện.
4. Tính xác suất hoặc trọng số theo tình hình, nhân vật, mùa và lịch sử.
5. Chọn sự kiện mới, kiểm tra xung đột và thời gian nghỉ trước khi lặp lại.
6. Lưu toàn bộ kết quả đã xác định trước khi hiển thị.

Đề xuất thông thường có 0–2 sự kiện mới mỗi tuần. Giới hạn này không được làm mất hậu quả đã đến hạn hoặc ngăn khủng hoảng đang diễn ra tiếp tục. Sự kiện có thể có nhiều bước, liên quan nhau và kéo dài nhiều tuần.

Random có thể được dùng cho kết quả lựa chọn khi hợp lý: điều tra phụ thuộc năng lực và mức che giấu; trận đánh phụ thuộc quân lực, chỉ huy và điều kiện chiến trường. Chi phí cố định đã xác nhận phải áp dụng chắc chắn. Nếu một lựa chọn có kết quả không chắc chắn, giao diện cần thể hiện mức rủi ro bằng thông tin nhà vua biết.

**11. Ví dụ về chuỗi và âm mưu.** Chuỗi vỡ đê có thể đi từ cảnh báo đê xuống cấp, quyết định sửa hoặc trì hoãn, báo cáo tiến độ, mưa lớn, rồi tới thiệt hại và cứu tế. Đê tốt làm giảm nguy cơ; tham nhũng có thể khiến đê thực tế yếu dù báo cáo nói đã sửa. Trì hoãn không phải lần nào cũng gây vỡ đê ngay.

Âm mưu phát triển theo động cơ, tập hợp đồng minh, chuẩn bị, tìm cơ hội và hành động. Trung thành, tham vọng, thiện cảm, ảnh hưởng, an ninh và tình hình triều đình cùng tác động. Không random một cái chết do ám sát hoàn toàn tách rời trạng thái game.

Các nguy cơ lớn cần có dấu hiệu hợp lý và cơ hội phản ứng, chẳng hạn điều chuyển quân bất thường, các cuộc gặp kín hoặc dấu hiệu sức khỏe đáng ngờ. Người chơi có thể điều tra, thay người, thương lượng hoặc bắt giữ. Tin báo có thể sai; trừng phạt nhầm tạo hậu quả mới. Biện pháp bảo vệ giảm rủi ro, không bảo đảm an toàn tuyệt đối.

**12. Quân sự và ngoại giao.** Chiến tranh kéo dài qua nhiều tuần. Người chơi chọn chỉ huy, ngân sách, tiếp tế và chủ trương phòng thủ, tăng viện, rút quân hoặc đàm phán. Kết quả phụ thuộc quân lực, tinh thần, năng lực và lòng trung thành của tướng, hậu cần, địa hình, thời tiết và đối phương.

Thua một trận không tự động mất nước. Mất nước phải có diễn biến và điều kiện kết thúc rõ ràng. Ngoại giao cho phép đổi tiền hoặc lợi ích lấy hòa bình, liên minh hoặc thời gian chuẩn bị; nghĩa vụ và hậu quả phá ước được theo dõi qua các tuần.

**13. Kết thúc và scoreboard.** Lượt chơi kết thúc khi vua chết, một hành động phế truất thành công, hoặc đất nước thất thủ đến mức vua không còn quyền cai trị. Màn “Biến cố cuối cùng” xuất hiện trước để giải thích nguyên nhân cụ thể: người và phe thực hiện đầu độc/đảo chính; ngoại xâm đánh sập phòng tuyến và chiếm kinh thành; dân nổi dậy khi lòng dân và quân lực quá thấp; hoặc bệnh tật, làm việc quá độ, mệt mỏi, căng thẳng, hưởng lạc và tuổi tác khiến long thể suy kiệt. Nội dung phải dựa trên trạng thái và diễn biến thực tế của lượt chơi.

Chọn “Xem thời gian trị vì” để mở màn tổng kết đơn giản, ví dụ: “Bạn đã trị vì được 23 năm 17 tuần.” Các nút gồm Chơi lại, Xem scoreboard và Về màn hình chính. Nguyên nhân được lưu cùng trạng thái kết thúc; tải lại vẫn xem được mà không ghi trùng thành tích. Đầu độc có thể gây chết ngay hoặc để lại di chứng; lưu nguồn gây bệnh đến khi chữa khỏi để kết cục muộn vẫn nêu đúng người gây án. Khi sức khỏe đã cạn kiệt, không tiếp tục xử lý âm mưu/chiến tranh rồi gán nhầm một nguyên nhân khác. Không suy đoán thêm thủ phạm cho bản lưu chỉ có nguyên nhân cũ; việc lưu trữ lượt dùng luật cũ được mô tả tại mục 22.

Scoreboard dùng tổng số tuần hoàn thành làm tiêu chí duy nhất. Thành tích bằng nhau thì đồng hạng theo cách 1, 2, 2, 4; không dùng tài sản, sức khỏe, thời điểm nộp hoặc điểm phụ để phân thắng thua. Mỗi hồ sơ người chơi hiển thị thành tích tốt nhất trên bảng chính. Chỉ lượt đã kết thúc mới được ghi nhận; tạm dừng không kết thúc lượt, bỏ lượt để chơi lại không tạo thành tích hoàn tất.

| Giai đoạn | Phạm vi scoreboard |
|---|---|
| MVP | Local trên thiết bị hoặc trình duyệt hiện tại; có thể dùng tên người chơi do người dùng nhập, chưa cần tài khoản online |
| Có server | Bảng chung gắn với tài khoản; server tự tính và ghi thành tích |

Scoreboard hiển thị hạng, tên người chơi và số năm/tuần. Các bộ luật ảnh hưởng đáng kể đến độ khó dùng bảng riêng. Điểm local thử nghiệm không tự động nhập vào bảng chính thức của giai đoạn server.

**14. Kiến trúc MVP ở FE.** MVP chưa có backend, đăng nhập online, đồng bộ hay yêu cầu kết nối mạng để chơi sau khi ứng dụng đã được tải/cài đầy đủ. Mọi xử lý, kể cả nhân vật và âm mưu bí mật, nằm trên thiết bị. Chưa đặt mục tiêu chống sửa dữ liệu local hoặc xác thực thành tích cạnh tranh.

| Thành phần | Trách nhiệm |
|---|---|
| Giao diện | Hiển thị dữ liệu, nhận lựa chọn, trình bày kết quả và cảnh báo |
| Game gateway | Cung cấp thao tác đọc tình hình và gửi hành động; che giấu cách chạy local hay gọi server |
| Bộ xử lý game | Kiểm tra luật, áp dụng hành động, xử lý tuần, sức khỏe, random và kết thúc |
| Bộ luật và nội dung | Cấu hình chỉ số, chi phí, sự kiện, lựa chọn và điều kiện |
| Lớp lưu trữ local | Lưu, tải, kiểm tra phiên bản dữ liệu và ghi nhận thành tích |

Luồng MVP: `Giao diện → Local game gateway → Bộ xử lý game → Lưu local → Trả kết quả cho giao diện`.

Giao diện gửi ý định như “cấp tiền sửa đê”, “nghỉ ngơi”, “chọn phương án của sự kiện” hoặc “chuyển tuần”. Giao diện không tự sửa trực tiếp ngân khố, sức khỏe hay số tuần. Bộ xử lý tự kiểm tra chi phí, quyền lựa chọn và trạng thái hiện tại.

Bộ xử lý không phụ thuộc màn hình hay API lưu trữ cụ thể. Đầu vào gồm trạng thái, hành động, trạng thái random và bộ luật; đầu ra gồm trạng thái mới, diễn biến, lỗi hợp lệ và thông tin được phép hiển thị. Giao diện dùng dữ liệu dành cho người chơi, không phụ thuộc trực tiếp cấu trúc bí mật của engine.

Không chốt framework hay ngôn ngữ trong tài liệu này. Tách trách nhiệm giúp giảm thay đổi khi chuyển server, nhưng vẫn cần kiểm tra lại lưu trữ, giao tiếp mạng và tính nhất quán của bộ mô phỏng.

**15. Random có thể tái tạo.** Mỗi lượt có seed và trạng thái bộ sinh số giả ngẫu nhiên. Mọi random ảnh hưởng gameplay phải đi qua cùng một cơ chế do engine quản lý, không gọi random tùy tiện trong giao diện và không dùng giờ thực để quyết định diễn biến.

Lưu cả seed lẫn vị trí/trạng thái hiện tại của bộ random. Seed đơn lẻ không đủ để tiếp tục giữa lượt nếu không chạy lại toàn bộ lịch sử. Khi có cùng trạng thái ban đầu, bộ luật, thứ tự hành động và thuật toán random, bộ xử lý phải tái tạo cùng kết quả.

Thứ tự xử lý phải ổn định. Các quy tắc làm tròn và phiên bản nội dung cần được xác định rõ, nhất là nếu FE và server sau này dùng nền tảng khác nhau. Random dùng riêng cho hiệu ứng hình ảnh không được tiêu thụ chuỗi random gameplay.

Kết quả đã cam kết được lưu trước khi hiển thị; tải lại không tạo một lần bốc thăm mới. Điều này bảo đảm hành vi bình thường nhất quán, không được xem là cơ chế chống người dùng chủ động sửa bản lưu.

**16. Dữ liệu và lưu local.** Bản Web đề xuất dùng IndexedDB cho trạng thái và nhật ký có cấu trúc. Các nền tảng khác dùng adapter lưu trữ phù hợp, giữ cùng ý nghĩa dữ liệu. Việc tải ứng dụng Web để chạy offline cần cơ chế cache tài nguyên riêng; lưu bản game không tự làm trang Web hoạt động offline.

| Nhóm dữ liệu | Nội dung cần lưu |
|---|---|
| Định danh | Mã lượt chơi, hồ sơ local, phiên bản schema, phiên bản luật và nội dung |
| Tiến trình | Trạng thái đang chơi/đã kết thúc, số tuần hoàn thành, tuần hiện tại, điểm hành động |
| Quốc gia | Chỉ số, lương thực, nghĩa vụ chi trả, quân sự và ngoại giao |
| Nhà vua | Sức khỏe, mệt mỏi, căng thẳng, lịch sử hưởng lạc, bệnh và thói quen |
| Nhân vật | Thuộc tính, quan hệ, chức vụ, phe và trạng thái |
| Diễn biến | Công việc, sự kiện đang mở, hậu quả chờ, hạn chót, âm mưu và thời gian nghỉ sự kiện |
| Random | Seed, trạng thái bộ sinh và phiên bản thuật toán |
| Nhật ký | Thứ tự hành động, lựa chọn, kết quả và các mã yêu cầu đã xử lý |
| Thành tích | Lượt kết thúc, số tuần được tính và phiên bản bảng local |

Tự lưu sau mỗi hành động đã cam kết và sau khi xử lý xong chuyển tuần. Trạng thái, nhật ký và trạng thái random được ghi trong cùng một lần cập nhật nguyên tử. Nếu kết thúc, việc đóng lượt và ghi thành tích cũng phải nhất quán; không để một tuần mới chỉ được lưu một nửa.

Mỗi yêu cầu có mã riêng và số phiên bản trạng thái dự kiến. Gửi lại cùng yêu cầu trả lại kết quả đã xử lý; không thực hiện lần nữa. Yêu cầu dựa trên trạng thái cũ phải tải lại tình hình. Điều này xử lý bấm lặp, hai tab cùng mở và chuẩn bị cho việc gửi lại khi có mạng sau này.

Schema bản lưu khác phiên bản luật. Thay đổi cấu trúc dữ liệu cần chuyển đổi có kiểm soát; không âm thầm đưa lượt đang chơi sang bộ luật mới làm thay đổi độ khó hoặc phá lịch sử random. Trong MVP có thể giữ bộ luật cũ hoặc thông báo bản lưu không tương thích trước khi yêu cầu bắt đầu lại.

Lưu local không đồng nghĩa có bản sao lưu online. Xóa dữ liệu ứng dụng hoặc trình duyệt có thể mất tiến trình. Nhập/xuất bản lưu là tính năng có thể bổ sung sau, chưa bắt buộc cho vòng chơi MVP.

**17. Chuyển sang server sau MVP.** Giữ cách giao diện gửi ý định, thay Local game gateway bằng Remote game gateway. Server trở thành nơi quyết định trạng thái chính thức; client chỉ giữ cache để hiển thị và cài đặt cá nhân.

Luồng giai đoạn server: `Giao diện → API → Bộ xử lý game trên server → Cơ sở dữ liệu → Kết quả được phép hiển thị`.

- Server tạo lượt, giữ random và thông tin bí mật; không gửi seed gameplay hoặc tương lai của âm mưu xuống client.
- Mọi hành động có tác động hoặc tiết lộ thông tin được server kiểm tra và lưu khi xác nhận, không chỉ gửi toàn bộ kết quả cuối tuần từ FE.
- Server tự đếm tuần và ghi scoreboard khi kết thúc; client không có quyền tự khai điểm chính thức.
- Server dùng tài khoản, quyền sở hữu lượt, mã yêu cầu và phiên bản trạng thái để ngăn ghi nhầm hoặc xử lý lặp.
- Khi mất mạng, không cam kết thêm hành động hoặc tuần; kết nối lại thì tải trạng thái chính thức để tiếp tục.
- Lượt chơi local của MVP không được đưa thẳng vào bảng xếp hạng chính thức. Cách chuyển tiến trình cũ, nếu cần, phải được quyết định riêng.

Game theo lượt có thể bắt đầu với API HTTP; chưa cần kết nối WebSocket liên tục. Khả năng dùng lại mã engine phụ thuộc công nghệ được chọn, vì vậy cần giữ luật và dữ liệu nội dung độc lập với giao diện ngay từ MVP.

**18. Giao diện.** Màn hình chính hiển thị tuổi vua, năm/tuần trị vì, mùa, sáu chỉ số, điểm hành động, sự kiện cần xử lý và nút Sang tuần tiếp theo. Cảnh báo quan trọng nêu rõ việc gì đang xấu đi và hạn xử lý nếu có.

Các màn hình quản lý gồm triều đình, nhân vật, quốc gia và ngân khố, quân sự/ngoại giao, hậu cung, sức khỏe và công việc đang thực hiện. Nhật ký giúp xem lại lựa chọn và nguyên nhân thay đổi. Thông tin chưa xác minh phải có cách biểu diễn khác thông tin chắc chắn.

MVP dùng giao diện ngai vàng/tấu chương làm trung tâm; chưa cần bản đồ lớn. Cảnh báo sức khỏe thể hiện mức làm việc, nghỉ ngơi và hưởng lạc gần đây để người chơi hiểu rủi ro tích lũy.

**19. Phạm vi MVP và tiêu chí hoàn thành.** Bản đầu cần một vòng chơi đầy đủ: lên ngôi, điều hành theo tuần, chịu hậu quả, kết thúc, ghi scoreboard local và chơi lại. Chưa triển khai server, bảng xếp hạng chung, tài khoản online hoặc chống gian lận.

Đề xuất quy mô nội dung ban đầu là một vương quốc, khoảng 10–15 nhân vật hoạt động, bốn phe và 40–60 sự kiện có khả năng tái sử dụng theo điều kiện, gồm các chuỗi về thiên tai, dân sinh, hậu cung, sức khỏe, âm mưu và ngoại xâm. Đây là mục tiêu nội dung để cân đối nguồn lực, không phải cam kết đủ đa dạng cho mọi độ dài lượt chơi.

Các kiểm tra quan trọng trước khi coi vòng chơi MVP hoàn thành:

- Một tuần là một lượt; điểm chỉ tăng khi hoàn thành tuần và còn giữ ngai.
- Làm việc quá sức gây suy giảm; hưởng lạc vừa phải có lợi nhưng lạm dụng chuyển sang có hại; tác động tích lũy qua nhiều tuần.
- Random tuân thủ điều kiện, các hậu quả đến hạn không bị bỏ qua, có thể có tuần không xuất hiện sự kiện mới.
- Cùng đầu vào và trạng thái random tạo cùng kết quả; tải lại không đổi diễn biến đã cam kết.
- Lưu/tải khôi phục đúng công việc, sức khỏe, nhân vật, sự kiện và số tuần.
- Bấm lặp hoặc mở hai tab không nhân đôi hành động, chuyển tuần hoặc ghi thành tích.
- Kết thúc khóa lượt; giải thích nguyên nhân trước khi mở màn thời gian trị vì và các nút điều hướng.
- Scoreboard local đúng số tuần, cách hiển thị, đồng hạng và phiên bản luật.
- Giao diện không tự tính kết quả gameplay hoặc tự ghi điểm ngoài luồng engine.

**20. Thay đổi so với v0.1.** Bổ sung sức khỏe chịu tác động tích lũy từ làm việc và hưởng lạc; xác định bốn nguồn sự kiện cùng quy trình random; chốt MVP chạy FE và lưu local; giới hạn scoreboard MVP ở thiết bị; chuẩn bị tách giao diện, engine và lưu trữ để server tiếp quản sau này. Làm rõ cách cộng tuần, lưu trạng thái random và xử lý hành động bị gửi lặp.

**21. Cân bằng và mở rộng ở bản 0.3.** Lượt mới có 28 triều thần (mỗi phe bảy người) và 10 ứng viên hậu cung trưởng thành. Triều thần được phân theo Văn ban, Võ ban, Địa phương, Hoàng thất và Nội đình; có thể kết hợp phân loại, phe và tìm kiếm tên/chức vụ. Hậu cung phân theo Hoàng hậu, Phi tần và Tú nữ. Tú nữ là người chưa nhập cung; sau khi được tuyển vào cung mới trở thành Phi tần.

Sự kiện tiến cử xuất hiện từ tuần 4 và mỗi 13 tuần sau đó. Mỗi sự kiện gắn với một ứng viên mới cụ thể, có tên, tuổi, phe và tính cách; người chơi nhận làm tú nữ với một hành động và 20 tiền, hoặc khước từ. Tú nữ chưa nhập cung nên chưa phát sinh chi sinh hoạt hậu cung; cần tuyển riêng với một hành động và 35 tiền để trở thành Phi tần. Nạp thủ công cùng người sẽ khép lại tấu chương tiến cử, tránh nạp hai lần. Sự kiện kết thân gia tộc còn có lựa chọn chi 20 tiền và một hành động để giới thiệu hai ứng viên mới. Tất cả ứng viên đều ít nhất 18 tuổi. Người chưa nhập cung không được thực hiện âm mưu trong cung.

| Hành động | Lợi ích và chi phí ở bản 0.3 |
|---|---|
| Chấn chỉnh triều chính | Lần đầu trong tuần: tối đa +3 uy quyền, +1 ổn định; các lần sau: +1 uy quyền, không tăng ổn định. Mỗi lần thêm 6 mệt mỏi và 4 căng thẳng, ngoài gánh nặng công việc cuối tuần. Khi uy quyền từ 80 trở lên, lần đầu chỉ tăng 2. |
| Mở kho cứu tế | Tốn 20 tiền và 25 lương thực, tăng tối đa 5 lòng dân. Lòng dân từ 75 trở lên chỉ tăng tối đa 2; lặp trong tuần tiếp tục giảm hiệu quả. Không đủ kho thì lệnh bị từ chối trước khi trừ tiền/hành động. |
| Bổ sung kho lương | Chi 45 tiền, thêm 30 lương thực, tốn một hành động; không mua khi kho đầy. |
| Tiếp kiến | Thiện cảm tối đa +6, phe đối lập giảm thiện cảm 2; quan hệ cao và lặp lại giảm lợi ích. |
| Ban thưởng | Chi 25, thiện cảm tối đa +8, phe đối lập giảm thiện cảm 3; quyền lực người được thưởng tăng. Tăng trung thành có giới hạn trong tuần. |
| Hòa giải các phe | Một hành động, chi 25, mỗi phe +2 thái độ, ổn định +2 nhưng uy quyền −2, mệt mỏi +4 và căng thẳng +4. Tối đa một lần/tuần. |

Tiếp kiến, ban thưởng và dạo Ngự uyển dùng chung số lần được ưu ái theo nhân vật trong tuần. Từ thiện cảm 65, mức tăng cơ bản bị giới hạn ở 3; từ 85 chỉ còn 1; tiếp tục chia theo số lần lặp. Tải lại không xóa bộ đếm. Nạp phi và phong hậu cũng tạo phản ứng từ phe đối lập.

Văn thần ↔ Võ tướng và Hoàng tộc ↔ Thế gia là hai cặp đối trọng. Seed của lượt chọn một phe dè chừng ngay từ đầu; thiện cảm các thành viên phe này ở khoảng 12–35. Các phe còn lại và từng cá nhân có giá trị khởi đầu khác nhau, không đồng loạt 50. Thiện cảm tăng cao có xu hướng giảm dần về mức nền; thái độ phe thấp hoặc thiện cảm rất thấp làm trung thành suy giảm. Uy quyền cao không tự động khiến người đang bất mãn trung thành trở lại. Chênh lệch thái độ các phe trên 35 gây giảm ổn định mỗi bốn tuần và có báo cáo cảnh báo.

Độ khó tăng bằng chi phí tài nguyên, hồi phục, hiệu quả giảm dần và phản ứng phe phái. Ngân khố ban đầu là 520; chi cơ bản cung đình tăng từ 6 lên 8 mỗi tuần. Giữ giới hạn tối đa ba âm mưu đang phát triển cùng lúc để việc tăng số nhân vật không tạo hàng loạt nguy cơ bất ngờ; các âm mưu vẫn có dấu hiệu trước khi ra tay. Thời gian trị vì vẫn là thành tích duy nhất.

Luật mới dùng phiên bản `mvp-0.3.0` và schema 2. Lượt 0.2 được lưu nguyên trạng trong kho local, cần bắt đầu lượt mới để chơi luật mới; không tự chuyển tiến trình cũ rồi tính điểm theo luật khác. Thành tích 0.2 vẫn giữ và xem riêng. Quá trình chuyển kho không xóa lịch sử, bản lưu cũ hoặc thành tích đã hoàn thành.

**22. Hậu quả bỏ bê ở bản 0.4.** Lưu thêm `affairsThisWeek` (số việc nước đã chủ động giải quyết) và `neglectedWeeks` (số tuần liên tiếp bỏ bê). Chỉ một quyết định quốc sự cũng đủ ngắt chuỗi ở lần chuyển tuần; không bắt buộc dùng hết ba hành động để tránh ép nhà vua làm quá sức. Việc đã xử lý được lưu ngay nên tải lại không xóa chuỗi hoặc mất ghi nhận.

Việc nước gồm ban lệnh quản trị, kinh tế, quân sự, an ninh, ngoại giao; thay đổi thuế/ưu tiên ngân sách; tiếp kiến, thưởng, điều tra và bãi chức quan; chủ động chọn phương án tấu chương ngoài nhóm Cung đình, Hậu cung và Sức khỏe. Quyết định tấu chương không tốn hành động vẫn được tính; tự hết hạn không tính. Nghỉ, chữa bệnh, hưởng lạc, tuyển phi, phong hậu và thăm phi tần không thay thế việc nước. Công trình đã giao vẫn tiến triển nhưng không tự ghi một quyết định quốc sự mới cho vua mỗi tuần.

Nếu không xử lý việc nước, tăng chuỗi một tuần và áp dụng thiệt hại sau, ngoài hao mòn và sự kiện thông thường:

| Tác động | Công thức với N là số tuần bỏ bê liên tiếp |
|---|---|
| Uy quyền | Giảm `min(12, 2 + 2N)` |
| Ổn định | Giảm `min(7, 1 + N)` |
| Lòng dân | Giảm `min(4, (N + 1) ~/ 2)` |
| Trung thành của quan đang tại chức | Giảm 1 mỗi tuần; từ tuần thứ ba giảm 2 |
| Tiến độ âm mưu đủ điều kiện | Thêm `min(4, N)` mỗi tuần; thêm 2 nếu uy quyền dưới 30 |

Tấu chương thuộc Khủng hoảng hoặc Âm mưu bị quá hạn còn làm giảm 4 uy quyền và 3 ổn định mỗi việc, tính tối đa hai việc mỗi tuần để tránh một đợt random tạo thiệt hại không giới hạn. Hậu quả mặc định của từng tấu chương vẫn áp dụng đầy đủ một lần. Lựa chọn chủ động chấp nhận phương án bất lợi chịu hậu quả của phương án đó, không thêm hình phạt vì không phản hồi.

Khi uy quyền bằng 0 và ổn định dưới 25, triều thần tập hợp ép vua thoái vị; màn kết cục giải thích sự sụp đổ, nêu người/phe đứng đầu và việc bỏ bê nếu đang có chuỗi. Điều kiện này dựa trên tình hình đất nước, không ấn định một tuần thua cố định. Các kết cục do sức khỏe, âm mưu, nổi loạn và ngoại xâm vẫn tồn tại. Sau khi trở lại việc nước, ngắt chuỗi nhưng không hoàn lại uy quyền, ổn định, lòng dân hay trung thành đã mất.

Giao diện tổng quan cảnh báo cả tuần chưa xử lý quốc sự và chuỗi bỏ bê; thanh chuyển tuần nhắc khi chưa giải quyết việc nước, kể cả đã dùng hết hành động vào nghỉ ngơi/hậu cung. Nhật ký ghi rõ thiệt hại mỗi tuần; hộp thoại bỏ qua tấu chương báo thêm hình phạt khủng hoảng/âm mưu.

Mô phỏng cùng engine qua 100 seed (1–100), giới hạn 260 tuần: chỉ skip và chỉ nghỉ đều kết thúc vào tuần 6–7, tương ứng 5–6 tuần được ghi thành tích. Trước chỉnh sửa, chỉ skip ghi trung vị 19 tuần (khoảng 17–40). Chính sách chủ động đơn giản ghi trung vị 78 tuần ở cả hai bản, cho thấy hình phạt nhắm vào bỏ bê; chưa xem đây là cân bằng hoàn tất cho mọi chiến lược.

Bản 0.4 dùng luật `mvp-0.4.0`, nội dung 3, schema vẫn là 2. Lượt 0.2/0.3 được giữ nguyên trong `archivedRuns`, không áp dụng luật mới giữa lượt. Người chơi bắt đầu triều đại mới để thử độ khó 0.4. Điểm cũ giữ nguyên và xem theo từng bộ luật, không trộn với bảng mới; tải lại hoặc bắt đầu lượt mới không xóa lịch sử cũ.

**23. Các mốc kết thúc tại 0 ở bản 0.5.** Triều đình, Lòng dân, Quân lực và Sức khỏe đều có điều kiện kết thúc độc lập khi giá trị bằng 0. Chỉ số khác cao không bù được một điều kiện đã xảy ra. Không bốc thăm thêm để quyết định có kết thúc hay không tại mốc này.

| Chỉ số về 0 | Mã kết cục | Giải thích |
|---|---|---|
| Triều đình | `courtCollapse` | Các phe công khai tranh quyền, quan lại không còn tuân lệnh và các đại thần ép vua thoái vị |
| Lòng dân | `rebellion` | Dân chúng không còn chấp nhận sự cai trị, nổi dậy lật đổ triều đình, không phụ thuộc quân lực còn lại |
| Quân lực, đang chiến tranh | `invasion` | Không còn lực lượng phòng thủ, ngoại xâm chiếm kinh thành và đất nước |
| Quân lực, thời bình | `armyCollapse` | Quân đội và cấm vệ tan rã, các thế lực tranh quyền chiếm hoàng cung, ép vua thoái vị |
| Sức khỏe | `poisoning`, `illness` hoặc `exhaustion` | Nhà vua băng hà; nêu nguồn đầu độc hoặc những yếu tố sức khỏe thực tế |

Các nguy cơ trước mốc 0 vẫn tồn tại, gồm đảo chính, đầu độc, thất thủ qua nhiều bước và nổi loạn khi lòng dân/quân lực thấp. Điều kiện “uy quyền bằng 0 và ổn định dưới 25” vẫn áp dụng khi triều đình còn một ít ổn định.

Kiểm tra sau mỗi hành động và trong bước xử lý tuần, trước khi xử lý âm mưu mới. Nếu một quyết định như bãi chức, siết thuế hoặc trì hoãn quân lương làm một chỉ số xuống 0, kết thúc ngay giữa tuần. Không cộng tuần thất bại; không cho phép phát lệnh tiếp sau kết cục. Khi đọc trạng thái đã bằng 0, lệnh kế tiếp xác nhận kết cục trước khi thực hiện tác dụng của lệnh, tránh dùng một hành động phục hồi để hồi sinh lượt đã mất. Trong cùng một bước kiểm tra, thứ tự xác định là sức khỏe → triều đình → lòng dân → quân lực; nguyên nhân đã xác định không bị ghi đè bởi biến cố tiếp theo.

Ở mức 1–20, tổng quan cảnh báo riêng từng chỉ số, nêu hậu quả tại 0 và gợi ý ứng phó (hòa giải, cứu tế, luyện quân, chữa bệnh/nghỉ ngơi). Thanh chuyển tuần nhắc tên chỉ số nguy cấp hoặc tổng số nếu có nhiều chỉ số. Trước khi về 0 vẫn có thể cứu vãn. Màn “Biến cố cuối cùng” giải thích đúng nguyên nhân và hiển thị các chỉ số liên quan; không dùng báo cáo sức khỏe cũ để mô tả một cái chết xảy ra giữa tuần. Tiếp đó mới hiện thời gian trị vì; lưu local, phục hồi kết cục và ghi scoreboard theo cùng luồng nguyên tử đang có.

Bản này dùng luật `mvp-0.5.0`, nội dung 4, schema vẫn là 2. Lượt 0.2/0.3/0.4 được giữ nguyên trong kho local; bắt đầu triều đại mới để áp dụng điều kiện kết thúc mới. Thành tích các luật cũ vẫn xem riêng, không trộn vào bảng 0.5. Kết quả mô phỏng ở mục 22 và báo cáo spam 0.4 là số liệu lịch sử, không mặc định là số liệu của luật mới.

**24. Chuyên môn, giao việc và bổ nhiệm ở bản 0.6.** Mỗi nhân vật có năng lực 0–100 và một chuyên môn vốn có: Dân chính, Kinh tế, Công trình, Quân sự, An ninh, Ngoại giao, Y thuật hoặc Cung đình. Chuyên môn được lưu riêng với chức vụ và không tự đổi khi bổ nhiệm vào chức khác. Năng lực ban đầu dưới 50 ở sáu quan: Hộ bộ 43, Lễ bộ 46, Võ quan 34, Quận vương 39, Tổng quản 48 và Quan điền 44. Các quan giỏi vẫn tồn tại để người chơi có lựa chọn; thay người không phải điều kiện bắt buộc để qua tuần đầu.

Hồ sơ mở khi triệu kiến hiển thị chú thích năng lực, chuyên môn, tác dụng theo chức vụ và nhắc rằng tài năng khác trung thành/liêm chính. Hiệu quả thường trực của Ngự y, Mật thám, Ngự sử và Đại tướng cũng nhân với mức phù hợp chuyên môn; ví dụ người trái nghề được phong làm Đại tướng không nhận đầy đủ đóng góp phòng thủ chỉ nhờ điểm năng lực cao. Các phẩm chất chưa điều tra vẫn bị ẩn.

| Quốc sự | Chuyên môn chính | Mức thu cơ bản khi thành công |
|---|---|---|
| Chấn chỉnh | Dân chính | Uy quyền 3, ổn định 1; giữ giảm hiệu quả khi lặp/uy quyền cao |
| Cứu tế | Dân chính | Lòng dân 5; giảm khi lặp/lòng dân cao |
| Hòa giải | Dân chính | Các phe 2, ổn định 2; uy quyền vẫn −2 |
| Mua thóc | Kinh tế | Lương thực 30 |
| Khai khẩn | Kinh tế | Lương thực 35, lòng dân 4; giải quyết sau 5 tuần |
| Sửa đê | Công trình | Đê 30; giải quyết sau 4 tuần |
| Luyện quân | Quân sự | Quân lực 10 |
| Củng cố cấm vệ | An ninh | Giảm 18 tiến độ âm mưu, uy quyền 2 |
| Hòa đàm | Ngoại giao | Giảm 3 áp lực chiến tranh, uy quyền 2; hồi âm sau 3 tuần |

Mức phù hợp là 100 khi đúng chuyên môn, 65 khi liên quan và 20 khi trái chuyên môn. Ví dụ Quân sự và An ninh có liên quan; Kinh tế có liên quan Công trình. Luật dùng bảng quan hệ rõ ràng trong `personnel_rules.dart`, không suy luận từ tên nhân vật hay điểm thiện cảm.

Xác suất thành công là `round(20 + 0,6 × năng lực + 0,25 × phù hợp)`, giới hạn 15–95%. Hệ số phần thưởng là `round(45 + 0,6 × năng lực + 0,3 × phù hợp)%`. Làm tròn lượng nhận được và giữ tối thiểu 1 cho phần thưởng dương; các trần chỉ số quốc gia vẫn áp dụng. Công trình còn nhân với `0,75 + 0,005 × liêm chính`; thông tin dự báo ghi rõ yếu tố liêm chính, không tiết lộ chỉ số chưa xác minh. Năng lực cao và đúng chuyên môn tăng cả xác suất và hiệu quả, nhưng không bảo đảm thành công tuyệt đối.

Trước khi gửi lệnh, UI cho so sánh quan đang rảnh theo năng lực, chuyên môn, mức phù hợp, xác suất và hệ số phần thưởng; sau đó xác nhận kinh phí/rủi ro. Quan đang làm công trình hoặc dẫn sứ đoàn không nhận việc quốc sự khác. Tác vụ tức thời bốc kết quả ngay; công trình bốc khi đủ tiến độ, hòa đàm khi tới hạn. Không bốc khi chỉ mở danh sách hoặc tải lại. Các tác vụ dưỡng sức, hưởng lạc và chữa bệnh giữ luồng chăm sóc bản thân; chữa bệnh dùng hiệu quả Ngự y đang tại chức.

Nếu lần bốc từ xác suất thành công trở lên, công việc thất bại; cao hơn ngưỡng đó ít nhất 15 điểm là thất bại nặng. Kinh phí, hành động và gánh nặng công việc đã bỏ ra không hoàn lại. Thất bại không được nhận phần thưởng thành công.

| Loại việc | Thất bại thường | Thất bại nặng |
|---|---|---|
| Chấn chỉnh/hòa giải | Uy quyền −2, ổn định −1 | Uy quyền −4, ổn định −2, lòng dân −2 |
| Cứu tế/khai khẩn | Lòng dân −2, thóc −3 | Lòng dân −4, thóc −6, uy quyền −2, ngân khố −10 |
| Mua thóc | Uy quyền −1, không nhận thóc | Uy quyền −2, thêm ngân khố −15 |
| Sửa đê | Đê −4, lòng dân −2 | Đê −8, lòng dân −4, uy quyền −3, ngân khố −15 |
| Luyện quân | Quân lực −3, uy quyền −1 | Quân lực −6, uy quyền −2, ngân khố −15 |
| Cấm vệ | Uy quyền −2, ổn định −1, âm mưu +4 | Uy quyền −4, ổn định −2, âm mưu +8 |
| Hòa đàm | Chiến tranh +1, uy quyền −2 | Chiến tranh +2, uy quyền −4, ngân khố −20 |

Chi phí phát sinh vượt ngân khố chuyển phần thiếu thành nợ chi trả. Nhật ký nêu việc, người, chuyên môn/năng lực và thiệt hại thực tế; những thiệt hại chạm mốc 0 vẫn kích hoạt kết cục ở mục 23.

**Bãi chức và chọn người tiếp nhận.** Từ hồ sơ quan, mở danh sách 12 ứng viên trưởng thành, có tên, phe, chuyên môn, năng lực và giá bổ nhiệm. Đầu lượt có ba ứng viên mỗi phe, nhiều mức năng lực; ứng viên nằm trong kho riêng, không tính vào 28 quan đang tại chức. Mở/hủy màn hình không làm đổi danh sách. Chọn người rồi xem xác nhận đầy đủ trước khi gửi lệnh; thiếu tiền hoặc hành động thì không bổ nhiệm được.

Công thức cũ ở bản 0.6 là `20 + A + A² ~/ 100`, với A là năng lực; bản 0.7.2 thay bằng công thức ở mục 27. Ví dụ A=40 tốn 76, A=80 tốn 164, A=90 tốn 191. Mỗi lần tốn thêm một hành động; uy quyền +1, ổn định giảm `clamp(ảnh hưởng người cũ ~/ 12, 2, 8)`. Khi ổn định còn quá thấp, giao diện cảnh báo thao tác này sẽ làm triều đình tan rã.

Phe ứng viên +5 thái độ; phe đối lập −6 và các thành viên đối lập −2 thiện cảm. Phe quan cũ còn −4 nếu khác phe ứng viên; bổ nhiệm cùng phe vẫn có lợi +5 cho phe đó. Nếu phe cũ trùng phe đối lập, các tác động bất mãn được cộng dồn. Các chỉ số vẫn chặn tại 0–100.

Bổ nhiệm thành công gỡ ứng viên khỏi danh sách, cho tiếp nhận đúng chức vụ của người bị bãi chức, giữ nguyên chuyên môn, đồng thời bổ sung đúng một ứng viên mới theo random đã lưu. Người cũ thôi tại chức nhưng còn trong lịch sử. Công trình và sứ đoàn đang giao được chuyển sang người mới, giữ tiến độ/hạn chót; kết quả sẽ dùng chuyên môn và năng lực của người mới. Qua đời tự nhiên vẫn có cơ chế người kế nhiệm, khác với thao tác bãi chức do người chơi lựa chọn.

Lưu thêm chuyên môn trong nhân vật, `officialsPool` và bộ đếm `nextOfficialCandidate` trong lượt chơi. Bổ nhiệm ghi tiền, điểm hành động, thay người, phản ứng phe phái, chuyển công việc và danh sách mới trong cùng transaction. Gửi lặp không trừ tiền hoặc bốc thêm ứng viên; lệnh cũ/xung đột hai tab bị kiểm tra revision. Mọi phép tính vẫn ở FE, không dùng đồng hồ hoặc backend.

Bản này dùng luật `mvp-0.6.0`, nội dung 5, schema vẫn là 2. Lượt 0.2–0.5 được lưu nguyên trạng; bắt đầu lượt mới để áp dụng chuyên môn/rủi ro và bổ nhiệm có chi phí. Thành tích cũ giữ nguyên, xem theo bộ luật riêng.


**25. Kho sự kiện và phân phối ở bản 0.7.** Giữ 45 sự kiện gốc, bổ sung 405 tình huống viết riêng thành 15 nhóm, mỗi nhóm 27 tình huống. Tổng cộng 450 sự kiện và 1.330 lựa chọn. Mỗi tình huống có ID ổn định, tiêu đề, mô tả, ba nhãn quyết định; 45 mẫu quyết định mới quy định chi phí, đánh đổi chỉ số và kết quả. Các sự kiện gốc giữ số phương án riêng. Không tạo nội dung bằng cách đổi tên nhân vật hoặc ghép câu ngẫu nhiên.

| Nhóm mới | Tình huống tiêu biểu | Đánh đổi chính |
|---|---|---|
| Dân sinh | Giếng bẩn, trẻ mồ côi, mất chỗ làm | Tiền/thóc, lòng dân, uy quyền |
| Ngân khố | Sổ kép, thu trùng, góp vốn | Thu trước, mất lòng dân, nợ hoặc rủi ro đầu tư |
| Thương mại | Bến chung, đầu cơ, mua/bán thóc | Ngân khố, thóc, lòng dân, thế gia |
| Nông nghiệp | Thử giống, cứu đói, giữ nước | Chi phí trước, sản lượng về sau, rủi ro mất vụ |
| Công trình | Bờ yếu, đường hỏng, vật tư thất thoát | Tiền, lòng dân, đê, quân lực |
| Quân sự | Quân trang, tập luyện, lương đồn | Quân lực, thóc, lòng dân, phe Võ |
| Ngoại giao | Tù binh, ranh giới, buôn liên quốc | Chi phí, uy quyền, áp lực chiến tranh |
| Pháp luật | Ép cung, quyền thế, trộm vì đói | Phép nước, lòng dân, tiền, phe phái |
| Triều chính | Trình ký, quyền bộ, chi công | Ổn định, uy quyền, công sức, ngân khố |
| Phe phái | Văn–Võ, đặc quyền, tranh ngôi | Thiện cảm phe, uy quyền, âm mưu |
| An ninh | Thuốc lạ, lịch bị lộ, cửa kín | Điều tra có rủi ro, trấn áp, tiền, âm mưu |
| Hậu cung | Quà riêng, phân bổ, giải khuây | Công bằng, phe phái, thiện cảm, hưởng lạc/nghỉ |
| Sức khỏe | Mất ngủ, quá sức, đổi thuốc | Hành động, uy quyền, bệnh, mệt/căng thẳng |
| Thiên tai | Lũ, cháy, sạt, mặn | Tiền, thóc, quân lực, đê, lòng dân |
| Văn hóa | Lớp học, sân chung, thử công nghệ | Đầu tư dài hạn, công sức, tinh hoa/đại chúng |

**Chọn theo điều kiện trước, ưu tiên độ mới sau.** Bộ lọc vẫn kiểm tra tuần tối thiểu, mùa, chỉ số, chiến tranh, hậu cung và cooldown. Bổ sung điều kiện có ít nhất một phi tần đang trong cung, đê dưới 50 và độ chênh thái độ phe lớn hơn 35. Sự kiện đề cập phi tần cần có người đã nhập cung; sự kiện ngoại giao/quân sự mới mở từ tuần 8. Trong pool đủ điều kiện, lấy mức xuất hiện ít nhất, sau đó ưu tiên nhóm không xuất hiện trong 3 tuần gần nhất và thể loại khác hai thể loại vừa gặp. Nếu thiếu phương án phù hợp thì nới phần giãn nhóm/thể loại; không nới điều kiện nội dung. Random có seed chọn trong pool còn lại. Vì vậy không bốc lại sự kiện thường đã gặp khi còn tình huống chưa gặp đủ điều kiện.

Không tăng tần suất gấp mười: giữ 0–2 sự kiện thường mới mỗi tuần và giới hạn 5 tấu chương khi thêm sự kiện thường. Tiến cử hậu cung giữ lịch tuần 4 và mỗi 13 tuần. Khủng hoảng, hậu quả tới hạn không bị giới hạn này chặn. Vẫn có tuần không xuất hiện sự kiện thường.

**Khủng hoảng có nhiều lời cảnh báo, cùng một nguyên nhân.** Đói có 4 biến thể; dân biến 7; tranh ngôi, âm mưu, lũ mỗi loại 4. Tất cả biến thể cùng nguyên nhân chia cooldown gốc (5, 6, 15, 5, 8 tuần tương ứng) và chỉ có một tấu chương cùng nguyên nhân đang mở. Biến thể đã gặp ít nhất được ưu tiên; không áp dụng giãn nhóm thường để che khủng hoảng. Thiệt hại lũ áp dụng một lần lúc phát sinh, không nhân theo số biến thể. Bỏ mặc các tấu chương này vẫn chịu phạt khủng hoảng như luật cũ.

**Hậu quả nhiều tuần.** 152 lựa chọn mới có kết quả trì hoãn, 143 có nhánh thất bại. Phương án cho biết chi phí, hiệu ứng tức thời, thời gian 2–5 tuần, xác suất và cả hai nhánh kết quả; 9 lựa chọn còn lại chắc chắn có kết quả sau 4 tuần. Bốc kết quả khi người chơi xác nhận, cùng PRNG của lượt; ghi hiệu ứng đã bốc vào hậu quả chờ trong cùng transaction. Không bốc khi mở dialog, tải lại hay gửi lặp lệnh đã commit. Hiệu ứng chờ chưa được cộng sớm. Khi tới hạn, xóa khỏi hàng chờ, áp dụng đúng một lần và ghi nhật ký tên quyết định/thành công hoặc thất bại/chỉ số. Thời hạn 2 tuần tính cả tuần nhận quyết định: chọn ở tuần 1, nhận kết quả cuối tuần 2. Mục Quốc sự chỉ hiển thị tên và hạn, chưa tiết lộ nhánh kết quả.

Tiền và thóc dùng như khoản chi của lựa chọn phải được kiểm tra trước, kể cả phương án bán thóc lấy tiền. Phương án cuối miễn chi phí/hành động để luôn có cách xử lý nhưng thường gây thiệt hại. Mất tiền do hậu quả vượt số dư chuyển phần thiếu thành nợ; thóc/chỉ số tuân thủ giới hạn hiện có. Thưởng/phạt có thể tác động trực tiếp đến một phe hoặc thiện cảm thành viên đang hoạt động, không tác động ứng viên chưa nhập cung. Mốc chết/phế/mất nước tại 0 giữ nguyên.

Lưu thêm eventSeen, eventFamilyWeeks, recentEventCategories và hiệu ứng/tên/mô tả của hậu quả chờ. Tất cả do engine FE xử lý, IndexedDB lưu nguyên tử; không có server mới. Bản dùng mvp-0.7.0, nội dung 6, schema 2. Lượt 0.2–0.6 giữ nguyên trong kho cũ, thành tích vẫn xem riêng; bắt đầu triều đại mới để dùng bộ sự kiện và luật phân phối mới. Sau này server tiếp nhận cùng engine/lịch sử/random, client chỉ gửi ý định.


**26. Công việc tăng ngân khố — bản 0.7.1.** Người chơi không phải chờ sự kiện random để có thêm tiền. Nhóm “Tăng ngân khố” trong Quốc sự chứa ba lệnh chủ động, mỗi lệnh tốn 1 hành động và dùng chuyên môn Kinh tế. UI chọn quan, dự báo xác suất, số tiền, chi phí và thiệt hại trước khi xác nhận. Tất cả tính trong engine FE, lưu cùng lệnh; thiếu tài nguyên/người rảnh/hành động hoặc chưa hết hạn chờ thì từ chối nguyên tử, không đổi random.

| Công việc | Thành công | Chi phí và giới hạn áp dụng cả khi thất bại | Thất bại thường / nặng |
|---|---|---|---|
| Truy thu thuế tồn | Cơ bản +45 tiền tức thời, nhân hiệu quả người phụ trách | Không ứng vốn; lòng dân −2, mệt +4, căng thẳng +3; cooldown 4 tuần | Uy quyền −2, lòng dân −1 / uy quyền −4, lòng dân −2, ổn định −2, ngân khố −10 (ngoài chi phí chung) |
| Bán lương dư | Cơ bản +28 tiền tức thời, nhân hiệu quả người phụ trách | Xuất 40 thóc, phải giữ lại ít nhất 25 nên yêu cầu trước lệnh là 65; mệt +2; 1 lần/tuần | Không có tiền thu, thóc không hoàn; uy quyền/lòng dân mỗi chỉ số −1 / mỗi chỉ số −2, thêm ngân khố −8 |
| Mở đoàn thương mại | Cơ bản +110 doanh thu sau 4 tuần, nhân hiệu quả người phụ trách rồi nhân hệ số liêm chính 0,75–1,25 | Ứng 40 vốn; chỉ một đoàn đang chạy; người phụ trách bận cho tới hoàn tất | Không có doanh thu, không hoàn vốn; thêm ngân khố −10, uy quyền −1 / thêm ngân khố −20, uy quyền −2, lòng dân −2 |

Hai việc tức thời bốc kết quả lúc gửi lệnh; thương mại bốc khi đủ tiến độ, theo cùng quy tắc thành công/thất bại nặng ở mục 24. Ví dụ truy thu ở tuần 1 thì được thử lại từ tuần 5, kể cả lần trước thất bại. Bán thóc có hạn mức theo tuần được lưu trong actionCounts; truy thu lưu cooldown với khóa riêng, không đụng lịch sự kiện. Hạn mức và chi phí áp dụng trước khi xét kết quả. Các việc tính là xử lý quốc sự, có công sức và ảnh hưởng làm quá độ theo luật sức khỏe chung. Tiền lỗ vượt số dư chuyển sang nợ; các mốc kết thúc tại 0 giữ nguyên.

Nguồn thu cơ bản còn điều chỉnh theo năng lực/chuyên môn, không phải mức cố định hoặc bảo đảm thành công. UI thương mại hiển thị khoảng tiền ứng với liêm chính 0–100, không tiết lộ liêm chính chưa điều tra; doanh thu chưa trừ 40 vốn. Không cộng tiền khi vừa mở đoàn. Đoàn bắt đầu tuần N nhận kết quả cuối tuần N+3; lưu/tải giữ tiến độ. Thay người chuyển đoàn và giữ tiến độ nhưng đổi mức phù hợp/năng lực/liêm chính dùng để tính kết quả. Chỉ nhận doanh thu một lần, sau đó giải phóng người phụ trách. Mua 30 thóc cơ bản với giá 45 rồi bán 40 thóc lấy 28 tiền cơ bản không tạo vòng sinh lời, kể cả với hệ số tối đa.

Bản dùng luật mvp-0.7.1, nội dung sự kiện vẫn là 6, schema vẫn là 2. Bản lưu 0.7.0 tương thích đầy đủ và nâng tại ranh giới GameArchive: giữ nguyên mọi dữ liệu lượt, chỉ đổi nhãn luật. Lượt đang chơi tiếp tục được, không vào kho bỏ dở, không reset seed/revision/hạn chờ/công việc. Điểm cũ giữ nhãn luật cũ và xem riêng; lượt kết thúc sau nâng dùng luật mới. Bản 0.2–0.6 vẫn giữ chính sách lưu nguyên trạng ở mục trước. IndexedDB ghi nguyên tử, retry lệnh không tăng tiền hoặc tạo đoàn lần nữa. Không thêm backend.


**27. Phí bổ nhiệm theo chức vụ và địa vị — bản 0.7.2.** Giảm phí còn khoảng 1/10–1/5 mức cũ để thay quan là một lựa chọn có thể cân nhắc cùng các công việc quốc sự. Giá phụ thuộc ba yếu tố công khai: năng lực A, địa vị ứng viên (dùng ảnh hưởng I) và bậc chức vụ tiếp nhận R. Không dùng thiện cảm, phẩm chất ẩn, số dư ngân khố, chức hiện tại của ứng viên hoặc ảnh hưởng người cũ để tính giá.

Công thức: A và I giới hạn 0–100; nền B = 20 + A + (A² ~/ 100); mức địa vị S = ceil(I / 25), từ 0 đến 4; tỷ lệ P = 10 + 2 × (R − 1) + S, từ 10 đến 20%; phí = round(B × P / 100). Làm tròn đến tiền nguyên. Năng lực tăng làm nền cao hơn; địa vị tăng theo từng ngưỡng 25 ảnh hưởng; cùng một người thì bậc chức cao hơn có tỷ lệ lớn hơn. Không tăng phí khi số dư ngân khố tăng.

| Bậc chức vụ | Các chức vụ |
|---|---|
| 1 | Học sĩ, Võ quan, Ngự tiền, Quan điền |
| 2 | Tri phủ, Mật thám, Ngự y, Cấm vệ, Biên tướng, Trấn thủ, Tổng quản, Thương chính |
| 3 | Hộ bộ, Lại bộ, Lễ bộ, Công bộ, Hình bộ, Ngự sử, Phó tướng, Đô đốc, Quận vương, Tông chính, Tuần phủ |
| 4 | Tể tướng, Đại tướng, Thái phó, Thân vương, Quốc công |

Cấu hình bao phủ cả 28 chức vụ đang có. Chức mới chưa có cấu hình tạm dùng bậc 2; khi thêm nội dung cần khai báo bậc rõ ràng. Đây là bậc của vị trí đang tuyển, giữ nguyên khi đổi người. Địa vị dùng ảnh hưởng của ứng viên trước bổ nhiệm; chọn người có nhiều ảnh hưởng làm phí cao hơn trong cùng chức vụ.

Ví dụ cùng ứng viên A=80, I=40: nền cũ 164, S=2. Bậc 1 dùng 12% → 20 tiền, bậc 2 dùng 14% → 23, bậc 3 dùng 16% → 26, bậc 4 dùng 18% → 30. Trước đây cả bốn đều là 164. Toàn thang A/I 0–100 có phí 2–44; ứng viên thực tế chủ yếu có năng lực 32–94 và ảnh hưởng 25–50 nên phí thấp hơn nhiều so với vốn/phần thưởng của một công việc.

UI hiển thị bậc chức đang tuyển ở đầu danh sách; mỗi ứng viên có năng lực, chuyên môn, ảnh hưởng và tổng phí. Bước xác nhận nhắc lại ba yếu tố, tổng tiền và hậu quả phe phái/ổn định. Engine tự lấy chức vụ của người đang bị thay, tính và giữ báo giá trước khi đổi vai trò ứng viên; số tiền trừ và nhật ký dùng đúng báo giá đó. Không tin giá hay chức danh do client gửi. Không đủ tiền hoặc hành động thì từ chối nguyên tử, không đổi danh sách/random. Retry không thu thêm tiền.

Giữ 1 hành động, uy quyền +1, xáo trộn ổn định theo ảnh hưởng người cũ, phản ứng phe phái và chuyển tiến độ công việc như mục 24. Chỉ đổi phí và lời giải thích liên quan. Luật mvp-0.7.2, content 6/schema 2; lượt 0.7.0 và 0.7.1 nâng tương thích, giữ nguyên tiến trình, seed, revision, danh sách, công việc và biên nhận. Không hoàn tiền những lần bổ nhiệm đã hoàn tất trước đây. Thành tích đã ghi giữ nhãn luật cũ; lượt kết thúc sau nâng ghi theo luật mới. Vẫn xử lý FE và lưu local.


**28. Mở rộng quan địa phương — bản 0.7.3.** Tăng số vị trí địa phương từ 3 lên 10, gồm 4 Tri phủ, 3 Tuần phủ, 3 Quan điền. Ba người hiện có giữ nguyên; thêm bảy người có ID riêng, không tạo thêm loại chức vụ. Tổng số quan đang tại chức đầu lượt tăng từ 28 lên 35. Hậu cung ban đầu vẫn có 10 ứng viên, danh sách tuyển quan vẫn là 12 người riêng. Số người từng xuất hiện trong lịch sử có thể lớn hơn khi thay quan, nhưng số vị trí không tăng do thao tác bãi chức.

| Người mới | Chức vụ | Phe | Năng lực | Ảnh hưởng | Địa bàn trong mô tả |
|---|---|---|---:|---:|---|
| Phan Nhật Quang | Tri phủ | Văn thần | 84 | 46 | Bắc Sơn |
| Trịnh Bảo Nghi | Tri phủ | Võ tướng | 52 | 39 | Đông Hải |
| Đinh Hữu Dư | Tri phủ | Hoàng tộc | 38 | 52 | Tây Lĩnh |
| Hồ Đức Lâm | Tuần phủ | Thế gia | 88 | 73 | Nam Xuyên |
| Đoàn Quang Thịnh | Tuần phủ | Văn thần | 65 | 57 | Thượng Nguyên |
| Ngô Khắc Nông | Quan điền | Võ tướng | 79 | 35 | Duyên Hà |
| Cao Minh Túc | Quan điền | Hoàng tộc | 47 | 32 | Bình Trạch |

Năng lực, trung thành, tham vọng, liêm chính, ảnh hưởng và tính cách được phân hóa. Người giỏi không bảo đảm liêm chính/trung thành; người yếu tạo lý do thay thế. Tri phủ/Tuần phủ dùng chuyên môn Công trình, Quan điền dùng Kinh tế như quy tắc hiện có. Danh mục Địa phương hiển thị 10 người, tìm Tri phủ có 4, Tuần phủ có 3, Quan điền có 3. Phe phân bổ tổng triều thần thành 9 Văn thần, 9 Võ tướng, 9 Hoàng tộc, 8 Thế gia. Không có thêm bộ lọc địa bàn hoặc hệ thống quản lý lãnh thổ trong bản này; địa bàn nằm trong mô tả để phân biệt người cùng chức.

Các quan cùng chức không dùng chung định danh. Triệu kiến, giao việc, điều tra và bãi chức chọn theo ID; thay một Tri phủ không đổi người hay công việc đang giao cho Tri phủ khác. Phí tiếp nhận vẫn theo bậc chức ở mục 27: Tri phủ bậc 2, Tuần phủ bậc 3, Quan điền bậc 1. Công trình/sứ đoàn gắn với ID người phụ trách. Chỉ số, điểm hành động, lương/thu chi cơ bản và nội dung 450 sự kiện giữ nguyên cấu hình.

Luật mvp-0.7.3, content 6/schema 2. Lượt mới khởi tạo đủ 35 quan. Lượt 0.7.0/0.7.1/0.7.2 đang chơi bổ sung các ID mới còn thiếu tại ranh giới đọc GameArchive, từ cùng danh sách bất biến dùng cho lượt mới. Mọi người cũ, ứng viên, thay thế trước đây, dự án, hậu quả chờ, seed/random/revision, hạn mức và biên nhận được giữ nguyên; không reset trạng thái hoặc bốc lại danh sách. Người mới nhận thiện cảm dựa trên thái độ phe hiện tại cộng độ lệch xác định từ seed, lưu baseAffection tương ứng; không tiêu thụ PRNG gameplay hoặc thay đổi chỉ số phe. Không thêm ID đã có trong court/officialsPool, kể cả người không còn tại chức. Ghi chú bổ sung chỉ xuất hiện khi có người thực sự được thêm. Sau commit, bản 0.7.3 không chạy lại bước bổ sung. Lượt đã kết thúc không thêm nhân vật vào lịch sử; điểm cũ giữ theo luật cũ, điểm sau nâng dùng luật mới. Các bản 0.2–0.6 vẫn giữ nguyên trong kho cũ.


**29. Sổ tiền và giải thích ngân sách — bản 0.7.4.** Người chơi biết tiền thu từ đâu, vì sao có số đó, chi cho việc gì và có khoản nào chưa thanh toán. Trong Tổng quan có nút “Xem thu/chi ngân khố”; Quốc sự có bảng sổ tiền và bộ chọn tuần. Báo cáo thực tế và dự toán dùng nhãn riêng, không lấy dự toán làm tiền đã phát sinh.

**Báo cáo thực tế.** Mỗi tuần lưu số dư/nợ đầu kỳ, số dư/nợ cuối kỳ, trạng thái đang ghi/đã chốt, phạm vi đầy đủ/một phần và danh sách khoản theo đúng thứ tự xảy ra. Một khoản có tiêu đề, nguyên nhân/cách tính, loại, số tiền có dấu, nghĩa vụ cần trả, thay đổi nợ và số dư/nợ ngay sau khoản đó. Các dòng tiền dương tạo tổng thu; dòng âm tạo thực chi; tiền chưa trả chỉ tăng nợ. Nợ giảm có thể do trả bằng tiền hoặc được miễn, nên hiển thị “nợ giảm” thay vì khẳng định mọi khoản giảm đều đã chi tiền.

Phép đối chiếu mỗi tuần: số dư đầu kỳ + tổng thu − thực chi = số dư cuối kỳ; nợ đầu kỳ + nợ phát sinh − nợ giảm = nợ cuối kỳ. Tổng thu/chi bao gồm quyết định trong tuần và xử lý cuối tuần: vốn công trình/thương mại, cứu tế, mua thóc, luyện quân, chữa bệnh, nghỉ vui có chi, giao việc thất bại, truy thu thuế, bán lương dư, bổ nhiệm, ban thưởng, điều tra, tuyển phi/phong hậu, lựa chọn sự kiện, tấu chương quá hạn, kết quả trì hoãn, doanh thu thương mại và thu hồi tiền thất thoát. Không ghi doanh thu trước hạn hoặc trừ lại vốn lúc thu doanh thu. Chi thóc nêu trong nguyên nhân nếu đi cùng tiền, không quy đổi thành tiền chi.

**Cách tính thường lệ dùng chung với engine.**

| Khoản | Công thức | Giải thích hiển thị |
|---|---|---|
| Thu cơ bản | 13 mỗi tuần | Nguồn thu nền cố định của vương quốc |
| Thu theo thuế | mức 0/1/2 × 8 | Nhẹ/vừa/cao; mức hiện tại và số nhân |
| Thu thêm theo lòng dân | phần nguyên lòng dân / 12 | Dùng lòng dân tại thời điểm thực sự thu, không dùng chỉ số sau khi cả tuần kết thúc |
| Quân đội | 12 + mức chiến tranh × 3 | Nền và chi thêm do chiến tranh |
| Dân sinh | 5 mỗi tuần | Chi thường lệ, khác khoản mở kho cứu tế chủ động |
| Triều đình và hậu cung | 8 + số người còn trong cung × 2 | Tính phi tần và hoàng hậu đang hoạt động, không tính ứng viên chưa nhập cung |
| Trả nợ | min(nợ, 10, số dư sau chi thường lệ − 20), khi đủ điều kiện | Không trả quá số nợ; giữ ít nhất 20 tiền; số nợ và số dư trước trả được lưu |

Chi thường lệ theo ưu tiên quân đội/dân sinh, rồi khoản còn lại, rồi triều đình. Mỗi khoản ghi yêu cầu, thực trả và phần thiếu. Phần thiếu chuyển thành nợ, áp dụng mất chỉ số theo luật cũ; không cộng phần thiếu vào thực chi. Khi mất tiền do thất bại/sự kiện vượt ngân khố, chỉ phần có thể trả mới là dòng tiền ra, phần còn lại vào nợ. Hiệu ứng giảm nợ bị giới hạn ở nợ thực có, không tạo tiền thu. Công việc dùng năng lực/chuyên môn ghi cơ bản, hệ số công khai và số làm tròn; thương mại ghi điều chỉnh chất lượng thực hiện, chỉ nêu liêm chính cụ thể khi đã xác minh. Không tự tiết lộ phẩm chất ẩn qua dòng mô tả.

Dự toán đọc trạng thái hiện tại bằng cùng hàm tính nguồn thu, khoản chi và thứ tự thanh toán mà engine sử dụng. Nó cho xem nghĩa vụ, khả năng trả, phần thiếu dự kiến, trả nợ và số dư nếu chỉ tính thường lệ. Đây không phải cam kết số dư cuối tuần: tấu chương quá hạn, quyết định tiếp theo, công trình và sự kiện đến hạn có thể làm thay đổi tiền/lòng dân/chiến tranh trước hoặc sau bước thu chi. Xem dự toán hoặc đổi tuần xem sổ không tiêu thụ hành động, random hay ghi giao dịch. Các hệ số kinh tế/phần thưởng giữ nguyên.

**Lưu và nâng phiên bản.** Thêm financialWeeks trong GameState, gồm FinanceWeek và FinanceEntry. Engine ghi từng thay đổi tiền/nợ qua cùng một hàm và cập nhật số dư báo cáo ngay trong bản sao trạng thái của lệnh. Chốt báo cáo trước khi tăng tuần; khi có hoạt động tuần sau, lấy số dư cuối kỳ trước làm đầu kỳ mới. Lượt kết thúc giữa tuần vẫn chốt sổ tiền. Giao dịch thất bại do thiếu tài nguyên không ghi khoản nào; request đã commit gửi lại không ghi thêm. IndexedDB lưu báo cáo cùng tiền, random, revision, lịch sử và scoreboard trong một transaction.

Luật mvp-0.7.4, content 6/schema 2. Bản 0.7.0–0.7.3 được đọc tương thích, giữ tiến trình và các nâng cấp quan địa phương. Trường sổ tiền thiếu thì mặc định chưa có báo cáo; không giả lập lại lịch sử dựa trên chỉ số hiện tại. Kỳ đầu bắt đầu từ số dư ở hành động mới đầu tiên và được đánh dấu một phần nếu đã có tiến trình; các kỳ sau ghi đầy đủ. UI vẫn cho đọc tổng thường lệ cũ khi có, kèm nhãn chưa gồm nhiệm vụ/sự kiện và chưa có chi tiết. Các trường lastIncome/lastExpense cũ vẫn giữ ý nghĩa thường lệ để tương thích, không dùng làm tổng thu/chi mới. Lượt không bị reset; điểm cũ xem theo nhãn luật cũ. Toàn bộ vẫn xử lý FE và lưu local.

**30. Báo cáo công việc và sự kiện đến hạn — v0.7.6.** Mỗi công trình, khai khẩn, đoàn thương mại, hòa đàm, kiểm toán, điều tra, lớp học, quân khí và kết quả trì hoãn của sự kiện tạo một báo cáo khi thực sự xử lý. Báo cáo ghi tên việc/sự kiện, quyết định hoặc người liên quan, tuần hoàn tất, trạng thái thành công/thất bại/gián đoạn/chưa có kết luận và từng biến động tài nguyên/chỉ số. Không đủ chứng cứ không được gọi là thành công; người phụ trách hoặc đối tượng đã rời chức có báo cáo gián đoạn. Các hậu quả sự kiện mới giữ tên sự kiện và quyết định gốc; dữ liệu cũ thiếu thông tin này dùng tên báo cáo hiện có.

Sau một lần sang tuần có kết quả mới, hiện một popup gom tất cả báo cáo mới, có nội dung cuộn và nút “Đã xem”. Không hiện sớm cho việc chưa đến hạn, không hiện lại báo cáo cũ khi sang tuần không có kết quả. Báo cáo được lưu trước khi mở popup; đóng hoặc xem lại không tiêu hành động, random, cộng thưởng hay trừ phạt. Nếu kết quả khiến lượt chơi kết thúc, vẫn hiện popup trên màn giải thích kết cục. Triều chính và màn giải thích kết cục có nút “Xem kết quả” cho tuần có kết quả gần nhất; Quốc sự có mục “Kết quả đã nhận” với bộ chọn tuần để đọc lịch sử sau khi tải lại. Sử ký vẫn giữ các ghi chép tương ứng.

Biến động được chụp riêng trước/sau từng kết quả, không lấy chênh lệch cả tuần: tách thu/chi thường lệ, sức khỏe, bỏ bê và các diễn biến khác. Chỉ số dùng tác động trước giới hạn, có chú thích rõ trên giao diện; tiền là phần thực tăng/giảm, thiếu hụt được ghi riêng thành nợ chi trả. Vốn cấp lúc ban lệnh không bị trừ lại khi trả kết quả; doanh thu thương mại ghi rõ chưa trừ vốn đã cấp. Các kết quả không tăng/giảm tài nguyên như xác minh hồ sơ vẫn mô tả kết quả và nơi xem thông tin mới.

GameState thêm danh sách outcomes (OutcomeReport), lưu ID, tuần, tên, trạng thái, nội dung và bản đồ biến động cùng transaction với tác động, biên nhận và random. Request lặp không tạo thêm báo cáo. Bản lưu chưa có trường này mặc định danh sách rỗng, không dựng lại số liệu quá khứ; xem kết quả cũ trong Sử ký. Không đổi phần thưởng, xác suất, lịch xử lý hoặc lượt random. Giữ luật mvp-0.7.4, content 6/schema 2 và nhóm scoreboard; phiên bản ứng dụng 0.7.6.


**32. Độ khó, chuỗi và đại biến cố ở 0.8.** Phần này thay thế các mức cân bằng/lưu trữ xung đột của các phiên bản trước. Xem [difficulty-08.md](difficulty-08.md) để biết luật hiện hành: khủng hoảng riêng, mệt/công trạng/yêu sách của quan, nghĩa vụ cứu nguy, 3 chuỗi có nhánh hậu quả, giai đoạn trị vì và 6 đại biến cố dạng nhiệm vụ. Luật `mvp-0.8.0`, nội dung 7, schema 2; giữ nguyên lượt cũ trong kho thay vì tự áp luật mới.


**33. Thư viện đại biến cố 0.8.1.** Đã triển khai 60 kịch bản review, tổng 66 loại/264 mục tiêu, cùng cơ chế ưu tiên chưa gặp, điều kiện mùa/tuần/tình hình, thưởng theo nhóm, nguồn thu/chi định kỳ và trạng thái kế vị. Nội dung 8 tiếp tục được lượt 0.8 nội dung 7; xem [major-scenarios-review-60.md](major-scenarios-review-60.md) và [difficulty-08.md](difficulty-08.md).


**34. Chuỗi tấu chương ở bản 0.17.0.** Lượt theo mùa dùng 10 chuỗi thường và 66 đại biến cố nối tiếp trong Tấu chương. Quốc sự chỉ theo dõi, không giao nhiệm vụ/ra quyết định chuỗi riêng. Lịch sử thay đổi nội dung, phí và hậu quả sau; đại biến cố chịu tổn thất theo từng mùa, không tính lại lúc tổng kết. Giữ bản lưu và công việc cũ trong transaction; lượt tuần giữ cơ chế cũ. Luật `mvp-0.17.0`, nội dung 16, schema 2. Xem [story-petitions.md](story-petitions.md) để biết danh sách, công thức và quy tắc chuyển đổi.
