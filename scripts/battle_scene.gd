extends Node

@export var character_spacing = 30

var player_character_stats = [PlayerStats]
var player_characters = [Area2D]
var enemy_stats = [EnemyStats]
var enemies = [Area2D]

func _ready() -> void:
	spawn_players()
	spawn_enemies()

func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = Sprite2D.new()
		player_character.texture = player_character_stats[i].battle_sprite
		player_character.position = Vector2($PlayerStart.position.x, $PlayerStart.position.y + character_spacing * i)
		add_child(player_character)

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = Sprite2D.new()
		enemy.texture = enemy_stats[i].battle_sprite
		enemy.position = Vector2($EnemyStart.position.x, $EnemyStart.position.y + character_spacing * i)
		add_child(enemy)
