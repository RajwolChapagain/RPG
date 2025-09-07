extends Button
class_name ItemButton

@export var item: Item
@export var count: int:
	get:
		return count
	set(value):
		if value < 0:
			printerr("Error: Attempted to set a negative value to item count")
		else:
			count = value
			%CountLabel.text = str(count)

@onready var stat_text_height: float = 20
@onready var original_size = size

signal item_selected

func _ready() -> void:
	if item != null:
		%NameLabel.text = item.name
		%CountLabel.text = str(count)
		initialize_stat_label()
	else:
		push_error("Uninitialized Item Button addded to scene")

func initialize(item: Item, count: int) -> void:
	self.item = item
	self.count = count
	
func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		item_selected.emit(item)

func _on_focus_entered() -> void:
	show_stats()

func _on_focus_exited() -> void:
	hide_stats()
	
func show_stats() -> void:
	%StatLabel.visible = true
	set_custom_minimum_size(Vector2(get_minimum_size().x, get_minimum_size().y + stat_text_height))
	
func hide_stats() -> void:
	%StatLabel.visible = false
	set_custom_minimum_size(Vector2(original_size.x, original_size.y))

func get_item_name() -> String:
	return str(item)
	
func initialize_stat_label() -> void:
	%StatLabel.text = item.get_stats_as_string()
