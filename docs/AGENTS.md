# AGENT RULES FOR OPENCODE (LLM CODING INSTRUCTIONS)
## BỘ LUẬT BẮT BUỘC KHI VIẾT CODE CHO INSOMNIA IN THE DARK WAR

---

### 1. Quy tắc lập trình API Godot 4.x
*   **BẮT BUỘC** luôn luôn viết mã nguồn tương thích 100% với phiên bản **Godot 4.x**.
*   **CẤM** sử dụng các cú pháp cũ của Godot 3 (Ví dụ: cấm dùng `KinematicBody2D`, cấm dùng `export(int)`, cấm truyền tham số cho `move_and_slide()`, cấm sử dụng phương thức `instance()`). 
*   Nếu không chắc chắn về cú pháp API Godot 4, hãy tra cứu cheatsheet đi kèm tại `godot4_cheatsheet.md`.

---

### 2. Ép kiểu dữ liệu tĩnh (Statically Typed GDScript)
Để hạn chế tối đa lỗi runtime lãng phí thời gian gỡ lỗi cho solo developer, mọi đoạn code do Agent sinh ra bắt buộc phải khai báo kiểu dữ liệu rõ ràng.

*   **Không viết:** `var speed = 100` hay `func process_input(event)`
*   **Bắt buộc viết:**
    ```gdscript
    var speed: float = 100.0
    var player_name: String = "Survivor"
    
    func process_input(event: InputEvent) -> void:
        # Code xử lý...
    ```

*   **CẢNH BÁO sign():** Hàm `sign()` trong Godot 4 trả về `int`, không phải `float`. Khi dùng `var x := sign(...)` sẽ lỗi type inference. **Bắt buộc khai báo rõ kiểu:**
    ```gdscript
    # SAI — lỗi Cannot infer the type:
    var dir := sign(global_position.x)
    var side := -sign(global_position.x)
    
    # ĐÚNG:
    var dir: float = sign(global_position.x)
    var side: float = -sign(global_position.x)
    ```
    Tương tự cho mọi hàm trả `int`: `absi()`, `snappedi()`, `floori()`, `ceili()`, `roundi()`. Luôn dùng `var x: float = ...` khi cần float.

---

### 3. Không tự tiện thêm Addons hay Dependency bên ngoài
*   Agent **KHÔNG ĐƯỢC** viết code phụ thuộc vào bất kỳ thư viện, plugin, C# scripts hay addons bên thứ ba nào (như Godot-Playfab, YarnSpinner...) trừ khi được yêu cầu rõ ràng.
*   Mọi giải pháp kỹ thuật phải được giải quyết triệt để chỉ bằng các Node mặc định tích hợp sẵn của Godot 4 (như `CharacterBody2D`, `TileMapLayer`, `Area2D`, `GPUParticles2D`, `AudioStreamPlayer`).

---

### 4. Quy tắc kết thúc nhiệm vụ (Test Line Pattern)
Mỗi khi viết xong một tính năng hoặc sửa một lỗi, Agent **BẮT BUỘC** phải kết thúc phản hồi bằng đúng một dòng tóm tắt mô tả phương thức kiểm tra thủ công trong Godot Editor theo cú pháp:

> **"chạy scene X, kỳ vọng thấy Y"**

*Ví dụ:*
*   *Hợp lệ:* `chạy scene res://scenes/building_manager.tscn, kỳ vọng thấy bóng mờ của vách gỗ bám dính (snap) chính xác theo tọa độ chuột khi di chuyển quanh pháo đài.`
*   *Hợp lệ:* `chạy scene res://scenes/lofi_stove.tscn, kỳ vọng thấy khói hạt GPUParticles2D bốc lên ấm áp và in log "Món súp nấu chín!" sau 5 giây click vào bếp lò.`

---

### 5. Phòng chống lỗi "Mất trí nhớ" (Context Protection)
*   Khi sửa đổi một tệp script, Agent phải xuất ra **toàn bộ mã nguồn hoàn chỉnh**.
*   **CẤM** cắt ngắn code bằng các ghi chú dạng `# [đoạn code cũ giữ nguyên ở đây]` hoặc `# ... code cũ ...`. Việc này sẽ khiến người dùng không biết code gặp khó khăn lớn khi dán đè file.
