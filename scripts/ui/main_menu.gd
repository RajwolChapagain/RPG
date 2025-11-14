extends Node

@export var main_scene: PackedScene
var state: states = states.TITLE:
	get():
		return state
	set(value):
		if value == states.TITLE:
			%AnimationPlayer.play('slide_out')
			for button in %ButtonsContainer.get_children():
				button.release_focus()
		elif value == states.MENU:
			if state == states.TITLE:
				%AnimationPlayer.play('slide_in')
				%PromptAnimationPlayer.stop()
				%PromptAnimationPlayer.play('fade_out')
			else:
				%ContentPanel.modulate = Color(%ContentPanel.modulate.r, %ContentPanel.modulate.g, %ContentPanel.modulate.b, 0)
		elif value == states.PLAY:
			%ContentPanel.modulate = Color(%ContentPanel.modulate.r, %ContentPanel.modulate.g, %ContentPanel.modulate.b, 1)
			hide_all_content_panels()
			%PlayPanel.visible = true
		elif value == states.SETTINGS:
			%ContentPanel.modulate = Color(%ContentPanel.modulate.r, %ContentPanel.modulate.g, %ContentPanel.modulate.b, 1)
			hide_all_content_panels()
			%SettingsPanel.visible = true
		state = value
		
enum states { TITLE, MENU, PLAY, SETTINGS }

func _ready() -> void:
	connect_save_slot_signals()
	MusicManager.fade_music_out(0.8)
	await get_tree().create_timer(3.0).timeout
	MusicManager.play_music('title')

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
		
	if state == states.TITLE:
		state = states.MENU
	elif state == states.MENU:
		if event.is_action_released('ui_cancel'):
			state = states.TITLE
		
func connect_save_slot_signals() -> void:
	for save_slot: SaveSlot in %SaveSlotsContainer.get_children():
		save_slot.load_game_button_pressed.connect(load_saved_game)
		save_slot.new_game_button_pressed.connect(load_new_game)
		
func load_new_game(save_slot_id: int) -> void:
	await play_shroud_animation()
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
	main.activate_item_slots(5 - len(save.party_member_names))
	main.initialize_inventory(save.inventory_items)
	main.initialize_equipped_items(save.equipped_items)
	SaveManager.current_save_slot = saved_slot_id
	queue_free()

func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_other_buttons(%PlayButton)
		state = states.PLAY
	else:
		state = states.MENU

func _on_settings_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_other_buttons(%SettingsButton)
		state = states.SETTINGS
	else:
		state = states.MENU

func hide_all_content_panels() -> void:
	for panel in %PanelsContainer.get_children():
		panel.visible = false

func untoggle_all_other_buttons(calling_button: Button) -> void:
	for button: Button in %ButtonsContainer.get_children():
		if button == calling_button:
			continue
			
		button.button_pressed = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'slide_in':
		%PlayButton.grab_focus()
	elif anim_name == 'slide_out':
		%PromptAnimationPlayer.play('blink')
		
# Intended to be called only by main when coming from pause menu
func quick_switch_to_main() -> void:
	%Prompt.visible = false
	state = states.MENU
	
func play_shroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate.r, %Shroud.modulate.g, %Shroud.modulate.b, 1), 0.4).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2).timeout
