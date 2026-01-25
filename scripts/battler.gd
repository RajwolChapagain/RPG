class_name Battler
extends Area2D

@export var stats: BaseStats
var is_alive = true

signal battler_died

func _ready() -> void:
	$Sprite2D.texture = stats.battle_sprite
	set_hit_particle_color()
	
# Returns true if attack hit, false if missed
func attack(target) -> bool:
	var crit_damage = 30
	var true_damage = stats.attack_damage
	var critting = false
	if (randf() <= (stats.crit / 100.0)):
		true_damage += crit_damage
		critting = true
		
	%AnimationTree.set('parameters/StateMachine/conditions/attacking', true) 
	return target.take_damage(true_damage, stats.accuracy, critting)
	
# Returns true if damage was taken, false if attack missed
func take_damage(damage: int, accuracy: int, critting: bool = false) -> bool:
	if not is_alive:
		return false
		
	var true_dodge_chance = stats.dodge - accuracy
	if randf() <= (true_dodge_chance / 100.0):
		if critting:
			%AnimationTree["parameters/CriticalMiss/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			%AnimationTree["parameters/Dodge/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		return false

	if critting:
		%AnimationTree['parameters/CriticalHit/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
		
	var true_damage = clamp(damage - stats.defence, 0, damage)
	stats.hp -= true_damage
	stats.hp = clamp(stats.hp, 0, INF)
	%DamageLabel.text = str(-true_damage)
	%AnimationTree["parameters/TakeDamage/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	if (stats.hp == 0):
		die()
	
	%HitParticles.emitting = true
	return true

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

func set_hit_particle_color() -> void:
	var sum_color = Color(0, 0, 0, 0)
	var num_pixels = 0
	var image = $Sprite2D.texture.get_image()
	for i in image.get_width():
		for j in image.get_height():
			var pixel = image.get_pixel(i,j)
			if pixel.a != 0:
				sum_color.r += pixel.r
				sum_color.g += pixel.g
				sum_color.b += pixel.b
				num_pixels += 1
	
	var avg_color = Color(sum_color.r / num_pixels, sum_color.g / num_pixels, sum_color.b / num_pixels, 1)
	%HitParticles.modulate = avg_color
