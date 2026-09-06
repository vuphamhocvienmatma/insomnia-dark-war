# AI Guide & Coding Architecture (AGENTS.md)

> **QUY TẮC BẮT BUỘC VỀ TESTING:**
> 1. TRƯỚC KHI sửa bất kỳ file nào: chạy tất cả test case (`run_tests.bat`) và đảm bảo PASS toàn bộ.
> 2. SAU KHI sửa xong: chạy lại tất cả test case và đảm bảo vẫn PASS toàn bộ.
> 3. Không được phép PR/commit nếu có test nào FAIL.

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
- **Arrays & Decals:** Các mảng sinh rác (như array dấu chân _decals, mảng _spawned_zombies) phải có giới hạn (Max = 50-80 phần tử) và tự động 
emove_at(0).
- **Hạn chế _process:** Không dùng _process() để poll trạng thái (ví dụ check khoảng cách Camera). Dùng Timer, Signal, hoặc call_deferred.

## 4. UI VÀ THUẬT TOÁN
- **KHÔNG sử dụng position cho Control nodes (UI).** Bắt buộc dùng offset_left/right/top/bottom và hệ thống Anchor.
- **Hàm sign():** Trong Godot 4, sign() trả về int. Tuyệt đối sử dụng signf() cho các phép toán vật lý float để tránh giật lag (snapping).
- **Âm thanh:** Mọi âm thanh SFX phải đi qua udio_manager.gd (Hệ thống Pool array 10 kênh) để tránh bị clipping tiếng súng.

## 5. HỆ THỐNG ECO MODE
Mọi thuật toán tính toán góc bóng đổ (Directional Shadows) và tia nắng (God rays) phải đọc cờ GameState.eco_mode. Nếu bật, bỏ qua việc render để tiết kiệm pin tối đa cho nền tảng Web di động.
