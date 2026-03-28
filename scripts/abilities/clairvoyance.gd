class_name Clairvoyance extends Ability

@export var stat_card: StatCard
@export var confirm_button: Button

signal stats_panel_closed

func execute(_caster: Battler, target: Battler) -> void:
	show_stats(target.stats)
	await stats_panel_closed
	ability_finished_execution.emit()
	queue_free()

func get_stats_dict() -> Dictionary[String, String]:
	return {
		'Cost': "%d Abilty %s" % [cost, "Point" if cost == 1 else "Points"],
	}
	
func show_stats(stats: BaseStats) -> void:
	stat_card.stats = stats
	# Can't call grab_focus immediate because !is_inside_tree() error pops up
	var grab_focus_callable: Callable = Callable(confirm_button, 'grab_focus')
	grab_focus_callable.call_deferred()

func _on_confirm_button_button_down() -> void:
	stats_panel_closed.emit()
