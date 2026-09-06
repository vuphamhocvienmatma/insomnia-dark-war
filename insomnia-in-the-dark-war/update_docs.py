import os

readme_content = '''# Insomnia in the Dark War

> Một tựa game sinh tồn chill-lofi 2.5D Diorama viết bằng **Godot 4.7** (GDScript), nơi bạn xây dựng căn cứ, chăm sóc vườn tược, nuôi mèo đồng hành, đọc thư từ phương xa và chống chọi từng đêm zombie — tất cả dưới ánh sáng ấm áp của một căn cabin gỗ giữa vùng hoang tàn sau chiến tranh.

---

## 1. Tổng Quan

**Insomnia in the Dark War** (*Mất ngủ giữa cuộc chiến bóng tối*) là tựa game sinh tồn thư giãn (cozy-survival) theo chu kỳ **Ngày / Đêm** mang phong cách diorama hoài niệm:

- **Ban ngày**: Thu thập phế liệu, trồng cây, tương tác với thư từ, xây dựng phòng tuyến, thư giãn bên lò sưởi lofi.
- **Ban đêm**: Zombie mắt đỏ tràn đến từ sa mạc. Hệ thống súng AK tự động tiêu tốn pin mặt trời (Solar) để bảo vệ. Nếu phòng tuyến vỡ, bạn sẽ bị **mất ngủ** (giảm tốc độ di chuyển) vào ngày hôm sau.

---

## 2. Công Nghệ Đồ Họa 100% Procedural 2.5D (Web-Optimized)

Dự án này sử dụng kiến trúc vẽ tay hoàn toàn bằng mã Code (_draw()), không sử dụng file ảnh Texture/Sprite2D hay Light2D của Godot, đảm bảo game chạy **60-120fps trên trình duyệt Web** (WebGL) với chi phí CPU gần như bằng 0%.

### Phase 1: Bầu Trời Kể Chuyện (Procedural Parallax)
- **5 Lớp Độ Sâu:** Bầu trời, Đám mây trôi, Núi non xa thẳm, Thành phố hoang tàn, và Sa mạc gần. Cảnh vật trượt theo bước chân người chơi (Parallax Scrolling).
- **Hệ thống Mood:** 6 tông màu chuyển sắc mượt mà (Bình minh, Nắng vàng, Hoàng hôn, Đêm cô liêu, Mất ngủ, Ác mộng).

### Phase 2: Mặt Đất Ghi Nhớ (Ground State Machine)
- **6 Vùng Đất:** Sàn gỗ Cabin, Hiên nhà, Đất nện sát nhà, Sa mạc gần, Lớp cắt địa chất đa tầng (Top soil, Sand, Bedrock).
- **Thời Tiết Tương Tác:** Đất đổi màu khi Mưa (Wet), Bão tuyết (Snowy), Bão cát (Sandy), hay Trái Đất cháy xém (Scorched).
- **Dấu Vết Động (Decals):** Dấu chân người/zombie in hằn trên mặt đất, vết xước do cào cấu, vỏ đạn rớt ra từ tháp pháo — tất cả sẽ nhạt dần (Fade out) theo thời gian.

### Phase 3: Ánh Sáng Lofi Additive (Procedural Lighting)
- **Hòa Trộn Ánh Sáng:** Thay vì Godot Light2D, game sử dụng CanvasItemMaterial với BLEND_MODE_ADD tạo ra ánh sáng mượt như Linear Dodge.
- **Bóng Đổ Động:** Vật thể tự đổ bóng tròn (Contact Shadow) và bóng nghiêng xoay theo quỹ đạo mặt trời (Directional Shadow).
- **God Rays & Dust Motes:** Vạt nắng xiên góc mang theo những hạt bụi lơ lửng, tạo ra khoảnh khắc điện ảnh ấm cúng.

---

## 3. Hệ Thống Âm Thanh (Audio Pooling)
Âm thanh (.wav) được tạo hoàn toàn bằng các kịch bản sinh âm, sau đó import vào engine bằng lệnh --headless --editor. Hệ thống **AudioPool** 10 kênh đảm bảo tiếng súng, tiếng bước chân không bao giờ bị cắt cụt hay vỡ tiếng.

---

## 4. Cách Chơi
- Dùng A/D hoặc Trái/Phải để di chuyển.
- Tương tác với Cửa (vào trong nhà/ra ngoài), Hòm thư (nhận Scrap/Seed), Bếp lò (nấu ăn).
- Mở rương và thả tháp pháo tự động để chuẩn bị cho đêm.

## 5. Build & Export
Phát triển trực tiếp trên Godot 4.7. Để deploy Web, xuất qua chuẩn HTML5 (WebGL2), game siêu nhẹ vì dung lượng Textures = 0MB.
'''

