extends Node

@export var dialogue_ui_scene: PackedScene
@export var sprite_database: PortraitDatabase

enum SIDE { LEFT, RIGHT }
var dialogue_file = null
var last_side = SIDE.LEFT
var last_sprite_name = ""
var dialogue_ui = null
var dialogue_ongoing = false
var current_dialogue_line_number: int = 0

func _ready() -> void:
	dialogue_ui = dialogue_ui_scene.instantiate()
	%CanvasLayer.add_child(dialogue_ui)
	dialogue_ui.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		advance_dialogue()
		
func load_dialogue(dialogue_file_path: String, dialogue_start_line_number: int) -> void:
	dialogue_file = FileAccess.open(dialogue_file_path, FileAccess.READ)
	current_dialogue_line_number = 0
	
	# Potentially slow implementation. Profile for performance issues if ever slow
	while current_dialogue_line_number < dialogue_start_line_number - 1: # Positions cursor right above the starting line
		dialogue_file.get_csv_line()
		current_dialogue_line_number += 1
		
	start_dialogue()

func advance_dialogue() -> void:
	if not dialogue_ongoing:
		return

	var line = dialogue_file.get_csv_line()
	current_dialogue_line_number += 1
	
	if line[0] == 'x' or line[0] == 'X':
		end_dialogue()
		return
		
	var side = get_side(line)
	var dialogue = get_dialogue(line)
	var sprite = get_sprite(get_sprite_name(line))
	var set_dialogue: Callable
	
	if side == SIDE.LEFT:
		set_dialogue = dialogue_ui.set_left_dialogue
	else:
		set_dialogue = dialogue_ui.set_right_dialogue
		
	set_dialogue.call(sprite, dialogue)
	
func get_side(line: PackedStringArray) -> SIDE:
	if not line[0].is_empty():
		if line[0].split(':')[0] == 'L':
			last_side = SIDE.LEFT
		else:
			last_side = SIDE.RIGHT
		
	return last_side

func get_sprite_name(line: PackedStringArray) -> String:
	if line[0].is_empty():
		return last_sprite_name
		
	if '/' not in line[0]:
		last_sprite_name = line[0].split(':')[1]
		return last_sprite_name
		
	var possible_sprite_names = line[0].split(':')[1].split('/')
	for sprite_name: String in possible_sprite_names:
		if GameManager.is_alive(get_player_name_from_sprite_name(sprite_name)):
			last_sprite_name = sprite_name
			break
			
	return last_sprite_name

func get_dialogue(line: PackedStringArray) -> String:
	return line[1]
	
func get_sprite(name: String) -> Texture2D:
	if sprite_database.get_portrait(name) == null:
		printerr("Received null from portrait database! Verify that %s is a valid key in %s" % [name, sprite_database.resource_path])
		return null
	
	return sprite_database.get_portrait(name)

func get_player_name_from_sprite_name(sprite_name: String) -> String:
	return sprite_name.split('_')[0]
	
func start_dialogue() -> void:
	dialogue_ui.visible = true
	dialogue_ongoing = true
	get_tree().paused = true
	advance_dialogue()
	
func end_dialogue() -> void:
	dialogue_ui.visible = false
	dialogue_ongoing = false
	
	# If not done, the previous inactive portraits show up next dialogue
	# Doesn't seem to need enabling visibility in start_diaologue. Perhaps
	#	dialogue_ui.visible = true sets all its children to true as well 🤷‍♂️
	dialogue_ui.get_node("%Portrait1").visible = false
	dialogue_ui.get_node("%Portrait2").visible = false
	
	get_tree().paused = false
