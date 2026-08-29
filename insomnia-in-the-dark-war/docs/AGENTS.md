# AGENTS.md

## 6. BỘ LUẬT CHỐNG LỖI COMPILE (COMPILE-SAFE RULES)
6.1 .tscn colors: NEVER use Color("hex") or Color.WHITE in raw .tscn content. ALWAYS RGBA float format: modulate = Color(r, g, b, a) với giá trị 0.0-1.0.
6.2 Node.get() accepts ONLY ONE argument. Default value syntax: node.get("prop") if "prop" in node else default_value.
6.3 Typed arrays: NEVER assign untyped Array into Array[Dictionary]/Array[String] with "=". Use .assign() or append loop. Prefer explicit type declarations over ":=" for complex expressions.
6.4 Variable scope: declare var ONCE at function top, before if/elif branches; inside branches only reassign, never redeclare the same name.
6.5 UI Control nodes (Label, Button...) in .tscn: NEVER use position. ALWAYS offset_left, offset_top, offset_right, offset_bottom.
