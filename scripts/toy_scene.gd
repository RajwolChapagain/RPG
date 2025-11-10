extends Node

func _ready() -> void:
	#ItemDropManager.drop_items([load("res://resources/items/doloris's_necklace.tres"), Item.new("Consumable", Item.ItemType.CONSUMABLE, [StatModifier.new("max_hp", "*", false, 2), StatModifier.new("attack_damage", '-', true, 50)])])
	%PauseMenu.initialize_inventory()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		GameManager.get_alive_players().pick_random().stats.hp = 0
		$Party.purge_dead_members()
