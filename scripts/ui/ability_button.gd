extends Button
class_name AbilityButton

@export var dectivated_ap_icon: Texture2D

var ability: Node = null
signal ability_selected(ability)
	
func set_ability(new_ability: Node) -> void:
	ability = new_ability
	%NameLabel.text = ability.ability_name
	%CostLabel.text =  str(ability.cost)
	
func _on_pressed() -> void:
	ability_selected.emit(ability)

func disable_button() -> void:
	disabled = true
	%APIcon.texture = dectivated_ap_icon
	%NameLabel.add_theme_color_override("font_color", Color.DIM_GRAY)
	%CostLabel.add_theme_color_override("font_color", Color.DIM_GRAY)
