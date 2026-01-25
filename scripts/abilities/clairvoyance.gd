class_name Clairvoyance extends Ability

signal stats_panel_closed

func execute(_caster: Battler, target: Battler) -> void:
	show_stats(target.stats)
	await stats_panel_closed
	ability_finished_execution.emit()
	queue_free()
	
func show_stats(stats: BaseStats) -> void:
	%StatCard.portraits.sprite_dictionary[stats.name] = stats.battle_sprite
	%StatCard.stats = stats
	%ConfirmButton.grab_focus()

func _on_confirm_button_button_down() -> void:
	stats_panel_closed.emit()
