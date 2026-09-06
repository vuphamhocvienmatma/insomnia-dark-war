# TEST PLAN — Insomnia in the Dark War
**Phiên bản:** 1.0 | **Ngày:** 2026-09-06
**Loại:** Black-box E2E + Unit Tests (GDScript)
**Công cụ:** Godot 4 built-in test runner + headless mode (`--headless --quit-after`)

---

## 0. NGUYÊN TẮC CHẠY TEST

> **Mọi AI agent hoặc lập trình viên trước khi sửa bất kỳ file nào PHẢI:**
> 1. Chạy `run_tests.bat` — tất cả phải PASS
> 2. Thực hiện thay đổi
> 3. Chạy lại `run_tests.bat` — tất cả vẫn phải PASS
> 4. Chỉ commit khi bước 3 xanh hoàn toàn

---

## 1. KIẾN TRÚC TEST

```
tests/
├── run_tests.gd           # Entry point headless runner
├── unit/
│   ├── test_game_state.gd
│   ├── test_journal_manager.gd
│   ├── test_save_manager.gd
│   ├── test_time_manager.gd
│   ├── test_mailbox_manager.gd
│   └── test_crafting_ui.gd
├── integration/
│   ├── test_player_movement.gd
│   ├── test_zombie_ai.gd
│   ├── test_plant_pot.gd
│   ├── test_cabin_door.gd
│   ├── test_build_and_defend.gd
│   └── test_night_cycle.gd
├── e2e/
│   ├── test_full_day_cycle.gd
│   ├── test_survival_loop.gd
│   ├── test_save_load.gd
│   ├── test_crafting_flow.gd
│   ├── test_plant_harvest.gd
│   ├── test_merchant_shop.gd
│   └── test_font_integrity.gd
└── helpers/
    ├── test_assert.gd
    └── scene_spawner.gd
```

### Cách chạy test

```bat
rem Windows
run_tests.bat
```

`run_tests.bat` nội dung:
```bat
@echo off
Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 120 res://tests/run_tests.gd
if %errorlevel% == 0 (echo [ALL PASS]) else (echo [FAILED] && exit /b 1)
```

---

## 2. UNIT TESTS

### 2.1 test_game_state.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| GS-01 | add_scrap cộng đúng | add_scrap(5) khi scrap=0 | scrap_count = 5 |
| GS-02 | add_scrap phát signal | add_scrap(3) | signal scrap_changed(3) emit |
| GS-03 | spend_scrap đủ tiền | scrap=10, spend_scrap(4) | return true, scrap=6 |
| GS-04 | spend_scrap không đủ | scrap=2, spend_scrap(5) | return false, scrap=2 |
| GS-05 | add_seeds / spend_seeds | như GS-01..04 | tương tự với seeds_count |
| GS-06 | add_water / spend_water | như GS-01..04 | tương tự với water_count |
| GS-07 | start_new_day không mệt | breach=false, meal=false | is_tired = false |
| GS-08 | start_new_day mệt khi breach | breach=true, meal=false | is_tired = true |
| GS-09 | start_new_day không mệt nhờ bữa ăn | breach=true, meal=true | is_tired = false |
| GS-10 | start_new_day reset flags | bất kỳ | breach_last_night=false, meal_buff=false |
| GS-11 | add_relic buff_turret | add_relic("buff_turret") | turret_damage_multiplier = 1.5 |
| GS-12 | add_relic buff_plant | add_relic("buff_plant") | plant_harvest_bonus = 2 |
| GS-13 | add_relic buff_solar | add_relic("buff_solar") | solar_charge_multiplier = 1.5 |
| GS-14 | add_relic trùng lặp bị từ chối | thêm relic 2 lần | relics_found.size() = 1 |
| GS-15 | golden_fishing_rod thưởng sáng | relic="golden_fishing_rod", start_new_day | +1 scrap +1 water |
| GS-16 | set_eco_mode phát signal | set_eco_mode(true) | signal eco_mode_changed(true) |
| GS-17 | stats days_survived tăng | start_new_day() | stats["days_survived"] += 1 |
| GS-18 | stats dict không null khi init | khởi tạo | stats.has("zombies_killed") = true |
| GS-19 | rest_well xóa mệt | is_tired=true, rest_well() | is_tired=false, signal emit |
| GS-20 | track_stat tăng đúng key | track_stat("zombies_killed") | stats["zombies_killed"] += 1 |

