class_name Clairvoyance extends Ability

signal stats_panel_closed

func execute(_caster: Battler, target: Battler) -> void:
	show_stats(target.stats)
	await stats_panel_closed
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {'Cost': str(cost)}
	
func show_stats(stats: BaseStats) -> void:
	%StatCard.portraits.sprite_dictionary[stats.name] = stats.battle_sprite
	%StatCard.stats = stats
	# Can't call grab_focus immediate because !is_inside_tree() error pops up
	var grab_focus_callable: Callable = Callable(%ConfirmButton, 'grab_focus')
	grab_focus_callable.call_deferred()

func _on_confirm_button_button_down() -> void:
	stats_panel_closed.emit()
