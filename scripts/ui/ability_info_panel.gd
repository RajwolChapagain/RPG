extends Panel

@export var ability_card_scene: PackedScene

func _on_visibility_changed() -> void:
	if visible:
		populate_abilities()
	else:
		for ability_card in %GridContainer.get_children():
			ability_card.queue_free()
			
func populate_abilities() -> void:
	for player: Player in GameManager.get_alive_players():
		for ability_scene: PackedScene in player.stats.abilities:
			var ability_card = ability_card_scene.instantiate()
			var ability: Ability = ability_scene.instantiate()
			ability_card.INITIALIZE(ability.ability_name, null, ability.description)
			%GridContainer.add_child(ability_card)
			ability.queue_free()
