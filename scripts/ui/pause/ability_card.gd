extends Panel

signal ability_info_button_pressed
signal ability_info_button_released

func INITIALIZE(ability_name: String, ability_image: Texture2D, ability_description: String) -> void:
	%AbilityName.text = ability_name
	if ability_image:
		%AbilityImage.texture = ability_image
	%AbilityDescription.text = ability_description
	
func _on_button_focus_entered() -> void:
	ability_info_button_pressed.emit(%AbilityName.text)

func _on_button_focus_exited() -> void:
	ability_info_button_released.emit(%AbilityName.text)
