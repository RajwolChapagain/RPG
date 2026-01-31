extends Node

const SAVE_DIR = 'user://saves/'
var save_paths = [1, 2, 3].map(func(x): return SAVE_DIR + 'save' + str(x) + '.tres')

var saved_data: Array[SaveInfo] = [null, null, null]
var current_save_slot = 1

func _ready() -> void:
	for i in range(3):
		if ResourceLoader.exists(save_paths[i]):
			saved_data[i] = ResourceLoader.load(save_paths[i])
			
func save_to_current_slot(save: SaveInfo) -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)
		
	ResourceSaver.save(save, save_paths[current_save_slot - 1])
	saved_data[current_save_slot - 1] = save
	
func get_save(slot_id: int) -> SaveInfo:
	assert(saved_data[slot_id - 1] != null)
	return saved_data[slot_id - 1]
	
func slot_contains_data(slot_id: int) -> bool:
	return false if saved_data[slot_id - 1] == null else true

func delete_save(slot_id: int) -> void:
	saved_data[slot_id - 1] = null
	DirAccess.remove_absolute(save_paths[slot_id - 1])
