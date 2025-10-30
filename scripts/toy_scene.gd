extends Node

func _ready() -> void:
	ItemDropManager.drop_items([load("res://resources/items/doloris's_necklace.tres"), Item.new("Consumable", Item.ItemType.CONSUMABLE, [StatModifier.new("max_hp", "*", false, 2), StatModifier.new("attack_damage", '-', true, 50)])])
	%PauseMenu.initialize_inventory()
