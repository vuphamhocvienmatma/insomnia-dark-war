# Insomnia in the Dark War

> Một tựa game sinh tồn chill-lofi 2.5D Diorama viết bằng **Godot 4.7** (GDScript), nơi bạn xây dựng căn cứ, chăm sóc vườn tược, nuôi mèo đồng hành, đọc thư từ phương xa và chống chọi từng đêm zombie — tất cả dưới ánh sáng ấm áp của một căn cabin gỗ giữa vùng hoang tàn sau chiến tranh.

---

## 1. Tổng Quan

**Insomnia in the Dark War** (*Mất ngủ giữa cuộc chiến bóng tối*) là tựa game sinh tồn thư giãn (cozy-survival) theo chu kỳ **Ngày / Đêm** mang phong cách diorama hoài niệm:

- **Ban ngày**: Thu thập phế liệu (scrap), hạt giống (seed), nước (water); trồng và tưới cây; kiểm tra hòm thư nhận tiếp tế; xây dựng hàng rào quanh pháo đài; nấu súp lò sưởi; vuốt ve mèo cưng; nghe đĩa than lofi.
- **Ban hoàng hôn**: Toast cảnh báo hoàng hôn 10 giây trước khi đêm xuống kèm hiệu ứng nhấp nháy viền đỏ màn hình.
- **Ban đêm**: Zombie mắt đỏ tràn đến từ hai rìa sa mạc. Hai khẩu súng AK-47 trên mái dốc tự động nã đạn bảo vệ căn cứ tiêu tốn pin mặt trời (Solar). Nếu hàng rào bị xuyên thủng → bạn sẽ **mất ngủ** (giảm tốc chạy) vào ngày hôm sau.

Mục tiêu: Sống sót qua các chu kỳ ngày-đêm, gắn kết tình bạn với những người sống sót phương xa qua hòm thư, tối ưu hóa công sự và tận hưởng không gian lofi ấm cúng.

---

## 2. Tính Năng Nổi Bật 🌟

1. **Procedural Rendering (Vẽ Thuật Toán)**
   - Game hoàn toàn **không sử dụng Sprite/Texture (ảnh bitmap)**. Mọi thứ từ Căn nhà, Bàn làm việc, Cây cối, cho đến Zombie, Mèo, Hòm thư đều được vẽ tay 100% bằng code thông qua các lệnh draw_colored_polygon, draw_circle, draw_line.
   - **Tối ưu hóa cực cao**: Mọi khối vector phức tạp đều được *cache* ở _ready(), triệt tiêu hoàn toàn gánh nặng bộ nhớ. Game nhẹ, load nhanh và chạy siêu mượt trên Web HTML5.

2. **Giao Diện Động 2.5D & Hiệu Ứng Chiều Sâu**
   - **Cửa Cabin Thực Tế**: Cửa có viền tường (depth bevel) và hiệu ứng xoay (swing) mở cánh theo góc nhìn 2.5D mượt mà kèm âm thanh chân thực.
   - **Mặt Tiền Trang Trí Sinh Động**: Có mái hiên gỗ (porch roof), chậu hoa, bệ cửa sổ, dây leo xanh, và đèn hiên tự động phát sáng vào ban đêm. Khi Zoom, mặt tiền mờ đi (fade) để lộ nội thất cực chill bên trong.

3. **Cơ Chế Hòm Thư & Tình Bạn (Affinity System)**
   - Mỗi ngày, Hòm thư tự động nhận thư từ các NPC phương xa (Bác Sáu, Cô Anna, Trader Jim...).
   - Hiệu ứng máy đánh chữ (Typewriter effect) kèm âm thanh gõ lạch cạch.
   - Reply thư để tăng độ "Thân mật" (Affinity ❤️) và nhận phần thưởng đính kèm.

4. **Hệ Thống Chiến Đấu Thông Minh & An Toàn**
   - Súng máy tự động (Auto Turret) tracking thông minh, chuyển mục tiêu mượt mà khi Zombie bị tiêu diệt hoặc ra khỏi tầm ngắm.
   - Zombie (Runner, Brute, Thief) với các chỉ số riêng biệt, có khả năng ăn trộm phế liệu, và được tối ưu hóa vật lý ngay khi gục ngã để tránh lỗi va chạm (collision bugs).

5. **Lofi Shader & Web Font Support**
   - Lofi Wobble Post-Processing: Shader tái tạo cảm giác nhiễu sóng nhẹ (dithering) của màn hình CRT cũ mà vẫn giữ cho UI sắc nét. Mức độ giật lag máy quay được tinh chỉnh để tạo cảm giác "thoang thoảng" thay vì rung lắc dữ dội.
   - **Emoji Web Font**: Game tích hợp bộ Font dự phòng (Fallback Font) NotoColorEmoji giúp toàn bộ Icon / Emoji hiển thị rực rỡ và hoàn hảo kể cả khi chơi trực tiếp trên Web Browser.

---

## 3. Kiến Trúc Mã Nguồn (Cho Developer)

- **Godot 4.7 Standard**: Áp dụng chuẩn code GDScript mới nhất với Static Typing khắt khe. Không còn sử dụng yield(), instance(), hay các tàn dư của Godot 3.
- **Save/Load Tuyệt Đối An Toàn**: Hệ thống Checkpoint parse JSON với các bước chặn lỗi kiểu dữ liệu (	ypeof() == TYPE_DICTIONARY), đảm bảo game không bao giờ crash nếu file save bị can thiệp hay hỏng.
- **Diegetic UI & Tweening**: Hạn chế tối đa các UI trôi nổi (floating HUD). Ưu tiên gắn UI vào môi trường 2.5D, và toàn bộ hiệu ứng chuyển động đều dùng create_tween().set_ease().set_trans(), có cơ chế dọn dẹp (kill) tự động để chống memory leak.

---

## 4. Hướng Dẫn Cài Đặt & Chơi Ngay

1. Cài đặt **Godot 4.7** (hoặc bản tương đương 4.x).
2. Clone repository này về máy.
3. Mở file project.godot bằng Godot Editor.
4. Nhấn F5 hoặc bấm nút Play để khởi chạy.
5. (Hoặc) Nhấn nút **Export -> Web** để build ra bản HTML5 và up lên itch.io dễ dàng!

*P/s: Hãy nhớ nạp năng lượng cho hệ thống pin mặt trời vào ban ngày, nếu không súng máy sẽ vô dụng khi màn đêm buông xuống đấy!* 🔋