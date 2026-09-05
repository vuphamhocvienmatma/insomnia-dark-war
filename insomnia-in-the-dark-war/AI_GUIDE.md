# 🤖 AI SYSTEM GUIDE & ARCHITECTURE 

Welcome, fellow AI Assistant! This document contains the critical context and rules you need to understand, maintain, and expand **Insomnia in the Dark War** without breaking the codebase.

## 1. Core Paradigm: "Procedural 2.5D Diorama"
**CRITICAL RULE:** DO NOT USE TEXTURES OR SPRITES (unless absolutely necessary for UI fonts).
This game renders everything purely via code using Godot's _draw() function. 
- You must use draw_colored_polygon, draw_circle, draw_line, etc.
- To create 3D/2.5D illusions, manually calculate perspective lines (e.g., in rt_cabin_props.gd and rt_player.gd).
- Use warm, muted color palettes (Color(r, g, b, a)).

## 2. Strict Performance & Optimization Rules (Godot 4)
We have optimized this game for seamless Web HTML5 exports and low-end devices:
- **No Unconditional Redraws:** DO NOT call queue_redraw() unconditionally inside _process() unless drawing dynamic particles. Use dirty flags, Timers, or signal-based redraws.
- **Cache All Rendering Resources:** NEVER instantiate Color(), PackedVector2Array(), Font(), or StyleBox() directly inside a _draw() function. Allocate them in _ready() or as file-level global variables (ar _poly: PackedVector2Array). 
- **Tween Management:** Whenever using create_tween() on UI elements (like toasts or vignette), always store the reference (e.g. ar toast_tween: Tween) and call .kill() on it before creating a new one to prevent memory leaks and flickering.
- **Strict Static Typing:** Use strict types for all variables and function returns (e.g. ar speed: float = 10.0, unc do_x() -> void:). Avoid instance() (use instantiate()) or Godot 3 syntaxes.

## 3. Architecture & Singletons
The game relies heavily on Global Singletons (Autoloads) defined in project.godot:
- **GameState (game_state.gd)**: Stores player stats, inventory (scrap, seed, water), and relics.
- **ChillManager (chill_manager.gd)**: The heart of the "lofi indie" vibe. Handles UI fade-ins, weather interactions (Sound Garden), animals, polaroids, and minigames.
- **JournalManager, SaveManager, MailboxManager, CabinDecorationManager**: Handle sub-systems.
- **Fonts & Web Export**: We use a custom global theme (ssets/theme.tres) with MainFont.tres (CourierPrime with NotoColorEmoji fallback) to ensure Emojis render correctly on Web HTML5. Do NOT use ThemeDB.fallback_font in scripts; preload MainFont.tres instead.

## 4. The "Chill Lofi" Vibe & Polish Rules
- **No rigid linear movements:** Always use Tween. 
- **Organic Easing:** Default to .set_trans(Tween.TRANS_SINE) or Tween.TRANS_CUBIC and .set_ease(Tween.EASE_IN_OUT). Avoid TRANS_BOUNCE or TRANS_LINEAR.
- **Diegetic UIs:** Draw UI elements onto the environment whenever possible (e.g., rt_cabin_props.gd).
- **Living World:** Animate static objects using sin(_time * speed). Use this for floating animals, swaying lanterns, or breathing characters.

## 5. Zombie AI & Combat Mechanics
- Zombies must immediately stop processing physics (set_physics_process(false)) and stop monitoring areas when their health reaches 0 to avoid collision glitches during their death animation.
- Turrets (uto_turret.gd) track multiple targets in an array via Area2D and smoothly switch targets when one dies. 

## 6. How to Test (Headless CLI)
You MUST test your GDScript code before reporting success to the user. Use the local Godot CLI in headless mode to check for parse/compilation errors:
`ash
C:\Users\ezral\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 50
`
If the command exits with Code 0, your syntax is valid. 

## 7. Version Control & Git
1. Double-check that it works headlessly.
2. Ensure you haven't broken the _draw() rendering loops.
3. Push everything automatically. The user explicitly enabled automated Push permissions.