### 2.2 test_journal_manager.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| JM-01 | generate_daily_tasks tạo 3 task | generate_daily_tasks() | daily_tasks.size() = 3 |
| JM-02 | Mỗi task có đủ key | sau generate | desc, type, target, progress, completed |
| JM-03 | tasks_updated signal emit | generate() | signal tasks_updated |
| JM-04 | track_progress tăng progress | gọi 3 lần với target=5 | progress = 3 |
| JM-05 | task completed khi đủ target | track tới target | completed = true |
| JM-06 | task_completed signal emit | hoàn thành | signal task_completed(desc) |
| JM-07 | Hoàn thành thưởng +5 scrap | hoàn thành | GameState.scrap += 5 |
| JM-08 | Hoàn thành thưởng +2 seeds | hoàn thành | GameState.seeds += 2 |
| JM-09 | progress không vượt target | track 10 lần, target=3 | progress = 3 |
| JM-10 | generate reset mỗi ngày mới | _on_phase_changed(false) | daily_tasks mới, progress=0 |

### 2.3 test_save_manager.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| SM-01 | save_game ghi file | save_game() | file tồn tại tại user://insomnia_save.json |
| SM-02 | save_game JSON hợp lệ | sau save | JSON.parse(content) không error |
| SM-03 | load_game đọc đúng scrap | save scrap=7, load | scrap_count = 7 |
| SM-04 | load_game đọc đúng seeds | save seeds=3, load | seeds_count = 3 |
| SM-05 | load_game đọc đúng water | save water=5, load | water_count = 5 |
| SM-06 | load_game đọc đúng relics | save relics=["buff_turret"], load | relics_found = ["buff_turret"] |
| SM-07 | load_game đọc eco_mode | save eco=true, load | eco_mode = true |
| SM-08 | load_game trả false khi không có file | xóa file, load | return false |
| SM-09 | unlock/has_unlocked đúng | unlock("x"), has_unlocked("x") | true |
| SM-10 | has_unlocked false khi chưa unlock | has_unlocked("unknown") | false |
| SM-11 | unlocked_ids persist qua save/load | unlock("bp_radio"), save, load | "bp_radio" trong ids |
| SM-12 | sender_affinity persist | affinity["Bác Sáu"]=50, save, load | = 50 |
| SM-13 | daily_tasks persist | tasks có progress, save, load | progress giữ nguyên |

### 2.4 test_time_manager.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| TM-01 | is_night = false ban đầu | init | is_night = false |
| TM-02 | phase_changed(true) khi đủ thời gian | time_elapsed >= day_duration | signal phase_changed(true) |
| TM-03 | phase_changed(false) sau đêm | sau night_duration | signal phase_changed(false) |
| TM-04 | sunset_warning 30s trước đêm | 30s trước đêm | signal sunset_warning |
| TM-05 | solar_changed ban ngày | ban ngày | signal solar_changed(0..100) |
| TM-06 | solar không tăng ban đêm | is_night=true | current_solar_energy không tăng |
| TM-07 | sun_angle thay đổi ban ngày | time trôi | sun_angle.x thay đổi |
| TM-08 | cloud_cover trong [0,1] | bất kỳ thời điểm | 0.0 <= cloud_cover <= 1.0 |
| TM-09 | mood_changed emit khi mood đổi | mood_name thay đổi | signal mood_changed(name) |

### 2.5 test_mailbox_manager.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| MM-01 | mail_received emit | nhận thư | signal mail_received(dict) |
| MM-02 | Thư có title, content, sender | letter_dict | has keys: title, content, sender |
| MM-03 | Đọc thư tăng affinity | đọc thư từ "Bác Sáu" | sender_affinity["Bác Sáu"] tăng |
| MM-04 | gift_claimed không nhận lại | nhận quà 2 lần | lần 2: không thêm relic |
| MM-05 | golden_fishing_rod khi affinity >= 60 | affinity = 60 | relics_found.has("golden_fishing_rod") |
| MM-06 | mail_history lưu thư | gửi N thư | mail_history.size() = N |
| MM-07 | MailboxManager không null | init | MailboxManager != null |

