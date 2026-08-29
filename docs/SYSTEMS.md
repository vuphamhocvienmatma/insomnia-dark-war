# TECHNICAL SYSTEMS SPECIFICATION
## HỆ THỐNG KỸ THUẬT - INSOMNIA IN THE DARK WAR

---

### Phase 1: Khung lõi (Core Framework)

#### 1.1 Hệ thống Grid & Modular Building (Sockets & Snapping)
*   **Mục đích:** Xử lý cơ chế kéo thả các mảnh gỗ/sắt phế liệu để lắp ráp và bắt dính (snap) chính xác vào lưới tọa độ của pháo đài dựa trên dữ liệu Pose (Vị trí + Góc xoay) [22].
*   **Node Godot chính:** `Node2D` (BuildingManager), `TileMapLayer` (Lưới tính toán tọa độ), `Area2D` (Socket phát hiện va chạm xây dựng), `Sprite2D` (PreviewGhost).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: socket_2d.gd
    class_name BuildSocket2D
    extends Area2D

    @export_enum("Floor", "Wall", "Door", "SolarGrid") var accept_type: String = "Wall"
    
    var is_occupied: bool = false
    var occupant_part: Node2D = null

    func get_snap_pose() -> Dictionary:
        return {
            "position": global_position,
            "rotation": global_rotation
        }

    func can_accept(part_type: String) -> bool:
        return !is_occupied and part_type == accept_type
    ```
    ```gdscript
    # file: building_manager.gd
    extends Node2D

    @export var ghost_material: ShaderMaterial
    @export var valid_material: ShaderMaterial

    var holding_part_type: String = "Wall"
    var active_socket: BuildSocket2D = null
    var ghost_preview: Sprite2D = null

    func _ready() -> void:
        ghost_preview = Sprite2D.new()
        ghost_preview.material = ghost_material
        add_child(ghost_preview)

    func _process(_delta: float) -> void:
        var mouse_pos := get_global_mouse_position()
        active_socket = _find_closest_valid_socket(mouse_pos)
        
        if active_socket != null:
            var pose := active_socket.get_snap_pose()
            ghost_preview.global_position = pose.position
            ghost_preview.global_rotation = pose.rotation
            ghost_preview.material = valid_material
        else:
            ghost_preview.global_position = mouse_pos
            ghost_preview.global_rotation = 0.0
            ghost_preview.material = ghost_material

    func _unhandled_input(event: InputEvent) -> void:
        if event.is_action_pressed("click_build") and active_socket != null:
            place_build_piece(active_socket)

    func place_build_piece(socket: BuildSocket2D) -> void:
        var new_piece = load("res://scenes/wall_piece.tscn").instantiate() as Node2D
        get_parent().add_child(new_piece)
        
        var pose := socket.get_snap_pose()
        new_piece.global_position = pose.position
        new_piece.global_rotation = pose.rotation
        
        socket.is_occupied = true
        socket.occupant_part = new_piece
        active_socket = null
    
    func _find_closest_valid_socket(pos: Vector2) -> BuildSocket2D:
        var space_state := get_world_2d().direct_space_state
        var query := PhysicsPointQueryParameters2D.new()
        query.position = pos
        query.collision_mask = 2 # Socket Layer
        query.collide_with_areas = true
        
        var results := space_state.intersect_point(query)
        for res in results:
            var area = res.collider as BuildSocket2D
            if area and area.can_accept(holding_part_type):
                return area
        return null
    ```
*   **Hệ thống phụ thuộc:** Không có.

#### 1.2 Hệ thống Base Integrity & Blind Spot Detector
*   **Mục đích:** Kiểm tra định kỳ tính toàn vẹn của pháo đài. Nếu xuất hiện bất kỳ ô Socket trống (Blind Spot/Góc chết) nào chưa được trám ván, thây ma có thể xâm nhập mà không gặp cản trở [8].
*   **Node Godot chính:** `Node` (IntegrityTracker), `Area2D` (BreachTrigger).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: integrity_tracker.gd
    extends Node

    signal fort_breached
    signal fort_secured

    @export var critical_sockets: Array[BuildSocket2D] = []

    func _ready() -> void:
        var timer = Timer.new()
        timer.wait_time = 1.0
        timer.autostart = true
        timer.timeout.connect(check_perimeter_integrity)
        add_child(timer)

    func check_perimeter_integrity() -> void:
        var open_blind_spots := 0
        for socket in critical_sockets:
            if not socket.is_occupied:
                open_blind_spots += 1
        
        if open_blind_spots > 0:
            fort_breached.emit()
        else:
            fort_secured.emit()
    ```
