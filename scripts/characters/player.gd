class_name Player extends Area2D

@export var stats: BaseStats
var is_active = true
var grid_pos
var last_grid_pos = grid_pos
var next_character = null
var move_queue = []
var equipped_items: Array[Item]
const OBSTACLE_RAYCAST_LENGTH: float = 32.0

signal character_moved(character, old_grid_pos)
signal enemy_encountered(enemy)

func _process(_delta: float) -> void:
	if not is_colliding():
		take_input()
	process_movement_queue()
	check_and_emit_last_pos()

func is_colliding() -> bool:
	if Input.is_action_pressed("move_right"):
		%ObstacleRayCast.target_position = Vector2(OBSTACLE_RAYCAST_LENGTH, 0)
	elif Input.is_action_pressed("move_up"):
		%ObstacleRayCast.target_position = Vector2(0, -OBSTACLE_RAYCAST_LENGTH)
	elif Input.is_action_pressed("move_left"):
		%ObstacleRayCast.target_position = Vector2(-OBSTACLE_RAYCAST_LENGTH, 0)
	elif Input.is_action_pressed("move_down"):
		%ObstacleRayCast.target_position = Vector2(0, OBSTACLE_RAYCAST_LENGTH)
		
	%ObstacleRayCast.force_raycast_update()
	if %ObstacleRayCast.is_colliding():
		return true
	else:
		return false
		
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
		# Direction is not in the next tile
		pass

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
	
	for property_name in get_constant_stat_properties():
		modified_stats.set(property_name, stats.get(property_name))
	
	for property_name in get_modifiable_stat_properties():
		modified_stats.set(property_name, stats.get(property_name) + modification_amount.get(property_name))
	
	return modified_stats
	
func get_modification_amount() -> BaseStats:
	var modification_amount = BaseStats.new()
	
	for property_name in get_modifiable_stat_properties():
		if modification_amount.get(property_name) is int: # Will cause bug if float properties are added to
														  # base_stats that need to be set to 0 as well
			modification_amount.set(property_name, 0)
	
	for item: Item in equipped_items:
		for stat_modifier: StatModifier in item.stats:
			var stat_name: String = stat_modifier.stat_name
			var new_amount = 0
			if stat_modifier.modification == '+':
				if not stat_modifier.percentage:
					new_amount = modification_amount.get(stat_name) + stat_modifier.amount
				else:
					new_amount = modification_amount.get(stat_name) + int(stat_modifier.amount / 100 * stats.get(stat_name))
			elif stat_modifier.modification == '-':
				if not stat_modifier.percentage:
					new_amount = modification_amount.get(stat_name) - stat_modifier.amount
				else:
					new_amount = modification_amount.get(stat_name) - int(stat_modifier.amount / 100 * stats.get(stat_name))
			elif stat_modifier.modification == '*':
				if not stat_modifier.percentage:
					new_amount = modification_amount.get(stat_name) + stats.get(stat_name) * (stat_modifier.amount - 1) # Multiplied by n-1 because this is not the final modified amount but the amount to be added to the base
				else:
					# Again, we subtract by the initial stat value because we'll add this again in the caller get_modified_stats
					# Ex: If stats.get(stat_name) = 100, stat_modifier.amount = 10, then
					# 		new_amount = 0 + ( int(10 / 100 * 100) * 100 - 100)
					#		new_amount = 0 + ( 10 * 100 - 100)
					#		new_amount = 0 + 900
					new_amount = modification_amount.get(stat_name) + (int(stat_modifier.amount / 100 * stats.get(stat_name)) * stats.get(stat_name) - stats.get(stat_name))
			elif stat_modifier.modification == '/':
				if not stat_modifier.percentage:
					# Ex: If stats.get(stat_name) = 100, stat_modifier.amount = 4, then
					# 		new_amount = 0 - (100 - (100 / 4))
					# 		new_amount = 0 - (100 - (100 / 4))
					# 		new_amount = 0 - (100 - 25)
					#		new_amount = 0 - 75
					#		new_amount = -75
					new_amount = modification_amount.get(stat_name) - (stats.get(stat_name) -  (stats.get(stat_name) / stat_modifier.amount) )
				else:
					# Here, we take an example of when we want to divide a stat by 10% of 100
					# Ex: If stats.get(stat_name) = 100, stat_modifier.amount = 10, then
					# 			new_amount = 0 - ( 100 - ( 100 / int(10 / 100 * 100)) )
					# 			new_amount = 0 - ( 100 - ( 100 / 10) )
					# 			new_amount = 0 - ( 100 - 10 )
					# 			new_amount = 0 - 90
					#			new_amount = -90
					new_amount = modification_amount.get(stat_name) - ( stats.get(stat_name) - (stats.get(stat_name) / int(stat_modifier.amount / 100 * stats.get(stat_name))) ) 
					
			modification_amount.set(stat_name, new_amount)
			
		for ability: PackedScene in item.abilities:
			modification_amount.abilities.append(ability)
	
	return modification_amount

func consume_item(item: Item) -> void:
	stats.abilities.append_array(item.abilities)
	
	for stat_modifier: StatModifier in item.stats:
		modify_base_stats(stat_modifier)
		
func modify_base_stats(stat_modifier: StatModifier) -> void:
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

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemy'):
		enemy_encountered.emit(area)

func get_constant_stat_properties() -> Array[String]:
	return get_stat_properties_in_group('constant')

func get_modifiable_stat_properties() -> Array[String]:
	return get_stat_properties_in_group('modifiable')
	
func get_stat_properties_in_group(group_name: String) -> Array[String]:
	var current_group = ''
	var out: Array[String] = []
	
	for property in stats.get_property_list():
		if property.usage & PROPERTY_USAGE_GROUP:
			current_group = property['name']
		
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and current_group == group_name:
			out.append(property.name)
	
	return out
