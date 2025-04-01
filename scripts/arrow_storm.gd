extends Area2D
class_name ArrowStorm

@export var damage: int
var targets: Array[Node2D]

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
func set_targets(targets: Array[Node2D])-> void:
	self.targets = targets
	
func trigger_ability() -> void:
	if targets.is_empty():
		print("Error: Did you forget to call set_target()?")
		get_tree().quit(-1)
	
	# For single-target abilities, targets.pick_random() should just return the
	# 	only target in targets array. pick_random() is used instead of front()
	#	to easily spot weird behaviors for multi-target abilities
	global_position = targets.pick_random().global_position

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
