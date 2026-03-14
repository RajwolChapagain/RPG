class_name ArrowStorm extends Ability

@export var max_damage: int
@export var damage_faloff_curve: Curve
@export var accuracy_faloff_curve: Curve
@export var arrow_storm: Node
@export var particles: Node
@export var animation_player: AnimationPlayer

func execute(_caster: Battler, target: Battler) -> void:
	arrow_storm.global_position = target.global_position
	particles.emitting = true
	animation_player.play('decal_fade_in')
	await animation_player.animation_finished
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
		'Max Damage': str(max_damage),
	}
	
func _on_arrow_storm_area_entered(area: Area2D) -> void:
	var max_accuracy = 100
	if area.has_method("take_damage"):
		var damage = int(max_damage * damage_faloff_curve.sample(arrow_storm.global_position.distance_to(area.global_position)))
		var accuracy = int(max_accuracy * accuracy_faloff_curve.sample(arrow_storm.global_position.distance_to(area.global_position)))
		area.take_damage(damage, accuracy)
