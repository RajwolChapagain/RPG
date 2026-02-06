class_name Heal extends Ability

@export_range(0, 100) var heal_percentage: float

func execute(_caster: Battler, target: Battler) -> void:
	%HealParticles.global_position = target.global_position
	%HealParticles.emitting = true
	target.stats.hp += int(heal_percentage / 100 * target.stats.max_hp)
	await %HealParticles.finished
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
		'Heal Amount': "%d%% of Max HP" % heal_percentage,
	}
