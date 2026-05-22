extends Area2D

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
var is_active: bool = true

signal statue_toggled(activated: bool)

var interactable: bool = false:
	get:
		return interactable
	set(value):
		sprite.material.set_shader_parameter('interactable', value)
		interactable = value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and interactable:
		is_active = not is_active
		statue_toggled.emit(is_active)

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		interactable = true

func _on_area_exited(_area: Area2D) -> void:
	for overlapping_areas in get_overlapping_areas():
		if overlapping_areas is Player:
			return
	
	interactable = false

func play_activate_animation() -> void:
	sprite.play("activating")

func play_deactivate_animation() -> void:
	sprite.play("deactivating")
