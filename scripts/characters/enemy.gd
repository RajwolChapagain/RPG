extends Area2D
class_name Enemy

@export var gang: Array[BaseStats]
@export var dropped_items: Array[Item] # Used by battle_manager before queuing this enemy for death
@export var random_drop_item_count: int = 1 # Used by battle_manager before queuing this enemy for death
@export_range(0, 100, 1) var random_dropped_item_rarity_modifier: float = 0 # Used by battle_manager before queuing this enemy for death
@export var post_defeat_hook: String
var last_position

@warning_ignore("unused_signal")
signal enemy_defeated # Emitted by BattleManager at end of battle

func _ready() -> void:
	last_position = position
	
func _process(_delta: float) -> void:
	var movement = position - last_position
	
	# Ignore tiny movement (prevents jitter)
	if movement.length() < 0.1 or get_node_or_null("Patroller") == null:
		return
	
	if abs(movement.x) > abs(movement.y):
		# Horizontal dominant
		if movement.x > 0:
			if %Sprite2D.animation != 'move_right':
				PLAY_ANIMATION('move_right')
		else:
			if %Sprite2D.animation != 'move_left':
				PLAY_ANIMATION('move_left')
	else:
		# Vertical dominant
		if movement.y > 0:
			if %Sprite2D.animation != 'move_down':
				PLAY_ANIMATION('move_down')
		else:
			if %Sprite2D.animation != 'move_up':
				PLAY_ANIMATION('move_up')
	
	last_position = global_position
	
func get_gang() -> Array[BaseStats]:
	return gang

func turn_to_pulp() -> void:
	%Sprite2D.visible = false
	%PulpSprite.frame = randi_range(0, 3)
	%CollisionShape2D.disabled = true
	%PulpSprite.visible = true

func STOP_PATROL() -> void:
	for child in get_children():
		if child is Patroller:
			child.STOP_PATROL()

func START_PATROL() -> void:
	for child in get_children():
		if child is Patroller:
			child.START_PATROL()

func PLAY_ANIMATION(animation_name: String) -> void:
	assert(animation_name in %Sprite2D.sprite_frames.get_animation_names())
	%Sprite2D.play(animation_name)
	await %Sprite2D.animation_finished
	
func GET_ANIMATED_SPRITE() -> AnimatedSprite2D:
	return %Sprite2D
