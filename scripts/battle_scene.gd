extends Node

@export var character_spacing = 30
@export var player_character_stats : Array[BaseStats]= []
@export var enemy_stats : Array[BaseStats]= []
@export var ability_button: PackedScene
var battler_player = preload("res://scenes/battler_player.tscn")
var battler_enemy = preload("res://scenes/battler_enemy.tscn")
var player_characters: Array[Node2D] = []
var enemies: Array[Node2D] = []
var active_index = 0
var first_attacker_index = 0
var players_turn = true
var enemy_is_attacking = false
var alive_player_count: int
var alive_enemy_count: int
var num_attacked: int = 0

@export var win_text: String = "Battle Won! :)"
@export var lose_text: String = "Battle Lost! :("

signal battle_ended

func initialize_battle(player_stats: Array[BaseStats], enemy_stats: Array[BaseStats], first_attacker_index: int = 0) -> void:
	self.player_character_stats = player_stats
	self.enemy_stats = enemy_stats
	self.first_attacker_index = first_attacker_index
	
func _ready() -> void:
	%AttackButton.grab_focus()
	spawn_players()
	spawn_enemies()
	alive_player_count = len(player_characters)
	alive_enemy_count = len(enemies)
	initialize_ui()
	
func _process(delta: float) -> void:
	update_ui()
		
func update_ui() -> void:
	var health_fields = [%HealthBarP1, %HealthBarP2, %HealthBarP3, %HealthBarP4]
	for i in range(len(player_characters)):
		health_fields[i].value = player_characters[i].stats.hp
		
	var hp_labels = [%HPLabel1, %HPLabel2, %HPLabel3, %HPLabel4]
	for i in range(len(player_characters)):
		var string = str(player_characters[i].stats.hp) + "/" + str(player_characters[i].stats.max_hp)
		hp_labels[i].text = string
		
# Precondition: new_index points to an alive battler
func update_active_battler(new_index):
	if players_turn:
		player_characters[active_index].mark_inactive()
		player_characters[new_index].mark_active()
	
	active_index = new_index
	
func on_player_battler_died(player_name: String) -> void:
	GameManager.queue_player_for_purging(player_name)
	alive_player_count -= 1
	if alive_player_count == 0:
		end_battle(false)
	
func on_enemy_battler_died(enemy_name: String) -> void:
	alive_enemy_count -= 1
	if alive_enemy_count == 0:
		end_battle(true)
	
#region initialization
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x  + character_spacing * i, $PlayerStart.position.y)
		player_characters.append(player_character)
		call_deferred("add_child", player_character)
		
	connect_player_animation_finished_signal()
	connect_player_battler_died_signal()
	update_active_battler(first_attacker_index)

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = battler_enemy.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x + character_spacing * i, $EnemyStart.position.y)
		enemies.append(enemy)
		call_deferred("add_child", enemy)
		
	connect_enemy_animation_started_signal()
	connect_enemy_animation_finished_signal()
	connect_enemy_battler_died_signal()
	
func connect_player_animation_finished_signal() -> void:
	for character in player_characters:
		character.get_node("AnimationTree").animation_finished.connect(on_player_animation_finished)

func connect_enemy_animation_started_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationTree").animation_started.connect(on_enemy_animation_started)
		
func connect_enemy_animation_finished_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationTree").animation_finished.connect(on_enemy_animation_finished)
		
func on_player_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		advance_turn()
		
func on_enemy_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		advance_turn()
		enemy_is_attacking = false
		
func on_enemy_animation_started(animation: StringName) -> void:
	if animation == "attack":
		enemy_is_attacking = true
	
func connect_player_battler_died_signal() -> void:
	for character in player_characters:
		character.battler_died.connect(on_player_battler_died)
		
func connect_enemy_battler_died_signal() -> void:
	for enemy in enemies:
		enemy.battler_died.connect(on_enemy_battler_died)
		
func initialize_ui() -> void:
	var info_fields = [%P1Info, %P2Info, %P3Info, %P4Info]
	for i in range(len(player_characters), 4):
		info_fields[i].visible = false
		
	initialize_ui_names()
	initialize_hp_bar()
	
func initialize_ui_names() -> void:
	var name_fields = [%NameLabelP1, %NameLabelP2, %NameLabelP3, %NameLabelP4]
	for i in range(len(player_characters)):
		name_fields[i].text = player_characters[i].stats.name
		
