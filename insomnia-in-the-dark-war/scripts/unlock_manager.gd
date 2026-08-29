extends Node

func _ready() -> void:
	GameState.relic_collected.connect(_on_relic_collected)

func _on_relic_collected(type: String) -> void:
	match type:
		"buff_turret":
			print("✅ Unlock thật: Turret damage x1.5 (đã apply vào GameState.turret_damage_multiplier)")
		"buff_plant":
			print("✅ Unlock thật: Thu hoạch cây +2 phế liệu (đã apply vào GameState.plant_harvest_bonus)")
		"buff_solar":
			print("✅ Unlock thật: Solar charge x1.5 (đã apply vào GameState.solar_charge_multiplier)")
