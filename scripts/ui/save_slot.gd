class_name SaveSlot
extends Control

const SLOT_ID_LABEL_TEMPLATE: String = 'Slot %s'
@export var save_slot_id: int = 1

signal new_game_button_pressed(save_slot_id)
signal load_game_button_pressed(save_slot_id)

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
		%UnsavedItems.visible = false
		%SavedItems.visible = true
		# show_saved_info()
	else:
		%SavedItems.visible = false
		%UnsavedItems.visible = true

func _on_new_button_pressed() -> void:
	new_game_button_pressed.emit(save_slot_id)
	
func _on_load_button_pressed() -> void:
	load_game_button_pressed.emit(save_slot_id)
	
func _on_delete_button_pressed() -> void:
	SaveManager.delete_save(save_slot_id)
	initialize_buttons()
