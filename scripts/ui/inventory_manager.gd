extends Panel

@export var ItemButtonScene: PackedScene
var item_buttons: Array[ItemButton]
var selected_item: Item

func _ready() -> void:
	add_item(Item.new())
	add_item(Item.new("My Item"), 2)
	add_item(Item.new("Custom Item", Item.ItemType.CONSUMABLE, [StatModifier.new('hp', '+', false, 20.0), StatModifier.new('atk', '-', true, 5.0)]))
	add_item(Item.new(), 3)
	populate_character_inventory()
	
func add_item(item: Item, count: int = 1) -> void:
	for button in item_buttons:
		if button.get_item_name() == str(item):
			button.set("count", button.count + count)
			return
	
	add_item_button(item, count)
	
func add_item_button(item: Item, count: int) -> void:
	var item_button = ItemButtonScene.instantiate()
	item_button.initialize(item, count)
	%ItemButtonsContainer.add_child(item_button)
	item_buttons.append(item_button)
	item_button.item_selected.connect(on_inventory_item_selected)
	
func on_inventory_item_selected(item: Item) -> void:
	print("Selected item %s" % item)
	selected_item = item

func populate_character_inventory() -> void:
	const MAX_CHARACTERS = 4
	var characters: Array[Player] = GameManager.get_alive_players()
	for i in range(MAX_CHARACTERS):
		if i < len(characters):
			%CharacterInventories.get_child(i).initialize_inventory(characters[i])
		else:
			%CharacterInventories.get_child(i).visible = false
		
