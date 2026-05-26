extends Area2D

@export var sprite: Sprite2D

var active: bool = true
signal sky_interacted

var interactable: bool = false:
	get:
		return interactable
	set(value):
		sprite.material.set_shader_parameter('interactable', value)
		interactable = value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and interactable and active and not BattleManager.is_battle_ongoing:
		sky_interacted.emit()

func _on_area_entered(area: Area2D) -> void:
	if area is Player and active:
		interactable = true

func _on_area_exited(_area: Area2D) -> void:
	for overlapping_areas in get_overlapping_areas():
		if overlapping_areas is Player:
			return
	
	interactable = false