*   **Hệ thống phụ thuộc:** Grid & Modular Building.

#### 1.3 Hệ thống Zombie Wave & Barricade Obstruction
*   **Mục đích:** Điều phối AI thây ma di chuyển hướng thẳng về phía pháo đài ban đêm [8]. Khi chạm phải vách gỗ/sắt đã xây dựng, chúng sẽ chuyển trạng thái sang tấn công (đập rào "THWACK") gây hư hại công trình [26].
*   **Node Godot chính:** `CharacterBody2D` (Zombie), `NavigationAgent2D` (Dẫn đường), `Area2D` (AttackArea).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: zombie_ai.gd
    extends CharacterBody2D

    @export var speed: float = 30.0
    @export var attack_damage: float = 10.0

    @onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
    @onready var attack_area: Area2D = $AttackArea

    var target_fort_center: Vector2 = Vector2.ZERO
    var is_attacking: bool = false
    var current_target_fence: Node2D = null

    func _ready() -> void:
        target_fort_center = get_tree().get_first_node_in_group("fort_center").global_position
        navigation_agent.target_position = target_fort_center

    func _physics_process(_delta: float) -> void:
        if is_attacking:
            return
            
        if navigation_agent.is_navigation_finished():
            velocity = Vector2.ZERO
            return

        var next_path_pos := navigation_agent.get_next_path_position()
        var dir := global_position.direction_to(next_path_pos)
        velocity = dir * speed
        move_and_slide()

    func _on_attack_area_body_entered(body: Node2D) -> void:
        if body.is_in_group("defensive_wall"):
            is_attacking = true
            current_target_fence = body
            $AttackTimer.start()

    func _on_attack_timer_timeout() -> void:
        if current_target_fence and is_instance_valid(current_target_fence):
            current_target_fence.take_damage(attack_damage)
        else:
            is_attacking = false
            $AttackTimer.stop()
            navigation_agent.target_position = target_fort_center
    ```
*   **Hệ thống phụ thuộc:** Grid & Modular Building, Base Integrity.

---

### Phase 2: Không khí & Vòng lặp (Atmosphere & Loop)

#### 2.1 Hệ thống Day-Night Cycle & Solar Grid
*   **Mục đích:** Quản lý thời gian thực của game. Ban ngày nạp điện năng lượng mặt trời (Solar Grid) để vận hành súng phun lửa và lò sưởi ban đêm [8].
*   **Node Godot chính:** `Node` (TimeManager), `CanvasModulate` (Phủ lọc màu ngày/đêm), `Timer`.
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: time_manager.gd
    extends Node

    signal phase_changed(is_night: bool)

    @export var day_duration_seconds: float = 120.0
    @export var night_duration_seconds: float = 60.0

    @onready var environmental_light: CanvasModulate = $CanvasModulate

    var current_solar_energy: float = 0.0
    var max_solar_storage: float = 100.0
    var is_night: bool = false
    var time_elapsed: float = 0.0

    @export var day_color := Color("ffe699") 
    @export var night_color := Color("1c1d3a")

    func _process(delta: float) -> void:
        time_elapsed += delta
        var target_color: Color
        
        if not is_night:
            var ratio := time_elapsed / day_duration_seconds
            target_color = day_color.lerp(night_color, ratio)
            current_solar_energy = clamp(current_solar_energy + (delta * 5.0), 0.0, max_solar_storage)
            
            if time_elapsed >= day_duration_seconds:
                transition_to_night()
        else:
            var ratio := time_elapsed / night_duration_seconds
            target_color = night_color.lerp(day_color, ratio * 0.1)
            
            if time_elapsed >= night_duration_seconds:
                transition_to_day()
                
        environmental_light.color = target_color

    func transition_to_night() -> void:
        is_night = true
        time_elapsed = 0.0
        phase_changed.emit(true)

    func transition_to_day() -> void:
        is_night = false
        time_elapsed = 0.0
        phase_changed.emit(false)
    ```
*   **Hệ thống phụ thuộc:** Không có.

