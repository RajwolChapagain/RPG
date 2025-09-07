extends Panel

@export var items: Dictionary[Item, int]
@export var ItemButtonScene: PackedScene
var item_buttons: Array[ItemButton]

func _ready() -> void:
	for key in items.keys():
		add_item_button(key, items[key])
		
	add_item(Item.new(), 1)
	add_item(Item.new('ds', Item.ItemType.CONSUMABLE, [StatModifier.new()]), 2)
	
	
func add_item(item: Item, count: int) -> void:
	for key in items.keys():
		if str(key) == str(item):
			items[key] += count
			update_item_button_count(item, items[key])
			return
	
	items[item] = count
	add_item_button(item, count)
	
func add_item_button(item: Item, count: int) -> void:
	var item_button = ItemButtonScene.instantiate()
	item_button.initialize(item, count)
	%ItemButtonsContainer.add_child(item_button)
	item_buttons.append(item_button)
	
func update_item_button_count(item: Item, new_count: int) -> void:
	for button in item_buttons:
		if button.get_item_name() == str(item):
			button.set("count", new_count)
