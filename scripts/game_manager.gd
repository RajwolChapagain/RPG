extends Node

var party
var inventory_manager

func get_alive_players() -> Array[Player]:
	if party != null:
		return party.get_players()
	else:
		push_warning('Warning: Party was not declared in the scene tree. Returning empty array.')
		return []

func set_party(party) -> void:
	self.party = party

func set_inventory_manager(inventory_manager) -> void:
	self.inventory_manager = inventory_manager
	
func increase_available_inventory_slots() -> void:
	assert(inventory_manager != null)
	inventory_manager.increase_slots()

func queue_player_for_purging(player_name: String) -> void:
	for player in party.get_players():
		if player.stats.name== player_name:
			player.stats.hp = 0
