class_name Echo extends Ability

@export var resonant_effect: StatusEffect

func execute(_caster: Battler, target: Battler) -> void:
	target.APPLY_EFFECT(resonant_effect.duplicate(true))
	await get_tree().process_frame # This await is so that the delay expected  by battle_scene.gd
								   # between abilty casting and execution is upheld.
								   # Later to be replaced by casting animation completion
	ability_finished_execution.emit()
	queue_free()
	
func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
		'Status Duration': "%d Ticks" % resonant_effect.duration_in_ticks,
	}
