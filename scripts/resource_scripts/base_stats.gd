extends Resource
class_name BaseStats

@export_group('constant') # Untouched by consumables and other modifiers
@export var name: String
@export var battle_sprite: Texture2D
@export var attack_sprite: Texture2D
@export var ability_invoke_sprite: Texture2D

@export_group('modifiable')
@export var attack_damage: int
@export var max_hp: int
@export var hp: int:
	get:
		return hp
	set(value):
		hp = clamp(value, 0, max_hp)
@export var defence: int
@export var crit: int:
	get:
		return crit
	set(value):
		crit = clamp(value, 0, 100)
@export var dodge: int
@export var accuracy: int
@export var ap_per_attack: int = 1
@export var abilities: Array[PackedScene]
