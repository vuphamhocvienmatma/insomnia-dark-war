# Insomnia in the Dark War

> Một tựa game sinh tồn chill-lofi 2.5D Diorama viết bằng **Godot 4.7** (GDScript), nơi bạn xây dựng
> căn cứ, chăm sóc vườn tược, nuôi mèo đồng hành, đọc thư từ phương xa và chống chọi từng đêm zombie — tất cả
> dưới ánh sáng ấm áp của một căn cabin gỗ giữa vùng hoang tàn sau chiến tranh.

---

## 1. Tổng Quan

**Insomnia in the Dark War** (*Mất ngủ giữa cuộc chiến bóng tối*) là tựa game sinh tồn thư giãn (cozy-survival) theo chu kỳ **Ngày / Đêm** mang phong cách quảng cáo hoạt hình hoài niệm:

- **Ban ngày**: Thu thập phế liệu (scrap), hạt giống (seed), nước (water); trồng và tưới cây; kiểm tra hòm thư nhận tiếp tế; xây dựng hàng rào quanh pháo đài; nấu súp lò sưởi; vuốt ve mèo cưng; nghe đĩa than lofi.
- **Ban hoàng hôn**: Toast cảnh báo hoàng hôn 10 giây trước khi đêm xuống kèm hiệu ứng nhấp nháy viền đỏ màn hình.
- **Ban đêm**: Zombie mắt đỏ tràn đến từ hai rìa sa mạc. Hai khẩu súng AK-47 trên mái dốc tự động nã đạn bảo vệ căn cứ tiêu tốn pin mặt trời (Solar). Nếu hàng rào bị xuyên thủng → bạn sẽ **mất ngủ** (giảm tốc chạy) vào ngày hôm sau.

Mục tiêu: Sống sót qua các chu kỳ ngày-đêm, gắn kết tình bạn với những người sống sót phương xa qua hòm thư, tối ưu hóa công sự và tận hưởng không gian lofi ấm cúng.

---

## 2. Tính Năng Chính Mới Nhất

| Hệ thống | Mô tả chi tiết |
|----------|----------------|
| **2.5D Diorama Cutaway** | Không gian đa tầng có chiều sâu 2.5D, mặt vách địa chất trầm tích tự nhiên, hầm trú ẩn ngầm và cabin gỗ cắt lớp ấm cúng. |
| **Zombie Đột Biến Ban Đêm** | 4 chủng loại: Normal, **Runner** (nhanh, mắt rực lửa, máu giấy), **Brute** (khổng lồ, giáp thép, đập đau x3), **Thief** (lén lút cuỗm 2 phế liệu, hạ gục thu hồi lại). |
| **Đêm Ác Mộng Mỗi 5 Ngày** | Cảnh báo trước qua Radio: Zombie tăng tốc 30%, Jackpot phế liệu x2, Nhật thực sụt 50% Solar, hoặc Sương mù che mắt. |
| **Thương Nhân Chó Robot** | Chó robot balo ghé hiên mỗi 3 ngày, bán hạt giống, nước, đồ decor Cozy Score, Blueprint công sự và Băng cassette lofi. |
| **Hòm Thư Story Arc & Mini-Endings** | Chuỗi 6-8 thư cốt truyện, lựa chọn cộng dồn thân mật; kết thúc bằng 4 bảo vật vĩnh viễn (Cần Câu Vàng, Kính Nhìn Đêm, Bình Tưới Thần Kỳ, Nòng AK Mạ Crom). |
| **Thời Tiết Có Hệ Quả** | Bão cát sa mạc (+4 scrap rơi, mèo ở nhà sưởi), Mưa axit (cây lớn x2, solar -50%), Mưa sao băng (rơi +12 scrap quý hiếm). |
| **Tường Huy Chương Gỗ** | Bảng gỗ chạm khắc 7 huân chương thành tựu treo trên tường gác xép tầng 2 (Sống sót 7 ngày, 50 kill, Tri kỷ, Nông dân, Thợ xây, Bếp trưởng, Vua ấm cúng). |
| **Cá Nhân Hóa Cabin & Cozy Score** | Thảm len dệt thổ cẩm, Quả cầu disco lấp lánh, Tranh poster hoài niệm, Đổi màu đèn fairy lights pastel; buff tốc độ cho mèo và bớt mệt mỏi. |
| **Nấu Ăn 2.0 (Strategic Cooking)** | 4 món ăn nấu từ thảo dược: Canh măng (+tốc độ chạy), Trà hoa cúc (+sạc Solar), Súp kiên cố (+HP tường và cửa), Bánh hạt (+mèo may mắn x2 tài nguyên). |
| **Cửa Chính Ra Vào & Gia Cố 3 Cấp** | Cửa gỗ dã chiến có thể Đóng/Mở chặn zombie; gia cố bằng phế liệu lên Cấp 2 (Nẹp sắt 250 HP) và Cấp 3 (Thiết giáp 500 HP). |
| **Thang Trong Nhà & Chuột Tương Tác** | Leo thang bằng phím [E] mượt mà; con trỏ chuột lofi phát sáng đổi hình `👆` khi hover action và click trực tiếp. |

