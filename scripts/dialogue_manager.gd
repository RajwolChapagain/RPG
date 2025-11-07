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
var wildcard: String = 'WILDCARD'
var current_invoking_entity = null
var last_dialogue_line = ''

signal dialogue_finished

func _ready() -> void:
	dialogue_ui = dialogue_ui_scene.instantiate()
	%CanvasLayer.add_child(dialogue_ui)
	dialogue_ui.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		advance_dialogue()
		
func load_dialogue(dialogue_file_path: String, dialogue_start_line_number: int = 1, invoking_entity=null) -> void:
	dialogue_file = FileAccess.open(dialogue_file_path, FileAccess.READ)
	current_invoking_entity = invoking_entity
	current_dialogue_line_number = 0
	
	# Potentially slow implementation. Profile for performance issues if ever slow
	while current_dialogue_line_number < dialogue_start_line_number - 1: # Positions cursor right above the starting line
		dialogue_file.get_csv_line()
		current_dialogue_line_number += 1
		
		
	start_dialogue()

func advance_dialogue() -> void:
	if not dialogue_ongoing:
		return

	if dialogue_ui.unraveling_line:
		dialogue_ui.set_dialogue_text(last_dialogue_line)
		return
		
	var line = dialogue_file.get_csv_line()
	current_dialogue_line_number += 1
	if line[0] == 'x' or line[0] == 'X':
		end_dialogue()
		return
	
	if not line[0].is_empty():
		if line[0][0] == ':':
			handle_function_call(line[0])
			advance_dialogue()
			return
		
	var side = get_side(line)
	var dialogue = get_dialogue(line)
	var sprite = get_sprite(get_sprite_name(line))
	var set_dialogue: Callable
	
	if side == SIDE.LEFT:
		set_dialogue = dialogue_ui.set_left_dialogue
	else:
		set_dialogue = dialogue_ui.set_right_dialogue
		
	last_dialogue_line = dialogue
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
	var out = line[1].replace('*', wildcard)
	return out
	
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
	dialogue_finished.emit()
	if current_invoking_entity != null:
		if current_invoking_entity.has_method('start_interaction_cooldown_timer'):
			current_invoking_entity.start_interaction_cooldown_timer()

# Expects: line to be a string starting with a : followed by a function name
func handle_function_call(line: String) -> void:
	var items = line.split(' ')
	
	for i in range(len(items) - 1, -1, -1):
		var item = items[i]
		if item.begins_with(':'): # If it is a function name
			var function_name = item.substr(1, len(item) - 1)
			var return_value = Callable(self, function_name).bindv(items.slice(i + 1, len(items))).call()
			if return_value != null: # This should only ever be null for the first function in the line
				items[i] = return_value
				
			while i < len(items) - 1:
				items.remove_at(len(items) - 1)
				
	
#region CSV-Callable Functions
func set_wildcard(new_wildcard: String) -> void:
	wildcard = new_wildcard
	
func get_random_dead_hero_name() -> String:
	var all_player_names = ['Rachelle', 'Magda', 'Josephine', 'Lachlan', 'Einar']
	return all_player_names.filter(func (player_name): return player_name not in GameManager.get_alive_players().map(func (player): return player.stats.name)).pick_random()
	
# line_number is String because we read everything as String from the CSV file
func if_dead_go_to(player_name: String, line_number: String) -> void:
	if player_name not in GameManager.get_alive_players().map(func(player): return player.stats.name):
		go_to(line_number)

# line_number is String because we read everything as String from the CSV file
func go_to(line_number: String) -> void:
	while current_dialogue_line_number < int(line_number) - 1: # Positions cursor right above the starting line
		dialogue_file.get_csv_line()
		current_dialogue_line_number += 1

func get_pause_button_as_string() -> String:
	return InputMap.action_get_events("pause")[0].as_text()
	
func set_next_interaction_line(line_number: String) -> void:
	assert(current_invoking_entity != null, "Tried to set next interaction line on a null invoking entity")
	current_invoking_entity.dialogue_start_line_number = int(line_number)

func drop_item(item_name: String) -> void:
	ItemDropManager.drop_item_by_name(item_name)
	
#endregion
