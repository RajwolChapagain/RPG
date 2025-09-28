extends ArrowStorm

@export var heal: int

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
func trigger_ability() -> void:
	if not is_initialized():
		print("Error: Did you forget to call initalize()?")
		get_tree().quit(-1)
		
	for target in targets:
		if target.stats.hp != 0:
			target.stats.hp += heal
