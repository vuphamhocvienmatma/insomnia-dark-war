# GAME DESIGN DOCUMENT (GDD)
## TRÒ CHƠI: INSOMNIA IN THE DARK WAR
### Thể loại: Cozy Zombie Survival Lofi

---

### 1. Elevator Pitch (3 câu)
**Insomnia in the Dark War** là một trò chơi sinh tồn hậu tận thế phong cách lofi ấm áp, nơi người chơi cải tạo một pháo đài bọc thép độc đáo từ các thực thể đổ nát [8]. Ban ngày, bạn sẽ thảnh thơi dọn dẹp căn cứ, chèn lấp rào chắn, nấu ăn và trồng trọt trong không gian an toàn của riêng mình [21, 22]. Khi đêm xuống, bạn sẽ nép mình bên lò sưởi ấm cúng bập bùng cùng chú mèo nhỏ, lắng nghe tiếng mưa rơi rả rích hòa cùng giai điệu jazz lofi xoa dịu trong khi hệ thống tháp súng phun lửa tự động đẩy lùi bầy thây ma ngoài rào chắn [16, 30].

---

### 2. Core Fantasy & Tone
*   **Core Fantasy (Mộng tưởng cốt lõi):** Hiện thực hóa trọn vẹn khái niệm **"Cozy Apocalypse" (Hậu tận thế ấm cúng)** [30]. Sự bình yên và xoa dịu của game không đến từ việc quét sạch thây ma trên toàn thế giới, mà đến từ việc **tổ chức lại sự hỗn loạn một cách gọn gàng, có tiến trình đếm được và có một góc an toàn tuyệt đối để trở về** [30].
*   **Tone (Âm hưởng):** Sự tương phản cực hạn (High Contrast) giữa **bên ngoài lạnh lẽo** (sa mạc u tối hoang vu [15], bóng thây ma rình rập ngoài hàng rào [16]) và **bên trong ấm áp** (lửa sưởi mật ong bập bùng, ánh sáng lấp lánh dịu nhẹ của pin mặt trời, đồ len dày, tiếng củi nổ lách tách [16, 21]).

---

### 3. Core Loop & Session Loop

#### Vòng lặp cốt lõi (Core Loop - Cấp phút)
Áp dụng cấu trúc vòng lặp 4 bước [14]: **Hành động (Action) → Phần thưởng (Reward) → Tái đầu tư (Investment) → Gia tăng (Escalation)**.
1.  **Hành động (Action):** Nhặt phế liệu quanh pháo đài [8], kéo thả các tấm gỗ/ván sắt để lấp khe hở trên hàng rào bằng cơ chế Sockets & Snapping [22].
2.  **Phần thưởng (Reward):** Thu thập được năng lượng mặt trời (Solar Grid) để nạp đầy pin [8], nhặt được gạo măng rừng [20] hoặc đồ hộp.
3.  **Tái đầu tư (Investment):** Nâng cấp/bố trí lại súng phun lửa [8], thủ công nấu nướng hoặc chế tạo đồ nội thất trang trí căn phòng để tăng độ cozy [21].
4.  **Gia tăng (Escalation):** Đêm sau thây ma ngửi mùi máu tìm đến đông hơn một chút [8], đòi hỏi vị trí phòng thủ và lưới điện hoạt động tối ưu hơn.

#### Vòng lặp phiên chơi (Session Loop - 15 đến 20 phút)
Một phiên chơi đại diện cho một chu kỳ Ngày - Đêm hoàn chỉnh:
*   **Ban ngày (Daytime - 70% thời lượng):** Thảnh thơi nhặt phế liệu (scavenging run) [8], dọn dẹp sắp xếp pháo đài (home base reset) [30], tưới cây, nấu ăn và củng cố rào chắn [22].
*   **Ban đêm (Nighttime - 30% thời lượng):** Súng phun lửa tự kích hoạt thiêu rụi thây ma tiếp cận [8]. Người chơi an toàn ở bên trong cabin máy bay/toa tàu [15, 16], vừa xoa dịu lo âu vừa chuẩn bị sẵn vật tư để phòng thủ khẩn cấp ở tuyến sau nếu hàng rào bị vỡ [8, 33].

---

### 4. Danh sách hoạt động chi tiết

