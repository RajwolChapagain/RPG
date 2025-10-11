extends Node

@export var main_scene: PackedScene
var state: states = states.TITLE:
	get():
		return state
	set(value):
		if value == states.TITLE:
			hide_all_content_panels()
		elif value == states.PLAY:
			%ContentPanel.visible = true
			hide_all_content_panels()
			%PlayPanel.visible = true
		elif value == states.SETTINGS:
			%ContentPanel.visible = true
			hide_all_content_panels()
			%SettingsPanel.visible = true
		state = value
		
enum states { TITLE, PLAY, SETTINGS }

func _ready() -> void:
	connect_save_slot_signals()
	%PlayButton.grab_focus()
	
func connect_save_slot_signals() -> void:
	for save_slot: SaveSlot in %PlayPanel.get_children():
		save_slot.load_game_button_pressed.connect(load_saved_game)
		save_slot.new_game_button_pressed.connect(load_new_game)
		
func load_new_game(save_slot_id: int) -> void:
	var main = main_scene.instantiate()
	get_tree().root.add_child(main)
	SaveManager.current_save_slot = save_slot_id
	queue_free()

func load_saved_game(saved_slot_id: int) -> void:
	var save: SaveInfo = SaveManager.get_save(saved_slot_id)
	var main = main_scene.instantiate()
	main.current_level_number = save.level_number
	get_tree().root.add_child(main)
	main.initialize_party(save.party_member_names)
	main.initialize_character_stats(save.character_stats)
	main.initialize_inventory(save.inventory_items)
	main.initialize_equipped_items(save.equipped_items)
	SaveManager.current_save_slot = saved_slot_id
	queue_free()

func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_other_buttons(%PlayButton)
		state = states.PLAY
	else:
		state = states.TITLE

func _on_settings_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_other_buttons(%SettingsButton)
		state = states.SETTINGS
	else:
		state = states.TITLE

func hide_all_content_panels() -> void:
	for panel in %ContentPanel.get_children():
		panel.visible = false

func untoggle_all_other_buttons(calling_button: Button) -> void:
	for button: Button in %ButtonsContainer.get_children():
		if button == calling_button:
			continue
			
		button.button_pressed = false
