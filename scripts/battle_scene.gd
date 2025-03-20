extends Node

@export var character_spacing = 30
@export var player_character_stats : Array[BaseStats]= []
@export var enemy_stats : Array[BaseStats]= []
var battler_player = preload("res://scenes/battler_player.tscn")
var battler_enemy = preload("res://scenes/battler_enemy.tscn")
var player_characters = []
var enemies = []
var active_index = 0
var players_turn = true
var enemy_is_attacking = false
var alive_player_count: int
var alive_enemy_count: int

signal battle_ended

func _ready() -> void:
	%AttackButton.grab_focus()
	spawn_players()
	spawn_enemies()
	alive_player_count = len(player_characters)
	alive_enemy_count = len(enemies)
	initialize_ui()
	
func _process(delta: float) -> void:
	if not players_turn and not enemy_is_attacking:
		attack_random_player()
		
func update_active_battler(new_index):
	var active_team = []
	
	if players_turn:
		active_team = player_characters
	else:
		active_team = enemies
		
	active_team[active_index].mark_inactive()
	
	if not active_team[new_index].is_alive:
		if new_index == len(active_team) - 1:
			if players_turn:
				end_player_turn()
			else:
				end_enemy_turn()
			return
		
		active_index = new_index
		update_turn()
		return
		
	active_team[new_index].mark_active()
	active_index = new_index
	
func on_player_battler_died():
	alive_player_count -= 1
	if alive_player_count == 0:
		end_battle(false)
	
func on_enemy_battler_died():
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
		add_child(player_character)
		
	connect_player_animation_finished_signal()
	connect_player_battler_died_signal()
	player_characters[active_index].mark_active()

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = battler_enemy.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x + character_spacing * i, $EnemyStart.position.y)
		enemies.append(enemy)
		add_child(enemy)
		
	connect_enemy_animation_started_signal()
	connect_enemy_animation_finished_signal()
	connect_enemy_battler_died_signal()
	
func connect_player_animation_finished_signal() -> void:
	for character in player_characters:
		character.get_node("AnimationPlayer").animation_finished.connect(on_animation_finished)

func connect_enemy_animation_started_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationPlayer").animation_started.connect(on_enemy_attack_animation_started)
		
func connect_enemy_animation_finished_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationPlayer").animation_finished.connect(on_animation_finished)
		
func on_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		update_turn()
		
		if not players_turn:
			enemy_is_attacking = false
		
func on_enemy_attack_animation_started(animation: StringName) -> void:
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
		
#endregion initialization

#region: turntaking
func update_turn() -> void:
	if players_turn:
		update_player_turn()
	else:
		update_enemy_turn()
		
func update_player_turn() -> void:
	if active_index == len(player_characters) - 1:
		end_player_turn()
		return
		
	update_active_battler( (active_index + 1) % len(player_characters))
	
func update_enemy_turn() -> void:
	if active_index == len(enemies) - 1:
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
	active_index = 0
	update_active_battler(0)
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
	
func enable_attack_button() -> void:
	%AttackButton.disabled = false
	%AttackButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.grab_focus()
	
func disable_attack_button() -> void:
	%AttackButton.disabled = true
	%AttackButton.set_focus_mode(Control.FOCUS_NONE)

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
		print("Battle won!")
	else:
		print("Battle lost!")
	battle_ended.emit()
