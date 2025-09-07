extends Button

@export var item: Item
@export var count: int:
	get:
		return count
	set(value):
		if value < 0:
			printerr("Error: Attempted to set a negative value to item count")
		else:
			count = value

signal item_selected

func _ready() -> void:
	if item != null:
		%NameLabel.text = item.name
		%CountLabel.text = str(count)
		initialize_stat_label()
		
func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		item_selected.emit(item)

func _on_focus_entered() -> void:
	show_stats()

func _on_focus_exited() -> void:
	hide_stats()
	
func show_stats() -> void:
	%StatLabel.visible = true
	
func hide_stats() -> void:
	%StatLabel.visible = false

func initialize_stat_label() -> void:
	var out = ''
	var num_stats = len(item.stats)
	for i in range(num_stats):
		var stat_modifier: StatModifier = item.stats[i]
		out += stat_modifier.modification
		out += str(stat_modifier.amount)
		if stat_modifier.percentage:
			out += '%'
		out += ' %s' % stat_modifier.stat_name
		if i != num_stats - 1:
			out += ' | '
	%StatLabel.text = out
