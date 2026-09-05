# 🤖 AI SYSTEM GUIDE & ARCHITECTURE 

Welcome, fellow AI Assistant! This document contains the critical context and rules you need to understand, maintain, and expand **Insomnia in the Dark War** without breaking the codebase.

## 1. Core Paradigm: "Procedural 2.5D Diorama"
**CRITICAL RULE:** DO NOT USE TEXTURES OR SPRITES (unless absolutely necessary for UI fonts).
This game renders everything purely via code using Godot's `_draw()` function. 
- You must use `draw_colored_polygon`, `draw_circle`, `draw_line`, etc.
- To create 3D/2.5D illusions, manually calculate perspective lines (e.g., in `art_cabin_props.gd` and `art_player.gd`).
- Use warm, muted color palettes (`Color(r, g, b, a)`).

## 2. Architecture & Singletons
The game relies heavily on Global Singletons (Autoloads) defined in `project.godot`:
- **`GameState` (`game_state.gd`)**: Stores player stats, inventory (scrap, seed, water), and relics.
- **`ChillManager` (`chill_manager.gd`)**: The heart of the "lofi indie" vibe. Handles UI fade-ins, weather interactions (Sound Garden), animals, polaroids, and minigames (Guitar, Coffee).
- **`TimeManager` (`hud.gd` / `LevelSetup`)**: Controls the day/night cycle.

*Rule:* If you need to add a new chill/aesthetic feature, put it in `ChillManager`. If you need to add a physical object to the cabin, draw it in `art_cabin_props.gd`.

## 3. The "Chill Lofi" Vibe & Polish Rules
When writing animations or UI, follow these strict aesthetic guidelines:
- **No rigid linear movements:** Always use `Tween`. 
- **Organic Easing:** Default to `.set_trans(Tween.TRANS_SINE)` or `Tween.TRANS_CUBIC` and `.set_ease(Tween.EASE_IN_OUT)`. Avoid `TRANS_BOUNCE` or `TRANS_LINEAR`.
- **Breathing UIs:** Menus and texts should fade in/out (`modulate:a`) rather than `show()` / `hide()`.
- **Living World:** Animate static objects using `sin(Time.get_ticks_msec() * 0.001 * speed)`. Use this for floating animals, swaying lanterns, or breathing characters.

## 4. Weather & Shaders
The Weather Sensory System consists of 6 states (`sunny`, `drizzle`, `heavy_rain`, `thick_fog`, `snowstorm`, `meteor_shower`).
- **Logic & Particles**: Managed entirely in `art_weather.gd`.
- **Color Grading**: Managed by a full-screen `ColorRect` using `shaders/weather_post_process.gdshader`.
- *Rule:* If adding a new weather effect, you must update the switch cases in `art_weather.gd`, adjust `current_weather` in `level_setup.gd`, and modify the shader uniforms.

## 5. Node Groups & References
Do not use hardcoded node paths (e.g., `get_node("../../Player")`). 
Instead, rely on `get_tree().get_first_node_in_group()`:
- `"player"`: The main character.
- `"hud"`: For calling `show_toast(msg, duration, is_urgent)`.
- `"companion_cat"`: The pet cat.
- `"time_manager"`: The day/night cycle tracker.

## 6. How to Test (Headless CLI)
You MUST test your GDScript code before reporting success to the user. Use the local Godot CLI in headless mode to check for parse/compilation errors:
```bash
C:\Users\ezral\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 50
```
If the command exits with Code 0, your syntax is valid. 

## 7. Version Control & Git
When you finish implementing a feature:
1. Double-check that it works headlessly.
2. Ensure you haven't broken the `_draw()` rendering loops.
3. Commit with standard conventional commits (e.g., `feat: ...`, `fix: ...`, `refactor: ...`).

Good luck! Keep the code clean, and the vibes chill. ☕
