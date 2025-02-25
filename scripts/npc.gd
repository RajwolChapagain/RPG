extends Area2D

signal npc_encountered_player(npc)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_character"):
		npc_encountered_player.emit(self)
