extends Area2D

@export var stats: BaseStats
var is_alive = true

signal battler_died

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	
func attack(target) -> void:
	$AnimationPlayer.play("attack")
	target.take_damage(stats.attack_damage)
	print(stats.dodge)
	
func take_damage(damage: int) -> void:
	stats.hp -= damage
	
	stats.hp = clamp(stats.hp, 0, INF)
	
	if (stats.hp == 0):
		die()
	else:
		$AnimationPlayer.play("flash_white")

func mark_active():
	$Pointer.visible = true
	
func mark_inactive():
	$Pointer.visible = false
	
func die():
	if is_alive:
		battler_died.emit()
		is_alive = false
		$Sprite2D.self_modulate = Color.DARK_RED