#### A. Nấu ăn (Cooking)
*   **Input Loop:** Người chơi sử dụng củi khô thu lượm ban ngày và các nguyên liệu dã ngoại như gạo măng vùng cao [20] hoặc đồ hộp bỏ hoang [8].
*   **Xử lý:** Click nhóm củi vào chiếc lò sưởi gang đặt góc phòng, đun sôi nước trên ấm đun lofi dã ngoại.
*   **Phần thưởng cảm xúc:** Âm thanh súp sôi lăn tăn hòa cùng tiếng lửa củi tí tách mang lại cảm giác ấm no, bình yên sâu sắc, xua tan cái lạnh lẽo hậu tận thế.

#### B. Làm vườn (Gardening)
*   **Input Loop:** Hạt giống hoang dã nhặt được từ các đống đổ nát ngoài sa mạc [8].
*   **Xử lý:** Gieo mầm vào các chậu đất nhỏ đặt dọc kệ cửa sổ khoang cabin [16]. Tưới nước định kỳ vào ban ngày.
*   **Phần thưởng cảm xúc:** Sự phát triển chậm rãi, xanh tươi của mầm lá tương phản trực quan với thế giới sắt thép hoang tàn gỉ sét ngoài kia, gieo vào lòng người chơi niềm hy vọng sống.

#### C. Dọn dẹp & Tái lập (Cleaning & Base Reset)
*   **Input Loop:** Sàn pháo đài bám bẩn hoặc vật dụng nội thất bị xô lệch sau các đợt va chạm đêm hôm trước [30].
*   **Xử lý:** Quét dọn các vết bẩn, sắp xếp lại kho đồ lộn xộn ngăn nắp [30], dựng lại chiếc ghế gỗ bị đổ.
*   **Phần thưởng cảm xúc:** Chuyển hóa stress vô hình của cuộc sống thành một hành động dọn dẹp vật lý trực quan. Nhìn căn phòng từ bừa bộn trở nên sạch sẽ ngăn nắp giúp bộ não đạt được trạng thái thư giãn tuyệt đối (Home base reset) [30].

#### D. Phòng thủ zombie nhẹ nhàng (Gentle Defense)
*   **Input Loop:** Bầy thây ma lảo đảo chạm vào rào chắn khi đêm xuống [8].
*   **Xử lý:** Các tháp súng phun lửa tự kích hoạt tiêu diệt quái vật khi chạm vào vùng rà quét của lưới điện mặt trời [8]. Người chơi chỉ cần vá nhanh rào bằng cơ chế bám dính tự động nếu một góc rào bị cào rách (phòng thủ thích ứng) [22, 33].
*   **Phần thưởng cảm xúc:** Sự an toàn tuyệt đối khi đứng sau lớp kính bọc thép dày của máy bay/toa tàu [15, 16], nhìn bầy quái vật hoàn toàn bất lực ngoài kia, biến thảm họa hậu tận thế thành một phông nền lãng mạn lofi.

---

### 5. Những thứ game KHÔNG có
*   **Không Gameplay Disguise (Kéo chốt giả):** Loại bỏ hoàn toàn cơ chế giải đố kéo chốt lừa dối thường thấy trên các quảng cáo lừa đảo [11, 27].
*   **Không Narrative Pretense (Cốt truyện kịch tính giả):** Không tạo ra drama gia đình bi thảm (như người vợ bị bỏ rơi trốn vào nhà hoang tuyết rơi) chỉ để thu hút cài đặt rồi mang lại gameplay nông trại phẳng dẹt [11, 31].
*   **Không MMO 4X Guild Wars & PvP:** Không có bang hội tranh đoạt đất đai, không bị người chơi khác cướp bóc tàn phá pháo đài khi offline.
*   **Không Pay-To-Win & Timers ép buộc:** Không giới hạn lượt chơi bằng thể lực, không bắt người chơi nạp tiền để rút ngắn thời gian xây dựng hay nâng cấp tháp pháo.
*   **[AI ĐOÁN] Không thanh máu căng thẳng:** Nhân vật không bị quái vật cắn chết lập tức hay sụt giảm máu sinh học liên tục. Thanh máu được thay thế bằng trạng thái "Insomnia" (Mất ngủ) - nếu rào chắn rò rỉ góc chết đêm trước, nhân vật sẽ mệt mỏi, đi chậm lại đôi chút vào hôm sau thay vì chết.

