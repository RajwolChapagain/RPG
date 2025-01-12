extends Node

@export var character_spacing = 30

var battler_player = preload("res://scenes/battler.tscn")
var battler_enemy = preload("res://scenes/battler_enemy.tscn")
var player_character_stats = [PlayerStats]
var player_characters = []
var enemy_stats = [EnemyStats]
var enemies = []
var active_character_index = 0

func _ready() -> void:
	spawn_players()
	spawn_enemies()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		player_characters[active_character_index].attack(enemies.front())
		
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x, $PlayerStart.position.y + character_spacing * i)
		player_characters.append(player_character)
		add_child(player_character)

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = battler_enemy.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x, $EnemyStart.position.y + character_spacing * i)
		enemies.append(enemy)
		add_child(enemy)
