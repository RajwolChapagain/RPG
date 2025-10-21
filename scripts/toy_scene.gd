extends Node

func _ready() -> void:
	ItemDropManager.drop_items([Item.new("Consumable Item", Item.ItemType.CONSUMABLE)])
	ItemDropManager.drop_random_items(0, 2)
	%PauseMenu.initialize_inventory()