---

## 3. Cấu Trúc Dự Án

```
insomnia-in-the-dark-war/
├── project.godot              # Cấu hình dự án, input mapping, autoload singletons
├── docs/
│   ├── AGENTS.md              # Quy tắc phát triển mã nguồn bắt buộc
│   └── godot4_cheatsheet.md   # Cú pháp Godot 4.x chuẩn
├── scenes/
│   ├── main_level.tscn        # Scene màn chơi chính
│   ├── player.tscn            # Nhân vật người chơi
│   ├── companion_cat.tscn     # Mèo đồng hành
│   ├── zombie.tscn            # Zombie kẻ địch
│   ├── mailbox.tscn           # Hòm thư dã chiến
│   ├── auto_turret.tscn       # Ổ súng AK-47 dã chiến
│   ├── scrap_item.tscn        # Phế liệu, hạt giống, nước
│   ├── relic_item.tscn        # Cổ vật tăng chỉ số
│   ├── plant_pot.tscn         # Chậu cây hoa thảo dược
│   ├── wall_piece.tscn        # Tường phòng thủ
│   ├── stove.tscn             # Bếp súp lò sưởi
│   └── hud.tscn               # Giao diện người dùng
├── scripts/
│   ├── mailbox_manager.gd     # Quản lý thư từ, độ thân mật, quà bất ngờ
│   ├── mailbox_ui.gd          # Giao diện thư giấy da cổ điển, lựa chọn hồi âm
│   ├── art_mailbox.gd         # Vẽ hòm thư, lá cờ đỏ animated
│   ├── camera_lofi.gd         # Camera zoom chuột, chống rung, bám nhân vật
│   ├── art_player.gd          # Render nhân vật, cử động leo thang chân tay phối hợp
│   ├── art_cabin_props.gd     # Vẽ cabin, thang trong nhà, lỗ sàn tầng 2, đèn dây
│   ├── hud.gd                 # Đồng hồ Lofi, pin solar, zoom controls, toasts
│   ├── game_state.gd          # Tài nguyên toàn cục
│   └── level_setup.gd         # Khởi tạo màn chơi, sinh hòm thư, wave zombie
└── shaders/
    └── lofi_post_process.gdshader # Shader phim nhựa, hạt nhiễu (film grain), vignette ấm
```

### 3.1 Autoloads Toàn Cục (`project.godot`)

| Tên Singleton | Script | Trách nhiệm |
|---------------|--------|-------------|
| `GameState` | `game_state.gd` | Kho tài nguyên (scrap, seed, water), trạng thái mệt mỏi, relic buffs. |
| `JournalManager` | `journal_manager.gd` | Quản lý 3 nhiệm vụ hàng ngày, theo dõi tiến trình thực hiện. |
| `MailboxManager` | `mailbox_manager.gd` | Hệ thống thư từ ngẫu nhiên, độ thân mật pen-pal, quà tiếp tế & quà bất ngờ. |
| `SaveManager` | `save_manager.gd` | Lưu trữ và tải tiến trình chơi JSON vào `user://`. |
| `UnlockManager` | `unlock_manager.gd` | Xử lý mở khóa các tính năng và cổ vật. |

---

## 4. Hệ Thống Hòm Thư & Bằng Hữu Phương Xa (Wasteland Postal Mailbox)

Hòm thư đặt trước hiên cabin (`x = -225`). Khi có thư mới, **lá cờ đỏ 🚩 sẽ bật đứng dậy** kèm phong thư nhấp nháy:

- **Các Người Bạn Phương Xa**:
  - 🎣 **Bác Sáu (Câu Cá Sa Mạc)**: Lão già hóm hỉnh, hay kể chuyện hài câu trúng zombie dưới đụn cát, tặng nước ngọt và hạt giống.
  - 📡 **Bóng Đêm 404 (Trạm Vô Tuyến)**: Nhân vật tuần đêm bí ẩn, cảnh báo những hiện tượng rùng rợn lúc 3h sáng, hỗ trợ linh kiện thép.
  - 🌻 **Cô Bé Hoa Cúc (Trạm Cứu Hộ)**: Những lá thư ấm áp động viên, gửi tặng hạt hoa cúc dại và trà thảo mộc.
  - 🔧 **Thợ Máy Râu Kẽm (Xưởng Ngầm)**: Bác thợ máy chuyên chế đồ độ súng AK, gửi phụ tùng giảm giật và phế liệu.
