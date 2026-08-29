# Godot 4 Cheatsheet

## 8. Màu trong .tscn
CHÚA GHÉT: modulate = Color("ffd700") hoặc Color.WHITE trong .tscn
VACCINE: modulate = Color(1.0, 0.84, 0.0, 1.0)

## 9. Node.get()
CHÚA GHÉT: node.get("item_type", "scrap") (Too many arguments)
VACCINE: str(node.get("item_type")) if "item_type" in node else "scrap"

## 10. Typed array
CHÚA GHÉT: daily_tasks = task_pool.slice(0, 3) (Array gán vào Array[Dictionary])
VACCINE: daily_tasks.assign(task_pool.slice(0, 3))

## 11. Scope
CHÚA GHÉT: khai báo var trùng tên bên trong từng nhánh if/elif rồi gọi chéo
VACCINE: var dir: float = 0.0 ở đầu hàm, trong nhánh chỉ gán dir = ...

## 12. UI trong .tscn
CHÚA GHÉT: position = Vector2(16, 88) cho Label
VACCINE: offset_left = 16.0 / offset_top = 88.0 / offset_right = 400.0 / offset_bottom = 112.0
