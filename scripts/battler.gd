extends Node2D

@export var stats: PlayerStats
var is_alive = true

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	
func attack(target) -> void:
	$AnimationPlayer.play("attack")
	target.take_damage(stats.attack_damage)
	
func take_damage(damage: int) -> void:
	stats.hp -= damage
	
	stats.hp = clamp(stats.hp, 0, INF)
	
	if (stats.hp == 0):
		is_alive = false
		$Sprite2D.self_modulate = Color.DARK_RED
		#queue_free()
	else:
		$AnimationPlayer.play("flash_white")

func mark_active():
	$Pointer.visible = true
	
func mark_inactive():
	$Pointer.visible = false
