import re

with open('scripts/art_cabin_props.gd', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace PackedVector2Array([ ... ]) with cached variables
poly_counter = 0
polys_init = []
polys_decl = []

def poly_replacer(match):
    global poly_counter
    poly_name = f"_poly_{poly_counter}"
    poly_counter += 1
    
    val = match.group(0)
    polys_decl.append(f"var {poly_name}: PackedVector2Array")
    polys_init.append(f"\t{poly_name} = {val}")
    return poly_name

content = re.sub(r'PackedVector2Array\(\[[^\]]+\]\)', poly_replacer, content)

# Now inject declarations and initializations
content = content.replace("func _ready() -> void:", "func _ready() -> void:\n" + "\n".join(polys_init))
decl_str = "\n".join(polys_decl)
content = content.replace("var _time: float = 0.0", f"{decl_str}\nvar _time: float = 0.0")

# For Color(...), the user said no Color(...) inside _draw.
color_counter = 0
colors_decl = []
def color_replacer(match):
    global color_counter
    c_name = f"_col_{color_counter}"
    color_counter += 1
    val = match.group(0)
    colors_decl.append(f"const {c_name}: Color = {val}")
    return c_name

# We need to find Color(...) that are NOT already in constants or declarations.
# A simple way: find all Color(...) inside functions (indented).
def function_color_replacer(match):
    prefix = match.group(1)
    if 'const ' in prefix or 'var ' in prefix: return match.group(0)
    
    # We found a Color(...) inside code
    col_str = match.group(2)
    global color_counter
    c_name = f"_col_{color_counter}"
    color_counter += 1
    colors_decl.append(f"const {c_name}: Color = Color({col_str})")
    return prefix + c_name

content = re.sub(r'(\n\s+[^#\n]*?)Color\(([^)]+)\)', function_color_replacer, content)
content = content.replace("var _time: float = 0.0", "\n".join(colors_decl) + "\nvar _time: float = 0.0")

with open('scripts/art_cabin_props.gd', 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Refactored {poly_counter} polygons and {color_counter} colors.")