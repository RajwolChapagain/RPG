class_name Heal extends Ability

@export var heal_amount: int
@export var heal_particles: Node

func execute(_caster: Battler, target: Battler) -> void:
	heal_particles.global_position = target.global_position
	heal_particles.emitting = true
	target.stats.hp += heal_amount
	await heal_particles.finished
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
		'Heal Amount': "%d HP" % heal_amount,
	}