### 2.6 test_crafting_ui.gd

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| CR-01 | can_afford meal đúng | seeds=2, water=1 | true |
| CR-02 | can_afford meal thiếu nguyên liệu | seeds=1 | false |
| CR-03 | can_afford battery đúng | scrap=3 | true |
| CR-04 | Craft meal trừ đúng nguyên liệu | seeds=2, water=1 | seeds=0, water=0 |
| CR-05 | Craft meal set meal_buff | craft "meal" | GameState.meal_buff = true |
| CR-06 | Craft battery tăng solar multiplier | craft "battery" | solar_charge_multiplier tăng |
| CR-07 | Craft cat_toy set cat_toy_done | craft "cat_toy" | cat_toy_done = true |
| CR-08 | Panel ẩn mặc định | init | panel.visible = false |
| CR-09 | C key toggle panel | input toggle_crafting | panel.visible flip |
| CR-10 | 3 recipe đúng ID | RECIPES | ["meal", "battery", "cat_toy"] |

---

## 3. INTEGRATION TESTS

### 3.1 test_player_movement.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| PM-01 | Nhấn ui_right | position.x tăng sau 0.5s |
| PM-02 | Nhấn ui_left | position.x giảm sau 0.5s |
| PM-03 | Speed bình thường | velocity.x = 150 |
| PM-04 | Speed chậm khi mệt | velocity.x = 127.5 (85%) |
| PM-05 | Art flip đi trái | art.scale.x = -1.0 |
| PM-06 | Art flip đi phải | art.scale.x = 1.0 |
| PM-07 | Ladder prompt hiện khi gần x=150 | ladder_prompt.visible = true |
| PM-08 | Ladder prompt ẩn khi xa | ladder_prompt.visible = false |
| PM-09 | Footprint decal spawn | di chuyển 0.35s | add_decal("footprint") gọi |
| PM-10 | Footstep pitch trong cabin | x < 180 | play_sfx pitch = 0.8 |
| PM-11 | Footstep pitch ngoài sa mạc | x > 200 | play_sfx pitch = 1.4 |

### 3.2 test_zombie_ai.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| ZA-01 | Zombie spawn đúng vị trí | global_position.x = spawn_position.x |
| ZA-02 | Zombie tiến về safe_zone | velocity.x hướng về safe_zone |
| ZA-03 | Zombie deflect trong safe_zone | velocity.x dương (đẩy ra) |
| ZA-04 | take_damage giảm health | current_health = 70 sau take_damage(30) |
| ZA-05 | Chết khi hp <= 0 | is_dead = true, queue_free gọi |
| ZA-06 | track_progress khi chết | JournalManager.track_progress("zombie_kill") |
| ZA-07 | Thief ăn cắp scrap | GameState.scrap giảm |
| ZA-08 | Thief trả scrap khi chết | GameState.add_scrap(stolen) |
| ZA-09 | set_physics_process false khi chết | is_dead=true → physics tắt |
| ZA-10 | scrap_jackpot thưởng thêm | mutation="scrap_jackpot", chết → +1 scrap thêm |
| ZA-11 | Toast tiếng Việt đúng khi thief ăn cắp | toast chứa "Thief" không mojibake |
| ZA-12 | Toast tiếng Việt đúng khi hạ gục | toast chứa "hạ gục" không mojibake |

### 3.3 test_plant_pot.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| PP-01 | plant_seed thành công | true, state=PLANTED, seeds giảm |
| PP-02 | plant_seed thất bại không đủ hạt | false, state=EMPTY |
| PP-03 | plant_seed thất bại đã có cây | false |
| PP-04 | Cây lớn đủ growth_time | state = BLOOMED |
| PP-05 | harvest thành công | seeds tăng, state=EMPTY |
| PP-06 | God Ray bonus 2x | x trong [-60,60], ngày, shadow>0.5 → speed*2 |
| PP-07 | miracle_watering_can 1.5x | relic → speed*1.5 |
| PP-08 | acid_rain 2x | weather="acid_rain" → speed*2 |
| PP-09 | plant_harvest_bonus | bonus=2 → +2 seeds khi harvest |
| PP-10 | _harvest_label không tạo mới | harvest 3 lần → label count không tăng |

