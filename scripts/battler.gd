extends Node2D

@export var stats: PlayerStats

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	
func attack(target) -> void:
	target.take_damage(stats.attack_damage)
	
func take_damage(damage: int) -> void:
	stats.hp -= damage
	
	stats.hp = clamp(stats.hp, 0, INF)
	
	if (stats.hp == 0):
		queue_free()
