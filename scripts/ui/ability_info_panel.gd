extends Panel

@export var ability_card_scene: PackedScene
@export var ability_images: Dictionary[String, Texture2D]

var ability_stats: Dictionary[String, Dictionary]

func _on_visibility_changed() -> void:
	if visible:
		populate_abilities()
	else:
		for ability_card in %GridContainer.get_children():
			ability_card.queue_free()
		%AbilityStats.visible = false
			
func populate_abilities() -> void:
	for player: Player in GameManager.get_alive_players():
		for ability_scene: PackedScene in player.stats.abilities:
			var ability_card = ability_card_scene.instantiate()
			var ability: Ability = ability_scene.instantiate()
			var ability_image = null
			if ability.ability_name in ability_images:
				ability_image = ability_images[ability.ability_name]
			ability_card.INITIALIZE(ability.ability_name, ability_image, ability.description)
			ability_card.ability_info_button_pressed.connect(on_ability_card_focus_entered)
			ability_card.ability_info_button_released.connect(on_ability_card_focus_exited)
			%GridContainer.add_child(ability_card)
			ability_stats[ability.ability_name] = ability.get_stats_dict()
			ability.queue_free()

func on_ability_card_focus_entered(ability_name: String) -> void:
	%AbilityStats.visible = true
	%AbilityStats.set_stats(ability_name, ability_stats[ability_name])
	
func on_ability_card_focus_exited(ability_name: String) -> void:
	%AbilityStats.visible = false
