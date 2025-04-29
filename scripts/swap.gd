extends Area2D

@export var cost: int

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
# Swapping requires too much data to be passed here due to which it is done
#	in the battle scene itself
func trigger_ability() -> void:
	return
