extends Node

@export var targets : Array
@export var target_indicator: Texture2D
@export var pointer_y_offset = 25
@export var active: bool = false
var current_callable: Callable

var selected: int = 0:
	get:
		return selected
	set(value):
		selected = value
		mark_selected(value)

#region Externally-called functions
func SET_TARGETS(new_targets) -> void:
	targets = new_targets

func ACTIVATE(post_selection_callable: Callable) -> void:
	assert(len(targets) != 0)
	active = true
	current_callable = post_selection_callable
	# Because we remember the last selected index for convenience, we need to
	# ensure that index is still within bounds as the target size may have
	# shrunk since last time due to deaths
	selected = clamp(selected, 0, len(targets) - 1)
	mark_selected(selected)

func IS_ACTIVE() -> bool:
	return active
#endregion

func _input(event: InputEvent) -> void:
	if not active:
		return
		
	if event.is_action_pressed("select_target"):
		current_callable.call(targets[selected])
		DEACTIVATE()
	
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

func DEACTIVATE() -> void:
	active = false
	%Pointer.visible = false
