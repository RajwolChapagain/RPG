extends Node

@export var main_scene: PackedScene

func load_new_game() -> void:
	var main = main_scene.instantiate()
	get_tree().root.add_child(main)
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
	queue_free()
	
func _on_play_button_pressed() -> void:
	load_saved_game(3)