### 3.4 test_cabin_door.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| CD-01 | Door đóng mặc định | is_open = false |
| CD-02 | toggle_door mở | is_open = true |
| CD-03 | toggle_door đóng | is_open = false |
| CD-04 | door_state_changed signal | signal emit với is_open |
| CD-05 | reinforce tăng level | reinforce_level += 1 |
| CD-06 | reinforce trừ scrap | scrap giảm |
| CD-07 | take_damage giảm hp | hp giảm đúng lượng |
| CD-08 | Toast cảnh báo khi door phá | hud.show_toast gọi |
| CD-09 | Collision tắt khi mở | collision_shape disabled |
| CD-10 | Prompt hiện khi player gần | prompt.visible = true |

### 3.5 test_build_and_defend.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| BD-01 | Build wall tại socket | wall spawn tại socket.position |
| BD-02 | Build wall trừ scrap | scrap giảm |
| BD-03 | Socket is_occupied sau build | is_occupied = true |
| BD-04 | Không build thiếu scrap | wall không spawn |
| BD-05 | Wall nhận damage | current_health giảm |
| BD-06 | Wall destroy khi hp=0 | queue_free gọi |
| BD-07 | Track walls_built | stats["walls_built"] += 1 |
| BD-08 | IntegrityTracker phát hiện breach | signal fort_breached |
| BD-09 | IntegrityTracker phát hiện secure | signal fort_secured |
| BD-10 | breach_last_night = true khi breach | GameState.breach_last_night = true |

### 3.6 test_night_cycle.gd

| ID | Test Case | Assert |
|----|-----------|--------|
| NC-01 | Zombie spawn khi đêm | _spawned_zombies.size() > 0 |
| NC-02 | Zombie clear khi sáng | tất cả zombie queue_free |
| NC-03 | _spawned_zombies = 0 khi sáng | size = 0 |
| NC-04 | day_count tăng mỗi sáng | day_count += 1 |
| NC-05 | Weather roll mỗi ngày | current_weather là string hợp lệ |
| NC-06 | Night mutation roll | mutation trong danh sách hợp lệ |
| NC-07 | Save gọi khi sáng | SaveManager.save_game() gọi |
| NC-08 | JournalManager generate khi sáng | daily_tasks mới |
| NC-09 | GameState.start_new_day gọi | stats["days_survived"] += 1 |
| NC-10 | scrap_jackpot tăng drop | zombie chết → +1 scrap thêm |
| NC-11 | Solar eclipse mutation áp dụng | current_weather đổi sang liên quan |

---

## 4. E2E TESTS (BLACK BOX)

### 4.1 test_full_day_cycle.gd

Setup: `day_duration=5s, night_duration=3s`

| Step | Action | Assert |
|------|--------|--------|
| 1 | Game khởi động | HUD visible, không có SCRIPT ERROR trong log |
| 2 | Đợi day (5s) | is_night = true |
| 3 | Check zombie | _spawned_zombies.size() >= 1 |
| 4 | Đợi night (3s) | is_night = false |
| 5 | Check zombie clear | _spawned_zombies.size() = 0 |
| 6 | Check day_count | day_count = 2 |
| 7 | Check save file | FileAccess.file_exists(SAVE_PATH) = true |
| 8 | Check daily_tasks | size = 3 |
| 9 | Check stats | stats["days_survived"] = 1 |
| 10 | Check journal text | journal_btn.text KHÔNG chứa "Ã" hay "â€" |

### 4.2 test_survival_loop.gd — 3 đêm liên tiếp

Setup: `day=3s, night=2s` → tổng 15s chạy

| Check | Assert |
|-------|--------|
| Không có SCRIPT ERROR | Godot log sạch |
| day_count = 4 sau 3 đêm | đúng |
| _spawned_zombies = 0 mỗi sáng | đúng |
| breach_last_night reset | false mỗi sáng |
| scrap_count >= 0 | không âm |
| Save JSON hợp lệ | parse được |

### 4.3 test_save_load.gd

| Step | Action | Assert |
|------|--------|--------|
| 1 | Set scrap=42, seeds=7, water=3 | set đúng |
| 2 | add_relic("buff_turret") | relics_found có buff_turret |
| 3 | unlock("bp_radio") | has_unlocked true |
| 4 | save_game() | file tồn tại |
| 5 | Reset GameState | scrap=0 |
| 6 | load_game() | return true |
| 7 | Verify scrap | = 42 |
| 8 | Verify relic | has buff_turret |
| 9 | Verify unlock | has bp_radio |
| 10 | Verify multiplier | turret_damage_multiplier = 1.5 |

