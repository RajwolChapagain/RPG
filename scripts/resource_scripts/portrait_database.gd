extends Resource
class_name PortraitDatabase

@export var sprite_dictionary: Dictionary

func get_portrait(name: String):
	if not sprite_dictionary.has(name):
		printerr("Could not find portrait nameed %s in portrait database!" % name)
		return null
		
	return sprite_dictionary[name]
