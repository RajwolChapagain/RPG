extends CharacterBody2D

const SPEED: int = 1
const GRID_SIZE: int = 32
var grid_pos = Vector2(0, 0)
var is_moving = false
var is_active = false
var last_grid_pos = grid_pos
var next_character = null
	
signal character_moved(character, old_grid_pos)

func _ready() -> void:
	grid_pos.x = 0

func _process(_delta: float) -> void:
	take_input()
	
	if position != grid_pos * GRID_SIZE:
		update_position()
	else:
		if is_moving:
			is_moving = false
			character_moved.emit(self, last_grid_pos)
			last_grid_pos = grid_pos

func take_input() -> void:
	if is_moving:
		return

	if not is_active:
		return
		
	if Input.is_action_pressed("move_right"):
		set_grid_pos(Vector2(grid_pos.x + 1, grid_pos.y))
	elif Input.is_action_pressed("move_up"):
		set_grid_pos(Vector2(grid_pos.x, grid_pos.y - 1))
	elif Input.is_action_pressed("move_left"):
		set_grid_pos(Vector2(grid_pos.x - 1, grid_pos.y))
	elif Input.is_action_pressed("move_down"):
		set_grid_pos(Vector2(grid_pos.x, grid_pos.y + 1))
	
# Updates the position to reflect the position in grid_pos
func update_position() -> void:
	var direction: Vector2 = position.direction_to(grid_pos * GRID_SIZE)
	is_moving = true
	velocity = direction * SPEED
	move_and_collide(velocity)

func set_active(value: bool) -> void:
	is_active = value
	
	if is_active:
		$Pointer.visible = true
	else:
		$Pointer.visible = false
		

func set_grid_pos(pos: Vector2):
	grid_pos = pos
