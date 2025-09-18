extends Panel

@export var ItemButtonScene: PackedScene
var item_buttons: Array[ItemButton]
var selected_item: Item
var selected_character_inventory
var selected_character_inventory_index

func _ready() -> void:
	add_item(Item.new("Potion of Healing", Item.ItemType.CONSUMABLE, [StatModifier.new('max_hp', '+', true, 20)]))
	
	populate_character_inventory()
	initialize_character_inventory_signals()
	GameManager.set_inventory_manager(self)
	
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
	if selected_item.type == Item.ItemType.CONSUMABLE:
		for character_inventory: CharacterInventory in %CharacterInventories.get_children():
			character_inventory.enable_consume_button()
		%CharacterInventories.get_child(0).grab_focus_to_consume_button()
	else:
		%CharacterInventories.get_child(0).grab_focus_to_first_slot()

func populate_character_inventory() -> void:
	const MAX_CHARACTERS = 4
	var characters: Array[Player] = GameManager.get_alive_players()
	for i in range(MAX_CHARACTERS):
		if i < len(characters):
			%CharacterInventories.get_child(i).initialize_inventory(characters[i])
		else:
			%CharacterInventories.get_child(i).visible = false
		
func initialize_character_inventory_signals() -> void:
	for child in %CharacterInventories.get_children():
		child.character_item_slot_selected.connect(on_character_item_slot_selected)
		child.consume_button_pressed.connect(on_consume_button_pressed)
		
func on_character_item_slot_selected(character_inventory, index: int) -> void:
	if selected_item != null:
		var old_item = character_inventory.equip_item_to_slot(selected_item, index)
		if old_item != null:
			add_item(old_item)
		remove_item(selected_item)
		selected_item = null
	else:
		if character_inventory.get_item_at_slot(index) == null or str(character_inventory.get_item_at_slot(index)) == '':
			return
			
		selected_character_inventory = character_inventory
		selected_character_inventory_index = index
		%DiscardButton.visible = true
		for button in item_buttons:
			button.focus_mode = Control.FOCUS_NONE
		
func remove_item(item: Item) -> void:
	var i = 0
	for button in item_buttons:
		if button.get_item_name() == str(item):
			var new_count = button.count - 1
			if new_count == 0:
				remove_button(button, i)
			else:
				button.set("count", new_count)
			
			return
		i += 1
func remove_button(button: ItemButton, index: int) -> void:
	button.item = null
	item_buttons.remove_at(index)
	%ItemButtonsContainer.remove_child(button)

func _on_discard_button_pressed() -> void:
	var item = selected_character_inventory.get_item_at_slot(selected_character_inventory_index)
	add_item(item)
	selected_character_inventory.remove_item_at_index(selected_character_inventory_index)
	%DiscardButton.visible = false
	for button in item_buttons:
		button.focus_mode = Control.FOCUS_ALL
	focus_item_button(item)
		
func on_consume_button_pressed(character_name: String) -> void:
	GameManager.make_player_consume_item(character_name, selected_item)
	remove_item(selected_item)
	selected_item = null
	for character_inventory: CharacterInventory in %CharacterInventories.get_children():
		character_inventory.disable_consume_button()
	
func focus_item_button(item: Item) -> void:
	for button in item_buttons:
		if button.get_item_name() == str(item):
			button.grab_focus()
			return

func increase_slots() -> void:
	for character_inventory in %CharacterInventories.get_children():
		character_inventory.activate_new_slot()

func remove_character_inventory(player_name: String) -> void:
	for character_inventory: CharacterInventory in %CharacterInventories.get_children():
		if character_inventory.get_character_name() == player_name:
			character_inventory.visible = false
