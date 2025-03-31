extends Area2D

var target: Node2D

func set_target(target: Node2D)-> void:
	self.target = target
	
func trigger_ability() -> void:
	if target == null:
		print("Error: Did you forget to call set_target()?")
		get_tree().quit(-1)
	
	global_position = target.global_position