func initialize_hp_bar() -> void:
	var hp_bars = [%HealthBarP1, %HealthBarP2, %HealthBarP3, %HealthBarP4]
	for i in range(len(player_characters)):
		hp_bars[i].max_value = player_characters[i].stats.max_hp
		hp_bars[i].value = player_characters[i].stats.hp
	
	# Initialize hp labels
	var hp_labels = [%HPLabel1, %HPLabel2, %HPLabel3, %HPLabel4]
	for i in range(len(player_characters)):
		var string = str(player_characters[i].stats.hp) + "/" + str(player_characters[i].stats.max_hp)
		hp_labels[i].text = string
	
#endregion initialization

#region turntaking
func advance_turn() -> void:
	if players_turn:
		if num_attacked == alive_player_count:
			end_player_turn()
			num_attacked = 0
			return
		
		var next_player_index = active_index
		for i in range(len(player_characters)):
			next_player_index = (next_player_index + 1) % len(player_characters)
			if player_characters[next_player_index].stats.hp != 0:
				break
			
		update_active_battler(next_player_index)
	else:
		if active_index == len(enemies) - 1: # Inconsistency: players turn is checked by num_attacked
											 # Assumes enemies will always attack starting from the first enemy to the left
			end_enemy_turn()
			return
		
		var next_alive_enemy_index = active_index + 1
		for i in range(next_alive_enemy_index, len(enemies)):
			if enemies[next_alive_enemy_index].stats.hp != 0:
				break
			next_alive_enemy_index += 1
		
		if next_alive_enemy_index == len(enemies):
			end_enemy_turn()
		else:
			update_active_battler(next_alive_enemy_index)
		attack_random_player()

func end_player_turn() -> void:
	player_characters[active_index].mark_inactive()
	players_turn = false
	enemy_is_attacking = false
	
	var first_alive_enemy_index = -1
	for enemy in enemies:
		if enemy.stats.hp != 0:
			first_alive_enemy_index += 1
			break
		first_alive_enemy_index += 1
		
	assert(first_alive_enemy_index != -1)
	
	update_active_battler(first_alive_enemy_index)
	disable_attack_button()
	attack_random_player()

func end_enemy_turn() -> void:
	enemies[active_index].mark_inactive()
	players_turn = true
	for i in range(len(player_characters)):
		if player_characters[first_attacker_index].stats.hp != 0:
			break
		first_attacker_index = (first_attacker_index + 1) % len(player_characters)
	update_active_battler(first_attacker_index)
	enable_attack_button()
	
#endregion turntaking

#region attacking

### Player Attacking ###

func _on_attack_button_button_down() -> void:
	if not players_turn or $TargetSelect.is_active():
		return

	%AbilitiesButton.set_pressed(false)
	
	var alive_enemies = []
	for enemy in enemies:
		if enemy.stats.hp != 0:
			alive_enemies.append(enemy)
			
	$TargetSelect.set_targets(alive_enemies) 
	$TargetSelect.activate(attack_alive_enemy)
	disable_attack_button()

func attack_alive_enemy(enemy_index: int) -> void:
	var alive_enemies = []
	for enemy in enemies:
		if enemy.stats.hp != 0:
			alive_enemies.append(enemy)
			
	player_characters[active_index].attack(alive_enemies[enemy_index])
	%AbilityPointsContainer.increase_points(player_characters[active_index].stats.ap_per_attack)
	await get_tree().process_frame
	enable_attack_button()
	num_attacked += 1

func attack_alive_enemy_with_ability(enemy_index: int, ability: Node) -> void:
	var alive_enemies = []
	for enemy in enemies:
		if enemy.stats.hp != 0:
			alive_enemies.append(enemy)
			
	var target_enemies_array: Array[Node2D] = []
	target_enemies_array.append(alive_enemies[enemy_index])
	ability.initialize(target_enemies_array)
	add_child(ability)
	ability.trigger_ability()
	num_attacked += 1
	
func enable_attack_button() -> void:
	%AttackButton.disabled = false
	%AttackButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.grab_focus()
	
func disable_attack_button() -> void:
	%AttackButton.disabled = true
	%AttackButton.set_focus_mode(Control.FOCUS_NONE)

