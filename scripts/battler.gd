extends Area2D

@export var stats: BaseStats
var is_alive = true

signal battler_died

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	
func attack(target) -> void:
	var crit_damage = 30
	var true_damage = stats.attack_damage
	if (randf() <= (stats.crit / 100.0)):
		true_damage += crit_damage
		print("CRITICAL HIT!!!")
		
	$AnimationPlayer.play("attack")
	target.take_damage(true_damage, stats.accuracy)
	
func take_damage(damage: int, accuracy: int) -> void:
	var true_dodge_chance = stats.dodge - accuracy
	if randf() <= (true_dodge_chance / 100.0):
		print('DODGED!!!')
		return
		
	var true_damage = clamp(damage - stats.defence, 0, damage)
	stats.hp -= true_damage
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
		battler_died.emit(stats.name)
		is_alive = false
		$Sprite2D.self_modulate = Color.DARK_RED
