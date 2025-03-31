extends Resource
class_name BaseStats

@export var name: String
@export var attack_damage: int
@export var max_hp: int
@export var hp: int:
	get:
		return hp
	set(value):
		hp = clamp(value, 0, max_hp)
		
@export var battle_sprite: Texture2D
@export var abilities: Array[PackedScene]