func enable_abilities_button() -> void:
	if get_node_or_null("%AbilitiesButton") == null:
		return
		
	%AbilitiesButton.disabled = false
	%AbilitiesButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.grab_focus()

func disable_abilities_button() -> void:
	%AbilitiesButton.disabled = true
	%AbilitiesButton.set_focus_mode(Control.FOCUS_NONE)
	
func on_ability_exited_tree() -> void:
	advance_turn()
	enable_abilities_button()
	enable_attack_button()
	
### Enemy Attacking ###

# Precondition: active_index points to an alive enemy
func attack_random_player() -> void:
	if enemies[active_index].stats.hp == 0:
		return
	enemies[active_index].attack(get_random_alive_player())
	
func get_random_alive_player():
	var alive_players = []
	for character in player_characters:
		if character.is_alive:
			alive_players.append(character)

	return alive_players.pick_random()
	
#endregion attacking

func end_battle(won: bool) -> void:
	if won:
		%ResultAnnouncementLabel.text = win_text
	else:
		%ResultAnnouncementLabel.text = lose_text
	%ResultAnnouncementLabel.visible = true
	%ResultAnnouncementLabel/AnimationPlayer.play("fade_in")

func _on_abilities_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%PlayerInfos.visible = false
		create_abilities_list()
	else:
		destroy_abilities_list()
		%PlayerInfos.visible = true

func create_abilities_list() -> void:
	for ability_scene in player_characters[active_index].stats.abilities:
		var ability = ability_scene.instantiate()
		var button = ability_button.instantiate() as AbilityButton
		button.set_ability(ability)
		button.ability_selected.connect(on_ability_selected)
		if ability.cost > %AbilityPointsContainer.points:
			button.disabled = true
			
		%AbilitiesContainer.add_child(button)
	
	%AbilitiesContainer.visible = true
	%AbilitiesContainer.get_child(0).grab_focus()
	
func destroy_abilities_list() -> void:
	%AbilitiesContainer.visible = false
	while %AbilitiesContainer.get_child_count() != 0:
		%AbilitiesContainer.remove_child(%AbilitiesContainer.get_child(0))
	
func on_ability_selected(ability: Node) -> void:
	if %AbilityPointsContainer.points < ability.cost:
		print("Not enough APs")
		return
	else:
		%AbilityPointsContainer.decrease_points(ability.cost)
	
	ability.tree_exited.connect(on_ability_exited_tree)
	%AbilitiesButton.set_pressed(false)
	%PlayerInfos.visible = true
	disable_attack_button()
	# Only Heal ability targets player characters
	if ability.ability_name == "Heal":
		ability.initialize(player_characters)
		ability.trigger_ability()
		add_child(ability)
		num_attacked += 1
	# Swap requires additional initialization parameters
	elif ability.ability_name == "Swap":
		var picked_enemy_index = randi_range(0, len(enemies) - 1)
		player_characters[active_index].mark_inactive()
		add_child(ability)
		swap_characters(active_index, picked_enemy_index)
		num_attacked += 1
	else:
		var alive_enemies = []
		for enemy in enemies:
			if enemy.stats.hp != 0:
				alive_enemies.append(enemy)
				
		$TargetSelect.set_targets(alive_enemies) 
		$TargetSelect.activate(attack_alive_enemy_with_ability.bind(ability))
	
func swap_characters(player_index: int, enemy_index: int) -> void:
	var player = player_characters[player_index]
	var enemy = enemies[enemy_index]
	
	enemies[enemy_index] = player
	player_characters[player_index] = enemy
	
	# Swap positions
	var player_pos = player.global_position
	var enemy_pos = enemy.global_position
	player.global_position = enemy_pos
	enemy.global_position = player_pos
	
	player.get_node("AnimationPlayer").animation_finished.disconnect(on_player_animation_finished)
	enemy.get_node("AnimationPlayer").animation_started.disconnect(on_enemy_animation_started)
	enemy.get_node("AnimationPlayer").animation_finished.disconnect(on_enemy_animation_finished)
	
	player.get_node("AnimationPlayer").animation_started.connect(on_enemy_animation_started)
	player.get_node("AnimationPlayer").animation_finished.connect(on_enemy_animation_finished)
	enemy.get_node("AnimationPlayer").animation_finished.connect(on_player_animation_finished)

func _on_result_label_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		battle_ended.emit()
