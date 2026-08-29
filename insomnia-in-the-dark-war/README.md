# Insomnia in the Dark War

> Một tựa game sinh tồn chill-lofi 2D viết bằng **Godot 4.7** (GDScript), nơi bạn xây dựng
> pháo đài, chăm sóc vườn tược, nuôi mèo đồng hành và chống chọi từng đêm zombie — tất cả
> dưới ánh sáng ấm áp của một căn cabin giữa vùng hoang tàn.

---

## 1. Tổng quan

**Insomnia in the Dark War** (tạm dịch: *Mất ngủ giữa cuộc chiến bóng tối*) là game sinh tồn
phiếm (cozy-survival) theo chu kỳ **Ngày / Đêm**:

- **Ban ngày**: thu thập phế liệu (scrap), hạt giống (seed), nước (water); trồng và tưới cây;
  xây dựng hàng rào quanh pháo đài; nhặt di vật (relic) để mở khóa buff; nấu súp ở bếp lò.
- **Ban đêm**: zombie tràn đến từ rìa bản đồ, tìm cách phá hàng rào. Nếu có "góc chết"
  (socket chưa bịt kín), pháo đài bị xuyên thủng → bạn sẽ **mất ngủ** (đi chậm) ngày hôm sau.
- **Năng lượng mặt trời (Solar)**: chỉ nạp vào ban ngày, dùng để bắn Turret ban đêm.

Mục tiêu: sống sót càng nhiều chu kỳ ngày-đêm càng tốt, tối ưu hóa phòng thủ và thu thập.

---

## 2. Tính năng chính

| Hệ thống | Mô tả |
|----------|-------|
| **Quản lý tài nguyên** | Phế liệu, hạt giống, nước với signal `scrap_changed` / `seeds_changed` / `water_changed` cập nhật HUD realtime. |
| **Nhật ký nhiệm vụ (Journal)** | 3 nhiệm vụ ngẫu nhiên mỗi ngày (nhặt hạt, xây rào, bắn zombie), theo dõi tiến độ tự động. |
| **Chu kỳ ngày/đêm (Time Manager)** | Chuyển cảnh ánh sáng (`CanvasModulate`), nạp Solar ban ngày, reset Solar khi sang ngày mới. |
| **Hàng rào & tính toàn vẹn (Integrity Tracker)** | Quét 24 socket quanh pháo đài; phát hiện "góc chết" → breach → mất ngủ. |
| **Xây dựng (Building Manager)** | Ghost preview bám socket, chỉ xây khi đủ gần player và đủ phế liệu. |
| **Mèo đồng hành (Companion Cat)** | Tự động đi nhặt scrap/seed/water đem về, track journal khi nhặt seed, được vuốt ve. |
| **Turret tự động** | Bắn zombie trong vùng vào ban đêm, tiêu tốn Solar, nhận buff damage. |
| **Cây trồng (Plant Pot)** | Trồng → tưới → nở hoa → thu hoạch (tặng phế liệu + bonus). |
| **Di vật (Relic)** | 3 loại buff: turret x1.5, thu hoạch +2, solar x1.5. |
| **Lưu / Tải (Save Manager)** | Lưu tài nguyên, tường đã xây, tiến độ nhiệm vụ, relic và breach vào `user://insomnia_save.json`. |
| **Âm nhạc Lofi (Audio Manager)** | Nhạc ngày + ambient đêm chuyển đổi theo phase. |

---

## 3. Cấu trúc dự án

```
insomnia-in-the-dark-war/
├── project.godot              # Cấu hình project, input map, autoloads
├── docs/
│   ├── AGENTS.md             # Quy tắc BẮT BUỘC cho agent/LLM viết code
│   └── godot4_cheatsheet.md  # Cheatsheet cú pháp Godot 4 chuẩn
├── scenes/
│   ├── main_level.tscn       # Scene chính (world + cabin + hệ thống)
│   ├── player.tscn           # Nhân vật người chơi
│   ├── companion_cat.tscn    # Mèo đồng hành
│   ├── zombie.tscn           # Kẻ địch
│   ├── scrap_item.tscn       # Phế liệu / hạt / nước rải rác
│   ├── relic_item.tscn       # Di vật buff
│   ├── plant_pot.tscn        # Chậu cây
│   ├── wall_piece.tscn       # Mảnh tường xây được
│   ├── auto_turret.tscn      # Tháp canh
│   ├── stove.tscn            # Bếp lò nấu súp
│   ├── hud.tscn              # Giao diện (phế liệu, hạt, nước, nhiệm vụ)
│   └── test_level.tscn       # Scene test
└── scripts/                  # Toàn bộ logic GDScript (xem mục 4)
```

### 3.1 Autoloads (Singleton)
Được khai báo trong `project.godot` → luôn tồn tại toàn cục:

| Autoload | Script | Trách nhiệm |
|----------|--------|-------------|
| `GameState` | `game_state.gd` | Tài nguyên, trạng thái mệt, relic, buff multiplier, signal. |
| `JournalManager` | `journal_manager.gd` | `daily_tasks: Array[Dictionary]`, `track_progress()`, sinh nhiệm vụ mới mỗi ngày. |
| `SaveManager` | `save_manager.gd` | `save_game()` / `load_game()` JSON. |
| `UnlockManager` | `unlock_manager.gd` | Lắng nghe `relic_collected`, log buff đã apply. |

### 3.2 Input Map (`project.godot`)
- `interact` → phím **E** (nhặt đồ, trồng/tưới thu hoạch, nấu súp, vuốt mèo, lấy relic).
- `click_build` → **chuột trái** (xây tường vào socket gần chuột).
- Di chuyển: `ui_up/down/left/right` (mũi tên / WASD tuỳ cấu hình hệ thống).

