extends Node

@export var dialogue_ui_scene: PackedScene
@export var sprite_database: PortraitDatabase

enum SIDE { LEFT, RIGHT }
var dialogue_file = null
var last_side = SIDE.LEFT
var last_sprite_name = ""
var dialogue_ui = null
var dialogue_ongoing = false

func _ready() -> void:
	dialogue_ui = dialogue_ui_scene.instantiate()
	add_child(dialogue_ui)
	dialogue_ui.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		advance_dialogue()
		
func load_dialogue(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		printerr("File %s does not exist!" % file_path)
		return
	
	dialogue_file = FileAccess.open(file_path, FileAccess.READ)
	start_dialogue()

func advance_dialogue() -> void:
	if not dialogue_ongoing:
		return
		
	if dialogue_file == null:
		printerr("dialogue_file is null! Set dialogue_file to a valid value before invoking me.")
		return
		
	var line = dialogue_file.get_csv_line()
	
	if line.size() == 1:
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
	if not line[0].is_empty():
		last_sprite_name = line[0].split(':')[1]
		
	return last_sprite_name

func get_dialogue(line: PackedStringArray) -> String:
	return line[1]
	
func get_sprite(name: String) -> Texture2D:
	if sprite_database.get_portrait(name) == null:
		printerr("Received null from portrait database! Verify that %s is a valid key in %s" % [name, sprite_database.resource_path])
		return null
	
	return sprite_database.get_portrait(name)

func start_dialogue() -> void:
	dialogue_ui.visible = true
	dialogue_ongoing = true
	advance_dialogue()
	
func end_dialogue() -> void:
	dialogue_ui.visible = false
	dialogue_ongoing = false