- **Hồi Âm & Điểm Thân Mật (Affinity)**:
  - Mỗi bức thư có 3 phương án hồi âm (Thân thiện / Vui vẻ / Khó tính).
  - Điểm thân mật tăng/giảm ảnh hưởng trực tiếp đến thái độ của người gửi.
- **Quà Bất Ngờ (Surprise Packages)**:
  - Khi đạt mốc **30** và **60** điểm thân mật, bạn sẽ nhận được **Thùng Đồ Tri Kỷ** với lượng tài nguyên dồi dào (+40 Phế liệu, +12 Hạt giống, +5 Nước).

---

## 5. Hướng Dẫn Điều Khiển & Phím Tắt

- **Di chuyển**: Phím mũi tên hoặc `A` / `D` (Trái / Phải).
- **Leo thang**: Đứng tại vị trí thang trong nhà (`x = 150`), nhấn `W` / `Mũi tên Lên` để trèo lên gác xép, `S` / `Mũi tên Xuống` để trèo xuống.
- **Tương tác**: Phím `E` (Nhặt phế liệu, mở hòm thư đọc thư, vuốt ve mèo, thu hoạch cây, nấu súp).
- **Xây hàng rào**: Di chuột vào ô socket gần pháo đài và **Chuột trái** để xây tường.
- **Phóng to / Thu nhỏ camera**:
  - **Cuộn chuột (Mouse Wheel)**: Lăn lên để phóng to cận cảnh cabin, lăn xuống để nhìn bao quát sa mạc.
  - **Nút bấm UI**: Click các nút `－`, `1.0x`, `＋` ở góc trên bên phải màn hình.
- **Nhiệm vụ & Hướng dẫn**: Click nút `📋 Nhiệm Vụ & Hướng Dẫn` ở góc dưới bên phải để mở rộng menu nhiệm vụ.

---

## 6. Cách Chạy Game

1. Khởi chạy **Godot 4.7** (hoặc bản 4.x tương thích).
2. Chọn `Import` trỏ đến thư mục `insomnia-in-the-dark-war/project.godot`.
3. Nhấn **F5** (hoặc nút Run Project) để khởi chạy `scenes/main_level.tscn`.

---

## 7. Tối Ưu Hóa HTML5 / WebGL & Chế Độ Tiết Kiệm (Eco Mode)

Dự án được tối ưu sâu cho xuất bản Web (HTML5 / WASM) và phần cứng yếu:

- **Nút Bật/Tắt Eco Mode (`[⚡ Eco: BẬT/TẮT]`)**: Tích hợp trên HUD góc trên bên phải. Khi bật, game sẽ tắt lớp shader hậu kỳ (film grain, chromatic aberration, vignette) và tắt nhấp nháy đèn lò sưởi, giảm tải GPU tới 60%. Game tự động nhận diện và kích hoạt Eco Mode khi chạy trên trình duyệt Web.
- **Triệt tiêu Redraw lặp lại mỗi frame (`queue_redraw`)**:
  - `art_skyline.gd` & `art_ground_props.gd`: Tách nền tĩnh (vẽ 1 lần) khỏi hiệu ứng chuyển động (chim, lá bay, cỏ lay) và giảm tần số vẽ xuống 15-20 fps.
  - `art_scrap.gd`: Chuyển hiệu ứng nhấp nhô sang GPU transform (`position.y`), giảm 1.560 lần gọi redraw mỗi giây xuống còn 0 lần trong gameplay!
  - `art_plantpot.gd`, `art_zombie.gd`, `art_player.gd`, `art_cat.gd`, `art_clouds.gd`, `art_night_sky.gd`, `art_merchant_dog.gd`, `art_cursor_drawer.gd`, `art_stove.gd`: Đều được throttle và kiểm tra trạng thái hiển thị / di chuột thông minh.
- **Bộ nhớ âm thanh siêu gọn**: Chuyển đổi toàn bộ nhạc nền BGM từ PCM .WAV (5.2 MB) sang Vorbis .OGG (360 KB), giảm dung lượng tới 15 lần và nạp tức thì trên web.
- **Tối ưu Physics & Giới hạn Zombie**:
  - Giới hạn tối đa đàn zombie mỗi đêm là 18 con, tránh drop FPS ở các ngày sinh tồn cao.
  - Thu hẹp bán kính quét Area2D của tháp pháo AK từ 320px xuống 260px.
  - Chuyển hạt máu zombie sang `CPUParticles2D` tương thích 100% chuẩn WebGL.
- **Caching chuỗi giao diện HUD**: Không tạo mới chuỗi văn bản mỗi frame; chỉ cập nhật text của nhãn mặt trời/trăng, pin solar và zoom khi chỉ số thực sự thay đổi.