ai_guide_content = '''# AI Guide & Coding Architecture (AGENTS.md)

Đây là tài liệu hướng dẫn bắt buộc cho mọi AI/LLM tham gia viết code cho **Insomnia in the Dark War**.

## 1. QUY TẮC TỐI THƯỢNG (THE ZERO-SPRITE RULE)
- **TUYỆT ĐỐI KHÔNG sử dụng Sprite2D, TextureRect, hay bất kỳ file hình ảnh nào (.png, .jpg).**
- Mọi hình ảnh trong game (từ đám mây, nhân vật, cây cỏ, cho tới ánh sáng và UI) đều phải được vẽ procedural thông qua hàm _draw() của Godot.
- **KHÔNG SỬ DỤNG Godot Light2D hay PointLight2D**. Mọi ánh sáng phải được vẽ bằng thuật toán BLEND_MODE_ADD thông qua CanvasItemMaterial.

## 2. KIẾN TRÚC RENDER 2.5D DIORAMA
- Game tuân theo góc nhìn Diorama (nhà búp bê mặt cắt).
- Trục X là không gian di chuyển. Trục Y là độ cao/độ sâu. Trục Z (Z-Index) quyết định lớp layer.
- Hệ thống chia làm nhiều file Art tĩnh để dễ quản lý:
  - rt_skyline.gd: Vẽ bầu trời, mặt trời, trăng và bối cảnh thành phố xa. Tự động nội suy Parallax theo vị trí camera.
  - rt_ground_props.gd: Vẽ 6 vùng mặt đất, cắt lớp địa tầng, bụi cỏ, sỏi, và quản lý Decals (dấu chân, vỏ đạn). Chứa State Machine quản lý thời tiết.
  - rt_lighting.gd: Layer Additive trên cùng (Z-Index=50). Vẽ Lò sưởi, God Rays, Fairy Lights, và Dust Motes.
  - rt_weather.gd: Hệ thống Shader Post-Processing và GPU Particles (mưa, bão cát).
  - Khối tĩnh Cabin: rt_cabin_front.gd, rt_cabin_props.gd.

## 3. HIỆU NĂNG VÀ BỘ NHỚ (MEMORY LEAKS)
- Godot 4 Tween sẽ sinh rác nếu không kill. Luôn lưu reference vào biến cục bộ của class và kiểm tra: if tw != null and tw.is_valid(): tw.kill() trước khi tạo mới.
- **Arrays & Decals:** Các mảng sinh rác (như array dấu chân _decals, mảng _spawned_zombies) phải có giới hạn (Max = 50-80 phần tử) và tự động emove_at(0).
- **Hạn chế _process:** Không dùng _process() để poll trạng thái (ví dụ check khoảng cách Camera). Dùng Timer, Signal, hoặc call_deferred.

## 4. UI VÀ THUẬT TOÁN
- **KHÔNG sử dụng position cho Control nodes (UI).** Bắt buộc dùng offset_left/right/top/bottom và hệ thống Anchor.
- **Hàm sign():** Trong Godot 4, sign() trả về int. Tuyệt đối sử dụng signf() cho các phép toán vật lý float để tránh giật lag (snapping).
- **Âm thanh:** Mọi âm thanh SFX phải đi qua udio_manager.gd (Hệ thống Pool array 10 kênh) để tránh bị clipping tiếng súng.

## 5. HỆ THỐNG ECO MODE
Mọi thuật toán tính toán góc bóng đổ (Directional Shadows) và tia nắng (God rays) phải đọc cờ GameState.eco_mode. Nếu bật, bỏ qua việc render để tiết kiệm pin tối đa cho nền tảng Web di động.
'''

with open('README.md', 'w', encoding='utf-8') as f:
    f.write(readme_content)

with open('AI_GUIDE.md', 'w', encoding='utf-8') as f:
    f.write(ai_guide_content)

print("Updated README.md and AI_GUIDE.md")
