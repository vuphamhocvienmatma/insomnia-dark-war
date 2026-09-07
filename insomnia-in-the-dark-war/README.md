# Insomnia in the Dark War

> Một tựa game sinh tồn chill-lofi 2.5D Diorama viết bằng **Godot 4.7** (GDScript), nơi bạn xây dựng căn cứ, chăm sóc vườn tược, nuôi mèo đồng hành, đọc thư từ phương xa và chống chọi từng đêm zombie — tất cả dưới ánh sáng ấm áp của một căn cabin gỗ giữa vùng hoang tàn sau chiến tranh.

---

## 1. Tổng Quan

**Insomnia in the Dark War** (*Mất ngủ giữa cuộc chiến bóng tối*) là tựa game sinh tồn thư giãn (cozy-survival) theo chu kỳ **Ngày / Đêm** mang phong cách diorama hoài niệm:

- **Ban ngày**: Thu thập phế liệu, trồng cây, tương tác với thư từ qua hòm thư, rèn vũ khí/trang bị, câu cá, chơi minigame Guitar, thư giãn bên lò sưởi lofi.
- **Ban đêm**: Zombie mắt đỏ tràn đến từ sa mạc. Hệ thống súng AK tự động tiêu tốn pin mặt trời (Solar) để bảo vệ. Nếu phòng tuyến vỡ, bạn sẽ bị **mất ngủ** (giảm tốc độ di chuyển) vào ngày hôm sau.

---

## 2. Công Nghệ Đồ Họa 100% Procedural 2.5D (Web-Optimized)

Dự án này sử dụng kiến trúc vẽ tay hoàn toàn bằng mã Code (`_draw()`), không sử dụng file ảnh Texture/Sprite2D hay Light2D của Godot, đảm bảo game chạy **60-120fps trên trình duyệt Web** (WebGL) với chi phí CPU cực thấp.

### Phase 1: Bầu Trời Kể Chuyện (Procedural Parallax)
- **5 Lớp Độ Sâu:** Bầu trời, Đám mây trôi, Núi non xa thẳm, Thành phố hoang tàn, và Sa mạc gần. Cảnh vật trượt theo bước chân người chơi (Parallax Scrolling).
- **Hệ thống Mood:** 6 tông màu chuyển sắc mượt mà (Bình minh, Nắng vàng, Hoàng hôn, Đêm cô liêu, Mất ngủ, Ác mộng).

### Phase 2: Mặt Đất Ghi Nhớ (Ground State Machine)
- **6 Vùng Đất:** Sàn gỗ Cabin, Hiên nhà, Đất nền sát nhà, Sa mạc gần, Lớp cắt địa chất đa tầng.
- **Thời Tiết Tương Tác (Cinematic Weather Readability):** Mưa và bão cát thay đổi động với 3 lớp Parallax CPUParticles2D. Mật độ thời tiết được đồng bộ với góc Zoom của Camera. Đặc biệt, hệ thống **Radial Clarity Mask** kết hợp Shader giữ cho khu vực Cabin luôn rõ nét (Mắt Bão) dù thời tiết xấu đến đâu.
- **Dấu Vết Động (Decals):** Dấu chân người/zombie in hằn trên mặt đất, vết xước do cào cấu, vỏ đạn rớt ra từ tháp pháo — tất cả sẽ nhạt dần.

### Phase 3: Ánh Sáng Lofi Additive (Procedural Lighting)
- **Beacon Effect:** Khi bão tố, đèn trong nhà tự động tăng độ sáng (energy) và chớp nháy (flicker) vẫy gọi người chơi.
- **Bóng Đổ Động:** Vật thể tự đổ bóng tròn (Contact Shadow) và bóng nghiêng xoay theo quỹ đạo mặt trời (Directional Shadow).

---

## 3. Hệ Thống Âm Thanh Adaptive (AudioDirector)
Kiến trúc âm thanh chuẩn AAA dành cho dự án lofi:
- **AudioDirector Autoload:** Quản lý toàn bộ vòng đời âm thanh với các Bus chuyên biệt (Master, BGM, Weather, SFX, UI). Đã loại bỏ hoàn toàn `.wav`, dùng định dạng `.ogg` (Vorbis) chuẩn Web.
- **BGM Crossfading & Ducking:** Chuyển đổi nhạc nền mượt mà theo Mood và thời tiết. Tiếng sấm sét tự động Ducking nhạc nền -3dB.
- **Positional Audio (Zombie Panning):** Khi thời tiết xấu, game chuyển sang chế độ sinh tồn âm thanh. Tiếng bước chân và tiếng rên của Zombie tự động Panning trái/phải thông qua `AudioStreamPlayer2D`, giúp người chơi phán đoán hướng tấn công bằng tai.

---

## 4. Cách Chơi & Cơ Chế (Features)
- Dùng A/D hoặc Trái/Phải để di chuyển.
- Tương tác với Cửa (vào trong nhà/ra ngoài), Hòm thư (nhận thư, kết bạn Affinity), Bếp lò (nấu ăn/Crafting UI).
- Thu thập tài nguyên và Crafting các vật phẩm sinh tồn, nâng cấp hàng rào, chế tạo mồi câu, chế tạo đồ chơi cho mèo.
- Chơi minigame đánh đàn Guitar để giảm căng thẳng (Lofi Guitar).
- Mở rương và thả tháp pháo tự động để chuẩn bị cho đêm.

## 5. Build & Export
Phát triển trực tiếp trên Godot 4.7. Để deploy Web, xuất qua chuẩn HTML5 (WebGL2), game siêu nhẹ vì dung lượng Textures = 0MB. Đảm bảo chạy mượt trên mọi nền tảng.
