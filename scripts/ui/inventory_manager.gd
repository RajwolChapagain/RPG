extends Panel

@export var items: Dictionary[Item, int]
@export var ItemButtonScene: PackedScene
var item_buttons: Array[ItemButton]

func _ready() -> void:
	for key in items.keys():
		add_item_button(key, items[key])
		
	var my_item: Item = Item.new()
	my_item.name = 'hi'
	add_item(my_item, 2)
	var new_item: Item = Item.new()
	new_item.name = 'helo'
	add_item(new_item, 3)
	
	
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
