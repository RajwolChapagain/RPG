extends Area2D

@export var damage: int
var target: Node2D

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
func set_target(target: Node2D)-> void:
	self.target = target
	
func trigger_ability() -> void:
	if target == null:
		print("Error: Did you forget to call set_target()?")
		get_tree().quit(-1)
	
	global_position = target.global_position

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
