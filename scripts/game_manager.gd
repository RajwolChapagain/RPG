extends Node

var party

func get_alive_players() -> Array[Player]:
	if party != null:
		return party.get_players()
	else:
		push_warning('Warning: Party was not declared in the scene tree. Returning empty array.')
		return []

func set_party(party) -> void:
	self.party = party