---

### 6. Phong cách hình ảnh & âm thanh

#### Phong cách hình ảnh (Visual Style)
*   **Cel-shading / Toon-shading:** Sử dụng nét vẽ viền đen (ink outlines) rõ ràng bao quanh các khối vật thể [4], mang lại phong cách truyện tranh vẽ tay có chất liệu nhám mộc mạc như giấy vẽ.
*   **Tương phản ánh sáng cực mạnh (High Contrast):** Đêm sa mạc bên ngoài hoang vu tăm tối phủ sắc xanh Cobalt lạnh [15], trong khi cabin pháo đài bên trong rực rỡ sắc cam bập bùng của lửa sưởi ấm cúng [16].
*   **Silhouette & Exaggeration (Hình khối & Phóng đại):** Thiết kế nhân vật có bóng silhouette tròn trịa, thân thiện mặc áo len ấm áp [13]. Chuyển động thây ma lảo đảo giật lofi ở tốc độ stop-motion (4-8 FPS).

#### Phong cách âm thanh (Audio Style)
*   **Nhạc nền (BGM):** Nhạc nền Jazzy Lofi Hip-hop nhẹ nhàng với nhịp điệu chậm rãi (70-80 BPM) chơi lặp đi lặp lại để xoa dịu tâm trí [1].
*   **Hiệu ứng âm thanh (SFX) & Ambient:**
    *   Tiếng củi thông nổ tí tách rộn ràng hòa cùng tiếng mưa rơi rả rích gõ đều đặn lên phần vỏ kim loại cabin [21].
    *   Âm thanh xây dựng modular phát ra tiếng cọc cạch khô giòn và lách cách vui tai của kim loại/gỗ ghép khớp ("CLATTER") [22].
    *   Tiếng "THWACK" trầm đục khi thây ma va đập vào rào gỗ bên ngoài đi kèm hiệu ứng máy ảnh giật nhẹ (Camera Shake) để tạo phản hồi va chạm sinh động [26].

---

### 7. HUD/UI tối giản
*   **Không gian hiển thị chính:** Mô hình cắt lớp 2.5D (Cross-section view) trực diện của pháo đài đặt tại tâm màn hình, cho thấy rõ cả nội thất bên trong lẫn ngoại cảnh zombie ngoài rào chắn [15, 16].
*   **Góc trên bên phải:** Một chiếc đồng hồ tròn cơ học lofi tối giản biểu thị chu kỳ Ngày/Đêm hiện tại và thời gian còn lại trước hoàng hôn.
*   **Góc dưới màn hình:** Lưới ô vuông mờ để chứa phế liệu và vật liệu nấu ăn bập bùng.
*   **Mép màn hình:** Checklist mục tiêu dọn dẹp, gia cố viết bằng nét chữ tay nhỏ gọn.
*   **[AI ĐOÁN] Tuyệt đối không có bảng pop-up nhấp nháy quảng cáo nạp tiền hay nút Cửa hàng làm xao nhãng cảm xúc chill của trò chơi.**

---

### 8. Điều kiện thắng/thua (Sandbox Flow)
*   **Điều kiện thua (Loss Condition) - Không bao giờ là dấu chấm hết:** Game áp dụng triết lý "chuẩn bị cho thất bại" [33]. Nếu hàng rào gỗ bị vỡ, quái vật không ăn thịt bạn. Chúng chỉ quấy phá làm đổ bàn ghế, làm bẩn sàn nhà, lấy đi một ít tài nguyên đóng hộp [33]. Sáng hôm sau, người chơi chỉ cần lau dọn, dựng lại ghế và gia cố rào chắn kiên cố hơn [33].
*   **Điều kiện thắng (Win Condition):** Trò chơi vận hành theo dạng Sandbox thư giãn vô hạn. Mục tiêu tối cao là bạn tự tay cải tạo được một pháo đài hoàn hảo theo gu thẩm mỹ của mình: từ một xác máy bay gỉ sét ban đầu trở thành một "ốc đảo lofi ấm áp" bọc thép kiên cố có súng phun lửa tự động, rèm cửa ấm cúng và lò sưởi bập bùng [15, 16].