### 4.4 test_crafting_flow.gd

| Step | Action | Assert |
|------|--------|--------|
| 1 | Set seeds=2, water=1 | đủ nguyên liệu |
| 2 | Craft "meal" | seeds=0, water=0, meal_buff=true |
| 3 | Set breach_last_night=true | chuẩn bị |
| 4 | start_new_day() | is_tired = false (meal đã cứu) |

### 4.5 test_plant_harvest_flow.gd

| Step | Action | Assert |
|------|--------|--------|
| 1 | seeds=1, plant_seed() | true, state=PLANTED |
| 2 | growth_time = 0.1s, đợi | state = BLOOMED |
| 3 | harvest() | seeds >= 2, state=EMPTY |

### 4.6 test_merchant_shop.gd

| Step | Action | Assert |
|------|--------|--------|
| 1 | scrap=20, mở shop | UI visible |
| 2 | Mua "seeds_pack" (4 scrap) | scrap=16, seeds+=3 |
| 3 | Mua "cozy_rug" (12 scrap) | purchased_unique["cozy_rug"]=true |
| 4 | Thử mua lại "cozy_rug" | button disabled hoặc không tác dụng |

### 4.7 test_font_integrity.gd — PHẢI CHẠY MỌI LẦN

| Step | File scan | Assert |
|------|-----------|--------|
| 1 | scripts/hud.gd | KHÔNG chứa "Ã°", "â€", "Å¸" trong strings |
| 2 | scripts/zombie_ai.gd | tương tự |
| 3 | scripts/time_manager.gd | tương tự |
| 4 | scripts/mailbox_manager.gd | tương tự |
| 5 | scripts/art_cabin_props.gd | tương tự |
| 6 | Runtime: journal_btn.text | == "📋 Nhiệm Vụ & Hướng Dẫn  ▲" |
| 7 | Runtime: phase toast | toast "ĐÊM ĐÃ XUỐNG" (tiếng Việt đúng) |

---

## 5. PERFORMANCE TESTS

| ID | Test | Threshold |
|----|------|-----------|
| PERF-01 | FPS sau 5s gameplay | >= 30 FPS |
| PERF-02 | ObjectDB leak khi quit | <= 8 instances |
| PERF-03 | _draw() không gọi Node.new() | 0 allocations trong draw |
| PERF-04 | _tracers array | size <= 20 |
| PERF-05 | Tween chồng chất | chỉ 1 _insomnia_tw tại 1 thời điểm |
| PERF-06 | audio_manager cache | không gọi get_first_node_in_group mỗi frame |

---

## 6. REGRESSION TESTS

| ID | Bug cũ | Test | Assert |
|----|--------|------|--------|
| REG-01 | Solar text copy-paste bug | HUD process | solar_text KHÔNG gán new_arc_text |
| REG-02 | _spawn_zombies memory leak | sau đêm 2 | _spawned_zombies.size() đúng |
| REG-03 | Tween spam journal | mở/đóng 10 lần | panel đóng/mở mượt, không crash |
| REG-04 | Merchant dog ghost collision | player gần dog | player không bị kẹt |
| REG-05 | Mojibake encoding | mọi .gd file | không có Ã byte trong strings |
| REG-06 | Player đứng yên | nhấn phím | player di chuyển |
| REG-07 | Fireplace glow quá to | art_lighting draw | radius ngoài cùng <= 80px |
| REG-08 | WAV không phát | footstep | footstep.wav.import tồn tại |

---

## 7. IMPLEMENTATION GUIDE

### test_assert.gd (helper)

```gdscript
# tests/helpers/test_assert.gd
extends Node

var pass_count: int = 0
var fail_count: int = 0
var suite_name: String = ""

func begin(name: String) -> void:
    suite_name = name
    print("\n=== " + name + " ===")

func check(condition: bool, msg: String) -> void:
    if condition:
        print("[PASS] " + msg)
        pass_count += 1
    else:
        printerr("[FAIL] " + msg)
        fail_count += 1
        OS.exit_code = 1

func done() -> void:
    print("[%s] PASS: %d | FAIL: %d" % [suite_name, pass_count, fail_count])
```

### test_game_state.gd (mẫu đầy đủ)

