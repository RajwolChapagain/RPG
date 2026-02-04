extends Panel

signal ability_info_button_pressed

func INITIALIZE(ability_name: String, ability_image: Texture2D, ability_description: String) -> void:
	%AbilityName.text = ability_name
	if ability_image:
		%AbilityImage.texture = ability_image
	%AbilityDescription.text = ability_description

func _on_button_pressed() -> void:
	ability_info_button_pressed.emit(%AbilityName.text)
