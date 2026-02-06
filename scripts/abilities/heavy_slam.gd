class_name HeavySlam extends Ability

@export var damage: int

func execute(_caster: Battler, target: Battler) -> void:
	var accuracy = 100
	target.take_damage(damage, accuracy)
	await get_tree().process_frame
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {'Cost': str(cost)}
