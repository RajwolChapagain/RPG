extends Control

static var activated_slots = 1
const MAX_SLOTS = 4
var equipped_items: Array[Item]

signal character_item_slot_selected

func _ready() -> void:
	for i in range(MAX_SLOTS):
		if i < activated_slots:
			%SlotContainer.get_child(i).activate(i)
			%SlotContainer.get_child(i).item_slot_selected.connect(on_item_slot_selected)

func initialize_inventory(character: Player) -> void:
	%Portrait.texture = character.stats.battle_sprite
	%CharacterNameLabel.text = character.stats.name
	
	for i in range(len(character.equipped_items)):
		equip_item_to_slot(character.equipped_items[i], i)
		
	equipped_items = character.equipped_items
	
func activate_new_slot() -> void:
	if activated_slots >= MAX_SLOTS:
		push_error('Error: Max number of inventory slots already activated for character %s' % %CharacterNameLabel.text)
		return
		
	%SlotContainer.get_child(activated_slots).activate()
	activated_slots += 1

func equip_item_to_slot(item: Item, index: int) -> Item:
	return %SlotContainer.get_child(index).equip_item(item)

func grab_focus_to_first_slot() -> void:
	%SlotContainer.get_child(0).grab_focus()
	
func on_item_slot_selected(index: int) -> void:
	character_item_slot_selected.emit(self, index)
