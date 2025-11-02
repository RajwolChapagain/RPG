class_name EnemyStatViewer
extends Control

@export var ability_name: String = 'Clairvoyance'
@export var cost: int = 1

func show_stats(stats: BaseStats) -> void:
	%StatCard.portraits.sprite_dictionary[stats.name] = stats.battle_sprite
	%StatCard.stats = stats
	var callable: Callable = Callable(%ConfirmButton.grab_focus)
	callable.call_deferred()

func _on_confirm_button_button_down() -> void:
	queue_free()
