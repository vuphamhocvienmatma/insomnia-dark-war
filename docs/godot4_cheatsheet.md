# GODOT 4 GDSCRIPT "VACCINE" CHEATSHEET
## Hướng dẫn cú pháp chuẩn Godot 4.x (Chống ảo tưởng cú pháp Godot 3)

---

### 1. Khai báo thuộc tính biên tập (@export thay vì export)
Trong Godot 3, ta dùng `export(int) var speed`. Trong Godot 4, ta dùng `@export` kèm static typing.

```gdscript
# CHÚA GHÉT (Cú pháp Godot 3 lỗi thời):
export(int) var max_energy = 100
export(Color) var light_color

# VACCINE CHUẨN (Godot 4):
@export var max_energy: int = 100
@export var light_color: Color = Color.ORANGE
```

---

### 2. Biến khởi tạo sẵn (@onready thay vì onready)
Mọi biến trích xuất Node con khi sẵn sàng phải dùng `@onready`.

```gdscript
# CHÚA GHÉT (Godot 3):
onready var animation_player = get_node("AnimationPlayer")

# VACCINE CHUẨN (Godot 4):
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var unique_ui: Label = %UniqueLabelUI  # Sử dụng Unique Node (%)
```

---

### 3. Kết nối tín hiệu (Signal Connection dạng Callable)
Trong Godot 4, kết nối signal không sử dụng chuỗi string bừa bãi mà kết nối trực tiếp qua đối tượng Callable.

```gdscript
# CHÚA GHÉT (Godot 3):
$Area2D.connect("body_entered", self, "_on_body_entered")

# VACCINE CHUẨN (Godot 4):
$Area2D.body_entered.connect(_on_body_entered)

# Kết nối hàm ẩn danh (Lambda) tiện lợi cho solo dev:
$Timer.timeout.connect(func(): print("Time out chill!"))
```

---

### 4. Di chuyển vật lý cơ học (move_and_slide() không tham số)
Trong Godot 4, `move_and_slide()` không nhận bất kỳ tham số hướng Vector nào nữa. Hướng di chuyển và vận tốc được gán trực tiếp vào thuộc tính `velocity` của `CharacterBody2D`.

```gdscript
# CHÚA GHÉT (Godot 3):
velocity = move_and_slide(velocity, Vector2.UP)

# VACCINE CHUẨN (Godot 4):
# CharacterBody2D đã tích hợp sẵn thuộc tính `velocity`
velocity = direction * speed
move_and_slide() # Tự động di chuyển dựa trên biến velocity nội bộ
```

---

### 5. Hệ thống lưới gạch (TileMapLayer thay cho TileMap)
Godot 4.3 đã loại bỏ node `TileMap` phức tạp để chuyển hoàn toàn sang sử dụng hệ thống riêng lẻ `TileMapLayer` giúp quản lý dễ dàng hơn.

```gdscript
# CHÚA GHÉT (Godot 3/4.0 cũ):
# Sử dụng TileMap rồi set_cell qua các layer id số

# VACCINE CHUẨN (Godot 4.3 trở lên):
# Sử dụng trực tiếp class TileMapLayer
@onready var wall_layer: TileMapLayer = $WallTileMapLayer

func place_tile(grid_pos: Vector2i) -> void:
    # set_cell(tọa_độ, source_id_atlas, atlas_coords, alternative_tile)
    wall_layer.set_cell(grid_pos, 0, Vector2i(1, 2))
```

---

### 6. Khởi tạo đối tượng động (instantiate() thay vì instance())
Để tạo một scene con từ file tscn vào game trong Godot 4.

```gdscript
# CHÚA GHÉT (Godot 3):
var wall_scene = load("res://wall.tscn")
var wall_instance = wall_scene.instance()

# VACCINE CHUẨN (Godot 4):
var wall_scene := preload("res://wall.tscn")
var wall_instance := wall_scene.instantiate() as Node2D
```

---

### 7. Tạo chuyển động mượt mà (Tween trực tiếp bằng Code)
Godot 4 loại bỏ hoàn toàn Node Tween vật lý rời rạc trong Scene Tree. Mọi Tween được khởi tạo thông qua phương thức trực tiếp `create_tween()`.

```gdscript
# CHÚA GHÉT (Godot 3):
# Phải kéo thả một node Tween vào scene, kết nối mệt mỏi

# VACCINE CHUẨN (Godot 4):
func fade_in_cozy_light() -> void:
    var tween := create_tween()
    # tween_property(đối_tượng, thuộc_tính_string, giá_trị_đích, thời_gian)
    tween.tween_property($PointLight2D, "energy", 1.5, 2.0).set_trans(Tween.TRANS_SINE)
```
