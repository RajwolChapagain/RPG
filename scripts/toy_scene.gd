extends Node

func _ready() -> void:
	ItemDropManager.drop_random_items(0, 5)
