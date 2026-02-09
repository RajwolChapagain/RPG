class_name Battler
extends Area2D

@export var stats: BaseStats
var status_effects: Array[StatusEffect] = []
var effects_pending_application: Array[StatusEffect] = []
var is_alive = true
var is_player

signal battler_died

func _ready() -> void:
	%Sprite2D.texture = stats.battle_sprite
	set_hit_particle_color()
	
# Returns true if attack hit, false if missed
func attack(target) -> bool:
	var crit_damage = 30
	var true_damage = stats.attack_damage
	var critting = false
	if (randf() <= (stats.crit / 100.0)):
		true_damage += crit_damage
		critting = true
	
	if stats.attack_sprite != null:
		%Sprite2D.texture = stats.attack_sprite
		
	%AnimationTree.set('parameters/StateMachine/conditions/attacking', true) 
	
	return target.take_damage(true_damage, stats.accuracy, critting)
	
# Returns true if damage was taken, false if attack missed
func take_damage(damage: int, accuracy: int, critting: bool = false) -> bool:
	if not is_alive:
		return false
		
	# 0 accuracy doesn't necessarily mean that it will always miss because if say stats.dodge = 20,
	# true_dodge_chance = 20 - 0 = 20
	# So, there's a 20 percent chance that the hit will miss. But 80 that it will hit
	# This also means, if dodge < accuracy, it will never miss
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

func APPLY_EFFECT(effect: StatusEffect) -> void:
	# Check for effect re-application
	for existing_effect: StatusEffect in status_effects:
		if existing_effect.effect_name == effect.effect_name:
			existing_effect.duration_in_ticks += effect.duration_in_ticks
			return
	
	effects_pending_application.append(effect)
	var effect_label: Label = Label.new()
	effect_label.text = effect.effect_name.to_upper()
	effect_label.theme_type_variation = 'ProgressLabel'
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	%StatusEffectLabels.add_child(effect_label)
	
func TICK_EFFECTS_DOWN() -> void:
	var depleted_effect_indices = []
	var i = 0
	for effect: StatusEffect in status_effects:
		effect.duration_in_ticks -= 1
		if effect.duration_in_ticks == 0:
			depleted_effect_indices.append(i)
		i += 1
	
	for index in depleted_effect_indices:
		for label: Label in %StatusEffectLabels.get_children():
			if label.text.to_upper() == status_effects[index].effect_name.to_upper():
				label.queue_free()
				
		status_effects.remove_at(index)
		
	apply_pending_effects()

# Need to create and apply a pending effects queue like this because otherwise,
# the effect gets ticked down immediately after it gets applied
func apply_pending_effects() -> void:
	for effect: StatusEffect in effects_pending_application:
		status_effects.append(effect)
	effects_pending_application.clear()
	
func mark_active():
	$Pointer.visible = true
	var active_slide_direction = Vector2.UP
	if not is_player:
		active_slide_direction = Vector2.DOWN
	
	slide(active_slide_direction)
	
func mark_inactive():
	$Pointer.visible = false
	var inactive_slide_direction = Vector2.DOWN
	if not is_player:
		inactive_slide_direction = Vector2.UP
	
	slide(inactive_slide_direction)
	
func die():
	if is_alive:
		battler_died.emit(stats.name)
		is_alive = false
		%AnimationTree["parameters/StateMachine/conditions/dead"] = true
		%StatusEffectLabels.visible = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		%AnimationTree.set('parameters/StateMachine/conditions/attacking', false)
		%Sprite2D.texture = stats.battle_sprite

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

func slide(direction: Vector2) -> void:
	var slide_distance = 15
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'position', position + (direction * slide_distance), 0.1)

func play_ability_animation() -> void:
	var animation_duration = 0.5
	%Sprite2D.texture = stats.ability_invoke_sprite
	await get_tree().create_timer(animation_duration).timeout
	%Sprite2D.texture = stats.battle_sprite
