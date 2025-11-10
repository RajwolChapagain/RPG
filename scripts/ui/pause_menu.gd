extends Control

signal main_menu_button_pressed

func _input(event: InputEvent) -> void:
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
	%InventoryManager.visible = false

func initialize_inventory() -> void:
	%InventoryManager.populate_character_inventory()

func _on_visibility_changed() -> void:
	if visible == true:
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
		%InventoryManager.visible = true
		%StatsPanel.visible = false
	else:
		%InventoryManager.visible = false
		%StatsPanel.visible = true
