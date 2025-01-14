extends Node

@export var character_spacing = 30

var battler_player = preload("res://scenes/battler.tscn")
var battler_enemy = preload("res://scenes/battler_enemy.tscn")
var player_character_stats = [PlayerStats]
var player_characters = []
var enemy_stats = [EnemyStats]
var enemies = []
var active_character_index = 0
var active_enemy_index = 0
var players_turn = true

func _ready() -> void:
	spawn_players()
	spawn_enemies()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not players_turn:
			return
			
		player_characters[active_character_index].attack(enemies.front())
		if active_character_index == len(player_characters) - 1:
			start_enemy_turn()
		update_active_player( (active_character_index + 1) % len(player_characters))
		
func start_enemy_turn():
	players_turn = false
	enemies[active_enemy_index].attack(player_characters[randi_range(0, len(player_characters) - 1)])
	players_turn = true
	
func update_active_player(new_index):
	player_characters[active_character_index].mark_inactive()
	if not player_characters[new_index].is_alive:
		update_active_player((new_index + 1) % len(player_characters)) 
		return
		
	player_characters[new_index].mark_active()
	active_character_index = new_index
	
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x, $PlayerStart.position.y + character_spacing * i)
		player_characters.append(player_character)
		add_child(player_character)
		
	player_characters[active_character_index].mark_active()

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = battler_enemy.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x, $EnemyStart.position.y + character_spacing * i)
		enemies.append(enemy)
		add_child(enemy)
