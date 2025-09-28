extends Control

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

func _on_inventory_button_pressed() -> void:
	%InventoryManager.visible = true
	%StatsPanel.visible = false

func initialize_inventory() -> void:
	%InventoryManager.populate_character_inventory()

func _on_visibility_changed() -> void:
	if visible == true:
		initialize_stats()
		
func initialize_stats() -> void:
	var i = 0
	for player: Player in GameManager.get_alive_players():
		%Stats.get_child(i).stats = player.stats
		i += 1
	%StatsPanel.visible = true
