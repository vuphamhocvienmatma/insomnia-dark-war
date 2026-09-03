extends StaticBody2D

@export var max_health: float = 50.0

var current_health: float = 0.0

func _ready() -> void:
	current_health = max_health
	add_to_group("defensive_wall")

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Rào chắn chịu ", amount, " sát thương! Còn lại: ", current_health)
	var art: Node = get_node_or_null("Art")
	if art != null and art.has_method("set_health_ratio"):
		art.call("set_health_ratio", current_health / max_health)
	if current_health <= 0.0:
		_spawn_break_fx()
		queue_free()


func _spawn_break_fx() -> void:
	var particles := GPUParticles2D.new()
	var parent := get_parent()
	if parent != null:
		parent.add_child(particles)
	else:
		add_child(particles)
	particles.global_position = global_position
	particles.amount = 15
	particles.lifetime = 0.5
	particles.one_shot = true
	var mat := ParticleProcessMaterial.new()
	mat.color = Color(0.4, 0.3, 0.2, 1.0)
	mat.gravity = Vector3(0.0, 100.0, 0.0)
	mat.scale_min = 0.0
	mat.scale_max = 0.3
	particles.process_material = mat
	particles.emitting = true
	var am := get_tree().get_first_node_in_group("audio_manager")
	if am != null:
		am.call("play_sfx", "wall_break")
	var cam := get_tree().get_first_node_in_group("main_camera")
	if cam != null and cam.has_method("trigger_shake"):
		cam.call("trigger_shake", 12.0)
	get_tree().create_timer(0.6).timeout.connect(particles.queue_free)
