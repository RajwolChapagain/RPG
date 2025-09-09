extends Node

func get_alive_players() -> Array[Player]:
	if get_node("/root/Node/Party")!= null:
		return get_node("/root/Node/Party").get_players()
	else:
		push_warning('Warning: Game Manager did not find Party scene in the tree. Returning empty array.')
		return []