#### 2.2 Hệ thống Cozy Cabin Living (Cooking & Gardening)
*   **Mục đích:** Xử lý cơ chế nấu ăn bên bếp lò sưởi ấm áp và gieo trồng cây xanh bên ô cửa sổ pháo đài [16, 21].
*   **Node Godot chính:** `Area2D` (InteractiveFurniture), `GPUParticles2D` (Hiệu ứng khói súp bốc lên), `Timer`.
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: interactive_stove.gd
    extends Area2D

    @onready var steam_particles: GPUParticles2D = $SteamParticles
    @onready var cooking_timer: Timer = $CookingTimer

    var player_inside: bool = false
    var is_cooking: bool = false

    func _ready() -> void:
        body_entered.connect(func(body): if body.is_in_group("player"): player_inside = true)
        body_exited.connect(func(body): if body.is_in_group("player"): player_inside = false)

    func _input(event: InputEvent) -> void:
        if event.is_action_pressed("interact") and player_inside and not is_cooking:
            start_cooking()

    func start_cooking() -> void:
        is_cooking = true
        steam_particles.emitting = true
        cooking_timer.start(5.0)

    func _on_cooking_timer_timeout() -> void:
        is_cooking = false
        steam_particles.emitting = false
        print("Món súp nấu chín!")
    ```
*   **Hệ thống phụ thuộc:** Day-Night Cycle.

---

### Phase 3: Polish & Juice (Cảm xúc & Độ đã tay)

#### 3.1 Hệ thống Juicy Impact Feedback & Camera Shake
*   **Mục đích:** Tạo phản hồi rung máy ảnh và dừng hình (hit stop) khi zombie cào hàng rào hoặc súng phun lửa phát nổ, gia tăng độ thỏa mãn hành động [26].
*   **Node Godot chính:** `Camera2D`, `Node` (HitStopManager).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: camera_lofi.gd
    extends Camera2D

    var shake_intensity: float = 0.0
    var shake_decay: float = 5.0

    func _process(delta: float) -> void:
        if shake_intensity > 0.0:
            offset = Vector2(
                randf_range(-shake_intensity, shake_intensity),
                randf_range(-shake_intensity, shake_intensity)
            )
            shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
        else:
            offset = Vector2.ZERO

    func trigger_shake(intensity: float) -> void:
        shake_intensity = intensity
    ```
*   **Hệ thống phụ thuộc:** Zombie Wave & Barricade.

#### 3.2 Hệ thống Screen-Space Cel Shader & Warm Flicker
*   **Mục đích:** Tái hiện mỹ thuật cel-shaded hoạt họa vẽ viền mộc mạc và ánh sáng lửa sưởi bập bùng tự nhiên [4, 16].
*   **Node Godot chính:** `SubViewportContainer` (áp dụng Shader hậu kỳ), `PointLight2D` (Lửa sưởi).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: warm_fireplace_light.gd
    extends PointLight2D

    @export var base_energy: float = 1.2
    @export var flicker_speed: float = 12.0
    var noise: FastNoiseLite
    var time: float = 0.0

    func _ready() -> void:
        noise = FastNoiseLite.new()
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

    func _process(delta: float) -> void:
        time += delta * flicker_speed
        var n_val := noise.get_noise_1d(time)
        energy = base_energy + (n_val * 0.25)
    ```
*   **Hệ thống phụ thuộc:** Không có.

#### 3.3 Hệ thống Cozy Audio Dynamic Crossfader
*   **Mục đích:** Chuyển giao nhạc nền mượt mà giữa trạng thái lofi dọn dẹp ban ngày và âm thanh mưa rơi, gió rít mờ sương ban đêm [21, 23].
*   **Node Godot chính:** `AudioStreamPlayer` (BGM_Day), `AudioStreamPlayer` (Ambient_Night).
*   **Logic cốt lõi (GDScript 4.x):**
    ```gdscript
    # file: lofi_audio_manager.gd
    extends Node

    @onready var day_lofi_player: AudioStreamPlayer = $DayLofiPlayer
    @onready var night_ambient_player: AudioStreamPlayer = $NightAmbientPlayer

    func _ready() -> void:
        day_lofi_player.play()
        night_ambient_player.play()
        night_ambient_player.volume_db = -80.0
        day_lofi_player.volume_db = 0.0

    func fade_to_night() -> void:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(day_lofi_player, "volume_db", -15.0, 4.0)
        tween.tween_property(night_ambient_player, "volume_db", 0.0, 4.0)

    func fade_to_day() -> void:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(day_lofi_player, "volume_db", 0.0, 4.0)
        tween.tween_property(night_ambient_player, "volume_db", -80.0, 4.0)
    ```
*   **Hệ thống phụ thuộc:** Day-Night Cycle.
