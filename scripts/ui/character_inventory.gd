extends Control

var activated_slots = 1
const MAX_SLOTS = 4

func _ready() -> void:
	for i in range(MAX_SLOTS):
		if i < activated_slots:
			%SlotContainer.get_child(i).activate()

func initialize(character_name: String, portrait: Texture2D) -> void:
	%Portrait.texture = portrait
	%CharacterNameLabel.text = character_name
	
func activate_new_slot() -> void:
	if activated_slots >= MAX_SLOTS:
		push_error('Error: Max number of inventory slots already activated for character %s' % %CharacterNameLabel.text)
		return
		
	%SlotContainer.get_child(activated_slots).activate()
	activated_slots += 1

func equip_item_to_slot(item: Item, index: int) -> Item:
	return %SlotContainer.get_child(index).equip_item(item)
