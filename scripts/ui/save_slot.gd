class_name SaveSlot
extends Control

const SLOT_ID_LABEL_TEMPLATE: String = 'Slot %s'
@export var save_slot_id: int = 1

func _ready() -> void:
	initialize_slot_id_label()
	initialize_buttons()
	
func initialize_slot_id_label() -> void:
	if save_slot_id == 1:
		%SlotIDLabel.text = SLOT_ID_LABEL_TEMPLATE % 'I'
	elif save_slot_id == 2:
		%SlotIDLabel.text = SLOT_ID_LABEL_TEMPLATE % 'II'
	elif save_slot_id == 3:
		%SlotIDLabel.text = SLOT_ID_LABEL_TEMPLATE % 'III'
	else:
		push_error('Error: Save slot ID out of bounds')

func initialize_buttons() -> void:
	if SaveManager.slot_contains_data(save_slot_id):
		%SavedItems.visible = true
		# show_saved_info()
	else:
		%UnsavedItems.visible = true