---

## 4. Chi tiết từng script

| Script | Vai trò chính | Điểm cần lưu ý |
|--------|---------------|----------------|
| `game_state.gd` | Kho tài nguyên + buff. | `Array[String]` relics; `add_*/spend_*` phát signal. |
| `journal_manager.gd` | Nhiệm vụ hàng ngày. | `daily_tasks: Array[Dictionary]` (static typed). |
| `time_manager.gd` | Chu kỳ ngày/đêm + Solar. | Reset `current_solar_energy = 0.0` khi `transition_to_day()`; null-check `GameState` trong `_process`. |
| `integrity_tracker.gd` | Quét socket lỏng lẻo. | Set/clear `GameState.breach_last_night`, gọi `rest_well()` khi kín. |
| `save_manager.gd` | Lưu/tải JSON. | Convert `Array` untyped → `Array[Dictionary]` an toàn khi load tasks. |
| `level_setup.gd` | Sinh world (socket ring, turret, scrap, relic, zombie wave). | Relic spawn randomize `randf_range(850, 950)`. |
| `building_manager.gd` | Xây tường. | Check khoảng cách player < 200, đủ scrap, ghost preview. |
| `plant_pot.gd` | Chậu cây. | `PotState` EMPTY/PLANTED/BLOOMED; interact theo khoảng cách < 60. |
| `companion_cat.gd` | Mèo đồng hành. | `_deliver_item()` track journal + null-safety; `_find_nearest_scrap()` có distance check. |
| `zombie_ai.gd` | AI zombie. | `loot_cooldown` 10s; flash đỏ + camera shake khi attack. |
| `auto_turret.gd` | Turret. | Reset target khi zombie chết; `turret_damage_multiplier` null-safe. |
| `scrap_item.gd` / `relic_item.gd` | Vật phẩm. | Null-check `GameState`/`JournalManager` trước khi thao tác. |
| `player.gd` | Người chơi. | Tốc độ ×0.85 khi `GameState.is_tired`. |
| `interactive_stove.gd` | Bếp lò. | Hạt giống/nước → nấu súp (particles + timer). |
| `wall_piece.gd` | Mảnh tường. | `StaticBody2D`, `take_damage()`, `add_to_group("defensive_wall")`. |
| `build_socket_2d.gd` | Socket xây dựng. | `class_name BuildSocket2D`, `can_accept()`, `get_snap_pose()`. |
| `camera_lofi.gd` / `warm_fireplace_light.gd` / `lofi_audio_manager.gd` | Camera / ánh sáng / nhạc. | Hỗ trợ atmosphere chill. |

---

## 5. Cách chơi

1. **Di chuyển** bằng phím mũi tên đến gần vật phẩm, nhấn **E** để nhặt.
2. **Trồng cây**: đứng gần chậu (E) → trồng hạt → đứng gần lại (E) → tưới nước → chờ nở → (E) thu hoạch.
3. **Xây rào**: di chuột đến socket gần pháo đài, **chuột trái** để xây (tốn 1 phế liệu, phải đủ gần).
4. **Mèo**: tự động nhặt đồ mang về; đứng cạnh và nhấn **E** để vuốt ve (tăng hạnh phúc).
5. **Relic**: đi lượm 3 di vật rải rác, nhấn **E** để kích hoạt buff vĩnh viễn.
6. **Ban đêm**: Turret tự bắn (tốn Solar). Hãy chắc chắn mọi socket đều có tường trước khi đêm xuống,
   nếu không bạn sẽ **mất ngủ** và đi chậm ngày hôm sau.
7. **Bếp lò**: đứng gần và nhấn **E** để nấu súp thư giãn.

---

## 6. Cách chạy dự án

1. Mở **Godot 4.7** (hoặc mới hơn thuộc 4.x).
2. `Project Manager → Import → chọn file `insomnia-in-the-dark-war/project.godot`.
3. Nhấn **Run** (F5) hoặc chạy trực tiếp `scenes/main_level.tscn`.
4. Game tự load save cũ (nếu có) khi `_ready()` của `LevelSetup` gọi `SaveManager.load_game()`.

> Lưu ý: Tất cả code tuân thủ nghiêm ngặt `docs/AGENTS.md` (Godot 4.x, static typing,
> không dependency ngoài, in test-line pattern khi sửa lỗi). Xem `docs/godot4_cheatsheet.md`
> để tránh các cú pháp lỗi thời Godot 3.

---

## 7. Quy tắc code (tóm tắt từ docs/AGENTS.md)

- ✅ 100% tương thích **Godot 4.x**, cấm mọi cú pháp Godot 3 (`instance()`, `export(int)`, `move_and_slide(v)`...).
- ✅ **Static typing** bắt buộc (`var x: float = 1.0`, `func f(p: int) -> void:`).
- ✅ Không thêm addon/thư viện bên thứ ba.
- ✅ Khi sửa/xuất code: in ra **toàn bộ** file, không cắt ngắn.
- ✅ Kết thúc bằng dòng test: `chạy scene X, kỳ vọng thấy Y`.

---

## 8. Trạng thái phát triển

- [x] Core loop ngày/đêm
- [x] Thu thập & tài nguyên
- [x] Xây dựng hàng rào + integrity tracking
- [x] Mèo đồng hành
- [x] Turret + năng lượng mặt trời
- [x] Cây trồng & bếp lò
- [x] Di vật & buff
- [x] Save/Load
- [x] Âm nhạc Lofi & atmosphere

*Dự án được tối ưu cho trải nghiệm "chill nhưng vẫn cần tư duy phòng thủ" — kiểu vừa nhâm nhi
cốc trà vừa canh hàng rào trước bầy zombie.*
