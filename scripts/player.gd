extends Area2D
class_name Player

@export var stats: BaseStats
var is_active = true
var grid_pos
var last_grid_pos = grid_pos
var next_character = null
var move_queue = []
var equipped_items: Array[Item]
	
signal character_moved(character, old_grid_pos)

func _process(_delta: float) -> void:
	take_input()
	process_movement_queue()
	check_and_emit_last_pos()
	
func take_input() -> void:
	if $GridMover.is_moving:
		return

	if not is_active:
		return
		
	if Input.is_action_pressed("move_right"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.RIGHT)
	elif Input.is_action_pressed("move_up"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.UP)
	elif Input.is_action_pressed("move_left"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.LEFT)
	elif Input.is_action_pressed("move_down"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.DOWN)

func process_movement_queue() -> void:
	if $GridMover.is_moving:
		return
		
	if move_queue.is_empty():
		return
		
	var next_grid_pos = move_queue.front()
	move_queue.remove_at(0)
	if (next_grid_pos == null):
		return
		
	if (next_grid_pos == $GridPositionTracker.get_grid_coord()):
		return
		
	var direction = next_grid_pos - $GridPositionTracker.get_grid_coord()
	
	if direction == Vector2i.RIGHT:
		$GridMover.move_target_right()
		$Sprite2D.play("run_right")
	elif direction == Vector2i.UP:
		$GridMover.move_target_up()
		$Sprite2D.play("run_up")
	elif direction == Vector2i.LEFT:
		$GridMover.move_target_left()
		$Sprite2D.play("run_left")
	elif direction == Vector2i.DOWN:
		$GridMover.move_target_down()
		$Sprite2D.play("run_down")
	else:
		print("Weird direction encountered. Cannot move:")
		print("Current grid pos: ", $GridPositionTracker.get_grid_coord(), " | Next grid pos: ", next_grid_pos)

func check_and_emit_last_pos() -> void:
	if last_grid_pos != $GridPositionTracker.get_grid_coord():
		character_moved.emit(self, last_grid_pos)
		last_grid_pos = $GridPositionTracker.get_grid_coord()
		
func set_active(value: bool) -> void:
	is_active = value
	
	if is_active:
		$Pointer.visible = true
	else:
		$Pointer.visible = false

func get_modified_stats() -> BaseStats:
	var modification_amount: BaseStats = get_modification_amount()
	var modified_stats = BaseStats.new()
	modified_stats.name = stats.name
	modified_stats.battle_sprite = stats.battle_sprite
	modified_stats.attack_damage = stats.attack_damage + modification_amount.attack_damage
	modified_stats.max_hp = stats.max_hp + modification_amount.max_hp
	modified_stats.hp = stats.hp + modification_amount.hp
	modified_stats.crit = stats.crit + modification_amount.crit
	modified_stats.accuracy = stats.accuracy + modification_amount.accuracy
	modified_stats.dodge = stats.dodge + modification_amount.dodge
	modified_stats.defence = stats.defence + modification_amount.defence
	modified_stats.abilities.append_array(stats.abilities)
	modified_stats.abilities.append_array(modification_amount.abilities)
	return modified_stats
	
func get_modification_amount() -> BaseStats:
	var modification_amount = BaseStats.new()
	modification_amount.attack_damage = 0
	modification_amount.max_hp = 0
	modification_amount.hp = 0
	
	for item: Item in equipped_items:
		for stat_modifier: StatModifier in item.stats:
			modify_stats(modification_amount, stat_modifier)
		
		for ability: PackedScene in item.abilities:
			modification_amount.abilities.append(ability)
	
	return modification_amount

func consume_item(item: Item) -> void:
	stats.abilities.append_array(item.abilities)
	
	for stat_modifier: StatModifier in item.stats:
		modify_stats(stats, stat_modifier)
		
func modify_stats(stats: BaseStats, stat_modifier: StatModifier) -> void:
	var stat_name: String = stat_modifier.stat_name
	var new_amount = 0
	if stat_modifier.modification == '+':
		if not stat_modifier.percentage:
			new_amount = stats.get(stat_name) + stat_modifier.amount
		else:
			new_amount = stats.get(stat_name) + int(stat_modifier.amount / 100 * stats.get(stat_name))
	elif stat_modifier.modification == '-':
		if not stat_modifier.percentage:
			new_amount = stats.get(stat_name) - stat_modifier.amount
		else:
			new_amount = stats.get(stat_name) - int(stat_modifier.amount / 100 * stats.get(stat_name))
	elif stat_modifier.modification == '*':
		if not stat_modifier.percentage:
			new_amount = stats.get(stat_name) * stat_modifier.amount
		else:
			new_amount = stats.get(stat_name) * int(stat_modifier.amount / 100 * stats.get(stat_name))
	elif stat_modifier.modification == '/':
		if not stat_modifier.percentage:
			new_amount = stats.get(stat_name) / stat_modifier.amount
		else:
			new_amount = stats.get(stat_name) / int(stat_modifier.amount / 100 * stats.get(stat_name))
	stats.set(stat_name, new_amount)
