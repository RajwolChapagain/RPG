extends Button
class_name ItemButton

@export var stats_panel_offset: Vector2 = Vector2(60, 15)

@export var equippable_icon: Texture2D
@export var consumable_icon: Texture2D

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

@export var item_stats_panel_scene: PackedScene
var item_stats_panel: ItemStatsPanel

signal item_selected

func _ready() -> void:
	if item != null:
		%NameLabel.text = item.name
		%CountLabel.text = str(count)
		initialize_type_indicator()
	else:
		push_error("Uninitialized Item Button addded to scene")

func initialize(item: Item, count: int) -> void:
	self.item = item
	self.count = count

func _on_focus_entered() -> void:
	show_stats()

func _on_focus_exited() -> void:
	hide_stats()
	
func show_stats() -> void:
	if item_stats_panel == null:
		item_stats_panel = item_stats_panel_scene.instantiate()
		item_stats_panel.current_item = item
		item_stats_panel.global_position = global_position + stats_panel_offset
		add_child(item_stats_panel)
	else:
		item_stats_panel.global_position = global_position + stats_panel_offset
		item_stats_panel.visible = true
	
func hide_stats() -> void:
	item_stats_panel.visible = false

func get_item_name() -> String:
	return str(item)

func initialize_type_indicator() -> void:
	if item.type == Item.ItemType.EQUIPPABLE:
		%TypeIndicator.texture = equippable_icon
	else:
		%TypeIndicator.texture = consumable_icon
		
func _on_pressed() -> void:
	item_selected.emit(item)
