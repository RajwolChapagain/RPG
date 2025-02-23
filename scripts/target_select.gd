extends Node

@export var targets : Array
@export var target_indicator: Texture2D
@export var pointer_y_offset = 25
@export var active: bool = false

var selected: int = 0:
	get:
		return selected
	set(value):
		selected = value
		mark_selected(value)

signal target_selected(target_index)
	
func _input(event: InputEvent) -> void:
	if not active:
		return
		
	if event.is_action_pressed("select_target"):
		target_selected.emit(selected)
	
	if event.is_action_pressed("select_next"):
		select_next()
	
	if event.is_action_pressed("select_previous"):
		select_previous()
	
func select_next() -> void:
	selected = (selected + 1) % len(targets)

func select_previous() -> void:
	selected = (selected - 1) % len(targets)

func mark_selected(index) -> void:
	%Pointer.position.x = targets[index].position.x
	%Pointer.position.y = targets[index].position.y - pointer_y_offset
	%Pointer.visible = true

func set_targets(new_targets) -> void:
	targets = new_targets

func activate() -> void:
	assert(len(targets) != 0)
	active = true
	mark_selected(selected)
	
func deactivate() -> void:
	targets.clear()
	active = false
	%Pointer.visible = false
	
