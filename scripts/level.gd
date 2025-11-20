@abstract class_name Level extends Node

@export var level_number: int = 1

signal level_completed(level_number)

func initialize_party_position(party: Party) -> void:
	party.global_position = get_node("PartyOriginMarker").global_position
	party.reset_player_positions()
