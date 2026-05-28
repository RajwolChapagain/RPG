extends Area2D

@export var npc_index: int
@export_file('*.csv') var dialogue_file_path: String
@export var dialogue_start_line_number: int
@export var npc_without_spear_sprite: Texture2D
@export var interact_on_collide: bool = false
@export var is_obstacle: bool = false:
	get:
		return is_obstacle
	set(value):
		if value:
			%StaticBody2D.set_collision_layer_value(1, true)
		else:
			%StaticBody2D.set_collision_layer_value(1, false)
		is_obstacle = value
var handed_spear_off: bool = false:
	get:
		return handed_spear_off
	set(value):
		if value:
			%Sprite2D.texture = npc_without_spear_sprite
		handed_spear_off = value
		
@onready var sprite: Sprite2D = %Sprite2D

var interactable: bool = false:
	get:
		return interactable
	set(value):
		sprite.material.set_shader_parameter('interactable', value)
		interactable = value

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and interactable and not BattleManager.is_battle_ongoing:
		DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number, self)
		StatTracker.set_npc_interacted(npc_index)

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		if not interact_on_collide:
			interactable = true
		else:
			DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number, self)
			StatTracker.set_npc_interacted(npc_index)

func _on_area_exited(_area: Area2D) -> void:
	for overlapping_areas in get_overlapping_areas():
		if overlapping_areas is Player:
			return
	
	interactable = false
