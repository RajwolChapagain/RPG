extends Area2D

@export var stats: BaseStats
var is_alive = true

signal battler_died

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	
func attack(target) -> void:
	var crit_damage = 30
	var true_damage = stats.attack_damage
	var critting = false
	if (randf() <= (stats.crit / 100.0)):
		true_damage += crit_damage
		critting = true
		
	%AnimationTree.set('parameters/StateMachine/conditions/attacking', true) 
	target.take_damage(true_damage, stats.accuracy, critting)
	
func take_damage(damage: int, accuracy: int, critting: bool = false) -> void:


	var true_dodge_chance = stats.dodge - accuracy
	if randf() <= (true_dodge_chance / 100.0):
		if critting:
			%AnimationTree["parameters/CriticalMiss/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			%AnimationTree["parameters/Dodge/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		return

	if critting:
		%AnimationTree['parameters/CriticalHit/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		
	var true_damage = clamp(damage - stats.defence, 0, damage)
	stats.hp -= true_damage
	stats.hp = clamp(stats.hp, 0, INF)
	%DamageLabel.text = str(-true_damage)
	%AnimationTree["parameters/TakeDamage/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	if (stats.hp == 0):
		die()

func mark_active():
	$Pointer.visible = true
	
func mark_inactive():
	$Pointer.visible = false
	
func die():
	if is_alive:
		battler_died.emit(stats.name)
		is_alive = false
		%AnimationTree["parameters/StateMachine/conditions/dead"] = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		%AnimationTree.set('parameters/StateMachine/conditions/attacking', false)
