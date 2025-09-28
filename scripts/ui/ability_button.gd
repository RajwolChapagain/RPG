extends Button
class_name AbilityButton

var ability: Node = null
signal ability_selected(ability)

func set_ability(ability: Node) -> void:
	self.ability = ability
	text = ability.ability_name

func _on_pressed() -> void:
	ability_selected.emit(ability)
