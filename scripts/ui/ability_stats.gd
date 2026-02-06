extends Control

@export var ability_name_format: String
@export var label_font_size: int
	
func set_stats(ability_name: String, items: Dictionary[String, String]) -> void:
	%AbillityNameLabel.set_text(ability_name_format % ability_name)
	
	clear_existing_stats()
	for item in items:
		var value = items[item]
		var key_label = Label.new()
		key_label.set_text(item)
		key_label.add_theme_font_size_override('font_size', label_font_size)
		%KeyContainer.add_child(key_label)
		var value_label = Label.new()
		value_label.set_text(': %s' % value)
		value_label.add_theme_font_size_override('font_size', label_font_size)
		%ValueContainer.add_child(value_label)
		
func clear_existing_stats() -> void:
	for label in %KeyContainer.get_children():
		label.queue_free()
	
	for label in %ValueContainer.get_children():
		label.queue_free()
