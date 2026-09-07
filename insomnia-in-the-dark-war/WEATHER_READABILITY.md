# WEATHER READABILITY & CINEMATIC CONTRAST SYSTEM

## Tri?t lý thi?t k? (Design Philosophy)
H? th?ng th?i ti?t không du?c che khu?t "M?t Bão" (Cabin). Th?i ti?t dóng vai trò nhu m?t công c? di?n ?nh d? tôn lên c?m giác an toàn, ?m áp bên trong can nhà gi?a b?i c?nh sinh t?n.

## Các tính nang c?t lõi (Core Features)

### 1. Radial Clarity Mask (Vùng Trong Su?t Hu?ng Tâm)
- Các h?t mua, cát và hi?u ?ng post-processing (nhu tint, desaturation, aberration) s? b? làm m? và trong su?t d?n khi ti?n l?i g?n v? trí c?a cabin (`Vector2(0, -50)`).
- S? d?ng hàm `smoothstep` d? tính toán d? m? (alpha) d?a trên bán kính `clarity_radius`. Ði?u này d?m b?o cabin và các di?m nh?n nhu c?a, tháp pháo luôn rõ ràng (Readability 100%).
- Ðu?c áp d?ng d?ng th?i trong `_draw()` c?a h?t (particles) và trong Fragment Shader (`weather_post_process.gdshader`) b?ng bi?n `cabin_screen_pos`.

### 2. Tuong tác v?i M?t d? Zoom (Zoom Density Binding)
- M?t d? h?t th?i ti?t (s? lu?ng drop mua, h?t cát) và d? m? c?a l?p suong mù xa (haze) t? l? thu?n v?i d? zoom c?a camera.
- Khi ngu?i choi dùng ?ng nhòm phóng to (Zoom In, `zoom = 0.5x`), h? s? m?t d? gi?m m?nh. Khi thu nh? (Zoom Out, `zoom = 1.0x`), bão t? hi?n ra rõ r?t ? rìa màn hình.

### 3. Hi?u ?ng Ng?n H?i Ðang (Beacon Effect)
- Ðèn cabin t? d?ng tang `energy` (sáng r?c hon lên 1.3x - 1.5x) và thêm hi?u ?ng nh?p nháy nh? (flicker) b?ng sóng sine khi th?i ti?t x?u. T?o s? tuong ph?n rõ r?t v?i màn dêm l?nh l?o/bão cát bên ngoài.

### 4. Chi?u Sâu Ða L?p (Parallax Layers)
- Mua và cát du?c chia làm 3 l?p (Layer `far`, `mid`, `near`) trong cùng m?t vòng l?p `_draw()`.
- L?p g?n di chuy?n c?c nhanh, kích thu?c l?n và rõ nét. L?p xa di chuy?n ch?m, m? và s? lu?ng nhi?u. 
- Clarity Mask uu tiên làm m? l?p `mid` và `near` (nh?ng h?t ch?n tru?c camera và cabin), trong khi l?p `far` v?n duy trì d? t?o không khí.

### 5. Ð?c trung Th?i Ti?t Mua & Bão Cát
- **Mua (Heavy Rain):** Góc roi nghiêng nh? 15 d?, kèm theo ho?t ?nh gi?t nu?c (splashes) d?p xu?ng d?t và nu?c d?ng r? xu?ng trên ?ng kính máy quay (window drops). Kèm theo ch?p gi?t và ti?ng s?m (`trigger_thunder`).
- **Bão Cát (Sandstorm):** H?t bay ngang v?i t?c d? c?c cao. Gi?m bão hòa màu c?a c?nh (Desaturate 25-30%) và thêm l?p tint màu nâu ?m m?. T?m nhìn xa b? che b?i m?t l?p Haze, nhung vùng tâm quanh cabin v?n trong v?t.

### 6. Âm thanh Ð?nh hu?ng (Positional Panning Audio)
- M?i âm thanh c?a Zombie (ti?ng bu?c chân, ti?ng g?m g?) d?u du?c phát ra t? h? th?ng `AudioStreamPlayer2D` pool n?m trong Autoload `AudioDirector`.
- Panning trái/ph?i và suy hao âm lu?ng (Distance Attenuation) du?c t? d?ng tính toán b?i Godot Audio Engine.
- Game s? KHÔNG phát âm thanh d?nh hu?ng (t?t positional panning, fallback v? stereo thu?ng) n?u th?i ti?t d?p. Ngu?i choi ch? nghe th?y hu?ng c?a Zombie rõ ràng trong bão (khi t?m nhìn b? gi?m sút).

*Note: All VFX logic resides in `art_weather.gd` and `weather_post_process.gdshader`.*
