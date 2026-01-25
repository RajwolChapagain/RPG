@abstract class_name Level extends Node

@export var level_number: int = 1

@warning_ignore("unused_signal")
signal level_completed(level_number)

func initialize_party_position(party: Party) -> void:
	print('Party origin marker position: %s' % %PartyOriginMarker.global_position)
	print('Party  position: %s' % party.global_position)
	party.global_position = %PartyOriginMarker.global_position
	print('After:')
	print('Party  position: %s' % party.global_position)
	party.reset_player_positions()
