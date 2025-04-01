extends ArrowStorm

@export var heal: int

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
func trigger_ability() -> void:
	if targets.is_empty():
		print("Error: Did you forget to call set_targets()?")
		get_tree().quit(-1)
		
	for target in targets:
		target.stats.hp += heal
