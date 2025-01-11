extends Resource
class_name PlayerStats

enum types { Archer, Cleric, Knight, Lady, Mage }

@export var type: types
@export var attack_damage: int
@export var hp: int
@export var battle_sprite: Texture2D