```gdscript
# tests/unit/test_game_state.gd
extends Node

var _t: Node  # test_assert instance

func _ready() -> void:
    _t = preload("res://tests/helpers/test_assert.gd").new()
    add_child(_t)
    _t.begin("GameState")
    run_all()
    _t.done()

func _reset() -> void:
    GameState.scrap_count = 0
    GameState.seeds_count = 0
    GameState.water_count = 0
    GameState.is_tired = false
    GameState.breach_last_night = false
    GameState.meal_buff = false
    GameState.relics_found = []
    GameState.turret_damage_multiplier = 1.0
    GameState.plant_harvest_bonus = 0
    GameState.solar_charge_multiplier = 1.0
    GameState.stats = {"zombies_killed": 0, "days_survived": 0, "walls_built": 0, "plants_harvested": 0}

func run_all() -> void:
    _test_gs01_add_scrap()
    _test_gs03_spend_scrap_success()
    _test_gs04_spend_scrap_fail()
    _test_gs07_new_day_not_tired()
    _test_gs08_new_day_tired()
    _test_gs09_new_day_meal_saves()
    _test_gs10_new_day_reset_flags()
    _test_gs11_relic_buff_turret()
    _test_gs14_relic_no_duplicate()
    _test_gs18_stats_not_null()
    _test_gs19_rest_well()
    _test_gs20_track_stat()

func _test_gs01_add_scrap() -> void:
    _reset()
    GameState.add_scrap(5)
    _t.check(GameState.scrap_count == 5, "GS-01: add_scrap(5) = 5")

func _test_gs03_spend_scrap_success() -> void:
    _reset()
    GameState.scrap_count = 10
    var ok = GameState.spend_scrap(4)
    _t.check(ok == true, "GS-03: spend_scrap return true")
    _t.check(GameState.scrap_count == 6, "GS-03: scrap = 6")

func _test_gs04_spend_scrap_fail() -> void:
    _reset()
    GameState.scrap_count = 2
    var ok = GameState.spend_scrap(5)
    _t.check(ok == false, "GS-04: spend_scrap return false")
    _t.check(GameState.scrap_count == 2, "GS-04: scrap unchanged")

func _test_gs07_new_day_not_tired() -> void:
    _reset()
    GameState.breach_last_night = false
    GameState.meal_buff = false
    GameState.start_new_day()
    _t.check(GameState.is_tired == false, "GS-07: no breach = not tired")

func _test_gs08_new_day_tired() -> void:
    _reset()
    GameState.breach_last_night = true
    GameState.meal_buff = false
    GameState.start_new_day()
    _t.check(GameState.is_tired == true, "GS-08: breach no meal = tired")

func _test_gs09_new_day_meal_saves() -> void:
    _reset()
    GameState.breach_last_night = true
    GameState.meal_buff = true
    GameState.start_new_day()
    _t.check(GameState.is_tired == false, "GS-09: breach + meal = not tired")

func _test_gs10_new_day_reset_flags() -> void:
    _reset()
    GameState.breach_last_night = true
    GameState.meal_buff = true
    GameState.start_new_day()
    _t.check(GameState.breach_last_night == false, "GS-10: breach reset")
    _t.check(GameState.meal_buff == false, "GS-10: meal_buff reset")

func _test_gs11_relic_buff_turret() -> void:
    _reset()
    GameState.add_relic("buff_turret")
    _t.check(GameState.turret_damage_multiplier == 1.5, "GS-11: turret 1.5x")

func _test_gs14_relic_no_duplicate() -> void:
    _reset()
    GameState.add_relic("buff_turret")
    GameState.add_relic("buff_turret")
    _t.check(GameState.relics_found.size() == 1, "GS-14: no duplicate relic")

func _test_gs18_stats_not_null() -> void:
    _t.check(GameState.stats.has("zombies_killed"), "GS-18: stats has zombies_killed")

func _test_gs19_rest_well() -> void:
    _reset()
    GameState.is_tired = true
    GameState.rest_well()
    _t.check(GameState.is_tired == false, "GS-19: rest_well clears tired")

func _test_gs20_track_stat() -> void:
    _reset()
    var before = GameState.stats["zombies_killed"]
    GameState.track_stat("zombies_killed")
    _t.check(GameState.stats["zombies_killed"] == before + 1, "GS-20: track_stat +1")
```

### run_tests.gd (entry point)

