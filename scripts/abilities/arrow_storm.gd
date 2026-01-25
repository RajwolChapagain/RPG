class_name ArrowStorm extends Ability

@export var max_damage: int

func execute(_caster: Battler, target: Battler) -> void:
	%ArrowStorm.global_position = target.global_position
	%AnimatedSprite2D.play('default')
	await %AnimatedSprite2D.animation_finished
	ability_finished_execution.emit()
	queue_free()
	
func _on_arrow_storm_area_entered(area: Area2D) -> void:
	var ability_accuracy = 100
	if area.has_method("take_damage"):
		area.take_damage(max_damage, ability_accuracy)
