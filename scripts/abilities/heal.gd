class_name Heal extends Ability

@export var heal: int

func execute(_caster: Battler, target: Battler) -> void:
	%HealParticles.global_position = target.global_position
	%HealParticles.emitting = true
	target.stats.hp += heal
	await %HealParticles.finished
	ability_finished_execution.emit()
	queue_free()