```gdscript
# tests/run_tests.gd
extends SceneTree

func _initialize() -> void:
    print("=== INSOMNIA IN THE DARK WAR — TEST SUITE ===")

    var unit_tests: Array[String] = [
        "res://tests/unit/test_game_state.gd",
        "res://tests/unit/test_journal_manager.gd",
        "res://tests/unit/test_save_manager.gd",
        "res://tests/unit/test_time_manager.gd",
        "res://tests/unit/test_mailbox_manager.gd",
        "res://tests/unit/test_crafting_ui.gd",
    ]

    # Font integrity test (critical — run always)
    var integrity_tests: Array[String] = [
        "res://tests/e2e/test_font_integrity.gd",
    ]

    for path in unit_tests + integrity_tests:
        if not ResourceLoader.exists(path):
            printerr("[SKIP] File not found: " + path)
            OS.exit_code = 1
            continue
        var scr: GDScript = load(path)
        var node: Node = Node.new()
        node.set_script(scr)
        root.add_child(node)
        await node.get_signal("test_done") if node.has_signal("test_done") else Engine.get_main_loop()
        root.remove_child(node)
        node.queue_free()

    var result: int = OS.get_exit_code()
    if result == 0:
        print("\n✅ TẤT CẢ TEST PASS")
    else:
        printerr("\n❌ CÓ TEST FAIL")

    quit(result)
```

### test_font_integrity.gd (critical anti-mojibake)

```gdscript
# tests/e2e/test_font_integrity.gd
extends Node

func _ready() -> void:
    var _t = preload("res://tests/helpers/test_assert.gd").new()
    add_child(_t)
    _t.begin("FontIntegrity")

    var files_to_check: Array[String] = [
        "res://scripts/hud.gd",
        "res://scripts/zombie_ai.gd",
        "res://scripts/time_manager.gd",
        "res://scripts/mailbox_manager.gd",
        "res://scripts/art_cabin_props.gd",
        "res://scripts/companion_cat.gd",
    ]

    # Mojibake patterns that should NEVER appear in .gd source code
    var bad_patterns: Array[String] = ["Ã°", "Å¸", "â€", "Ã¡", "á»", "Ã©", "Ã¢"]

    for file_path in files_to_check:
        if not FileAccess.file_exists(file_path):
            continue
        var f := FileAccess.open(file_path, FileAccess.READ)
        var content: String = f.get_as_text()
        f.close()

        var has_corruption: bool = false
        for pattern in bad_patterns:
            if pattern in content:
                has_corruption = true
                break

        var fname: String = file_path.get_file()
        _t.check(not has_corruption, "FONT: " + fname + " - không có mojibake")

    _t.done()
```

---

## 8. ƯU TIÊN TRIỂN KHAI

| Priority | Nhóm | Lý do |
|----------|------|-------|
| 🔴 P0 | Unit: GameState (GS-01..20) | Core state — mọi thứ phụ thuộc |
| 🔴 P0 | Unit: SaveManager (SM-01..13) | Mất data = trải nghiệm hỏng |
| 🔴 P0 | E2E: FontIntegrity (4.7) | Bug đã xảy ra — phải prevent |
| 🟠 P1 | Regression: REG-01..08 | Các bug đã biết |
| 🟠 P1 | Unit: JournalManager (JM-01..10) | Daily loop |
| 🟠 P1 | Integration: NightCycle (NC-01..11) | Core gameplay |
| 🟠 P1 | E2E: FullDayCycle (4.1) | Smoke test |
| 🟡 P2 | Integration: Player, PlantPot, Door | Feature coverage |
| 🟡 P2 | E2E: SaveLoad, Crafting, PlantHarvest | Data integrity |
| 🟢 P3 | E2E: MerchantShop | Feature |
| 🟢 P3 | Performance tests | Optimization |

---

## 9. LƯU Ý QUAN TRỌNG

> **Test isolation:** Mỗi test PHẢI gọi `_reset()` trước. Dùng `_reset_game_state()` helper.

> **Headless mode:** Integration tests cần scene thật. Chạy với `--headless res://tests/integration/runner.tscn`.

> **Mojibake test (REG-05, 4.7):** Test này đọc .gd file như text thuần, dùng regex tìm pattern mojibake. PHẢI CHẠY mỗi lần sau khi edit script bằng tool bên ngoài.

> **Không sửa test để pass:** Nếu test fail → fix source code, không sửa test.
