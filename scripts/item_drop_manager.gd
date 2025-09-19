extends Node

@export var common_items: Array[Item]
@export var uncommon_items: Array[Item]
@export var rare_items: Array[Item]
@export var legendary_items: Array[Item]
@export var mythical_items: Array[Item]
	
func drop_items(items: Array[Item]) -> void:
	GameManager.add_items_to_inventory(items)
	display_items(items)
	
func drop_random_items(rarity_modifier: float = 0.0, item_count: int = 1) -> void:
	var items: Array[Item] = []
	for i in range(item_count):
		var random_number = randf_range(0.0, 100.0) + rarity_modifier
		if random_number < 55.0:
			items.append(common_items.pick_random())
		elif random_number < 85.0:
			items.append(uncommon_items.pick_random())
		elif random_number < 97.0:
			items.append(rare_items.pick_random())
		elif random_number < 99.5:
			items.append(legendary_items.pick_random())
		else:
			items.append(mythical_items.pick_random())
			
	drop_items(items)

func display_items(items: Array[Item]) -> void:
	for i in range(len(items)):
		var item_label = Label.new()
		item_label.text = items[i].name
		%ItemsContainer.add_child(item_label)
	%ItemDropPanel.visible = true
	%ItemDropPanel.grab_focus()
	
func _on_confirm_button_pressed() -> void:
	%ItemDropPanel.visible = false
	while %ItemsContainer.get_child_count() != 0:
		%ItemsContainer.remove_child(%ItemsContainer.get_child(0))
