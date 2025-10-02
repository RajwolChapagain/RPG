extends Node

var saved_data: Array[SaveInfo] = [null, null, preload("res://resources/saves/dummy_save.tres")]

func save_to_slot(slot_id: int) -> void:
	pass
	
func get_save(slot_id: int) -> SaveInfo:
	assert(saved_data[slot_id - 1] != null)
	return saved_data[slot_id - 1]
	
func slot_contains_data(slot_id: int) -> bool:
	return false if saved_data[slot_id - 1] == null else true
