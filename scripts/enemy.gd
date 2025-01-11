extends Area2D

signal enemy_encountered_player(enemy)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_character"):
		enemy_encountered_player.emit(self)
