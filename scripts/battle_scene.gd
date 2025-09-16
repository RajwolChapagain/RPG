extends Node

@export var character_spacing = 30
@export var player_character_stats : Array[BaseStats]= []
@export var enemy_stats : Array[BaseStats]= []
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

func _ready() -> void:
	%AttackButton.grab_focus()
	spawn_players()
	spawn_enemies()
	alive_player_count = len(player_characters)
	alive_enemy_count = len(enemies)
	initialize_ui()
	
func _process(delta: float) -> void:
	update_ui()
	if not players_turn and not enemy_is_attacking:
		attack_random_player()
		
func update_ui() -> void:
	var health_fields = [%HealthBarP1, %HealthBarP2, %HealthBarP3, %HealthBarP4]
	for i in range(len(player_characters)):
		health_fields[i].value = player_characters[i].stats.hp
		
	var hp_labels = [%HPLabel1, %HPLabel2, %HPLabel3, %HPLabel4]
	for i in range(len(player_characters)):
		var string = str(player_characters[i].stats.hp) + "/" + str(player_characters[i].stats.max_hp)
		hp_labels[i].text = string
		
func update_active_battler(new_index):
	var active_team = []
	
	if players_turn:
		active_team = player_characters
	else:
		active_team = enemies
		
	active_team[active_index].mark_inactive()
	
	if not active_team[new_index].is_alive:
		if num_attacked == alive_player_count:
			if players_turn:
				end_player_turn()
			else:
				end_enemy_turn()
			return
		
		active_index = new_index
		advance_turn()
		return
		
	active_team[new_index].mark_active()
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
	
#region: initialization
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x  + character_spacing * i, $PlayerStart.position.y)
		player_characters.append(player_character)
		call_deferred("add_child", player_character)
		
	connect_player_animation_finished_signal()
	connect_player_battler_died_signal()
	active_index = first_attacker_index
	player_characters[active_index].mark_active()

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
		character.get_node("AnimationPlayer").animation_finished.connect(on_player_animation_finished)

func connect_enemy_animation_started_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationPlayer").animation_started.connect(on_enemy_animation_started)
		
func connect_enemy_animation_finished_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationPlayer").animation_finished.connect(on_enemy_animation_finished)
		
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

#region: turntaking
func advance_turn() -> void:
	if players_turn:
		if num_attacked == alive_player_count:
			end_player_turn()
			num_attacked = 0
			return
			
		update_active_battler( (active_index + 1) % len(player_characters))
	else:
		if active_index == len(enemies) - 1: # Inconsistency: players turn is checked by num_attacked
			end_enemy_turn()
			return
			
		update_active_battler( (active_index + 1) % len(enemies))

func end_player_turn() -> void:
	player_characters[active_index].mark_inactive()
	players_turn = false
	enemy_is_attacking = false
	active_index = 0
	update_active_battler(0)
	disable_attack_button()

func end_enemy_turn() -> void:
	enemies[active_index].mark_inactive()
	players_turn = true
	active_index = first_attacker_index
	update_active_battler(active_index)
	enable_attack_button()
	
#endregion: turntaking

#region: attacking

### Player Attacking ###

func _on_attack_button_button_down() -> void:
	if not players_turn or $TargetSelect.is_active():
		return

	$TargetSelect.set_targets(enemies) 
	$TargetSelect.activate()
	disable_attack_button()

func _on_target_select_target_selected(target_index: int) -> void:
	player_characters[active_index].attack(enemies[target_index])
	enable_attack_button()
	await get_tree().process_frame
	$TargetSelect.deactivate()
	num_attacked += 1
	%AbilityPointsContainer.increase_points(1)
	
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
	%AttackButton.grab_focus()

func disable_abilities_button() -> void:
	%AbilitiesButton.disabled = true
	%AbilitiesButton.set_focus_mode(Control.FOCUS_NONE)
	
func on_ability_exited_tree() -> void:
	advance_turn()
	enable_abilities_button()
	
### Enemy Attacking ###

func attack_random_player() -> void:
	enemies[active_index].attack(get_random_alive_player())
	
func get_random_alive_player():
	var alive_players = []
	for character in player_characters:
		if character.is_alive:
			alive_players.append(character)

	return alive_players.pick_random()
	
#endregion: attacking

func end_battle(won: bool) -> void:
	if won:
		%ResultAnnouncementLabel.text = win_text
	else:
		%ResultAnnouncementLabel.text = lose_text
	%ResultAnnouncementLabel.visible = true
	%ResultAnnouncementLabel/AnimationPlayer.play("fade_in")

func _on_abilities_button_button_down() -> void:
	var ability = player_characters[active_index].stats.abilities.pick_random().instantiate()
	if %AbilityPointsContainer.points < ability.cost:
		print("Not enough APs")
		return
	else:
		%AbilityPointsContainer.decrease_points(ability.cost)
		
	disable_abilities_button()
	
	# REFACTOR: Once skill inheritance is in place, we can no longer use character names 
	# 			to distinguish abilities. Use the ability name instead
	
	# Only Magda's ability targets player characters
	if player_characters[active_index].stats.name == "Magda":
		ability.initialize(player_characters)
	# Josephine's ability requires additional initialization parameters
	elif player_characters[active_index].stats.name == "Josephine":
		var picked_enemy_index = randi_range(0, len(enemies) - 1)
		player_characters[active_index].mark_inactive()
		swap_characters(active_index, picked_enemy_index)
	else:
		ability.initialize(enemies)
		
	ability.tree_exited.connect(on_ability_exited_tree)
	add_child(ability)
	ability.trigger_ability()
	num_attacked += 1

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
