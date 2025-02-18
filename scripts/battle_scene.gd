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

func _ready() -> void:
	spawn_players()
	spawn_enemies()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not players_turn:
			return
			
		player_characters[active_index].attack(enemies.front())
		
	
func _process(delta: float) -> void:
	if not players_turn and not enemy_is_attacking:
		enemies[active_index].attack(player_characters[randi_range(0, len(player_characters) - 1)])
		
func update_active_battler(new_index):
	var active_team = []
	
	if players_turn:
		active_team = player_characters
	else:
		active_team = enemies
		
	active_team[active_index].mark_inactive()
	
	if not active_team[new_index].is_alive:
		update_turn()
		return
		
	active_team[new_index].mark_active()
	active_index = new_index
	
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x  + character_spacing * i, $PlayerStart.position.y)
		player_characters.append(player_character)
		add_child(player_character)
		
	connect_player_animation_finished_signal()
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
	players_turn = false
	active_index = 0
	enemy_is_attacking = false

func end_enemy_turn() -> void:
	players_turn = true
