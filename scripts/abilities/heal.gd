class_name Heal extends Ability

@export_range(0, 100) var heal_percentage: float
@export var heal_particles: Node

func execute(_caster: Battler, target: Battler) -> void:
	heal_particles.global_position = target.global_position
	heal_particles.emitting = true
	target.stats.hp += int(heal_percentage / 100 * target.stats.max_hp)
	await heal_particles.finished
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
		'Heal Amount': "%d%% of Max HP" % heal_percentage,
	}
