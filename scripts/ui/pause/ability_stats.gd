extends Control

@export var ability_name_format: String
@export var label_font_size: int
	
func set_stats(ability_name: String, items: Dictionary[String, String]) -> void:
	%AbillityNameLabel.set_text(ability_name_format % ability_name)
	
	clear_existing_stats()
	for item in items:
		var value = items[item]
		var key_label = Label.new()
		key_label.set_text('%s:' % item)
		key_label.add_theme_font_size_override('font_size', label_font_size)
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var value_label = Label.new()
		value_label.set_text(value)
		value_label.add_theme_font_size_override('font_size', label_font_size)
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var row = HBoxContainer.new()
		%StatsContainer.add_child(row)
		row.add_child(key_label)
		row.add_child(value_label)
		
func clear_existing_stats() -> void:
	for item in %StatsContainer.get_children():
		item.queue_free()
