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
