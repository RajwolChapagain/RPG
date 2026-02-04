extends Control

signal main_menu_button_pressed

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not get_tree().paused:
			pause_game()
		else:
			unpause_game()

func _on_continue_button_button_down() -> void:
	unpause_game()
	
func pause_game() -> void:
	visible = true
	get_tree().paused = true
	%ContinueButton.grab_focus()
	
func unpause_game() -> void:
	visible = false
	get_tree().paused = false

	untoggle_all_buttons()
	hide_all_content_panels()
		
	BattleManager.on_pause_menu_dropped_focus()
	
func initialize_inventory() -> void:
	%InventoryManager.populate_character_inventory()

func _on_visibility_changed() -> void:
	if visible:
		initialize_stats()
		
func initialize_stats() -> void:
	var i = 0
	for player: Player in GameManager.get_alive_players():
		%Stats.get_child(i).stats = player.get_modified_stats()
		i += 1
	
	for remaining in range(i, %Stats.get_child_count()): # Hide stat cards of dead players
		%Stats.get_child(remaining).visible = false
		
	%StatsPanel.visible = true

func get_inventory_items() -> Array[Item]:
	return %InventoryManager.get_items()

func _on_main_menu_button_pressed() -> void:
	unpause_game()
	main_menu_button_pressed.emit()

func _on_inventory_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_buttons()
		hide_all_content_panels()
		%InventoryButton.set_pressed_no_signal(true)
		%InventoryManager.visible = true
		%InventoryManager.GRAB_FIRST_ITEM_BUTTON_FOCUS()
	else:
		%InventoryManager.visible = false
		initialize_stats()

func _on_inventory_manager_inventory_focus_dropped() -> void:
	%InventoryButton.grab_focus()

func _on_ability_info_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		untoggle_all_buttons()
		hide_all_content_panels()
		%AbilityInfoButton.set_pressed_no_signal(true)
		%AbilityInfoPanel.visible = true
	else:
		%AbilityInfoPanel.visible = false
		initialize_stats()

func untoggle_all_buttons() -> void:
	for button: Button in %ButtonsContainer.get_children():
		button.button_pressed = false
	
func hide_all_content_panels() -> void:
	for panel: Panel in %ContentContainer.get_children():
		panel.visible = false
