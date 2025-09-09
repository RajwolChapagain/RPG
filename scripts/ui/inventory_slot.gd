extends Button
class_name InventorySlot

var item: Item
var active: bool = false

signal item_slot_selected

func activate() -> void:
	active = true
	disabled = false
	
func equip_item(new_item: Item) -> Item:
	if not active:
		push_error('Tried to equip item to inactive slot')
		return null
		
	var old_item = item
	item = new_item
	update_item_info()
	return old_item
	
func update_item_info() -> void:
	text = item.name
	tooltip_text = item.get_stats_as_string()

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		item_slot_selected.emit(self)
