extends Node

var menu_opened_this_press: bool = false

@export var main_scene: PackedScene
const SETTINGS_DIR = 'user://settings/'
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
		else: # All states that make the content panel visible go here
			%ContentPanel.modulate = Color(%ContentPanel.modulate.r, %ContentPanel.modulate.g, %ContentPanel.modulate.b, 1)
			hide_all_content_panels()
			%PanelsContainer.set_focus_behavior_recursive(Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_ENABLED)
			if value == states.PLAY:
				%PlayPanel.visible = true
				%SaveSlotsContainer.get_child(0).GRAB_BUTTON_FOCUS()
			if value == states.SETTINGS:
				%SettingsPanel.visible = true
				%FullScreenCheckBox.grab_focus()
			if value == states.CREDITS:
				%CreditsPanel.visible = true
		state = value
		
enum states { TITLE, MENU, PLAY, SETTINGS, CREDITS }

func _ready() -> void:
	load_settings()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	connect_save_slot_signals()
	MusicManager.fade_music_out(0.8)
	
func _on_title_music_delay_timer_timeout() -> void:
	MusicManager.play_music('title')

func _input(event: InputEvent) -> void:
	if event is not InputEventKey and event is not InputEventJoypadButton:
		return
		
	if state == states.TITLE:
		state = states.MENU
		menu_opened_this_press = true
	elif state == states.MENU:
		if event.is_action_released('ui_cancel') and not menu_opened_this_press:
			state = states.TITLE
		if menu_opened_this_press:
			menu_opened_this_press = false
		
func connect_save_slot_signals() -> void:
	for save_slot: SaveSlot in %SaveSlotsContainer.get_children():
		save_slot.load_game_button_pressed.connect(load_saved_game)
		save_slot.new_game_button_pressed.connect(load_new_game)
		
func load_new_game(save_slot_id: int) -> void:
	GameManager.catapace_pair_killed = false
	%TitleMusicDelayTimer.stop()
	MusicManager.fade_music_out(0.8)
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
	GameManager.route = save.route
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
		save_settings()

func _on_credits_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_other_buttons(%CreditsButton)
		state = states.CREDITS
	else:
		state = states.MENU
		
func hide_all_content_panels() -> void:
	for panel in %PanelsContainer.get_children():
		panel.visible = false
		# The following line is so that buttons inside PanelsContainer can't get focused after the panel
		# goes invisible
		%PanelsContainer.set_focus_behavior_recursive(Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_DISABLED)

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
func quick_switch_to_main(game_ended = false) -> void:
	if not game_ended:
		%Prompt.visible = false
		state = states.MENU
	else:
		%Prompt.modulate = Color(%Prompt.modulate, 0.0)
		%Prompt.visible = true
		%PromptAnimationPlayer.play('fade_in')
		await %PromptAnimationPlayer.animation_finished
		%PromptAnimationPlayer.play('blink')
	
func play_shroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate.r, %Shroud.modulate.g, %Shroud.modulate.b, 1), 0.4).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2).timeout

func _on_quit_button_button_down() -> void:
	get_tree().quit()

func _on_full_screen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_MAXIMIZED

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
func save_settings() -> void:
	var settings_path = SETTINGS_DIR + "/settings.tres"
	var saved_settings: Settings = ResourceLoader.load(settings_path)
	saved_settings.fullscreen = %FullScreenCheckBox.button_pressed
	saved_settings.music_level = %MusicVolumeSlider.value
	ResourceSaver.save(saved_settings, settings_path)
	
func load_settings() -> void:
	var settings_path = SETTINGS_DIR + "/settings.tres"
	var settings: Settings = null
	if ResourceLoader.exists(settings_path): 
		settings = ResourceLoader.load(settings_path)
		%FullScreenCheckBox.button_pressed = settings.fullscreen
		%MusicVolumeSlider.value = settings.music_level
	else: # First time opening game
		if not DirAccess.dir_exists_absolute(SETTINGS_DIR):
			DirAccess.make_dir_absolute(SETTINGS_DIR)
		
		settings = Settings.new(%FullScreenCheckBox.button_pressed, %MusicVolumeSlider.value)
		ResourceSaver.save(settings, settings_path)
	
	%FullScreenCheckBox.set_pressed_no_signal(settings.fullscreen)
	%MusicVolumeSlider.set_value_no_signal(settings.music_level)
	get_window().mode = Window.MODE_FULLSCREEN if settings.fullscreen else Window.MODE_MAXIMIZED
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.music_level))
