class_name  HeavySlam extends Ability

@export var damage: int

func execute(_caster: Battler, target: Battler) -> void:
	var accuracy = 100
	target.take_damage(damage, accuracy)
	ability_finished_execution.emit()
	queue_free()
