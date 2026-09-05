# AGENTS.md

## 6. B·ªò LU·∫¨T CH·ªêNG L·ªñI COMPILE (COMPILE-SAFE RULES)
6.1 .tscn colors: NEVER use Color("hex") or Color.WHITE in raw .tscn content. ALWAYS RGBA float format: modulate = Color(r, g, b, a) v·ªõi gi√° tr·ªã 0.0-1.0.
6.2 Node.get() accepts ONLY ONE argument. Default value syntax: node.get("prop") if "prop" in node else default_value.
6.3 Typed arrays: NEVER assign untyped Array into Array[Dictionary]/Array[String] with "=". Use .assign() or append loop. Prefer explicit type declarations over ":=" for complex expressions.
6.4 Variable scope: declare var ONCE at function top, before if/elif branches; inside branches only reassign, never redeclare the same name.
6.5 UI Control nodes (Label, Button...) in .tscn: NEVER use position. ALWAYS offset_left, offset_top, offset_right, offset_bottom.

6.6 Lu?t Cache B?t Bi?n: B?t bu?c AI Agent cache m?i Font, StyleBox, Color, Texture trong h‡m _ready(). C?M TUY?T –?I vi?c g?i ThemeDB.fallback_font hay Color(...) bÍn trong h‡m _draw() ho?c _process(). H‡m _draw() ph?i ch? ch?a c·c l?nh draw_*() thu?n t˙y.
6.7 TÌn hi?u (Signals): S? d?ng Signal thay vÏ g?i h‡m chÈo nhau b?ng Reference trong vÚng l?p _process().
