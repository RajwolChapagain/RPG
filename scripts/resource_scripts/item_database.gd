class_name ItemDatabase
extends Resource

@export var item_dictionary: Dictionary[String, Item]

func get_item(item_name: String):
	if not item_dictionary.has(item_name):
		printerr("Could not find item nameed %s in item database!" % item_name)
		return null
		
	return item_dictionary[item_name]

func has_item(item_name: String) -> bool:
	return item_dictionary.has(item_name)
