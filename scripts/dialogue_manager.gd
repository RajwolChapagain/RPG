extends Node

func load_dialogue(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		printerr("File %s does not exist!" % file_path)
		return
	
	var dialogue_file = FileAccess.open(file_path, FileAccess.READ)
